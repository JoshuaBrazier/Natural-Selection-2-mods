-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\GUIExoHUD.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

local kSheet1 = PrecacheAsset("ui/exosuit_HUD1.dds")
PrecacheAsset("ui/exosuit_HUD2.dds")
PrecacheAsset("ui/exosuit_HUD3.dds")
local kSheet4 = PrecacheAsset("ui/exosuit_HUD4.dds")
local kCrosshair = PrecacheAsset("ui/exo_crosshair.dds")

local kTargetingReticuleCoords = { 185, 0, 354, 184 }

local kStaticRingCoords = { 0, 490, 800, 1000 }

local kInfoBarRightCoords = { 354, 184, 800, 368 }
local kInfoBarLeftCoords = { 354, 0, 800, 184 }

local kInnerRingCoords = { 0, 316, 330, 646 }

local kOuterRingCoords = { 0, 0, 800, 490 }

local kCrosshairCoords = { 495, 403, 639, 547 }

local kTrackEntityDistance = 30

local function CoordsToSize(coords)
    return GUIScale(Vector(coords[3] - coords[1], coords[4] - coords[2], 0))
end

local time_now = 0
local time_to_scan = 5
local bool_text = "OFF"
GUIExoHUD.current_target = nil

class 'GUIExoHUD' (GUIAnimatedScript)

