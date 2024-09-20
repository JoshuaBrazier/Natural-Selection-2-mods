-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Sentry.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--                  Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/StunMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
--Script.Load("lua/LaserMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/TriggerMixin.lua")
Script.Load("lua/TargettingMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")

local kSpinUpSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_spin_up")
local kSpinDownSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_spin_down")

class 'Sentry' (ScriptActor)

Sentry.kMapName = "sentry"

Sentry.kModelName = PrecacheAsset("models/marine/sentry/sentry.model")
local kAnimationGraph = PrecacheAsset("models/marine/sentry/sentry.animation_graph")

local kBulletSound = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_fire_loop")
local kFlamerSound = PrecacheAsset("sound/NS2.fev/marine/flamethrower/attack_loop")
local kGLSound = PrecacheAsset("sound/NS2.fev/marine/rifle/fire_grenade")
local kShotgunSound = PrecacheAsset("sound/NS2.fev/marine/shotgun/fire")

local standard_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/standard")
local incendiary_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/incendiary")
local slug_sound = PrecacheAsset("sound/shotgun_sounds.fev/shotgun sounds/slug")

local cinematic_update_time = 0.10

local kSentryScanSoundName = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_scan")
Sentry.kUnderAttackSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/sentry_taking_damage")
Sentry.kFiringAlertSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/commander/sentry_firing")

Sentry.kConfusedSound = PrecacheAsset("sound/NS2.fev/marine/structures/sentry_confused")

Sentry.kFireShellEffect = nil -- PrecacheAsset("cinematics/marine/sentry/fire_shell.cinematic")

firstpersoncins = {
    
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic")

}

local function BurnSporesAndUmbra(startPoint, endPoint)

    local toTarget = endPoint - startPoint
    local length = toTarget:GetLength()
    toTarget:Normalize()

    local stepLength = 2
    for i = 1, 5 do

        -- stop when target has reached, any spores would be behind
        if length < i * stepLength then
            break
        end

        local checkAtPoint = startPoint + toTarget * i * stepLength
        local spores = GetEntitiesWithinRange("SporeCloud", checkAtPoint, kSporesDustCloudRadius)

        local clouds = GetEntitiesWithinRange("CragUmbra", checkAtPoint, CragUmbra.kRadius)
        table.copy(GetEntitiesWithinRange("StormCloud", checkAtPoint, StormCloud.kRadius), clouds, true)
        table.copy(GetEntitiesWithinRange("MucousMembrane", checkAtPoint, MucousMembrane.kRadius), clouds, true)
        table.copy(GetEntitiesWithinRange("EnzymeCloud", checkAtPoint, EnzymeCloud.kRadius), clouds, true)

        local bombs = GetEntitiesWithinRange("Bomb", checkAtPoint, 1.6)
        table.copy(GetEntitiesWithinRange("WhipBomb", checkAtPoint, 1.6), bombs, true)

        for i = 1, #bombs do
            local bomb = bombs[i]
            bomb:TriggerEffects("burn_bomb", { effecthostcoords = Coords.GetTranslation(bomb:GetOrigin()) } )
            DestroyEntity(bomb)
        end

        for i = 1, #spores do
            local spore = spores[i]
            spore:TriggerEffects("burn_spore", { effecthostcoords = Coords.GetTranslation(spore:GetOrigin()) } )
            DestroyEntity(spore)
        end

        for i = 1, #clouds do
            local cloud = clouds[i]
            cloud:TriggerEffects("burn_umbra", { effecthostcoords = Coords.GetTranslation(cloud:GetOrigin()) } )
            DestroyEntity(cloud)
        end

    end

end

-- Balance
Sentry.kPingInterval = 4
Sentry.kFov = 160
Sentry.kMaxPitch = 80 -- 160 total
Sentry.kMaxYaw = Sentry.kFov / 2
Sentry.kTargetScanDelay = 1.5

