fx_version 'cerulean'
game 'gta5'

description 'CLASAM SCRIPT'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
  'client.lua',
}


server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua',
}

lua54 'yes'


