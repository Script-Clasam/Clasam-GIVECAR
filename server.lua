local Framework = nil
local FrameworkType = nil

-- Auto-detect framework
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

local function GetPlayer(source)
    if FrameworkType == 'qbx' then return Framework.Functions.GetPlayer(source)
    elseif FrameworkType == 'qbcore' then return Framework.Functions.GetPlayer(source)
    elseif FrameworkType == 'esx' then return Framework.GetPlayerFromId(source) end
end

local function GetPlayerData(player)
    if FrameworkType == 'esx' then return player
    else return player.PlayerData end
end

local function GetPlayerName(data)
    if FrameworkType == 'esx' then return data.getName()
    else return (data.charinfo.firstname .. " " .. data.charinfo.lastname) end
end

local function GetIdentifier(data)
    return FrameworkType == 'esx' and data.identifier or data.citizenid
end

local function GetLicense(data)
    return FrameworkType == 'esx' and data.identifier or data.license
end

local function NotifyPlayer(src, msg, type, duration)
    if FrameworkType == 'esx' then
        TriggerClientEvent('esx:showNotification', src, msg)
    else
        TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary', duration or 5000)
    end
end

function GeneratePlate()
    local plate
    if FrameworkType == 'esx' then
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        plate = ""
        for i = 1, 8 do
            plate = plate .. chars:sub(math.random(#chars), math.random(#chars))
        end
    else
        plate = tostring(math.random(10000,99999))..string.char(math.random(65,90))..string.char(math.random(65,90))..tostring(math.random(100,999))
    end

    local tableName = Config.Database.tableName
    local plateCol = Config.Database.columns[FrameworkType == 'esx' and 'esx' or 'qb'].plate
    local result = MySQL.Sync.fetchScalar("SELECT "..plateCol.." FROM "..tableName.." WHERE "..plateCol.." = ?", {plate})
    if result then return GeneratePlate() end
    return plate:upper()
end


RegisterCommand(Config.CommandeName, function(src, args)
    local target = tonumber(args[1])
    local model = args[2]
    local plate = args[3]

    if not target or not model then
        NotifyPlayer(src, Config.Messages[Config.Language]['incorrect_format'], "error", 5000)
        return
    end

    local player = GetPlayer(src)
    if not player then return end
    if Config.AdminLevels.givecar and not HasPermission(src, Config.AdminLevels.givecar) then
        NotifyPlayer(src, "Tu n'as pas la permission", "error", 4000)
        return
    end

    local targetPlayer = GetPlayer(target)
    if not targetPlayer then
        NotifyPlayer(src, "Joueur introuvable", "error", 4000)
        return
    end

    if not plate or plate == "" then plate = GeneratePlate() end

    TriggerClientEvent("sam:client:givecar", target, model, plate)

    local name = GetPlayerName(GetPlayerData(targetPlayer))
    local msg = string.format(Config.Messages[Config.Language]['vehicle_given'], name, "", model, plate)
    NotifyPlayer(src, msg, "success", 6000)
end)

RegisterServerEvent('sam:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local player = GetPlayer(src)
    if not player then return end

    local data = GetPlayerData(player)
    local id = GetIdentifier(data)
    local license = GetLicense(data)

    local tableName = Config.Database.tableName
    local columns = Config.Database.columns[FrameworkType == 'esx' and 'esx' or 'qb']
    local exists = MySQL.Sync.fetchAll("SELECT "..columns.plate.." FROM "..tableName.." WHERE "..columns.plate.." = ?", {plate})
    if exists and exists[1] then
        NotifyPlayer(src, Config.Messages[Config.Language]['vehicle_exists'], "error", 4000)
        return
    end

    if FrameworkType == 'esx' then
        local vehicleData = {
            model = vehicle.model,
            plate = plate,
            fuelLevel = 100.0,
            engineHealth = 1000.0,
            bodyHealth = 1000.0,
            props = mods
        }

     MySQL.Async.insert("INSERT INTO "..tableName.." (`owner`, `plate`, `vehicle`, `type`, `garage`) VALUES (?, ?, ?, ?, ?)", {
        id,
        plate,
        json.encode(vehicleData),
        Config.type,
        'garage'
    })

    else
        MySQL.Async.insert("INSERT INTO "..tableName.." (`"..columns.license.."`, `"..columns.owner.."`, `"..columns.vehicle.."`, `"..columns.hash.."`, `"..columns.mods.."`, `"..columns.plate.."`, `"..columns.state.."`, `"..columns.garage.."`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {
            license,
            id,
            vehicle.model,
            hash,
            json.encode(mods),
            plate,
            0,
            'pillboxgarage'
        })
    end

    NotifyPlayer(src, Config.Messages[Config.Language]['vehicle_received'], "success", 5000)
end)



CreateThread(function()
    print([[
 ██████╗██╗      █████╗ ███████╗███████╗ █████╗ ███╗   ███╗
██╔════╝██║     ██╔══██╗██╔════╝██╔════╝██╔══██╗████╗ ████║
██║     ██║     ███████║███████╗███████╗███████║██╔████╔██║
██║     ██║     ██╔══██║╚════██║╚════██║██╔══██║██║╚██╔╝██║
╚██████╗███████╗██║  ██║███████║███████║██║  ██║██║ ╚═╝ ██║
 ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
                                                           

              GIVECAR SYSTEM 
         Script par CLASAM - Initialisé
    ]])
end)
