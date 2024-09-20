if Server then

    local function OrderBabblerToAttack(this, target, targetPos)
        local owner = this:GetOwner()
        if not owner then return end

        local orig = owner:GetOrigin()
        for _, babbler in ipairs(GetEntitiesForTeamWithinRange("Babbler", owner:GetTeamNumber(), orig, 6))
        do
            if babbler:GetOwner() == owner and not babbler:GetIsClinged() then
                babbler:SetMoveType(kBabblerMoveType.Attack, target, targetPos, true)
            end
        end
    end

    function Spit:ProcessHit(targetHit, surface, normal, hitPoint)

        --function LiveMixin:AddHealth(health, playSound, noArmor, hideEffect, healer, useEHP)

        --local amountHealed = targetEntity:AddHealth(health, true, false, false, player) --????Why was heal effect explicitly set to not show?!

        if self:GetOwner() ~= targetHit and GetAreEnemies(self:GetOwner(), targetHit) then
            self:DoDamage(kSpitDamage, targetHit, hitPoint, normal, "none", false, false)
            OrderBabblerToAttack(self, targetHit, hitPoint)
        elseif self:GetOwner() ~= targetHit and not GetAreEnemies(self:GetOwner(), targetHit) then

            if targetHit ~= nil then

                if (targetHit.GetHealth and targetHit.GetArmor) and (targetHit:GetHealth() < targetHit:GetMaxHealth() or targetHit:GetArmor() < targetHit:GetMaxArmor()) then
                    
                    if self:GetOwner():GetHasUpgrade( kTechId.Focus ) then

                        local veilLevel = self:GetOwner():GetVeilLevel()

                        if veilLevel == 0 then

                            targetHit:AddHealth(20, true, false, false, self:GetOwner())

                        elseif veilLevel == 1 then

                            targetHit:AddHealth(22, true, false, false, self:GetOwner())

                        elseif veilLevel == 2 then

                            targetHit:AddHealth(24, true, false, false, self:GetOwner())
                        
                        elseif veilLevel == 3 then

                            targetHit:AddHealth(26, true, false, false, self:GetOwner())

                        end

                    else

                        targetHit:AddHealth(20, true, false, false, self:GetOwner())

                    end

                end

            end

        elseif self:GetOwner() == targetHit then
            --a little hacky
            local player = self:GetOwner()
            if player then
                local eyePos = player:GetEyePos()
                local viewCoords = player:GetViewCoords()
                local trace = Shared.TraceRay(eyePos, eyePos + viewCoords.zAxis * 1.5, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
                if trace.fraction ~= 1 then

                    if trace.entity and trace.entity.GetTeamNumber then

                        local entity = trace.entity

                        if GetAreEnemies(self:GetOwner(), entity) then

                            if not self:GetOwner():GetHasUpgrade( kTechId.Focus ) then

                                self:DoDamage(30, entity, entity:GetOrigin(), nil)

                            else

                                if self:GetOwner():GetVeilLevel() == 1 then

                                    self:DoDamage(33, entity, entity:GetOrigin(), nil)

                                elseif self:GetOwner():GetVeilLevel() == 2 then

                                    self:DoDamage(36, entity, entity:GetOrigin(), nil)

                                elseif self:GetOwner():GetVeilLevel() == 3 then

                                    self:DoDamage(39, entity, entity:GetOrigin(), nil)

                                end

                            end

                        else

                            if (entity.GetHealth and targetHit.GetArmor) and (targetHit:GetHealth() < targetHit:GetMaxHealth() or targetHit:GetArmor() < targetHit:GetMaxArmor()) then
                    
                                if self:GetOwner():GetHasUpgrade( kTechId.Focus ) then
                
                                    local veilLevel = self:GetOwner():GetVeilLevel()

                                    if veilLevel == 0 then

                                        targetHit:AddHealth(20, true, false, false, self:GetOwner())
                
                                    elseif veilLevel == 1 then
                
                                        targetHit:AddHealth(22, true, false, false, self:GetOwner())
                
                                    elseif veilLevel == 2 then
                
                                        targetHit:AddHealth(24, true, false, false, self:GetOwner())
                                    
                                    elseif veilLevel == 3 then
                
                                        targetHit:AddHealth(26, true, false, false, self:GetOwner())
                
                                    end
                
                                else
                
                                    targetHit:AddHealth(20, true, false, false, self:GetOwner())
                
                                end
                
                            end

                        end

                    end

                end
            end
        end

        self:TriggerEffects("spit_hit", { effecthostcoords = self:GetCoords() })

        DestroyEntity(self)

    end
  
    function Spit:TimeUp()

        DestroyEntity(self)
        return false
        
    end
    
end