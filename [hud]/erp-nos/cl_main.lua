local NitrousActivated = false
local NitrousBoost = 15.0
local ScreenEffect = false
local NosFlames = nil
local VehicleNitrous = {}
local Fxs = {}
local vehicles = {}
local particles = {}
local flames = false
local spam = false


CreateThread(function() -- Use this only if you think/plan on restarting the resource often.
    Wait(2500)
    TriggerServerEvent('nitrous:GetNosLoadedVehs')
    return
end)

RegisterNetEvent('nitrous:GetNosLoadedVehs')
AddEventHandler('nitrous:GetNosLoadedVehs', function(veh)
    VehicleNitrous = veh
end)

local nosupdated = false

Citizen.CreateThread(function()
    while true do
        local IsInVehicle = IsPedInAnyVehicle(PlayerPedId())
        local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
        local nitroLevel = 0
        if IsInVehicle then
            local Plate = GetVehicleNumberPlateText(CurrentVehicle)
            if VehicleNitrous[Plate] ~= nil then
                if VehicleNitrous[Plate].hasnitro then
                    if IsControlJustPressed(0, 21) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() and not spam then
                        local speed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 2.3369
                        SetVehicleEnginePowerMultiplier(CurrentVehicle, NitrousBoost)
                        SetVehicleEngineTorqueMultiplier(CurrentVehicle, NitrousBoost)
                        SetEntityMaxSpeed(CurrentVehicle, 999.0)
                        SetVehicleBoostActive(CurrentVehicle, 1)
                        NitrousActivated = true

                        Citizen.CreateThread(function()
                            while NitrousActivated do
                                if VehicleNitrous[Plate].level - 1 ~= 0 then
                                    TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 1))
                                else
                                    TriggerServerEvent('nitrous:server:UnloadNitrous', Plate)
                                    NitrousActivated = false
                                    -- SetVehicleBoostActive(CurrentVehicle, 0)
                                    SetVehicleEnginePowerMultiplier(CurrentVehicle, LastEngineMultiplier)
                                    SetVehicleEngineTorqueMultiplier(CurrentVehicle, 1.0)
                                    SetVehicleLightTrailEnabled(CurrentVehicle, false)
                                    StopScreenEffect("RaceTurbo")
                                    ScreenEffect = false
                                    for index,_ in pairs(Fxs) do
                                        StopParticleFxLooped(Fxs[index], 1)
                                        TriggerServerEvent('nitrous:server:StopSync', GetVehicleNumberPlateText(CurrentVehicle), VehToNet(CurrentVehicle))
                                        Fxs[index] = nil
                                    end
                                end
                                Citizen.Wait(100)
                            end
                        end)
                    end

                    if IsControlJustReleased(0, 21) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
                        if NitrousActivated then
                            TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - 1))
                            local veh = GetVehiclePedIsIn(PlayerPedId())
                            SetVehicleBoostActive(veh, 0)
                            SetVehicleLightTrailEnabled(veh, false)
                            SetVehicleEnginePowerMultiplier(veh, LastEngineMultiplier)
                            SetVehicleEngineTorqueMultiplier(veh, 1.0)
                            for index,_ in pairs(Fxs) do
                                StopParticleFxLooped(Fxs[index], 1)
                                TriggerServerEvent('nitrous:server:StopSync', GetVehicleNumberPlateText(veh), VehToNet(veh))
                                Fxs[index] = nil
                            end
                            StopScreenEffect("RaceTurbo")
                            NitrousActivated = false
                            Citizen.CreateThread(function()
                                spam = true
                                Citizen.Wait(8000)
                                spam = false
                            end)
                        end
                    end
                end
            else
                if not nosupdated then
                    nosupdated = true
                end
                StopScreenEffect("RaceTurbo")
            end
        else
            if nosupdated then
                nosupdated = false
            end
            StopScreenEffect("RaceTurbo")
            Citizen.Wait(1500)
        end
        Citizen.Wait(3)
    end
end)

