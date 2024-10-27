function Plugin:CreateChatbox()
	local UIScale = SGUI.LinearScale( Vector( 1, 1, 1 ) ) * self.Config.Scale
	local ScalarScale = SGUI.LinearScale( 1 ) * self.Config.Scale

	local ScreenWidth, ScreenHeight = SGUI.GetScreenSize()
	ScreenWidth = ScreenWidth * self.Config.Scale
	ScreenHeight = ScreenHeight * self.Config.Scale

	local FourToThreeHeight = ( ScreenWidth / 4 ) * 3
	-- Use a more boxy box for 4:3 monitors.
	if FourToThreeHeight == ScreenHeight then
		local WidthMult = 0.72
		UIScale.x = UIScale.x * WidthMult
		ScalarScale = ScalarScale * ( WidthMult + 1 ) * 0.5
	end

	self.UIScale = UIScale
	self.ScalarScale = ScalarScale

	self.Font, self.MessageTextScale = ChatAPI.GetOptimalFontScale( ScreenHeight )
	self.TextScale = self.MessageTextScale
	self:SetFontSizeInPixels( self.Config.FontSizeInPixels )

	local Opacity = self.Config.Opacity
	UpdateOpacity( self, Opacity )

	local Pos = self.Config.Pos
	local ChatBoxPos
	local PanelSize = VectorMultiply( LayoutData.Sizes.ChatBox, UIScale )
	-- Keep the default position fixed as the GUIChat position can move depending on the team.
	local DefaultPos = SGUI.LinearScale( Vector2( 100, -430 ) ) - Vector2( 0, 100 * UIScale.y )

	if not Pos.x or not Pos.y then
		ChatBoxPos = DefaultPos
	else
		ChatBoxPos = Vector( Pos.x, Pos.y, 0 )
	end

	ChatBoxPos.x = Clamp( ChatBoxPos.x, 0, ScreenWidth - PanelSize.x )
	ChatBoxPos.y = Clamp( ChatBoxPos.y, -ScreenHeight + PanelSize.y, -PanelSize.y )

	local Border = SGUI:Create( "Panel" )
	Border:SetupFromTable{
		DebugName = "ChatBoxWindow",
		Anchor = "BottomLeft",
		Size = PanelSize,
		Pos = ChatBoxPos,
		Skin = Skin,
		Draggable = true
	}

	-- Double click the title bar to return it to the default position.
	function Border:ReturnToDefaultPos()
		self:SetPos( DefaultPos )
		self:OnDragFinished( DefaultPos )
	end

	function Border.GetMouseBounds( Border )
		local Size = Border:GetSize()
		if SGUI.IsValid( self.SettingsPanel ) and self.SettingsPanel:GetIsVisible() then
			-- If the settings is visible, the mouse bounds need to include it (as it's outside the window bounds).
			Size.x = Size.x + self.SettingsPanel:GetSize().x
			return Size
		end
		return Size
	end

	-- If, for some reason, there's an error in a panel hook, then this is removed.
	-- We don't want to leave the mouse showing if that happens.
	Border:CallOnRemove( function()
		if self.IgnoreRemove then return end

		if self.Visible then
			SGUI:EnableMouse( false )
			self.Visible = false
			self.GUIChat:SetIsVisible( true )
		end

		TableEmpty( self.Messages )
	end )

	self.MainPanel = Border

	local PaddingUnit = Scaled( LayoutData.Sizes.ChatBoxPadding, ScalarScale )
	local Padding = Spacing( PaddingUnit, PaddingUnit, PaddingUnit, PaddingUnit )

	local ChatBoxLayout = SGUI.Layout:CreateLayout( "Vertical", {
		Padding = Padding
	} )

	local function UpdateVanillaChatHistoryPos( Pos )
		if not self.Config.MoveVanillaChat then return end

		-- Update the external chat history position to match the chatbox.
		local AbsolutePadding = PaddingUnit:GetValue()
		self.GUIChat:SetScreenOffset( Pos + Vector2( AbsolutePadding * 2, AbsolutePadding * 2 ) )
	end
	self.UpdateVanillaChatHistoryPos = UpdateVanillaChatHistoryPos

	UpdateVanillaChatHistoryPos( ChatBoxPos )

	-- Update our saved position on drag finish.
	function Border.OnDragFinished( Panel, Pos )
		self.Config.Pos.x = Pos.x
		self.Config.Pos.y = Pos.y

		UpdateVanillaChatHistoryPos( Pos )

		self:SaveConfig()
	end

	-- Panel for messages.
	local Box = SGUI:Create( "Panel", Border )
	local ScrollbarPos = LayoutData.Positions.Scrollbar * UIScale.x
	ScrollbarPos.x = Ceil( ScrollbarPos.x )
	Box:SetupFromTable{
		DebugName = "ChatBoxContainer",
		ScrollbarPos = ScrollbarPos,
		ScrollbarWidth = Ceil( 8 * UIScale.x ),
		ScrollbarHeightOffset = 0,
		Scrollable = true,
		HorizontalScrollingEnabled = false,
		AllowSmoothScroll = self.Config.SmoothScroll,
		StickyScroll = true,
		Skin = Skin,
		StyleName = "MessageList",
		AutoHideScrollbar = true,
		Layout = SGUI.Layout:CreateLayout( "Vertical", {
			Elements = self.Messages,
			Padding = Padding
		} ),
		Fill = true,
		Margin = Spacing( 0, 0, 0, PaddingUnit )
	}
	Box.BufferAmount = PaddingUnit:GetValue()
	ChatBoxLayout:AddElement( Box )

	local EmojiAutoCompletePattern = ":([^:%s]-)$"
	local function InsertEmojiFromCompletion( EmojiName )
		local CaretPos = self.TextEntry:GetCaretPos()
		local TextBehindCaret = self.TextEntry:GetTextBetween( 1, CaretPos )

		local EmojiMatch = StringMatch( TextBehindCaret, EmojiAutoCompletePattern )
		if not EmojiMatch or not StringStartsWith( EmojiName, EmojiMatch ) then return end

		local TextToInsert = StringSub( EmojiName, #EmojiMatch + 1 )..":"

		-- Avoid inserting a second space if there's one in front of the caret already.
		local TextAfterCaret = self.TextEntry:GetTextBetween( CaretPos + 1, CaretPos + 1 )
		if StringSub( TextAfterCaret, 1, 1 ) ~= " " then
			TextToInsert = TextToInsert.." "
		end

		self.TextEntry:InsertTextAtCaret( TextToInsert )

		Hook.Broadcast( "OnChatBoxEmojiSelected", self, EmojiName )
	end

	do
		local AutoCompleteSize = Units.Integer( Units.GUIScaled( 40 ) )
		local PaddingSize = Units.Integer( Units.GUIScaled( 4 ) )

		local EmojiAutoCompletePanel = SGUI:Create( EmojiAutoComplete, Box )
		EmojiAutoCompletePanel:SetupFromTable{
			PositionType = SGUI.PositionType.ABSOLUTE,
			TopOffset = Units.Percentage.ONE_HUNDRED - AutoCompleteSize,
			AutoSize = Units.UnitVector( Units.Percentage.ONE_HUNDRED, AutoCompleteSize ),
			IsVisible = false,
			Padding = Units.Spacing( PaddingSize, 0, PaddingSize, 0 )
		}
		EmojiAutoCompletePanel:AddPropertyChangeListener( "SelectedEmojiName", function( Panel, EmojiName )
			if not EmojiName then return end

			Panel:SetIsVisible( false )

			InsertEmojiFromCompletion( EmojiName )
		end )

		self.EmojiAutoComplete = EmojiAutoCompletePanel
	end

	self.ChatBox = Box

	local SettingsButtonSize = LayoutData.Sizes.SettingsButton
	local TextEntryRowHeight = Scaled( SettingsButtonSize, ScalarScale )
	local TextEntryLayout = SGUI.Layout:CreateLayout( "Horizontal", {
		AutoSize = UnitVector( Percentage.ONE_HUNDRED, TextEntryRowHeight ),
		Fill = false
	} )
	ChatBoxLayout:AddElement( TextEntryLayout )

	local Font = self:GetFont()
	local IconFont, IconScale = SGUI.FontManager.GetFontForAbsoluteSize(
		SGUI.FontFamilies.Ionicons,
		Scaled( 32, self.UIScale.y ):GetValue()
	)

	do
		local Elements = SGUI:BuildTree( {
			Parent = Border,
			{
				ID = "TextEntryIconBackground",
				Class = "Row",
				Props = {
					DebugName = "ChatBoxTextEntryIconBackground",
					AutoSize = UnitVector(
						TextEntryRowHeight + PaddingUnit,
						Percentage.ONE_HUNDRED
					),
					Padding = Spacing( 0, 0, PaddingUnit, 0 ),
					StyleName = "TextEntryIconBackground"
				},
				Children = {
					{
						ID = "TextEntryIcon",
						Class = "Label",
						Props = {
							DebugName = "ChatBoxTextEntryIcon",
							Text = SGUI.Icons.Ionicons.Speakerphone,
							Font = IconFont,
							TextScale = IconScale,
							TextInheritsParentAlpha = false,
							Alignment = SGUI.LayoutAlignment.CENTRE,
							CrossAxisAlignment = SGUI.LayoutAlignment.CENTRE
						}
					}
				}
			}
		} )

		TextEntryLayout:AddElement( Elements.TextEntryIconBackground )

		self.TextEntryIconBackground = Elements.TextEntryIconBackground
		self.TextEntryIcon = Elements.TextEntryIcon
	end

	-- Where messages are entered.
	local TextEntry = SGUI:Create( "RichTextEntry", Border )
	TextEntry:SetupFromTable{
		DebugName = "ChatBoxTextEntry",
		Text = "",
		StickyFocus = true,
		Skin = Skin,
		Font = Font,
		Fill = true,
		MaxLength = kMaxChatLength,
		TextParser = function( Text )
			local ParsedText = Hook.Call( "ParseChatBoxText", self, Text )
			if IsType( ParsedText, "table" ) then return ParsedText end

			return { TextElement( Text ) }
		end
	}
	if self.TextScale ~= 1 then
		TextEntry:SetTextScale( self.TextScale )
	end

	TextEntryLayout:AddElement( TextEntry )

	-- Send the message when the client presses enter.
	function TextEntry:OnEnter()
		local Text = self:GetText()
		if SGUI.IsValid( Plugin.EmojiAutoComplete ) and Plugin.EmojiAutoComplete:GetIsVisible() then
			local EmojiName = Plugin.EmojiAutoComplete:ResolveSelectedEmojiName()
			if EmojiName then
				InsertEmojiFromCompletion( EmojiName )
			end

			Plugin.EmojiAutoComplete:SetIsVisible( false )

			return
		end

		-- Don't go sending blank messages.
		if #Text > 0 and StringContainsNonUTF8Whitespace( Text ) then
			Shine.SendNetworkMessage(
				"ChatClient",
				BuildChatClientMessage( Plugin.TeamChat, StringUTF8Sub( Text, 1, kMaxChatLength ) ),
				true
			)

			if Client then
				if chatMessage == "!rtd" then
					local player = Client.GetLocalPlayer()
					if player and player.GetIsAlive then
						if player:GetIsAlive() then
							local id = player:GetId()
							local RTD_Data = { entId = tostring(id) }
							Client.SendNetworkMessage("RTD", RTD_Data, true)
		
							-- Shared.Message("CLIENT SENT NETWORK MESSAGE RTD WITH ID " .. player:GetId())
						end
		
					end
		
				end
			end
			
		end

		self:SetText( "" )
		self:ResetUndoState()

		Plugin:DestroyAutoCompletePanel()

		if Plugin.Config.AutoClose then
			Plugin:CloseChat()
		end
	end

	function TextEntry:OnEscape()
		Plugin:CloseChat()
		return true
	end

	-- We don't want to allow characters after hitting the max length message.
	function TextEntry:ShouldAllowChar( Char )
		local Text = self:GetText()

		if self:IsAtMaxLength() then
			return false
		end

		-- We also don't want the player's chat button bind making it into the text entry.
		if ( Plugin.OpenTime or 0 ) + 0.05 > Clock() then
			return false
		end
	end

	local OldOnTab = TextEntry.OnTab
	function TextEntry.OnTab( TextEntry )
		if SGUI.IsValid( self.EmojiAutoComplete ) and self.EmojiAutoComplete:GetIsVisible() then
			self.EmojiAutoComplete:MoveSelection( SGUI:IsShiftDown() and -1 or 1 )
			return
		end

		return OldOnTab( TextEntry )
	end

	function TextEntry.OnUnhandledKey( TextEntry, Key, Down )
		if Down and ( Key == InputKey.Down or Key == InputKey.Up ) then
			self:ScrollAutoComplete( Key == InputKey.Down and 1 or -1 )
		end
	end

	local function UpdateEmojiAutoComplete( TextEntry )
		if not SGUI.IsValid( self.EmojiAutoComplete ) then return end

		if not self.Config.AutoCompleteEmoji then
			self.EmojiAutoComplete:SetIsVisible( false )
			return
		end

		local TextBehindCaret = TextEntry:GetTextBetween( 1, TextEntry:GetCaretPos() )
		local Emoji = StringMatch( TextBehindCaret, EmojiAutoCompletePattern )
		if not Emoji or #Emoji < 2 then
			self.EmojiAutoComplete:SetIsVisible( false )
			return
		end

		local Results = Hook.Call( "OnChatBoxEmojiAutoComplete", self, Emoji )
		if not IsType( Results, "table" ) or #Results == 0 then
			self.EmojiAutoComplete:SetIsVisible( false )
			return
		end

		self.EmojiAutoComplete:SetIsVisible( true )
		self.EmojiAutoComplete:SetEmoji( TableSlice( Results, 1, 5 ) )
		self.EmojiAutoComplete:SetSelectedIndex( 1 )
		self.EmojiAutoComplete:SetSelectedEmojiName( nil )
	end

	self.UpdateEmojiAutoComplete = UpdateEmojiAutoComplete

	-- Watch all text changes for emoji auto-complete to ensure it's hidden if the text is wiped.
	TextEntry:AddPropertyChangeListener( "Text", UpdateEmojiAutoComplete )

	function TextEntry.OnTextChanged( TextEntry, OldText, NewText )
		self:AutoCompleteCommand( NewText )
	end

	self:SetupAutoComplete( TextEntry )

	self.TextEntry = TextEntry

	do
		local EmojiButton = SGUI:Create( "Button", Border )
		EmojiButton:SetupFromTable{
			DebugName = "ChatBoxEmojiButton",
			Text = SGUI.Icons.Ionicons.HappyOutline,
			Skin = Skin,
			Font = IconFont,
			AutoSize = UnitVector(
				TextEntryRowHeight,
				Percentage.ONE_HUNDRED
			),
			Margin = Spacing( PaddingUnit, 0, 0, 0 ),
			TextInheritsParentAlpha = false,
			Tooltip = self:GetPhrase( "EMOJI_PICKER_TOOLTIP" ),
			IsVisible = false
		}
		EmojiButton:SetTextScale( IconScale )
		TextEntryLayout:AddElement( EmojiButton )

		self.EmojiButton = EmojiButton

		local function OnEmojiPicked( Picker, EmojiName )
			if not EmojiName then return end

			local FormatString = ":%s:"
			local TextAfterCaret = self.TextEntry:GetTextBetween( self.TextEntry:GetCaretPos() + 1 )
			if StringSub( TextAfterCaret, 1, 1 ) ~= " " then
				FormatString = ":%s: "
			end

			self.TextEntry:InsertTextAtCaret( StringFormat( FormatString, EmojiName ), {
				-- Only insert full emoji, if there's no more room, don't insert anything.
				SkipIfAnyCharBlocked = true
			} )

			Hook.Broadcast( "OnChatBoxEmojiSelected", self, EmojiName )
		end

		local RemovalFrameNumber
		local function OnPickerRemoved()
			RemovalFrameNumber = SGUI.FrameNumber()

			self.TextEntry:RequestFocus()

			if not SGUI.IsValid( EmojiButton ) then return end

			EmojiButton:RemoveStylingState( "Open" )
		end

		self.OpenEmojiPicker = function( self, SkipAnim )
			if SGUI.IsValid( self.EmojiPicker ) then return end

			local EmojiList = Hook.Call( "OnChatBoxEmojiPickerOpen", self )
			if not IsType( EmojiList, "table" ) or #EmojiList == 0 then return end

			EmojiButton:AddStylingState( "Open" )

			local Picker = SGUI:Create( EmojiPicker )
			Picker:SetPadding( Spacing.Uniform( Units.GUIScaled( 4 ) ) )

			local PickerSize = Vector2(
				Units.GUIScaled( 8 + 48 * 6 ):GetValue(),
				Units.GUIScaled( 8 + 48 * 6 + 4 + 32 ):GetValue()
			)
			Picker:SetSize( PickerSize )

			local ScreenWidth, ScreenHeight = SGUI.GetScreenSize()
			local Pos = EmojiButton:GetScreenPos() + Vector2( EmojiButton:GetSize().x, 0 )
			if Pos.x + PickerSize.x > ScreenWidth then
				Pos.x = ScreenWidth - PickerSize.x
			end
			if Pos.y + PickerSize.y > ScreenHeight then
				Pos.y = ScreenHeight - PickerSize.y
			end
			Picker:SetPos( Pos )
			Picker:SetSkin( Skin )
			Picker:InvalidateLayout( true )
			Picker:SetSearchPlaceholderText( self:GetPhrase( "EMOJI_SEARCH_PLACEHOLDER_TEXT" ) )
			Picker:SetEmojiList( EmojiList )
			Picker.Elements.SearchInput:RequestFocus()
			Picker:CallOnRemove( OnPickerRemoved )

			if not SkipAnim then
				Picker:ApplyTransition( {
					Type = "Move",
					StartValue = Pos - Vector2( EmojiButton:GetSize().x, 0 ),
					EndValue = Pos,
					Duration = 0.15
				} )
				Picker:ApplyTransition( {
					Type = "AlphaMultiplier",
					StartValue = 0,
					EndValue = 1,
					Duration = 0.15
				} )
			end

			Picker.OnEmojiSelected = OnEmojiPicked

			self.EmojiPicker = Picker
		end

		function EmojiButton.DoClick()
			-- Don't re-open if the button was the cause of the old picker's removal.
			if RemovalFrameNumber == EmojiButton:GetLastMouseDownFrameNumber() then return end

			self:OpenEmojiPicker()
		end
	end

	local SettingsButton = SGUI:Create( "Button", Border )
	SettingsButton:SetupFromTable{
		DebugName = "ChatBoxSettingsButton",
		Text = SGUI.Icons.Ionicons.GearB,
		Skin = Skin,
		Font = IconFont,
		AutoSize = UnitVector(
			TextEntryRowHeight,
			Percentage.ONE_HUNDRED
		),
		Margin = Spacing( PaddingUnit, 0, 0, 0 ),
		TextInheritsParentAlpha = false
	}
	SettingsButton:SetTextScale( IconScale )

	function SettingsButton:DoClick()
		return Plugin:OpenSettings( Border, UIScale, ScalarScale )
	end

	SettingsButton:SetTooltip( self:GetPhrase( "SETTINGS_TOOLTIP" ) )

	TextEntryLayout:AddElement( SettingsButton )

	self.SettingsButton = SettingsButton

	Border:SetLayout( ChatBoxLayout )
	Border:InvalidateLayout( true )
	Border:InvalidateMouseState( true )

	return true
end