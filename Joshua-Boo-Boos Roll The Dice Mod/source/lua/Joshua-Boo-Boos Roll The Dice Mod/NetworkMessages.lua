local RTD_Table = {
    entId = 'string (5)'
    }

Shared.RegisterNetworkMessage("RTD", RTD_Table)

if Server then

    Server.HookNetworkMessage("RTD",
    function(client, msg)
            
        -- Shared.Message("SERVER REGISTERED RTD REQUEST")

        ::reroll::

        local rolled_value = math.random(1,100)

        local players = GetEntities("Player")
    
        local playerEntity = Shared.GetEntity(tonumber(msg.entId))

        playerEntity:AddTimedCallback(function(playerEntity)
            if rolled_value == 1 then
                local enemies = {}
                if playerEntity:GetTeamNumber() == 1 then
                    local enemyAliens = GetEntitiesForTeam("Player", kTeam2Index)
                    for i = 1, #enemyAliens do
                        table.insert(enemies, enemyAliens[i])
                    end
                elseif playerEntity:GetTeamNumber() == 2 then
                    local enemyMarines = GetEntitiesForTeam("Player", kTeam1Index)
                    for j = 1, #enemyMarines do
                        table.insert(enemies, enemyAliens[j])
                    end
                end
                if #enemies > 0 then
                    for k = 1, #players do
                        players[k]:SendDirectMessage(string.format("Player %s luckily rolled a 1 and slayed the whole enemy team!", playerEntity:GetName()))
                    end
                    for l = 1, #enemies do
                        enemies[l]:Kill()
                    end
                else
                    for m = 1, #players do
                        players[m]:SendDirectMessage(string.format("Player %s luckily rolled a 1 but there are no enemy players!", playerEntity:GetName()))
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
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was perma-nanoshielded!", playerEntity:GetName(), rolled_value))
                        end
                    else
                        table.removevalue(players, playerEntity)
                        local newPlayerEntity = playerEntity:Replace(Exo.kMapName, playerEntity:GetTeamNumber(), false, playerEntity:GetOrigin(), { layout = "MinigunMinigun" })
                        table.insert(players, newPlayerEntity)
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became a dual minigun Exo!", playerEntity:GetName(), rolled_value))
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
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is spawning umbra!", playerEntity:GetName(), rolled_value))
                        end
                    else
                        table.removevalue(players, playerEntity)
                        local newPlayerEntity = playerEntity:Replace(Onos.kMapName, playerEntity:GetTeamNumber(), nil, nil, nil)
                        table.insert(players, newPlayerEntity)
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became an Onos!", playerEntity:GetName(), rolled_value))
                        end
                    end
                end
            elseif rolled_value >= 15 and rolled_value < 25 then
                for i = 1, #players do
                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and became a nuke!", playerEntity:GetName(), rolled_value))
                end
                playerEntity:AddTimedCallback(function(playerEntity)
                                                local nearbyEnemies = nil
                                                if playerEntity:GetTeamNumber() == 1 then
                                                    nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam2Index, playerEntity:GetOrigin(), 15)
                                                elseif playerEntity:GetTeamNumber() == 2 then
                                                    nearbyEnemies = GetEntitiesForTeamWithinRange("Player", kTeam1Index, playerEntity:GetOrigin(), 15)
                                                end
                                                players = GetEntities("Player")
                                                if nearbyEnemies ~= nil then
                                                    if #nearbyEnemies > 0 then
                                                        for i = 1, #players do
                                                            players[i]:SendDirectMessage(string.format("Player %s nuked an enemy / enemies!", playerEntity:GetName(), #nearbyEnemies))
                                                        end
                                                        for i = 1, #nearbyEnemies do
                                                            nearbyEnemies[i]:Kill()
                                                        end
                                                    else
                                                        for i = 1, #players do
                                                            players[i]:SendDirectMessage(string.format("Player %s nuked no enemies!", playerEntity:GetName(), #nearbyEnemies))
                                                        end
                                                    end
                                                else
                                                    for i = 1, #players do
                                                        players[i]:SendDirectMessage(string.format("Player %s nuked no enemies!", playerEntity:GetName(), #nearbyEnemies))
                                                    end
                                                end
                                                playerEntity:Kill()
                                            end, 5)
            elseif rolled_value >= 25 and rolled_value < 40 then
                if playerEntity:GetTeamNumber() == 1 then
                    CreateEntity(CatPack.kMapName, playerEntity:GetOrigin() + Vector(0, 0.4, 0), kTeam1Index)
                    for i = 1, 10 do
                        playerEntity:AddTimedCallback(function(playerEntity)
                                                            if Server then
                                                                CreateEntity(CatPack.kMapName, playerEntity:GetOrigin() + Vector(0, 0.5, 0), kTeam1Index)
                                                            end
                                                        end, i * 3.75)
                    end
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is receiving some catalyst packs!", playerEntity:GetName(), rolled_value))
                    end
                elseif playerEntity:GetTeamNumber() == 2 then
                    playerEntity:TriggerEnzyme(30)
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and is enzymed for 30 seconds!", playerEntity:GetName(), rolled_value))
                    end
                end
            elseif rolled_value >= 40 and rolled_value < 45 then
                playerEntity:Kill()
                for i = 1, #players do
                    players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was slayed!", playerEntity:GetName(), rolled_value))
                end
            elseif rolled_value >= 45 and rolled_value < 55 then
                if playerEntity:isa("Exo") then
                    playerEntity:SetArmor(1)
                    playerEntity:SetMaxArmor(1)
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max AP = 1!", playerEntity:GetName(), rolled_value))
                    end
                else
                    playerEntity:SetHealth(1)
                    playerEntity:SetMaxHealth(1)
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and now has max HP = 1!", playerEntity:GetName(), rolled_value))
                    end
                end
            elseif rolled_value >= 55 and rolled_value < 70 then
                if playerEntity:isa("Exo") then
                    local bonewall = CreateEntity(BoneWall.kMapName, playerEntity:GetOrigin(), kTeam2Index)
                    bonewall:SetOwner(playerEntity)
                    for i = 1, 2 do
                        playerEntity:AddTimedCallback(function(playerEntity)
                                                        local bonewall = CreateEntity(BoneWall.kMapName, playerEntity:GetOrigin(), kTeam2Index)
                                                        bonewall:SetOwner(playerEntity)
                                                    end, i)
                    end
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and will be bonewalled 3 times!", playerEntity:GetName(), rolled_value))
                    end
                else
                    playerEntity:SetHealth(math.max(0, playerEntity:GetHealth() - 0.25 * playerEntity:GetMaxHealth()))
                    if playerEntity:GetHealth() == 0 then
                        if playerEntity:GetIsAlive() then
                            playerEntity:Kill()
                        end
                    end
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and was slapped for %.1f HP damage!", playerEntity:GetName(), rolled_value, 0.25 * playerEntity:GetMaxHealth()))
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
                        local randomRollEnemies = math.random(1, #enemies)
                        enemyToSlay = enemies[randomRollEnemies]
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slayed!", playerEntity:GetName(), rolled_value, enemyToSlay:GetName()))
                        end
                    else
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slay!", playerEntity:GetName(), rolled_value))
                        end
                    end
                    if enemyToSlay ~= nil then
                        enemyToSlay:Kill()
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
                        enemyToSlay = enemies[randomRollEnemies]
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and caused %s to be slayed!", playerEntity:GetName(), rolled_value, enemyToSlay:GetName()))
                        end
                    else
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and there are no alive enemies to slay!", playerEntity:GetName(), rolled_value))
                        end
                    end
                    if enemyToSlay ~= nil then
                        enemyToSlay:Kill()
                    end
                end
            elseif rolled_value >= 85 and rolled_value <= 99 then
                if playerEntity:GetTeamNumber() == 1 then
                    if not playerEntity:isa("Exo") then
                        local weapons = playerEntity:GetWeapons()
                        for i = 1, #weapons do
                            if weapons[i]:isa("ClipWeapon") then
                                weapons[i].clip = 10 * weapons[i]:GetClipSize()
                                weapons[i].ammo = 0
                            end
                        end
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their clip-weapons have ten clips of ammo in one and no spare ammo!", playerEntity:GetName(), rolled_value))
                        end
                    else
                        playerEntity:SetMaxArmor(playerEntity:GetMaxArmor() * 2.5)
                        playerEntity:SetArmor(playerEntity:GetMaxArmor())
                        for i = 1, #players do
                            players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their AP and max AP was set to %.1f!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxArmor()))
                        end
                    end
                    
                elseif playerEntity:GetTeamNumber() == 2 then
                    playerEntity:SetMaxHealth(playerEntity:GetMaxHealth() * 2.5)
                    playerEntity:SetHealth(playerEntity:GetMaxHealth())
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a %i and their HP and max HP was set to %.1f!", playerEntity:GetName(), rolled_value, playerEntity:GetMaxHealth()))
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
                    for j = 1, #friendlyAliens do
                        table.insert(friendlies, friendlyAliens[j])
                    end
                end
                if #friendlies > 0 then
                    for k = 1, #friendlies do
                        friendlies[k]:Kill()
                    end
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a 100 and slayed their whole team!", playerEntity:GetName()))
                    end
                else
                    for i = 1, #players do
                        players[i]:SendDirectMessage(string.format("Player %s rolled a 100 and there are no enemies to slay!", playerEntity:GetName()))
                    end
                end
            end
        end, 0.5)

    end)

end