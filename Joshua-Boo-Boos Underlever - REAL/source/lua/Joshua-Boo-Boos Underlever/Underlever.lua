
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/PointGiverMixin.lua")

class 'Underlever' (ClipWeapon)

Underlever.kMapName = "underlever"
Underlever.kModelName = PrecacheAsset("models/underlever/underlever_world.model")
local kViewModelName = PrecacheAsset("models/underlever/underlever_view.model")
local kAnimationGraph = PrecacheAsset("models/underlever/underlever_view.animation_graph")

local kRange = 250
local kSpread = Math.Radians(1)

local fire_sound = PrecacheAsset("sound/NS2.fev/marine/pistol/fire")

local networkVars =
{
}

AddMixinNetworkVars(LiveMixin, networkVars)

function Underlever:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LiveMixin)
	InitMixin(self, PointGiverMixin)

    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end
    
end

function Underlever:OnInitialized()    
    ClipWeapon.OnInitialized(self)   
    self:SetModel(Underlever.kModelName) 
end

function Underlever:OnPrimaryAttack(player)

    if not self.attacking then
        
        self.sprintAllowed = false
        self.primaryAttacking = true
        
    end

end

function Underlever:OnUpdateAnimationInput(modelMixin)

    PROFILE("Underlever:OnUpdateAnimationInput")

    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)

    -- if player and player:GetIsIdle() then
    --     local totalTime = math.round(Shared.GetTime() - idleTime)
    --     if totalTime >= animFrequency*3 then
    --         idleTime = Shared.GetTime()
    --     elseif totalTime >= animFrequency*2 and self:GetIdleAnimations(3) then
    --         modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(3))
    --     elseif totalTime >= animFrequency and self:GetIdleAnimations(2) then
    --         modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(2))
    --     elseif totalTime < animFrequency then
    --         modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(1))
    --     end
        
    -- else
    --     idleTime = Shared.GetTime()
    --     modelMixin:SetAnimationInput("idleName", "idle")
    -- end
    
    local activity = "none"
    
    if self.primaryAttacking then
        activity = "primary"
        -- Log("activity is primary")
    end

    modelMixin:SetAnimationInput("activity", activity)
    -- Log("setanimationinput activity = " .. activity)
    
end


function Underlever:FirePrimary(player)

    ClipWeapon.FirePrimary(self, player)    
    -- self:TriggerEffects("cannon_attack")
    
end

if Client then

    function Underlever:OnClientPrimaryAttackStart()
    
        local player = self:GetParent()
        
    end
    
end

function Underlever:UpdateViewModelPoseParameters(viewModel)   
end

function Underlever:GetAnimationGraphName()
    return kAnimationGraph
end

function Underlever:GetViewModelName()
    return kViewModelName
end

function Underlever:GetDeathIconIndex()
    return kDeathMessageIcon.Xenocide    
end

function Underlever:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function Underlever:GetPrimaryMinFireDelay()
    return 0.1    
end

function Underlever:GetClipSize()
    return 6
end

function Underlever:GetSpread()
    return kSpread
end

function Underlever:CalculateSpreadDirection(shootCoords, player)
    return CalculateSpread(shootCoords, self:GetSpread() * self:GetInaccuracyScalar(player), 0.1)
end

function Underlever:GetBulletDamage(target, endPoint)
    return 40
end

function Underlever:GetBulletSize()
    return 0.05
end

function Underlever:GetRange()
    return 100
end

function Underlever:GetWeight()
    return 0.16
end

function Underlever:GetPrimaryAttackRequiresPress()
    return true
end

function Underlever:GetPrimaryCanInterruptReload()
    return false
end

function Underlever:GetSecondaryCanInterruptReload()
    return false
end

function Underlever:GetHasSecondary(player)
    return false
end

function Underlever:GetCatalystSpeedBase()
    if self:GetIsReloading() and kCombatVersion then
		local player = self:GetParent()
		if player then
            return player:GotFastReload() and 2.5 or 1.5
        end
    else	
		return 1.5
	end
end

function Underlever:OnReload(player)

    if self:CanReload() then
		self.reloading = true
	
		-- if player and player:GetHasCatPackBoost()then
		-- 	self:TriggerEffects("reload_speed1")
		-- else
		-- 	self:TriggerEffects("reload_speed0")
		-- end
    end
