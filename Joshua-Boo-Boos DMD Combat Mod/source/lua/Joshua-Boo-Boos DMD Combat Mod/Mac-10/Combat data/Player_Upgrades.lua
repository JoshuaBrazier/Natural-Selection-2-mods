local oldGetIsPrimary = GetIsPrimaryWeapon
function GetIsPrimaryWeapon(kMapName)
    
	local isPrimary = false
    if kMapName == Mac10.kMapName then
		isPrimary = false
		return isPrimary
	else
		return oldGetIsPrimary(kMapName)
	end

end