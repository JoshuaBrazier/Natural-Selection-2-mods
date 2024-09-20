-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Pistol.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PistolVariantMixin.lua")

class 'Pistol' (ClipWeapon)

Pistol.kMapName = "pistol"

Pistol.kModelName = PrecacheAsset("models/Mac-10/Mac-10_World.model")
local kViewModels = PrecacheAsset("models/Mac-10/Mac-10_View.model")
local kAnimationGraph = PrecacheAsset("models/Mac-10/Mac-10_View.animation_graph")

local reload_sound = PrecacheAsset("sound/Mac10.fev/Mac10_Sounds/Reload")
local shoot_sound = PrecacheAsset("sound/Mac10.fev/Mac10_Sounds/Shoot")

local kClipSize = 10
local kRange = 200
local kSpread = Math.Radians(0.4)
local kAltSpread = ClipWeapon.kCone0Degrees

local kLaserAttachPoint = "fxnode_laser"

local networkVars =
{
    -- emptyPoseParam = "private float (0 to 1 by 0.01)",
    -- queuedShots = "private compensated integer (0 to 10)",
}

AddMixinNetworkVars(PickupableWeaponMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(PistolVariantMixin, networkVars)

function Pistol:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PistolVariantMixin)
    
    self.emptyPoseParam = 0

    self.last_attack_time = 0
    self.can_shoot = false

end

if Client then

    function Pistol:GetBarrelPoint()

        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
        
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.1 + viewCoords.yAxis * -0.2
        end
        
        return self:GetOrigin()
        
    end
    
    function Pistol:OverrideLaserLength()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return 0.3
        end

        return 20
    
    end
    
    function Pistol:OverrideLaserWidth()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return 0.02
        end

        return 0.045
    
    end
    
    function Pistol:OverrideStartColor()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return Color(1, 0, 0, 0.35)
        end

        return Color(1, 0, 0, 0.7)
        
    end
    
    function Pistol:OverrideEndColor()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return Color(1, 0, 0, 0)
        end

        return Color(1, 0, 0, 0.07)
        
    end

    function Pistol:GetLaserAttachCoords()
    
        -- return first person coords
        local parent = self:GetParent()
        if parent and parent == Client.GetLocalPlayer() then

            local viewModel = parent:GetViewModelEntity()
        
            if Shared.GetModel(viewModel.modelIndex) then
                
                local viewCoords = parent:GetViewCoords()
                local attachCoords = viewModel:GetAttachPointCoords(kLaserAttachPoint)
                
                attachCoords.origin = viewCoords:TransformPoint(attachCoords.origin)
                
                -- when we are not reloading or sprinting then return the view axis (otherwise the laser pointer goes in wrong direction)
                --[[
                if not self:GetIsReloading() and not parent:GetIsSprinting() then
                
                    attachCoords.zAxis = viewCoords.zAxis
                    attachCoords.xAxis = viewCoords.xAxis
                    attachCoords.yAxis = viewCoords.yAxis

                else--]]
                
                    attachCoords.zAxis = viewCoords:TransformVector(attachCoords.zAxis)
                    attachCoords.xAxis = viewCoords:TransformVector(attachCoords.xAxis)
                    attachCoords.yAxis = viewCoords:TransformVector(attachCoords.yAxis)
                    
                    local zAxis = attachCoords.zAxis
                    attachCoords.zAxis = attachCoords.xAxis
                    attachCoords.xAxis = zAxis
                    
                --end
                
                attachCoords.origin = attachCoords.origin - attachCoords.zAxis * 0.1
                
                return attachCoords
            
            end
            
        end
        
        -- return third person coords
        return self:GetAttachPointCoords(kLaserAttachPoint)
        
    end
    
    function Pistol:GetUIDisplaySettings()
        return { xSize = 256, ySize = 256, script = "lua/GUIPistolDisplay.lua", variant = self:GetPistolVariant() }
    end
    
end

function Pistol:OnMaxFireRateExceeded()
    self.queuedShots = Clamp(self.queuedShots + 1, 0, 10)
end

function Pistol:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.04978440701961517, 0.0, -0.037144746631383896))
end

function Pistol:GetAnimationGraphName()
    return kAnimationGraph
end

function Pistol:GetHasSecondary(player)
    return false
end

function Pistol:GetViewModelName(sex, variant)
    return kViewModels
end

function Pistol:GetDeathIconIndex()
    return kDeathMessageIcon.Pistol
end

-- When in alt-fire mode, keep very accurate
function Pistol:GetInaccuracyScalar(player)
    return ClipWeapon.GetInaccuracyScalar(self, player)
end

function Pistol:GetHUDSlot()
    return kSecondaryWeaponSlot
end

function Pistol:GetPrimaryMinFireDelay()
    return kPistolRateOfFire    
end

function Pistol:GetPrimaryAttackRequiresPress()
    return false
end

function Pistol:GetWeight()
    return kPistolWeight * 1.4
end

function Pistol:GetClipSize()
    return 20
end

