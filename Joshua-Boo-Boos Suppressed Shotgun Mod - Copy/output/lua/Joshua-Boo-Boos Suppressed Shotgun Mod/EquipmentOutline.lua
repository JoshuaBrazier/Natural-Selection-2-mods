local origUpdateModel = EquipmentOutline_UpdateModel()
function EquipmentOutline_UpdateModel(forEntity)
	if weaponclass == 'SuppressedShotgun' then
		weaponclass = 'Shotgun'
	end
	return origUpdateModel(forEntity)
end
