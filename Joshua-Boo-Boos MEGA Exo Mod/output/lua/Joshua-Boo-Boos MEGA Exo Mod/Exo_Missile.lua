Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/DamageMixin.lua")

if Server then
    Script.Load("lua/OwnerMixin.lua")
end

class 'Exo_Missile' (ScriptActor)

Exo_Missile.kMapName = "exo_missile"
Exo_Missile.kModelName = PrecacheAsset("models/marine/exo_missile/exo_missile.model")

local newExhaustCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic")
local kRocketExhaust = "Exhaust"

local missile_flight_sound = PrecacheAsset("sound/NS2_Exo_Mod_Sounds.fev/Exo_Mod_Sounds/Missile_Flight")
local missile_explode_sound = PrecacheAsset("sound/NS2.fev/marine/structures/arc/fire")

local networkVars = {owner_exo = 'entityid',
                    final_direction_vector = 'vector',
                    initial_look_vector = 'vector',
                    set_owner = 'boolean',
                    locked_target_id = 'entityid',
                    tracking_missile_damage = 'float'}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)

if Server then
    AddMixinNetworkVars(OwnerMixin, networkVars)
end

local function compare(a,b)
    return a[1] < b[1]
end

function Exo_Missile:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin, { kTriggeringEnabledDefault = true })
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DamageMixin)
    if Server then
        InitMixin(self, OwnerMixin)
    end
    
    self:SetLagCompensated(true)
    self:SetUpdates(true, kRealTimeUpdateRate)

    if Server then
        StartSoundEffectOnEntity(missile_flight_sound, self, 0.15)
    end

    self.time_created = Shared.GetTime()
    self.time_now = 0
    self.locked_target = nil
    self.final_direction_vector = nil
    self.initial_look_vector = nil
    self.tracking_missile_damage = 0

    self.owner_exo = nil
    self.set_owner = false

    if Client then
        self.exhaustCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.exhaustCinematic:SetCinematic(newExhaustCinematic)
        self.exhaustCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.exhaustCinematic:SetParent(self)
        self.exhaustCinematic:SetCoords(Coords.GetIdentity())
        self.exhaustCinematic:SetAttachPoint(self:GetAttachPointIndex(kRocketExhaust))
    end

end

function Exo_Missile:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then
        self:SetModel(Exo_Missile.kModelName)
    end
    self:SetPhysicsType(PhysicsType.Kinematic)
    
end

function Exo_Missile:GetDeathIconIndex()
    return kDeathMessageIcon.ARC
end

local function CanHitTargetEntity(startPoint, endPoint, start_entity, targetEntity)
    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(start_entity))
    local dist = (startPoint - endPoint):GetLength()
    local hitWorld = false
    local hitTargetEntity = false
    -- Hit nothing?
    if trace.fraction == 1 then
        hitWorld = false
        -- Hit the world?
    elseif not trace.entity then
        dist = (startPoint - trace.endPoint):GetLength()
        hitWorld = true
    elseif trace.entity == targetEntity then
        hitTargetEntity = true
        -- Hit target entity, return traced distance to it.
        dist = (startPoint - trace.endPoint):GetLength()
        hitWorld = false
    end
    return hitTargetEntity, hitWorld, dist
end

local kMaximumAngle = 50
local kDistanceFromTargetToExplodeAt = 2.5
local kExplosionRadius = 6
local kTargetSeekingRange = 7.5
local kMissileSpeed = 0.48
local kCloakingValueForMissileLockLoss = 0.5

