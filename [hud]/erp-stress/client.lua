local currSpeed, justIncreased, increaseShooting, increaseMelee, increaseWalking, ped, increaseStill = 0, false, false, false, false, nil, false
local isPilot = false

CreateThread(function()
    Wait(100)
    LocalPlayer.state:set('stressLevel', 1, true)
    LocalPlayer.state:set('thirstLevel', 5000, true)
    LocalPlayer.state:set('hungerLevel', 5000, true)
end)


RegisterNetEvent("updatestress")
AddEventHandler("updatestress",function(amount, silent)
    if LocalPlayer.state.virtual then return end 
    if amount == 0 or amount == nil then print("Something went wrong with stress, either I got a nil value or 0.") return end;
    local silent = silent or false
    local currStress = LocalPlayer.state.stressLevel or 0
    local newStress = currStress + amount
    if newStress <= 0 then
        newStress = 1;
    elseif newStress > 10000 then
        newStress = 10000
    end
    LocalPlayer.state:set('stressLevel', newStress, true)
    local type = (amount > 0 and 1) or (amount == 0 and 0) or -1
    if type == 1 and not silent then
        exports['erp_notifications']:SendAlert('inform', 'Stress Gained', 6000)
    elseif type == -1 and not silent then
        exports['erp_notifications']:SendAlert('inform', 'Stress Relieved', 6000)
    end

end)

CreateThread(function()
    while true do
        ped = PlayerPedId()
        Wait(2500)
    end
end)

local isShooting = IsPedShooting(ped)
local inCombat = IsPedInMeleeCombat(ped)
local isStill = IsPedStill(ped)
local Armed = IsPedArmed(ped, 6)
local running = IsPedRunning(ped)

CreateThread(function()
    while true do 
        Wait(0)
        isShooting = IsPedShooting(ped)
        inCombat = IsPedInMeleeCombat(ped)
        isStill = IsPedStill(ped)
        Armed = IsPedArmed(ped, 6)
        running = IsPedRunning(ped)
        if IsPedBeingStunned(ped, 0) then SetPedMinGroundTimeForStungun(ped, 6000) end
    end
end)

CreateThread(function()
    Wait(500)
    while true do
        if LocalPlayer.state.stressLevel > 10000 then
            if math.random(1, 10) == math.random(3, 8) then
                if math.random(1,3) == 1 then
                    AnimpostfxPlay('DrugsTrevorClownsFightIn', 0, false)
                    Wait(2500)
                    AnimpostfxStop('DrugsTrevorClownsFightIn')
                    AnimpostfxPlay('DrugsTrevorClownsFight', 0, false)
                    Wait(5000)
                    AnimpostfxStop('DrugsTrevorClownsFight')
                    AnimpostfxPlay('DrugsTrevorClownsFightOut', 0, false)
                    Wait(2500)
                    AnimpostfxStop('DrugsTrevorClownsFightOut')
                elseif math.random(1,3) == 2 then
                    AnimpostfxPlay('DrugsMichaelAliensFightIn', 0, false)
                    Wait(2500)
                    AnimpostfxStop('DrugsMichaelAliensFightIn')
                    AnimpostfxPlay('DrugsMichaelAliensFight', 0, false)
                    Wait(5000)
                    AnimpostfxStop('DrugsMichaelAliensFight')
                    AnimpostfxPlay('DrugsMichaelAliensFightOut', 0, false)
                    Wait(2500)
                    AnimpostfxStop('DrugsMichaelAliensFightOut')
                else
                    Wait(1000)
                end
            else
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.11)
            end
        elseif LocalPlayer.state.stressLevel > 7500 then 
            if math.random(1, 10) == 5 then
                AnimpostfxPlay('Rampage', 0, false)
                Wait(5000)
                AnimpostfxStop('Rampage')
                AnimpostfxPlay('RampageOut', 0, false)
                Wait(5000)
                AnimpostfxStop('RampageOut')
            elseif math.random(1, 5) == 3 then
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.1)
            else
                Wait(1000)
            end
        elseif LocalPlayer.state.stressLevel > 4500 then 
            if math.random(1, 10) == math.random(1, 15) then
                SetCamEffect(1)
                Wait(10000)
                SetCamEffect(0)
            else
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.03)
            end
        elseif LocalPlayer.state.stressLevel > 2250 then
            if math.random(1, 10) == math.random(1, 15) then
                TransitionToBlurred(500)
                Wait(math.random(1500, 2000))
                TransitionFromBlurred(500)
            else
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.01)
            end
        end

        if LocalPlayer.state.stressLevel < 1000 then Wait(10000 - 2750)
        elseif LocalPlayer.state.stressLevel < 1500 then Wait(5000 - 2750) end

        Wait(2750)
    end 
