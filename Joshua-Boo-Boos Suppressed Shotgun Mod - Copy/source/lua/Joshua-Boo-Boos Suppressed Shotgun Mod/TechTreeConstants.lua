if not EnumUtils then
    Script.Load("lua/Joshua-Boo-Boos Suppressed Shotgun Mod/EnumUtils.lua")
end

local newTechIds = {
    "SuppressedShotgun",
    "SuppressedShotgunTech",
    'DropSuppressedShotgun',
}

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end