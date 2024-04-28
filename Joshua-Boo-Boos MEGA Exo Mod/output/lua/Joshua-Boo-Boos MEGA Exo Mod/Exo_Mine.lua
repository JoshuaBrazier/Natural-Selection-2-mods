Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/DamageMixin.lua")

if Server then
    Script.Load("lua/OwnerMixin.lua")
end

class 'Exo_Mine' (ScriptActor)

Exo_Mine.kMapName = "Exo_Mine"
Exo_Mine.kModelName = PrecacheAsset("models/marine/exo_mine/exo_mine.model")

local kExhaustCinematic = PrecacheAsset("cinematics/marine/exo/thruster.cinematic")
local kRocketExhaust = "Exhaust"

local missile_flight_sound = PrecacheAsset("sound/NS2_Exo_Mod_Sounds.fev/Exo_Mod_Sounds/Missile_Flight")
local missile_explode_sound = PrecacheAsset("sound/NS2.fev/marine/structures/arc/fire")
local mine_deploy_sound = PrecacheAsset("sound/NS2.fev/marine/common/mine_warmup")

local networkVars = {parent = "string (25)"} -- final_direction_vector = "Vector"}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)

if Server then
    AddMixinNetworkVars(OwnerMixin, networkVars)
end

local function compare(a,b)
    return a[1] < b[1]
end

function Exo_Mine:OnCreate()

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
        StartSoundEffectOnEntity(missile_flight_sound, self, 0.6)
    end

    -- self.time_created = Shared.GetTime()
    -- self.time_now = 0
    self.should_move = true
    self.should_explode = false
    self.final_direction_vector = nil
    self.initial_look_vector = nil
    self.parent_exo = nil

    -- if Client then
    --     self.exhaustCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
    --     self.exhaustCinematic:SetCinematic(kExhaustCinematic)
    --     self.exhaustCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
    --     self.exhaustCinematic:SetParent(self)
    --     self.exhaustCinematic:SetCoords(Coords.GetIdentity())
    --     self.exhaustCinematic:SetAttachPoint(self:GetAttachPointIndex(kRocketExhaust))
    --     self.exhaustCinematic:SetIsVisible(true)
    -- end

end

function Exo_Mine:Destroy()
    if Server then
        DestroyEntity(self)
    end
end

function Exo_Mine:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then
        self:SetModel(Exo_Mine.kModelName)
    end
    self:SetPhysicsType(PhysicsType.Kinematic)
    
end

function Exo_Mine:OnUpdate(deltaTime)

    PROFILE("ARC:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)

    if self.parent_exo == nil then
        local nearby_exos = GetEntitiesForTeamWithinRange("Exo", kTeam1Index, self:GetOrigin(), 3)
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
            self.parent = self.parent_exo:GetName()
        end
    end

    -- if self.parent_exo and not self.final_direction_vector then

    --     local nearby_missiles = GetEntitiesForTeamWithinRange("Exo_Mine", kTeam1Index, self:GetOrigin(), 5)

    --     if #nearby_missiles > 0 then

    --         self.final_direction_vector = nearby_missiles[1].final_direction_vector

    --     end

    -- end

    -- self.time_now = Shared.GetTime() -- Continuously update the time on the missile

    -- if self.time_now >= self.time_created + 5 or self.final_direction_vector == nil then -- If the missile has existed for five seconds or longer

    --     CreateExplosionDecals(self, "grenade_explode")
    --     local enemies_within_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 4)
    --     if #enemies_within_range > 0 then
    --         for i = 1, #enemies_within_range do
    --             if Server then
    --                 self:DoDamage(25, enemies_within_range[i], enemies_within_range[i]:GetOrigin(), nil)
    --             end
    --         end
    --         if Server then
    --             StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
    --             DestroyEntity(self)
    --         end
    --     end
    
    -- else

    local trace = Shared.TraceCapsule(self:GetOrigin(), self:GetOrigin() + 0.1 * self.final_direction_vector, 0.05, 0.05, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, self.parent_exo)) -- "Exo"
    --local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() + 0.05 * self.final_direction_vector, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
    if trace.fraction ~= 1 then
        self.should_move = false
        if Server then
            StartSoundEffectAtOrigin(mine_deploy_sound, self:GetOrigin())
        end
    end

    local enemies_within_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 2)

    if #enemies_within_range > 0 then

        self.should_explode = true

        local enemies_within_explosion_range = GetEntitiesForTeamWithinRange("Player", kTeam2Index, self:GetOrigin(), 5)

        for i = 1, #enemies_within_explosion_range do
            if Server then
                self:DoDamage(100, enemies_within_explosion_range[i], enemies_within_explosion_range[i]:GetOrigin(), nil)
            end
        end

    end
    if Server and self.should_explode then
        StartSoundEffectAtOrigin(missile_explode_sound, self:GetOrigin())
        DestroyEntity(self)
    end

    -- end

    if Server and self.should_move then
        SetAnglesFromVector(self, self.final_direction_vector)
        self:SetOrigin(self:GetOrigin() + 0.32 * self.final_direction_vector)
    end

end

function Exo_Mine:GetTeamType()
    return kMarineTeamType
end

Shared.LinkClassToMap("Exo_Mine", Exo_Mine.kMapName, networkVars, true)
