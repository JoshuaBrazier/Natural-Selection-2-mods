local origGetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
    if techId == kTechId.Mac10 or techId == kTechId.DropMac10 or techId == kTechId.Mac10Tech then
        techId = kTechId.Pistol
    end
    return origGetMaterialXYOffset(techId)
end