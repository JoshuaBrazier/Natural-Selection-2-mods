local RTD_Table = {
    entId = 'string (5)'
    }

Shared.RegisterNetworkMessage("RTD", RTD_Table)

local bulletsSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Bullets")
local nukeSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Nuke")
local omaewamoushindeiruSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/OMaeWaMouShindeiru")
local slapSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Slap")
local slayteamSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/SlayTeam")
local statdownSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/StatDown")
local statupSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/StatUp")
local slashSound = PrecacheAsset("sound/RollTheDice.fev/RollTheDice/Slash")

if Server then

    Server.HookNetworkMessage("RTD",
    function(client, msg)

        ::reroll::

        local rolled_value = math.random(1,100)

        local players = GetEntities("Player")
    
        local playerEntity = Shared.GetEntity(tonumber(msg.entId))

        playerEntity:AddTimedCallback(function(playerEntity)
        
                                            if not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then

                                                players = GetEntities("Player")

                                                if rolled_value == 1 then
                                                    local enemies = {}
                                                    if playerEntity:GetTeamNumber() == 1 then
                                                        local enemyAliens = GetEntitiesForTeam("Player", kTeam2Index)
                                                        for i = 1, #enemyAliens do
                                                            table.insert(enemies, enemyAliens[i])
                                                        end
                                                    elseif playerEntity:GetTeamNumber() == 2 then
                                                        local enemyMarines = GetEntitiesForTeam("Player", kTeam1Index)
                                                        for i = 1, #enemyMarines do
                                                            table.insert(enemies, enemyAliens[i])
                                                        end
                                                    end
                                                    if #enemies > 0 then
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                StartSoundEffectOnEntity(slayteamSound, players[i])
                                                                players[i]:SendDirectMessage(string.format("Player %s luckily rolled a 1 and slayed the whole enemy team!", playerEntity:GetName()))
                                                            end
                                                        end
                                                        for i = 1, #enemies do
                                                            if IsValid(players[i]) then
                                                                enemies[i]:Kill()
                                                            end
                                                        end
                                                    else
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                players[i]:SendDirectMessage(string.format("Player %s luckily rolled a 1 but there are no enemy players!", playerEntity:GetName()))
                                                            end
                                                        end
                                                    end
                                                elseif rolled_value >= 2 and rolled_value < 15 then
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
                                                elseif rolled_value >= 15 and rolled_value < 25 then
                                                    StartSoundEffectOnEntity(nukeSound, playerEntity)
                                                    for i = 1, #players do
                                                        if IsValid(players[i]) then
                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became a nuke!", playerEntity:GetName(), rolled_value))
                                                        end
                                                    end
                                                    playerEntity:AddTimedCallback(function(playerEntity)
                                                                                    if playerEntity.GetHealth and playerEntity:GetHealth() > 0 and not playerEntity:isa("MarineSpectator") and not playerEntity:isa("AlienSpectator") then
                                                                                        local nearbyEnemies = nil
                                                                                        local nearbyAliveEnemies = nil
                                                                                        if playerEntity:GetTeamNumber() == 1 then
                                                                                            nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam2Index, playerEntity:GetOrigin(), 15)
                                                                                        elseif playerEntity:GetTeamNumber() == 2 then
                                                                                            nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam1Index, playerEntity:GetOrigin(), 15)
                                                                                        end
                                                                                        players = GetEntities("Player")
                                                                                        for i = 1, #nearbyEnemies do
                                                                                            if not nearbyEnemies[i]:isa("MarineSpectator") and not nearbyEnemies[i]:isa("AlienSpectator") and nearbyEnemies[i].GetIsAlive and nearbyEnemies[i]:GetIsAlive and nearbyEnemies[i].GetHealth and nearbyEnemies[i]:GetHealth() > 0 then
                                                                                                table.insert(nearbyAliveEnemies nearbyEnemies[i])
                                                                                            end
                                                                                        end
                                                                                        if nearbyAliveEnemies ~= nil then
                                                                                            if #nearbyAliveEnemies > 0 then
                                                                                                for i = 1, #players do
                                                                                                    if IsValid(players[i]) then
                                                                                                        if #nearbyAliveEnemies == 1 then
                                                                                                            players[i]:SendDirectMessage(string.format("Player %s nuked 1 enemy!", playerEntity:GetName()))
                                                                                                        elseif #nearbyAliveEnemies > 1 then
                                                                                                            players[i]:SendDirectMessage(string.format("Player %s nuked %i enemies!", playerEntity:GetName(), #nearbyEnemies))
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
                                                                                                        players[i]:SendDirectMessage(string.format("Player %s nuked no enemies!", playerEntity:GetName(), #nearbyEnemies))
                                                                                                    end
                                                                                                end
                                                                                            end
                                                                                        else
                                                                                            for i = 1, #players do
                                                                                                if IsValid(players[i]) then
                                                                                                    players[i]:SendDirectMessage(string.format("Player %s nuked no enemies!", playerEntity:GetName(), #nearbyEnemies))
                                                                                                end
                                                                                            end
                                                                                        end
                                                                                        playerEntity:Kill()
                                                                                    end
                                                                                end, 5)
                                                elseif rolled_value >= 25 and rolled_value < 40 then
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
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is enzymed for 30 seconds!", playerEntity:GetName(), rolled_value))
                                                            end
                                                        end
                                                    end
                                                elseif rolled_value >= 40 and rolled_value < 45 then
                                                    StartSoundEffectOnEntity(slashSound, playerEntity)
                                                    playerEntity:Kill()
                                                    for i = 1, #players do
                                                        if IsValid(players[i]) then
                                                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was slayed!", playerEntity:GetName(), rolled_value))
                                                        end
                                                    end
                                                elseif rolled_value >= 45 and rolled_value < 55 then
                                                    StartSoundEffectOnEntity(statdownSound, playerEntity)
                                                    if playerEntity:isa("Exo") then
                                                        playerEntity:SetArmor(1)
                                                        playerEntity:SetMaxArmor(1)
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max AP = 1!", playerEntity:GetName(), rolled_value))
                                                            end
                                                        end
                                                    else
                                                        playerEntity:SetHealth(1)
                                                        playerEntity:SetMaxHealth(1)
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max HP = 1!", playerEntity:GetName(), rolled_value))
                                                            end
                                                        end
                                                    end
                                                elseif rolled_value >= 55 and rolled_value < 70 then
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
                                                elseif rolled_value >= 70 and rolled_value < 85 then
                                                    local enemyToSlay = nil
                                                    if playerEntity:GetTeamNumber() == 1 then
                                                        local playersToCheck = GetEntitiesForTeam("Player", kTeam2Index)
                                                        local enemies = {}
                                                        for i = 1, #playersToCheck do
                                                            if playersToCheck[i]:GetIsAlive() then
                                                                table.insert(enemies, playersToCheck[i])
                                                            end
                                                        end
                                                        if #enemies > 0 then
                                                            StartSoundEffectOnEntity(slashSound, playerEntity)
                                                            local randomRollEnemies = math.random(1, #enemies)
                                                            enemyToSlay = enemies[randomRollEnemies]
                                                            for i = 1, #players do
                                                                if IsValid(players[i]) then
                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slayed!", playerEntity:GetName(), rolled_value, enemyToSlay:GetName()))
                                                                end
                                                            end
                                                        else
                                                            for i = 1, #players do
                                                                if IsValid(players[i]) then
                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slay!", playerEntity:GetName(), rolled_value))
                                                                end
                                                            end
                                                        end
                                                        if enemyToSlay ~= nil then
                                                            if enemyToSlay.GetHealth and enemyToSlay:GetHealth() > 0 and not enemyToSlay:isa("MarineSpectator") and not enemyToSlay:isa("AlienSpectator") then
                                                                StartSoundEffectAtOrigin(slashSound, enemyToSlay:GetOrigin())
                                                            end
                                                            enemyToSlay:AddTimedCallback(function(enemyToSlay)
                                                                                            if enemyToSlay.GetHealth and enemyToSlay:GetHealth() > 0 and not enemyToSlay:isa("MarineSpectator") and not enemyToSlay:isa("AlienSpectator") then
                                                                                                enemyToSlay:Kill()
                                                                                            end
                                                                                        end, 0.35)
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
                                                            StartSoundEffectOnEntity(slashSound, playerEntity)
                                                            local randomRollEnemies = math.random(1, #enemies)
                                                            enemyToSlay = enemies[randomRollEnemies]
                                                            for i = 1, #players do
                                                                if IsValid(players[i]) then
                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slayed!", playerEntity:GetName(), rolled_value, enemyToSlay:GetName()))
                                                                end
                                                            end
                                                        else
                                                            for i = 1, #players do
                                                                if IsValid(players[i]) then
                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slay!", playerEntity:GetName(), rolled_value))
                                                                end
                                                            end
                                                        end
                                                        if enemyToSlay ~= nil then
                                                            StartSoundEffectAtOrigin(slashSound, enemyToSlay:GetOrigin())
                                                            enemyToSlay:Kill()
                                                        end
                                                    end
                                                elseif rolled_value >= 85 and rolled_value <= 99 then
                                                    if playerEntity:GetTeamNumber() == 1 then
                                                        if not playerEntity:isa("Exo") then
                                                            StartSoundEffectOnEntity(bulletsSound, playerEntity)
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
                                                            playerEntity:SetMaxArmor(math.min(playerEntity:GetMaxArmor() * 2.5, 2044))
                                                            playerEntity:SetArmor(playerEntity:GetMaxArmor())
                                                            for i = 1, #players do
                                                                if IsValid(players[i]) then
                                                                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their AP and max AP was set to %.1f!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxArmor()))
                                                                end
                                                            end
                                                        end
                                                        
                                                    elseif playerEntity:GetTeamNumber() == 2 then
                                                        StartSoundEffectOnEntity(statupSound, playerEntity)
                                                        playerEntity:SetMaxHealth(math.min(playerEntity:GetMaxHealth() * 2.5, 8190))
                                                        playerEntity:SetHealth(playerEntity:GetMaxHealth())
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their HP and max HP was set to %.1f!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxHealth()))
                                                            end
                                                        end
                                                    end
                                                elseif rolled_value == 100 then
                                                    local friendlies = {}
                                                    if playerEntity:GetTeamNumber() == 1 then
                                                        local friendlyMarines = GetEntitiesForTeam("Player", kTeam1Index)
                                                        for i = 1, #friendlyMarines do
                                                            table.insert(friendlies, friendlyMarines[i])
                                                        end
                                                    elseif playerEntity:GetTeamNumber() == 2 then
                                                        local friendlyAliens = GetEntitiesForTeam("Player", kTeam2Index)
                                                        for i = 1, #friendlyAliens do
                                                            table.insert(friendlies, friendlyAliens[i])
                                                        end
                                                    end
                                                    if #friendlies > 0 then
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                StartSoundEffectOnEntity(slayteamSound, players[i])
                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a 100 and slayed their whole team!", playerEntity:GetName()))
                                                            end
                                                        end
                                                        for i = 1, #friendlies do
                                                            friendlies[i]:Kill()
                                                        end
                                                    else
                                                        for i = 1, #players do
                                                            if IsValid(players[i]) then
                                                                players[i]:SendDirectMessage(string.format("Player %s rolled a 100 and there are no enemies to slay!", playerEntity:GetName()))
                                                            end
                                                        end
                                                    end
                                                end
                                    
                                            end

                                    end, 1)

    end)

end