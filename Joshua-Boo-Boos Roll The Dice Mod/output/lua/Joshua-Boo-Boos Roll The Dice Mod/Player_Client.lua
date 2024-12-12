local kTimePerRoll = 15

local function RTD()
    local player = Client.GetLocalPlayer()
    if player and player.GetIsAlive then
        if Client.GetIsControllingPlayer() then
            if (player:GetTeamNumber() == kTeam1Index or player:GetTeamNumber() == kTeam2Index) and player.GetIsAlive and player:GetIsAlive() and player.GetHealth and player:GetHealth() > 0 and not player:isa("Embryo") and not player:isa("Egg") and not player:isa("MarineSpectator") and not player:isa("AlienSpectator") then
                local id = player:GetId()
                local RTD_Data = { entId = tostring(id), rollTime = Shared.GetTime()} 
                Client.SendNetworkMessage("RTD", RTD_Data, true)
            end
        end
    end
end

local oldPlayer_SendKeyEvent = Player.SendKeyEvent
function Player:SendKeyEvent(key, down)
    
    oldPlayer_SendKeyEvent(self, key, down)
    
    if not ChatUI_EnteringChatMessage() and not MainMenu_GetIsOpened() then
        
        if GetIsBinding(key, "RollTheDice") then
            RTD()
        end

    end
    
end