function GUIExoHUD:Initialize()

    GUIAnimatedScript.Initialize(self, 0)

    self.updateInterval = 0

    local center = Vector(Client.GetScreenWidth() / 2, Client.GetScreenHeight() / 2, 0)
    
    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetPosition(Vector(0, 0, 0))
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor(Color(1, 1, 1, 0))
    
    self.crosshair = GUIManager:CreateGraphicItem()
    self.crosshair:SetTexture(kCrosshair)
    self.crosshair:SetSize(GUIScale(Vector(64, 64, 0)))
    self.crosshair:SetPosition(center-GUIScale(32))
    self.crosshair:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.crosshair)
    
    local leftInfoBar = GUIManager:CreateGraphicItem()
    leftInfoBar:SetTexture(kSheet1)
    leftInfoBar:SetTexturePixelCoordinates(GUIUnpackCoords(kInfoBarLeftCoords))
    local size = CoordsToSize(kInfoBarLeftCoords)
    leftInfoBar:SetSize(size)
    leftInfoBar:SetPosition(Vector(center.x - size.x, 0, 0))
    leftInfoBar:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(leftInfoBar)
    
    local rightInfoBar = GUIManager:CreateGraphicItem()
    rightInfoBar:SetTexture(kSheet1)
    rightInfoBar:SetTexturePixelCoordinates(GUIUnpackCoords(kInfoBarRightCoords))
    size = CoordsToSize(kInfoBarRightCoords)
    rightInfoBar:SetSize(size)
    rightInfoBar:SetPosition(Vector(center.x, 0, 0))
    rightInfoBar:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(rightInfoBar)
    
    self.leftInfoBar = leftInfoBar
    self.rightInfoBar = rightInfoBar

    self.staticRing = GUIManager:CreateGraphicItem()
    self.staticRing:SetTexture(kSheet4)
    self.staticRing:SetTexturePixelCoordinates(GUIUnpackCoords(kStaticRingCoords))
    size = CoordsToSize(kStaticRingCoords)
    self.staticRing:SetSize(size)
    self.staticRing:SetPosition(center - size / 2)
    self.staticRing:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.staticRing)
    
    self.innerRing = GUIManager:CreateGraphicItem()
    self.innerRing:SetTexture(kSheet1)
    self.innerRing:SetTexturePixelCoordinates(GUIUnpackCoords(kInnerRingCoords))
    size = CoordsToSize(kInnerRingCoords)
    self.innerRing:SetSize(size)
    self.innerRing:SetPosition(center - size / 2)
    self.innerRing:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.innerRing)
    
    self.outerRing = GUIManager:CreateGraphicItem()
    self.outerRing:SetTexture(kSheet4)
    self.outerRing:SetTexturePixelCoordinates(GUIUnpackCoords(kOuterRingCoords))
    size = CoordsToSize(kOuterRingCoords)
    self.outerRing:SetSize(size)
    self.outerRing:SetPosition(center - size / 2)
    self.outerRing:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(self.outerRing)
    
    self.targetcrosshair = GUIManager:CreateGraphicItem()
    self.targetcrosshair:SetTexture(kSheet1)
    self.targetcrosshair:SetTexturePixelCoordinates(GUIUnpackCoords(kCrosshairCoords))
    size = CoordsToSize(kCrosshairCoords)
    self.targetcrosshair:SetSize(size)
    self.targetcrosshair:SetLayer(kGUILayerPlayerHUDForeground1)
    self.targetcrosshair:SetIsVisible(false)
    self.background:AddChild(self.targetcrosshair)
    
    self.targets = { }

    self.siege_mode_display = self:CreateAnimatedTextItem()
    self.siege_mode_display:SetFontName(GUIMarineHUD.kTextFontName)
    self.siege_mode_display:SetTextAlignmentX(GUIItem.Align_Min)
    self.siege_mode_display:SetTextAlignmentY(GUIItem.Align_Min)
    self.siege_mode_display:SetLayer(kGUILayerPlayerHUDForeground2)
    self.siege_mode_display:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.siege_mode_display:SetColor(kBrightColor)
    self.siege_mode_display:SetFontIsBold(true)
    self.siege_mode_display:SetText("EXO SIEGE MODE TEXT INITIALIZE")
    self.background:AddChild(self.siege_mode_display)

    self.enemies_text_credits = self:CreateAnimatedTextItem()
    self.enemies_text_credits:SetFontName(GUIMarineHUD.kTextFontName)
    self.enemies_text_credits:SetTextAlignmentX(GUIItem.Align_Min)
    self.enemies_text_credits:SetTextAlignmentY(GUIItem.Align_Min)
    self.enemies_text_credits:SetLayer(kGUILayerPlayerHUDForeground2)
    self.enemies_text_credits:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.enemies_text_credits:SetColor(kBrightColor)
    self.enemies_text_credits:SetFontIsBold(true)
    self.enemies_text_credits:SetText("ALTERRA COMBAT GUI")
    self.background:AddChild(self.enemies_text_credits)

    self.enemies_text_skulk = self:CreateAnimatedTextItem()
    self.enemies_text_skulk:SetFontName(GUIMarineHUD.kTextFontName)
    self.enemies_text_skulk:SetTextAlignmentX(GUIItem.Align_Min)
    self.enemies_text_skulk:SetTextAlignmentY(GUIItem.Align_Min)
    self.enemies_text_skulk:SetLayer(kGUILayerPlayerHUDForeground2)
    self.enemies_text_skulk:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.enemies_text_skulk:SetColor(kBrightColor)
    self.enemies_text_skulk:SetFontIsBold(true)
    self.enemies_text_skulk:SetText("SKULK:   REQUIRES DATA")
    self.background:AddChild(self.enemies_text_skulk)

    self.enemies_text_gorge = self:CreateAnimatedTextItem()
    self.enemies_text_gorge:SetFontName(GUIMarineHUD.kTextFontName)
    self.enemies_text_gorge:SetTextAlignmentX(GUIItem.Align_Min)
    self.enemies_text_gorge:SetTextAlignmentY(GUIItem.Align_Min)
    self.enemies_text_gorge:SetLayer(kGUILayerPlayerHUDForeground2)
    self.enemies_text_gorge:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.enemies_text_gorge:SetColor(kBrightColor)
    self.enemies_text_gorge:SetFontIsBold(true)
    self.enemies_text_gorge:SetText("GORGE:   REQUIRES DATA")
    self.background:AddChild(self.enemies_text_gorge)

    self.enemies_text_lerk = self:CreateAnimatedTextItem()
    self.enemies_text_lerk:SetFontName(GUIMarineHUD.kTextFontName)
    self.enemies_text_lerk:SetTextAlignmentX(GUIItem.Align_Min)
    self.enemies_text_lerk:SetTextAlignmentY(GUIItem.Align_Min)
    self.enemies_text_lerk:SetLayer(kGUILayerPlayerHUDForeground2)
    self.enemies_text_lerk:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.enemies_text_lerk:SetColor(kBrightColor)
    self.enemies_text_lerk:SetFontIsBold(true)
    self.enemies_text_lerk:SetText("LERK:   REQUIRES DATA")
    self.background:AddChild(self.enemies_text_lerk)

    self.enemies_text_fade = self:CreateAnimatedTextItem()
    self.enemies_text_fade:SetFontName(GUIMarineHUD.kTextFontName)
    self.enemies_text_fade:SetTextAlignmentX(GUIItem.Align_Min)
    self.enemies_text_fade:SetTextAlignmentY(GUIItem.Align_Min)
    self.enemies_text_fade:SetLayer(kGUILayerPlayerHUDForeground2)
    self.enemies_text_fade:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.enemies_text_fade:SetColor(kBrightColor)
    self.enemies_text_fade:SetFontIsBold(true)
    self.enemies_text_fade:SetText("FADE:   REQUIRES DATA")
    self.background:AddChild(self.enemies_text_fade)

    self.enemies_text_onos = self:CreateAnimatedTextItem()
    self.enemies_text_onos:SetFontName(GUIMarineHUD.kTextFontName)
    self.enemies_text_onos:SetTextAlignmentX(GUIItem.Align_Min)
    self.enemies_text_onos:SetTextAlignmentY(GUIItem.Align_Min)
    self.enemies_text_onos:SetLayer(kGUILayerPlayerHUDForeground2)
    self.enemies_text_onos:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.enemies_text_onos:SetColor(kBrightColor)
    self.enemies_text_onos:SetFontIsBold(true)
    self.enemies_text_onos:SetText("ONOS:   REQUIRES DATA")
    self.background:AddChild(self.enemies_text_onos)

    -- self.ammo_left = Minigun.ammo_left
    -- self.ammo_right = Minigun.ammo_right
    -- self.ammo_siege_left = Minigun.ammo_siege_left
    -- self.ammo_siege_right = Minigun.ammo_siege_right

    -- self.ammo_left_text = self:CreateAnimatedTextItem()
    -- self.ammo_left_text:SetFontName(GUIMarineHUD.kTextFontName)
    -- self.ammo_left_text:SetTextAlignmentX(GUIItem.Align_Min)
    -- self.ammo_left_text:SetTextAlignmentY(GUIItem.Align_Min)
    -- self.ammo_left_text:SetLayer(kGUILayerPlayerHUDForeground2)
    -- self.ammo_left_text:SetFontName(GUIMarineHUD.kCommanderFontName)
    -- self.ammo_left_text:SetColor(kBrightColor)
    -- self.ammo_left_text:SetFontIsBold(true)
    -- self.ammo_left_text:SetText("AMMO LEFT: " .. self.ammo_left)
    -- self.background:AddChild(self.ammo_left_text)

    -- self.ammo_right_text = self:CreateAnimatedTextItem()
    -- self.ammo_right_text:SetFontName(GUIMarineHUD.kTextFontName)
    -- self.ammo_right_text:SetTextAlignmentX(GUIItem.Align_Min)
    -- self.ammo_right_text:SetTextAlignmentY(GUIItem.Align_Min)
    -- self.ammo_right_text:SetLayer(kGUILayerPlayerHUDForeground2)
    -- self.ammo_right_text:SetFontName(GUIMarineHUD.kCommanderFontName)
    -- self.ammo_right_text:SetColor(kBrightColor)
    -- self.ammo_right_text:SetFontIsBold(true)
    -- self.ammo_right_text:SetText("AMMO RIGHT: " .. self.ammo_right)
    -- self.background:AddChild(self.ammo_right_text)

    -- self.ammo_siege_left_text = self:CreateAnimatedTextItem()
    -- self.ammo_siege_left_text:SetFontName(GUIMarineHUD.kTextFontName)
    -- self.ammo_siege_left_text:SetTextAlignmentX(GUIItem.Align_Min)
    -- self.ammo_siege_left_text:SetTextAlignmentY(GUIItem.Align_Min)
    -- self.ammo_siege_left_text:SetLayer(kGUILayerPlayerHUDForeground2)
    -- self.ammo_siege_left_text:SetFontName(GUIMarineHUD.kCommanderFontName)
    -- self.ammo_siege_left_text:SetColor(kBrightColor)
    -- self.ammo_siege_left_text:SetFontIsBold(true)
    -- self.ammo_siege_left_text:SetText("SIEGE AMMO LEFT: " .. self.ammo_siege_left)
    -- self.background:AddChild(self.ammo_siege_left_text)

    -- self.ammo_siege_right_text = self:CreateAnimatedTextItem()
    -- self.ammo_siege_right_text:SetFontName(GUIMarineHUD.kTextFontName)
    -- self.ammo_siege_right_text:SetTextAlignmentX(GUIItem.Align_Min)
    -- self.ammo_siege_right_text:SetTextAlignmentY(GUIItem.Align_Min)
    -- self.ammo_siege_right_text:SetLayer(kGUILayerPlayerHUDForeground2)
    -- self.ammo_siege_right_text:SetFontName(GUIMarineHUD.kCommanderFontName)
    -- self.ammo_siege_right_text:SetColor(kBrightColor)
    -- self.ammo_siege_right_text:SetFontIsBold(true)
    -- self.ammo_siege_right_text:SetText("SIEGE AMMO RIGHT: " .. self.ammo_siege_right)
    -- self.background:AddChild(self.ammo_siege_right_text)

    self.missile_help_text = self:CreateAnimatedTextItem()
    self.missile_help_text:SetFontName(GUIMarineHUD.kTextFontName)
    self.missile_help_text:SetTextAlignmentX(GUIItem.Align_Min)
    self.missile_help_text:SetTextAlignmentY(GUIItem.Align_Min)
    self.missile_help_text:SetLayer(kGUILayerPlayerHUDForeground2)
    self.missile_help_text:SetFontName(GUIMarineHUD.kCommanderFontName)
    self.missile_help_text:SetColor(kBrightColor)
    self.missile_help_text:SetFontIsBold(true)
    self.missile_help_text:SetText("Press 4 to fire two missiles!")
    self.background:AddChild(self.missile_help_text)

    self.playerStatusIcons = CreatePlayerStatusDisplay(self, kGUILayerPlayerHUDForeground1, self.background, kTeam1Index)

    self.visible = true

    self:Reset()

