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

function Player:OnUpdatePlayer(deltaTime)

    if self:isa("Lerk") then

        if self.carried_entity_id and self.carried_entity_id ~= 0 then

            if IsValid(Shared.GetEntity(string.format("%i", self.carried_entity_id))) and Shared.GetEntity(string.format("%i", self.carried_entity_id)).GetHealth and Shared.GetEntity(string.format("%i", self.carried_entity_id)):GetHealth() <= 0 then

                self.is_carrying_an_entity = false
                self.carried_entity_id = 0

            elseif self:GetHealth() > 0 and IsValid(Shared.GetEntity(string.format("%i", self.carried_entity_id))) and Shared.GetEntity(string.format("%i", self.carried_entity_id)).GetHealth and Shared.GetEntity(string.format("%i", self.carried_entity_id)):GetHealth() > 0 then

                if Shared.GetTime() >= self.time + 0.1 then

                    self.time = Shared.GetTime()

                    if not self:GetIsOnGround() then

                        if self:GetEnergy() >= 0.05 * self:GetMaxEnergy() then

                            self:SetEnergy(math.max(0, self:GetEnergy() - 0.0275 * self:GetMaxEnergy()))

                        elseif self:GetEnergy() < 0.05 * self:GetMaxEnergy() then

                            if self.carried_entity_id and IsValid(Shared.GetEntity(self.carried_entity_id)) then
                    
                                self.is_carrying_an_entity = false
                                Shared.GetEntity(self.carried_entity_id).carrying_lerk_id = nil
                                self.carried_entity_id = nil
            
                            end

                        end

                    end

                end

            end

        end

    elseif self:isa("Gorge") or (self:isa("Marine") and not self:isa("JetpackMarine") and not self:isa("Exo")) then

    -- elseif self:isa("Gorge") then

        if self.carrying_lerk_id and self.carrying_lerk_id ~= 0 then

            if IsValid(Shared.GetEntity(string.format("%i", self.carrying_lerk_id))) and Shared.GetEntity(string.format("%i", self.carrying_lerk_id)).GetHealth and Shared.GetEntity(string.format("%i", self.carrying_lerk_id)):GetHealth() > 0 then

                self:SetOrigin(Shared.GetEntity(self.carrying_lerk_id):GetOrigin() - 1.5 * Vector(GetNormalizedVector(Shared.GetEntity(self.carrying_lerk_id):GetViewAngles():GetCoords().zAxis).x, 0, GetNormalizedVector(Shared.GetEntity(self.carrying_lerk_id):GetViewAngles():GetCoords().zAxis).z) + Vector(0, 0.2, 0))

            elseif (IsValid(Shared.GetEntity(string.format("%i", self.carrying_lerk_id))) and Shared.GetEntity(string.format("%i", self.carrying_lerk_id)).GetHealth and Shared.GetEntity(string.format("%i", self.carrying_lerk_id)):GetHealth() <= 0) or not IsValid(Shared.GetEntity(string.format("%i", self.carrying_lerk_id))) then

                self.carrying_lerk_id = nil

            end

        end

    end
    
    oldOUP(self, deltaTime)

end