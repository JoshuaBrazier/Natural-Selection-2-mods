
if not kCombatVersion then

    GUIMarineBuyMenu.kButtonGroupFrame_Labeled_x1     = PrecacheAsset("ui/buymenu_marine/button_group_frame_labeled_x1.dds")

    local kExtraWeaponGroupButtonPositions =
    {
        [GUIMarineBuyMenu.kButtonGroupFrame_Labeled_x1] =

        {
            Vector(4, 4, 0),
            Vector(4, 4, 0),
            Vector(4, 4, 0),
            Vector(4, 4, 0),
        }
    }

    local kTechIdInfo = debug.getupvaluex(GUIMarineBuyMenu._GetButtonPixelCoordinatesForTechID, "kTechIdInfo")

    function GUIMarineBuyMenu:CreateExtraButton()
        local x1ButtonPositions = kExtraWeaponGroupButtonPositions[self.kButtonGroupFrame_Labeled_x1]

        local paddingX = 105
        local buttonNumUtility = 0
        local buttonNumPrimary = 0
        local buttonHeight = 117
        for i, extraButtonsTechID in pairs(kTechIdInfo) do
            if extraButtonsTechID.techItem then
                local extraweaponGroupBottomRight = self:CreateAnimatedGraphicItem()
                extraweaponGroupBottomRight:SetIsScaling(false)
                if  extraButtonsTechID.itemType == "Utility" then
                    extraweaponGroupBottomRight:SetPosition(Vector(585, 780 + buttonHeight* (buttonNumUtility), 0))
                    buttonNumUtility = buttonNumUtility + 1
                elseif extraButtonsTechID.itemType == "Primary" then
                    extraweaponGroupBottomRight:SetPosition(Vector(paddingX, 780 + buttonHeight * (buttonNumPrimary) , 0))
                    buttonNumPrimary = buttonNumPrimary + 1
                end
                extraweaponGroupBottomRight:SetTexture(self.kButtonGroupFrame_Labeled_x1)
                extraweaponGroupBottomRight:SetSizeFromTexture()
                extraweaponGroupBottomRight:SetOptionFlag(GUIItem.CorrectScaling)
                self.background:AddChild(extraweaponGroupBottomRight)

                self:_InitializeWeaponGroup(extraweaponGroupBottomRight, x1ButtonPositions,   {extraButtonsTechID.techItem})
            end
        end
    end

    local old__SetDetailsSectionTechId = GUIMarineBuyMenu._SetDetailsSectionTechId
    function GUIMarineBuyMenu:_SetDetailsSectionTechId(techId, techCost)
        local techIdBigPicture = kTechIdInfo[techId]

        if self.hostStructure:isa("PrototypeLab") then
            old__SetDetailsSectionTechId(self, techId, techCost)
        else
            if techIdBigPicture.techItem then
                self.bigPicture:SetTexture(techIdBigPicture.BigInfoPath)
                old__SetDetailsSectionTechId(self, techId, techCost)
            else
                self.bigPicture:SetTexture(self.kArmoryBigPicturesTexture)
                old__SetDetailsSectionTechId(self, techId, techCost)
            end

        end
    end

    local old__CreateButton = GUIMarineBuyMenu._CreateButton
    function GUIMarineBuyMenu:_CreateButton(parent, buttonPosition, buttonTechId)
        local data = old__CreateButton(self, parent, buttonPosition, buttonTechId)
        local techButtonData = kTechIdInfo[buttonTechId]

        if techButtonData.techItem then
            data.Button:SetTexture(techButtonData.ButtonPath)
        end
        return data
    end

    -- function GUIMarineBuyMenu:SetHostStructure(hostStructure)

    --     assert(hostStructure)

    --     self.hostStructure = hostStructure

    --     if self.hostStructure:isa("Armory") then
    --         self:CreateArmoryUI()
    --         self:CreateExtraButton()
    --     elseif self.hostStructure:isa("PrototypeLab") then
    --         self:CreatePrototypeLabUI()
    --     else
    --         Log(string.format("ERROR: No generator found for class: %s", self.hostStructure:GetClassName()))
    --     end

    -- end

    local kTechIdInfo = debug.getupvaluex(GUIMarineBuyMenu._GetButtonPixelCoordinatesForTechID, "kTechIdInfo")

    local kSuppressedShotgunNewButtonImage = PrecacheAsset("ui/buymenu_marine/SuppressedShotgun_button.dds")
    local kSuppressedShotgunNewBigInfoImage = PrecacheAsset("ui/buymenu_marine/SuppressedShotgun_bigicon.dds")

    table.insert(kTechIdInfo,
            kTechId.SuppressedShotgun,
            {
                ButtonTextureIndex = 0,
                BigPictureIndex = 0,
                Description = "It's Joshua-Boo-Boos's Suppressed Shotgun, what more could you want? A quieter, weaker and faster firing shotgun with a nice camouflage! :D",
                ButtonPath = kSuppressedShotgunNewButtonImage,
                BigInfoPath = kSuppressedShotgunNewBigInfoImage,
                techItem = kTechId.SuppressedShotgun,
                itemType = "Utility",
                Stats = {   LifeFormDamage = 0.2,
                            StructureDamage = 0.2,
                            Range = 0.7,
                }
            }
    )

else
	local bigIconWidth = 400
	local bigIconHeight = 300
	local smallIconHeight = 80
	local smallIconWidth = 80
    local SuppressedShotgunTexture = PrecacheAsset("ui/buymenu_marine/SuppressedShotguncombaticon.dds")

    local kSuppressedShotgunNewBigInfoImage = PrecacheAsset("ui/buymenu_marine/SuppressedShotgun_bigicon.dds")

	local old_InitializeItemButtons = GUIMarineBuyMenu._InitializeItemButtons
    function GUIMarineBuyMenu:_InitializeItemButtons()
        old_InitializeItemButtons(self)
        
        if self.itemButtons then
            for i, item in ipairs(self.itemButtons) do
                if item.TechId == kTechId.SuppressedShotgun then
                    item.Button:SetTexture(SuppressedShotgunTexture)
                    item.Button:SetTexturePixelCoordinates(0, 0, smallIconWidth, smallIconHeight)
                end
            end
        end
    end
    
    local old_InitializeEquipped = GUIMarineBuyMenu._InitializeEquipped
    function GUIMarineBuyMenu:_InitializeEquipped()
        old_InitializeEquipped(self)
        
        if self.equipped then
            for i, item in ipairs(self.equipped) do
                if item.TechId == kTechId.SuppressedShotgun then
                    item.Graphic:SetTexture(SuppressedShotgunTexture)
                    item.Graphic:SetTexturePixelCoordinates(0, 0, smallIconWidth, smallIconHeight)
                end
            end
        end
    end
    
    local old_UpdateContent = GUIMarineBuyMenu._UpdateContent
    function GUIMarineBuyMenu:_UpdateContent(deltaTime)
        old_UpdateContent(self, deltaTime)
        local techId = self.hoverItem
        if not self.hoverItem then
            techId = self.selectedItem
        end
        if techId ~= nil and techId ~= kTechId.None and self.portrait then
            if techId == kTechId.SuppressedShotgun then
                self.portrait:SetTexture(kSuppressedShotgunNewBigInfoImage)
                self.portrait:SetTexturePixelCoordinates(0, 0, bigIconWidth, bigIconHeight)
            else
                self.portrait:SetTexture(GUIMarineBuyMenu.kBigIconTexture)
            end
        end
    end
end