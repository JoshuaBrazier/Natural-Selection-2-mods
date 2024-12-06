local newNetworkVars = {trackingMode = 'boolean', trackedTargetId = 'entityid'}

local oldOnCreate = HeavyMachineGun.OnCreate

function HeavyMachineGun:OnCreate()

    self.trackingMode = false
    self.trackedTarget = nil
    self.trackedTargetId = nil
    
    oldOnCreate(self)

end

local function compare(a,b)
    return a[1] < b[1]
end

local function CanHitTargetEntity(startPoint, endPoint, player, targetEntity)

    local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
    local dist = (startPoint - endPoint):GetLength()
    local hitWorld = false
    local hitTargetEntity = false

    -- Hit nothing?
    if trace.fraction == 1 then
        hitWorld = false
        -- Hit the world?
    elseif not trace.entity then

        dist = (startPoint - trace.endPoint):GetLength()
        hitWorld = true

    elseif trace.entity == targetEntity then

        hitTargetEntity = true

            -- Shared.Message("Traceray hit target entity")

        -- Hit target entity, return traced distance to it.
        dist = (startPoint - trace.endPoint):GetLength()
        hitWorld = false

    end

    return hitTargetEntity, hitWorld, dist

end

local trackingModeDamageScalar = 0.7
local trackingDistance = 20
local hitChanceChanger = 11
local maxAngleToDetect = 40

local function NewFireBullets(self, player)

    PROFILE("NewFireBullets")

    if self.trackingMode == false then

        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        -- Filter ourself out of the trace so that we don't hit ourselves.
        local filter = EntityFilterTwo(player, self)
        local range = self:GetRange()
        
        local numberBullets = self:GetBulletsPerShot()
        local startPoint = player:GetEyePos()
        local bulletSize = self:GetBulletSize()
        
        for bullet = 1, numberBullets do
        
            local spreadDirection = self:CalculateSpreadDirection(shootCoords, player)
            
            local endPoint = startPoint + spreadDirection * range
            local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, bulletSize, filter)        
            local damage = self:GetBulletDamage()

            HandleHitregAnalysis(player, startPoint, endPoint, trace)        

            local direction = (trace.endPoint - startPoint):GetUnit()
            local hitOffset = direction * kHitEffectOffset
            local impactPoint = trace.endPoint - hitOffset
            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = math.random() < effectFrequency

            local numTargets = #targets
            
            if numTargets == 0 then
                self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
            end
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, impactPoint)
            end
            
            for i = 1, numTargets do

                local target = targets[i]
                local hitPoint = hitPoints[i]

                self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)
                
                local client = Server and player:GetClient() or Client
                if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                    RegisterHitEvent(player, bullet, startPoint, trace, damage)
                end
            
            end
            
        end

        if self.trackedTargetId then

            self.trackedTargetId = nil
            self.trackedTarget = nil

        end

    elseif self.trackingMode == true then

        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        -- Filter ourself out of the trace so that we don't hit ourselves.
        local filter = EntityFilterTwo(player, self)
        local range = self:GetRange()
        
        local numberBullets = self:GetBulletsPerShot()
        local startPoint = player:GetEyePos()
        local bulletSize = self:GetBulletSize()
        
        for bullet = 1, numberBullets do
        
            local spreadDirection = self:CalculateSpreadDirection(shootCoords, player)
            if not self.trackedTarget or not IsValid(self.trackedTarget) then
                self.attacking = false
                break
            else

                local doesHit = false
                local hitChanceRoll
                local distanceBetweenPlayerAndTarget = (player:GetEyePos() - self.trackedTarget:GetEyePos()):GetLength()
                
                -- if distanceBetweenPlayerAndTarget <= 0.4 * trackingDistance then

                --     doesHit = true

                -- elseif distanceBetweenPlayerAndTarget > 0.4 * trackingDistance then

                if distanceBetweenPlayerAndTarget <= trackingDistance then

                    hitChanceRoll = math.random(1,100)

                    local unitVectorBetweenParentAndEnemy = GetNormalizedVector(self.trackedTarget:GetEyePos() - player:GetEyePos())
                    local viewCameraVector = player:GetViewCoords().zAxis
                    local dotProductValue = unitVectorBetweenParentAndEnemy:DotProduct(viewCameraVector)
                    local angle = math.acos(dotProductValue) * (180 / 3.14159)

                    if 50 - (hitChanceChanger + (12.5 * (maxAngleToDetect - angle)/maxAngleToDetect)) <= hitChanceRoll and hitChanceRoll <= 50 + (hitChanceChanger + (12.5 * (maxAngleToDetect - angle)/maxAngleToDetect)) then

                        doesHit = true

                    end

                end

                if doesHit then

                    local endPoint = self.trackedTarget:GetEyePos()
                    local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, bulletSize, filter)        
                    local damage = trackingModeDamageScalar * self:GetBulletDamage()

                    HandleHitregAnalysis(player, startPoint, endPoint, trace)        

                    local direction = (trace.endPoint - startPoint):GetUnit()
                    local hitOffset = direction * kHitEffectOffset
                    local impactPoint = trace.endPoint - hitOffset
                    local effectFrequency = self:GetTracerEffectFrequency()
                    local showTracer = math.random() < effectFrequency

                    local numTargets = #targets
                    
                    if numTargets == 0 then
                        self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
                    end
                    
                    if Client and showTracer then
                        TriggerFirstPersonTracer(self, impactPoint)
                    end
                    
                    for i = 1, numTargets do

                        local target = targets[i]
                        local hitPoint = hitPoints[i]

                        self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)
                        
                        local client = Server and player:GetClient() or Client
                        if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                            RegisterHitEvent(player, bullet, startPoint, trace, damage)
                        end
                    
                    end

                    if self.trackedTarget:GetHealth() - damage <= 0 then

                        self.trackedTarget = nil
                        self.trackedTargetId = nil
                        break
                    
                    end

                end

            end

        end

    end
    
