local oldGetStatusDesc = Marine.GetPlayerStatusDesc
function Marine:GetPlayerStatusDesc()
		  
	local weapon = self:GetWeaponInHUDSlot(1)
	if (weapon) then
		if (weapon:isa("SuppressedShotgun")) then
			return kPlayerStatus.SuppressedShotgun
		end
	end
		
	return oldGetStatusDesc(self)
end