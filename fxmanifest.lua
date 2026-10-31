fx_version 'cerulean'
game 'gta5'

author 'VikingM0nk'
description 'Standalone Blackmarket System with NUI, Reputation, Rotation, Alerts'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
  
}

shared_scripts {
    'config.lua',
    
}

client_scripts {
    'client/main.lua',
    
}

server_scripts {
    'server/main.lua'
    
}
escrow_ignore {
    'config.lua',
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'README.md'
}