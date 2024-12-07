local oldGetIsPrimary = GetIsPrimaryWeapon
function GetIsPrimaryWeapon(kMapName)
    
	local isPrimary = false
    if kMapName == SuppressedShotgun.kMapName then
		isPrimary = true
		return isPrimary
	else
		return oldGetIsPrimary(kMapName)
	end

end