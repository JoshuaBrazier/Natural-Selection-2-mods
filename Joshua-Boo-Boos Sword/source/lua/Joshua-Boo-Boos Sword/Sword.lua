
Script.Load("lua/Weapons/Weapon.lua")

class 'Sword' (Weapon)

Sword.kMapName = "sword"

Sword.kModelName = PrecacheAsset("models/marine/sword/sword.model")

local kViewModels = PrecacheAsset("models/marine/sword/sword_view.model")
local kAnimationGraph = PrecacheAsset("models/marine/sword/sword_view.animation_graph")

local networkVars =
{
    sprintAllowed = "boolean",
}

function Sword:OnCreate()

    Weapon.OnCreate(self)
    
    self.sprintAllowed = true
    
end

function Sword:OnInitialized()

    Weapon.OnInitialized(self)
    
    self:SetModel(Sword.kModelName)
    
end

function Sword:GetViewModelName()
    return kViewModels
end

function Sword:GetAnimationGraphName()
    return kAnimationGraph
end

function Sword:OverrideWeaponName()
    return "axe"
end

function Sword:GetHUDSlot()
    return kTertiaryWeaponSlot
end

function Sword:UpdateViewModelPoseParameters(viewModel)

    -- viewModel:SetPoseParam("swing_pitch", 0)
    -- viewModel:SetPoseParam("swing_yaw", 0)
    -- viewModel:SetPoseParam("arm_loop", 0)
    
end

function Sword:GetRange()
    return 5 -- kRange
end

function Sword:GetShowDamageIndicator()
    return true
end

function Sword:GetSprintAllowed()
    return self.sprintAllowed
end

function Sword:GetDeathIconIndex()
    return kDeathMessageIcon.Axe
end

function Sword:GetIsAffectedByWeaponUpgrades()
    return true
end

function Sword:GetIdleAnimations(index)
    -- local animations = {"idle", "idle_toss", "idle_toss"}
    -- return animations[index]
end

function Sword:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)

    self.drawing = true
    
    -- Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
    -- idleTime = Shared.GetTime()
    
end

function Sword:OnHolster(player)

    Weapon.OnHolster(self, player)

    self.holstering = true
    
    self.sprintAllowed = true
    self.primaryAttacking = false
    
end

function Sword:OnPrimaryAttack(player)

    if not self.attacking then
        
        self.sprintAllowed = false
        self.primaryAttacking = true
        
    end

end


function Sword:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
    -- idleTime = Shared.GetTime()
end

function Sword:GetIsDroppable()
    return true
end

function Sword:OnTag(tagName)

    PROFILE("Sword:OnTag")

    -- if tagName == "swipe_sound" then
    
    --     local player = self:GetParent()
    --     if player then
    --         player:TriggerEffects("katana_swing")
    --     end
        
    -- elseif tagName == "hit" then
    
    --     local player = self:GetParent()
    --     if player then
	-- 		AttackMeleeCapsule(self, player, 40, 2)
    --     end
        
    -- elseif tagName == "attack_end" then
    --     self.sprintAllowed = true
    -- elseif tagName == "deploy_end" then
    --     self.sprintAllowed = true
    -- elseif tagName == "idle_toss_start" then
    --     self:TriggerEffects("Sword_idle_toss")
    -- elseif tagName == "idle_fiddle_start" then
    --     self:TriggerEffects("Sword_idle_fiddle")
    -- end

    if tagName == "slash_start" then
        Log("tagname = slash_start")
        self.sprintAllowed = false
        local player = self:GetParent()
        if player then
			AttackMeleeCapsule(self, player, 40, 2)
        end
    elseif tagName == "slash_end" then
        Log("tagname = slash_end")
        self.sprintAllowed = true
    end
    
end

function Sword:OnUpdateAnimationInput(modelMixin)

    PROFILE("Sword:OnUpdateAnimationInput")
    
    local player = self:GetParent()

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
    
    local activity = "idle"

    if self.drawing then
        activity = "draw"
        self.drawing = false
    end

    if self.holstering then
        activity = "sheath"
        self.holstering = false
    end
    
    if player:GetIsSprinting() then
        activity = "sprint"
        Log("activity is sprinting")
    end
    
    if self.primaryAttacking then
        activity = "slash"
        Log("activity is slashing")
    end

    modelMixin:SetAnimationInput("activity", activity)
    Log("setanimationinput activity = " .. activity)
    
end

Shared.LinkClassToMap("Sword", Sword.kMapName, networkVars)