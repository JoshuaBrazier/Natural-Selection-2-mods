Script.Load("lua/Joshua-Boo-Boos Flame Lerk Mod/Firebreath.lua")

local firebreath_required_bio = 1

oldLHB = Lerk.HandleButtons

function Lerk:HandleButtons(input)

    oldLHB(self, input)

    if not kCombatVersion then

        if self.check_firebreath_given_time == nil or (self.check_firebreath_given_time ~= nil and Shared.GetTime() >= self.check_firebreath_given_time + 1) then

            self.check_firebreath_given_time = Shared.GetTime()

            local hives = GetEntitiesForTeam("Hive", kTeam2Index)
            local bio_num = 0
            for i = 1, #hives do
                bio_num = bio_num + hives[i].bioMassLevel
            end

            if bio_num >= firebreath_required_bio then

                if self.given_firebreath == nil or self.given_firebreath == false then

                    if Server then

                        self:GiveItem(Firebreath.kMapName)
                        self.given_firebreath = true

                    end

                end

            end

        end

    else

        if self.check_firebreath_given_time == nil or (self.check_firebreath_given_time ~= nil and Shared.GetTime() >= self.check_firebreath_given_time + 1) then

            self.check_firebreath_given_time = Shared.GetTime()

            if self.threeHives then

                if self.given_firebreath == nil or self.given_firebreath == false then

                    if Server then

                        self:GiveItem(Firebreath.kMapName)

                    end

                end

            end

        end

    end

end