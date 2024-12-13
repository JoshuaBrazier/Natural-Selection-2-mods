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

local BuckshotClusterFragmentDamage = 13
kClusterGrenadeFragmentDamageType = kDamageType.ClusterFlameFragment

function BuckshotRadiusDamage(entities, centerOrigin, radius, fullDamage, doer, ignoreLOS, fallOffFunc, useXZDistance)

    assert(HasMixin(doer, "Damage"))

    local radiusSquared = radius * radius

    -- Do damage to every target in range
    for _, target in ipairs(entities) do

        if not target:isa("Player") then
    
            -- Find most representative point to hit
            local targetOrigin = GetTargetOrigin(target)

            local distanceVector = targetOrigin - centerOrigin

            -- Trace line to each target to make sure it's not blocked by a wall
            local wallBetween = false
            local distanceFromTarget
            if useXZDistance then
                distanceFromTarget = distanceVector:GetLengthSquaredXZ()
            else
                distanceFromTarget = distanceVector:GetLengthSquared()
            end

            if not ignoreLOS then
                wallBetween = GetWallBetween(centerOrigin, targetOrigin, target)
            end
            
            if (ignoreLOS or not wallBetween) and (distanceFromTarget <= radiusSquared) then
            
                -- Damage falloff
                local distanceFraction = distanceFromTarget / radiusSquared
                if fallOffFunc then
                    distanceFraction = fallOffFunc(distanceFraction)
                end
                distanceFraction = Clamp(distanceFraction, 0, 1)

                local damage = fullDamage * (1 - distanceFraction)

                local damageDirection = distanceVector
                damageDirection:Normalize()
                
                -- we can't hit world geometry, so don't pass any surface params and let DamageMixin decide
                doer:DoDamage(damage, target, target:GetOrigin(), damageDirection, "none")

            end

        end
        
    end
    
end

class 'BuckshotClusterFragment' (Projectile)

BuckshotClusterFragment.kMapName = "buckshotclusterfragment"

function BuckshotClusterFragment:OnCreate()

    Projectile.OnCreate(self)

    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, DamageMixin)

    if Server then
        self:AddTimedCallback(BuckshotClusterFragment.TimedDetonateCallback, math.random() * 1 + 0.5)
    elseif Client then
        self:AddTimedCallback(BuckshotClusterFragment.CreateResidue, 0.06)
    end

end

function BuckshotClusterFragment:GetProjectileModel()
    return ClusterFragment.kModelName
end

function BuckshotClusterFragment:GetDeathIconIndex()
    return kDeathMessageIcon.ClusterGrenade
end

if Server then

    function BuckshotClusterFragment:TimedDetonateCallback()
        self:Detonate()
    end

    function BuckshotClusterFragment:Detonate(targetHit)

        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kClusterFragmentDamageRadius)
        table.removevalue(hitEntities, self)

        if targetHit then
            table.removevalue(hitEntities, targetHit)
            self:DoDamage(BuckshotClusterFragmentDamage, targetHit, targetHit:GetOrigin(), GetNormalizedVector(targetHit:GetOrigin() - self:GetOrigin()), "none")
        end

        BuckshotRadiusDamage(hitEntities, self:GetOrigin(), kClusterFragmentDamageRadius, BuckshotClusterFragmentDamage, self)

        local surface = GetSurfaceFromEntity(targetHit)

        local params = { surface = surface }
        if not targetHit then
            params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis)
        end

        if GetDebugGrenadeDamage() then
            DebugWireSphere( self:GetOrigin(), kClusterFragmentDamageRadius, 0.5, 1, 0.498, 0, 1 )
        end

        self:TriggerEffects("cluster_fragment_explode", params)
        CreateExplosionDecals(self)
        DestroyEntity(self)

    end

end

function BuckshotClusterFragment:CreateResidue()

    self:TriggerEffects("clusterfragment_residue")
    return true

end

Shared.LinkClassToMap("BuckshotClusterFragment", BuckshotClusterFragment.kMapName, networkVars)

class 'SuppressedShotgun' (ClipWeapon)

SuppressedShotgun.kMapName = "suppressedshotgun"

SuppressedShotgun.kModelName = PrecacheAsset("models/SuppressedShotgun_World.model")
local kViewModels = PrecacheAsset("models/SuppressedShotgun_View.model")
local kAnimationGraph = PrecacheAsset("models/SuppressedShotgun_View.animation_graph")

local draw_sound = PrecacheAsset("sound/SuppressedShotgun.fev/SuppressedShotgun/BoltClose")
local reload_sound = PrecacheAsset("sound/SuppressedShotgun.fev/SuppressedShotgun/Reload")
local shoot_sound = PrecacheAsset("sound/SuppressedShotgun.fev/SuppressedShotgun/Shoot")

