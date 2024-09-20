if Client then
	local origGetCrosshairY = PlayerUI_GetCrosshairY
	function PlayerUI_GetCrosshairY()
		if mapname == Mac10.kMapName then
			mapname = Pistol.kMapName
		end
		return origGetCrosshairY(self)
	end
end
	