end)

--[[
    + Driving over 140mph
    + Shooting w/o silenced
    + Melee Combat
    + Flying out of vehicle.
    + Yacht Heist
    + Searching Vehicles
    + Hotwiring vehicles
    + Stealing vehicles
    + Store robberies
    + Vault heist
    + Oxy runs
    + Truck Robbery
    + Cargo deliveries
    + Fleeca robbery
    + Chopping vehicles.
    + Pawn runs
    + Vangelico Heist
    + House robberies
    + Casino
    
    - Walking whilst unarmed.
    - Fishing.
    - Smoking weed/opium
    - Finishing cargo delivery
    - Laying down on bed.
    - Cigs.
    - Standing still.
    - Meditating, yoga, stretching, out of breath anim.

]]

local bodySweat = 0

CreateThread(function()
    Wait(500)
    -- S = Stress, O = States
    local increaseShootingS, increaseShootingO = false, false
    local increaseMeleeS, increaseMeleeO = false, false
    local increaseWalkingS, increaseWalkingO = false, false
    local increaseStillS, increaseStillO = false, false
    local increaseRunningO = false
    local increaseRunningOStamina = false

    while true do
        Wait(0)

        if Armed and isShooting and not increaseShootingO and math.random(100) >= 95 then
            CreateThread(function() increaseShootingO = true Wait(math.random(7500,12500)) increaseShootingO = false end)
            bodySweat = bodySweat + 300
            TriggerServerEvent('erp-status:applyStatus', 'Red Gunpowder Residue')
        end

        if inCombat and not increaseMeleeO and math.random(100) >= 95 then
            local pedinfront = GetPedInFront()
            if pedinfront > 0 then
                if IsPedInCombat(pedinfront, ped) == 1 then
                    CreateThread(function() increaseMeleeO = true Wait(math.random(10000,15000)) increaseMeleeO = false end)
                    bodySweat = bodySweat + 300
                    if math.random(100) >= 75 then
                        TriggerServerEvent('erp-status:applyStatus', 'Red Hands')
                    end
                end
            end            
        end

        if running and not increaseRunningO and math.random(100) >= 95 then
            CreateThread(function() increaseRunningO = true Wait(math.random(10000,15000)) increaseRunningO = false end)
            bodySweat = bodySweat + (20 + math.ceil(GetEntitySpeed(ped) * 5))
        end

        if not increaseRunningOStamina and running and math.random(100) >= 98 then
            if GetPlayerSprintStaminaRemaining(PlayerId()) >= 95 then
                CreateThread(function() increaseRunningOStamina = true Wait(math.random(30000,45000)) increaseRunningOStamina = false end)
                TriggerServerEvent('erp-status:applyStatus', 'Labored Breathing')
            end 
        end

        if not increaseStillO and isStill and math.random(100) > 85 and not Armed then 
            CreateThread(function() increaseStillO = true Wait(30000) increaseStillO = false end)
            bodySweat = bodySweat - 30
        end

        if bodySweat < 0 then bodySweat = 0 end;

        if bodySweat > math.random(9750, 10000) then
            if math.random(100) >= 25 then
                TriggerServerEvent('erp-status:applyStatus', 'Body Sweat')
                bodySweat = 0
            else
                TriggerServerEvent('erp-status:applyStatus', 'Clothing Sweat')
                bodySweat = 0
            end
        end


        if Armed and isShooting and not increaseShootingS and math.random(1, 100) >= 85 then
            CreateThread(function() increaseShootingS = true Wait(math.random(17500,25000)) increaseShootingS = false end)
            TriggerEvent("updatestress", math.random(280,350))
        elseif not increaseMeleeS and inCombat and math.random(1, 100) >= 65 then
            local pedinfront = GetPedInFront()
            if pedinfront > 0 then
                if IsPedInCombat(pedinfront, ped) == 1 then
                    CreateThread(function() increaseMeleeS = true Wait(math.random(10000,15000)) increaseMeleeS = false end)
                    TriggerEvent("updatestress", 300)
                end
            end
        elseif not increaseWalkingS and IsPedWalking(ped) and not Armed and math.random(1, 100) >= 55 then
            CreateThread(function() increaseWalkingS = true Wait(math.random(10000,15000)) increaseWalkingS = false end)
            TriggerEvent("updatestress", -50, true)
        elseif not increaseStillS and isStill and math.random(100) > 75 and not Armed then 
            CreateThread(function() increaseStillS = true Wait(30000) increaseStillS = false end)
            TriggerEvent("updatestress", -25, true)
        end
    end
end)

function GetPedInFront()	
	local plyPed = ped
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)
	return ped
end

