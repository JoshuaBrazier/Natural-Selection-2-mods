
local oldBuildClassToGrid = BuildClassToGrid
function BuildClassToGrid()

    local ClassToGrid = oldBuildClassToGrid()
    
	ClassToGrid["Mac10"] = { 1, 2 }
    
    return ClassToGrid
    
end

local loadOnce = true
local oldGetTexCoordsForTechId = GetTexCoordsForTechId
function GetTexCoordsForTechId(techId)
	if loadOnce and gTechIdPosition then
		gTechIdPosition[kTechId.Mac10] = kDeathMessageIcon.Mac10
		loadOnce = false
	end
	return oldGetTexCoordsForTechId(techId)
end
