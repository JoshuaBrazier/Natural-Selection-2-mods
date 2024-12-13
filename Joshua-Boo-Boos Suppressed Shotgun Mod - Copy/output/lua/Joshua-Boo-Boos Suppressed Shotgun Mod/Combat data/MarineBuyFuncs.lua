local oldCombatMarineBuy_GUISortUps = CombatMarineBuy_GUISortUps
function CombatMarineBuy_GUISortUps(upgradeList)

	local suppressedshotgunUpgrade
	for _, upgrade in ipairs(upgradeList) do
		if upgrade:GetTechId() == kTechId.SuppressedShotgun then
			suppressedshotgunUpgrade = upgrade
			break
		end
	end

	local oldList = oldCombatMarineBuy_GUISortUps(upgradeList)
	
	if suppressedshotgunUpgrade then
		for index, entry in ipairs(oldList) do
			if entry.GetTechId and entry:GetTechId() == kTechId.Shotgun then
				table.insert(oldList, index, suppressedshotgunUpgrade)
				break
			end
		end
	end
	
	return oldList
	
end

local oldDescFunc = CombatMarineBuy_GetWeaponDescription
function CombatMarineBuy_GetWeaponDescription(techId)
	if techId == kTechId.SuppressedShotgun then
		return "Joshua-Boo-Boos Suppressed Shotgun - Requires NS2 shotgun to unlock!"
	end
	return oldDescFunc(techId)
end