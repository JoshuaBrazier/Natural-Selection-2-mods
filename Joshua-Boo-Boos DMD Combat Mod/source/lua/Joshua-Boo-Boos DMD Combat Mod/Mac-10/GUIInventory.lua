local oldLocalAdjust = GUIInventory.LocalAdjustSlot

local kMac10Texture = PrecacheAsset("ui/Mac-10/Mac10_icon.dds")

function GUIInventory:LocalAdjustSlot(index, hudSlot, techId, isActive, resetAnimations, alienStyle)
	oldLocalAdjust(self, index, hudSlot, techId, isActive, resetAnimations, alienStyle)

	if techId == kTechId.Mac10 then
		local inventoryItem = self.inventoryIcons[index]
		inventoryItem.Graphic:SetTexture(kMac10Texture)
		inventoryItem.Graphic:SetTexturePixelCoordinates(0,0,128,64)
	end

end