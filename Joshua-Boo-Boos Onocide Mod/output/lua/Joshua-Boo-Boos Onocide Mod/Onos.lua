Script.Load("lua/Joshua-Boo-Boos Onocide Mod/Onocide.lua")

oldOHB = Onos.HandleButtons

function Onos:HandleButtons(input)

    oldOHB(self, input)

    if not self.activated_onocide and bit.band(input.commands, Move.Reload) ~= 0 then

        if not kCombatVersion then

            local hives = GetEntitiesForTeam("Hive", kTeam2Index)
            local bio_num = 0
            for i = 1, #hives do
                bio_num = bio_num + hives[i].bioMassLevel
            end

            if bio_num >= 8 then
            
                self.activated_onocide = true
                self.has_onocide = false
                local weps = self:GetWeapons()
                for i = 1, #weps do
                    if weps[i]:isa("Onocide") then
                        self:SetActiveWeapon(weps[i])
                        self.has_onocide = true
                        break
                    end
                end
                if not self.has_onocide then
                    if Server then
                        self:GiveItem(Onocide.kMapName)
                    end
                    local weps_new = self:GetWeapons()
                    for i = 1, #weps_new do
                        if weps_new[i]:isa("Onocide") then
                            self:SetActiveWeapon(weps_new[i])
                            break
                        end
                    end
                end
                self:PrimaryAttack()

            end

        else

            if self.threeHives then
            
                self.activated_onocide = true
                self.has_onocide = false
                local weps = self:GetWeapons()
                for i = 1, #weps do
                    if weps[i]:isa("Onocide") then
                        self:SetActiveWeapon(weps[i])
                        self.has_onocide = true
                        break
                    end
                end
                if not self.has_onocide then
                    if Server then
                        self:GiveItem(Onocide.kMapName)
                    end
                    local weps_new = self:GetWeapons()
                    for i = 1, #weps_new do
                        if weps_new[i]:isa("Onocide") then
                            self:SetActiveWeapon(weps_new[i])
                            break
                        end
                    end
                end
                self:PrimaryAttack()

            end

        end
        
    end

end