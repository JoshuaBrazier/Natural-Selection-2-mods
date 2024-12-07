local oldLocalAdjust = GUIInventory.LocalAdjustSlot

local kSuppressedShotgunTexture = PrecacheAsset("ui/Suppressed_Shotgun/SuppressedShotgun_icon.dds")

function GUIInventory:LocalAdjustSlot(index, hudSlot, techId, isActive, resetAnimations, alienStyle)
	oldLocalAdjust(self, index, hudSlot, techId, isActive, resetAnimations, alienStyle)

	if techId == kTechId.SuppressedShotgun then
		local inventoryItem = self.inventoryIcons[index]
		inventoryItem.Graphic:SetTexture(kSuppressedShotgunTexture)
		inventoryItem.Graphic:SetTexturePixelCoordinates(0,0,128,64)
	end

end