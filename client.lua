
local Framework = nil
local FrameworkType = nil

if Config.Framework == 'auto' then
    if GetResourceState('qbx_core') == 'started' then
        Framework = exports['qb-core']:GetCoreObject()
        FrameworkType = 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        Framework = exports['qb-core']:GetCoreObject()
        FrameworkType = 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        Framework = exports['es_extended']:getSharedObject()
        FrameworkType = 'esx'
    end
else
    FrameworkType = Config.Framework
    if FrameworkType == 'qbx' then
        Framework = exports['qb-core']:GetCoreObject()
    elseif FrameworkType == 'qbcore' then
        Framework = exports['qb-core']:GetCoreObject()
    elseif FrameworkType == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
    end
end


local function SpawnVehicle(model, coords, callback)
    print("[DEBUG] SpawnVehicle called with:", model, coords)
    
    if FrameworkType == 'qbx' or FrameworkType == 'qbcore' then
        if Framework.Functions and Framework.Functions.SpawnVehicle then
            Framework.Functions.SpawnVehicle(model, callback, coords, true)
        else
            print("[ERROR] Framework.Functions.SpawnVehicle not available")
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(1)
            end
            local veh = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, true, false)
            callback(veh)
        end
    elseif FrameworkType == 'esx' then
        if Framework.Game and Framework.Game.SpawnVehicle then
            Framework.Game.SpawnVehicle(model, coords, 0.0, callback)
        else
            print("[ERROR] Framework.Game.SpawnVehicle not available")
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(1)
            end
            local veh = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, true, false)
            callback(veh)
        end
    end
end

local function GetPlate(vehicle)
    if FrameworkType == 'qbx' or FrameworkType == 'qbcore' then
        return Framework.Functions.GetPlate(vehicle)
    elseif FrameworkType == 'esx' then
        return GetVehicleNumberPlateText(vehicle)
    end
end

local function NotifyPlayer(message, type, duration)
    if FrameworkType == 'qbx' or FrameworkType == 'qbcore' then
        Framework.Functions.Notify(message, type, duration)
    elseif FrameworkType == 'esx' then
        Framework.ShowNotification(message, type, duration)
    end
end

local function GiveVehicleKeys(vehicle, plate)
    if not Config.VehicleKeys.enabled then return end
    
    local keySystem = Config.VehicleKeys.system
    if keySystem == 'auto' then
        if GetResourceState('qb-vehiclekeys') == 'started' then
            keySystem = 'qb-vehiclekeys'
        elseif GetResourceState('qs-vehiclekeys') == 'started' then
            keySystem = 'qs-vehiclekeys'
        elseif GetResourceState('cd_garage') == 'started' then
            keySystem = 'cd_garage'
        elseif GetResourceState('esx_vehiclekeys') == 'started' then
            keySystem = 'esx_vehiclekeys'
        end
    end
    
   
    if keySystem == 'qb-vehiclekeys' then
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    elseif keySystem == 'qs-vehiclekeys' then
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        exports['qs-vehiclekeys']:GiveKeys(plate, model, true)
    elseif keySystem == 'cd_garage' then
        TriggerEvent('cd_garage:AddKeys', plate)
    elseif keySystem == 'esx_vehiclekeys' then
        TriggerEvent('esx_vehiclekeys:client:SetOwner', plate)
    end
end

local function GetClosestPlayer()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(GetPlayerPed(-1))
    
    if FrameworkType == 'qbx' or FrameworkType == 'qbcore' then
        local closestPlayers = Framework.Functions.GetPlayersFromCoords()
        for i=1, #closestPlayers, 1 do
            if closestPlayers[i] ~= PlayerId() then
                local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
                local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

                if closestDistance == -1 or closestDistance > distance then
                    closestPlayer = closestPlayers[i]
                    closestDistance = distance
                end
            end
        end
    elseif FrameworkType == 'esx' then
        local players = Framework.Game.GetPlayersInArea(coords, 50.0)
        for i=1, #players, 1 do
            if players[i] ~= PlayerId() then
                local pos = GetEntityCoords(GetPlayerPed(players[i]))
                local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

                if closestDistance == -1 or closestDistance > distance then
                    closestPlayer = players[i]
                    closestDistance = distance
                end
            end
        end
    end

    return closestPlayer, closestDistance
end

RegisterNetEvent('sam:client:givecar')
AddEventHandler('sam:client:givecar', function(vehicleModel, plate)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    SpawnVehicle(vehicleModel, coords, function(veh)
        SetVehicleNumberPlateText(veh, plate)
        TaskWarpPedIntoVehicle(playerPed, veh, -1)
        GiveVehicleKeys(veh, plate)
        
        SetVehicleEngineOn(veh, true, true)
        local mods = {}
        local vehicleData = {
            model = vehicleModel,
            hash = GetHashKey(vehicleModel)
        }
        
        TriggerServerEvent('sam:server:SaveCar', mods, vehicleData, GetHashKey(vehicleModel), plate)
    end)
end)

RegisterNetEvent('sam:client:transferrc', function(id)
    local me = PlayerPedId()
    if not IsPedSittingInAnyVehicle(me) then
        NotifyPlayer(Config.Messages[Config.Language]['must_be_in_vehicle'], "error", 5000)
        return
    end
    
    local vehicle = GetVehiclePedIsIn(me, false)
    local player, distance = GetClosestPlayer()
    
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if playerId == tonumber(id) then
            local plate = GetVehicleNumberPlateText(vehicle)
            TriggerServerEvent("sam:GiveRC", GetPlayerServerId(PlayerId()), playerId, plate)
        else
            NotifyPlayer(Config.Messages[Config.Language]['person_not_near'], "error", 5000)
        end
    else
        NotifyPlayer(Config.Messages[Config.Language]['no_one_around'], "error", 5000)
    end
end)

