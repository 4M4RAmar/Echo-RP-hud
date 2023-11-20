local CARCONTROLS = {
  
  isOpen = false,

  ValidVehicle = function(self)

    return IsPedInAnyVehicle( PlayerPedId(), false )

  end,
  
  ToggleNui = function(self, open)

    self.isOpen = self:ValidVehicle() and open or false
    SetNuiFocus(self.isOpen, self.isOpen)
    SendReactMessage('setVisible', self.isOpen)
    TriggerEvent('erp_carcontrols:toggle', self.isOpen)

    self:GetCarInfo()

  end,

  WindowStatus = function(self, vehicle, window, vehDoorNum)

    if vehDoorNum <= 4 then
      if window >= 2 then return 0 end
    end

    return IsVehicleWindowIntact(vehicle, window) == 1 and 2 or 1

  end,

  DoorStatus = function(self, vehicle, door, vehDoorNum)

    if vehDoorNum <= 4 then
      if door >= 2 then return 0 end
    end

    return GetVehicleDoorAngleRatio(vehicle, door) > 0.0 and 1 or 2

  end,

  SeatStatus = function(self, vehicle, seat, vehSeatNum)

    if seat + 2 > vehSeatNum then return 0 end; 

    return GetPedInVehicleSeat(vehicle, seat) == PlayerPedId() and 2 or 1;

  end,

  GetCarInfo = function(self)

    if not self.isOpen then return end;

    local plyVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehDoorNum = GetNumberOfVehicleDoors(plyVehicle)
    local vehSeatNum = GetVehicleModelNumberOfSeats( GetEntityModel(plyVehicle) )

    SendReactMessage('setCarInfo', {

      frontLeftWindow = self:WindowStatus(plyVehicle, 0, vehDoorNum),
      frontLeftDoor = self:DoorStatus(plyVehicle, 0, vehDoorNum),
      frontLeftSeat = self:SeatStatus(plyVehicle, -1, vehSeatNum),

      rightLeftWindow = self:WindowStatus(plyVehicle, 1, vehDoorNum),
      rightLeftDoor = self:DoorStatus(plyVehicle, 1, vehDoorNum),
      rightLeftSeat = self:SeatStatus(plyVehicle, 0, vehSeatNum),

      backLeftWindow = self:WindowStatus(plyVehicle, 2, vehDoorNum),
      backLeftDoor = self:DoorStatus(plyVehicle, 2, vehDoorNum),
      backLeftSeat = self:SeatStatus(plyVehicle, 1, vehSeatNum),

      backRightWindow = self:WindowStatus(plyVehicle, 3, vehDoorNum),
      backRightDoor = self:DoorStatus(plyVehicle, 3, vehDoorNum),
      backRightSeat = self:SeatStatus(plyVehicle, 2, vehSeatNum),

      engine = GetIsVehicleEngineRunning(plyVehicle) == 1,
      
      key = exports['erp-keys']:hasKey(GetVehicleNumberPlateText(plyVehicle)) and 2 or 1,
      hood = GetVehicleDoorAngleRatio(plyVehicle, 4) > 0.0 and 1 or 2,
      trunk = GetVehicleDoorAngleRatio(plyVehicle, 5) > 0.0 and 1 or 2,
      lock = GetVehicleDoorsLockedForPlayer(plyVehicle, PlayerPedId()) and 2 or 1

    })

  end,

  ToggleWindow = function(self, window)

    local plyVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    
    if GetPedInVehicleSeat(plyVehicle, window - 1) ~= PlayerPedId() then
      if GetPedInVehicleSeat(plyVehicle, -1) ~= PlayerPedId() then
        return
      end
    end

    if IsVehicleWindowIntact(plyVehicle, window) then
      RollDownWindow(plyVehicle, window)
    else
      RollUpWindow(plyVehicle, window)
    end

    return self:GetCarInfo()

  end,

  ToggleDoor = function(self, door)

    local plyVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if GetPedInVehicleSeat(plyVehicle, door - 1) ~= PlayerPedId() then
      if GetPedInVehicleSeat(plyVehicle, -1) ~= PlayerPedId() then
        return
      end
    end

    if GetVehicleDoorAngleRatio(plyVehicle, door) > 0.0 then
      SetVehicleDoorShut(plyVehicle, door, false)
    else
      SetVehicleDoorOpen(plyVehicle, door, false, false)
    end

    Wait(500)

    return self:GetCarInfo()

  end,

  SwitchSeat = function(self, seat)

    local plyVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not IsVehicleSeatFree(plyVehicle, seat) then
      exports['erp_notifications']:SendAlert('error', 'This seat is occupied.', 5000)
      return
    end

    SetPedIntoVehicle(PlayerPedId(), plyVehicle, seat)
    
    return self:GetCarInfo()

  end,
  
  ToggleEngine = function(self)

    local plyVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not exports['erp-keys']:hasKey(GetVehicleNumberPlateText(plyVehicle)) then 
      exports['erp_notifications']:SendAlert('error', 'Missing keys.', 5000)
      return 
    end;

    if GetPedInVehicleSeat(plyVehicle, -1) ~= PlayerPedId() then
      return
    end

    if GetIsVehicleEngineRunning(plyVehicle) == 1 then
      while GetIsVehicleEngineRunning(plyVehicle) ~= false do
        SetVehicleEngineOn(plyVehicle, false, true, true)
        Wait(10)
      end
    else
      TriggerEvent('keys:startvehicle', plyVehicle)
      Wait(500)
    end

    return self:GetCarInfo()

  end,

  ToggleLock = function(self)

    local plyVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehPlate = GetVehicleNumberPlateText(plyVehicle)
    if not exports['erp-keys']:hasKey(vehPlate) then 
      exports['erp_notifications']:SendAlert('error', 'Missing keys.', 5000)
      return 
    end;
    

    if GetPedInVehicleSeat(plyVehicle, -1) ~= PlayerPedId() then
      return
    end

    TriggerServerEvent('erp-carstatus:attemptLock', plyVehicle, vehPlate)

    Wait(1000)

    return self:GetCarInfo()

  end,

}

