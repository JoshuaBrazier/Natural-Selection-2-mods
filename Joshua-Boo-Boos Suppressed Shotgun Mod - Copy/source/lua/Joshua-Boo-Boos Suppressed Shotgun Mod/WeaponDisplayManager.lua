local GetWeaponClassesToPreload = WeaponDisplayManager.GetWeaponClassesToPreload
function WeaponDisplayManager:GetWeaponClassesToPreload()

    local classList = GetWeaponClassesToPreload(self)

    assert(SuppressedShotgun)
    table.insert(classList, SuppressedShotgun)
    
    return classList
    
end