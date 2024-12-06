-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIShotgunDisplay.lua
--
-- Created by: Max McGuire (max@unknownworlds.com)
--
-- Displays the ammo counter for the shotgun.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")

-- Global state that can be externally set to adjust the display.
weaponClip     = 0
weaponVariant  = 1
weaponAmmo     = 0
weaponAuxClip  = 0
globalTime     = 0
lowAmmoWarning = true

cartridge_type = ""
distance_to_target = 0

bulletDisplay  = nil

class 'GUIShotgunDisplay'

function GUIShotgunDisplay:Initialize()

    self.weaponClip     = 0
    self.weaponVariant  = 1
    self.weaponAmmo     = 0
    self.weaponClipSize = 6
    self.globalTime     = 0
    self.lowAmmoWarning = true

    self.cartridge_type = ""
    self.distance_to_target = 0
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(256, 128, 0) )
    self.background:SetPosition( Vector(0, 0, 0))
    self.background:SetTexture("ui/TSF Logo.dds")
    
    self.lowAmmoOverlay = GUIManager:CreateGraphicItem()
    self.lowAmmoOverlay:SetSize( Vector(256, 128, 0) )
    self.lowAmmoOverlay:SetPosition( Vector(0, 0, 0))    
    self.background:AddChild(self.lowAmmoOverlay)
    
    self.clipText, self.clipTextBg = self:CreateItem(35, 66)
    self.ammoText, self.ammoTextBg = self:CreateItem(118, 66)
    self.cart_type_gui, self.cart_type_guiBg = self:CreateItem(209, 33)

    self.distance_to_enemy_GUI, self.distance_to_enemy_GUIBg = self:CreateItem(209, 99)
    --self.distance_to_enemy_GUI:SetFontName("fonts/AgencyFB_large_bold.fnt")
    self.distance_to_enemy_GUI:SetText("N/A")
    --self.distance_to_enemy_GUIBg:SetFontName("fonts/AgencyFB_large_bold.fnt")
    self.distance_to_enemy_GUIBg:SetText("N/A")
    self.distance_to_enemy_GUI:SetScale(Vector(0.61, 0.91, 0))
    self.distance_to_enemy_GUIBg:SetScale(Vector(0.61, 0.91, 0))
    

    -- self.clipText, self.clipTextBg = self:CreateItem(52, 66)
    -- self.ammoText, self.ammoTextBg = self:CreateItem(177, 66)

    self.clipText:SetScale(Vector(0.8, 1, 0))
    self.clipTextBg:SetScale(Vector(0.8, 1, 0))
    self.ammoText:SetScale(Vector(0.8, 1, 0))
    self.ammoTextBg:SetScale(Vector(0.8, 1, 0))

    self.cart_type_gui:SetScale(Vector(0.65, 1, 0))
    self.cart_type_guiBg:SetScale(Vector(0.65, 1, 0))
    
    local slash, slashBg = self:CreateItem(65, 62)
    slash:SetFontName("fonts/AgencyFB_large_bold.fnt")
    slash:SetText("|")
    slashBg:SetFontName("fonts/AgencyFB_large_bold.fnt")
    slashBg:SetText("|")
    slash:SetScale(Vector(1.15, 1.9, 0))
    slashBg:SetScale(Vector(1.15, 1.9, 0))
    
    -- local slash, slashBg = self:CreateItem(100, 66)
    -- slash:SetFontName("fonts/AgencyFB_large_bold.fnt")
    -- slash:SetText("/")
    -- slashBg:SetFontName("fonts/AgencyFB_large_bold.fnt")
    -- slashBg:SetText("/")
    
    -- Force an update so our initial state is correct.
    self:Update(0)

end

function GUIShotgunDisplay:CreateItem(x, y)

    local textBg = GUIManager:CreateTextItem()
    textBg:SetFontName(Fonts.kMicrogrammaDMedExt_Medium)
    textBg:SetScale(Vector(1.17, 1.17, 0))
    textBg:SetTextAlignmentX(GUIItem.Align_Center)
    textBg:SetTextAlignmentY(GUIItem.Align_Center)
    textBg:SetPosition(Vector(x, y, 0))
    textBg:SetColor(Color(1, 1, 1, 1))

    -- Text displaying the amount of reserve ammo
    local text = GUIManager:CreateTextItem()
    text:SetFontName(Fonts.kMicrogrammaDMedExt_Medium )
    text:SetScale(Vector(1.17, 1.17, 0))
    text:SetTextAlignmentX(GUIItem.Align_Center)
    text:SetTextAlignmentY(GUIItem.Align_Center)
    text:SetPosition(Vector(x, y, 0))
    text:SetColor(Color(1, 1, 1, 1))
    
    return text, textBg
    
end

