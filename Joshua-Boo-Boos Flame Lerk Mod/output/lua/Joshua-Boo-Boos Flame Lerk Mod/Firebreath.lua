Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/DamageMixin.lua")

kFirebreathModActive = true

local kRange = 4

class 'Firebreath' (Ability)

Firebreath.kMapName = "firebreath"

local networkVars = { time = "time" }

firstpersoncins = {
    
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic"),
    PrecacheAsset("cinematics/marine/flamethrower/flame_trail_1p_part1.cinematic")

}

AddMixinNetworkVars(DamageMixin, networkVars)

function Firebreath:OnCreate()

    InitMixin(self, DamageMixin)

    Ability.OnCreate(self)

    self.time = 0
    self.trailCinematic_left = nil
    self.trailCinematic_right = nil

end
    
function Firebreath:OnDestroy()

    Weapon.OnDestroy(self)

    if Client then

        if self.trailCinematic_left or self.trailCinematic_right then

            Client.DestroyTrailCinematic(self.trailCinematic_left)
            Client.DestroyTrailCinematic(self.trailCinematic_right)

        end

    end

end

-- sets the options for the trail:
-- **************************************************************************************************************************************************************************
-- optionTable.numSegments              "integer"           number of segments in the trail
-- optionTable.collidesWithWorld        "boolean"           cinematics will stack up at the end if the trail collides with the world
-- optionTable.alignAngles              "boolean"           cinematics will align angles
-- optionTable.visibilityChangeDuration "float"             time it takes to change visibility of the trail (starts at first segment)
-- optionTable.fadeOutCinematics        "boolean"           if fade out is true, cinematics will be recreated everytime visiblity changes to true or to false then set them to Repeat_None and reject handle
-- optionTable.trailLength              "float"             total length of the trail
-- optionTable.stretchTrail             "boolean"           the trail will exceed the total length and stretches
-- optionTable.trailWeight              "float"             weight of the trail. Segments closer to the end will have more weight applied to them (Y values reduced
-- optionTable.maxLength           "float"
--
-- following 3 options control the bending of the trail. minHardening is applied to the last segment (higher values will make the trail stiff) and is interpolated
-- to maxHardening for the first segments. hardeningModifier is multiplied with the result
-- optionTable.hardeningModifier        "float"
-- optionTable.minHardening             "float"
-- optionTable.maxHardening             "float"
-- **************************************************************************************************************************************************************************

-- attach_point = "fxnode_hole_left"

function Firebreath:InitTrailCinematic()

    local player = Client.GetLocalPlayer()

    self.trailCinematic_left = Client.CreateTrailCinematic(RenderScene.Zone_Default)
    self.trailCinematic_left:SetCinematicNames(firstpersoncins)
    
        -- attach to third person fx node otherwise with an X offset since we align it along the X-Axis (the attackpoint is oriented in the model like that)
    self.trailCinematic_left:AttachTo(player, TRAIL_ALIGN_X,  Vector(0.3, 0, 0), "fxnode_hole_left")
    minHardeningValue = 5.25
    maxHardeningValue = 0.1
    numFlameSegments = #firstpersoncins

    self.trailCinematic_left:SetIsVisible(true)
    self.trailCinematic_left:SetRepeatStyle(Cinematic.Repeat_Endless)
    self.trailCinematic_left:SetOptions( {
            numSegments = numFlameSegments,
            collidesWithWorld = true,
            visibilityChangeDuration = 0,
            fadeOutCinematics = false,
            stretchTrail = true,
            trailLength = 2 * kRange,
            minHardening = 100,
            maxHardening = 100,
            hardeningModifier = 5,
            trailWeight = 0.04,
            maxLength = 1.1 * kRange
        } )

    self.trailCinematic_right = Client.CreateTrailCinematic(RenderScene.Zone_Default)
    self.trailCinematic_right:SetCinematicNames(firstpersoncins)
    
        -- attach to third person fx node otherwise with an X offset since we align it along the X-Axis (the attackpoint is oriented in the model like that)
    self.trailCinematic_right:AttachTo(player, TRAIL_ALIGN_X,  Vector(0.3, 0, 0), "fxnode_hole_right")
    minHardeningValue = 5.25
    maxHardeningValue = 0.1
    numFlameSegments = #firstpersoncins

    self.trailCinematic_right:SetIsVisible(true)
    self.trailCinematic_right:SetRepeatStyle(Cinematic.Repeat_Endless)
    self.trailCinematic_right:SetOptions( {
            numSegments = numFlameSegments,
            collidesWithWorld = true,
            visibilityChangeDuration = 0,
            fadeOutCinematics = false,
            stretchTrail = true,
            trailLength = 2 * kRange,
            minHardening = 100,
            maxHardening = 100,
            hardeningModifier = 5,
            trailWeight = 0.04,
            maxLength = 1.1 * kRange
        } )

    end

function Firebreath:GetDeathIconIndex()
    return kDeathMessageIcon.Flamethrower
end

function Firebreath:GetHUDSlot()
    return 4
end

function Firebreath:OnPrimaryAttack(player)

    if not self.primaryAttacking then

        self.primaryAttacking = true

    end

    if Shared.GetTime() >= self.time + 0.25 then

        self.time = Shared.GetTime()

        if player:GetEnergy() >= 0.05 * player:GetMaxEnergy() then

            player:SetEnergy(math.max(0, player:GetEnergy() - 0.05 * player:GetMaxEnergy()))

            if Client then

                if self.trailCinematic_left == nil and self.trailCinematic_right == nil then

                    self:InitTrailCinematic()

                end

            end

            local trace = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + player:GetViewAngles():GetCoords().zAxis * 5, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))

            if trace.fraction ~= 1 then

                if trace.entity then
                    
                    if trace.entity:isa("Marine") or HasMixin(trace.entity, "Construct") or trace.entity:isa("Exo") then

                        if HasMixin(trace.entity, "Fire") then

                            trace.entity:SetOnFire(player, self)

                        end

                        self:DoDamage(10, trace.entity, trace.entity:GetOrigin(), nil)

                    end

                end

            end

        else

            if self.trailCinematic_left or self.trailCinematic_right then

                Client.DestroyTrailCinematic(self.trailCinematic_left)
                Client.DestroyTrailCinematic(self.trailCinematic_right)
                self.trailCinematic_left = nil
                self.trailCinematic_right = nil

            end

        end

    end

end

function Firebreath:OnPrimaryAttackEnd(self)

    Ability.OnPrimaryAttackEnd(self, player)

    if Client then

        if self.trailCinematic_left or self.trailCinematic_right then

            Client.DestroyTrailCinematic(self.trailCinematic_left)
            Client.DestroyTrailCinematic(self.trailCinematic_right)
            self.trailCinematic_left = nil
            self.trailCinematic_right = nil

        end

    end
    
    self.primaryAttacking = false

end

function Firebreath:OnProcessMove(input)

    Ability.OnProcessMove(self, input)

    -- local player = self:GetParent()
    -- if self.xenociding then

    -- end

end

function Firebreath:GetDamageType()
    
    return kFlamethrowerDamageType
        
end

Shared.LinkClassToMap("Firebreath", Firebreath.kMapName, networkVars)