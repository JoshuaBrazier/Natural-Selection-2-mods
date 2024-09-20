-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Shotgun.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Balance.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/Hitreg.lua")
Script.Load("lua/ShotgunVariantMixin.lua")

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class 'Shotgun' (ClipWeapon)

Shotgun.kMapName = "shotgun"

local networkVars =
{
    emptyPoseParam = "private float (0 to 1 by 0.01)",
    timeAttackStarted = "time",
    shotgun_cartridge = "string (11)",
    shortened_shotgun_cartridge = "string (3)",
    is_incendiary = "boolean",
    --sound_played_at = "float",
    --distance = "integer",
    tracked_target = 'entityid',
    time_now = 'time',
    hit_tracker_target_at = 'time',
}

AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(ShotgunVariantMixin, networkVars)

local standard_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/standard")
local buckshot_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/buckshot")
local incendiary_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/incendiary")
local slug_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/slug")
local reload_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/reload")

--local all_clear_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/all_clear")
local danger_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/danger")
local enemy_nearby_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/enemy_nearby")
local enemy_detected_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/enemy_detected")

-- local kSlugDamageMultiplier = 0.7

-- higher numbers reduces the spread
Shotgun.kStartOffset = 0.1
Shotgun.kBulletSize = 0.016 -- not used... leave in just in case some mod uses it.

Shotgun.kDamageFalloffStart = 5 -- in meters, full damage closer than this.
Shotgun.kDamageFalloffEnd = 15 -- in meters, minimum damage further than this, gradient between start/end.
Shotgun.kDamageFalloffReductionFactor = 0.5 -- 50% reduction

local kBulletsPerShot = 0 -- calculated from rings.
Shotgun.kSpreadVectors = {}
Shotgun.kShotgunRings =
{
    { pelletCount = 1, distance = 0.0000, pelletSize = 0.016, pelletDamage = 10, thetaOffset = 0},
    { pelletCount = 4, distance = 0.3500, pelletSize = 0.016, pelletDamage = 10, thetaOffset = 0},
    { pelletCount = 4, distance = 0.6364, pelletSize = 0.016, pelletDamage = 10, thetaOffset = math.pi * 0.25},
    { pelletCount = 4, distance = 1.0000, pelletSize = 0.016, pelletDamage = 10, thetaOffset = 0},
    { pelletCount = 4, distance = 1.1314, pelletSize = 0.016, pelletDamage = 10, thetaOffset = math.pi * 0.25}
}

local kRingFieldNames = {"pelletCount", "distance", "pelletSize", "pelletDamage"}
local function GetAreSpreadVectorsOutdated()

    -- Check kShotgunSpreadDistance constant
    if kShotgunSpreadDistance ~= Shotgun.__lastKShotgunSpreadDistance then
        return true
    end

    -- Check the rings table.
    if Shotgun.__lastKShotgunRings == nil then
        return true -- not cached yet.
    end

    for i = 1, #Shotgun.kShotgunRings do
        local ring = Shotgun.kShotgunRings[i]
        local lastRing = Shotgun.__lastKShotgunRings[i]
        for j = 1, #kRingFieldNames do
            local ringFieldName = kRingFieldNames[j]
            if ring[ringFieldName] ~= lastRing[ringFieldName] then
                return true
            end
        end
    end

end

local function UpdateCachedLastValues()

    Shotgun.__lastKShotgunSpreadDistance = kShotgunSpreadDistance
    Shotgun.__lastKShotgunRings = Shotgun.__lastKShotgunRings or {} -- create if missing.
    for i=1, #Shotgun.kShotgunRings do
        Shotgun.__lastKShotgunRings[i] = Shotgun.__lastKShotgunRings[i] or {} -- create if missing.
        local ring = Shotgun.kShotgunRings[i]
        local lastRing = Shotgun.__lastKShotgunRings[i]
        for j = 1, #kRingFieldNames do
            local ringFieldName = kRingFieldNames[j]
            lastRing[ringFieldName] = ring[ringFieldName]
        end
    end

end

