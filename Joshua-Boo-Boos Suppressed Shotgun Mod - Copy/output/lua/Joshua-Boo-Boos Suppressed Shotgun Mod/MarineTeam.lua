local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)

    self.techTree:AddTargetedBuyNode(kTechId.SuppressedShotgun,              kTechId.AdvancedWeaponry,   kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.DropSuppressedShotgun,       kTechId.Armory,             kTechId.ShotgunTech)

    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end