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
Script.Load("lua/Weapons/Marine/Pistol.lua")

class 'Mac10' (ClipWeapon)

Mac10.kMapName = "mac10"

Mac10.kModelName = PrecacheAsset("models/Mac-10_World.model")
local kViewModels = PrecacheAsset("models/Mac-10_View.model")
local kAnimationGraph = PrecacheAsset("models/Mac-10_View.animation_graph")

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

function Mac10:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    
    self.emptyPoseParam = 0

    self.last_attack_time = 0
    self.can_shoot = false

    if Server then
        self.pistolVariant = 1.0
    end

end

if Client then

    function Mac10:GetBarrelPoint()

        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
        
            return origin + viewCoords.zAxis * 0.5 + viewCoords.xAxis * -0.05 + viewCoords.yAxis * -0.075
        end
        
        return self:GetOrigin()
        
    end
    
    function Mac10:OverrideLaserLength()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return 0.3
        end

        return 20
    
    end
    
    function Mac10:OverrideLaserWidth()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return 0.02
        end

        return 0.045
    
    end
    
    function Mac10:OverrideStartColor()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return Color(1, 0, 0, 0.35)
        end

        return Color(1, 0, 0, 0.7)
        
    end
    
    function Mac10:OverrideEndColor()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return Color(1, 0, 0, 0)
        end

        return Color(1, 0, 0, 0.07)
        
    end

    function Mac10:GetLaserAttachCoords()
    
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
    
    function Mac10:GetUIDisplaySettings()
        return { xSize = 256, ySize = 256, script = "lua/GUIPistolDisplay.lua", variant = 8 }
    end
    
end

function Mac10:OverrideWeaponName()
    return "pistol"
end

function Mac10:OnMaxFireRateExceeded()
    self.queuedShots = Clamp(self.queuedShots + 1, 0, 10)
end

function Mac10:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.04978440701961517, 0.0, -0.037144746631383896))
end

function Mac10:GetAnimationGraphName()
    return kAnimationGraph
end

function Mac10:GetHasSecondary(player)
    return false
end

function Mac10:GetViewModelName(sex, variant)
    return kViewModels
end

function Mac10:GetDeathIconIndex()
    return kDeathMessageIcon.Mac10
end

-- When in alt-fire mode, keep very accurate
function Mac10:GetInaccuracyScalar(player)
    return ClipWeapon.GetInaccuracyScalar(self, player)
end

function Mac10:GetHUDSlot()
    return 2
end

function Mac10:GetPrimaryMinFireDelay()
    return kPistolRateOfFire    
end

function Mac10:GetPrimaryAttackRequiresPress()
    return false
end

function Mac10:GetWeight()
    return kPistolWeight * 1.4
end

function Mac10:GetClipSize()
    return 20
end

function Mac10:GetSpread()
    return kSpread * 4.5
end

function Mac10:GetBulletDamage(target, endPoint)
    return kMac10Damage
end

function Mac10:GetIdleAnimations(index)
    -- local animations = {"idle", "idle_spin", "idle_gangster"}
    -- return animations[index]
end

function Mac10:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("empty", self.emptyPoseParam)
end

function Mac10:OnTag(tagName)

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
        if Server then
            StartSoundEffectOnEntity(reload_sound, player, 1)
        end
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
        if Server then
            StartSoundEffectOnEntity(shoot_sound, player, 0.4)
        end
    elseif tagName == "Sprint_Start" then
        self.can_shoot = false
    elseif tagName == "Sprint_End" then
        self.can_shoot = true
    -- elseif tagName == "Shoot_Start" then
    end
    
end

function Mac10:OnUpdateAnimationInput(modelMixin)

    PROFILE("Mac10:OnUpdateAnimationInput")
    
    local player = self:GetParent()
    
    local activity = "draw"
    local movement = "idle"
    
    if player then
        if not player:GetIsIdle() then

            if player:GetIsSprinting() then
                movement = "sprint"
            else
                movement = "run"
            end
        
        end
    end
    
    if not self.drawing then
        activity = "none"
    end
    
    if player then
        if not player:GetIsSprinting() and self.primaryAttacking and self.clip > 0 and not self.reloading and self.can_shoot then
            activity = "primary"
        end
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
    modelMixin:SetAnimationInput("movement", movement)
    -- Log("setanimationinput activity = " .. activity)
    -- Log("setanimationinput movement = " .. movement)
    
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

function Mac10:OnPrimaryAttack(player)

    if self.reloading == false then

        if self.clip == 0 and self.ammo > 0 and player.GetIsSprinting and not player:GetIsSprinting() then
            
            self.reloading = true
            player:Reload()

        elseif self.clip > 0 then

            self.primaryAttacking = true

        end

    end
    
end

function Mac10:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Mac10:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function Mac10:GetDestroyOnKill()
        return true
    end
    
    function Mac10:GetSendDeathMessageOverride()
        return false
    end 
    
end

-- function Pistol:OnDraw(player, previousWeaponMapName)

--     self.drawing = true
--     self.queuedShots = 0
    
-- end

function Mac10:OnReload(player)

    -- ClipWeapon.OnReload(self, player)

    if player.GetIsSprinting and not player:GetIsSprinting() then
        self.reloading = true
    end

    --self.queuedShots = 0

end

function Mac10:OnSecondaryAttack(player)

    --ClipWeapon.OnSecondaryAttack(self, player)

    --player.slowTimeStart = Shared.GetTime()
    --player.slowTimeEnd = Shared.GetTime() + 1
    --player.slowTimeOffset = 0
    --player.slowTimeFactor = 0.67
    --player.slowTimeRecoveryFactor = 1.33
    
end

function Mac10:OnProcessMove(input)

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

function Mac10:UseLandIntensity()
    return true
end

Shared.LinkClassToMap("Mac10", Mac10.kMapName, networkVars)