CreateThread(function()
    local canWait = false
    local justShockedS, justShockedO = false, false
    local justWet = false

    Wait(500)

    while true do
        Wait(1000)

        local x, y, z = table.unpack(GetEntityCoords(ped))
        local shocking = IsShockingEventInSphere(88, x, y, z, 2.5)

        if shocking and not justShockedS and math.random(100) >= 95 then
            CreateThread(function() justShockedS = true Wait(math.random(50000,75000)) justShockedS = false end)
            TriggerEvent("updatestress", math.random(1250,2000))
        end

        if shocking and not justShockedO and math.random(100) >= 95 then
            CreateThread(function() justShockedO = true Wait(math.random(100000,150000)) justShockedO = false end)
            TriggerServerEvent('erp-status:applyStatus', 'Agitated')
        end

        if not justWet and math.random(100) >= 85 and IsEntityInWater(ped) then
            CreateThread(function() justWet = true Wait(math.random(275000, 300000)) justWet = false end)
            TriggerServerEvent('erp-status:applyStatus', 'Saturated Clothing')
        end

        veh = GetVehiclePedIsIn(ped, false)
        
        if veh ~= 0 then
            local aircraft = (IsThisModelAPlane(GetEntityModel(veh)) or IsThisModelAHeli(GetEntityModel(veh)))       
            if aircraft == 1 and not isPilot then
                --print("Aircraft detected")
                isPilot = exports["erp-scripts"]:isValidPilot()
                --print(isPilot)
            end
            if (aircraft == 1 and isPilot) then
                -- Nothing or reduced stress.
            else
                currSpeed = GetEntitySpeed(veh) * 2.236963

                if currSpeed >= 90 and not justIncreased and math.random(1,100) >= 97 then
                    CreateThread(function() justIncreased = true Wait(math.random(17500, 25000)) justIncreased = false end)
                    TriggerEvent("updatestress", math.random(75, 100))
                elseif currSpeed >= 120 and not justIncreased and math.random(1,100) >= 97 then
                    CreateThread(function() justIncreased = true Wait(math.random(17500, 25000)) justIncreased = false end)
                    TriggerEvent("updatestress", math.random(175, 200))
                elseif currSpeed >= 140 and not justIncreased and math.random(1,100) >= 97 then
                    CreateThread(function() justIncreased = true Wait(math.random(17500, 25000)) justIncreased = false end)
                    TriggerEvent("updatestress", math.random(275, 300))
                elseif currSpeed >= 165 and not justIncreased and math.random(1,100) >= 97 then
                    CreateThread(function() justIncreased = true Wait(math.random(17500, 25000)) justIncreased = false end)
                    TriggerEvent("updatestress", math.random(375, 400))
                elseif currSpeed >= 190 and not justIncreased and math.random(1,100) >= 97 then
                    CreateThread(function() justIncreased = true Wait(math.random(17500, 25000)) justIncreased = false end)
                    TriggerEvent("updatestress", math.random(475, 500))
                end

                if not canWait and currSpeed > 80 and math.random(1,100) >= 90 then
                    if bodySweat < 500 then
                        bodySweat = bodySweat + (150 + math.ceil(currSpeed * 20))
                    else
                        bodySweat = bodySweat + (150 + math.ceil(currSpeed * 10))
                    end

                    CreateThread(function() canWait = true Wait(math.random(60000, 120000)) canWait = false end)
                end

                currSpeed = 0
            end

        elseif currSpeed > 0 then currSpeed = 0 end
    end
end)

