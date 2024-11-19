local function printTable(t, indent)
    indent = indent or ""  -- Initialize indent if not provided
    local result = "{\n"   -- Start with an opening brace and newline
    for k, v in pairs(t) do
        local keyString = indent .. "  " .. tostring(k) .. " = "  -- Format the key
        if type(v) == "table" then
            -- If the value is a table, recursively call printTable
            result = result .. keyString .. printTable(v, indent .. "  ") .. "\n"
        else
            -- Otherwise, just append the value
            result = result .. keyString .. tostring(v) .. ",\n"
        end
    end
    result = result .. indent .. "}"  -- Close the table with an indentation
    return result
end

if Server then
    function NS2Gamerules:SetGameState(state)
    
        if state ~= self.gameState then
        
            self.gameState = state
            self.gameInfo:SetState(state)
            self.timeGameStateChanged = Shared.GetTime()
            self.timeSinceGameStateChanged = 0
            
            if self.gameState == kGameState.Started then
                
                self.gameStartTime = Shared.GetTime()
                
                self.gameInfo:SetStartTime(self.gameStartTime)
                
                SendTeamMessage(self.team1, kTeamMessageTypes.GameStarted)
                SendTeamMessage(self.team2, kTeamMessageTypes.GameStarted)
                
            end
            
            -- On end game, check for map switch conditions
            if state == kGameState.Team1Won or state == kGameState.Team2Won then
            
                if MapCycle_TestCycleMap() then
                    self.timeToCycleMap = Shared.GetTime() + kPauseToSocializeBeforeMapcycle
                else
                    self.timeToCycleMap = nil
                end

                if CHUDGetLastRoundStats then
                    local JoshuaBooBoosRoundStats = CHUDGetLastRoundStats()
                    
                    if JoshuaBooBoosRoundStats then

                        if next(JoshuaBooBoosRoundStats) == nil then
                            Shared.Message("No Stats Gathered By NS2+ - Commander Stats Mod")
                            return
                        end

                        -- local file = io.open("Commander_Win_Rate_Stats_Requested_By_Fari.txt", "r+")
                        -- local lineCount = 0
                        -- for line in file:lines() do
                        --     lineCount = lineCount + 1
                        -- end
                        -- lineCount = lineCount - 1
                        -- if file then
                        --     local data = {}
                        --     for i = 1, lineCount % 3 do
                        --         local play
                        --         for j = 3 * i, 3 * i + 2 do
                        --             file:write()
                        -- else
                        --     file = io.open("Commander_Win_Rate_Stats_Requested_By_Fari.txt", "w")
                        -- end

                        if JoshuaBooBoosRoundStats.PlayerStats and JoshuaBooBoosRoundStats.PlayerStats ~= nil then

                            local file = io.open("../../Text_Data.txt", "r+")
                            if not file then
                                file = io.open("../../Text_Data.txt", "w")
                            end
                            file:write(printTable(JoshuaBooBoosRoundStats.PlayerStats))
                            file:close()
                            
                            Shared.Message(printTable(JoshuaBooBoosRoundStats.PlayerStats))

                            -- Shared.Message("Number of PlayerStats entries is: " .. tostring(#JoshuaBooBoosRoundStats.PlayerStats))

                            -- for i = 1, #JoshuaBooBoosRoundStats.PlayerStats do

                            --     Shared.Message("i is: " .. tostring(i))

                            --     for key, value in pairs(JoshuaBooBoosRoundStats.PlayerStats) do

                            --         Shared.Message("key is: " .. tostring(key))

                            --         local commanderTime = "0"

                            --         local classTypes = value.status
                            --         for j = 1, #classTypes do

                            --             if tostring(classTypes[j].statusId) == "Commander" then

                            --                 commanderTime = tonumber(classTypes[j].classTime)
                                        
                            --             end

                            --         end

                            --         Shared.Message("Player with ID: " .. tostring(key) .. " and name: " .. tostring(value.playerName) .. " played commander for: " .. tostring(commanderTime) .. " seconds.")

                            --     end

                            -- end
                            
                        end

                    end

                end
                
            end
            
        end
        
    end
end

-- local NS2PlusStats = CHUDGetLastRoundStats()
--         -- Dump(NS2PlusStats)
--         if next(NS2PlusStats) == nil then
--             if (verbose) then
--                 Shared.Message(" Wonitor: No data gathered for this round")
--             end
--             return
--         end

--         local data = {}
--         data.RoundInfo       = NS2PlusStats.RoundInfo
--         data.Locations       = NS2PlusStats.Locations
--         data.MarineCommStats = NS2PlusStats.MarineCommStats
--         data.ServerInfo      = NS2PlusStats.ServerInfo
--         data.PlayerStats     = NS2PlusStats.PlayerStats
--         local Research       = NS2PlusStats.Research
--         local Buildings      = NS2PlusStats.Buildings
--         local KillFeed       = NS2PlusStats.KillFeed