function GUIShotgunDisplay:Update(deltaTime)

    PROFILE("GUIShotgunDisplay:Update")
    
    -- Update the ammo counter.
    
    local clipFormat = string.format("%d", self.weaponClip) 
    local ammoFormat = string.format("%02d", self.weaponAmmo) 
    
    self.clipText:SetText( clipFormat )
    self.clipTextBg:SetText( clipFormat )
    
    self.ammoText:SetText( ammoFormat )
    self.ammoTextBg:SetText( ammoFormat )

    self.cart_type_gui:SetText(self.cartridge_type)
    self.cart_type_guiBg:SetText(self.cartridge_type)

    if self.cartridge_type == "ST" then
        self.cart_type_gui:SetColor(Color(1,1,1,1))
        self.cart_type_guiBg:SetColor(Color(1,1,1,1))
    elseif self.cartridge_type == "BU" then
        self.cart_type_gui:SetColor(Color(0,0,0,1))
        self.cart_type_guiBg:SetColor(Color(0,0,0,1))
    elseif self.cartridge_type == "IN" then
        self.cart_type_gui:SetColor(Color(1,0,0,1))
        self.cart_type_guiBg:SetColor(Color(1,0,0,1))
    elseif self.cartridge_type == "SL" then
        self.cart_type_gui:SetColor(Color(0,1,0,1))
        self.cart_type_guiBg:SetColor(Color(0,1,0,1))
    end

    self.distance_to_enemy_GUI:SetText(string.format("%02d", self.distance_to_target))
    self.distance_to_enemy_GUIBg:SetText(string.format("%02d", self.distance_to_target))

    if self.distance_to_target == 0 then
        self.distance_to_enemy_GUI:SetColor(Color(0,1,0,1))
        self.distance_to_enemy_GUIBg:SetColor(Color(0,1,0,1))
    elseif 14 <= self.distance_to_target then
        self.distance_to_enemy_GUI:SetColor(Color(0.3,1,0,1))
        self.distance_to_enemy_GUIBg:SetColor(Color(0.3,1,0,1))
    elseif 7 <= self.distance_to_target and self.distance_to_target < 14 then
        self.distance_to_enemy_GUI:SetColor(Color(0.5,0.5,0,1))
        self.distance_to_enemy_GUIBg:SetColor(Color(0.5,0.5,0,1))
    elseif 0 < self.distance_to_target and self.distance_to_target < 7 then
        self.distance_to_enemy_GUI:SetColor(Color(1,0,0,1))
        self.distance_to_enemy_GUIBg:SetColor(Color(1,0,0,1))
    end

    local fraction = self.weaponClip / self.weaponClipSize
    local alpha = 0
    local pulseSpeed = 5
    
    if fraction <= 0.4 then
        
        if fraction == 0 then
            pulseSpeed = 25
        elseif fraction < 0.25 then
            pulseSpeed = 10
        end
        
        alpha = (math.sin(self.globalTime * pulseSpeed) + 1) / 2
    end
    
    if not self.lowAmmoWarning then alpha = 0 end
    
    self.lowAmmoOverlay:SetColor(Color(1, 0, 0, alpha * 0.25))
    
end

function GUIShotgunDisplay:SetClip(weaponClip)
    self.weaponClip = weaponClip
end

function GUIShotgunDisplay:SetClipSize(weaponClipSize)
    self.weaponClipSize = weaponClipSize
end

function GUIShotgunDisplay:SetAmmo(weaponAmmo)
    self.weaponAmmo = weaponAmmo
end

function GUIShotgunDisplay:SetCartridgeType(val)
    self.cartridge_type = val
end

function GUIShotgunDisplay:SetTargetDistance(val)
    self.distance_to_target = val
end

function GUIShotgunDisplay:SetGlobalTime(globalTime)
    self.globalTime = globalTime
end

function GUIShotgunDisplay:SetLowAmmoWarning(lowAmmoWarning)
    self.lowAmmoWarning = ConditionalValue(lowAmmoWarning == "true", true, false)
end

--kShotgunVariants = enum({ "normal", "kodiak", "tundra", "forge", "sandstorm", "chroma" })
local kTextures =
{
    "ui/shotgundisplay0.dds", -- normal
    "ui/shotgundisplay4.dds", -- kodiak
    "ui/shotgundisplay1.dds", -- tundra
    "ui/shotgundisplay2.dds", -- forge
    "ui/shotgundisplay3.dds", -- sandstorm
    "ui/shotgundisplay5.dds", -- chroma
}

function GUIShotgunDisplay:SetWeaponVariant(weaponVariant)
    if weaponVariant ~= -1 then
        self.background:SetTexture("ui/TSF Logo.dds")
    end
    -- if cartridge_type == "standard" then
    --     self.background:SetTexture("ui/shotgundisplay0.dds")
    -- elseif cartridge_type == "buckshot" then
    --     self.background:SetTexture("ui/shotgundisplay1.dds")
    -- elseif cartridge_type == "incendiary" then
    --     self.background:SetTexture("ui/shotgundisplay2.dds")
    -- elseif cartridge_type == "slug" then
    --     self.background:SetTexture("ui/shotgundisplay3.dds")
    -- end

end

--
-- Called by the player to update the components.
--
function Update(deltaTime)

    bulletDisplay:SetClip(weaponClip)
    bulletDisplay:SetAmmo(weaponAmmo)
    bulletDisplay:SetWeaponVariant(weaponVariant)
    bulletDisplay:SetGlobalTime(globalTime)
    bulletDisplay:SetLowAmmoWarning(lowAmmoWarning)
    bulletDisplay:SetCartridgeType(cartridge_type)
    bulletDisplay:SetTargetDistance(distance_to_target)
    bulletDisplay:Update(deltaTime)

end

--
-- Initializes the player components.
--
function Initialize()

    GUI.SetSize( 256, 128 )

    bulletDisplay = GUIShotgunDisplay()
    bulletDisplay:Initialize()
    bulletDisplay:SetClipSize(6)
    bulletDisplay:SetGlobalTime(globalTime)
    bulletDisplay:SetLowAmmoWarning(lowAmmoWarning)

end

Initialize()
