class 'SuppressedShotgunAmmo' (WeaponAmmoPack)
SuppressedShotgunAmmo.kMapName = "suppressedshotgunammo"
SuppressedShotgunAmmo.kModelName = PrecacheAsset("models/marine/rifle/RifleAmmo.model")

function SuppressedShotgunAmmo:OnInitialized()

    WeaponAmmoPack.OnInitialized(self)
    self:SetModel(SuppressedShotgunAmmo.kModelName)

end

function SuppressedShotgunAmmo:GetWeaponClassName()
    return "SuppressedShotgun"
end

Shared.LinkClassToMap("SuppressedShotgunAmmo", SuppressedShotgunAmmo.kMapName)