end

function GUIExoHUD:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    GUI.DestroyItem(self.background)
    self.background = nil

    if self.playerStatusIcons then
        self.playerStatusIcons:Destroy()
        self.playerStatusIcons = nil
    end


end

function GUIExoHUD:SetIsVisible(isVisible)
    
    self.visible = isVisible
    self.background:SetIsVisible(isVisible)
    self.playerStatusIcons:SetIsVisible(isVisible)

end

function GUIExoHUD:GetIsVisible()
    
    return self.visible
    
end

local function GetFreeTargetItem(self)

    for r = 1, #self.targets do
    
        local target = self.targets[r]
        if not target:GetIsVisible() then
        
            target:SetIsVisible(true)
            return target
            
        end
        
    end
    
    local target = GUIManager:CreateGraphicItem()
    target:SetTexture(kSheet1)
    target:SetTexturePixelCoordinates(GUIUnpackCoords(kTargetingReticuleCoords))
    local size = CoordsToSize(kTargetingReticuleCoords)
    target:SetSize(size)
    target:SetLayer(kGUILayerPlayerHUDForeground1)
    self.background:AddChild(target)
    
    table.insert(self.targets, target)
    
    return target
    
end

local function Gaussian(mean, stddev, x) 

    local variance2 = stddev * stddev * 2.0
    local term = x - mean
    return math.exp(-(term * term) / variance2) / math.sqrt(math.pi * variance2)
    