local kClipSize = 6
local kRange = 200
local kSpread = Math.Radians(0.4)
local kAltSpread = ClipWeapon.kCone0Degrees

local kLaserAttachPoint = "fxnode_laser"

local networkVars =
{
    -- emptyPoseParam = "private float (0 to 1 by 0.01)",
    -- queuedShots = "private compensated integer (0 to 10)",
    shotgun_cartridge = 'string (11)',
    tracked_target = 'entityid',
    time_now = 'time',
    hit_tracker_target_at = 'time',
    equipped_at = 'time',
    is_incendiary = 'boolean'
}

AddMixinNetworkVars(PickupableWeaponMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(ShotgunVariantMixin, networkVars)

SuppressedShotgun.kStartOffset = 0.1
SuppressedShotgun.kBulletSize = 0.016 -- not used... leave in just in case some mod uses it.

SuppressedShotgun.kDamageFalloffStart = 5 -- in meters, full damage closer than this.
SuppressedShotgun.kDamageFalloffEnd = 15 -- in meters, minimum damage further than this, gradient between start/end.
SuppressedShotgun.kDamageFalloffReductionFactor = 0.5 -- 50% reduction

local kAttackDelay = 0.3

local kSuppressedShotgunBulletsPerShot = 0 -- calculated from rings.
local kDamageScalar = 0.75
local kAccuracyScalar = 0.75
local kSlugDamageMultiplier = 0.85

SuppressedShotgun.kSpreadVectors = {}
SuppressedShotgun.kShotgunRings =
{
    { pelletCount = 1, distance = 0.0000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
    { pelletCount = 4, distance = 0.3500 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
    { pelletCount = 4, distance = 0.6364 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = math.pi * 0.25},
    { pelletCount = 4, distance = 1.0000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
    { pelletCount = 4, distance = 1.1314 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = math.pi * 0.25}
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

    self.shotgun_cartridge = 'standard'
    
    self.emptyPoseParam = 0

    self.last_attack_time = 0
    self.can_shoot = false

    if Server then
        self.shotgunVariant = 1.0
    end

    self.is_incendiary = false
    self.tracked_target = 0

    self.time_now = 0
    self.hit_tracker_target_at = 0

end

if Client then

    function SuppressedShotgun:GetBarrelPoint()

        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
        
            return origin + viewCoords.zAxis * 0.6 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.08
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

-- function SuppressedShotgun:OnMaxFireRateExceeded()
--     self.queuedShots = Clamp(self.queuedShots + 1, 0, 10)
-- end

function SuppressedShotgun:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.04978440701961517, 0.0, -0.037144746631383896))
end

function SuppressedShotgun:GetAnimationGraphName()
    return kAnimationGraph
end

function SuppressedShotgun:GetHasSecondary(player)
    return true
end

function SuppressedShotgun:GetPrimaryCanInterruptReload()
    return true
end

function SuppressedShotgun:GetSecondaryCanInterruptReload()
    return true
end

function SuppressedShotgun:GetViewModelName(sex, variant)
    return kViewModels
end

function SuppressedShotgun:GetDeathIconIndex()
    return kDeathMessageIcon.SuppressedShotgun
end

-- When in alt-fire mode, keep very accurate
-- function SuppressedShotgun:GetInaccuracyScalar(player)
--     return ClipWeapon.GetInaccuracyScalar(self, player)
-- end

function SuppressedShotgun:GetHUDSlot()
    return 1
end

function SuppressedShotgun:GetPrimaryMinFireDelay()
    return kAttackDelay
end

function SuppressedShotgun:GetPrimaryAttackRequiresPress()
    return false
end

function SuppressedShotgun:GetWeight()
    return kShotgunWeight
end

function SuppressedShotgun:GetClipSize()

    local parent = self:GetParent()
    if parent then

        if kWeapons4Enabled then
            if parent.weaponUpgradeLevel == 4 then
                return 10
            elseif parent.weaponUpgradeLevel == 3 then
                return 9
            elseif parent.weaponUpgradeLevel == 2 then
                return 8
            elseif parent.weaponUpgradeLevel == 1 then
                return 7
            else
                return 6
            end
        else
            if parent.weaponUpgradeLevel == 3 then
                return 9
            elseif parent.weaponUpgradeLevel == 2 then
                return 8
            elseif parent.weaponUpgradeLevel == 1 then
                return 7
            else
                return 6
            end
        end
    
    end

    return kClipSize

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

    if self.shotgun_cartridge == "standard" then
        SuppressedShotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
            { pelletCount = 4, distance = 0.3500 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
            { pelletCount = 4, distance = 0.6364 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = math.pi * 0.25},
            { pelletCount = 4, distance = 1.0000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = 0},
            { pelletCount = 4, distance = 1.1314 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 10 * kDamageScalar, thetaOffset = math.pi * 0.25}
        }
        
    elseif self.shotgun_cartridge == "buckshot" then
        SuppressedShotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 18.5 * kDamageScalar, thetaOffset = 0},
            { pelletCount = 2, distance = 0.65 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 18.5 * kDamageScalar, thetaOffset = 0},
            { pelletCount = 2, distance = 0.65 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 18.5 * kDamageScalar, thetaOffset = math.pi * 0.66},
            { pelletCount = 2, distance = 0.65 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 18.5 * kDamageScalar, thetaOffset = math.pi * 1.33},
        }
        
    elseif self.shotgun_cartridge == "incendiary" then
        SuppressedShotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 15.5 * kDamageScalar, thetaOffset = 0},
            { pelletCount = 3, distance = 0.300 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 15.5 * kDamageScalar, thetaOffset = 0},
            { pelletCount = 3, distance = 0.600 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 15.5 * kDamageScalar, thetaOffset = math.pi * 0.25},
            { pelletCount = 3, distance = 0.9000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 15.5 * kDamageScalar, thetaOffset = 0},
        }
        
    elseif self.shotgun_cartridge == "slug" then
        SuppressedShotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000 * kAccuracyScalar, pelletSize = 0.016, pelletDamage = 170 * kDamageScalar * kSlugDamageMultiplier, thetaOffset = 0}
        }
    end

    if self.shotgun_cartridge == "incendiary" then
        self.is_incendiary = true
    else
        self.is_incendiary = false
    end

    local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2

    local shootCoords = viewAngles:GetCoords()

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()

    -- Ensure spread vectors are up-to-date. Disabled for production
    SuppressedShotgun._RecalculateSpreadVectors()

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

            if self.shotgun_cartridge == "slug" then
                self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, kSlugDamageMultiplier * thisTargetDamage, "", showTracer and i == numTargets)
            else
                self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, thisTargetDamage, "", showTracer and i == numTargets)
            end

            if self.shotgun_cartridge == "slug" then
                if not target:isa("Marine") and not target:isa("Exo") and not target:isa("Egg") and not target:isa("Embryo") and target:isa("Player") then
                    self.tracked_target = target:GetId()
                    self.hit_tracker_target_at = Shared.GetTime()
                end
            end

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
            StartSoundEffectOnEntity(draw_sound, player, 0.95)
        end
    elseif tagName == "Draw_End" then
        self.can_shoot = true
    elseif tagName == "Reload_Start" then
        -- self.can_shoot = false
        -- StartSoundEffectForPlayer(reload_sound, player, 0.55)
        -- if Server then
        --     StartSoundEffectOnEntity(reload_sound, player, 1)
        -- end
    elseif tagName == "Give_Cartridge" then
        self.required_ammo = self:GetClipSize() - self.clip
        if self.required_ammo > 0 and self.ammo > 0 then
            -- if self.ammo == 1 and self.required_ammo >= 1 then
            --     self.ammo = self.ammo - 1
            --     self.clip = self.clip + 1
            -- elseif self.ammo > 1 and self.required_ammo >= 2 then
            --     self.ammo = self.ammo - 2
            --     self.clip = self.clip + 2
            -- elseif self.ammo > 1 and self.required_ammo == 1 then
            --     self.ammo = self.ammo - 1
            --     self.clip = self.clip + 1
            -- end
            self.ammo = self.ammo - 1
            self.clip = self.clip + 1
            self.can_shoot = true
        else
            self.reloading = false
        end
    elseif tagName == "RELOAD_SOUND_HERE" then
        if Server then
            StartSoundEffectOnEntity(reload_sound, player, 0.35)
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
            StartSoundEffectOnEntity(shoot_sound, player, 0.35)
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
            elseif Shared.GetTime() <= self.last_attack_time + kAttackDelay then
                activity = "none"
                self.primaryAttacking = false
            end
        end
    end

    if self.reloading then -- not activity == "reload" and

        if self.primaryAttacking and self.clip > 0 then
            
            if Shared.GetTime() > self.last_attack_time + kAttackDelay then
                self.last_attack_time = Shared.GetTime()
                activity = "primary"
                self.reloading = false
            elseif Shared.GetTime() <= self.last_attack_time + kAttackDelay then
                activity = "none"
                -- self.primaryAttacking = false
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

