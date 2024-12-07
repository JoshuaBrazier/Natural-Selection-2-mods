
local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()

    local ClassToGrid = oldBuildClassToGrid()
    
	ClassToGrid["SuppressedShotgun"] = { 1, 2 }
    
    return ClassToGrid
    
end

local loadOnce = true
local oldGetTexCoordsForTechId = GetTexCoordsForTechId
function GetTexCoordsForTechId(techId)
	if loadOnce and gTechIdPosition then
		gTechIdPosition[kTechId.SuppressedShotgun] = kDeathMessageIcon.SuppressedShotgun
		loadOnce = false
	end
	return oldGetTexCoordsForTechId(techId)
end