p_flame_location = {
	"exhaust",
	"exhaust_2",
	"exhaust_3",
	"exhaust_4",
	"exhaust_5",
	"exhaust_6",
	"exhaust_7",
	"exhaust_8",
	"exhaust_9",
	"exhaust_10",
	"exhaust_11",
	"exhaust_12",
	"exhaust_13",
	"exhaust_14",
	"exhaust_15",
	"exhaust_16",
}

local bonesindex = {
    "chassis",
    "windscreen",
    "seat_pside_r",
    "seat_dside_r",
    "bodyshell",
    "suspension_lm",
    "suspension_lr",
    "platelight",
    "attach_female",
    "attach_male",
    "bonnet",
    "boot",
    "chassis_dummy",
    "chassis_Control",
    "door_dside_f",
    "door_dside_r",
    "door_pside_f",
    "door_pside_r",
    "Gun_GripR",
    "windscreen_f",
    "platelight",
    "VFX_Emitter",
    "window_lf",
    "window_lr",
    "window_rf",
    "window_rr",
    "engine",
    "gun_ammo",
    "ROPE_ATTATCH",
    "wheel_lf",
    "wheel_lr",
    "wheel_rf",
    "wheel_rr",
    "exhaust",
    "overheat",
    "misc_e",
    "seat_dside_f",
    "seat_pside_f",
    "Gun_Nuzzle",
    "seat_r",
}

ParticleDict = "veh_xs_vehicle_mods"
ParticleFx = "veh_nitrous"
ParticleSize = 1.4

