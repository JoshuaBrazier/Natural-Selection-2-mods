class 'Mac10Ammo' (WeaponAmmoPack)
Mac10Ammo.kMapName = "mac10ammo"
Mac10Ammo.kModelName = PrecacheAsset("models/marine/rifle/RifleAmmo.model")

function Mac10Ammo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(Mac10Ammo.kModelName)

end

function Mac10Ammo:GetWeaponClassName()
    return "Mac10"
end

Shared.LinkClassToMap("Mac10Ammo", Mac10Ammo.kMapName)