Sentry.kDamage = kSentryDamage
Sentry.kRange = kSentryRange
Sentry.kBaseROF = kSentryAttackBaseROF
Sentry.kRandROF = kSentryAttackRandROF
Sentry.kSpread = 0 -- kSentrySpread
Sentry.kBulletsPerSalvo = kSentryAttackBulletsPerSalvo
Sentry.kBarrelScanRate = 60      -- Degrees per second to scan back and forth with no target
Sentry.kBarrelMoveRate = 150    -- Degrees per second to move sentry orientation towards target or back to flat when targeted
Sentry.kBarrelMoveTargetMult = 4 -- when a target is acquired, how fast to swivel the barrel
Sentry.kReorientSpeed = .05

Sentry.kTargetAcquireTime = kSentryTargetAcquireTime
Sentry.kConfuseDuration = kSentryConfuseDuration
Sentry.kAttackEffectInterval = kSentryAttackEffectInterval
Sentry.kConfusedAttackEffectInterval = kConfusedSentryBaseROF

-- Animations
Sentry.kYawPoseParam = "sentry_yaw" -- Sentry yaw pose parameter for aiming
Sentry.kPitchPoseParam = "sentry_pitch"
Sentry.kMuzzleNode = "fxnode_sentrymuzzle"
Sentry.kEyeNode = "fxnode_eye"
Sentry.kLaserNode = "fxnode_eye"

-- prevents attacking during deploy animation for kDeployTime seconds
local kDeployTime = 3.5

local networkVars =
{    
    -- So we can update angles and pose parameters smoothly on client
    targetDirection = "vector",  
    
    confused = "boolean",
    
    deployed = "boolean",
    
    attacking = "boolean",
    
    attachedToBattery = "boolean",

    length = "float",

    mode = "string (25)",

    deployed_at = "time",

    owner_entity_id = "entityid",

    target_changed = "boolean"

}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
--AddMixinNetworkVars(LaserMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)

function Sentry:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, StunMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, ParasiteMixin)    
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self.desiredYawDegrees = 0
    self.desiredPitchDegrees = 0
    self.barrelYawDegrees = 0
    self.barrelPitchDegrees = 0

    self.confused = false
    self.attachedToBattery = false
    
    -- self.owner_entity_id = GetCommander(kTeam1Index):GetId()
    
    self.trailCinematic = nil

    self.mode = "bullet"

    self.last_changed_fire_mode = Shared.GetTime()

    self.deployed_at = 0

    self.target_changed = false

    self.length = 0

    self.time_now = Shared.GetTime()

    if Server then

        self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
        self.attackSound:SetParent(self)
        self.attackSound:SetAsset(self:GetAttackSoundName())
        
    elseif Client then
    
        self.timeLastAttackEffect = Shared.GetTime()
        
        -- Play a "ping" sound effect every Sentry.kPingInterval while scanning.
        local function PlayScanPing(sentry)
        
            local interval = sentry.kTargetScanDelay + sentry.kPingInterval
            if GetIsUnitActive(sentry) and not sentry.attacking and sentry.attachedToBattery and (sentry.timeLastAttackEffect + interval < Shared.GetTime())  then
                local player = Client.GetLocalPlayer()
                Shared.PlayPrivateSound(player, kSentryScanSoundName, nil, 1, sentry:GetModelOrigin())
            end
            return true
            
        end
        
        self:AddTimedCallback(PlayScanPing, self.kPingInterval)
        
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    self:SetUpdates(true, .05)
    
end

function Sentry:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, WeldableMixin)
    
    --InitMixin(self, LaserMixin)
    
    self:SetModel(Sentry.kModelName, kAnimationGraph)
    
    if Server then 
    
        InitMixin(self, SleeperMixin)
        
        self.timeLastTargetChange = Shared.GetTime()
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        -- TargetSelectors require the TargetCacheMixin for cleanup.
        InitMixin(self, TargetCacheMixin)
        InitMixin(self, SupplyUserMixin)
        
        -- configure how targets are selected and validated
        self.targetSelector = TargetSelector():Init(
            self,
            Sentry.kRange, 
            true,
            { kMarineStaticTargets, kMarineMobileTargets },
            { PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch), CloakTargetFilter() },
            { function(target) return target:isa("Player") end } )

        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)   
        InitMixin(self, HiveVisionMixin)
 
    end
    