end

local function UpdateTargets(self)

    for r = 1, #self.targets do
        self.targets[r]:SetIsVisible(false)
    end
    
    if not PlayerUI_GetHasMinigun() then
        return
    end
    
    local trackEntities = GetEntitiesWithinRange("Alien", PlayerUI_GetOrigin(), kTrackEntityDistance)
    local closestToCrosshair
    local closestDistToCrosshair = math.huge
    local closestToCrosshairScale
    local closestToCrosshairOpacity
    for t = 1, #trackEntities do
    
        local trackEntity = trackEntities[t]
        local player = Client.GetLocalPlayer()
        local inFront = player:GetViewCoords().zAxis:DotProduct(GetNormalizedVector(trackEntity:GetModelOrigin() - player:GetEyePos())) > 0
        -- Only really looks good on Skulks currently.
        if inFront and trackEntity:GetIsAlive() and trackEntity:isa("Skulk") and not trackEntity:GetIsCloaked() then
        
            local trace = Shared.TraceRay(player:GetEyePos(), trackEntity:GetModelOrigin(), CollisionRep.Move, PhysicsMask.All, EntityFilterOne(player))
            if trace.entity == trackEntity then
            
                local targetItem = GetFreeTargetItem(self)
                
                local _, max = trackEntity:GetModelExtents()
                local distance = trackEntity:GetDistance(PlayerUI_GetOrigin())
                local scalar = max:GetLength() / distance * 8
                local size = CoordsToSize(kTargetingReticuleCoords)
                local scaledSize = size * scalar
                targetItem:SetSize(scaledSize)
                
                local targetScreenPos = Client.WorldToScreen(trackEntity:GetModelOrigin())
                targetItem:SetPosition(targetScreenPos - scaledSize / 2)
                
                local opacity = math.min(1, Gaussian(0.5, 0.1, distance / kTrackEntityDistance))
                
                -- Factor distance to the crosshair into opacity.
                local distToCrosshair = (targetScreenPos - Vector(Client.GetScreenWidth() / 2, Client.GetScreenHeight() / 2, 0)):GetLength()
                opacity = opacity * (1 - (distToCrosshair / 300))
                
                targetItem:SetColor(Color(1, 1, 1, opacity))
                
                if distToCrosshair < closestDistToCrosshair then
                
                    closestDistToCrosshair = distToCrosshair
                    closestToCrosshair = targetScreenPos
                    closestToCrosshairScale = scalar
                    closestToCrosshairOpacity = opacity
                    
                end
                
            end
            
        end
        
    end
    
    if closestToCrosshair ~= nil and closestDistToCrosshair < 50 then
    
        self.targetcrosshair:SetIsVisible(true)
        local size = CoordsToSize(kCrosshairCoords) * (0.75 + (0.25 * ((math.sin(Shared.GetTime() * 7) + 1) / 2)))
        local scaledSize = size * closestToCrosshairScale
        self.targetcrosshair:SetSize(scaledSize)
        self.targetcrosshair:SetPosition(closestToCrosshair - scaledSize / 2)
        self.targetcrosshair:SetColor(Color(1, 1, 1, closestToCrosshairOpacity))
        
    else
        self.targetcrosshair:SetIsVisible(false)
    end
    
