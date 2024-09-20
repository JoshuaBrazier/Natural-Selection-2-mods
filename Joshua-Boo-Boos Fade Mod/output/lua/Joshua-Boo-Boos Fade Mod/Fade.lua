function Fade:ModifyAttackSpeed(attackSpeedTable)

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and activeWeapon:isa("SwipeBlink") then
        attackSpeedTable.attackSpeed = attackSpeedTable.attackSpeed * (1 + 0.05 * activeWeapon.number_of_hits + 0.25 * (1 - ((self:GetHealth() + self:GetArmor()) / (self:GetMaxHealth() + self:GetMaxArmor()))))
    end

end