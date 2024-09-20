Script.Load("lua/Joshua-Boo-Boos Bouncing Bullet Mod/Bullet.lua")

local rifle_rise_amount = 0.02 -- 0.035
local rifle_sideways_amount = 10000000 -- 10000000

local move_right_amount = 0.035
local move_upwards_amount = -0.02
local move_forward_amount = 0.07

local function FireBullets(self, player)

    PROFILE("FireBullets")

    if player.GetActiveWeapon and player:GetActiveWeapon() and not (player:GetActiveWeapon():isa("Rifle") or player:GetActiveWeapon():isa("HeavyMachineGun")) then

        local viewAngles = player:GetViewAngles()
        local shootCoords = viewAngles:GetCoords()
        
        -- Filter ourself out of the trace so that we don't hit ourselves.
        local filter = EntityFilterTwo(player, self)
        local range = self:GetRange()
        
        local numberBullets = self:GetBulletsPerShot()
        local startPoint = player:GetEyePos()
        local bulletSize = self:GetBulletSize()
        
        for bullet = 1, numberBullets do
        
            local spreadDirection = self:CalculateSpreadDirection(shootCoords, player)
            
            local endPoint = startPoint + spreadDirection * range
            local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, bulletSize, filter)        
            local damage = self:GetBulletDamage()

            HandleHitregAnalysis(player, startPoint, endPoint, trace)        

            local direction = (trace.endPoint - startPoint):GetUnit()
            local hitOffset = direction * kHitEffectOffset
            local impactPoint = trace.endPoint - hitOffset
            local effectFrequency = self:GetTracerEffectFrequency()
            local showTracer = math.random() < effectFrequency

            local numTargets = #targets
            
            if numTargets == 0 then
                self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
            end
            
            if Client and showTracer then
                TriggerFirstPersonTracer(self, impactPoint)
            end
            
            for i = 1, numTargets do

                local target = targets[i]
                local hitPoint = hitPoints[i]

                self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)
                
                local client = Server and player:GetClient() or Client
                if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                    RegisterHitEvent(player, bullet, startPoint, trace, damage)
                end
            
            end
            
        end

    elseif player.GetActiveWeapon and player:GetActiveWeapon() then

        if player:GetActiveWeapon():isa("Rifle") then

            -- local view_direction = player:GetViewAngles():GetCoords().zAxis
            -- local trace_ray = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + 100 * GetNormalizedVector(view_direction), CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
            -- if trace_ray ~= 1 then

            --     if trace_ray.entity then
            --         self:DoDamage(self:GetBulletDamage(), trace_ray.entity, trace_ray.entity:GetOrigin(), nil)
            --     end
                
            -- end
            
            -- if Client and player == Client.GetLocalPlayer() then

            --     Client.SetPitch(Client.GetPitch() - 0.0225)
            --     Client.SetYaw(Client.GetYaw() + (math.random(-8000000, 8000000)/1000000000))

            -- end

            if Server then
                
                local player_view_coords = player:GetViewAngles():GetCoords()
                local spawn_location = player:GetEyePos() + (- move_right_amount * player_view_coords.xAxis) + (move_upwards_amount * player_view_coords.yAxis) + (move_forward_amount * player_view_coords.zAxis)
                local bullet = CreateEntity(Bullet.kMapName, spawn_location, kTeam1Index)
                bullet.owner_id = player:GetId()
                bullet.final_direction_vector = GetNormalizedVector(player:GetViewAngles():GetCoords().zAxis)
                SetAnglesFromVector(bullet, bullet.final_direction_vector)

            end
            
            if Client and player == Client.GetLocalPlayer() then

                Client.SetPitch(Client.GetPitch() - rifle_rise_amount)
                Client.SetYaw(Client.GetYaw() + (math.random(-rifle_sideways_amount, rifle_sideways_amount)/1000000000))

            end


        elseif player:GetActiveWeapon():isa("HeavyMachineGun") then

            -- local view_direction = player:GetViewAngles():GetCoords().zAxis
            -- local trace_ray = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + 100 * GetNormalizedVector(view_direction), CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
            -- if trace_ray ~= 1 then

            --     if trace_ray.entity then
            --         self:DoDamage(self:GetBulletDamage(), trace_ray.entity, trace_ray.entity:GetOrigin(), nil)
            --     end
                
            -- end
            
            if Server then
                
                local player_view_coords = player:GetViewAngles():GetCoords()
                local spawn_location = player:GetEyePos() + (-0.085 * player_view_coords.xAxis) + (0.95 * player_view_coords.zAxis)
                local bullet = CreateEntity(Bullet.kMapName, spawn_location, kTeam1Index)
                bullet.owner_id = player:GetId()
                bullet.final_direction_vector = GetNormalizedVector(player:GetViewAngles():GetCoords().zAxis)
                SetAnglesFromVector(bullet, bullet.final_direction_vector)

            end
            
            if Client and player == Client.GetLocalPlayer() then

                Client.SetPitch(Client.GetPitch() - rifle_rise_amount)
                Client.SetYaw(Client.GetYaw() + (math.random(-rifle_sideways_amount, rifle_sideways_amount)/1000000000))

            end

        end

    end
    
end

function ClipWeapon:FirePrimary(player)
    self.fireTime = Shared.GetTime()
    FireBullets(self, player)
end