function Shotgun._RecalculateSpreadVectors()
    PROFILE("Shotgun._RecalculateSpreadVectors")

    -- Only recalculate if we really need to.  Allow this to be lazily called from wherever
    -- Shotgun.kSpreadVectors is used, to ensure it's up-to-date.
    if not GetAreSpreadVectorsOutdated() then
        return
    end

    UpdateCachedLastValues() -- update cached values so we can detect changes.

    Shotgun.kSpreadVectors = {} -- reset
    kBulletsPerShot = 0

    local circle = math.pi * 2.0

    for _, ring in ipairs(Shotgun.kShotgunRings) do

        local radiansPer = circle / ring.pelletCount
        kBulletsPerShot = kBulletsPerShot + ring.pelletCount
        for pellet = 1, ring.pelletCount do

            local theta = radiansPer * (pellet - 1) + (ring.thetaOffset or 0)
            local x = math.cos(theta) * ring.distance
            local y = math.sin(theta) * ring.distance
            table.insert(Shotgun.kSpreadVectors, { vector = GetNormalizedVector(Vector(x, y, kShotgunSpreadDistance)), size = ring.pelletSize, damage = ring.pelletDamage})

        end

    end

end
Shotgun._RecalculateSpreadVectors()

Shotgun.kModelName = PrecacheAsset("models/marine/shotgun/shotgun.model")
local kViewModels = GenerateMarineViewModelPaths("shotgun")

local kShotgunFireAnimationLength = 0.8474577069282532 -- defined by art asset.
Shotgun.kFireDuration = kShotgunFireAnimationLength -- same duration for now.
-- Multiplier for fire animation
local kShotgunFireSpeedMult = 1 -- kShotgunFireAnimationLength / math.max(Shotgun.kFireDuration, 0.01)

PrecacheAsset("cinematics/marine/shotgun/muzzle_flash.cinematic")

function Shotgun:OnCreate()

    ClipWeapon.OnCreate(self)

    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, ShotgunVariantMixin)

    self.emptyPoseParam = 0

    self.shotgun_cartridge = "standard"
    self.shortened_shotgun_cartridge = "ST"
    self.is_incendiary = false
    self.sound_played_at = 0

    self.distance = 0

    self.tracked_target = 0

    self.time_now = 0
    self.hit_tracker_target_at = 0

end

if Client then

    function Shotgun:OnInitialized()

        ClipWeapon.OnInitialized(self)

    end

end

-- function Shotgun:Dropped(prevOwner)

--     ClipWeapon.Dropped(self, prevOwner)
    
--     self.cartridge_type = "standard"
    
-- end

function Shotgun:GetPrimaryMinFireDelay()
    return Shotgun.kFireDuration
end

function Shotgun:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.19319871068000793, 0.0, 0.04182741045951843))
end

function Shotgun:GetAnimationGraphName()
    return ShotgunVariantMixin.kShotgunAnimationGraph
end

function Shotgun:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function Shotgun:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

function Shotgun:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Shotgun:GetClipSize()
    return kShotgunClipSize
end

function Shotgun:GetBulletsPerShot()
    return kBulletsPerShot
end

function Shotgun:GetRange()
    return 100
end

-- Only play weapon effects every other bullet to avoid sonic overload
function Shotgun:GetTracerEffectFrequency()
    return 0.5
end

-- Not used (just a required override of ClipWeapon)
function Shotgun:GetBulletDamage()
    return 0
end

function Shotgun:GetHasSecondary()
    return true
end

function Shotgun:GetSecondaryAttackRequiresPress()
    return true
end

function Shotgun:GetPrimaryCanInterruptReload()
    return true
end

function Shotgun:GetSecondaryCanInterruptReload()
    return true
end

function Shotgun:GetWeight()
    return kShotgunWeight
end

function Shotgun:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("empty", self.emptyPoseParam)

end

function Shotgun:OnUpdateAnimationInput(modelMixin)
    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)

    modelMixin:SetAnimationInput("attack_mult", kShotgunFireSpeedMult)
end

local function LoadBullet(self)

    if self.ammo > 0 and self.clip < self:GetClipSize() then

        self.clip = self.clip + 1
        self.ammo = self.ammo - 1

    end

    -- local parent = self:GetParent()

    -- if self.ammo > 0 and self.clip < self:GetClipSize() then
    --     if self.ammo == 1 then
    --         self.clip = self.clip + 1
    --         self.ammo = self.ammo - 1
    --     elseif self.ammo > 1 then
    --         if self.clip == 5 then
    --             self.clip = self.clip + 1
    --             self.ammo = self.ammo - 1
    --         elseif self.clip < 5 then
    --             local chance_roll = math.random()
    --             if chance_roll <= 0.5 then
    --                 self.clip = self.clip + math.max(1, parent.weaponUpgradeLevel-1)
    --                 self.ammo = self.ammo - math.max(1, parent.weaponUpgradeLevel-1)
    --             else
    --                 self.clip = self.clip + 1
    --                 self.ammo = self.ammo - 1
    --             end
    --         end
    --     end
    -- end

