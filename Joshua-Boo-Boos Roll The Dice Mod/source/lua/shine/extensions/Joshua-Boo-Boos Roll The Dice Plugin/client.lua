local Plugin = Shine.Plugin(...)
Plugin.Version = "1.0"
Plugin.HasConfig = false
Plugin.CheckConfigTypes = false
Plugin.CheckConfigRecursively = false
Plugin.DefaultState = true

local RTD_Table = {
    entId = 'string (5)'
    }
    
Shared.RegisterNetworkMessage("RTD", RTD_Table)

function Plugin:Initialise()
    Shared.ConsoleCommand( "bind F9 !rtd" )
    -- if Client then
    --     local player = Client.GetLocalPlayer()
    --     if player then
    --         Client.ConsoleCommand( "say <-- Automatic Message via Roll The Dice plugin: Press F9 to roll the dice! -->")
    --     end
    -- end
    return true
end

local function RTD()
    local player = Client.GetLocalPlayer()
    if player and player.GetIsAlive then
        if Client.GetIsControllingPlayer() then
            if (player:GetTeamNumber() == kTeam1Index or player:GetTeamNumber() == kTeam2Index) and player:GetIsAlive() then
                local id = player:GetId()
                local RTD_Data = { entId = tostring(id) }
                Client.SendNetworkMessage("RTD", RTD_Data, true)
            end
        end
    end
end

local RTD_Command = Shine:RegisterClientCommand( "!rtd", RTD )

function Plugin:Cleanup()
    Shared.ConsoleCommand( "unbind F9" )
end

return Plugin