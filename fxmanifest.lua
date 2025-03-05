fx_version 'cerulean'
game 'gta5'

author 'เจ้าอ้วงน้อย'
description 'Anti-Cheat FiveM'
version '1.0.0'

client_script {
    'client.lua'
}

server_script {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}