end

function HeavyMachineGun:GetHasSecondary(player)
    return true
end

function HeavyMachineGun:GetSecondaryAttackRequiresPress()
    return true
end

function HeavyMachineGun:OnSecondaryAttack(player)

    if not player:GetSecondaryAttackLastFrame() then

        if self.trackingMode == false then

            self.trackingMode = true

        elseif self.trackingMode == true then

            self.trackingMode = false

            self.trackedTargetId = nil
            self.trackedTarget = nil

        end

    end

end

function HeavyMachineGun:FirePrimary(player)
    self.fireTime = Shared.GetTime()
    NewFireBullets(self, player)
end

-- local oldOPA = HeavyMachineGun.OnPrimaryAttack

-- function HeavyMachineGun:OnPrimaryAttack(player)
--     if not self.trackingMode then
--         oldOPA(self, player)
--     elseif self.trackingMode then

--         if self.trackedTarget and IsValid(self.trackedTarget) then

--             if not self.trackedTarget or not self.trackedTargetId then

--             elseif self.trackedTarget and self.trackedTargetId and self.trackedTarget.GetHealth and self.trackedTarget:GetHealth() > 0 and not self.trackedTarget:isa("AlienSpectator") and (player:GetOrigin() - self.trackedTarget:GetOrigin()):GetLength() <= trackingDistance and CanHitTargetEntity(player:GetEyePos(), self.trackedTarget:GetEyePos(), player, self.trackedTarget) then
--                 oldOPA(self, player)
--             elseif self.trackedTarget and self.trackedTargetId and self.trackedTarget.GetHealth and self.trackedTarget:GetHealth() <= 0 or self.trackedTarget:isa("AlienSpectator") or (player:GetOrigin() - self.trackedTarget:GetOrigin()):GetLength() > trackingDistance then
--                 self.trackedTarget = nil
--                 self.trackedTargetId = nil
--                 oldOPA(self, player)
--             end

--         else

--             if self.trackedTarget and IsValid(self.trackedTarget) then

--                 if not self.trackedTarget or not self.trackedTargetId then
    
--                 elseif self.trackedTarget and self.trackedTargetId and self.trackedTarget.GetHealth and self.trackedTarget:GetHealth() > 0 and not self.trackedTarget:isa("AlienSpectator") and (player:GetOrigin() - self.trackedTarget:GetOrigin()):GetLength() <= trackingDistance and CanHitTargetEntity(player:GetEyePos(), self.trackedTarget:GetEyePos(), player, self.trackedTarget) then
--                     oldOPA(self, player)
--                 elseif self.trackedTarget and self.trackedTargetId and self.trackedTarget.GetHealth and self.trackedTarget:GetHealth() <= 0 or (player:GetOrigin() - self.trackedTarget:GetOrigin()):GetLength() > trackingDistance or not CanHitTargetEntity(player:GetEyePos(), self.trackedTarget:GetEyePos(), player, self.trackedTarget) then
--                     self.trackedTarget = nil
--                     self.trackedTargetId = nil
--                     self.attacking = false
--                 end

