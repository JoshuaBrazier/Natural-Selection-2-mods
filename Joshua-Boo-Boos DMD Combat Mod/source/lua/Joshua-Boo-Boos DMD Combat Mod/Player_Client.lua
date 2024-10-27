local oldOUP = Player.OnUpdatePlayer

function Player:OnUpdatePlayer(deltaTime)

    oldOUP(self, deltaTime)

    local weapon = self:GetActiveWeapon()

    if weapon and weapon:isa("Shotgun") then

        if weapon.tracked_target ~= 0 then
        
            weapon.time_now = Shared.GetTime()
    
            if weapon.time_now >= weapon.hit_tracker_target_at + 5 or not IsValid(Shared.GetEntity(weapon.tracked_target)) then
    
                weapon.tracked_target = 0
    
            end
    
        end

    end
    
end