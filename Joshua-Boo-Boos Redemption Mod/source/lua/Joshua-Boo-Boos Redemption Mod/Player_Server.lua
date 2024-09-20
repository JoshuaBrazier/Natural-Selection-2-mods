local function UpdateChangeToSpectator(self)

    if not self:GetIsAlive() and not self:isa("Spectator") then
        local time = Shared.GetTime()
        if self.timeOfDeath ~= nil and (time - self.timeOfDeath > kFadeToBlackTime) and (not GetConcedeSequenceActive()) then

            -- Destroy the existing player and create a spectator in their place (but only if it has an owner, ie not a body left behind by Phantom use)
            local owner = Server.GetOwner(self)
            if owner then

                -- Ready room players respawn instantly. Might need an API.
                if self:GetTeamNumber() == kTeamReadyRoom then
                    self:GetTeam():ReplaceRespawnPlayer(self, nil, nil);
                else
                    local spectator = self:Replace(self:GetDeathMapName())
                    spectator:GetTeam():PutPlayerInRespawnQueue(spectator)

                    -- Queue up the spectator for respawn.
                    local killer = self.killedBy and Shared.GetEntity(self.killedBy) or nil
                    if killer then
                        spectator:SetupKillCam(self, killer)
                    end
                end

            end

        end

    end

end

local oldOUP = Player.OnUpdatePlayer

local function compare(a,b)
    return a[1] < b[1]
end

function Player:OnUpdatePlayer(deltaTime)

    if self:isa("Alien") then

        if kCombatVersion then

            if self.twoHives or self.threeHives then

                local hives = GetEntitiesForTeam("Hive", kTeam2Index)
                local built_hives = {}
                local hive_entity_and_distance_pairs = {}

                for i = 1, #hives do
                    if hives[i]:GetIsBuilt() then
                        table.insert(built_hives, hives[i])
                    end
                end

                for j = 1, #built_hives do
                    table.insert(hive_entity_and_distance_pairs, {built_hives[j], (self:GetOrigin() - built_hives[j]:GetOrigin()):GetLengthSquared()})
                end

                if #built_hives > 0 then

                    table.sort(hive_entity_and_distance_pairs, compare)

                    if self.inCombat and not self.xenociding and not self.redemption_rolled and (Shared.GetTime() - self.lastTakenDamageTime) < 1 and self:GetHealth() <= math.max(28.5, 0.15 * self:GetMaxHealth()) and self:GetHealth() > 0 then

                        local redemption_roll = math.random()

                        local combat_redemption_value

                        if self.twoHives and not self.threeHives then

                            combat_redemption_value = 0.15
                            
                        elseif self.threeHives then

                            combat_redemption_value = 0.3

                        end

                        if redemption_roll <= combat_redemption_value then

                            self:SetHealth(math.max(50, self:GetHealth()))

                            self:SetOrigin(hive_entity_and_distance_pairs[1][1]:GetOrigin())

                            local techId = self:GetTechId()
                            local bounds = GetExtents(techId)
                            local spawn
                            local height, radius = GetTraceCapsuleFromExtents( bounds )
                            local resourceNear
                            local i = 1

                            repeat
                                spawn = GetRandomSpawnForCapsule( height, radius, self:GetOrigin(), 0.1, 15, EntityFilterAll() )

                                if spawn then
                                    resourceNear = #GetEntitiesWithinRange( "ResourcePoint", spawn, 2 ) > 0
                                end

                                i = i + 1
                            until not resourceNear or i > 100

                            if spawn then
                                self:SetOrigin(spawn)
                            end

                        end

                        self.redemption_rolled = true

                    elseif not self.inCombat and self.redemption_rolled then

                        self.redemption_rolled = false

                    end

                end

            end

        else

            if GetHasTech(self, kTechId.ShiftHive, true) then

                local hives = GetEntitiesForTeam("Hive", kTeam2Index)
                local built_hives = {}
                local hive_entity_and_distance_pairs = {}

                for i = 1, #hives do
                    if hives[i]:GetIsBuilt() then
                        table.insert(built_hives, hives[i])
                    end
                end

                for j = 1, #built_hives do
                    table.insert(hive_entity_and_distance_pairs, {built_hives[j], (self:GetOrigin() - built_hives[j]:GetOrigin()):GetLengthSquared()})
                end

                if #built_hives > 0 then

                    table.sort(hive_entity_and_distance_pairs, compare)

                    local bio_num = 0
                    for i = 1, #hives do
                        bio_num = bio_num + hives[i].bioMassLevel
                    end

                    if self.inCombat and not self.xenociding and not self.redemption_rolled and (Shared.GetTime() - self.lastTakenDamageTime) < 1 and self:GetHealth() <= math.max(28.5, 0.15 * self:GetMaxHealth()) and self:GetHealth() > 0 then

                        local redemption_roll = math.random()

                        if redemption_roll <= 0.25 * (bio_num / 12) then

                            self:SetHealth(math.max(50, self:GetHealth()))

                            self:SetOrigin(hive_entity_and_distance_pairs[1][1]:GetOrigin())

                            local techId = self:GetTechId()
                            local bounds = GetExtents(techId)
                            local spawn
                            local height, radius = GetTraceCapsuleFromExtents( bounds )
                            local resourceNear
                            local i = 1

                            repeat
                                spawn = GetRandomSpawnForCapsule( height, radius, self:GetOrigin(), 0.1, 10, EntityFilterAll() )

                                if spawn then
                                    resourceNear = #GetEntitiesWithinRange( "ResourcePoint", spawn, 2 ) > 0
                                end

                                i = i + 1
                            until not resourceNear or i > 100

                            if spawn then
                                self:SetOrigin(spawn)
                            end

                        end

                        self.redemption_rolled = true

                    elseif not self.inCombat and self.redemption_rolled then

                        self.redemption_rolled = false

                    end

                end

            end

        end

    end

    oldOUP(self, deltaTime)
    
end