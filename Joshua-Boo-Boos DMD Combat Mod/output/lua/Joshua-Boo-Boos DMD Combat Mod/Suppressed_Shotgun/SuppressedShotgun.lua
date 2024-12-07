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
Script.Load("lua/Weapons/Marine/Shotgun.lua")

class 'SuppressedShotgun' (ClipWeapon)

SuppressedShotgun.kMapName = "suppressedshotgun"

SuppressedShotgun.kModelName = PrecacheAsset("models/Suppressed_Shotgun/SuppressedShotgun_World.model")
local kViewModels = PrecacheAsset("models/Suppressed_Shotgun/SuppressedShotgun_View.model")
local kAnimationGraph = PrecacheAsset("models/Suppressed_Shotgun/SuppressedShotgun_View.animation_graph")

local draw_sound = PrecacheAsset("sound/Suppressed_Shotgun/SuppressedShotgun.fev/SuppressedShotgun/BoltClose")
local reload_sound = PrecacheAsset("sound/Suppressed_Shotgun/SuppressedShotgun.fev/SuppressedShotgun/Reload")
local shoot_sound = PrecacheAsset("sound/Suppressed_Shotgun/SuppressedShotgun.fev/SuppressedShotgun/Shoot")

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
AddMixinNetworkVars(ShotgunVariantMixin, networkVars)

SuppressedShotgun.kStartOffset = 0.1
SuppressedShotgun.kBulletSize = 0.016 -- not used... leave in just in case some mod uses it.

SuppressedShotgun.kDamageFalloffStart = 5 -- in meters, full damage closer than this.
SuppressedShotgun.kDamageFalloffEnd = 15 -- in meters, minimum damage further than this, gradient between start/end.
SuppressedShotgun.kDamageFalloffReductionFactor = 0.5 -- 50% reduction

local kAttackDelay = 0.5

local kSuppressedShotgunBulletsPerShot = 0 -- calculated from rings.
local kDamageScalar = 0.5
SuppressedShotgun.kSpreadVectors = {}
SuppressedShotgun.kShotgunRings =
{
    { pelletCount = 1, distance = 0.0000, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
    { pelletCount = 4, distance = 0.3500, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
    { pelletCount = 4, distance = 0.6364, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = math.pi * 0.25},
    { pelletCount = 4, distance = 1.0000, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
    { pelletCount = 4, distance = 1.1314, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = math.pi * 0.25}
}

local kRingFieldNames = {"pelletCount", "distance", "pelletSize", "pelletDamage"}
local function GetAreSpreadVectorsOutdated()

    -- Check kShotgunSpreadDistance constant
    if kShotgunSpreadDistance ~= SuppressedShotgun.__lastKShotgunSpreadDistance then
        return true
    end

    -- Check the rings table.
    if SuppressedShotgun.__lastKShotgunRings == nil then
        return true -- not cached yet.
    end

    for i = 1, #SuppressedShotgun.kShotgunRings do
        local ring = SuppressedShotgun.kShotgunRings[i]
        local lastRing = SuppressedShotgun.__lastKShotgunRings[i]
        for j = 1, #kRingFieldNames do
            local ringFieldName = kRingFieldNames[j]
            if ring[ringFieldName] ~= lastRing[ringFieldName] then
                return true
            end
        end
    end

end

local function UpdateCachedLastValues()

    SuppressedShotgun.__lastKShotgunSpreadDistance = kShotgunSpreadDistance
    SuppressedShotgun.__lastKShotgunRings = SuppressedShotgun.__lastKShotgunRings or {} -- create if missing.
    for i=1, #SuppressedShotgun.kShotgunRings do
        SuppressedShotgun.__lastKShotgunRings[i] = SuppressedShotgun.__lastKShotgunRings[i] or {} -- create if missing.
        local ring = SuppressedShotgun.kShotgunRings[i]
        local lastRing = SuppressedShotgun.__lastKShotgunRings[i]
        for j = 1, #kRingFieldNames do
            local ringFieldName = kRingFieldNames[j]
            lastRing[ringFieldName] = ring[ringFieldName]
        end
    end

end

function SuppressedShotgun._RecalculateSpreadVectors()
    PROFILE("SuppressedShotgun._RecalculateSpreadVectors")

    -- Only recalculate if we really need to.  Allow this to be lazily called from wherever
    -- Shotgun.kSpreadVectors is used, to ensure it's up-to-date.
    if not GetAreSpreadVectorsOutdated() then
        return
    end

    UpdateCachedLastValues() -- update cached values so we can detect changes.

    SuppressedShotgun.kSpreadVectors = {} -- reset
    kSuppressedShotgunBulletsPerShot = 0

    local circle = math.pi * 2.0

    for _, ring in ipairs(SuppressedShotgun.kShotgunRings) do

        local radiansPer = circle / ring.pelletCount
        kSuppressedShotgunBulletsPerShot = kSuppressedShotgunBulletsPerShot + ring.pelletCount
        for pellet = 1, ring.pelletCount do

            local theta = radiansPer * (pellet - 1) + (ring.thetaOffset or 0)
            local x = math.cos(theta) * ring.distance
            local y = math.sin(theta) * ring.distance
            table.insert(SuppressedShotgun.kSpreadVectors, { vector = GetNormalizedVector(Vector(x, y, kShotgunSpreadDistance)), size = ring.pelletSize, damage = ring.pelletDamage})

        end

    end

end
SuppressedShotgun._RecalculateSpreadVectors()

function SuppressedShotgun:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    
    self.emptyPoseParam = 0

    self.last_attack_time = 0
    self.can_shoot = false

    if Server then
        self.shotgunVariant = 1.0
    end

end

if Client then

    function SuppressedShotgun:GetBarrelPoint()

        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()
        
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.1 + viewCoords.yAxis * -0.2
        end
        
        return self:GetOrigin()
        
    end
    
    function SuppressedShotgun:OverrideLaserLength()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return 0.3
        end

        return 20
    
    end
    
    function SuppressedShotgun:OverrideLaserWidth()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return 0.02
        end

        return 0.045
    
    end
    
    function SuppressedShotgun:OverrideStartColor()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return Color(1, 0, 0, 0.35)
        end

        return Color(1, 0, 0, 0.7)
        
    end
    
    function SuppressedShotgun:OverrideEndColor()
    
        local parent = self:GetParent()
        
        if parent and parent == Client.GetLocalPlayer() and not parent:GetIsThirdPerson() then
            return Color(1, 0, 0, 0)
        end

        return Color(1, 0, 0, 0.07)
        
    end

    function SuppressedShotgun:GetLaserAttachCoords()
    
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
    
    function SuppressedShotgun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 256, script = "lua/GUIShotgunDisplay.lua", variant = 1 }
    end
    
end

function SuppressedShotgun:OverrideWeaponName()
    return "shotgun"
end

function SuppressedShotgun:OnMaxFireRateExceeded()
    self.queuedShots = Clamp(self.queuedShots + 1, 0, 10)
end

function SuppressedShotgun:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.04978440701961517, 0.0, -0.037144746631383896))
end

