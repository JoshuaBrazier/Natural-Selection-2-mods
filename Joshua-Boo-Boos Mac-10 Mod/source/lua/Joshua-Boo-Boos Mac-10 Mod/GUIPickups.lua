
local GetPickupTextureCoordinates = debug.getupvaluex(GUIPickups.Update, "GetPickupTextureCoordinates")
local kPickupTypes = debug.getupvaluex(GetPickupTextureCoordinates, "kPickupTypes")
table.insert(kPickupTypes, "Mac10")
local kPickupTextureYOffsets = debug.getupvaluex(GetPickupTextureCoordinates, "kPickupTextureYOffsets")
kPickupTextureYOffsets["Mac10"] = 13