--[[ Status' Below, Above is Stress ]]


local gsrWait = false

AddEventHandler("erp-status:gsr:cs",function()
    if not gsrWait then
        TriggerServerEvent('erp-status:checkGSR')
    end
end)

RegisterNetEvent("erp-status:wipeGSR")
AddEventHandler("erp-status:wipeGSR",function(value)
    if value then
        gsrWait = true
        CreateThread(function()

            local finished = exports["erp_progressbar"]:taskBar({ 
                length = math.random(20000, 25000), 
                text = "Washing off residue"
            })

            while true do 
                Wait(1000)

                if not IsEntityInWater(ped) then
                    exports["erp_progressbar"]:closeGuiFail()
                    Wait(5000)
                    gsrWait = false
                    return
                elseif finished == 100 then
                    TriggerServerEvent('erp-status:removeStatus', 'Red Gunpowder Residue')
                    gsrWait = false
                    return
                else
                    gsrWait = false
                    return
                end 
            end
        end)
    else
        exports['erp_notifications']:SendAlert('inform', 'You have no residue on you.', 6000)
    end 
end)

--[[ Food and Hunger ]]--

RegisterNetEvent("updatestatus")
AddEventHandler("updatestatus",function(type, amount)
    if amount == 0 or amount == nil then print("Something went wrong with stress, either I got a nil value or 0.") return end;

    if LocalPlayer.state.thirstLevel == nil then
        return
    elseif LocalPlayer.state.hungerLevel == nil then
        return
    end

    if type == 'hunger' then
        LocalPlayer.state:set('hungerLevel', LocalPlayer.state.hungerLevel + amount, true)
    elseif type == 'thirst' then
        LocalPlayer.state:set('thirstLevel', LocalPlayer.state.thirstLevel + amount, true)
    end

    if LocalPlayer.state.thirstLevel > 10000 then LocalPlayer.state:set('thirstLevel', 10000, true) end
    if LocalPlayer.state.hungerLevel > 10000 then LocalPlayer.state:set('hungerLevel', 10000, true) end
end)

--[[

    - Screen effect
    - Random blackouts
    - Increase stress multiplier

]]

CreateThread(function()
    Wait(500)
    while true do
        Wait(2000)

        if LocalPlayer.state.thirstLevel and LocalPlayer.state.hungerLevel then
            if math.random(10) >= 4 then TriggerEvent('updatestatus', 'thirst', -math.random(1,2), true) end
            if math.random(10) >= 4 then TriggerEvent('updatestatus', 'hunger', -math.random(1,2), true) end

            if IsPedRunning(ped) and math.random(100) >= 90 and GetPlayerSprintStaminaRemaining(PlayerId()) > 90 then
                TriggerEvent('updatestatus', 'thirst', -math.random(10,15), true)
            end
                    
            if LocalPlayer.state.thirstLevel < 0 then
                local chance = math.random(1, 100)
                if chance >= 85 then
                    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.02)
                elseif chance >= 76 then
                    SetPedToRagdoll(PlayerPedId(), 5511, 5511, 0, 0, 0, 0)
                elseif chance >= 73 then
                    DoScreenFadeOut(1000)
                    Wait(1250)
                    DoScreenFadeIn(1000)               
                elseif chance >= 65 then
                    TriggerEvent('erp_inventory:weapons:setEmptyHanded')
                else
                    local currHealth = GetEntityHealth(PlayerPedId())
                    SetEntityHealth(PlayerPedId(), currHealth - 1)
                end
            elseif LocalPlayer.state.hungerLevel < 0 then
                local chance = math.random(1, 100)
                if chance >= 75 then
                    TriggerEvent("updatestress", math.random(150,275), true)
                elseif chance >= 69 then
                    AnimpostfxPlay('FocusIn', 2000, false)
                    Wait(2000)
                    AnimpostfxPlay('FocusOut', 2000, false)
                    Wait(2000)
                    AnimpostfxStop('FocusIn')
                    AnimpostfxStop('FocusOut')
                elseif chance >= 65 then
                    AnimpostfxPlay('ChopVision', 0 , false)
                    Wait(5000)
                    AnimpostfxStop('ChopVision')
                else
                    local currHealth = GetEntityHealth(PlayerPedId())
                    SetEntityHealth(PlayerPedId(), currHealth - 2)
                end
            end
        end
    end
end)

-- Backwards compatibilty for the above.

RegisterNetEvent('erp-status:set')
AddEventHandler('erp-status:set', function(name, val)
    if name == 'hunger' then
        LocalPlayer.state:set('hungerLevel', val, true)
    elseif name == 'thirst' then
        LocalPlayer.state:set('thirstLevel', val, true)
    end 
end)

RegisterNetEvent('esx_basicneeds:healPlayer')
AddEventHandler('esx_basicneeds:healPlayer', function()
	TriggerEvent('erp-status:set', 'hunger', 10000)
	TriggerEvent('erp-status:set', 'thirst', 10000)
	local playerPed = PlayerPedId()
	SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
	exports['mythic_hospital']:ResetAll()
end)

AddEventHandler('esx_basicneeds:resetStatus', function()
	TriggerEvent('erp-status:set', 'hunger', 5000)
	TriggerEvent('erp-status:set', 'thirst', 5000)
end)

AddEventHandler('esx_basicneeds:zeroStatus', function()
	TriggerEvent('erp-status:set', 'hunger', 1000)
	TriggerEvent('erp-status:set', 'thirst', 1000)
end)


-- erp-status:add

RegisterNetEvent('erp-status:add')
AddEventHandler('erp-status:add', function(name, val)
   TriggerEvent('updatestatus', name, val, false)
end)

RegisterNetEvent('erp-status:remove')
AddEventHandler('erp-status:remove', function(name, val)
    TriggerEvent('updatestatus', name, -val, false)
end)

RegisterNetEvent('erp-stress:isPilot')
AddEventHandler('erp-stress:isPilot', function(val)
    isPilot = val
end)