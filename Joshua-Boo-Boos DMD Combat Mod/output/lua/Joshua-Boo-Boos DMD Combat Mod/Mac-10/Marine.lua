local oldGetStatusDesc = Marine.GetPlayerStatusDesc
function Marine:GetPlayerStatusDesc()
		  
	local weapon = self:GetWeaponInHUDSlot(2)
	if (weapon) then
		if (weapon:isa("Mac10")) then
			return kPlayerStatus.Mac10
		end
	end
		
	return oldGetStatusDesc(self)
end

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)