function Pistol:GetSpread()
    return kSpread * 4.5
end

function Pistol:GetBulletDamage(target, endPoint)
    return kPistolDamage * 0.5
end

function Pistol:GetIdleAnimations(index)
    -- local animations = {"idle", "idle_spin", "idle_gangster"}
    -- return animations[index]
end

function Pistol:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("empty", self.emptyPoseParam)
end

function Pistol:OnTag(tagName)

    PROFILE("Pistol:OnTag")

    -- ClipWeapon.OnTag(self, tagName)

    local player = self:GetParent()

    if tagName == "Draw_Start" then
        self.can_shoot = false
    elseif tagName == "Draw_End" then
        self.can_shoot = true
    elseif tagName == "Reload_Start" then
        self.can_shoot = false
        -- StartSoundEffectForPlayer(reload_sound, player, 0.55)
        StartSoundEffectOnEntity(reload_sound, player, 0.75)
    elseif tagName == "Reload_End" then
        self.required_ammo = 20 - self.clip
        if self.ammo >= self.required_ammo then
            self.ammo = self.ammo - (self.required_ammo)
            self.clip = 20
        else
            self.clip = self.clip + self.ammo
            self.ammo = 0
        end
        self.reloading = false
        self.can_shoot = true
    elseif tagName == "Shoot_Start" then
        ClipWeapon.FirePrimary(self, player)
        self.clip = self.clip - 1
        -- self:TriggerEffects("pistol_attack")
        -- StartSoundEffectForPlayer(shoot_sound, player, 0.25)
        StartSoundEffectOnEntity(shoot_sound, player, 0.21)
    elseif tagName == "Sprint_Start" then
        self.can_shoot = false
    elseif tagName == "Sprint_End" then
        self.can_shoot = true
    -- elseif tagName == "Shoot_Start" then
    end
    
end

function Pistol:OnUpdateAnimationInput(modelMixin)

    PROFILE("Pistol:OnUpdateAnimationInput")
    
    local player = self:GetParent()
    
    local activity = "draw"

    if not self.drawing then
        activity = "none"
    end
    
    if player then
        if player:GetIsSprinting() then
            activity = "sprint"
        end
    end
    
    if self.primaryAttacking and self.clip > 0 and not self.reloading and self.can_shoot then
        activity = "primary"
    end

    if self.reloading then -- not activity == "reload" and
        
        if self.clip < 20 and self.ammo > 0 then

            activity = "reload"

        else

            activity = "none"
            self.reloading = false

        end

    end

    modelMixin:SetAnimationInput("activity", activity)
    -- Log("setanimationinput activity = " .. activity)
    
end

-- function Pistol:FirePrimary(player)

--     if not self.reloading and player.GetIsSprinting and not player:GetIsSprinting() and self.can_shoot then

--         if Shared.GetTime() >= self.last_attack_time + 0.1 then
--             self.last_attack_time = Shared.GetTime()
--             -- ClipWeapon.FirePrimary(self, player)
--             --self:TriggerEffects("pistol_attack")
--         end

--     end

-- end

function Pistol:OnPrimaryAttack(player)

    if self.reloading == false then

        if self.clip == 0 and self.ammo > 0 and player.GetIsSprinting and not player:GetIsSprinting() then
            
            self.reloading = true
            player:Reload()

        elseif self.clip > 0 then

            self.primaryAttacking = true

        end

    end
    
end

function Pistol:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Pistol:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function Pistol:GetDestroyOnKill()
        return true
    end
    
    function Pistol:GetSendDeathMessageOverride()
        return false
    end 
    
end

-- function Pistol:OnDraw(player, previousWeaponMapName)

--     self.drawing = true
--     self.queuedShots = 0
    
-- end

function Pistol:OnReload(player)

    -- ClipWeapon.OnReload(self, player)

    if player.GetIsSprinting and not player:GetIsSprinting() then
        self.reloading = true
    end

    --self.queuedShots = 0

end

function Pistol:OnSecondaryAttack(player)

    --ClipWeapon.OnSecondaryAttack(self, player)

    --player.slowTimeStart = Shared.GetTime()
    --player.slowTimeEnd = Shared.GetTime() + 1
    --player.slowTimeOffset = 0
    --player.slowTimeFactor = 0.67
    --player.slowTimeRecoveryFactor = 1.33
    
end

function Pistol:OnProcessMove(input)

    ClipWeapon.OnProcessMove(self, input)

    -- if self.queuedShots > 0 then
    
    --     self.queuedShots = math.max(0, self.queuedShots - 1)
    --     self:OnPrimaryAttack(self:GetParent())
    
    -- end

    -- if self.clip ~= 0 then
    --     self.emptyPoseParam = 0
    -- else
    --     self.emptyPoseParam = Clamp(Slerp(self.emptyPoseParam, 1, input.time * 5), 0, 1)
    -- end

end

function Pistol:UseLandIntensity()
    return true
end

Shared.LinkClassToMap("Pistol", Pistol.kMapName, networkVars)