function SuppressedShotgun:OnPrimaryAttack(player)

    local weapon_owner = self:GetParent()

    if weapon_owner then

        if self.clip == 0 and self.ammo > 0 and weapon_owner.GetIsSprinting and not weapon_owner:GetIsSprinting() then
            
            self.reloading = true
            weapon_owner:Reload()

        elseif self.clip > 0 then
                    
            if Shared.GetTime() > self.last_attack_time + kAttackDelay then

                self.primaryAttacking = true

            end

        end

    end
    
end

function SuppressedShotgun:GetSecondaryAttackRequiresPress()
    return true
end

function SuppressedShotgun:OnSecondaryAttack(player)

    if not player:GetSecondaryAttackLastFrame() then

        if player.weaponUpgradeLevel == 1 then
            if self.shotgun_cartridge == "standard" then
                self.shotgun_cartridge = "buckshot"
            elseif self.shotgun_cartridge == "buckshot" then
                self.shotgun_cartridge = "standard"
            else
                self.shotgun_cartridge = "standard"
            end
        elseif player.weaponUpgradeLevel == 2 then
            if self.shotgun_cartridge == "standard" then
                self.shotgun_cartridge = "buckshot"
            elseif self.shotgun_cartridge == "buckshot" then
                self.shotgun_cartridge = "incendiary"
            elseif self.shotgun_cartridge == "incendiary" then
                self.shotgun_cartridge = "standard"
            else
                self.shotgun_cartridge = "standard"
            end
        elseif player.weaponUpgradeLevel == 3 then
            if self.shotgun_cartridge == "standard" then
                self.shotgun_cartridge = "buckshot"
            elseif self.shotgun_cartridge == "buckshot" then
                self.shotgun_cartridge = "incendiary"
            elseif self.shotgun_cartridge == "incendiary" then
                self.shotgun_cartridge = "slug"
            elseif self.shotgun_cartridge == "slug" then
                self.shotgun_cartridge = "standard"
            else
                self.shotgun_cartridge = "standard"
            end
        elseif player.weaponUpgradeLevel == 4 then
            if self.shotgun_cartridge == "standard" then
                self.shotgun_cartridge = "buckshot"
            elseif self.shotgun_cartridge == "buckshot" then
                self.shotgun_cartridge = "incendiary"
            elseif self.shotgun_cartridge == "incendiary" then
                self.shotgun_cartridge = "slug"
            elseif self.shotgun_cartridge == "slug" then
                self.shotgun_cartridge = "standard"
            else
                self.shotgun_cartridge = "standard"
            end
        end
    
    end