end


function Shotgun:OnTag(tagName)

    PROFILE("Shotgun:OnTag")

    local continueReloading = false
    if self:GetIsReloading() and tagName == "reload_end" then

        continueReloading = true
        self.reloading = false

    end

    ClipWeapon.OnTag(self, tagName)

    if tagName == "load_shell" then
        LoadBullet(self)
    elseif tagName == "reload_shotgun_start" then
        self:TriggerEffects("shotgun_reload_start")
    elseif tagName == "reload_shotgun_shell" then
        self:TriggerEffects("shotgun_reload_shell")
    elseif tagName == "reload_shotgun_end" then
        self:TriggerEffects("shotgun_reload_end")
    end

    if continueReloading then

        local player = self:GetParent()
        if player then
            player:Reload()
        end

    end

end

-- used for last effect
function Shotgun:GetEffectParams(tableParams)
    tableParams[kEffectFilterEmpty] = self.clip == 1
end

function Shotgun:FirePrimary(player)

    if self.shotgun_cartridge == "standard" then
        Shotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000, pelletSize = 0.016, pelletDamage = 10, thetaOffset = 0},
            { pelletCount = 4, distance = 0.3500, pelletSize = 0.016, pelletDamage = 10, thetaOffset = 0},
            { pelletCount = 4, distance = 0.6364, pelletSize = 0.016, pelletDamage = 10, thetaOffset = math.pi * 0.25},
            { pelletCount = 4, distance = 1.0000, pelletSize = 0.016, pelletDamage = 10, thetaOffset = 0},
            { pelletCount = 4, distance = 1.1314, pelletSize = 0.016, pelletDamage = 10, thetaOffset = math.pi * 0.25}
        }
        
    elseif self.shotgun_cartridge == "buckshot" then
        Shotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000, pelletSize = 0.016, pelletDamage = 18.5, thetaOffset = 0},
            { pelletCount = 2, distance = 0.65, pelletSize = 0.016, pelletDamage = 18.5, thetaOffset = 0},
            { pelletCount = 2, distance = 0.65, pelletSize = 0.016, pelletDamage = 18.5, thetaOffset = math.pi * 0.66},
            { pelletCount = 2, distance = 0.65, pelletSize = 0.016, pelletDamage = 18.5, thetaOffset = math.pi * 1.33},
        }
        
    elseif self.shotgun_cartridge == "incendiary" then
        Shotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000, pelletSize = 0.016, pelletDamage = 15.5, thetaOffset = 0},
            { pelletCount = 3, distance = 0.300, pelletSize = 0.016, pelletDamage = 15.5, thetaOffset = 0},
            { pelletCount = 3, distance = 0.600, pelletSize = 0.016, pelletDamage = 15.5, thetaOffset = math.pi * 0.25},
            { pelletCount = 3, distance = 0.9000, pelletSize = 0.016, pelletDamage = 15.5, thetaOffset = 0},
        }
        
    elseif self.shotgun_cartridge == "slug" then
        Shotgun.kShotgunRings =
        {
            { pelletCount = 1, distance = 0.0000, pelletSize = 0.016, pelletDamage = 135, thetaOffset = 0}
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
    Shotgun._RecalculateSpreadVectors()

    local numberBullets = self:GetBulletsPerShot()

    self:TriggerEffects("shotgun_attack_sound")
    self:TriggerEffects("shotgun_attack")

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

            if self.shotgun_cartridge == "slug" then
                if not target:isa("Marine") and not target:isa("Exo") and not target:isa("Egg") and not target:isa("Embryo") and target:isa("Player") then
                    self.tracked_target = target:GetId()
                    self.hit_tracker_target_at = Shared.GetTime()
                end
                -- Shared.Message("Hit target" .. Shared.GetEntity(self.tracked_target):GetName() .. "using tracker - self.tracked_target is:" .. string.format("%s", self.tracked_target))
            end

            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, thisTargetDamage)
            end

        end

    end

    if self.clip == 2 then

        StartSoundEffectForPlayer(reload_sound, player, 0.75)

    end
    
end

