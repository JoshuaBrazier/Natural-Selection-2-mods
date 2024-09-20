function LerkBite:OnTag(tagName)

    PROFILE("LerkBite:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then

            self:TriggerEffects("lerkbite_attack")
            self:OnAttack(player)
            
            self.spiked = false
        
            local didHit, target, endPoint, surface = AttackMeleeCapsule(self, player, kLerkBiteDamage, 1.5, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
            
            if didHit and target then

                if target:isa("Clog") then

                    -- Shared.Message(string.format("hp was %i, ap was %i", target:GetHealth(), target:GetArmor()))

                    --function LiveMixin:AddHealth(health, playSound, noArmor, hideEffect, healer, useEHP)

                    player:AddHealth(4, true, false, false, player, true)

                    -- Shared.Message(string.format("hp is now %i, ap is now %i", target:GetHealth(), target:GetArmor()))

                end
            
                if Server then
                    if not player.isHallucination and target:isa("Marine") and target:GetCanTakeDamage() then
                        target:SetPoisoned(player)
                    end
                elseif Client then
                    self:TriggerFirstPersonHitEffects(player, target)
                end
            
            end
            
            if target and HasMixin(target, "Live") and not target:GetIsAlive() then
                self:TriggerEffects("bite_kill")
            end
            
        end
        
    end
    
end