RegisterKeyMapping('+vehiclemenu', 'Vehicle Menu', 'keyboard', 'F9')
RegisterCommand("+vehiclemenu",function(source, args) CARCONTROLS:ToggleNui(true) end, false)

RegisterNUICallback('toggleWindow', function(data, cb)
  cb('ok')
  CARCONTROLS:ToggleWindow(data)
end)

RegisterNUICallback('toggleDoor', function(data, cb)
  cb('ok')
  CARCONTROLS:ToggleDoor(data)
end)

RegisterNUICallback('switchSeat', function(data, cb)
  cb('ok')
  CARCONTROLS:SwitchSeat(data)
end)

RegisterNUICallback('toggleEngine', function(data, cb)
  cb('ok')
  CARCONTROLS:ToggleEngine(data)
end)

RegisterNUICallback('toggleLock', function(data, cb)
  cb('ok')
  CARCONTROLS:ToggleLock(data)
end)

RegisterNUICallback('toggleNui', function(data, cb)
  cb('ok')
  CARCONTROLS:ToggleNui(data)
end)

--[[exports("exampleExport", function(...)
  return CARCONTROLS:ToggleNui(...)
end)]]

-- Migrated:


RegisterCommand('neon', function(src, args)

  local id = tonumber(args[1])
  local player = PlayerPedId()
  local veh = GetVehiclePedIsIn(player, false)
  local neonStatus = false

  if IsVehicleNeonLightEnabled(veh) == false then neonStatus = true end

  if veh ~= 0 then
      local lockStatus = GetVehicleDoorLockStatus(veh)
      if lockStatus == 1 or lockStatus == 0 then
          if id ~= nil then
              if IsVehicleNeonLightEnabled(veh, id) == false then neonStatus = true end
              SetVehicleNeonLightEnabled(veh, id, neonStatus)
          else
              SetVehicleNeonLightEnabled(veh, 0, neonStatus)
              SetVehicleNeonLightEnabled(veh, 1, neonStatus)
              SetVehicleNeonLightEnabled(veh, 2, neonStatus)
              SetVehicleNeonLightEnabled(veh, 3, neonStatus)
          end
      end
  end
end)

TriggerEvent('chat:addSuggestion','/neon','Toggles car neons (toggle all by leaving ID blank)', {
  { name="ID", help="0 = Left, 1 = Right, 2 = Front, 3 = Back" } 
})

RegisterCommand('seat', function(src, args)

  local id = tonumber(args[1])
  local plyPed = PlayerPedId()
  local plyVeh = GetVehiclePedIsIn(plyPed, false) 

  if not DoesEntityExist(plyVeh) then
    exports['erp_notifications']:SendAlert('error', 'Not in a vehicle', 3500)
    return 
  end

  if DoesEntityExist(GetPedInVehicleSeat(plyVeh, id)) then
    exports['erp_notifications']:SendAlert('error', 'Someone is in the seat already', 4000)
    return 
  end

  SetPedIntoVehicle(plyPed, plyVeh, id)

end)