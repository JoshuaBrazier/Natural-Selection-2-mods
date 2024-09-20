Script.Load("lua/Joshua-Boo-Boos Spear Mod/Spear.lua")

local speed = 1.1
local kViewModels = PrecacheAsset("models/spear/spear_view.model")
local kAnimationGraph = PrecacheAsset("models/spear/spear_view.animation_graph")

local spear_slash_sound = PrecacheAsset("sound/Joshua-Boo-Boos Spear Mod.fev/Spear_Sounds/slash")
local spear_throw_sound = PrecacheAsset("sound/Joshua-Boo-Boos Spear Mod.fev/Spear_Sounds/throw")

local oldcreate = Axe.OnCreate

function Axe:OnCreate()

    oldcreate(self)

    self.drawing = false
    self.holstering = false
    self.can_primary_attack = true
    self.can_secondary_attack = true
    
end

function Axe:OnInitialized()

    Weapon.OnInitialized(self)
    
    self:SetModel(Spear.kModelName)
    
end

function Axe:GetIsDroppable()
    
    return false

end

-- function Axe:OnDraw(player, previousWeaponMapName)

--     Weapon.OnDraw(self, player, previousWeaponMapName)
    
--     -- Attach weapon to parent's hand
--     self:SetAttachPoint(Weapon.kHumanAttachPoint)

--     self.draw = true
    
--     idleTime = Shared.GetTime()
    
-- end

-- function Axe:OnHolster(player)

--     Weapon.OnHolster(self, player)

--     self.sheath = true
    
--     self.sprintAllowed = true
--     self.primaryAttacking = false
    
-- end

function Axe:GetViewModelName(sex, variant)
    return kViewModels
end

function Axe:GetAnimationGraphName()
    return kAnimationGraph
end

function Axe:GetHasSecondary(player)
    return true
end

--

function Axe:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)

    self.drawing = true
    
    -- Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
    -- idleTime = Shared.GetTime()
    
end

function Axe:OnHolster(player)

    Weapon.OnHolster(self, player)

    self.holstering = true
    
    self.sprintAllowed = true
    self.primaryAttacking = false
    
end

function Axe:OnPrimaryAttack(player)

    if not self.attacking then
        
        self.sprintAllowed = false
        self.primaryAttacking = true
        
    end

end


function Axe:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
    self.can_secondary_attack = true
    -- idleTime = Shared.GetTime()
end

function Axe:GetDamageType()
    return kDamageType.Normal
end

function Axe:OnTag(tagName)

    PROFILE("Axe:OnTag")

    if tagName == "draw" then

        self.can_primary_attack = true
        self.can_secondary_attack = true

        -- self.can_primary_attack = false
        -- self.can_secondary_attack = false

    -- elseif tagName == "draw_end" then

    --     self.can_primary_attack = true
    --     self.can_secondary_attack = true

    elseif tagName == "slash_start" then
        -- Log("tagname = slash_start")
        self.sprintAllowed = false
        self.can_primary_attack = false
        self.can_secondary_attack = false
        if Server then
            StartSoundEffectOnEntity(spear_slash_sound, self:GetParent(), 0.1)
        end
        local player = self:GetParent()
        local traceray = Shared.TraceCapsule(player:GetEyePos(), player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * 1.25, 0.25, 0.25, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterTwo(self, player))

        if traceray.fraction ~= 1 then
            if traceray.entity then
                if traceray.entity.GetTeamNumber then
                    if traceray.entity:GetTeamNumber() == kTeam2Index then
                        self:DoDamage(40, traceray.entity, traceray.entity:GetOrigin(), nil)
                    end
                end
            end
        end
        -- Log("attackmeleecapsule")
    elseif tagName == "slash_end" then
        -- Log("tagname = slash_end")
        self.sprintAllowed = true
        self.can_primary_attack = true
        self.can_secondary_attack = true
    elseif tagName == "throw_start" then
        self.sprintAllowed = false
    elseif tagName == "throw_end" then

    end
    
end

function Axe:OnUpdateAnimationInput(modelMixin)

    PROFILE("Axe:OnUpdateAnimationInput")
    
    local player = self:GetParent()
    
    local activity = "none"

    if self.drawing then
        activity = "draw"
        -- Log("activity is draw")
        self.drawing = false
    end

    if self.holstering then
        activity = "holster"
        -- Log("activity is holster")
        self.holstering = false
    end
    
    if player and player.GetIsSprinting and player:GetIsSprinting() then
        activity = "sprint"
        -- Log("activity is sprinting")
    end
    
    if self.primaryAttacking then
        activity = "primary"
        -- Log("activity is primary")
    end

    if self.secondaryAttacking then
        activity = "secondary"
        -- Log("activity is secondary")

    end

    modelMixin:SetAnimationInput("activity", activity)
    -- Log("setanimationinput activity = " .. activity)
    
end

function Axe:OnPrimaryAttack(player)

    if self.can_primary_attack then
        self.primaryAttacking = true
        self.can_primary_attack = false
    end
    
end

function Axe:DestroyViewModel()

    assert(self.viewModelId ~= Entity.invalidId)
    
    DestroyEntity(self:GetViewModelEntity())
    self.viewModelId = Entity.invalidId
    
end

function Axe:GetPrimaryAttackRequiresPress()
    
    return true

end

function Axe:GetSecondaryAttackRequiresPress()
    
    return true

end

function Axe:OnSecondaryAttack(player)
    
    if self.can_secondary_attack then
        self.secondaryAttacking = true
        self.can_secondary_attack = false
        if Server then

            StartSoundEffectOnEntity(spear_throw_sound, player, 0.1)

            local spear = CreateEntity(Spear.kMapName, player:GetEyePos(), player:GetTeamNumber()) -- - 0.3 * GetNormalizedVector(player:GetViewAngles():GetCoords().xAxis) + (-0.2) * GetNormalizedVector(player:GetViewAngles():GetCoords().yAxis) + 0.2 * GetNormalizedVector(player:GetViewAngles():GetCoords().zAxis), player:GetTeamNumber())
            spear.parent_id = player:GetId()
            spear.direction_vector = player:GetViewAngles():GetCoords().zAxis
            spear.speed = speed
            spear:SetOwner(player)
        end
        if Server then

            local parent = self:GetParent()
            parent:RemoveWeapon(self)

        end
    end
end