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

    if self:isa("Skulk") then

        if self:GetIsLeaping() and not self.has_hit_target then

            local trace = Shared.TraceCapsule(self:GetEyePos(), self:GetEyePos() + self:GetViewAngles():GetCoords().zAxis * 1.25, 0.25, 0.25, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(self))
            if trace.fraction ~= 1 and trace.entity then
                
                if trace.entity:GetTeamNumber() == kTeam1Index then
                    local entity = trace.entity
                    self:SetActiveWeapon(BiteLeap.kMapName)
                    self:GetActiveWeapon():DoDamage(25, entity, entity:GetOrigin(), nil)
                    self.has_hit_target = true
                end
                
            end

        elseif not self:GetIsLeaping() and self.has_hit_target then

            self.has_hit_target = false

        end

    end

end