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