Citizen.CreateThread(function()
    while true do
        if NitrousActivated then
            local veh = GetVehiclePedIsIn(PlayerPedId())
            if veh ~= 0 then
                if not flames then
                    TriggerServerEvent('nitrous:server:SyncFlames', VehToNet(veh))
                    flames = true
                end
                -- SetVehicleBoostActive(veh, 1)
                -- StartScreenEffect("RaceTurbo", 0.0, 0)

                for _,bones in pairs(p_flame_location) do
                    if GetEntityBoneIndexByName(veh, bones) ~= -1 then
                        if Fxs[bones] == nil then
                            RequestNamedPtfxAsset(ParticleDict)
                            while not HasNamedPtfxAssetLoaded(ParticleDict) do
                                Citizen.Wait(0)
                            end
                            SetPtfxAssetNextCall(ParticleDict)
                            UseParticleFxAssetNextCall(ParticleDict)
                            Fxs[bones] = StartParticleFxLoopedOnEntityBone(ParticleFx, veh, 0.0, -0.02, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(veh, bones), ParticleSize, 0.0, 0.0, 0.0)
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

local NOSPFX = {}

RegisterNetEvent('nitrous:client:SyncFlames')
AddEventHandler('nitrous:client:SyncFlames', function(netid, nosid)
    local veh = NetToVeh(netid)
    SetVehicleLightTrailEnabled(veh, true)
    if veh ~= 0 then
        local myid = GetPlayerServerId(PlayerId())
        if NOSPFX[GetVehicleNumberPlateText(veh)] == nil then
            NOSPFX[GetVehicleNumberPlateText(veh)] = {}
        end
        if myid ~= nosid then
            for _,bones in pairs(p_flame_location) do
                if NOSPFX[GetVehicleNumberPlateText(veh)][bones] == nil then
                    NOSPFX[GetVehicleNumberPlateText(veh)][bones] = {}
                end
                if GetEntityBoneIndexByName(veh, bones) ~= -1 then
                    if NOSPFX[GetVehicleNumberPlateText(veh)][bones].pfx == nil then
                        RequestNamedPtfxAsset(ParticleDict)
                        while not HasNamedPtfxAssetLoaded(ParticleDict) do
                            Citizen.Wait(0)
                        end
                        SetPtfxAssetNextCall(ParticleDict)
                        UseParticleFxAssetNextCall(ParticleDict)
                        NOSPFX[GetVehicleNumberPlateText(veh)][bones].pfx = StartParticleFxLoopedOnEntityBone(ParticleFx, veh, 0.0, -0.05, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(veh, bones), ParticleSize, 0.0, 0.0, 0.0)

                    end
                end
            end
        end
    end
end)

RegisterNetEvent('nitrous:client:StopSync')
AddEventHandler('nitrous:client:StopSync', function(plate, veh)
    local vehl = NetToVeh(veh)
    flames = false
    SetVehicleLightTrailEnabled(vehl, false)
    if NOSPFX[plate] ~= nil then
        for k, v in pairs(NOSPFX[plate]) do
            StopParticleFxLooped(v.pfx, 1)
            NOSPFX[plate][k].pfx = nil
        end
    end
end)

RegisterNetEvent('nitrous:client:UpdateNitroLevel')
AddEventHandler('nitrous:client:UpdateNitroLevel', function(Plate, level)
    if Plate then
        if VehicleNitrous[Plate] then
            VehicleNitrous[Plate]['level'] = level
        end
    end
end)

RegisterNetEvent('nitrous:client:LoadNitrous')
AddEventHandler('nitrous:client:LoadNitrous', function(Plate)
    VehicleNitrous[Plate] = {
        hasnitro = true,
        level = 200,
    }
    local IsInVehicle = IsPedInAnyVehicle(PlayerPedId())
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = GetVehicleNumberPlateText(CurrentVehicle)
end)

RegisterNetEvent('nitrous:client:UnloadNitrous')
AddEventHandler('nitrous:client:UnloadNitrous', function(Plate)
    VehicleNitrous[Plate] = nil
    
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = GetVehicleNumberPlateText(CurrentVehicle)
    if CPlate == Plate then
        NitrousActivated = false
    end
end)

function IsVehicleLightTrailEnabled(vehicle)
    return vehicles[vehicle] == true
end

function SetVehicleLightTrailEnabled(vehicle, enabled)
    if IsVehicleLightTrailEnabled(vehicle) == enabled then
      return
    end
    
    if enabled then
      local ptfxs = {}
      
      local leftTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_l"), 1.0)
      local rightTrail = CreateVehicleLightTrail(vehicle, GetEntityBoneIndexByName(vehicle, "taillight_r"), 1.0)
      
      table.insert(ptfxs, leftTrail)
      table.insert(ptfxs, rightTrail)
  
      vehicles[vehicle] = true
      particles[vehicle] = ptfxs
    else
      if particles[vehicle] and #particles[vehicle] > 0 then
        for _, particleId in ipairs(particles[vehicle]) do
          StopVehicleLightTrail(particleId, 500)
        end
      end
  
      vehicles[vehicle] = nil
      particles[vehicle] = nil
    end
end
  
function CreateVehicleLightTrail(vehicle, bone, scale)
    UseParticleFxAssetNextCall('core')
    local ptfx = StartParticleFxLoopedOnEntityBone('veh_light_red_trail', vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, bone, scale, false, false, false)
    SetParticleFxLoopedEvolution(ptfx, "speed", 1.0, false)
    return ptfx
end

function StopVehicleLightTrail(ptfx, duration)
    Citizen.CreateThread(function()
      local startTime = GetGameTimer()
      local endTime = GetGameTimer() + duration
      while GetGameTimer() < endTime do 
        Citizen.Wait(0)
        local now = GetGameTimer()
        local scale = (endTime - now) / duration
        SetParticleFxLoopedScale(ptfx, scale)
        SetParticleFxLoopedAlpha(ptfx, scale)
      end
      StopParticleFxLooped(ptfx)
    end)
end
  
-- VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level

exports('nitrousInfo', function(vehicle)
    
    if not DoesEntityExist(vehicle) then return end;
    local plate = GetVehicleNumberPlateText(vehicle)
    local nitrous = VehicleNitrous[plate]

    if not nitrous then
        return {
            hasNitro = false,
            level = 0
        }
    end

    return {
        hasNitro = nitrous.hasnitro,
        level = nitrous.level
    }

end)