ModLoader.SetupFileHook( "lua/Chat.lua", "lua/Joshua-Boo-Boos Roll The Dice Mod/Chat.lua", "post" )
ModLoader.SetupFileHook( "lua/NetworkMessages.lua", "lua/Joshua-Boo-Boos Roll The Dice Mod/NetworkMessages.lua", "post" )

if Shine then
    ModLoader.SetupFileHook( "lua/shine/extensions/chatbox/client.lua", "lua/Joshua-Boo-Boos Roll The Dice Mod/client.lua", "post" )
end