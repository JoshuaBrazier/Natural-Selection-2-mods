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

    oldOUP(self, deltaTime)

    local weapon = self:GetActiveWeapon()

    if weapon and weapon:isa("Shotgun") then

        if weapon.tracked_target ~= 0 then
        
            weapon.time_now = Shared.GetTime()
    
            if weapon.time_now >= weapon.hit_tracker_target_at + 5 or not IsValid(Shared.GetEntity(weapon.tracked_target)) then
    
                weapon.tracked_target = 0
    
            end
    
        end

    end
    
end