if not EnumUtils then
    Script.Load("lua/Joshua-Boo-Boos DMD Combat Mod/Suppressed_Shotgun/EnumUtils.lua")
end

local newTechIds = {
    "SuppressedShotgun",
    "SuppressedShotgunTech",
    'DropSuppressedShotgun',
}

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end