function Shotgun:OnSecondaryAttack(player)

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
        end

        if Client then
            if self.shotgun_cartridge == "standard" then
                StartSoundEffectOnEntity(standard_sound, self:GetParent(), 0.75)
            elseif self.shotgun_cartridge == "buckshot" then
                StartSoundEffectOnEntity(buckshot_sound, self:GetParent(), 0.75)
            elseif self.shotgun_cartridge == "incendiary" then
                StartSoundEffectOnEntity(incendiary_sound, self:GetParent(), 0.75)
            elseif self.shotgun_cartridge == "slug" then
                StartSoundEffectOnEntity(slug_sound, self:GetParent(), 0.75)
            end
        end
    
    end

end

function Shotgun:OnDraw(player, previousWeaponMapName)

    ClipWeapon.OnDraw(self, player, previousWeaponMapName)

    if self.shotgun_cartridge == "standard" then
        StartSoundEffectForPlayer(standard_sound, player, 0.75)
    elseif self.shotgun_cartridge == "buckshot" then
        StartSoundEffectForPlayer(buckshot_sound, player, 0.75)
    elseif self.shotgun_cartridge == "incendiary" then
        StartSoundEffectForPlayer(incendiary_sound, player, 0.75)
    elseif self.shotgun_cartridge == "slug" then
        StartSoundEffectForPlayer(slug_sound, player, 0.75)
    end

end

function Shotgun:ApplyBulletGameplayEffects(player, hitEnt, impactPoint, direction, damage, surface, showTracer)
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

function Shotgun:OnProcessMove(input)
    ClipWeapon.OnProcessMove(self, input)
    self.emptyPoseParam = Clamp(Slerp(self.emptyPoseParam, ConditionalValue(self.clip == 0, 1, 0), input.time * 1), 0, 1)
end

function Shotgun:GetAmmoPackMapName()
    return ShotgunAmmo.kMapName
end


