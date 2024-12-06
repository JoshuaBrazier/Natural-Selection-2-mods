local oldOnKill = Onos.OnKill
function Onos:OnKill()
    if kCombatVersion then
        if Server then
            local bonewall = CreateEntity(BoneWall.kMapName, self:GetOrigin(), kTeam2Index)
            bonewall:SetOwner(self)
        end
    end
    oldOnKill(self)
end