function Exo_Missile:OnUpdate(deltaTime)
    PROFILE("Exo_Missile:OnUpdate")
    ScriptActor.OnUpdate(self, deltaTime)
    if not self.set_owner then
        if Server then
            if self.owner_exo then
                self:SetOwner(Shared.GetEntity(self.owner_exo))
                self.set_owner = true
            end
        end
    end
    if self.locked_target then
        if not IsValid(Shared.GetEntity(self.locked_target_id)) then
            if Server then
                DestroyEntity(self)
            end
        end
    end
    self.time_now = Shared.GetTime()
    if self.time_now > self.time_created + 5 then
        local enemies_sphere = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), kExplosionRadius)
        local visible_enemies = {}
        if #enemies_sphere > 0 then
            for i = 1, #enemies_sphere do
                -- if CanHitTargetEntity(self:GetOrigin(), enemies_sphere[i]:GetOrigin(), self, enemies_sphere[i]) then
                    if Server then
                        self:DoDamage(self.tracking_missile_damage, enemies_sphere[i], enemies_sphere[i]:GetOrigin(), nil)
                    end
                -- end
            end
        end
        if Server then
            StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
            self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
            CreateExplosionDecals(self)
            DestroyEntity(self)
        end
    elseif self.locked_target and (self:GetOrigin() - self.locked_target:GetOrigin()):GetLength() < kDistanceFromTargetToExplodeAt then
        local enemies_sphere = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), kExplosionRadius)
        local visible_enemies = {}
        if #enemies_sphere > 0 then
            for i = 1, #enemies_sphere do
                -- if CanHitTargetEntity(self:GetOrigin(), enemies_sphere[i]:GetOrigin(), self, enemies_sphere[i]) then
                    if Server then
                        self:DoDamage(self.tracking_missile_damage, enemies_sphere[i], enemies_sphere[i]:GetOrigin(), nil)
                    end
                -- end
            end
        end
        if Server then
            StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
            self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
            CreateExplosionDecals(self)
            DestroyEntity(self)
        end
    end
    if Server then
        SetAnglesFromVector(self, self.final_direction_vector)
    end
    if self.set_owner then
        local trace = Shared.TraceCapsule(self:GetOrigin(), self:GetOrigin() + 0.3 * self.final_direction_vector, 0.1, 0.1, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, "Exo"))
        if trace.fraction ~= 1 then
            local enemies_sphere = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), kExplosionRadius)
            local visible_enemies = {}
            if #enemies_sphere > 0 then
                for i = 1, #enemies_sphere do
                    -- if CanHitTargetEntity(self:GetOrigin(), enemies_sphere[i]:GetOrigin(), self, enemies_sphere[i]) then
                        if Server then
                            self:DoDamage(self.tracking_missile_damage, enemies_sphere[i], enemies_sphere[i]:GetOrigin(), nil)
                        end
                    -- end
                end
            end
            if Server then
                StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
                self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
                CreateExplosionDecals(self)
                DestroyEntity(self)
            end
        end
        local entity_sphere = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), kTargetSeekingRange)
        local cone_of_targets = {}
        if #entity_sphere > 0 then
            for i = 1, #entity_sphere do
                if (CanHitTargetEntity(self:GetOrigin(), entity_sphere[i]:GetEyePos(), self, entity_sphere[i]) or CanHitTargetEntity(self:GetOrigin(), entity_sphere[i]:GetOrigin() + Vector(0, 0.2, 0), self, entity_sphere[i])) and entity_sphere[i]:GetCloakFraction() < kCloakingValueForMissileLockLoss then
                    local vector_to_enemy = GetNormalizedVector(entity_sphere[i]:GetOrigin() - self:GetOrigin())
                    local dotProductValue = vector_to_enemy:DotProduct(GetNormalizedVector(self.final_direction_vector))
                    local angle = math.acos(dotProductValue) * (180 / 3.14159)
                    local distance_to_target = vector_to_enemy:GetLength()
                    if angle < kMaximumAngle then
                        table.insert(cone_of_targets, {distance_to_target, entity_sphere[i]})
                    end
                end
            end
        end
        if #cone_of_targets > 0 then
            table.sort(cone_of_targets, compare)
            self.locked_target = Shared.GetEntity(cone_of_targets[1][2]:GetId())
            self.locked_target_id = self.locked_target:GetId()
            self.final_direction_vector = GetNormalizedVector(self.locked_target:GetOrigin() - self:GetOrigin())
        end
        self:SetOrigin(self:GetOrigin() + kMissileSpeed * self.final_direction_vector)
    end
end

function Exo_Missile:GetTeamType()
    return kMarineTeamType
end

Shared.LinkClassToMap("Exo_Missile", Exo_Missile.kMapName, networkVars, true)
