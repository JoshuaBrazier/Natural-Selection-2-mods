local oldArmoryGetItemList = Armory.GetItemList
function Armory:GetItemList(forPlayer)

    local itemList = oldArmoryGetItemList(self, forPlayer)

    table.insert(itemList, kTechId.Mac10)

    return itemList
    
end

local oldAdvancedArmoryGetItemList = AdvancedArmory.GetItemList
function AdvancedArmory:GetItemList(forPlayer)

    local itemList = oldAdvancedArmoryGetItemList(self, forPlayer)

	if self:GetTechId() == kTechId.AdvancedArmory then
        table.insert(itemList, kTechId.Mac10)
    end

	return itemList

end