function SuppressedShotgun:GetAnimationGraphName()
    return kAnimationGraph
end

function SuppressedShotgun:GetHasSecondary(player)
    return false
end

function SuppressedShotgun:GetViewModelName(sex, variant)
    return kViewModels
end

function SuppressedShotgun:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

-- When in alt-fire mode, keep very accurate
function SuppressedShotgun:GetInaccuracyScalar(player)
    return ClipWeapon.GetInaccuracyScalar(self, player)
end

function SuppressedShotgun:GetHUDSlot()
    return 1
end

function SuppressedShotgun:GetPrimaryMinFireDelay()
    return kPistolRateOfFire    
end

function SuppressedShotgun:GetPrimaryAttackRequiresPress()
    return true
end

function SuppressedShotgun:GetWeight()
    return kShotgunWeight
end

function SuppressedShotgun:GetClipSize()
    return 10
end

function SuppressedShotgun:GetBulletDamage(target, endPoint)
    return kSuppressedShotgunDamage
end

function SuppressedShotgun:GetIdleAnimations(index)
    -- local animations = {"idle", "idle_spin", "idle_gangster"}
    -- return animations[index]
end

function SuppressedShotgun:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("empty", self.emptyPoseParam)
end

function SuppressedShotgun:GetBulletsPerShot()
    return kSuppressedShotgunBulletsPerShot
end

function SuppressedShotgun:FirePrimary(player)

    local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2

    local shootCoords = viewAngles:GetCoords()

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()

    -- Ensure spread vectors are up-to-date. Disabled for production
    -- Shotgun._RecalculateSpreadVectors()

    local numberBullets = self:GetBulletsPerShot()

    for bullet = 1, math.min(numberBullets, #self.kSpreadVectors) do

        if not self.kSpreadVectors[bullet] then
            break
        end

        local spreadVector = self.kSpreadVectors[bullet].vector
        local pelletSize = self.kSpreadVectors[bullet].size
        local spreadDamage = self.kSpreadVectors[bullet].damage

        local spreadDirection = shootCoords:TransformVector(spreadVector)

        local startPoint = player:GetEyePos() + shootCoords.xAxis * spreadVector.x * self.kStartOffset + shootCoords.yAxis * spreadVector.y * self.kStartOffset

        local endPoint = player:GetEyePos() + spreadDirection * range

        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, pelletSize, filter)

        HandleHitregAnalysis(player, startPoint, endPoint, trace)

        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = bullet % effectFrequency == 0

        local numTargets = #targets

        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end

        if Client and showTracer then
            TriggerFirstPersonTracer(self, impactPoint)
        end

        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]

            local thisTargetDamage = spreadDamage

            -- Apply a damage falloff for shotgun damage.
            if self.kDamageFalloffReductionFactor ~= 1 then
                local distance = (hitPoint - startPoint):GetLength()
                local falloffFactor = Clamp((distance - self.kDamageFalloffStart) / (self.kDamageFalloffEnd - self.kDamageFalloffStart), 0, 1)
                local nearDamage = thisTargetDamage
                local farDamage = thisTargetDamage * self.kDamageFalloffReductionFactor
                thisTargetDamage = nearDamage * (1.0 - falloffFactor) + farDamage * falloffFactor
            end

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, thisTargetDamage, "", showTracer and i == numTargets)

            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, thisTargetDamage)
            end

        end

    end

