-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\BoneWall.lua
--
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/MapBlipMixin.lua")

class 'BoneWall' (CommanderAbility)

BoneWall.kMapName = "bonewall"

BoneWall.kModelName = PrecacheAsset("models/alien/infestationspike/infestationspike.model")
local kAnimationGraph = PrecacheAsset("models/alien/infestationspike/infestationspike.animation_graph")

local kCommanderAbilityType = CommanderAbility.kType.OverTime
local kLifeSpan = 6

local kMoveOffset = 4
local kMoveDuration = 0.4

local bio_num_required_for_spores_and_umbra = 1
local max_bonewall_count = 4
local bonewall_per_this_number_of_on_ground_and_infestation_and_alive_marines = 3
local can_create_spores = true
local can_create_umbra = true

local networkVars =
{
    spawnPoint = "vector",
    comm_entity_id = "entityid"
}

local function GetCommander(teamNum)
    local commanders = GetEntitiesForTeam("Commander", teamNum)
    return commanders[1]
end

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)

function AlignBoneWalls(coords)

    local nearbyMarines = GetEntitiesWithinRange("Marine", coords.origin, 20)
    Shared.SortEntitiesByDistance(coords.origin, nearbyMarines)

    for _, marine in ipairs(nearbyMarines) do
    
        if marine:GetIsAlive() and marine:GetIsVisible() then

            local newZAxis = GetNormalizedVectorXZ(marine:GetOrigin() - coords.origin)
            local newXAxis = coords.yAxis:CrossProduct(newZAxis)
            coords.zAxis = newZAxis
            coords.xAxis = newXAxis
            break
        
        end
    
    end
    
    return coords

end


function BoneWall:GetDestroyOnKill()
    return true
end

function BoneWall:OnKill(attacker, doer, point, direction)

    if Server then

        local nearby_marines = GetEntitiesForTeamWithinRange("Marine", kTeam1Index, self:GetOrigin(), 3)

        for i = 1, #nearby_marines do
            nearby_marines[i]:SetPoisoned(Shared.GetEntity(self.comm_entity_id))
        end

    end

    self:TriggerEffects("death")

end

function BoneWall:OnCreate()

    CommanderAbility.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, ObstacleMixin)
    
    if Server then
        InitMixin(self, MapBlipMixin)
    end

    self.comm_entity_id = GetCommander(kTeam2Index):GetId()
    
end

function BoneWall:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    self.spawnPoint = self:GetOrigin()
    self:SetModel(BoneWall.kModelName, kAnimationGraph)
    
    if Server then
        self:TriggerEffects("bone_wall_burst")
        
        -- local team = self:GetTeam()
        -- if team then
        --     local level = math.max(0, team:GetBioMassLevel() - 1)
        --     local newMaxHealth = kBoneWallHealth + level * kBoneWallHealthPerBioMass
        --     if newMaxHealth ~= self.maxHealth  then
        --         self:SetMaxHealth(newMaxHealth)
        --         self:SetHealth(self.maxHealth)
        --     end
        -- end

        local hives = GetEntitiesForTeam("Hive", kTeam2Index)
        local bio_num = 0
        for i = 1, #hives do
            bio_num = bio_num + hives[i].bioMassLevel
        end

        local techtree = GetTechTree(kTeam2Index)

        if techtree then
            if bio_num >= bio_num_required_for_spores_and_umbra then
                if techtree:GetHasTech(kTechId.Spores) and can_create_spores then
                    local spores = CreateEntity( SporeCloud.kMapName, self:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                    spores:SetTravelDestination( self:GetOrigin() + Vector(0, 2, 0) )
                    spores:SetOwner(Shared.GetEntity(self.comm_entity_id))
                end
                if techtree:GetHasTech(kTechId.Umbra) and can_create_umbra then
                    local umbraCloud = CreateEntity( CragUmbra.kMapName, self:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                    umbraCloud:SetTravelDestination( self:GetOrigin() + Vector(0, 2, 0) )
                end
            end
        end

        local bonewalls = GetEntitiesForTeam("BoneWall", kTeam2Index)

        if #bonewalls == 1 then

            local bonewall_count = 1

            local marines = GetEntitiesForTeamWithinRange("Player", kTeam1Index, self:GetOrigin(), 8)

            local alive_marines = {}

            for i = 1, #marines do

                if marines[i]:GetIsAlive() then

                    table.insert(alive_marines, marines[i])
                
                end

            end

            local on_ground_and_infestation_and_alive_marines = {}

            for i = 1, #alive_marines do

                -- if alive_marines[i]:GetIsOnGround() == true and alive_marines[i]:GetGameEffectMask(kGameEffect.OnInfestation) == true then
                if alive_marines[i]:GetIsOnGround() == true then


                    table.insert(on_ground_and_infestation_and_alive_marines, alive_marines[i])

                end

            end

            for i = 1, #on_ground_and_infestation_and_alive_marines do

                if bonewall_count < max_bonewall_count and (i-1) % bonewall_per_this_number_of_on_ground_and_infestation_and_alive_marines == 0 then

                    CreateEntity(BoneWall.kMapName, on_ground_and_infestation_and_alive_marines[i]:GetOrigin(), kTeam2Index)
                    bonewall_count = bonewall_count + 1

                    if techtree then
                        if bio_num >= bio_num_required_for_spores_and_umbra then
                            if techtree:GetHasTech(kTechId.Spores) and can_create_spores then
                                local spores = CreateEntity( SporeCloud.kMapName, on_ground_and_infestation_and_alive_marines[i]:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                                spores:SetTravelDestination( self:GetOrigin() + Vector(0, 2, 0) )
                                spores:SetOwner(Shared.GetEntity(self.comm_entity_id))
                            end
                            if techtree:GetHasTech(kTechId.Umbra) and can_create_umbra then
                                local umbraCloud = CreateEntity( CragUmbra.kMapName, on_ground_and_infestation_and_alive_marines[i]:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                                umbraCloud:SetTravelDestination( self:GetOrigin() + Vector(0, 2, 0) )
                            end
                        end
                    end

                end

            end

        end

        self:SetMaxHealth(250 + ((bio_num - 3) * 50))
        self:SetHealth(250 + ((bio_num - 3) * 50))

    end
    
    -- Make the structure kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)

end

function BoneWall:GetSurfaceOverride()
    return "infestation"
end    

function BoneWall:GetType()
    return kCommanderAbilityType
end

function BoneWall:GetResetsPathing()
    return true
end

function BoneWall:GetLifeSpan()
    return kLifeSpan
end

function BoneWall:OnUpdate(deltaTime)

    CommanderAbility.OnUpdate(self, deltaTime)
    
    local lifeTime = math.max(0, Shared.GetTime() - self:GetTimeCreated())
    local remainingTime = self:GetLifeSpan() - lifeTime
    
    if remainingTime < self:GetLifeSpan() then
        
        local moveFraction = 0

        if remainingTime <= 1 then
            moveFraction = 1 - Clamp(remainingTime / kMoveDuration, 0, 1)
        end
        
        local piFraction = moveFraction * (math.pi / 2)

        self:SetOrigin(self.spawnPoint - Vector(0, math.sin(piFraction) * kMoveOffset, 0))
    
    end

end

function BoneWall:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function BoneWall:GetIsFlameAble()
    return true
end

function BoneWall:GetReceivesStructuralDamage()
    return true
end

Shared.LinkClassToMap("BoneWall", BoneWall.kMapName, networkVars)
