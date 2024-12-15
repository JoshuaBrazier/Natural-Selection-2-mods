-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Weapons\Marine\Minigun.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/BulletsMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/FilteredCinematicMixin.lua")

class 'Minigun' (Entity)

Minigun.kMapName = "minigun"

local railgun_fire_sound = PrecacheAsset("sound/NS2.fev/marine/heavy/railgun_fire")

local kSpinUpSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up_2"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_up") }

local kSpinDownSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_down") }

local kSpinSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin_2"),
                          [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/spin") }

local kSpinTailSoundNames = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail_2"),
                              [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("sound/NS2.fev/marine/heavy/tail") }
                              
local missile_launch_sound = PrecacheAsset("sound/NS2_Exo_Mod_Sounds.fev/Exo_Mod_Sounds/Missile_Launch")

--local kHeatUISoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/heat_UI")
local kOverheatedSoundName = PrecacheAsset("sound/NS2.fev/marine/heavy/overheated")

PrecacheAsset("shaders/ExoMinigunView.surface_shader")

local kOverheatEffect = PrecacheAsset("cinematics/marine/minigun/overheat.cinematic")

-- Trigger on the client based on the "shooting" variable below.
local kShellsCinematics = { [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("cinematics/marine/minigun/mm_left_shell.cinematic"),
                            [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("cinematics/marine/minigun/mm_shell.cinematic") }
local kShellsAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "Exosuit_LElbow",
                              [ExoWeaponHolder.kSlotNames.Right] = "Exosuit_RElbow" }

local kMinigunRange = 400
local kMinigunSpread = Math.Radians(5)
local kMinigunSiegeModeSpread = Math.Radians(1.4)

local fire_rate_multiplier = 10

local kBulletSize = 0.03

-- Minigun.ammo_left = 1000
-- Minigun.ammo_right = 1000
-- Minigun.ammo_siege_left = 200
-- Minigun.ammo_siege_right = 200

Minigun.kHeatUpRate = 0.3
Minigun.kCoolDownRate = 0.4

Minigun.kOverheatAnimationBaseLength = 1.1666666269302368 -- from the art asset.
Minigun.kOverheatDuration = 2.0 -- desired overheat length.
local kOverheatSpeed = Minigun.kOverheatAnimationBaseLength / Minigun.kOverheatDuration

-- Scale down the heat UI  so we avoid some aliasing artifacts.  Since the GUIView textures don't
-- generate miplevels, we need to be careful about how high we set the resolution of these things.
local heatUIScaleFactor = 0.25

local networkVars =
{
    minigunAttacking = "private boolean",
    shooting = "boolean",
    heatAmount = "float (0 to 1 by 0.01)",
    overheated = "private boolean",
    spinSoundId = "entityid",
    damage_multiplier = "float",
    -- l_i = "compensated integer",
    -- r_i = "compensated integer",
    --heatUISoundId = "private entityid"
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function Minigun:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)

    self.minigunAttacking = false
    self.shooting = false
    self.heatAmount = 0
    self.overheated = false
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
        InitMixin(self, FilteredCinematicMixin)
    end
    
    self.l_i = 0
    self.r_i = 0
    self.damage_multiplier = 1

end

function Minigun:OnInitialized()

    if Client then
    
        local attachPointName = kShellsAttachPoints[self:GetExoWeaponSlot()]
        local cinematicName = kShellsCinematics[self:GetExoWeaponSlot()]
        if attachPointName and cinematicName then
        
            self.shellsCinematic = Client.CreateCinematic(RenderScene.Zone_Default)
            self.shellsCinematic:SetCinematic(FilterCinematicName(cinematicName))
            self.shellsCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.shellsCinematic:SetParent(self:GetParent())
            self.shellsCinematic:SetCoords(Coords.GetIdentity())
            self.shellsCinematic:SetAttachPoint(self:GetParent():GetAttachPointIndex(attachPointName))
            self.shellsCinematic:SetIsActive(false)
            
        end
        
    end

    self.defenseMod = ModLoader.GetModInfo("defense")
    
end

function Minigun:OnDestroy()

    Entity.OnDestroy(self)
    
    if self.shellsCinematic then
    
        Client.DestroyCinematic(self.shellsCinematic)
        self.shellsCinematic = nil
        
    end
    
    if self.heatDisplayUI then
    
        Client.DestroyGUIView(self.heatDisplayUI)
        self.heatDisplayUI = nil
        
    end
    
end

function Minigun:GetIsThrusterAllowed()
    return true
end

function Minigun:OnWeaponSlotAssigned(slot)

    assert(Server)
    
    self.spinSound = Server.CreateEntity(SoundEffect.kMapName)
    self.spinSound:SetAsset(kSpinSoundNames[slot])
    self.spinSound:SetParent(self)
    self.spinSoundId = self.spinSound:GetId()
    
    --[[
    self.heatUISound = Server.CreateEntity(SoundEffect.kMapName)
    self.heatUISound:SetAsset(kHeatUISoundName)
    self.heatUISound:SetParent(self)
    self.heatUISound:Start()
    self.heatUISoundId = self.heatUISound:GetId()
    --]]
end

function Minigun:ConstrainMoveVelocity(moveVelocity)

    if self.minigunAttacking then
    
        moveVelocity.x = moveVelocity.x / 3
        moveVelocity.z = moveVelocity.z / 3
        
    end
    
end

function Minigun:OnPrimaryAttack(parent)
    self.minigunAttacking = true
end

function Minigun:OnPrimaryAttackEnd(parent)

    if self.minigunAttacking then
    
        if Server then
        
            if self.shooting then
                StartSoundEffectOnEntity(kSpinTailSoundNames[self:GetExoWeaponSlot()], self)
            end
            
            if self.spinSound:GetIsPlaying() then
                self.spinSound:Stop()
            end
            
        end
        
        self.shooting = false
        
    end
    
    self.minigunAttacking = false
    
end

function Minigun:GetBarrelPoint()

    local parent = self:GetParent()
    if parent then
    
        if parent.GetIsLocalPlayer and parent:GetIsLocalPlayer() then
        
            local origin = parent:GetEyePos()
            local viewCoords = parent:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
            end    
        
        else
    
            local origin = parent:GetEyePos()
            local viewCoords = parent:GetViewCoords()
            
            if self:GetIsLeftSlot() then
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * 0.35 + viewCoords.yAxis * -0.15
            else
                return origin + viewCoords.zAxis * 0.9 + viewCoords.xAxis * -0.35 + viewCoords.yAxis * -0.15
            end
            
        end    
        
    end
    
    return self:GetOrigin()
    
end

function Minigun:GetTracerEffectName()
    local exo_player = self:GetParent()
    if exo_player.siege_mode then
        return kRailgunTracerEffectName --kMinigunTracerEffectName
    else
        return kMinigunTracerEffectName
    end
end

function Minigun:GetTracerResidueEffectName()
    local exo_player = self:GetParent()
    if exo_player.siege_mode then
        return kRailgunTracerResidueEffectName
    end
end

function Minigun:GetTracerEffectFrequency()
    return 1
end

function Minigun:GetIsAffectedByWeaponUpgrades()
    return true
end 

function Minigun:GetDeathIconIndex()
    return kDeathMessageIcon.Minigun
end

function Minigun:GetWeight()
    return kMinigunWeight
end

local missile_count_siege_mode_defense = 3
-- local missile_count_siege_mode_combat = 2

-- TODO: we should use clip weapons provided functionality here (or create a more general solution which distincts between melee, hitscan and projectile only)!
local function Shoot(self, leftSide)

    local parent = self:GetParent()
    
    -- We can get a shoot tag even when the clip is empty if the frame rate is low
    -- and the animation loops before we have time to change the state.
    if self.minigunAttacking and not self.overheated and parent then

        if kWeapons4Enabled then

            -- if GetHasTech(parent, kTechId.Weapons3) or GetHasTech(parent, kTechId.Weapons4) then

                local viewAngles = parent:GetViewAngles()
                local shootCoords = viewAngles:GetCoords()
                local direction = shootCoords.zAxis
                local barrel_point = self:GetBarrelPoint()

                if parent.siege_mode then

                    if Server and ((leftSide and self.l_i % 5 * fire_rate_multiplier == 0) or (not leftSide and self.r_i % 5 * fire_rate_multiplier == 0)) then
                        if Server then
                            StartSoundEffectOnEntity(missile_launch_sound, self, 0.045)
                            
                            if leftSide then
                                if self.defenseMod then
                                    for i = 1, missile_count_siege_mode_defense do
                                        parent:AddTimedCallback(function(parent)
                                                                    local missile
                                                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (-1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                                                    missile.owner_exo = parent:GetId()
                                                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                                                    missile.initial_look_vector = missile.final_direction_vector
                                                                    missile.tracking_missile_damage = 25
                                                                end, i * 0.15)
                                    end
                                else
                                    local missile
                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (-1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                    missile.owner_exo = parent:GetId()
                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                    missile.initial_look_vector = missile.final_direction_vector
                                    missile.tracking_missile_damage = 20
                                end
                            elseif not leftSide then
                                if self.defenseMod then
                                    for i = 1, missile_count_siege_mode_defense do
                                        parent:AddTimedCallback(function(parent)
                                                                    local missile
                                                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                                                    missile.owner_exo = parent:GetId()
                                                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                                                    missile.initial_look_vector = missile.final_direction_vector
                                                                    missile.tracking_missile_damage = 25
                                                                end, i * 0.15)
                                    end
                                else
                                    local missile
                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                    missile.owner_exo = parent:GetId()
                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                    missile.initial_look_vector = missile.final_direction_vector
                                    missile.tracking_missile_damage = 20
                                end
                            end
                        end
                    end

                else

                    if Server and ((leftSide and self.l_i % (5 * fire_rate_multiplier) == 0) or (not leftSide and self.r_i % (5 * fire_rate_multiplier) == 0)) then
                        if Server then
                            local missile
                            StartSoundEffectOnEntity(missile_launch_sound, self, 0.045)
                            if leftSide then
                                missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (-1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                missile.owner_exo = parent:GetId()
                                missile.final_direction_vector = parent:GetViewCoords().zAxis
                                missile.initial_look_vector = missile.final_direction_vector
                            elseif not leftSide then
                                missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                missile.owner_exo = parent:GetId()
                                missile.final_direction_vector = parent:GetViewCoords().zAxis
                                missile.initial_look_vector = missile.final_direction_vector
                            end
                            missile.final_direction_vector = GetNormalizedVector(direction)
                        end
                    end

                end
                
            -- end

            if Server then
                if parent.siege_mode then
                    StartSoundEffectOnEntity(railgun_fire_sound, self, 0.75)
                else
                    StartSoundEffectOnEntity(railgun_fire_sound, self, 0.28)
                end
            end
        
            local viewAngles = parent:GetViewAngles()
            local shootCoords = viewAngles:GetCoords()
            
            -- Filter ourself out of the trace so that we don't hit ourselves.
            local filter = EntityFilterTwo(parent, self)
            local startPoint = parent:GetEyePos()
            
            local spreadDirection = CalculateSpread(shootCoords, kMinigunSpread, NetworkRandom)
            
            if parent.siege_mode then
    
                spreadDirection = CalculateSpread(shootCoords, kMinigunSiegeModeSpread, NetworkRandom)
    
            end
            
            local range = kMinigunRange
            
            local endPoint = startPoint + spreadDirection * range
            
            local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter) 
            
            local direction = (trace.endPoint - startPoint):GetUnit()
            local hitOffset = direction * kHitEffectOffset
            local impactPoint = trace.endPoint - hitOffset
            local surfaceName = trace.surface
            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = true --(math.random() < effectFrequency)
            
            local numTargets = #targets
            
            if numTargets == 0 then
                self:ApplyBulletGameplayEffects(parent, nil, impactPoint, direction, 0, trace.surface, showTracer, kBotAccWeaponGroup.ExoMinigun)
            end
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, trace.endPoint)
            end
            
            for i = 1, numTargets do
    
                local target = targets[i]
                local hitPoint = hitPoints[i]
    
                if parent.siege_mode then
                    self:ApplyBulletGameplayEffects(parent, target, hitPoint - hitOffset, direction, self.damage_multiplier * 4 * kMinigunDamage, "", showTracer and i == numTargets, kBotAccWeaponGroup.ExoMinigun)
                else
                    self:ApplyBulletGameplayEffects(parent, target, hitPoint - hitOffset, direction, self.damage_multiplier * kMinigunDamage, "", showTracer and i == numTargets, kBotAccWeaponGroup.ExoMinigun)
                end
                local client = Server and parent:GetClient() or Client
                if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                    RegisterHitEvent(parent, bullet, startPoint, trace, damage)
                end
            
            end
            
            self.shooting = true

        elseif not kWeapons4Enabled then

            -- if GetHasTech(parent, kTechId.Weapons3) then

                local viewAngles = parent:GetViewAngles()
                local shootCoords = viewAngles:GetCoords()
                local direction = shootCoords.zAxis
                local barrel_point = self:GetBarrelPoint()

                if parent.siege_mode then

                    if Server and ((leftSide and self.l_i % 5 * fire_rate_multiplier == 0) or (not leftSide and self.r_i % 5 * fire_rate_multiplier == 0)) then
                        if Server then
                            StartSoundEffectOnEntity(missile_launch_sound, self, 0.045)
                            
                            if leftSide then
                                if self.defenseMod then
                                    for i = 1, missile_count_siege_mode_defense do
                                        parent:AddTimedCallback(function(parent)
                                                                    local missile
                                                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (-1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                                                    missile.owner_exo = parent:GetId()
                                                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                                                    missile.initial_look_vector = missile.final_direction_vector
                                                                    missile.tracking_missile_damage = 25
                                                                end, i * 0.15)
                                    end
                                else
                                    local missile
                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (-1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                    missile.owner_exo = parent:GetId()
                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                    missile.initial_look_vector = missile.final_direction_vector
                                    missile.tracking_missile_damage = 25
                                end
                            elseif not leftSide then
                                if self.defenseMod then
                                    for i = 1, missile_count_siege_mode_defense do
                                        parent:AddTimedCallback(function(parent)
                                                                    local missile
                                                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                                                    missile.owner_exo = parent:GetId()
                                                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                                                    missile.initial_look_vector = missile.final_direction_vector
                                                                    missile.tracking_missile_damage = 25
                                                                end, i * 0.15)
                                    end
                                else
                                    local missile
                                    missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                    missile.owner_exo = parent:GetId()
                                    missile.final_direction_vector = parent:GetViewCoords().zAxis
                                    missile.initial_look_vector = missile.final_direction_vector
                                    missile.tracking_missile_damage = 25
                                end
                            end
                        end
                    end

                else

                    if Server and ((leftSide and self.l_i % (5 * fire_rate_multiplier) == 0) or (not leftSide and self.r_i % (5 * fire_rate_multiplier) == 0)) then
                        if Server then
                            local missile
                            StartSoundEffectOnEntity(missile_launch_sound, self, 0.045)
                            if leftSide then
                                missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (-1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                missile.owner_exo = parent:GetId()
                                missile.final_direction_vector = parent:GetViewCoords().zAxis
                                missile.initial_look_vector = missile.final_direction_vector
                                missile.tracking_missile_damage = 20
                            elseif not leftSide then
                                missile = CreateEntity(Exo_Missile.kMapName, barrel_point + (1) * GetNormalizedVector(parent:GetViewAngles():GetCoords().xAxis) + Vector(0, 0.4, 0) + (-0.21) * GetNormalizedVector(parent:GetViewAngles():GetCoords().zAxis), kTeam1Index)
                                missile.owner_exo = parent:GetId()
                                missile.final_direction_vector = parent:GetViewCoords().zAxis
                                missile.initial_look_vector = missile.final_direction_vector
                                missile.tracking_missile_damage = 20
                            end
                            missile.final_direction_vector = GetNormalizedVector(direction)
                        end
                    end

                end
                
            -- end

            if Server then
                if parent.siege_mode then
                    StartSoundEffectOnEntity(railgun_fire_sound, self, 0.75)
                else
                    StartSoundEffectOnEntity(railgun_fire_sound, self, 0.28)
                end
            end
        
            local viewAngles = parent:GetViewAngles()
            local shootCoords = viewAngles:GetCoords()
            
            -- Filter ourself out of the trace so that we don't hit ourselves.
            local filter = EntityFilterTwo(parent, self)
            local startPoint = parent:GetEyePos()
            
            local spreadDirection = CalculateSpread(shootCoords, kMinigunSpread, NetworkRandom)
            
            if parent.siege_mode then
    
                spreadDirection = CalculateSpread(shootCoords, kMinigunSiegeModeSpread, NetworkRandom)
    
            end
            
            local range = kMinigunRange
            
            local endPoint = startPoint + spreadDirection * range
            
            local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, kBulletSize, filter) 
            
            local direction = (trace.endPoint - startPoint):GetUnit()
            local hitOffset = direction * kHitEffectOffset
            local impactPoint = trace.endPoint - hitOffset
            local surfaceName = trace.surface
            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = true --(math.random() < effectFrequency)
            
            local numTargets = #targets
            
            if numTargets == 0 then
                self:ApplyBulletGameplayEffects(parent, nil, impactPoint, direction, 0, trace.surface, showTracer, kBotAccWeaponGroup.ExoMinigun)
            end
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, trace.endPoint)
            end
            
            for i = 1, numTargets do
    
                local target = targets[i]
                local hitPoint = hitPoints[i]
    
                if parent.siege_mode then
                    self:ApplyBulletGameplayEffects(parent, target, hitPoint - hitOffset, direction, self.damage_multiplier * 1.85 * kMinigunDamage, "", showTracer and i == numTargets, kBotAccWeaponGroup.ExoMinigun)
                else
                    self:ApplyBulletGameplayEffects(parent, target, hitPoint - hitOffset, direction, self.damage_multiplier * kMinigunDamage, "", showTracer and i == numTargets, kBotAccWeaponGroup.ExoMinigun)
                end
                local client = Server and parent:GetClient() or Client
                if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                    RegisterHitEvent(parent, bullet, startPoint, trace, damage)
                end
            
            end
            
            self.shooting = true

        end

    end
    
end

local function UpdateOverheated(self, parent)

    if not self.overheated and self.heatAmount == 1 then
    
        self.overheated = true
        self:OnPrimaryAttackEnd(parent)
        
        if self:GetIsLeftSlot() then
            parent:TriggerEffects("minigun_overheated_left")
        elseif self:GetIsRightSlot() then    
            parent:TriggerEffects("minigun_overheated_right")
        end    
        
        StartSoundEffectForPlayer(kOverheatedSoundName, parent)
        
    end
    
end

function Minigun:AddHeat(amount)
    self.heatAmount = self.heatAmount + amount
end

function Minigun:ProcessMoveOnWeapon(parent, input)

    local dt = input.time
    local addAmount = self.shooting and (dt * Minigun.kHeatUpRate) or -(dt * Minigun.kCoolDownRate)
    self.heatAmount = math.min(1, math.max(0, self.heatAmount + addAmount))
    
    UpdateOverheated(self, parent)  
    
    if Client and not Shared.GetIsRunningPrediction() then
    
        local spinSound = Shared.GetEntity(self.spinSoundId)
        spinSound:SetParameter("heat", self.heatAmount, 1)
        
        --[[
        if parent:GetIsLocalPlayer() then
        
            local heatUISound = Shared.GetEntity(self.heatUISoundId)
            if heatUISound then
                heatUISound:SetParameter("heat", self.heatAmount, 1)
            end
            
        end
        --]]
    end
    
end

function Minigun:OnUpdateRender()

    PROFILE("Minigun:OnUpdateRender")

    local parent = self:GetParent()
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            viewModel:GetRenderModel():SetMaterialParameter("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
            
        end
        
        local heatDisplayUI = self.heatDisplayUI
        if not heatDisplayUI then
        
            heatDisplayUI = Client.CreateGUIView(242 * heatUIScaleFactor, 720 * heatUIScaleFactor)
            
            heatDisplayUI:Load("lua/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "MinigunDisplay.lua")
            heatDisplayUI:SetTargetTexture("*exo_minigun_" .. self:GetExoWeaponSlotName())
            self.heatDisplayUI = heatDisplayUI
            heatDisplayUI:SetGlobal("scaleFactor", heatUIScaleFactor)
        end
        
        heatDisplayUI:SetGlobal("heatAmount" .. self:GetExoWeaponSlotName(), self.heatAmount)
        
    else
    
        if self.heatDisplayUI then
        
            Client.DestroyGUIView(self.heatDisplayUI)
            self.heatDisplayUI = nil
            
        end
        
    end
    
    if self.shellsCinematic then
        self.shellsCinematic:SetIsActive(self.shooting)
    end
    
end

if Server then

    function Minigun:OnParentKilled(attacker, doer, point, direction)
    
        self.spinSound:Stop()
        --self.heatUISound:Stop()
        self.shooting = false
        
    end
    
end

function Minigun:OnTag(tagName)
    
    PROFILE("Minigun:OnTag")

    local parent = self:GetParent()

    if parent.siege_mode then

        self.damage_multiplier = 1.1

    else

        self.damage_multiplier = 1

    end

    if self:GetIsLeftSlot() and tagName == "l_shoot" then

        if parent.siege_mode then

            if self.l_i % 4 == 0 then
        
        -- if Minigun.ammo_left > 0 then
                Shoot(self, true)
            -- Minigun.ammo_left = Minigun.ammo_left - 1
        -- end
                
            end
        
        else

            Shoot(self, true)

        end

        self.l_i = self.l_i + 1
        
    elseif not self:GetIsLeftSlot() and tagName == "r_shoot" then

        if parent.siege_mode then

            if self.r_i % 4 == 0 then
        
        -- if Minigun.ammo_right > 0 then
                Shoot(self, false)
            -- Minigun.ammo_right = Minigun.ammo_right - 1
        -- end
                
            end
        
        else

            Shoot(self, false)

        end
        
        self.r_i = self.r_i + 1

    end
    
    -- Play spin-up sound.
    if Server then
        if self:GetIsLeftSlot() and tagName == "left_minigun_attack_start" then
            StartSoundEffectOnEntity(kSpinUpSoundNames[ExoWeaponHolder.kSlotNames.Left], self)
        elseif self:GetIsRightSlot() and tagName == "right_minigun_attack_start" then
            StartSoundEffectOnEntity(kSpinUpSoundNames[ExoWeaponHolder.kSlotNames.Right], self)
        end
    end
    
    -- Play spin-down sound.
    if Server then
        if self:GetIsLeftSlot() and tagName == "left_minigun_attack_end" then
            -- if not self.defenseMod then
            --     self.l_i = 0
            -- end
            StartSoundEffectOnEntity(kSpinDownSoundNames[ExoWeaponHolder.kSlotNames.Left], self)
        elseif self:GetIsRightSlot() and tagName == "right_minigun_attack_end" then
            -- if not self.defenseMod then
            --     self.r_i = 0
            -- end
            StartSoundEffectOnEntity(kSpinDownSoundNames[ExoWeaponHolder.kSlotNames.Right], self)
        end
    end
    
    -- Stop being overheated when the animation finishes.
    if Server then
        if self:GetIsLeftSlot() and tagName == "left_overheat_end" or
           self:GetIsRightSlot() and tagName == "right_overheat_end" then
            
            self.overheated = false
        end
    end

end

function Minigun:OnUpdateAnimationInput(modelMixin)

    local activity = "none"
    if self.overheated then
        -- Trigger the overheat animation, but only once so we don't accidentally play it twice in a row.
        activity = "overheat"
    elseif self.minigunAttacking --[=[and not self.overheated--]=] then
        activity = "primary"
    end
    
    modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)
    
    -- TODO calculate this once, and hard-code it in.  Updated every frame for now so balance team
    -- can make adjustments on-the-fly.
    modelMixin:SetAnimationInput("overheat_speed", kOverheatSpeed)
    
end

if Client then

    local kMinigunMuzzleEffectRate = 0.15
    local kAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_l_minigun_muzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_r_minigun_muzzle" }
    -- local kMuzzleEffectName =  { 
    --     [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("cinematics/marine/railgun/muzzle_flash.cinematic"), 
    --     [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("cinematics/marine/railgun/muzzle_flash.cinematic")
    -- }

    local kMuzzleEffectName =  { 
        [ExoWeaponHolder.kSlotNames.Left] = PrecacheAsset("cinematics/marine/minigun/muzzle_flash_left.cinematic"), 
        [ExoWeaponHolder.kSlotNames.Right] = PrecacheAsset("cinematics/marine/minigun/muzzle_flash.cinematic") 
    }

    function Minigun:GetIsActive()
        return true
    end
    
    function Minigun:GetPrimaryEffectRate()
        return kMinigunMuzzleEffectRate
    end
    
    function Minigun:GetPrimaryAttacking()
        return self.shooting
    end
    
    function Minigun:GetSecondaryAttacking()
        return false
    end
    
    function Minigun:OnClientPrimaryAttacking()
    
        local parent = self:GetParent()
        
        if parent then
            CreateMuzzleCinematic(self, 
                kMuzzleEffectName[self:GetExoWeaponSlot()], 
                kMuzzleEffectName[self:GetExoWeaponSlot()], 
                kAttachPoints[self:GetExoWeaponSlot()], 
                parent, nil, true)
        end
    
    end

    function Minigun:OnFilteredCinematicOptionChanged()
        local cinematicName = kShellsCinematics[self:GetExoWeaponSlot()]
        if cinematicName and self.shellsCinematic then
            self.shellsCinematic:SetCinematic(FilterCinematicName(cinematicName))
        end
    end
    
end

Shared.LinkClassToMap("Minigun", Minigun.kMapName, networkVars)