end

function Sentry:OnDestroy()

    ScriptActor.OnDestroy(self)
    
    -- The attackSound was already destroyed at this point, clear the reference.
    self.attackSound = nil
    if self.trailCinematic then
        Client.DestroyTrailCinematic(self.trailCinematic)
        self.trailCinematic = nil
    end
    
end

function Sentry:GetAttackSoundName()
    if self.mode == "flame" then
        return kFlamerSound
    elseif self.mode == "bullet" then
        return kBulletSound
    end
end

-- sets the options for the trail:
-- **************************************************************************************************************************************************************************
-- optionTable.numSegments              "integer"           number of segments in the trail
-- optionTable.collidesWithWorld        "boolean"           cinematics will stack up at the end if the trail collides with the world
-- optionTable.alignAngles              "boolean"           cinematics will align angles
-- optionTable.visibilityChangeDuration "float"             time it takes to change visibility of the trail (starts at first segment)
-- optionTable.fadeOutCinematics        "boolean"           if fade out is true, cinematics will be recreated everytime visiblity changes to true or to false then set them to Repeat_None and reject handle
-- optionTable.trailLength              "float"             total length of the trail
-- optionTable.stretchTrail             "boolean"           the trail will exceed the total length and stretches
-- optionTable.trailWeight              "float"             weight of the trail. Segments closer to the end will have more weight applied to them (Y values reduced
-- optionTable.maxLength           "float"
--
-- following 3 options control the bending of the trail. minHardening is applied to the last segment (higher values will make the trail stiff) and is interpolated
-- to maxHardening for the first segments. hardeningModifier is multiplied with the result
-- optionTable.hardeningModifier        "float"
-- optionTable.minHardening             "float"
-- optionTable.maxHardening             "float"
-- **************************************************************************************************************************************************************************

function Sentry:InitTrailCinematic(length)

    self.trailCinematic = Client.CreateTrailCinematic(RenderScene.Zone_Default)
    self.trailCinematic:SetCinematicNames(firstpersoncins)
    
        -- attach to third person fx node otherwise with an X offset since we align it along the X-Axis (the attackpoint is oriented in the model like that)
    self.trailCinematic:AttachTo(self, TRAIL_ALIGN_X,  Vector(0.3, 0, 0), "fxnode_sentrymuzzle")
    minHardeningValue = 5.25
    maxHardeningValue = 0.1
    numFlameSegments = #firstpersoncins

    self.trailCinematic:SetIsVisible(true)
    self.trailCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    self.trailCinematic:SetOptions( {
            numSegments = numFlameSegments,
            collidesWithWorld = true,
            visibilityChangeDuration = 0,
            fadeOutCinematics = false,
            stretchTrail = true,
            trailLength = 2 * length,
            minHardening = 100,
            maxHardening = 100,
            hardeningModifier = 5,
            trailWeight = 0.04,
            maxLength = 1.1 * self.kRange
        } )
    -- self.trailCinematic:SetIsVisible(true)
end

function Sentry:GetCanSleep()
    return self.attacking == false
end

function Sentry:GetMinimumAwakeTime()
    return 10
end 

function Sentry:GetFov()
    return Sentry.kFov
end

local kSentryEyeHeight = Vector(0, 0.8, 0)
function Sentry:GetEyePos()
    return self:GetOrigin() + kSentryEyeHeight
end

function Sentry:GetDeathIconIndex()
    return kDeathMessageIcon.Sentry
end

function Sentry:GetReceivesStructuralDamage()
    return true
end

function Sentry:GetBarrelPoint()
    return self:GetAttachPointOrigin(Sentry.kMuzzleNode)    
end

function Sentry:GetLaserAttachCoords()

    local coords = self:GetAttachPointCoords(Sentry.kLaserNode)    
    local xAxis = coords.xAxis
    coords.xAxis = -coords.zAxis
    coords.zAxis = xAxis

    return coords   
end

function Sentry:OverrideLaserLength()
    return self.kRange
end

function Sentry:GetPlayInstantRagdoll()
    return true
end

function Sentry:GetIsLaserActive()
    return GetIsUnitActive(self) and self.deployed and self.attachedToBattery
end

function Sentry:OnUpdatePoseParameters()

    PROFILE("Sentry:OnUpdatePoseParameters")

    local pitchConfused = 0
    local yawConfused = 0
    
    -- alter the yaw and pitch slightly, barrel will swirl around
    if self.confused then
    
        pitchConfused = math.sin(Shared.GetTime() * 6) * 2
        yawConfused = math.cos(Shared.GetTime() * 6) * 2
        
    end
    
    self:SetPoseParam(Sentry.kPitchPoseParam, self.barrelPitchDegrees + pitchConfused)
    self:SetPoseParam(Sentry.kYawPoseParam, self.barrelYawDegrees + yawConfused)
    
end

function Sentry:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sentry:OnUpdateAnimationInput")    
    modelMixin:SetAnimationInput("attack", self.attacking)
    modelMixin:SetAnimationInput("powered", self.attachedToBattery)
    
end

-- used to prevent showing the hit indicator for the commander
function Sentry:GetShowHitIndicator()
    return false
end

function Sentry:OnWeldOverride(entity, elapsedTime)

    local welded = false

    -- faster repair rate for sentries, promote use of welders
    if entity:isa("Welder") then

        local amount = kWelderSentryRepairRate * elapsedTime
        self:AddHealth(amount)

    elseif entity:isa("MAC") then

        self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime)

    end

