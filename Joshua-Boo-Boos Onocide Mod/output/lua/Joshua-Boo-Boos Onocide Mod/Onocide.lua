Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

kOnocideModActive = true

-- local kRange = 3.5
local kRange = 2.0

class 'Onocide' (Ability)

Onocide.kMapName = "onocide"

-- after kDetonateTime seconds the skulk goes 'boom!'
local kDetonateTime = 3.5 -- 2.0
local kXenocideSoundName = PrecacheAsset("sound/NS2.fev/alien/common/xenocide_start")
local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_view.animation_graph")

local networkVars = { }

AddMixinNetworkVars(StompMixin, networkVars)

local function CheckForDestroyedEffects(self)
    if self.XenocideSoundName and not IsValid(self.XenocideSoundName) then
        self.XenocideSoundName = nil
    end
end
    
local function TriggerXenocide(self, player)

    if Server then
        CheckForDestroyedEffects( self )
        
        if not self.XenocideSoundName then
            self.XenocideSoundName = Server.CreateEntity(SoundEffect.kMapName)
            self.XenocideSoundName:SetAsset(kXenocideSoundName)
            self.XenocideSoundName:SetParent(self)
            self.XenocideSoundName:Start()
        else     
            self.XenocideSoundName:Start()    
        end
        --StartSoundEffectOnEntity(kXenocideSoundName, player)
        self.xenocideTimeLeft = kDetonateTime
        
    elseif Client and Client.GetLocalPlayer() == player then

        if not self.xenocideGui then
            self.xenocideGui = GetGUIManager():CreateGUIScript("GUIXenocideFeedback")
        end
    
        self.xenocideGui:TriggerFlash(kDetonateTime)
        player:SetCameraShake(.01, 15, kDetonateTime)
        
    end
    
end

local function CleanUI(self)

    if self.xenocideGui ~= nil then
    
        GetGUIManager():DestroyGUIScript(self.xenocideGui)
        self.xenocideGui = nil
        
    end
    
end

function Onocide:OnCreate()

    Ability.OnCreate(self)

    InitMixin(self, StompMixin)

end
    
function Onocide:OnDestroy()

    Weapon.OnDestroy(self)
    
    if Client then
        CleanUI(self)
    end

end

function Onocide:GetAnimationGraphName()
    return kAnimationGraph
end

function Onocide:OnUpdateAnimationInput(modelMixin)

    local activityString = "none"
    local abilityString = "gore"
    
    modelMixin:SetAnimationInput("ability", abilityString)
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function Onocide:GetDeathIconIndex()
    return kDeathMessageIcon.None
end

function Onocide:GetEnergyCost()

    if not self.xenociding then
        return kXenocideEnergyCost
    else
        return Gore.GetEnergyCost(self)
    end
    
end

function Onocide:GetIsXenociding()
    return self.xenociding
end

function Onocide:GetHUDSlot()
    if kCombatVersion then
        return 4
    else
        return 3
    end
end

function Onocide:GetRange()
    return kRange
end

function Onocide:OnPrimaryAttack(player)

    if not self.xenociding then
    
        if player:GetEnergy() >= self:GetEnergyCost() then

            TriggerXenocide(self, player)
            self.xenociding = true
            player:SetActiveWeapon(Gore.kMapName)

        end

    elseif self.xenociding then

        if player:GetEnergy() >= Gore:GetEnergyCost() and self.xenocideTimeLeft and self.xenocideTimeLeft < kDetonateTime * 0.8 then

            Gore.OnPrimaryAttack(self, player)

        end
        
    end
    
end

local function StopXenocide(self)

    CleanUI(self)
    
    self.xenociding = false

end

function Onocide:OnProcessMove(input)

    Ability.OnProcessMove(self, input)

    local player = self:GetParent()
    if self.xenociding then

        if player:isa("Commander") then
            -- StopXenocide(self)
        elseif Server then

            CheckForDestroyedEffects( self )

            self.xenocideTimeLeft = math.max(self.xenocideTimeLeft - input.time, 0)

            if self.xenocideTimeLeft == 0 and player:GetIsAlive() then

                local xenoOrigin = player.GetEngagementPoint and player:GetEngagementPoint() or (player:GetOrigin() + Vector(0,0.5,0))

                player:TriggerEffects("xenocide", {effecthostcoords = Coords.GetTranslation(player:GetOrigin())})

                if kCombatVersion then

                    local hitEntities = GetEntitiesWithMixinWithinRange("Live", xenoOrigin, kXenocideRange)
                    table.removevalue(hitEntities, player)

                    -- RadiusDamage(hitEntities, xenoOrigin, kXenocideRange, 500, self)
                    RadiusDamage(hitEntities, xenoOrigin, kXenocideRange, kXenocideDamage, self)

                else

                    local hives = GetEntitiesForTeam("Hive", kTeam2Index)
                    local bio_num = 0
                    for i = 1, #hives do
                        bio_num = bio_num + hives[i].bioMassLevel
                    end

                    local hitEntities = GetEntitiesWithMixinWithinRange("Live", xenoOrigin, kXenocideRange * (bio_num / 8))
                    table.removevalue(hitEntities, player)

                    -- RadiusDamage(hitEntities, xenoOrigin, kXenocideRange, 400 * (1 + 0.25 * ((player:GetHealth() + player:GetArmor()) / (player:GetMaxHealth() + player:GetMaxArmor()))) * (1 + 0.1 * (math.max(bio_num, 8) - 8)), self) -- kXenocideDamage
                    RadiusDamage(hitEntities, xenoOrigin, kXenocideRange, kXenocideDamage + (50 * (bio_num - 8)), self)

                end

                player.spawnReductionTime = 4

                player:SetBypassRagdoll(true)

                player:Kill(player, self)

                if self.XenocideSoundName then
                    self.XenocideSoundName:Stop()
                    self.XenocideSoundName = nil
                end
            end
            if Server and not player:GetIsAlive() and self.XenocideSoundName and self.XenocideSoundName:GetIsPlaying() == true then
                self.XenocideSoundName:Stop()
                self.XenocideSoundName = nil
            end

        elseif Client and not player:GetIsAlive() and self.xenocideGui then
            CleanUI(self)
        end

    end

end

if Server then

    function Onocide:GetDamageType()
    
        if self.xenocideTimeLeft == 0 then
            return kXenocideDamageType
        else
            return kGoreDamageType
        end
        
    end
    
end

Shared.LinkClassToMap("Onocide", Onocide.kMapName, networkVars)