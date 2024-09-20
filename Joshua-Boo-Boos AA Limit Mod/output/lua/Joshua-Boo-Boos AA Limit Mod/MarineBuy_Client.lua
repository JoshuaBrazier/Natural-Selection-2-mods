local max_ft = 3
local max_gl = 3
local max_hmg = 3
-- local hmg_w = 1
-- local gl_w = 2
-- local ft_w = 3

function MarineBuy_PurchaseItem(itemTechId)
    Log(string.format("Bought a %s", itemTechId))
    if itemTechId == kTechId.Flamethrower or itemTechId == kTechId.GrenadeLauncher or itemTechId == kTechId.HeavyMachineGun then
        local player = Client.GetLocalPlayer()
        if itemTechId == kTechId.Flamethrower then
            if GetHasTech(player, kTechId.Weapons3, true) then
                local ft_count
                ft_count = #GetEntitiesForTeam("Flamethrower", kTeam1Index)
                Log(string.format("FT count is %i", ft_count))
                if ft_count < max_ft then
                    Client.SendNetworkMessage("Buy", BuildBuyMessage({ itemTechId }), true)
                else
                    StartSoundEffectForPlayer(max_ft_sound, player, 1)
                end
            else
                StartSoundEffectForPlayer(w3_sound, player, 1)
            end

        elseif itemTechId == kTechId.GrenadeLauncher then
            if GetHasTech(player, kTechId.Weapons2, true) then
                local gl_count
                gl_count = #GetEntitiesForTeam("GrenadeLauncher", kTeam1Index)
                Log(string.format("GL count is %i", gl_count))
                if gl_count < max_gl then
                    Client.SendNetworkMessage("Buy", BuildBuyMessage({ itemTechId }), true)
                else
                    StartSoundEffectForPlayer(max_gl_sound, player, 1)
                end
            else
                StartSoundEffectForPlayer(w2_sound, player, 1)
            end

        elseif itemTechId == kTechId.HeavyMachineGun then
            if GetHasTech(player, kTechId.Weapons1, true) then
                local hmg_count
                hmg_count = #GetEntitiesForTeam("HeavyMachineGun", kTeam1Index)
                Log(string.format("HMG count is %i", hmg_count))
                if hmg_count < max_hmg then
                    Client.SendNetworkMessage("Buy", BuildBuyMessage({ itemTechId }), true)
                else
                    StartSoundEffectForPlayer(max_hmg_sound, player, 1)
                end
            else
                StartSoundEffectForPlayer(w1_sound, player, 1)
            end
        end
    else
        Client.SendNetworkMessage("Buy", BuildBuyMessage({ itemTechId }), true)
    end
end