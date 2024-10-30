local oldOUP = Player.OnUpdatePlayer

function Player:OnUpdatePlayer(deltaTime)

    oldOUP(self, deltaTime)

    local weapon = self:GetActiveWeapon()

    if weapon and weapon:isa("Shotgun") then

        if weapon.tracked_target ~= 0 then
        
            weapon.time_now = Shared.GetTime()
    
            if weapon.time_now >= weapon.hit_tracker_target_at + 5 or not IsValid(Shared.GetEntity(weapon.tracked_target)) then
    
                weapon.tracked_target = 0
    
            end
    
        end

    end
    
end

local kTimePerRoll = 5

local function RTD()
    local player = Client.GetLocalPlayer()
    if player and player.GetIsAlive then
        if Client.GetIsControllingPlayer() then
            if (player:GetTeamNumber() == kTeam1Index or player:GetTeamNumber() == kTeam2Index) and player:GetIsAlive() and player.GetHealth and player:GetHealth() > 0 then
                local id = player:GetId()
                local RTD_Data = { entId = tostring(id) }
                if not player.lastCalledRTDTime then
                    player.lastCalledRTDTime = Shared.GetTime()
                    Client.SendNetworkMessage("RTD", RTD_Data, true)
                else
                    if Shared.GetTime() >= player.lastCalledRTDTime + kTimePerRoll then
                        player.lastCalledRTDTime = Shared.GetTime()
                        Client.SendNetworkMessage("RTD", RTD_Data, true)
                    end
                end
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