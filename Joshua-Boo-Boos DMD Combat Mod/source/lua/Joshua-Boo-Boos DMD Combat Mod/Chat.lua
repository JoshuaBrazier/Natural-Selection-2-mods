function ChatUI_SubmitChatMessageBody(chatMessage)

    -- Quote string so spacing doesn't come through as multiple arguments
    if chatMessage ~= nil and string.len(chatMessage) > 0 then
    
        chatMessage = string.UTF8Sub(chatMessage, 1, kMaxChatLength)

        Client.SendNetworkMessage("ChatClient", BuildChatClientMessage(teamOnlyChat, chatMessage), true)
        
        teamOnlyChat = false
        
    end
    
    enteringChatMessage = false
    
    SetMoveInputBlocked(false)

    if not Shine then

        if Client then
            if chatMessage == "!rtd" then
                local player = Client.GetLocalPlayer()
                if player and player.GetIsAlive then
                    if player:GetIsAlive() then
                        local id = player:GetId()
                        local RTD_Data = { entId = tostring(id) }
                        Client.SendNetworkMessage("RTD", RTD_Data, true)

                        -- Shared.Message("CLIENT SENT NETWORK MESSAGE RTD WITH ID " .. player:GetId())
                    end

                end

            end
        end

    end
    
end