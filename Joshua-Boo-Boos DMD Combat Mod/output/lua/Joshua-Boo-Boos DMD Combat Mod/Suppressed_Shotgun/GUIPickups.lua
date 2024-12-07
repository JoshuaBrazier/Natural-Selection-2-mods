
local GetPickupTextureCoordinates = debug.getupvaluex(GUIPickups.Update, "GetPickupTextureCoordinates")
local kPickupTypes = debug.getupvaluex(GetPickupTextureCoordinates, "kPickupTypes")
table.insert(kPickupTypes, "SuppressedShotgun")
local kPickupTextureYOffsets = debug.getupvaluex(GetPickupTextureCoordinates, "kPickupTextureYOffsets")
kPickupTextureYOffsets["SuppressedShotgun"] = 13