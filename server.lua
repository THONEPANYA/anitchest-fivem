local MySQL = require "mysql-async"

-- ✅ ฟังก์ชันเช็คว่าผู้เล่นถูกแบนไหม
function IsPlayerBanned(identifier, callback)
    MySQL.Async.fetchScalar("SELECT COUNT(*) FROM banned_players WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(result)
        callback(result > 0)
    end)
end

-- ✅ ตรวจสอบผู้เล่นตอนเข้าสู่เซิร์ฟเวอร์
AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local steamIdentifier = identifiers[1] -- ใช้ Steam ID

    deferrals.defer()
    Wait(100)

    IsPlayerBanned(steamIdentifier, function(isBanned)
        if isBanned then
            deferrals.done("🚫 You are permanently banned from this server!")
        else
            deferrals.done()
        end
    end)
end)

-- ✅ ฟังก์ชันบันทึกการแบนผู้เล่นลงฐานข้อมูล
function BanPlayer(identifier, reason)
    MySQL.Async.execute("INSERT INTO banned_players (identifier, reason) VALUES (@identifier, @reason)", {
        ['@identifier'] = identifier,
        ['@reason'] = reason
    })
end

-- ✅ ตรวจจับโกงจาก Client และแบนถาวร
RegisterServerEvent("anticheat:ban")
AddEventHandler("anticheat:ban", function(reason)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local steamIdentifier = identifiers[1]

    print("[🚨 Anti-Cheat] " .. GetPlayerName(src) .. " was banned for: " .. reason)
    BanPlayer(steamIdentifier, reason)
    DropPlayer(src, "🚫 You have been permanently banned from this server. Reason: " .. reason)

    -- 🔔 แจ้งเตือนแอดมินผ่าน Discord
    sendToDiscord("🚨 Anti-Cheat Alert", "**" .. GetPlayerName(src) .. "** was banned!\n**Reason:** " .. reason, 16711680)
end)

-- ✅ ป้องกัน Money Hack (ตรวจจับเงินผิดปกติ)
RegisterServerEvent("anticheat:checkMoney")
AddEventHandler("anticheat:checkMoney", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        local money = xPlayer.getMoney()
        local bank = xPlayer.getAccount('bank').money

        if money > 10000000 or bank > 10000000 then
            print("[🚨 Anti-Cheat] " .. GetPlayerName(src) .. " was detected for Money Hack!")
            DropPlayer(src, "🚫 Money Hack Detected!")
        end
    end
end)

-- ✅ ป้องกันการ Spawn รถโกง
local bannedVehicles = {
    "RHINO", "HYDRA", "LAZER", "OPPRESSOR"
}

RegisterServerEvent("anticheat:checkVehicle")
AddEventHandler("anticheat:checkVehicle", function(vehicleModel)
    local src = source

    for _, v in pairs(bannedVehicles) do
        if vehicleModel == v then
            print("[🚨 Anti-Cheat] " .. GetPlayerName(src) .. " tried to spawn restricted vehicle: " .. v)
            DropPlayer(src, "🚫 Restricted Vehicle Spawn Detected!")
        end
    end
end)

-- ✅ ปิดการใช้ Native Functions ที่ใช้โกง
local blockedNatives = {
    "GiveWeaponToPed",
    "SetEntityCoords",
    "SetPedInfiniteAmmo"
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for _, native in ipairs(blockedNatives) do
            if Citizen.InvokeNative(GetHashKey(native)) then
                print("[🚨 Anti-Cheat] Blocked native function used: " .. native)
            end
        end
    end
end)

-- ✅ ส่งแจ้งเตือนไปยัง Discord
function sendToDiscord(name, message, color)
    local webhook = "YOUR_DISCORD_WEBHOOK_URL"
    local data = {
        username = "Anti-Cheat System",
        embeds = {{
            title = name,
            description = message,
            color = color
        }}
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end
