Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")

if Server then
    Script.Load("lua/OwnerMixin.lua")
end

class 'Bullet' (ScriptActor)

Bullet.kMapName = "bullet"
Bullet.kModelName = PrecacheAsset("models/bullet/bullet.model")

local networkVars = {

    owner_id = "entityid",
    final_direction_vector = "vector",
    set_owner = "boolean"
    
}

local speed = 4

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)

if Server then
    AddMixinNetworkVars(OwnerMixin, networkVars)
end

local function compare(a,b)
    return a[1] < b[1]
end

local speed = 4

function Bullet:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin, { kTriggeringEnabledDefault = true })
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DamageMixin)
    if Server then
        InitMixin(self, OwnerMixin)
    end
    
    self:SetLagCompensated(true)
    self:SetUpdates(true, kRealTimeUpdateRate)

    self:SetPhysicsType(PhysicsType.Dynamic)
    self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)

    -- if Server then
    --     StartSoundEffectOnEntity(missile_flight_sound, self, 0.08)
    -- end

    self.time_created = Shared.GetTime()
    self.time_now = 0
    self.final_direction_vector = nil
    self.owner_entity_id = nil
    self.set_owner = false
    self.added_impulse = false

end

function Bullet:OnInitialized()

    ScriptActor.OnInitialized(self)

    if Server then
        self:SetModel(Bullet.kModelName)
    end
    
end

function Bullet:GetDeathIconIndex()
    return kDeathMessageIcon.Rifle
end

function Bullet:OnUpdate(deltaTime)

    PROFILE("Bullet:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)

    if not self.set_owner then

        if Server then

            self:SetOwner(Shared.GetEntity(self.owner_id))
            self.set_owner = true

        end

    else

        self:SetIsVisible(true)
        
        local trace = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() + speed * self.final_direction_vector, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
        if trace.fraction ~= 1 then

            if trace.entity then

                if trace.entity:GetTeamNumber() == kTeam2Index then

                    self:DoDamage(10, trace.entity, trace.entity:GetOrigin(), nil)

                end

            end
            
            if Server then
                
                DestroyEntity(self)

            end

        else


            self:SetOrigin(self:GetOrigin() + speed * self.final_direction_vector)
            

        end

    end

end

function Bullet:GetTeamType()
    return kMarineTeamType
end

function Bullet:GetMass()
    return 0.05
end

Shared.LinkClassToMap("Bullet", Bullet.kMapName, networkVars, true)
