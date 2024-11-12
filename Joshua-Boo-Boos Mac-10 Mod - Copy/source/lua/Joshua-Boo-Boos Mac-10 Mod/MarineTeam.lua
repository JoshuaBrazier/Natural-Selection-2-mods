local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)

    self.techTree:AddTargetedBuyNode(kTechId.Mac10,              kTechId.AdvancedWeaponry,   kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropMac10,       kTechId.Armory,             kTechId.ShotgunTech)

    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end