--             end
        
--         end
        
--     end
-- end


local oldPMOW = HeavyMachineGun.ProcessMoveOnWeapon

function HeavyMachineGun:ProcessMoveOnWeapon(player, input)

    if self.trackingMode then

        if bit.band(input.commands, Move.PrimaryAttack) ~= 0 then

            local parent = self:GetParent()
            if parent then

                local alienPlayers = GetEntitiesForTeamWithinRange("Player", kTeam2Index, parent:GetOrigin(), trackingDistance)
                local distancesAndPlayers = {}
                for i = 1, #alienPlayers do
                    local distance = (parent:GetOrigin() - alienPlayers[i]:GetOrigin()):GetLength()
                    -- Shared.Message(string.format("distance of target %i is %.1f", i, distance))
                    if not alienPlayers[i]:isa("AlienSpectator") and alienPlayers[i].GetHealth and alienPlayers[i]:GetHealth() > 0 and not alienPlayers[i]:isa("Hive") then
                        if CanHitTargetEntity(parent:GetEyePos(), alienPlayers[i]:GetEyePos(), parent, alienPlayers[i]) then
                            local unitVectorBetweenParentAndEnemy = GetNormalizedVector((alienPlayers[i]:GetEyePos() - parent:GetEyePos()))
                            local viewCameraVector = parent:GetViewCoords().zAxis
                            local dotProductValue = unitVectorBetweenParentAndEnemy:DotProduct(viewCameraVector)
                            local angle = math.acos(dotProductValue) * (180 / 3.14159)
                            if angle < maxAngleToDetect then
                                table.insert(distancesAndPlayers, {distance, alienPlayers[i]})
                            end
                        end
                    end
                end

                if #distancesAndPlayers > 0 then
                    -- Shared.Message("DISTANCESANDPLAYERS > 0")
                    table.sort(distancesAndPlayers, compare)
                    -- Shared.Message("DISTANCESANDPLAYERS SORTED")
                    self.trackedTarget = distancesAndPlayers[1][2]
                    self.trackedTargetId = distancesAndPlayers[1][2]:GetId()
                    -- Shared.Message(string.format("SELF.TRACKEDTARGETID = %s", tostring(self.trackedTargetId)))

                else
                    -- Shared.Message("DISTANCESANDPLAYERS COUNT == 0")
                end
            end

            if self.trackedTarget and IsValid(self.trackedTarget) then

                local stopShootingDueToAngle = false

                local unitVectorBetweenParentAndEnemy = GetNormalizedVector(self.trackedTarget:GetEyePos() - parent:GetEyePos())
                local viewCameraVector = parent:GetViewCoords().zAxis
                local dotProductValue = unitVectorBetweenParentAndEnemy:DotProduct(viewCameraVector)
                local angle = math.acos(dotProductValue) * (180 / 3.14159)
                if angle > maxAngleToDetect then
                    self.trackedTarget = nil
                    self.trackedTargetId = nil
                    stopShootingDueToAngle = true
                end

                if self.trackedTarget and IsValid(self.trackedTarget) and not CanHitTargetEntity(player:GetEyePos(), self.trackedTarget:GetEyePos(), player, self.trackedTarget) or stopShootingDueToAngle then

                    -- Shared.Message("CANNOT HIT TARGET ENTITY")

                    input.commands = bit.band(input.commands, bit.bnot(Move.PrimaryAttack))

                    self.attacking = false
                    self.primaryAttacking = false

                end

            elseif not self.trackedTarget or not IsValid(self.trackedTarget) then

                -- Shared.Message("NO TARGET ENTITY TO HIT - PROCESSMOVEONWEAPON")

                input.commands = bit.band(input.commands, bit.bnot(Move.PrimaryAttack))

                self.attacking = false
                self.primaryAttacking = false

            end

        end
    
    end

    oldPMOW(self, player, input)
    
end

Shared.LinkClassToMap("HeavyMachineGun", HeavyMachineGun.kMapName, newNetworkVars)