if Client then

    function Shotgun:GetBarrelPoint()

        local player = self:GetParent()
        if player then

            local origin = player:GetEyePos()
            local viewCoords= player:GetViewCoords()

            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.18 + viewCoords.yAxis * -0.2

        end

        return self:GetOrigin()

    end

    function Shotgun:GetUIDisplaySettings()
        return { xSize = 256, ySize = 128, script = "lua/GUIShotgunDisplay.lua", variant = self:GetShotgunVariant() }
    end

    function Shotgun:OnUpdateRender()

        ClipWeapon.OnUpdateRender( self )
    
        local parent = self:GetParent()
        local settings = self:GetUIDisplaySettings()

        if parent and parent:GetIsLocalPlayer() and not parent:isa("Commander") then

            if parent:GetActiveWeapon() then

                if parent:GetActiveWeapon():isa("Shotgun") then
            
                    if Shared.GetTime() > self.sound_played_at + 10 - (2/3)*parent.weaponUpgradeLevel then

                        local show_distance_to_nearest_uncloaked_enemy = false
                    
                        local enemies = GetEntitiesForTeamWithinRange("Player", kTeam2Index, parent:GetOrigin(), 8 + 3.34 * parent.weaponUpgradeLevel)

                        local enemy_not_cloaked = false

                        local distance_enemy_table = {}

                        for i = 1, #enemies do

                            local vector_difference_to_enemy = enemies[i]:GetOrigin() - parent:GetOrigin()
                            local distance_to_enemy = vector_difference_to_enemy:GetLength()
                            --Log("vector_difference_to_enemy " .. i .. " is: " .. distance_to_enemy)
                            if enemies[i]:GetCloakFraction() < 0.45 + 0.1 * parent.weaponUpgradeLevel then
                                enemy_not_cloaked = true
                                table.insert(distance_enemy_table, math.floor(distance_to_enemy))
                            end

                        end

                        if #enemies > 0 and enemy_not_cloaked then
                            
                            table.sort(distance_enemy_table)

                            -- for i = 1, #distance_enemy_table do

                            --     Log("Distance value " .. i .. ": " .. distance_enemy_table[i])

                            -- end

                            self.distance = distance_enemy_table[1]

                            --Log("Minimum distance: " .. self.distance)

                            if 0 < self.distance and self.distance < 7 then

                                StartSoundEffectOnEntity(danger_sound, self, 0.2)

                            elseif 7 <= self.distance and self.distance < 14 then

                                StartSoundEffectOnEntity(enemy_nearby_sound, self, 0.2)

                            elseif 14 <= self.distance then

                                StartSoundEffectOnEntity(enemy_detected_sound, self, 0.2)

                            end
                            
                            self.sound_played_at = Shared.GetTime()

                        end

                        if #enemies == 0 or not enemy_not_cloaked then
                            self.distance = 0
                            self.sound_played_at = Shared.GetTime()
                            --StartSoundEffectOnEntity(all_clear_sound, self, 0.2)
                        end

                    end
                
                elseif not parent:GetActiveWeapon():isa("Shotgun") then
                    self.sound_played_at = Shared.GetTime()
                end

            end

        end

        if parent and parent:GetIsLocalPlayer() then
            local viewModel = parent:GetViewModelEntity()
            if viewModel and viewModel:GetRenderModel() then
    
                local clip = self:GetClip()
                local time = Shared.GetTime()
    
                if self.lightCount ~= clip and
                        not self.lightChangeTime or self.lightChangeTime + 0.15 < time
                then
                    self.lightCount = clip
                    self.lightChangeTime = time
                end
    
                viewModel:InstanceMaterials()
                viewModel:GetRenderModel():SetMaterialParameter("ammo", self.lightCount or 6 )
    
            end
        end
    
        if parent and parent:GetIsLocalPlayer() and settings then
    
            local isActive = self:GetIsActive()
            local mapName = settings.textureNameOverride or self:GetMapName()
            local ammoDisplayUI = GetWeaponDisplayManager():GetWeaponDisplayScript(settings, mapName)
            self.ammoDisplayUI = ammoDisplayUI
            
            ammoDisplayUI:SetGlobal("weaponClip", parent:GetWeaponClip())
            ammoDisplayUI:SetGlobal("weaponAmmo", parent:GetWeaponAmmo())
            ammoDisplayUI:SetGlobal("weaponAuxClip", parent:GetAuxWeaponClip())
    
            if self.shotgun_cartridge == "standard" then
               self.shortened_shotgun_cartridge = "ST"
            elseif self.shotgun_cartridge == "buckshot" then
               self.shortened_shotgun_cartridge = "BU"
            elseif self.shotgun_cartridge == "incendiary" then
               self.shortened_shotgun_cartridge = "IN"
            elseif self.shotgun_cartridge == "slug" then
               self.shortened_shotgun_cartridge = "SL"
            end

            ammoDisplayUI:SetGlobal("cartridge_type", self.shortened_shotgun_cartridge)

            --Log("Distance: " .. self.distance)

            if self.distance > 0 then

                --Log("GOT DISTANCE")

                ammoDisplayUI:SetGlobal("distance_to_target", self.distance)

            else

                --Log("NOT GOT DISTANCE")

                ammoDisplayUI:SetGlobal("distance_to_target", 0)

            end

            if settings.variant and isActive then
                --[[
                    Only update variant if we are the active weapon, since some
                    of these GUIViews are re-used. For example, the Builder and Welder GUIViews are one
                    and the same, which could cause (randomly, depending on the order of execution) the builder
                    to override the variant of the welder due to this method being called for both weapons, and the
                    builder's UpdateRender function being called _after_ the welder's.
                --]]
                ammoDisplayUI:SetGlobal("weaponVariant", settings.variant)
            end
            self.ammoDisplayUI:SetGlobal("globalTime", Shared.GetTime())
            -- For some reason I couldn't pass a bool here so... this is for modding anyways!
            -- If you pass anything that's not "true" it will disable the low ammo warning
            self.ammoDisplayUI:SetGlobal("lowAmmoWarning", tostring(Weapon.kLowAmmoWarningEnabled))
            
            -- Render this frame, if the weapon is active.  This is called every frame, so we're just
            -- saying "render one frame" every frame it's equipped.  Easier than keeping track of
            -- when the weapon is holstered vs equipped, and this call is super cheap.
            if isActive then
                self.ammoDisplayUI:SetRenderCondition(GUIView.RenderOnce)
            end
            
        end
        
    end

end

function Shotgun:ModifyDamageTaken(damageTable, _, _, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function Shotgun:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

function Shotgun:GetIdleAnimations(index)
    local animations = {"idle", "idle_check", "idle_clean"}
    return animations[index]
end

if Server then

    function Shotgun:GetDestroyOnKill()
        return true
    end

    function Shotgun:GetSendDeathMessageOverride()
        return false
    end

end

Shared.LinkClassToMap("Shotgun", Shotgun.kMapName, networkVars)
