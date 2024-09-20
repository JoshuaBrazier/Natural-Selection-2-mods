function BiteLeap:OnTag(tagName)

    PROFILE("BiteLeap:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then
        
            -- local range = (player.GetIsEnzymed and player:GetIsEnzymed()) and kEnzymedRange or kRange
        
            local didHit, target, endPoint = AttackMeleeCapsule(self, player, kBiteDamage, 1.42, nil, false, EntityFilterOneAndIsa(player, "Babbler"))

            if didHit then

                if Client then
                    self:TriggerFirstPersonHitEffects(player, target)
                end

                if target then
                    
                    if target:isa("Clog") then

                        -- Shared.Message(string.format("hp was %i, ap was %i", target:GetHealth(), target:GetArmor()))

                        --function LiveMixin:AddHealth(health, playSound, noArmor, hideEffect, healer, useEHP)

                        player:AddHealth(2, true, false, false, player, true)

                        -- Shared.Message(string.format("hp is now %i, ap is now %i", target:GetHealth(), target:GetArmor()))

                    end

                end

            end
            
            if target and HasMixin(target, "Live") and not target:GetIsAlive() then
                self:TriggerEffects("bite_kill")
            elseif Server and target and target.TriggerEffects and GetReceivesStructuralDamage(target) and (not HasMixin(target, "Live") or target:GetCanTakeDamage()) then
                target:TriggerEffects("bite_structure", {effecthostcoords = Coords.GetTranslation(endPoint), isalien = GetIsAlienUnit(target)})
            end
            

            self:OnAttack(player)
            self:TriggerEffects("bite_attack")
            
        end
        
    end
    
end