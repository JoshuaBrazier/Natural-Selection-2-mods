Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/BaseModelMixin.lua")
Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

if Server then
    Script.Load("lua/OwnerMixin.lua")
end

class 'Spear' (ScriptActor)

Spear.kMapName = "Spear"
Spear.kModelName = PrecacheAsset("models/spear/spear_world.model")

local networkVars = {armor = "float", parent_id = "entityid", health = "float", alive = "boolean", direction_vector = "vector", speed = "float"}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)

if Server then
    AddMixinNetworkVars(OwnerMixin, networkVars)
end

local function compare(a,b)
    return a[1] < b[1]
end

local damage_value = 100

function Spear:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin, { kTriggeringEnabledDefault = true })
    InitMixin(self, ClientModelMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, EntityChangeMixin)

    if Server then
        InitMixin(self, OwnerMixin)
    end
    
    self:SetLagCompensated(true)
    self:SetUpdates(true, kRealTimeUpdateRate)

    self.alive = true

    self.parent = nil
    self.speed = nil

    self.set_model_and_physics = false

    self:SetMaxHealth(60)
    self:SetHealth(60)
    self:SetMaxArmor(0)
    self:SetArmor(0)

end

function Spear:OverrideWeaponName()
    return "axe"
end

function Spear:OnInitialized()

    ScriptActor.OnInitialized(self)
    
end

function Spear:OnUse(player, elapsedTime, useSuccessTable)

    local success = false
    if player:isa("Marine") then
        local w = 0
        local weapons = player:GetWeapons()
        for i = 1, #weapons do
            if weapons[i]:isa("Axe") or weapons[i]:isa("Welder") then
                w = w + 1
                break
            end
        end
        if w == 0 then
            if Server then
                player:GiveItem(Axe.kMapName)
                DestroyEntity(self)
            end
            success = true
        end

    end
    
    useSuccessTable.useSuccess = useSuccessTable.useSuccess or success
    
end

function Spear:GetIsAlive()
    return self.health > 0
end

function Spear:OnDestroy()

    ScriptActor.OnDestroy(self)

end

function Spear:OnUpdate(deltaTime)

    PROFILE("Spear:OnUpdate")
    
    ScriptActor.OnUpdate(self, deltaTime)

    if self.health <= 0 then

        if Server then

            DestroyEntity(self)

        end
    
    end

    if self.parent_id then

        if self.direction_vector then

            if not self.set_model_and_physics then

                if Server then
                    self:SetModel(Spear.kModelName)
                end
                self:SetPhysicsType(PhysicsType.Kinematic)

                self.set_model_and_physics = true

            end

            if Server then
                SetAnglesFromVector(self, self.direction_vector)
            end

            if not self.hit_something then

                local traceray = Shared.TraceRay(self:GetOrigin(), self:GetOrigin() + self.direction_vector * self.speed, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, Shared.GetEntity(self.parent_id)))

                if traceray.fraction ~= 1 then

                    self.hit_something = true

                    if traceray.entity then

                        if traceray.entity.GetTeamNumber then

                            if traceray.entity:GetTeamNumber() == kTeam2Index then

                                self:DoDamage(damage_value, traceray.entity, traceray.entity:GetOrigin(), nil)

                            end

                            if Server then

                                DestroyEntity(self)
            
                            end

                        end

                    end

                else

                    self:SetOrigin(self:GetOrigin() + self.direction_vector * self.speed)

                end

            end

        end

    end

end

function Spear:GetTeamType()
    return kMarineTeamType
end

function Spear:GetTeamNumber()
    return kTeam1Index
end

Shared.LinkClassToMap("Spear", Spear.kMapName, networkVars, true)
