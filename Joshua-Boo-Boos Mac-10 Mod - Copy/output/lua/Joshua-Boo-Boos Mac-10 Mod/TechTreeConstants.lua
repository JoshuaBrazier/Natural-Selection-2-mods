if not EnumUtils then
    Script.Load("lua/Joshua-Boo-Boos Mac-10 Mod/EnumUtils.lua")
end

local newTechIds = {
    "Mac10",
    "Mac10Tech",
    'DropMac10',
}

for _,v in ipairs(newTechIds) do
    EnumUtils.AppendToEnum(kTechId, v)
end