end

function Sentry:GetHealthbarOffset()
    return 0.4
end 

if Server then

    local function OnDeploy(self)
    
        self.attacking = false
        self.deployed = true
        self.deployed_at = Shared.GetTime()
        return false
        
    end
    
    function Sentry:OnConstructionComplete()
        self:AddTimedCallback(OnDeploy, kDeployTime)      
    end
    
    function Sentry:OnStun(duration)
        self:Confuse(duration)
    end
    
    function Sentry:GetDamagedAlertId()
        return kTechId.MarineAlertSentryUnderAttack
    end

    function Sentry:FireFlames()

        local fireCoords = Coords.GetLookIn(Vector(0,0,0), self.targetDirection)     
        local startPoint = self:GetBarrelPoint()
        local spreadDirection = CalculateSpread(fireCoords, 0, math.random)
        local endPoint = startPoint + spreadDirection * self.kRange

        local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))

        if trace.fraction < 1 then

            if trace.entity then

                if trace.entity.GetHealth and trace.entity:GetHealth() > 0 and GetAreEnemies(trace.entity, self) then

                    self.length = math.sqrt((trace.entity:GetOrigin() - startPoint):GetLengthSquared()) 

                    BurnSporesAndUmbra(startPoint, trace.entity:GetOrigin())

                    ----------------
                    local path = {}
                    local overall_enemies = {}

                    for i = 1, math.ceil(self.length/2) do

                        table.insert(path, startPoint + (i/math.ceil(self.length/2)) * (trace.entity:GetOrigin() - startPoint))

                    end

                    if #path > 0 then

                        for i = 1, #path do

                            local nearby_alien_entities = {}
                            local enemy_structures = GetEntitiesWithMixinForTeamWithinRange("Construct", kTeam2Index, path[i], 1)
                            local enemy_players = GetEntitiesForTeamWithinRange("Alien", kTeam2Index, path[i], 1)

                            if #enemy_structures > 0 then

                                for i = 1, #enemy_structures do
                                    table.insert(nearby_alien_entities, enemy_structures[i])
                                end

                            end

                            if #enemy_players > 0 then

                                for i = 1, #enemy_players do
                                    table.insert(nearby_alien_entities, enemy_players[i])
                                end

                            end

                            if #nearby_alien_entities > 0 then
                                
                                for i = 1, #nearby_alien_entities do

                                    if HasMixin(nearby_alien_entities[i], "Fire") then
                                        
                                        table.insert(overall_enemies, nearby_alien_entities[i])

                                    end

                                end

                            end
                        
                        end

                    end
                    
                    local unique_enemies = {}

                    for i = 1, #overall_enemies do

                        if not table.contains(unique_enemies, overall_enemies[i]) then

                            table.insert(unique_enemies, overall_enemies[i])
                        
                        end

                    end
                    ----------------

                    -- Shared.Message(string.format("%i overall enemies nearby", #overall_enemies, i))
                    -- Shared.Message(string.format("%i unique enemies nearby", #unique_enemies, i))

                    for i = 1, #unique_enemies do

                        if HasMixin(unique_enemies[i], "Fire") then

                            self:DoDamage( 7, unique_enemies[i], unique_enemies[i]:GetOrigin(), nil )

                            if not unique_enemies[i]:GetIsOnFire() then

                                unique_enemies[i]:SetOnFire(Shared.GetEntity(self.ownerId), self)

                            end

                        end

                    end

                end

            end

        end
        
    end

    function Sentry:FireBullets()

        local fireCoords = Coords.GetLookIn(Vector(0,0,0), self.targetDirection)     
        local startPoint = self:GetBarrelPoint()

        for bullet = 1, self.kBulletsPerSalvo do
        
            local spreadDirection = CalculateSpread(fireCoords, self.kSpread, math.random)

            local endPoint = startPoint + spreadDirection * self.kRange
            
            local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
            
            if trace.fraction < 1 then
            
                local damage = self.kDamage
                local surface = trace.surface
                
                -- Disable friendly fire.
                trace.entity = (not trace.entity or GetAreEnemies(trace.entity, self)) and trace.entity or nil
                
                local blockedByUmbra = trace.entity and GetBlockedByUmbra(trace.entity) or false
                
                if blockedByUmbra then
                    surface = "umbra"
                end
                
                local direction = (trace.endPoint - startPoint):GetUnit()
                --Print("Sentry %d doing %.2f damage to %s (ramp up %.2f)", self:GetId(), damage, SafeClassName(trace.entity), rampUpFraction)
                self:DoDamage(damage, trace.entity, trace.endPoint, direction, surface, false, true)
                                
            end
            
        end
        
    end
    
    -- checking at range 1.8 for overlapping the radius a bit. no LOS check here since i think it would become too expensive with multiple sentries
    function Sentry:GetFindsSporesAt(position)
        return #GetEntitiesWithinRange("SporeCloud", position, kSporesDustCloudRadius * 0.75) > 0
    end
    
    function Sentry:Confuse(duration)

        if not self.confused then
        
            self.confused = true
            self.timeConfused = Shared.GetTime() + duration
            
            StartSoundEffectOnEntity(self.kConfusedSound, self)
            
        end
        
    end
    

    local kSporesConfusionDelay = 0.2

    -- check for spores in our way every kSporesConfusionDelay seconds
    local function UpdateConfusedState(self, target)

        if not self.confused and target then
            
            if not self.timeCheckedForSpores then
                self.timeCheckedForSpores = Shared.GetTime() - kSporesConfusionDelay
            end
            
            if self.timeCheckedForSpores + kSporesConfusionDelay < Shared.GetTime() then
            
                self.timeCheckedForSpores = Shared.GetTime()
            
                local eyePos = self:GetEyePos()
                local toTarget = target:GetOrigin() - eyePos
                local distanceToTarget = toTarget:GetLength()
                toTarget:Normalize()
                
                local stepLength = 3
                local numChecks = math.ceil(self.kRange/stepLength)
                
                -- check every few meters for a spore in the way, min distance 3 meters, max 12 meters (but also check sentry eyepos)
                for i = 0, numChecks do
                
                    -- stop when target has reached, any spores would be behind
                    if distanceToTarget < (i * stepLength) then
                        break
                    end
                
                    local checkAtPoint = eyePos + toTarget * i * stepLength
                    if self:GetFindsSporesAt(checkAtPoint) then
                        self:Confuse(self.kConfuseDuration)
                        break
                    end
                
                end
            
            end
            
        elseif self.confused then
        
            if self.timeConfused < Shared.GetTime() then
                self.confused = false
            end
        
        end

    end
    
    local function UpdateBatteryState(self)
    
        local time = Shared.GetTime()
        
        if self.lastBatteryCheckTime == nil or (time > self.lastBatteryCheckTime + 0.5) then
        
            -- Update if we're powered or not
            self.attachedToBattery = false
            
            local ents = GetEntitiesForTeamWithinRange("SentryBattery", self:GetTeamNumber(), self:GetOrigin(), SentryBattery.kRange)
            for index, ent in ipairs(ents) do
            
                if GetIsUnitActive(ent) and ent:GetLocationName() == self:GetLocationName() then
                
                    self.attachedToBattery = true
                    break
                    
                end
                
            end
            
            self.lastBatteryCheckTime = time
            
        end
        
    end
    
    function Sentry:OnUpdate(deltaTime)
    
        PROFILE("Sentry:OnUpdate")
        
        ScriptActor.OnUpdate(self, deltaTime)
        
        -- elseif techtree:GetHasTech(kTechId.Weapons1) then
        --     self.mode = "bullet"
        -- end

        if self:GetOwner() then
            self.owner_entity_id = self:GetOwner():GetId()
            -- Shared.Message(string.format("name of owner is %s", Shared.GetEntity(self.owner_entity_id):GetName()))
        end
        
        UpdateBatteryState(self)

        -- if not self.attacking and self.deployed and Shared.GetTime() >= self.deployed_at + 2 then
        --     self:GetFireModeChanger()
        -- end
        
        if self.timeNextAttack == nil or (Shared.GetTime() > self.timeNextAttack) then
        
            local initialAttack = self.target == nil
            
            local prevTarget
            if self.target then
                prevTarget = self.target
            end
            
            self.target = nil
            
            if GetIsUnitActive(self) and self.attachedToBattery and self.deployed then
                if self.mode == "bullet" then

                    self.targetSelector = TargetSelector():Init(
                        self,
                        14, 
                        true,
                        { kMarineStaticTargets, kMarineMobileTargets },
                        { PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch), CloakTargetFilter() },
                        { function(target) return target:isa("Player") end } )
                    self.kRange = 14
                    self.kSpread = kSentrySpread

                elseif self.mode == "flame" then

                    self.targetSelector = TargetSelector():Init(
                        self,
                        10, 
                        true,
                        { kMarineStaticTargets, kMarineMobileTargets },
                        { PitchTargetFilter(self,  -Sentry.kMaxPitch, Sentry.kMaxPitch), CloakTargetFilter() },
                        { function(target) return target:isa("Player") end } )
                    self.kRange = 10
                    self.kSpread = 0
                end
                self.target = self.targetSelector:AcquireTarget()
            end
            
            UpdateConfusedState(self, self.target)
            -- slower fire rate when confused
            local confusedTime = self.confused == true and self.kConfusedAttackEffectInterval or 0

            -- Random rate of fire so it can't be gamed
            if initialAttack and self.target then
                self.timeNextAttack = Shared.GetTime() + self.kTargetAcquireTime
            else
                self.timeNextAttack = confusedTime + Shared.GetTime() + self.kBaseROF + math.random() * self.kRandROF
            end

            if self.target then
            
                local previousTargetDirection = self.targetDirection
                self.targetDirection = GetNormalizedVector(self.target:GetEngagementPoint() - self:GetAttachPointOrigin(Sentry.kMuzzleNode))
                
                -- Reset damage ramp up if we moved barrel at all
                if previousTargetDirection then
                    local dotProduct = previousTargetDirection:DotProduct(self.targetDirection)
                    if dotProduct < .99 then
                    
                        self.timeLastTargetChange = Shared.GetTime()
                        
                    end    
                end

                -- Or if target changed, reset it even if we're still firing in the exact same direction
                if self.target ~= prevTarget then
                    self.timeLastTargetChange = Shared.GetTime()
                end

                self.target_changed = true

                -- don't shoot immediately
                if not initialAttack then

                    if GetHasTech(self:GetOwner(), kTechId.Weapons3) then
                        self.mode = "flame"
                        if IsValid(self.attackSound) then
                            DestroyEntity(Shared.GetEntity(self.attackSound:GetId()))
                            self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
                            self.attackSound:SetParent(self)
                            self.attackSound:SetAsset(self:GetAttackSoundName())
                        else
                            self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
                            self.attackSound:SetParent(self)
                            self.attackSound:SetAsset(self:GetAttackSoundName())
                        end
                        self:FireFlames()
                    else
                        self.mode = "bullet"
                        if IsValid(self.attackSound) then
                            DestroyEntity(Shared.GetEntity(self.attackSound:GetId()))
                            self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
                            self.attackSound:SetParent(self)
                            self.attackSound:SetAsset(self:GetAttackSoundName())
                        else
                            self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
                            self.attackSound:SetParent(self)
                            self.attackSound:SetAsset(self:GetAttackSoundName())
                        end
                        self:FireBullets()

                    end
                    
                    self.attacking = true
                    
                end    
                
            else
            
                self.attacking = false
                self.timeLastTargetChange = Shared.GetTime()

            end
            
            if not GetIsUnitActive() or self.confused or not self.attacking or not self.attachedToBattery then
            
                if not IsValid(self.attackSound) then
                    self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
                    self.attackSound:SetParent(self)
                    self.attackSound:SetAsset(self:GetAttackSoundName())
                else
                    if self.attackSound:GetIsPlaying() then
                        self.attackSound:Stop()
                    end
                end
                
            elseif self.attacking then
            
                if not IsValid(self.attackSound) then
                    self.attackSound = Server.CreateEntity(SoundEffect.kMapName)
                    self.attackSound:SetParent(self)
                    self.attackSound:SetAsset(self:GetAttackSoundName())
                end
                
                if not self.attackSound:GetIsPlaying() then
                    self.attackSound:Start()
                end

            end 
        
        end
    
    end

elseif Client then

    local function UpdateAttackEffects(self, deltaTime)
    
        local intervall = self.confused == true and self.kConfusedAttackEffectInterval or self.kAttackEffectInterval

        if self.attacking and (self.timeLastAttackEffect + intervall < Shared.GetTime()) then
        
            if self.confused then
                self:TriggerEffects("sentry_single_attack")
            end
            
            -- plays muzzle flash and smoke
            -- self:TriggerEffects("sentry_attack")

            self.timeLastAttackEffect = Shared.GetTime()
            
        end
        
    end

    function Sentry:OnUpdate(deltaTime)
    
        ScriptActor.OnUpdate(self, deltaTime)

        -- if self.confused and self.trailCinematic ~= nil then

        --     Client.DestroyTrailCinematic(self.trailCinematic)
        --     self.trailCinematic = nil

        -- end

        -- if self.target_changed == true and self.trailCinematic ~= nil then

        --     Client.DestroyTrailCinematic(self.trailCinematic)
        --     self.trailCinematic = nil

        -- end

        self.reset_cinematic = false

        if Shared.GetTime() >= self.time_now then

            self.reset_cinematic = true
        
            self.time_now = self.time_now + cinematic_update_time

        end

        if self.attacking and not self.trailCinematic and self.mode == "flame" then

            self:InitTrailCinematic(self.length)
        
        elseif self.attacking and self.trailCinematic then

            if self.confused and self.trailCinematic then

                Client.DestroyTrailCinematic(self.trailCinematic)
                self.trailCinematic = nil

            end

            if self.reset_cinematic and self.trailCinematic then

                Client.DestroyTrailCinematic(self.trailCinematic)
                self.trailCinematic = nil
                self:InitTrailCinematic(self.length)

            end

        elseif not self.attacking then

            if self.trailCinematic then

                Client.DestroyTrailCinematic(self.trailCinematic)
                self.trailCinematic = nil

            end

        end
        
        if GetIsUnitActive(self) and self.deployed and self.attachedToBattery then
      
            local swingMult = 1.0

            -- Swing barrel yaw towards target
            if self.attacking then
            
                if self.targetDirection then
                
                    local invSentryCoords = self:GetAngles():GetCoords():GetInverse()
                    self.relativeTargetDirection = GetNormalizedVector( invSentryCoords:TransformVector( self.targetDirection ) )
                    self.desiredYawDegrees = Clamp(math.asin(-self.relativeTargetDirection.x) * 180 / math.pi, -self.kMaxYaw, self.kMaxYaw)
                    self.desiredPitchDegrees = Clamp(math.asin(self.relativeTargetDirection.y) * 180 / math.pi, -self.kMaxPitch, self.kMaxPitch)
                    
                    swingMult = self.kBarrelMoveTargetMult

                end
                
                UpdateAttackEffects(self, deltaTime)
                
            -- Else when we have no target, swing it back and forth looking for targets
            else
            
                local interval = self.kTargetScanDelay
                if (self.timeLastAttackEffect + interval < Shared.GetTime()) then
                    local sin = math.sin(math.rad((Shared.GetTime() + self:GetId() * .3) * Sentry.kBarrelScanRate))
                    self.desiredYawDegrees = sin * self:GetFov() / 2

                    -- Swing barrel pitch back to flat
                    self.desiredPitchDegrees = 0
                end
            end
            
            -- swing towards desired direction
            self.barrelPitchDegrees = Slerp(self.barrelPitchDegrees, self.desiredPitchDegrees, self.kBarrelMoveRate * swingMult * deltaTime)
            self.barrelYawDegrees = Slerp(self.barrelYawDegrees , self.desiredYawDegrees, self.kBarrelMoveRate * swingMult * deltaTime)
        
        end
    
    end

end

function GetCheckSentryLimit(techId, origin, normal, commander)

    -- Prevent the case where a Sentry in one room is being placed next to a
    -- SentryBattery in another room.
    local battery = GetSentryBatteryInRoom(origin)
    if battery then
    
        if (battery:GetOrigin() - origin):GetLength() > SentryBattery.kRange then
            return false
        end
        
    else
        return false
    end
    
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local numInRoom = 0
    local validRoom = false
    
    if locationName then
    
        validRoom = true
        
        for index, sentry in ientitylist(Shared.GetEntitiesWithClassname("Sentry")) do
        
            if sentry:GetLocationName() == locationName then
                numInRoom = numInRoom + 1
            end
            
        end
        
    end
    
    return validRoom and numInRoom < kSentriesPerBattery
    
end

function GetBatteryInRange(commander)

    local entities = { }
    local ranges = { }

    for _, battery in ipairs(GetEntitiesForTeam("SentryBattery", commander:GetTeamNumber())) do
        ranges[battery] = SentryBattery.kRange
        table.insert(entities, battery)
    end
    
    return entities, ranges
    
end

Shared.LinkClassToMap("Sentry", Sentry.kMapName, networkVars)