local oldOC = SwipeBlink.OnCreate

function SwipeBlink:OnCreate()

    oldOC(self)

    self.number_of_hits = 0

end

function SwipeBlink:PerformMeleeAttack()

    local didHit = false
    local lastTarget = nil
    local endPoint = nil
    local surface = nil

    local player = self:GetParent()

    if player then    
        didHit, lastTarget, endPoint, surface = AttackMeleeCapsule(self, player, SwipeBlink.kDamage, SwipeBlink.kRange, nil, false, EntityFilterOneAndIsa(player, "Babbler"))
    end

    if didHit and lastTarget and lastTarget.GetTeamNumber and lastTarget:GetTeamNumber() == kTeam1Index and not HasMixin(lastTarget, "Construct") then
        player:TriggerEffects("heal", { isalien = GetIsAlienUnit(player) })
        player:TriggerEffects("heal_sound", { isalien = GetIsAlienUnit(player), regen = player.healedFromSelf })
        if player:GetHasUpgrade( kTechId.Focus ) then

            local veils = GetEntitiesForTeam("Veil", kTeam2Index)
            local veilLevel = 0

            for i = 1, #veils do
                if veils[i]:GetIsBuilt() then
                    veilLevel = veilLevel + 1
                end
            end

            if veilLevel == 0 then

                player:AddHealth(10, true, false, false, player, true)

            elseif veilLevel == 1 then

                player:AddHealth(11, true, false, false, player, true)

            elseif veilLevel == 2 then

                player:AddHealth(12, true, false, false, player, true)
            
            elseif veilLevel >= 3 then

                player:AddHealth(13, true, false, false, player, true)

            end

        else

            player:AddHealth(10, true, false, false, player, true)

        end
        self.number_of_hits = math.min(5, self.number_of_hits + 1)
    elseif not didHit then
        self.number_of_hits = math.max(-5, self.number_of_hits - 1)
    end
    
end