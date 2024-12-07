local oldCombatMarineBuy_GUISortUps = CombatMarineBuy_GUISortUps
function CombatMarineBuy_GUISortUps(upgradeList)

	local mac10Upgrade
	for _, upgrade in ipairs(upgradeList) do
		if upgrade:GetTechId() == kTechId.Mac10 then
			mac10Upgrade = upgrade
			break
		end
	end

	local oldList = oldCombatMarineBuy_GUISortUps(upgradeList)
	
	if mac10Upgrade then
		for index, entry in ipairs(oldList) do
			if entry.GetTechId and entry:GetTechId() == kTechId.Shotgun then
				table.insert(oldList, index, mac10Upgrade)
				break
			end
		end
	end
	
	return oldList
	
end

local oldDescFunc = CombatMarineBuy_GetWeaponDescription
function CombatMarineBuy_GetWeaponDescription(techId)
	if techId == kTechId.Mac10 then
		return "Joshua-Boo-Boos Mac-10 - Requires Weapons 1 to unlock!"
	end
	return oldDescFunc(techId)
end