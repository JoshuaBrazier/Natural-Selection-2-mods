local RTD_Table = {
    entId = 'string (5)'
    }

local RTD_Server_Relay_Table = {
    entId = 'string (5)',
    newXP = 'float',
    newLvl = 'integer'
    }
Shared.RegisterNetworkMessage("RTD", RTD_Table)

Shared.RegisterNetworkMessage("RTD_Server_Relay", RTD_Server_Relay_Table)

if Server then

    Server.HookNetworkMessage("RTD",
        function(client, msg)
            
            -- Shared.Message("SERVER REGISTERED RTD REQUEST")

            local rolled_value = math.random(1,5)

            local players = GetEntities("Player")
        
            local playerEntity = Shared.GetEntity(tonumber(msg.entId))

            if rolled_value == 1 then
                if playerEntity:GetLvl() < 20 then
                    local gainedXP = math.ceil(0.5 * (Experience_XpForLvl(playerEntity:GetLvl()+1) - Experience_XpForLvl(playerEntity:GetLvl())))
                    local RTD_New_XP = playerEntity:GetXp() + gainedXP
                    playerEntity.score = RTD_New_XP
                    playerEntity.combatTable.lvl = playerEntity:GetLvl()
                
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a 1 and got %.1f XP!", playerEntity:GetName(), gainedXP))
                    end
                else
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a 1 but is already level 20!", playerEntity:GetName(), gainedXP))
                    end
                end
            elseif rolled_value == 2 then
                local level = playerEntity:GetLvl()
                if level == 1 then
                    local currentXp = playerEntity:GetXp()
                    if currentXp < 0.5 * Experience_XpForLvl(2) then
                        local lostXp = currentXp
                        playerEntity.score = 0
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s (level 1) rolled a 2 and lost %.1f XP!", playerEntity:GetName(), lostXp))
                        end
                    elseif currentXp >= 0.5 * Experience_XpForLvl(2) then
                        playerEntity.score = playerEntity:GetXp() - 0.5 * Experience_XpForLvl(2)
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s (level 1) rolled a 2 and lost %.1f XP!", playerEntity:GetName(), 0.5 * Experience_XpForLvl(2)))
                        end
                    end
                elseif level > 1 and level < 20 then
                    local lostXp = (Experience_XpForLvl(playerEntity:GetLvl()+1) - Experience_XpForLvl(playerEntity:GetLvl()))
                    playerEntity.score = player:GetXp() - lostXp
                    playerEntity.combatTable.lvl = playerEntity:GetLvl()
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s (level %i) rolled a 2 and lost %.1f XP!", playerEntity:GetName(), playerEntity:GetLvl(), lostXp))
                    end
                elseif level == 20 then
                    playerEntity.score = playerEntity:GetXp() - 500
                    playerEntity.combatTable.lvl = playerEntity:GetLvl()
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s (level 20) rolled a 2 and lost 500 XP!", playerEntity:GetName()))
                    end
                end
            elseif rolled_value == 3 then
                playerEntity:Kill()
                for i = 1, #players do
                    players[i]:SendDirectMessage(string.format("Player %s rolled a 3 and was slayed!", playerEntity:GetName()))
                end
            elseif rolled_value == 4 then
                playerEntity:SetHealth(1)
                playerEntity:SetMaxHealth(1)
                for i = 1, #players do
                    players[i]:SendDirectMessage(string.format("Player %s rolled a 4 and now has max HP = 1!", playerEntity:GetName()))
                end
            elseif rolled_value == 5 then
                playerEntity:SetHealth(math.max(0, playerEntity:GetHealth() - 25))
                if playerEntity:GetHealth() == 0 then
                    if playerEntity:GetIsAlive() then
                        playerEntity:Kill()
                    end
                end
                for i = 1, #players do
                    players[i]:SendDirectMessage(string.format("Player %s rolled a 5 and was slapped for 25 damage!", playerEntity:GetName()))
                end
            end
        end)

end