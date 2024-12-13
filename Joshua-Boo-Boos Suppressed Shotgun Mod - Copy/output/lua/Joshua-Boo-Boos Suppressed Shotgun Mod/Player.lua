if Client then
	local origGetCrosshairY = PlayerUI_GetCrosshairY
	function PlayerUI_GetCrosshairY()
		if mapname == SuppressedShotgun.kMapName then
			mapname = Shotgun.kMapName
		end
		return origGetCrosshairY(self)
	end
end
	