end

function GUIExoHUD:Update(deltaTime)

    PROFILE("GUIExoHUD:Update")

    local parent = Client.GetLocalPlayer()
    -- if parent:GetHasMinigun() then
    --     self.ammo_left = Minigun.ammo_left
    --     self.ammo_right = Minigun.ammo_right
    --     self.ammo_siege_left = Minigun.ammo_siege_left
    --     self.ammo_siege_right = Minigun.ammo_siege_right
    -- end

    local exo_player = Client.GetLocalPlayer()
    self.siege_mode = exo_player.siege_mode

    local fullMode = Client.GetHudDetail() == kHUDMode.Full

    if fullMode then
    
        self.ringRotation = self.ringRotation or 0
        self.lastPlayerYaw = self.lastPlayerYaw or PlayerUI_GetYaw()

        local currentYaw = PlayerUI_GetYaw()
        self.ringRotation = self.ringRotation + (GetAnglesDifference(self.lastPlayerYaw, currentYaw) * 0.25)
        self.lastPlayerYaw = currentYaw
        
        self.innerRing:SetRotation(Vector(0, 0, -self.ringRotation))
        self.outerRing:SetRotation(Vector(0, 0, self.ringRotation))

    end
    
    self.innerRing:SetIsVisible(fullMode)
    self.outerRing:SetIsVisible(fullMode)
    self.leftInfoBar:SetIsVisible(fullMode)
    self.rightInfoBar:SetIsVisible(fullMode)
   

	local _, timePassedPercent = PlayerUI_GetShowGiveDamageIndicator()
	
	local color = Color(1, 0.5 + timePassedPercent * 0.5, 0.5 + timePassedPercent * 0.5, 1 )
	self.staticRing:SetColor(color)    
	self.innerRing:SetColor(color)
	self.outerRing:SetColor(color)
   
    self.staticRing:SetIsVisible(fullMode)
    
    UpdateTargets(self)

    -- Update player status icons
    local playerStatusIcons = {
        ParasiteState = PlayerUI_GetPlayerParasiteState(),
        ParasiteTime = PlayerUI_GetPlayerParasiteTimeRemaining(),
        NanoShieldState = PlayerUI_GetPlayerNanoShieldState(),
        NanoShieldTime = PlayerUI_GetNanoShieldTimeRemaining(),
        CatPackState = PlayerUI_GetPlayerCatPackState(),
        CatPackTime = PlayerUI_GetCatPackTimeRemaining(),
        Corroded = PlayerUI_GetIsCorroded(),
        BeingWelded = PlayerUI_IsBeingWelded(),
    }

    -- Updates animations
    GUIAnimatedScript.Update(self, deltaTime)
    self.playerStatusIcons:Update(deltaTime, playerStatusIcons, fullMode)

    if exo_player:GetHasMinigun() then

        -- exo_player.closest_target = exo_player.closest_target -- Try to update the closest target value to stop the error of entity no longer existing when the entity dies

        -- if exo_player.closest_target then

        --     if exo_player.closest_target[2]:isa("Skulk") then
        --         self.missile_help_text:SetText("Locked Target: Skulk")
        --     elseif exo_player.closest_target[2]:isa("Gorge") then
        --         self.missile_help_text:SetText("Locked Target: Gorge")
        --     elseif exo_player.closest_target[2]:isa("Lerk") then
        --         self.missile_help_text:SetText("Locked Target: Lerk")
        --     elseif exo_player.closest_target[2]:isa("Fade") then
        --         self.missile_help_text:SetText("Locked Target: Fade")
        --     elseif exo_player.closest_target[2]:isa("Onos") then
        --         self.missile_help_text:SetText("Locked Target: Onos")
        --     end

        -- else

            self.missile_help_text:SetText("Press 4 to fire two missiles!")

        -- end

        if self.siege_mode then
            bool_text = "ON"
            -- self.ammo_left_text:SetIsVisible(false)
            -- self.ammo_right_text:SetIsVisible(false)
            -- self.ammo_siege_left_text:SetText("SIEGE AMMO LEFT: " .. self.ammo_siege_left)
            -- self.ammo_siege_right_text:SetText("SIEGE AMMO RIGHT: " .. self.ammo_siege_right)
            -- self.ammo_siege_left_text:SetIsVisible(true)
            -- self.ammo_siege_right_text:SetIsVisible(true)
        else
            bool_text = "OFF"
            -- self.ammo_siege_left_text:SetIsVisible(false)
            -- self.ammo_siege_right_text:SetIsVisible(false)
            -- self.ammo_left_text:SetText("AMMO LEFT: " .. self.ammo_left)
            -- self.ammo_right_text:SetText("AMMO RIGHT: " .. self.ammo_right)
            -- self.ammo_left_text:SetIsVisible(true)
            -- self.ammo_right_text:SetIsVisible(true)
        end

        if exo_player.siege_mode_timer_now > exo_player.siege_mode_timer then
            self.siege_mode_display:SetText("SIEGE MODE (R):   " .. bool_text .. " (0)")
        else
            self.siege_mode_display:SetText("SIEGE MODE (R):   " .. bool_text .. string.format(" (%.1f)", exo_player.siege_mode_timer - exo_player.siege_mode_timer_now))
        end

    end

    local player = Client.GetLocalPlayer()
    if player and player:isa("Exo") then
        time_now = Shared.GetTime()
        if time_now >= time_to_scan then
            time_to_scan = time_now + 9 - player.weaponUpgradeLevel
            StartSoundEffectOnEntity(Scan.kScanSound, player)
            local could_be_cloaked_skulks_table = GetEntitiesForTeamWithinRange("Skulk", kTeam2Index, player:GetOrigin(), 20)
            local could_be_cloaked_gorges_table = GetEntitiesForTeamWithinRange("Gorge", kTeam2Index, player:GetOrigin(), 20) 
            local could_be_cloaked_lerks_table = GetEntitiesForTeamWithinRange("Lerk", kTeam2Index, player:GetOrigin(), 20)
            local could_be_cloaked_fades_table = GetEntitiesForTeamWithinRange("Fade", kTeam2Index, player:GetOrigin(), 20)
            local could_be_cloaked_oni_table = GetEntitiesForTeamWithinRange("Onos", kTeam2Index, player:GetOrigin(), 20)
            local number_of_uncloaked_skulks = 0
            local number_of_uncloaked_gorges = 0
            local number_of_uncloaked_lerks = 0
            local number_of_uncloaked_fades = 0
            local number_of_uncloaked_oni = 0

            if #could_be_cloaked_skulks_table > 0 then
                for skulk = 1, #could_be_cloaked_skulks_table do
                    if could_be_cloaked_skulks_table[skulk]:GetCloakFraction() < 0.5 then
                        number_of_uncloaked_skulks = number_of_uncloaked_skulks + 1
                    end
                end
            end

            if #could_be_cloaked_gorges_table > 0 then
                for gorge = 1, #could_be_cloaked_gorges_table do
                    if could_be_cloaked_gorges_table[gorge]:GetCloakFraction() < 0.5 then
                        number_of_uncloaked_gorges = number_of_uncloaked_gorges + 1
                    end
                end
            end

            if #could_be_cloaked_lerks_table > 0 then
                for lerk = 1, #could_be_cloaked_lerks_table do
                    if could_be_cloaked_lerks_table[lerk]:GetCloakFraction() < 0.5 then
                        number_of_uncloaked_lerks = number_of_uncloaked_lerks + 1
                    end
                end
            end

            if #could_be_cloaked_fades_table > 0 then
                for fade = 1, #could_be_cloaked_fades_table do
                    if could_be_cloaked_fades_table[fade]:GetCloakFraction() < 0.5 then
                        number_of_uncloaked_fades = number_of_uncloaked_fades + 1
                    end
                end
            end

            if #could_be_cloaked_oni_table > 0 then
                for onos = 1, #could_be_cloaked_oni_table do
                    if could_be_cloaked_oni_table[onos]:GetCloakFraction() < 0.5 then
                        number_of_uncloaked_oni = number_of_uncloaked_oni + 1
                    end
                end
            end

            

            self.enemies_text_credits:SetText("ALTERRA COMBAT GUI")
            if number_of_uncloaked_skulks > 0 then
                self.enemies_text_skulk:SetColor(Color(1,0,0,1))
            else
                self.enemies_text_skulk:SetColor(Color(0,1,0,1))
            end
            self.enemies_text_skulk:SetText("Skulk:                 " .. string.format("%02d", number_of_uncloaked_skulks))
            if number_of_uncloaked_gorges > 0 then
                self.enemies_text_gorge:SetColor(Color(1,0,0,1))
            else
                self.enemies_text_gorge:SetColor(Color(0,1,0,1))
            end
            self.enemies_text_gorge:SetText("Gorge:                " .. string.format("%02d", number_of_uncloaked_gorges))
            if number_of_uncloaked_lerks > 0 then
                self.enemies_text_lerk:SetColor(Color(1,0,0,1))
            else
                self.enemies_text_lerk:SetColor(Color(0,1,0,1))
            end
            self.enemies_text_lerk:SetText("Lerk:                  " .. string.format("%02d", number_of_uncloaked_lerks))
            if number_of_uncloaked_fades > 0 then
                self.enemies_text_fade:SetColor(Color(1,0,0,1))
            else
                self.enemies_text_fade:SetColor(Color(0,1,0,1))
            end
            self.enemies_text_fade:SetText("Fade:                  " .. string.format("%02d", number_of_uncloaked_fades))
            if number_of_uncloaked_oni > 0 then
                self.enemies_text_onos:SetColor(Color(1,0,0,1))
            else
                self.enemies_text_onos:SetColor(Color(0,1,0,1))
            end
            self.enemies_text_onos:SetText("Onos:                 " .. string.format("%02d", number_of_uncloaked_oni))
        end

    end

