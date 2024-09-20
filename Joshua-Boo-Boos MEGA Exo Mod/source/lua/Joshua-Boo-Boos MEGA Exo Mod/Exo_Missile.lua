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

local kExhaustCinematic = PrecacheAsset("cinematics/marine/exo/thruster.cinematic")
local newExhaustCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic")
local kRocketExhaust = "Exhaust"

local missile_flight_sound = PrecacheAsset("sound/NS2_Exo_Mod_Sounds.fev/Exo_Mod_Sounds/Missile_Flight")
local missile_explode_sound = PrecacheAsset("sound/NS2.fev/marine/structures/arc/fire")

local networkVars = {}

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

function Exo_Missile:OnUpdate(deltaTime)

    PROFILE("Exo_Missile:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)

    if self.locked_target and not debug.isvalid(self.locked_target) then
        local enemies_within_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 4)
        if #enemies_within_range > 0 then
            for i = 1, #enemies_within_range do
                if Server then
                    self:DoDamage(50, enemies_within_range[i], enemies_within_range[i]:GetOrigin(), nil)
                end
            end
        end
        -- if Server then
        --     StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
        --     DestroyEntity(self)
        -- end
        if Server then
            StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
            self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
            CreateExplosionDecals(self)
            DestroyEntity(self)
        end
    end


    if self.parent_exo == nil then
        local nearby_exos = GetEntitiesForTeamWithinRange("Exo", kTeam1Index, self:GetOrigin(), 2)
        local exo_info_data_pairs = {}
        if #nearby_exos > 0 then
            for i = 1, #nearby_exos do
                local data_pair = {(nearby_exos[i]:GetOrigin() - self:GetOrigin()):GetLength(), nearby_exos[i]}
                table.insert(exo_info_data_pairs, data_pair)
            end
            table.sort(exo_info_data_pairs, compare)
            self.parent_exo = exo_info_data_pairs[1][2]
            if Server then
                self:SetOwner(self.parent_exo)
            end
            --self:SetOrigin(self.parent_exo:GetEyePos() + GetNormalizedVector(self.parent_exo:GetViewCoords().zAxis))
            self:SetOrigin(self:GetOrigin() + Vector(0, 2.5, 0))
            --Log("Exo name is " .. self.parent_exo:GetName())
            self.final_direction_vector = GetNormalizedVector(self.parent_exo:GetViewCoords().zAxis)
            self.initial_look_vector = self.final_direction_vector
        end
    end
    if self.final_direction_vector then
        local trace = Shared.TraceCapsule(self:GetOrigin(), self:GetOrigin() + 0.3 * self.final_direction_vector, 0.1, 0.1, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, "Exo"))
        --local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() + 0.05 * self.final_direction_vector, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
        if trace.fraction ~= 1 then
            local enemies_within_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 4)
            if #enemies_within_range > 0 then
                for i = 1, #enemies_within_range do
                    if Server then
                        self:DoDamage(50, enemies_within_range[i], enemies_within_range[i]:GetOrigin(), nil)
                    end
                end
            end
            -- if Server then
            --     StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
            --     DestroyEntity(self)
            -- end
            if Server then
                StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
                self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
                CreateExplosionDecals(self)
                DestroyEntity(self)
            end
        end
    end
    self.time_now = Shared.GetTime() -- Continuously update the time on the missile
    if self.time_now >= self.time_created + 5 then -- If the missile has existed for five seconds or longer
        local enemies_within_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 4)
        if #enemies_within_range > 0 then
            for i = 1, #enemies_within_range do
                if Server then
                    self:DoDamage(50, enemies_within_range[i], enemies_within_range[i]:GetOrigin(), nil)
                end
            end
            -- if Server then
            --     StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
            --     DestroyEntity(self)
            -- end
            if Server then
                StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
                self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
                CreateExplosionDecals(self)
                DestroyEntity(self)
            end
        end
    end
    if self.locked_target and not debug.isvalid(self.locked_target) then
        self.locked_target = nil
        local enemies_within_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 4)
        if #enemies_within_range > 0 then
            for i = 1, #enemies_within_range do
                if Server then
                    self:DoDamage(50, enemies_within_range[i], enemies_within_range[i]:GetOrigin(), nil)
                end
            end
        end
        if Server then
            StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
            self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
            CreateExplosionDecals(self)
            DestroyEntity(self)
        end
    elseif not self.locked_target then
        if Server then
            SetAnglesFromVector(self, self.final_direction_vector)
            self:SetOrigin(self:GetOrigin() + 0.48 * self.final_direction_vector)
        end
        local nearby_targets = {}
        local check_for_targets = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 10)
        local distance_and_target_pair_table = {}
        if #check_for_targets > 0 then
            for i = 1, #check_for_targets do
                if check_for_targets[i] and check_for_targets[i]:GetIsAlive() then
                    if check_for_targets[i]:GetCloakFraction() < 0.5 then
                        table.insert(nearby_targets, check_for_targets[i])
                    end
                end
            end
        end
        if #nearby_targets > 0 then
            for i = 1, #nearby_targets do
                local distance = (self:GetOrigin() - nearby_targets[i]:GetOrigin()):GetLength()
                local target = nearby_targets[i]
                local data_pair = {distance, target}
                table.insert(distance_and_target_pair_table, data_pair)
            end
            table.sort(distance_and_target_pair_table, compare)
            self.locked_target = distance_and_target_pair_table[1][2]
        end
    elseif self.locked_target and debug.isvalid(self.locked_target) then
        if self.locked_target:GetCloakFraction() < 0.5 then
            local vector_difference_to_target = self.locked_target:GetOrigin() - self:GetOrigin()
            self.final_direction_vector = GetNormalizedVector(vector_difference_to_target)
            local distance_to_target = vector_difference_to_target:GetLength()
            if distance_to_target < 0.5 then
                local enemies_within_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 4)
                if #enemies_within_range > 0 then
                    for i = 1, #enemies_within_range do
                        if Server then
                            self:DoDamage(50, enemies_within_range[i], enemies_within_range[i]:GetOrigin(), nil)
                        end
                    end
                    -- if Server then
                    --     StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
                    --     DestroyEntity(self)
                    -- end
                    if Server then
                        StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
                        self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
                        CreateExplosionDecals(self)
                        DestroyEntity(self)
                    end
                end
            end
            if Server then
                SetAnglesFromVector(self, self.final_direction_vector)
            end
            self:SetOrigin(self:GetOrigin() + 0.48 * self.final_direction_vector)
        else
            self.locked_target = nil
            self.final_direction_vector = self.initial_look_vector
        end
    end
end

function Exo_Missile:GetTeamType()
    return kMarineTeamType
end

Shared.LinkClassToMap("Exo_Missile", Exo_Missile.kMapName, networkVars, true)
