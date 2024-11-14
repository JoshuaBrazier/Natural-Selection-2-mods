local RTD_Table = {
    entId = 'string (5)'
    }

Shared.RegisterNetworkMessage("RTD", RTD_Table)

local dicerollSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/DiceRoll")
local enzymeSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/EnzymeSound")
local bulletsSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Bullets")
local nukeSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Nuke")
local omaewamoushindeiruSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/OMaeWaMouShindeiru")
local slapSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Slap")
local slayteamSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/SlayTeam")
local statdownSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/StatDown")
local statupSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/StatUp")
local slashSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Slash")

local tacticalNukeRollProbabilityModifier = 25

if Server then

    Server.HookNetworkMessage("RTD",
        function(client, msg)

            if IsValid(Shared.GetEntity(tonumber(msg.entId))) then
        
                local playerEntity = Shared.GetEntity(tonumber(msg.entId))

                StartSoundEffectOnEntity(dicerollSound, playerEntity)

                playerEntity:AddTimedCallback(function(playerEntity)

                                                    ::reroll::

                                                    local rolled_value = math.random(1,100)
                
                                                    if not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then

                                                        local players = GetEntities("Player")

                                                        if rolled_value == 1 or rolled_value == 100 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "tacticalNuke"

                                                                for i = 1, #players do
                                                                    if IsValid(players[i]) then
                                                                        StartSoundEffectOnEntity(slayteamSound, players[i])
                                                                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is calling in a tactical nuke!", playerEntity:GetName(), rolled_value))
                                                                    end
                                                                end

                                                                playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                    local playersToRollNukeOn = GetEntities("Player")
                                                                                                    local validPlayers = {}
                                                                                                    for i = 1, #playersToRollNukeOn do
                                                                                                        if playersToRollNukeOn[i].GetIsAlive and playersToRollNukeOn[i]:GetIsAlive() and not playersToRollNukeOn[i]:isa("MarineSpectator") and not playersToRollNukeOn[i]:isa("AlienSpectator") then
                                                                                                            table.insert(validPlayers, playersToRollNukeOn[i])
                                                                                                        end
                                                                                                    end
                                                                                                    if #validPlayers > 0 then
                                                                                                        local nukeThesePlayers = {}
                                                                                                        for i = 1, #validPlayers do
                                                                                                            local roll = math.random(1,100)
                                                                                                            if roll >= (50 - tacticalNukeRollProbabilityModifier) and roll < (50 + tacticalNukeRollProbabilityModifier) then
                                                                                                                table.insert(nukeThesePlayers, validPlayers[i])
                                                                                                            end
                                                                                                        end
                                                                                                        if #nukeThesePlayers > 0 then
                                                                                                            for i = 1, #nukeThesePlayers do
                                                                                                                StartSoundEffectAtOrigin(omaewamoushindeiruSound, nukeThesePlayers[i]:GetOrigin())
                                                                                                                nukeThesePlayers[i]:Kill()
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                            end, 5)

                                                            else

                                                                if playerEntity.rollResult == "tacticalNuke" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "tacticalNuke"

                                                                    for i = 1, #players do
                                                                        if IsValid(players[i]) then
                                                                            StartSoundEffectOnEntity(slayteamSound, players[i])
                                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is calling in a tactical nuke!", playerEntity:GetName(), rolled_value))
                                                                        end
                                                                    end

                                                                    playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                        local playersToRollNukeOn = GetEntities("Player")
                                                                                                        local validPlayers = {}
                                                                                                        for i = 1, #playersToRollNukeOn do
                                                                                                            if playersToRollNukeOn[i].GetIsAlive and playersToRollNukeOn[i]:GetIsAlive() and not playersToRollNukeOn[i]:isa("MarineSpectator") and not playersToRollNukeOn[i]:isa("AlienSpectator") then
                                                                                                                table.insert(validPlayers, playersToRollNukeOn[i])
                                                                                                            end
                                                                                                        end
                                                                                                        if #validPlayers > 0 then
                                                                                                            local nukeThesePlayers = {}
                                                                                                            for i = 1, #validPlayers do
                                                                                                                local roll = math.random(1,100)
                                                                                                                if roll >= (50 - tacticalNukeRollProbabilityModifier) and roll < (50 + tacticalNukeRollProbabilityModifier) then
                                                                                                                    table.insert(nukeThesePlayers, validPlayers[i])
                                                                                                                end
                                                                                                            end
                                                                                                            if #nukeThesePlayers > 0 then
                                                                                                                for i = 1, #nukeThesePlayers do
                                                                                                                    StartSoundEffectAtOrigin(omaewamoushindeiruSound, nukeThesePlayers[i]:GetOrigin())
                                                                                                                    nukeThesePlayers[i]:Kill()
                                                                                                                end
                                                                                                            end
                                                                                                        end
                                                                                                end, 5)

                                                                end

                                                            end
                                                            --------------------

                                                        elseif rolled_value >= 2 and rolled_value < 15 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "exoOrOnosOrNanoShieldOrUmbraRoll"

                                                                if playerEntity:GetTeamNumber() == 1 then
                                                                    if playerEntity:isa("Exo") then
                                                                        playerEntity:ActivateNanoShield()
                                                                        for i = 1, 50 do
                                                                            if IsValid(playerEntity) and playerEntity.GetIsAlive and playerEntity:GetIsAlive() then
                                                                                playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                playerEntity:ActivateNanoShield()
                                                                                                            end, i * kNanoShieldPlayerDuration)
                                                                            else
                                                                                break
                                                                            end
                                                                        end
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was perma-nanoshielded!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    else
                                                                        table.removevalue(players, playerEntity)
                                                                        local newPlayerEntity = playerEntity:Replace(Exo.kMapName, playerEntity:GetTeamNumber(), false, playerEntity:GetOrigin(), { layout = "MinigunMinigun" })
                                                                        table.insert(players, newPlayerEntity)
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became a dual minigun Exo!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    end
                                                                elseif playerEntity:GetTeamNumber() == 2 then
                                                                    if playerEntity:isa("Onos") then
                                                                        local umbraCloud = CreateEntity( CragUmbra.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                                                                        umbraCloud:SetTravelDestination( playerEntity:GetOrigin() + Vector(0, 1.5, 0) )
                                                                        for i = 1, 5 do
                                                                            playerEntity:AddTimedCallback(function(playerEntity)   
                                                                                                                local umbraCloud = CreateEntity( CragUmbra.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                                                                                                                umbraCloud:SetTravelDestination( playerEntity:GetOrigin() + Vector(0, 1.5, 0) )
                                                                                                            end, i * 3.5)
                                                                        end
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is spawning umbra!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    else
                                                                        table.removevalue(players, playerEntity)
                                                                        local newPlayerEntity = playerEntity:Replace(Onos.kMapName, playerEntity:GetTeamNumber(), nil, nil, nil)
                                                                        table.insert(players, newPlayerEntity)
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became an Onos!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    end
                                                                end

                                                            else

                                                                if playerEntity.rollResult == "exoOrOnosOrNanoShieldOrUmbraRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "exoOrOnosOrNanoShieldOrUmbraRoll"

                                                                    if playerEntity:GetTeamNumber() == 1 then
                                                                        if playerEntity:isa("Exo") then
                                                                            playerEntity:ActivateNanoShield()
                                                                            for i = 1, 50 do
                                                                                if IsValid(playerEntity) and playerEntity.GetIsAlive and playerEntity:GetIsAlive() then
                                                                                    playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                    playerEntity:ActivateNanoShield()
                                                                                                                end, i * kNanoShieldPlayerDuration)
                                                                                else
                                                                                    break
                                                                                end
                                                                            end
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was perma-nanoshielded!", playerEntity:GetName(), rolled_value))
                                                                                end
                                                                            end
                                                                        else
                                                                            table.removevalue(players, playerEntity)
                                                                            local newPlayerEntity = playerEntity:Replace(Exo.kMapName, playerEntity:GetTeamNumber(), false, playerEntity:GetOrigin(), { layout = "MinigunMinigun" })
                                                                            table.insert(players, newPlayerEntity)
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became a dual minigun Exo!", playerEntity:GetName(), rolled_value))
                                                                                end
                                                                            end
                                                                        end
                                                                    elseif playerEntity:GetTeamNumber() == 2 then
                                                                        if playerEntity:isa("Onos") then
                                                                            local umbraCloud = CreateEntity( CragUmbra.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                                                                            umbraCloud:SetTravelDestination( playerEntity:GetOrigin() + Vector(0, 1.5, 0) )
                                                                            for i = 1, 5 do
                                                                                playerEntity:AddTimedCallback(function(playerEntity)   
                                                                                                                    local umbraCloud = CreateEntity( CragUmbra.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam2Index )
                                                                                                                    umbraCloud:SetTravelDestination( playerEntity:GetOrigin() + Vector(0, 1.5, 0) )
                                                                                                                end, i * 3.5)
                                                                            end
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is spawning umbra!", playerEntity:GetName(), rolled_value))
                                                                                end
                                                                            end
                                                                        else
                                                                            table.removevalue(players, playerEntity)
                                                                            local newPlayerEntity = playerEntity:Replace(Onos.kMapName, playerEntity:GetTeamNumber(), nil, nil, nil)
                                                                            table.insert(players, newPlayerEntity)
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became an Onos!", playerEntity:GetName(), rolled_value))
                                                                                end
                                                                            end
                                                                        end
                                                                    end

                                                                end

                                                            end
                                                            ---------------------
                                                            
                                                        elseif rolled_value >= 15 and rolled_value < 20 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "nukeRoll"

                                                                StartSoundEffectOnEntity(nukeSound, playerEntity)
                                                                                                                        for i = 1, #players do
                                                                                                                            if IsValid(players[i]) then
                                                                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became a nuke!", playerEntity:GetName(), rolled_value))
                                                                                                                            end
                                                                                                                        end
                                                                                                                        playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                                                        if playerEntity.GetHealth and playerEntity:GetHealth() > 0 and not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then
                                                                                                                                                            local nearbyEnemies = nil
                                                                                                                                                            local nearbyAliveEnemies = {}
                                                                                                                                                            if playerEntity:GetTeamNumber() == 1 then
                                                                                                                                                                nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam2Index, playerEntity:GetOrigin(), 15)
                                                                                                                                                            elseif playerEntity:GetTeamNumber() == 2 then
                                                                                                                                                                nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam1Index, playerEntity:GetOrigin(), 15)
                                                                                                                                                            end
                                                                                                                                                            players = GetEntities("Player")
                                                                                                                                                            for i = 1, #nearbyEnemies do
                                                                                                                                                                if not nearbyEnemies[i]:isa("MarineSpectator") and not nearbyEnemies[i]:isa("AlienSpectator") and nearbyEnemies[i].GetIsAlive and nearbyEnemies[i]:GetIsAlive() and nearbyEnemies[i].GetHealth and nearbyEnemies[i]:GetHealth() > 0 then
                                                                                                                                                                    table.insert(nearbyAliveEnemies, nearbyEnemies[i])
                                                                                                                                                                end
                                                                                                                                                            end
                                                                                                                                                            if #nearbyAliveEnemies > 0 then
                                                                                                                                                                for i = 1, #players do
                                                                                                                                                                    if IsValid(players[i]) then
                                                                                                                                                                        if #nearbyAliveEnemies == 1 then
                                                                                                                                                                            players[i]:SendDirectMessage(string.format("Player %s nuked 1 enemy!", playerEntity:GetName()))
                                                                                                                                                                        elseif #nearbyAliveEnemies > 1 then
                                                                                                                                                                            players[i]:SendDirectMessage(string.format("Player %s nuked %i enemies!", playerEntity:GetName(), #nearbyAliveEnemies))
                                                                                                                                                                        end
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                                for i = 1, #nearbyAliveEnemies do
                                                                                                                                                                    if IsValid(nearbyAliveEnemies[i]) then
                                                                                                                                                                        nearbyAliveEnemies[i]:Kill()
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                            else
                                                                                                                                                                for i = 1, #players do
                                                                                                                                                                    if IsValid(players[i]) then
                                                                                                                                                                        players[i]:SendDirectMessage(string.format("Player %s nuked no enemies!", playerEntity:GetName()))
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                            end
                                                                                                                                                            playerEntity:Kill()
                                                                                                                                                        end
                                                                                                                                                    end, 5)

                                                            else

                                                                if playerEntity.rollResult == "nukeRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "nukeRoll"

                                                                    StartSoundEffectOnEntity(nukeSound, playerEntity)
                                                                                                                        for i = 1, #players do
                                                                                                                            if IsValid(players[i]) then
                                                                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became a nuke!", playerEntity:GetName(), rolled_value))
                                                                                                                            end
                                                                                                                        end
                                                                                                                        playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                                                        if playerEntity.GetHealth and playerEntity:GetHealth() > 0 and not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then
                                                                                                                                                            local nearbyEnemies = nil
                                                                                                                                                            local nearbyAliveEnemies = {}
                                                                                                                                                            if playerEntity:GetTeamNumber() == 1 then
                                                                                                                                                                nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam2Index, playerEntity:GetOrigin(), 15)
                                                                                                                                                            elseif playerEntity:GetTeamNumber() == 2 then
                                                                                                                                                                nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam1Index, playerEntity:GetOrigin(), 15)
                                                                                                                                                            end
                                                                                                                                                            players = GetEntities("Player")
                                                                                                                                                            for i = 1, #nearbyEnemies do
                                                                                                                                                                if not nearbyEnemies[i]:isa("MarineSpectator") and not nearbyEnemies[i]:isa("AlienSpectator") and nearbyEnemies[i].GetIsAlive and nearbyEnemies[i]:GetIsAlive() and nearbyEnemies[i].GetHealth and nearbyEnemies[i]:GetHealth() > 0 then
                                                                                                                                                                    table.insert(nearbyAliveEnemies, nearbyEnemies[i])
                                                                                                                                                                end
                                                                                                                                                            end
                                                                                                                                                            if #nearbyAliveEnemies > 0 then
                                                                                                                                                                for i = 1, #players do
                                                                                                                                                                    if IsValid(players[i]) then
                                                                                                                                                                        if #nearbyAliveEnemies == 1 then
                                                                                                                                                                            players[i]:SendDirectMessage(string.format("Player %s nuked 1 enemy!", playerEntity:GetName()))
                                                                                                                                                                        elseif #nearbyAliveEnemies > 1 then
                                                                                                                                                                            players[i]:SendDirectMessage(string.format("Player %s nuked %i enemies!", playerEntity:GetName(), #nearbyAliveEnemies))
                                                                                                                                                                        end
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                                for i = 1, #nearbyAliveEnemies do
                                                                                                                                                                    if IsValid(nearbyAliveEnemies[i]) then
                                                                                                                                                                        nearbyAliveEnemies[i]:Kill()
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                            else
                                                                                                                                                                for i = 1, #players do
                                                                                                                                                                    if IsValid(players[i]) then
                                                                                                                                                                        players[i]:SendDirectMessage(string.format("Player %s nuked no enemies!", playerEntity:GetName()))
                                                                                                                                                                    end
                                                                                                                                                                end
                                                                                                                                                            end
                                                                                                                                                            playerEntity:Kill()
                                                                                                                                                        end
                                                                                                                                                    end, 5)

                                                                end

                                                            end
                                                            --------------------

                                                        elseif rolled_value >= 20 and rolled_value < 35 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "catalystPackOrEnzymeRoll"

                                                                if playerEntity:GetTeamNumber() == 1 then
                                                                    if not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then
                                                                        CreateEntity(CatPack.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam1Index)
                                                                    end
                                                                    for i = 1, 7 do
                                                                        playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                            if Server then
                                                                                                                if not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then
                                                                                                                    CreateEntity(CatPack.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam1Index)
                                                                                                                end
                                                                                                            end
                                                                                                        end, i * 3.5)
                                                                    end
                                                                    for i = 1, #players do
                                                                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is receiving some catalyst packs!", playerEntity:GetName(), rolled_value))
                                                                    end
                                                                elseif playerEntity:GetTeamNumber() == 2 then
                                                                    playerEntity:TriggerEnzyme(30)
                                                                    StartSoundEffectOnEntity(enzymeSound, playerEntity)
                                                                    for i = 1, #players do
                                                                        if IsValid(players[i]) then
                                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is enzymed for 30 seconds!", playerEntity:GetName(), rolled_value))
                                                                        end
                                                                    end
                                                                end

                                                            else

                                                                if playerEntity.rollResult == "catalystPackOrEnzymeRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "catalystPackOrEnzymeRoll"

                                                                    if playerEntity:GetTeamNumber() == 1 then
                                                                        if not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then
                                                                            CreateEntity(CatPack.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam1Index)
                                                                        end
                                                                        for i = 1, 7 do
                                                                            playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                if Server then
                                                                                                                    if not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then
                                                                                                                        CreateEntity(CatPack.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam1Index)
                                                                                                                    end
                                                                                                                end
                                                                                                            end, i * 3.5)
                                                                        end
                                                                        for i = 1, #players do
                                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is receiving some catalyst packs!", playerEntity:GetName(), rolled_value))
                                                                        end
                                                                    elseif playerEntity:GetTeamNumber() == 2 then
                                                                        playerEntity:TriggerEnzyme(30)
                                                                        StartSoundEffectOnEntity(enzymeSound, playerEntity)
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is enzymed for 30 seconds!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    end

                                                                end

                                                            end
                                                            --------------------

                                                        elseif rolled_value >= 35 and rolled_value < 40 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "slaySelfRoll"

                                                                StartSoundEffectOnEntity(slashSound, playerEntity)
                                                                                                                        playerEntity:Kill()
                                                                                                                        for i = 1, #players do
                                                                                                                            if IsValid(players[i]) then
                                                                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was slayed!", playerEntity:GetName(), rolled_value))
                                                                                                                            end
                                                                                                                        end

                                                            else

                                                                if playerEntity.rollResult == "slaySelfRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "slaySelfRoll"

                                                                    StartSoundEffectOnEntity(slashSound, playerEntity)
                                                                                                                        playerEntity:Kill()
                                                                                                                        for i = 1, #players do
                                                                                                                            if IsValid(players[i]) then
                                                                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was slayed!", playerEntity:GetName(), rolled_value))
                                                                                                                            end
                                                                                                                        end

                                                                end

                                                            end
                                                            --------------------

                                                        elseif rolled_value >= 40 and rolled_value < 50 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "lowHPOrAPRoll"

                                                                StartSoundEffectOnEntity(statdownSound, playerEntity)
                                                                                                                        if playerEntity:isa("Exo") then
                                                                                                                            local currentMaxAPBeforeCallback = playerEntity:GetMaxArmor()
                                                                                                                            local currentAPBeforeCallback = playerEntity:GetArmor()
                                                                                                                            playerEntity:SetArmor(1)
                                                                                                                            playerEntity:SetMaxArmor(1)
                                                                                                                            playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                                                                playerEntity:SetMaxArmor(currentMaxAPBeforeCallback)
                                                                                                                                                                playerEntity:SetArmor(currentAPBeforeCallback)
                                                                                                                                                        end, 9.5)
                                                                                                                            for i = 1, #players do
                                                                                                                                if IsValid(players[i]) then
                                                                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max AP = 1 for 10 seconds!", playerEntity:GetName(), rolled_value))
                                                                                                                                end
                                                                                                                            end
                                                                                                                        else
                                                                                                                            local currentMaxHPBeforeCallback = playerEntity:GetMaxHealth()
                                                                                                                            local currentHPBeforeCallback = playerEntity:GetHealth()
                                                                                                                            playerEntity:SetHealth(1)
                                                                                                                            playerEntity:SetMaxHealth(1)
                                                                                                                            playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                                                                playerEntity:SetMaxHealth(currentMaxHPBeforeCallback)
                                                                                                                                                                playerEntity:SetHealth(currentHPBeforeCallback)
                                                                                                                                                        end, 9.5)
                                                                                                                            for i = 1, #players do
                                                                                                                                if IsValid(players[i]) then
                                                                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max HP = 1 for 10 seconds!", playerEntity:GetName(), rolled_value))
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end

                                                            else

                                                                if playerEntity.rollResult == "lowHPOrAPRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "lowHPOrAPRoll"

                                                                    StartSoundEffectOnEntity(statdownSound, playerEntity)
                                                                                                                        if playerEntity:isa("Exo") then
                                                                                                                            local currentMaxAPBeforeCallback = playerEntity:GetMaxArmor()
                                                                                                                            local currentAPBeforeCallback = playerEntity:GetArmor()
                                                                                                                            playerEntity:SetArmor(1)
                                                                                                                            playerEntity:SetMaxArmor(1)
                                                                                                                            playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                                                                playerEntity:SetMaxArmor(currentMaxAPBeforeCallback)
                                                                                                                                                                playerEntity:SetArmor(currentAPBeforeCallback)
                                                                                                                                                        end, 9.5)
                                                                                                                            for i = 1, #players do
                                                                                                                                if IsValid(players[i]) then
                                                                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max AP = 1 for 10 seconds!", playerEntity:GetName(), rolled_value))
                                                                                                                                end
                                                                                                                            end
                                                                                                                        else
                                                                                                                            local currentMaxHPBeforeCallback = playerEntity:GetMaxHealth()
                                                                                                                            local currentHPBeforeCallback = playerEntity:GetHealth()
                                                                                                                            playerEntity:SetHealth(1)
                                                                                                                            playerEntity:SetMaxHealth(1)
                                                                                                                            playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                                                                playerEntity:SetMaxHealth(currentMaxHPBeforeCallback)
                                                                                                                                                                playerEntity:SetHealth(currentHPBeforeCallback)
                                                                                                                                                        end, 9.5)
                                                                                                                            for i = 1, #players do
                                                                                                                                if IsValid(players[i]) then
                                                                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max HP = 1 for 10 seconds!", playerEntity:GetName(), rolled_value))
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end

                                                                end

                                                            end
                                                            --------------------
                                                            
                                                        elseif rolled_value >= 50 and rolled_value < 65 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "slapSelfRoll"

                                                                if playerEntity:isa("Exo") then
                                                                    StartSoundEffectOnEntity(statdownSound, playerEntity)
                                                                    local currentAPMax = playerEntity:GetMaxArmor()
                                                                    if playerEntity.GetArmor then
                                                                        if playerEntity:GetArmor() - 0.1666666666 * currentAPMax <= 0 then
                                                                            playerEntity:Kill()
                                                                        else
                                                                            playerEntity:SetArmor(playerEntity:GetArmor() - 0.1666666666 * currentAPMax)
                                                                            for i = 1, 2 do
                                                                                playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                if playerEntity.GetArmor then
                                                                                                                    if playerEntity:GetArmor() - 0.1666666666 * currentAPMax <= 0 then
                                                                                                                        playerEntity:Kill()
                                                                                                                    else
                                                                                                                        playerEntity:SetArmor(playerEntity:GetArmor() - 0.1666666666 * currentAPMax)
                                                                                                                    end
                                                                                                                end
                                                                                                            end, 1.25 * i)
                                                                            end
                                                                        end
                                                                    end
                                                                    for i = 1, #players do
                                                                        if IsValid(players[i]) then
                                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is being slapped (%.1f AP per slap)!", playerEntity:GetName(), rolled_value, 0.1666666666 * currentAPMax))
                                                                        end
                                                                    end
                                                                else
                                                                    StartSoundEffectOnEntity(slapSound, playerEntity)
                                                                    playerEntity:SetHealth(math.max(0, playerEntity:GetHealth() - 0.25 * playerEntity:GetMaxHealth()))
                                                                    if playerEntity:GetHealth() == 0 then
                                                                        if playerEntity:GetIsAlive() then
                                                                            playerEntity:Kill()
                                                                        end
                                                                    end
                                                                    for i = 1, #players do
                                                                        if IsValid(players[i]) then
                                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was slapped for %.1f HP damage!", playerEntity:GetName(), rolled_value, 0.25 * playerEntity:GetMaxHealth()))
                                                                        end
                                                                    end
                                                                end

                                                            else

                                                                if playerEntity.rollResult == "slapSelfRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "slapSelfRoll"

                                                                    if playerEntity:isa("Exo") then
                                                                        StartSoundEffectOnEntity(statdownSound, playerEntity)
                                                                        local currentAPMax = playerEntity:GetMaxArmor()
                                                                        if playerEntity.GetArmor then
                                                                            if playerEntity:GetArmor() - 0.1666666666 * currentAPMax <= 0 then
                                                                                playerEntity:Kill()
                                                                            else
                                                                                playerEntity:SetArmor(playerEntity:GetArmor() - 0.1666666666 * currentAPMax)
                                                                                for i = 1, 2 do
                                                                                    playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                    if playerEntity.GetArmor then
                                                                                                                        if playerEntity:GetArmor() - 0.1666666666 * currentAPMax <= 0 then
                                                                                                                            playerEntity:Kill()
                                                                                                                        else
                                                                                                                            playerEntity:SetArmor(playerEntity:GetArmor() - 0.1666666666 * currentAPMax)
                                                                                                                        end
                                                                                                                    end
                                                                                                                end, 1.25 * i)
                                                                                end
                                                                            end
                                                                        end
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is being slapped (%.1f AP per slap)!", playerEntity:GetName(), rolled_value, 0.1666666666 * currentAPMax))
                                                                            end
                                                                        end
                                                                    else
                                                                        StartSoundEffectOnEntity(slapSound, playerEntity)
                                                                        playerEntity:SetHealth(math.max(0, playerEntity:GetHealth() - 0.25 * playerEntity:GetMaxHealth()))
                                                                        if playerEntity:GetHealth() == 0 then
                                                                            if playerEntity:GetIsAlive() then
                                                                                playerEntity:Kill()
                                                                            end
                                                                        end
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was slapped for %.1f HP damage!", playerEntity:GetName(), rolled_value, 0.25 * playerEntity:GetMaxHealth()))
                                                                            end
                                                                        end
                                                                    end

                                                                end

                                                            end
                                                            --------------------

                                                        elseif rolled_value >= 65 and rolled_value < 85 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "slapEnemyRoll"

                                                                if playerEntity:GetTeamNumber() == 1 then
                                                                    local playersToCheck = GetEntitiesForTeam("Player", kTeam2Index)
                                                                    local enemies = {}
                                                                    for i = 1, #playersToCheck do
                                                                        if playersToCheck[i]:GetIsAlive() then
                                                                            table.insert(enemies, playersToCheck[i])
                                                                        end
                                                                    end
                                                                    if #enemies > 0 then
                                                                        local randomRollEnemies = math.random(1, #enemies)
                                                                        enemyToSlap = enemies[randomRollEnemies]
                                                                        for i = 1, 5 do
                                                                            enemyToSlap:AddTimedCallback(function(enemyToSlap)
                                                                                                            
                                                                                                            if enemyToSlap.GetIsAlive and enemyToSlap:GetIsAlive() and enemyToSlap.GetArmor then
                                                                                                                if enemyToSlap:GetArmor() <= 0.225 * enemyToSlap:GetMaxArmor() then
                                                                                                                    StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                    enemyToSlap:Kill()
                                                                                                                else
                                                                                                                    StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                    enemyToSlap:SetHealth(enemyToSlap:GetArmor() - 0.225 * enemyToSlap:GetMaxArmor())
                                                                                                                end
                                                                                                            end
                                                                                                        end, 0.80 * i)
                                                                        end
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slapped a bunch!", playerEntity:GetName(), rolled_value, enemyToSlap:GetName()))
                                                                            end
                                                                        end
                                                                    else
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slap around!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    end
                                                                elseif playerEntity:GetTeamNumber() == 2 then
                                                                    local playersToCheck = GetEntitiesForTeam("Player", kTeam1Index)
                                                                    local enemies = {}
                                                                    for i = 1, #playersToCheck do
                                                                        if playersToCheck[i]:GetIsAlive() then
                                                                            table.insert(enemies, playersToCheck[i])
                                                                        end
                                                                    end
                                                                    if #enemies > 0 then
                                                                        local randomRollEnemies = math.random(1, #enemies)
                                                                        enemyToSlap = enemies[randomRollEnemies]
                                                                        for i = 1, 5 do
                                                                            enemyToSlap:AddTimedCallback(function(enemyToSlap)
                                                                                                            if not enemyToSlap:isa("Exo") then
                                                                                                                if enemyToSlap.GetIsAlive and enemyToSlap:GetIsAlive() and enemyToSlap.GetHealth then
                                                                                                                    if enemyToSlap:GetHealth() <= 0.249 * enemyToSlap:GetMaxHealth() then
                                                                                                                        StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                        enemyToSlap:Kill()
                                                                                                                    else
                                                                                                                        StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                        enemyToSlap:SetHealth(enemyToSlap:GetHealth() - 0.198 * enemyToSlap:GetMaxHealth())
                                                                                                                    end
                                                                                                                end
                                                                                                            else
                                                                                                                if enemyToSlap.GetIsAlive and enemyToSlap:GetIsAlive() and enemyToSlap.GetArmor then
                                                                                                                    if enemyToSlap:GetArmor() <= 0.249 * enemyToSlap:GetMaxArmor() then
                                                                                                                        StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                        enemyToSlap:Kill()
                                                                                                                    else
                                                                                                                        StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                        enemyToSlap:SetHealth(enemyToSlap:GetArmor() - 0.198 * enemyToSlap:GetMaxArmor())
                                                                                                                    end
                                                                                                                end
                                                                                                            end
                                                                                                        end, 0.80 * i)
                                                                        end
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slapped a bunch!", playerEntity:GetName(), rolled_value, enemyToSlap:GetName()))
                                                                            end
                                                                        end
                                                                    else
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slap around!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    end
                                                                end

                                                            else

                                                                if playerEntity.rollResult == "slapEnemyRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "slapEnemyRoll"

                                                                    if playerEntity:GetTeamNumber() == 1 then
                                                                        local playersToCheck = GetEntitiesForTeam("Player", kTeam2Index)
                                                                        local enemies = {}
                                                                        for i = 1, #playersToCheck do
                                                                            if playersToCheck[i]:GetIsAlive() then
                                                                                table.insert(enemies, playersToCheck[i])
                                                                            end
                                                                        end
                                                                        if #enemies > 0 then
                                                                            local randomRollEnemies = math.random(1, #enemies)
                                                                            enemyToSlap = enemies[randomRollEnemies]
                                                                            for i = 1, 5 do
                                                                                enemyToSlap:AddTimedCallback(function(enemyToSlap)
                                                                                                                
                                                                                                                if enemyToSlap.GetIsAlive and enemyToSlap:GetIsAlive() and enemyToSlap.GetArmor then
                                                                                                                    if enemyToSlap:GetArmor() <= 0.225 * enemyToSlap:GetMaxArmor() then
                                                                                                                        StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                        enemyToSlap:Kill()
                                                                                                                    else
                                                                                                                        StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                        enemyToSlap:SetHealth(enemyToSlap:GetArmor() - 0.225 * enemyToSlap:GetMaxArmor())
                                                                                                                    end
                                                                                                                end
                                                                                                            end, 0.80 * i)
                                                                            end
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slapped a bunch!", playerEntity:GetName(), rolled_value, enemyToSlap:GetName()))
                                                                                end
                                                                            end
                                                                        else
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slap around!", playerEntity:GetName(), rolled_value))
                                                                                end
                                                                            end
                                                                        end
                                                                    elseif playerEntity:GetTeamNumber() == 2 then
                                                                        local playersToCheck = GetEntitiesForTeam("Player", kTeam1Index)
                                                                        local enemies = {}
                                                                        for i = 1, #playersToCheck do
                                                                            if playersToCheck[i]:GetIsAlive() then
                                                                                table.insert(enemies, playersToCheck[i])
                                                                            end
                                                                        end
                                                                        if #enemies > 0 then
                                                                            local randomRollEnemies = math.random(1, #enemies)
                                                                            enemyToSlap = enemies[randomRollEnemies]
                                                                            for i = 1, 5 do
                                                                                enemyToSlap:AddTimedCallback(function(enemyToSlap)
                                                                                                                if not enemyToSlap:isa("Exo") then
                                                                                                                    if enemyToSlap.GetIsAlive and enemyToSlap:GetIsAlive() and enemyToSlap.GetHealth then
                                                                                                                        if enemyToSlap:GetHealth() <= 0.249 * enemyToSlap:GetMaxHealth() then
                                                                                                                            StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                            enemyToSlap:Kill()
                                                                                                                        else
                                                                                                                            StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                            enemyToSlap:SetHealth(enemyToSlap:GetHealth() - 0.198 * enemyToSlap:GetMaxHealth())
                                                                                                                        end
                                                                                                                    end
                                                                                                                else
                                                                                                                    if enemyToSlap.GetIsAlive and enemyToSlap:GetIsAlive() and enemyToSlap.GetArmor then
                                                                                                                        if enemyToSlap:GetArmor() <= 0.249 * enemyToSlap:GetMaxArmor() then
                                                                                                                            StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                            enemyToSlap:Kill()
                                                                                                                        else
                                                                                                                            StartSoundEffectOnEntity(slapSound, enemyToSlap)
                                                                                                                            enemyToSlap:SetHealth(enemyToSlap:GetArmor() - 0.198 * enemyToSlap:GetMaxArmor())
                                                                                                                        end
                                                                                                                    end
                                                                                                                end
                                                                                                            end, 0.80 * i)
                                                                            end
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slapped a bunch!", playerEntity:GetName(), rolled_value, enemyToSlap:GetName()))
                                                                                end
                                                                            end
                                                                        else
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slap around!", playerEntity:GetName(), rolled_value))
                                                                                end
                                                                            end
                                                                        end
                                                                    end

                                                                end

                                                            end
                                                            --------------------

                                                        elseif rolled_value >= 85 and rolled_value <= 99 then

                                                            --------------------
                                                            if not playerEntity.rollResult then

                                                                playerEntity.rollResult = "ammoOrAPorHPRoll"

                                                                if playerEntity:GetTeamNumber() == 1 then
                                                                    if not playerEntity:isa("Exo") then
                                                                        StartSoundEffectOnEntity(bulletsSound, playerEntity, 0.55)
                                                                        local weapons = playerEntity:GetWeapons()
                                                                        for i = 1, #weapons do
                                                                            if weapons[i]:isa("ClipWeapon") then
                                                                                weapons[i].clip = 10 * weapons[i]:GetClipSize()
                                                                                weapons[i].ammo = 0
                                                                            end
                                                                        end
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their clip-weapons have ten clips of ammo in one and no spare ammo!", playerEntity:GetName(), rolled_value))
                                                                            end
                                                                        end
                                                                    else
                                                                        StartSoundEffectOnEntity(statupSound, playerEntity)
                                                                        local oldMaxAP = playerEntity:GetMaxArmor()
                                                                        local oldAP = playerEntity:GetArmor()
                                                                        playerEntity:SetMaxArmor(math.min(playerEntity:GetMaxArmor() * 2.5, 900))
                                                                        playerEntity:SetArmor(playerEntity:GetMaxArmor())
                                                                        playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                            playerEntity:SetArmor(oldAP)
                                                                                                            playerEntity:SetMaxArmor(oldMaxAP)
                                                                                                    end, 9.5)
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their AP and max AP was set to %.1f for 10 seconds!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxArmor()))
                                                                            end
                                                                        end
                                                                    end
                                                                    
                                                                elseif playerEntity:GetTeamNumber() == 2 then
                                                                    StartSoundEffectOnEntity(statupSound, playerEntity)
                                                                    local oldMaxHP = playerEntity:GetMaxHealth()
                                                                    local oldHP = playerEntity:GetHealth()
                                                                    playerEntity:SetMaxHealth(math.min(playerEntity:GetMaxHealth() * 2.5, 2750))
                                                                    playerEntity:SetHealth(playerEntity:GetMaxHealth())
                                                                    playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                        playerEntity:SetHealth(oldHP)
                                                                                                        playerEntity:SetMaxHealth(oldMaxHP)
                                                                                                end, 9.5)
                                                                    for i = 1, #players do
                                                                        if IsValid(players[i]) then
                                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their HP and max HP was set to %.1f for 10 seconds!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxHealth()))
                                                                        end
                                                                    end
                                                                end

                                                            else

                                                                if playerEntity.rollResult == "ammoOrAPorHPRoll" then

                                                                    goto reroll

                                                                else

                                                                    playerEntity.rollResult = "ammoOrAPorHPRoll"

                                                                    if playerEntity:GetTeamNumber() == 1 then
                                                                        if not playerEntity:isa("Exo") then
                                                                            StartSoundEffectOnEntity(bulletsSound, playerEntity, 0.55)
                                                                            local weapons = playerEntity:GetWeapons()
                                                                            for i = 1, #weapons do
                                                                                if weapons[i]:isa("ClipWeapon") then
                                                                                    weapons[i].clip = 10 * weapons[i]:GetClipSize()
                                                                                    weapons[i].ammo = 0
                                                                                end
                                                                            end
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their clip-weapons have ten clips of ammo in one and no spare ammo!", playerEntity:GetName(), rolled_value))
                                                                                end
                                                                            end
                                                                        else
                                                                            StartSoundEffectOnEntity(statupSound, playerEntity)
                                                                            local oldMaxAP = playerEntity:GetMaxArmor()
                                                                            local oldAP = playerEntity:GetArmor()
                                                                            playerEntity:SetMaxArmor(math.min(playerEntity:GetMaxArmor() * 2.5, 900))
                                                                            playerEntity:SetArmor(playerEntity:GetMaxArmor())
                                                                            playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                                playerEntity:SetArmor(oldAP)
                                                                                                                playerEntity:SetMaxArmor(oldMaxAP)
                                                                                                        end, 9.5)
                                                                            for i = 1, #players do
                                                                                if IsValid(players[i]) then
                                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their AP and max AP was set to %.1f for 10 seconds!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxArmor()))
                                                                                end
                                                                            end
                                                                        end
                                                                        
                                                                    elseif playerEntity:GetTeamNumber() == 2 then
                                                                        StartSoundEffectOnEntity(statupSound, playerEntity)
                                                                        local oldMaxHP = playerEntity:GetMaxHealth()
                                                                        local oldHP = playerEntity:GetHealth()
                                                                        playerEntity:SetMaxHealth(math.min(playerEntity:GetMaxHealth() * 2.5, 2750))
                                                                        playerEntity:SetHealth(playerEntity:GetMaxHealth())
                                                                        playerEntity:AddTimedCallback(function(playerEntity)
                                                                                                            playerEntity:SetHealth(oldHP)
                                                                                                            playerEntity:SetMaxHealth(oldMaxHP)
                                                                                                    end, 9.5)
                                                                        for i = 1, #players do
                                                                            if IsValid(players[i]) then
                                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their HP and max HP was set to %.1f for 10 seconds!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxHealth()))
                                                                            end
                                                                        end
                                                                    end

                                                                end

                                                            end
                                                            --------------------

                                                        end
                                            
                                                    end

                                            end, 1)

            end
        end)

end