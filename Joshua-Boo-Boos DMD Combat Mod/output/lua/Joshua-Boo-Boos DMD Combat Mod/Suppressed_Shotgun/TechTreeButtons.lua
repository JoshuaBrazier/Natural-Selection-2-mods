local origGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.SuppressedShotgun or techId == kTechId.DropSuppressedShotgun or techId == kTechId.SuppressedShotgunTech then
        techId = kTechId.Shotgun
    end
    return origGetMaterialXYOffset(techId)
end