local GetWeaponClassesToPreload = WeaponDisplayManager.GetWeaponClassesToPreload
function WeaponDisplayManager:GetWeaponClassesToPreload()

    local classList = GetWeaponClassesToPreload(self)

    assert(Mac10)
    table.insert(classList, Mac10)
    
    return classList
    
end