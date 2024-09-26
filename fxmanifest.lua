server_script "@watchers/server/_rewriter.lua"
client_script "@EasyCore/client/watchdog/external_modules.lua"
server_script "@EasyCore/server/watchdog/external_modules.lua"

client_script "@STITGUARD/handler/stitguard.lua"

fx_version 'cerulean'
games { 'gta5' }

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    'server/**/*.lua',
}