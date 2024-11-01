Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/DamageMixin.lua")

if Server then
    Script.Load("lua/OwnerMixin.lua")
end

class 'Sentry_Missile' (ScriptActor)

Sentry_Missile.kMapName = "sentry_missile"
Sentry_Missile.kModelName = PrecacheAsset("models/marine/exo_missile/exo_missile.model")

local kExhaustCinematic = PrecacheAsset("cinematics/marine/exo/thruster.cinematic")
local newExhaustCinematic = PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic")
local kRocketExhaust = "Exhaust"

local missile_flight_sound = PrecacheAsset("sound/NS2_Exo_Mod_Sounds.fev/Exo_Mod_Sounds/Missile_Flight")
local missile_explode_sound = PrecacheAsset("sound/NS2.fev/marine/structures/arc/fire")

local missile_damage_value = 32.5
local speed = 0.8
local damage_range = 4
local decreasing_damage = false

local networkVars = {
    final_direction_vector = "vector",
    owner_entity_id = "entityid",
    set_owner = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)

if Server then
    AddMixinNetworkVars(OwnerMixin, networkVars)
end

local function compare(a,b)
    return a[1] < b[1]
end

function Sentry_Missile:OnCreate()

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
        StartSoundEffectOnEntity(missile_flight_sound, self, 0.08)
    end

    self.time_created = Shared.GetTime()
    self.time_now = 0
    self.final_direction_vector = nil
    self.owner_entity_id = 0
    self.set_owner = false

    self:SetIsVisible(false)

    if Client then
        self.exhaustCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
        self.exhaustCinematic:SetCinematic(newExhaustCinematic)
        self.exhaustCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.exhaustCinematic:SetParent(self)
        self.exhaustCinematic:SetCoords(Coords.GetIdentity())
        self.exhaustCinematic:SetAttachPoint(self:GetAttachPointIndex(kRocketExhaust))
    end

end

function Sentry_Missile:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then
        self:SetModel(Sentry_Missile.kModelName)
    end
    self:SetPhysicsType(PhysicsType.Kinematic)
    
end

function Sentry_Missile:GetDeathIconIndex()
    return kDeathMessageIcon.Minigun
end

function Sentry_Missile:OnUpdate(deltaTime)

    PROFILE("Sentry_Missile:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)

    if not self.set_owner then

        local nearby_sentries = GetEntitiesForTeamWithinRange("Exo", kTeam1Index, self:GetOrigin(), 5)
        local sentry_info_data_pairs = {}
        if #nearby_sentries > 0 then
            for i = 1, #nearby_sentries do
                local data_pair = {(nearby_sentries[i]:GetOrigin() - self:GetOrigin()):GetLength(), nearby_sentries[i]}
                table.insert(sentry_info_data_pairs, data_pair)
            end
            table.sort(sentry_info_data_pairs, compare)
            self.parent_sentry = sentry_info_data_pairs[1][2]
            if Server then
                self:SetOwner(self.parent_sentry)
                -- Shared.Message(string.format("Owner is: %s", self:GetOwner():GetName()))
                self.set_owner = true
            end
            --self:SetOrigin(self.parent_sentry:GetEyePos() + GetNormalizedVector(self.parent_sentry:GetViewCoords().zAxis))
            --Log("Sentry name is " .. self.parent_sentry:GetName())
            -- self.final_direction_vector = GetNormalizedVector(self.parent_sentry:GetAngles():GetCoords().zAxis)
        end

    else

        self.time_now = Shared.GetTime() -- Continuously update the time on the missile

        if self.time_now >= self.time_created + 5 or self.final_direction_vector == nil then -- If the missile has existed for five seconds or longer

            if Server then

                StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
                self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
                CreateExplosionDecals(self)
                local enemy_entities = GetEntitiesWithMixinForTeamWithinRange("Construct", kTeam2Index, self:GetOrigin(), damage_range)
                local enemies_within_range = GetEntitiesForTeamWithinRange("Alien", kTeam2Index, self:GetOrigin(), damage_range)
                local result = {}

                if #enemy_entities > 0 then
                    for i = 1, #enemy_entities do
                        table.insert(result, enemy_entities[i])
                    end
                end

                if #enemies_within_range > 0 then
                    for i = 1, #enemies_within_range do
                        table.insert(result, enemies_within_range[i])
                    end
                end
                
                if #result > 0 then
                    for i = 1, #result do
                        if Server then
                            if decreasing_damage then
                                self:DoDamage(missile_damage_value * (1 - (1/damage_range) * math.sqrt((result[i]:GetOrigin() - self:GetOrigin()):GetLengthSquared())), result[i], result[i]:GetOrigin(), nil)
                            else
                                self:DoDamage(missile_damage_value, result[i], result[i]:GetOrigin(), nil)
                            end
                        end
                    end
                    
                end
                
                DestroyEntity(self)
            end
        
        else

            local trace = Shared.TraceCapsule(self:GetOrigin(), self:GetOrigin() + 0.3 * self.final_direction_vector, 0.15, 0.15, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, self.parent_sentry)) -- "Sentry"
            --local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() + 0.05 * self.final_direction_vector, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
            if trace.fraction ~= 1 then

                if Server then

                    StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
                    self:TriggerEffects("pulse_grenade_explode", {kEffectHostCoords = Coords.GetTranslation( self:GetOrigin() )})
                    CreateExplosionDecals(self)

                    local enemy_entities = GetEntitiesWithMixinForTeamWithinRange("Construct", kTeam2Index, self:GetOrigin(), damage_range)
                    local enemies_within_range = GetEntitiesForTeamWithinRange("Alien", kTeam2Index, self:GetOrigin(), damage_range)
                    local result = {}

                    if #enemy_entities > 0 then
                        for i = 1, #enemy_entities do
                            table.insert(result, enemy_entities[i])
                        end
                    end

                    if #enemies_within_range > 0 then
                        for i = 1, #enemies_within_range do
                            table.insert(result, enemies_within_range[i])
                        end
                    end
                    
                    if #result > 0 then
                        for i = 1, #result do
                            if Server then
                                if decreasing_damage then
                                    self:DoDamage(missile_damage_value * (1 - (1/damage_range) * math.sqrt((result[i]:GetOrigin() - self:GetOrigin()):GetLengthSquared())), result[i], result[i]:GetOrigin(), nil)
                                else
                                    self:DoDamage(missile_damage_value, result[i], result[i]:GetOrigin(), nil)
                                end
                            end
                        end
                        
                    end
                    
                    DestroyEntity(self)

                end
            end

        end

        if Server then
            SetAnglesFromVector(self, self.final_direction_vector)
            self:SetOrigin(self:GetOrigin() + speed * self.final_direction_vector)
        end

        if Client then
            self.exhaustCinematic:SetIsVisible(true)
        end

        self:SetIsVisible(true)
        
    end

end

function Sentry_Missile:GetTeamType()
    return kMarineTeamType
end

Shared.LinkClassToMap("Sentry_Missile", Sentry_Missile.kMapName, networkVars, true)
