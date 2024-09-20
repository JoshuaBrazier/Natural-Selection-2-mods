if Server then
    function Babbler:OnKill(attacker, doer, point, direction)
        if self:GetMaxHealth() > 3 then
            local babbler1 = CreateEntity(Babbler.kMapName, self:GetOrigin() + Vector(0, 0.1, 0), kTeam2Index)
            babbler1:SetOwner(self:GetOwner())
            babbler1:SetMaxHealth(self:GetMaxHealth() * 0.5)
            babbler1:OnInitialized()
            local babbler2 = CreateEntity(Babbler.kMapName, self:GetOrigin() + Vector(0, 0.1, 0), kTeam2Index)
            babbler2:SetOwner(self:GetOwner())
            babbler2:SetMaxHealth(self:GetMaxHealth() * 0.5)
            babbler2:OnInitialized()
            babbler1.targetId = self.targetId
            babbler2.targetId = self.targetId
            babbler1:UpdateBabbler()
            babbler2:UpdateBabbler()
        end
    end
end