Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/DamageMixin.lua")

if Server then
    Script.Load("lua/OwnerMixin.lua")
end

class 'Exo_Support_Turret' (ScriptActor)

Exo_Support_Turret.kMapName = "exo_support_turret"
Exo_Support_Turret.kModelName = PrecacheAsset("models/marine/exo_support_turret/exo_support_turret.model")

local fire_sound = PrecacheAsset("sound/NS2.fev/marine/structures/arc/fire")

local laser_damage = 25

local networkVars = {owner_exo = 'entityid',
                    set_owner = 'boolean',
                    turret_number = 'integer (1 to 2)'}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)

if Server then
    AddMixinNetworkVars(OwnerMixin, networkVars)
end

local function compare(a,b)
    return a[1] < b[1]
end

function Exo_Support_Turret:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin, { kTriggeringEnabledDefault = true })
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DamageMixin)
    if Server then
        InitMixin(self, OwnerMixin)
    end
    
    self:SetLagCompensated(true)
    self:SetUpdates(true, kRealTimeUpdateRate)

    self.time_created = Shared.GetTime()
    self.time_now = 0
    self.locked_target = nil

    self.last_fired_timer_now = 0
    self.last_fired_timer = 0

    self.owner_exo = nil
    self.set_owner = false

    self.defenseMod = ModLoader.GetModInfo("defense")

end

function Exo_Support_Turret:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then
        self:SetModel(Exo_Support_Turret.kModelName)
    end
    self:SetPhysicsType(PhysicsType.Kinematic)
    
end

function Exo_Support_Turret:GetDeathIconIndex()
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

local kMaximumAngle = 75
local kTargetSeekingRange = 25
local kCloakingValueForMissileLockLoss = 0.5

function Exo_Support_Turret:GetTracerEffectName()
    return kRailgunTracerEffectName
end

function Exo_Support_Turret:GetTracerResidueEffectName()
    return kRailgunTracerResidueEffectName
end

function Exo_Support_Turret:GetTracerEffectFrequency()
    return 1
end

function Exo_Support_Turret:OnUpdate(deltaTime)
    PROFILE("Exo_Support_Turret:OnUpdate")
    ScriptActor.OnUpdate(self, deltaTime)
    self.last_fired_timer_now = Shared.GetTime()
    local owner_exo_entity
    if self.owner_exo then
        owner_exo_entity = Shared.GetEntity(self.owner_exo)
    end
    self.time_now = Shared.GetTime()
    if Server and owner_exo_entity ~= nil and IsValid(owner_exo_entity) and owner_exo_entity.GetViewCoords then
        SetAnglesFromVector(self, owner_exo_entity:GetViewCoords().zAxis)
    end
    if not self.set_owner then
        if Server then
            if self.owner_exo then
                self:SetOwner(Shared.GetEntity(self.owner_exo))
                self.set_owner = true
            end
        end
    elseif self.set_owner and owner_exo_entity ~= nil and IsValid(owner_exo_entity) then
        local entity_sphere = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), kTargetSeekingRange)
        local cone_of_targets = {}
        if #entity_sphere > 0 then
            for i = 1, #entity_sphere do
                if (CanHitTargetEntity(self:GetOrigin(), entity_sphere[i]:GetEyePos(), self, entity_sphere[i]) or CanHitTargetEntity(self:GetOrigin(), entity_sphere[i]:GetOrigin() + Vector(0, 0.2, 0), self, entity_sphere[i])) and entity_sphere[i]:GetCloakFraction() < kCloakingValueForMissileLockLoss then
                    local vector_to_enemy = GetNormalizedVector(entity_sphere[i]:GetOrigin() - self:GetOrigin())
                    local dotProductValue = vector_to_enemy:DotProduct(GetNormalizedVector(owner_exo_entity:GetViewCoords().zAxis))
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
            if self.last_fired_timer_now > self.last_fired_timer then
                if self.defenseMod then
                    self.last_fired_timer = Shared.GetTime() + 0.4
                else
                    self.last_fired_timer = Shared.GetTime() + 1
                end
                if IsValid(self.locked_target) and (self.locked_target).GetHealth and self.locked_target:GetHealth() > 0 then
                    self:DoDamage(laser_damage, self.locked_target, (self.locked_target):GetOrigin(), nil)
                    if Server then
                        StartSoundEffectOnEntity(fire_sound, self, 0.5)
                    end
                    -- Tell other players in relevancy to show the tracer. Does not tell the shooting player.
                    self:DoDamage(0, nil, self.locked_target:GetEyePos(), (self.locked_target:GetEyePos() - self:GetOrigin()):GetUnit(), nil, false, true)

                    -- Tell the player who shot to show the tracer.
                    if Client then
                        TriggerFirstPersonTracer(self, self.locked_target:GetEyePos())
                    end
                end
            end
        end
        if IsValid(owner_exo_entity) then
            if self.turret_number == 1 then
                self:SetOrigin(owner_exo_entity:GetOrigin() + (-0.6) * owner_exo_entity:GetViewCoords().xAxis + Vector(0, 3.1, 0) - 0.7 * owner_exo_entity:GetViewCoords().zAxis)
            elseif self.turret_number == 2 then
                self:SetOrigin(owner_exo_entity:GetOrigin() + (0.6) * owner_exo_entity:GetViewCoords().xAxis + Vector(0, 3.1, 0) - 0.7 * owner_exo_entity:GetViewCoords().zAxis)
            end
        end
        if self.defenseMod then
            if self.time_now > self.time_created + 30 then
                if Server then
                    DestroyEntity(self)
                end
            end
        else
            if self.time_now > self.time_created + 15 then
                if Server then
                    DestroyEntity(self)
                end
            end
        end
    end
end

function Exo_Support_Turret:GetTeamType()
    return kMarineTeamType
end

Shared.LinkClassToMap("Exo_Support_Turret", Exo_Support_Turret.kMapName, networkVars, true)