end


function Underlever:OnProcessMove(input)
    ClipWeapon.OnProcessMove(self, input)
end

function Underlever:GetIsDroppable()
    return true
end

function Underlever:GetAmmoPackMapName()
    return RifleAmmo.kMapName
end

function Underlever:OverrideWeaponName()
    return "rifle"
end

function Underlever:ApplyBulletGameplayEffects(player, target, endPoint, direction, damage, surface, showTracer)

    -- if not(tostring(endPoint.x) == tostring((-1)^.5) or tostring(endPoint.y) == tostring((-1)^.5) or tostring(endPoint.z) == tostring((-1)^.5)) and Server then
    --     local surface = GetSurfaceFromEntity(target)
    --     local params = { surface = surface }
    --     params[kEffectHostCoords] = Coords.GetTranslation(endPoint)
    --     GetEffectManager():TriggerEffects("cannon_hit", params)
    -- end
    -- local hitEntities = GetEntitiesWithMixinWithinRange("Live", endPoint, kAoeRadius)
    
    --   --Fades' blink is interrupted by the cannon hit.
    --   --currently at 10% chance. to disrupt blink. ::TODO change magic numbers!!

    
    -- table.removevalue(hitEntities, target)
    
    -- -- reduced damage to yourself
    -- if (table.contains(hitEntities, player)) then
    --    table.removevalue(hitEntities, player)
    --    self:DoDamage(kCannonSelfDamage, player, endPoint, direction, surface, false, showTracer)
    -- end
    
    -- RadiusDamage(hitEntities, endPoint, kAoeRadius, kCannonAoeDamage, self)
    
    if HasMixin(target, "Fire") and not target:GetIsOnFire() then

        target:SetOnFire(player, self)

    end

end

function Underlever:OnTag(tagName)

    PROFILE("Underlever:OnTag")

    ClipWeapon.OnTag(self, tagName)

    local parent = self:GetParent()

    if self.clip > 0 then

        if tagName == "shoot" then
            Log("tagName = shoot")

            if Server then

                StartSoundEffectAtOrigin(fire_sound, parent:GetOrigin())

            end

            local trace = Shared.TraceRay(parent:GetEyePos(), parent:GetEyePos() + parent:GetViewAngles():GetCoords().zAxis * 100, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, parent))
            if trace.fraction ~= 1 then
                if trace.entity then
                    if trace.entity.GetTeamNumber then
                        if trace.entity:GetTeamNumber() == kTeam2Index then
                            self:DoDamage(30, trace.entity, trace.entity:GetOrigin(), nil)
                        end
                    end
                end
            end

            self.clip = self.clip - 1

        end

    elseif self.clip == 0 then

        if self.ammo > 0 then

            self.clip = self.clip + 1

            self.ammo = self.ammo - 1

        end

    end
    
end

if Client then    
    
    function Underlever:GetBarrelPoint()
    
        local player = self:GetParent()
        if player then
        
            local origin = player:GetEyePos()
            local viewCoords = player:GetViewCoords()
            
            return origin + viewCoords.zAxis * 0.4 + viewCoords.xAxis * -0.15 + viewCoords.yAxis * -0.10
            
        end
        
        return self:GetOrigin()
        
    end    
    
    -- function Cannon:GetUIDisplaySettings()
    --     return { xSize = 256, ySize = 500, script = "lua/Cannon/GUICannonDisplay.lua"}
    -- end
    
end

function Underlever:ModifyDamageTaken(damageTable, attacker, doer, damageType)

    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
    
end

function Underlever:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

-- function Underlever:GetTracerEffectName()
--     return kTracerCinematic
-- end

-- function Underlever:GetTracerResidueEffectName()
--     return kTracerResidueCinematic
-- end

-- function Underlever:GetTracerEffectFrequency()
--     return 1
-- end

if Server then

    function Underlever:OnKill()
        DestroyEntity(self)
    end
    
    function Underlever:GetSendDeathMessageOverride()
        return false
    end 
    
end


Shared.LinkClassToMap("Underlever", Underlever.kMapName, networkVars)