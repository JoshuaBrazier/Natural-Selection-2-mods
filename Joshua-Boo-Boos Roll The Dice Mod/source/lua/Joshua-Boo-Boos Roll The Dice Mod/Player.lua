local newNetworkVars = {lastCalledRTDTime = 'time'}

local oldPlayerOEC = Player.OnEntityChange

function Player:OnEntityChange(oldEntityId, newEntityId)

    local oldEntity = nil
    local newEntity = nil

    if oldEntityId and oldEntityId ~= nil then
        oldEntity = Shared.GetEntity(oldEntityId)
    end
    if newEntityId and newEntityId ~= nil then
        newEntity = Shared.GetEntity(newEntityId)
    end
    if oldEntityId and newEntityId and oldEntityId ~= nil and newEntityId ~= nil and oldEntity ~= nil and newEntity ~= nil and oldEntity ~= newEntity then
        newEntity.lastCalledRTDTime = oldEntity.lastCalledRTDTime
    end
    
    oldPlayerOEC(self, oldEntityId, newEntityId)

end

Shared.LinkClassToMap("Player", Player.kMapName, newNetworkVars)