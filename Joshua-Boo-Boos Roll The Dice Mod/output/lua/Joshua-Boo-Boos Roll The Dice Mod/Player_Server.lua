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

local oldPlayerOnKill = Player.OnKill

function Player:OnKill(killer, doer, point, direction)

    self:SendDirectMessage("ROLL THE DICE: M -> Client Config -> Plugins -> ENABLE Joshua-Boo-Boos Roll The Dice Plugin -> Press F9")

    oldPlayerOnKill(self, killer, doer, point, direction)
    
end