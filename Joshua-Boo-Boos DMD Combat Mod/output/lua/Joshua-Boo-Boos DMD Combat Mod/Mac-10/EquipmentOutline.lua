local origUpdateModel = EquipmentOutline_UpdateModel()
function EquipmentOutline_UpdateModel(forEntity)
	if weaponclass == 'Mac10' then
		weaponclass = 'Pistol'
	end
	return origUpdateModel(forEntity)
end
