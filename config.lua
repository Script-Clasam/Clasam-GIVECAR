Config = {}

--Framework Detection (Auto-detect or force specific framework)
Config.Framework = 'auto' -- 'auto', 'qbcore', 'qbx', 'esx'
Config.CommandeName = 'givecar' -- Command name for giving vehicles
Config.Language = 'fr'
--Only for ESX :
Config.type = 'vehicle' -- Type of vehicle, can be 'vehicle', 'boat', 'aircraft', etc.
Config.Database = {

    tableName = 'owned_vehicles', -- 'player_vehicles' (QB/QBX) or 'owned_vehicles' (ESX)
    columns = {
        qb = {
            owner = 'citizenid',
            plate = 'plate',
            vehicle = 'vehicle',
            mods = 'mods',
            state = 'state',
            garage = 'garage',
            fuel = 'fuel',
            engine = 'engine',
            body = 'body',
            hash = 'hash',
            license = 'license'
        },
        
        esx = {
            owner = 'owner',
            plate = 'plate',
            vehicle = 'vehicle',
            type = 'type',
            garage = 'garage'
        }

    }
}
Config.AdminLevels = {
    givecar = 'admin', -- nil = everyone can use (change to 'god' for QB or 'admin' for ESX)
}

-- Vehicle Keys System
Config.VehicleKeys = {
    enabled = true,
    system = 'auto', -- 'auto', 'qb-vehiclekeys', 'qs-vehiclekeys', 'cd_garage', 'esx_vehiclekeys'
}



-- Messages (Multi-language support)
Config.Messages = {
    ['en'] = {
        ['vehicle_given'] = 'You gave the vehicle to %s %s Vehicle: %s With plate: %s',
        ['vehicle_received'] = 'Vehicle received and saved!',
        ['vehicle_exists'] = 'Vehicle already exists..',
        ['incorrect_format'] = 'Incorrect Format',
        ['must_be_in_vehicle'] = 'You must be in a Vehicle to Transfer',
        ['person_not_near'] = 'Person not Near!',
        ['no_one_around'] = 'No one around!',
        ['provide_id'] = 'Please Provide ID',
        ['transfer_given'] = 'You gave registration paper to %s %s',
        ['transfer_received'] = 'You received registration paper from %s %s',
        ['dont_own_vehicle'] = "You don't own this vehicle"
    },
    ['fr'] = {
        ['vehicle_given'] = 'Tu as donné le véhicule à %s %s Véhicule: %s Avec la plaque: %s',
        ['vehicle_received'] = 'Le véhicule est à toi!',
        ['vehicle_exists'] = 'Le véhicule est déjà à toi..',
        ['incorrect_format'] = 'Format incorrect',
        ['must_be_in_vehicle'] = 'Vous devez être dans un véhicule pour le transférer',
        ['person_not_near'] = 'Personne à proximité!',
        ['no_one_around'] = 'Personne autour!',
        ['provide_id'] = 'Veuillez fournir un ID',
        ['transfer_given'] = 'Vous avez donné les papiers d\'immatriculation à %s %s',
        ['transfer_received'] = 'Vous avez reçu les papiers d\'immatriculation de %s %s',
        ['dont_own_vehicle'] = 'Vous ne possédez pas ce véhicule'
    }
}