end

function SuppressedShotgun:ApplyBulletGameplayEffects(player, hitEnt, impactPoint, direction, damage, surface, showTracer)
    if HasMixin(hitEnt, "Fire") and self.shotgun_cartridge == "incendiary" and not hitEnt:isa("Marine") and not hitEnt:isa("Hive") then
        hitEnt:SetOnFire(player, self)
    elseif self.shotgun_cartridge == "buckshot" then
        if Server then
            fragment = CreateEntity(BuckshotClusterFragment.kMapName, impactPoint, kTeam1Index)
            fragment:SetOwner(self:GetParent())
            fragment:Detonate()
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

function SuppressedShotgun:OnDraw(player, previousWeaponMapName)

    ClipWeapon.OnDraw(self, player, previousWeaponMapName)

    self.current_time = Shared.GetTime()

    if self.current_time - self.equipped_at >= 5 then

        local player = self:GetParent()

        if player then

            if Server then

                if player.SendDirectMessage then

                    player:SendDirectMessage('Secondary Attack: Switches between cartridges (W0: Standard [PVPVE] | W1: Buckshot [PVE] | W2: Incendiary [PVE] | W3: Slug [PVP])')
                    player:SendDirectMessage("Percentages are relative to the NS2 shotgun")
                    player:SendDirectMessage('Standard: 75% Dmg')
                    player:SendDirectMessage('Buckshot: 64% PDmg and 98% SDmg')
                    player:SendDirectMessage('Incendiary: 67.5% PDmg and Fire DOT')
                    player:SendDirectMessage('Slug: 64% Dmg in 1 Pellet & 5 sec data')

                end

            end

        end

        self.equipped_at = Shared.GetTime()

    end
    
end

function SuppressedShotgun:OnReload(player)

    -- ClipWeapon.OnReload(self, player)

    if player.GetIsSprinting and not player:GetIsSprinting() then
        self.reloading = true
    end

    --self.queuedShots = 0

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