end

function GUIExoHUD:Reset()
    self.playerStatusIcons:Reset(self.scale)

    local exo_player = Client.GetLocalPlayer()
    self.siege_mode_display:SetText("SIEGE MODE (R):   " .. bool_text)

    if exo_player:GetHasMinigun() then
        self.siege_mode_display:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 100) * self.scale), Client.GetScreenHeight() - (325 * self.scale), 0) * (1/self.scale))
        self.siege_mode_display:SetScale(GetScaledVector())
        self.siege_mode_display:SetFontIsBold(true)

        -- self.ammo_left_text:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 674) * self.scale), Client.GetScreenHeight() - (325 * self.scale), 0) * (1/self.scale))
        -- self.ammo_left_text:SetScale(GetScaledVector())
        -- self.ammo_left_text:SetFontIsBold(true)

        -- self.ammo_right_text:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 1074) * self.scale), Client.GetScreenHeight() - (325 * self.scale), 0) * (1/self.scale))
        -- self.ammo_right_text:SetScale(GetScaledVector())
        -- self.ammo_right_text:SetFontIsBold(true)

        -- self.ammo_siege_left_text:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 660) * self.scale), Client.GetScreenHeight() - (325 * self.scale), 0) * (1/self.scale))
        -- self.ammo_siege_left_text:SetScale(GetScaledVector())
        -- self.ammo_siege_left_text:SetFontIsBold(true)

        -- self.ammo_siege_right_text:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 1060) * self.scale), Client.GetScreenHeight() - (325 * self.scale), 0) * (1/self.scale))
        -- self.ammo_siege_right_text:SetScale(GetScaledVector())
        -- self.ammo_siege_right_text:SetFontIsBold(true)

        self.missile_help_text:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 822) * self.scale), Client.GetScreenHeight() - (280 * self.scale), 0) * (1/self.scale))
        self.missile_help_text:SetScale(GetScaledVector())
        self.missile_help_text:SetFontIsBold(true)
    end

    if exo_player:GetHasRailgun() then
        self.siege_mode_display:SetIsVisible(false)
        -- self.ammo_left_text:SetIsVisible(false)
        -- self.ammo_right_text:SetIsVisible(false)
        -- self.ammo_siege_left_text:SetIsVisible(false)
        -- self.ammo_siege_right_text:SetIsVisible(false)
        self.missile_help_text:SetIsVisible(false)
    elseif exo_player:GetHasMinigun() then

        if exo_player.siege_mode then
            -- self.ammo_left_text:SetIsVisible(false)
            -- self.ammo_right_text:SetIsVisible(false)
            -- self.ammo_siege_left_text:SetIsVisible(true)
            -- self.ammo_siege_right_text:SetIsVisible(true)
        else
            -- self.ammo_siege_left_text:SetIsVisible(false)
            -- self.ammo_siege_right_text:SetIsVisible(false)
            -- self.ammo_left_text:SetIsVisible(true)
            -- self.ammo_right_text:SetIsVisible(true)
        end

        self.siege_mode_display:SetIsVisible(true)
        self.missile_help_text:SetIsVisible(true)

    end

    self.enemies_text_credits:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 115) * self.scale), Client.GetScreenHeight() - (545 * self.scale), 0) * (1/self.scale))
    self.enemies_text_credits:SetScale(GetScaledVector())
    self.enemies_text_credits:SetFontIsBold(true)
    self.enemies_text_credits:SetIsVisible(true)
    
    self.enemies_text_skulk:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 120) * self.scale), Client.GetScreenHeight() - (500 * self.scale), 0) * (1/self.scale))
    self.enemies_text_skulk:SetScale(GetScaledVector())
    self.enemies_text_skulk:SetFontIsBold(true)
    self.enemies_text_skulk:SetIsVisible(true)

    self.enemies_text_gorge:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 120) * self.scale), Client.GetScreenHeight() - (470 * self.scale), 0) * (1/self.scale))
    self.enemies_text_gorge:SetScale(GetScaledVector())
    self.enemies_text_gorge:SetFontIsBold(true)
    self.enemies_text_gorge:SetIsVisible(true)
    
    self.enemies_text_lerk:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 120) * self.scale), Client.GetScreenHeight() - (440 * self.scale), 0) * (1/self.scale))
    self.enemies_text_lerk:SetScale(GetScaledVector())
    self.enemies_text_lerk:SetFontIsBold(true)
    self.enemies_text_lerk:SetIsVisible(true)
    
    self.enemies_text_fade:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 120) * self.scale), Client.GetScreenHeight() - (410 * self.scale), 0) * (1/self.scale))
    self.enemies_text_fade:SetScale(GetScaledVector())
    self.enemies_text_fade:SetFontIsBold(true)
    self.enemies_text_fade:SetIsVisible(true)
    
    self.enemies_text_onos:SetPosition(Vector(Client.GetScreenWidth() - ((1920 - 120) * self.scale), Client.GetScreenHeight() - (380 * self.scale), 0) * (1/self.scale))
    self.enemies_text_onos:SetScale(GetScaledVector())
    self.enemies_text_onos:SetFontIsBold(true)
    self.enemies_text_onos:SetIsVisible(true)
    
end

function GUIExoHUD:OnResolutionChanged(oldX, oldY, newX, newY)

    self:Reset()

    self:Uninitialize()
    self:Initialize()
    
end