end

function SuppressedShotgun:OnTag(tagName)

    PROFILE("SuppressedShotgun:OnTag")

    -- ClipWeapon.OnTag(self, tagName)

    local player = self:GetParent()

    if tagName == "Draw_Start" then
        self.can_shoot = false
        if Server then
            StartSoundEffectOnEntity(draw_sound, player, 1)
        end
    elseif tagName == "Draw_End" then
        self.can_shoot = true
    elseif tagName == "Reload_Start" then
        self.can_shoot = false
        -- StartSoundEffectForPlayer(reload_sound, player, 0.55)
        -- if Server then
        --     StartSoundEffectOnEntity(reload_sound, player, 1)
        -- end
        if Server then
            StartSoundEffectOnEntity(reload_sound, player, 1)
        end
    elseif tagName == "Give_Cartridge" then
        self.required_ammo = self:GetClipSize() - self.clip
        if self.required_ammo > 0 and self.ammo > 0 then
            self.ammo = self.ammo - 1
            self.clip = self.clip + 1
            self.can_shoot = true
        else
            self.reloading = false
        end
    elseif tagName == "Reload_End" then
        self.reloading = false
        self.can_shoot = true
    elseif tagName == "Shoot_Start" then
        self:FirePrimary(player)
        self.clip = self.clip - 1
        -- self:TriggerEffects("pistol_attack")
        -- StartSoundEffectForPlayer(shoot_sound, player, 0.25)
        -- if Server then
        --     StartSoundEffectOnEntity(shoot_sound, player, 0.4)
        -- end
        if Server then
            StartSoundEffectOnEntity(shoot_sound, player, 1)
        end
    elseif tagName == "Sprint_Start" then
        self.can_shoot = false
    elseif tagName == "Sprint_End" then
        self.can_shoot = true
    -- elseif tagName == "Shoot_Start" then
    end
    
end

function SuppressedShotgun:OnUpdateAnimationInput(modelMixin)

    PROFILE("SuppressedShotgun:OnUpdateAnimationInput")
    
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
            if Shared.GetTime() > self.last_attack_time + kAttackDelay then
                self.last_attack_time = Shared.GetTime()
                activity = "primary"
            end
        end
    end

    if self.reloading then -- not activity == "reload" and

        if self.primaryAttacking and self.clip > 0 then
            
            if Shared.GetTime() > self.last_attack_time + kAttackDelay then
                self.last_attack_time = Shared.GetTime()
                activity = "primary"
                self.reloading = false
            end
        
        else
        
            if self.clip < self:GetClipSize() and self.ammo > 0 then

                activity = "reload"

            elseif self.clip == self:GetClipSize() then

                activity = "none"
                self.reloading = false

            end

        end

    end

    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("movement", movement)
    Log("setanimationinput activity = " .. activity)
    Log("setanimationinput movement = " .. movement)
    
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

function SuppressedShotgun:OnPrimaryAttack(player)

    if self.clip == 0 and self.ammo > 0 and player.GetIsSprinting and not player:GetIsSprinting() then
        
        self.reloading = true
        player:Reload()

    elseif self.clip > 0 then



        if not player:GetPrimaryAttackLastFrame() then

            if self.lastShotAt then
                
                if Shared.GetTime() > self.lastShotAt + 0.5 then

                    self.primaryAttacking = true

                end

            else

                self.lastShotAt = Shared.GetTime()

                self.primaryAttacking = true

            end

        end

    end
    
end

function SuppressedShotgun:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function SuppressedShotgun:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function SuppressedShotgun:GetDestroyOnKill()
        return true
    end
    
    function SuppressedShotgun:GetSendDeathMessageOverride()
        return false
    end 
    
end

-- function Pistol:OnDraw(player, previousWeaponMapName)

--     self.drawing = true
--     self.queuedShots = 0
    
-- end

function SuppressedShotgun:OnReload(player)

    -- ClipWeapon.OnReload(self, player)

    if player.GetIsSprinting and not player:GetIsSprinting() then
        self.reloading = true
    end

    --self.queuedShots = 0

end

function SuppressedShotgun:OnSecondaryAttack(player)

    --ClipWeapon.OnSecondaryAttack(self, player)

    --player.slowTimeStart = Shared.GetTime()
    --player.slowTimeEnd = Shared.GetTime() + 1
    --player.slowTimeOffset = 0
    --player.slowTimeFactor = 0.67
    --player.slowTimeRecoveryFactor = 1.33
    
end

function SuppressedShotgun:OnProcessMove(input)

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

function SuppressedShotgun:UseLandIntensity()
    return true
end

Shared.LinkClassToMap("SuppressedShotgun", SuppressedShotgun.kMapName, networkVars)
