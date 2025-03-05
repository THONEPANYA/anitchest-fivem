local xPlayer = ESX.GetPlayerFromId(src)
local src = source
local playerName = GetPlayerName(src)
local identifiers = GetPlayerIdentifiers(src)
local steamIdentifier = identifiers[1]

RegisterServerEvent("anitcheat:ban")
AddEventHandler("anitcheat:ban", function (reson)
    print("[Anit-Chest]" .. playerName .. "You Got Banned Reson:" .. reson)
    DropPlayer(src, "You Got Banned By AnitChest Reson: ")
end)

local maxMoney = 9999999999999999

RegisterServerEvent("esx:getSharedObject")
AddEventHandler("esx:getSharedObject", function ()

    if xPlayer then
        local money = xPlayer.getMoney()
        local bank = xPlayer.getAccount('bank').money

        if money > maxMoney or bank > maxMoney then
            print("[Anti-Cheat] Player " .. GetPlayerName(src) .. " Detected!")
            DropPlayer(src, "Detected Money Hack")
        end
    end

end)

local bannedVehicles = {
    "RHINO", "HYDRA", "LAZER", "OPPRESSOR" 
}

RegisterServerEvent("anticheat:checkVehicle")
AddEventHandler("anticheat:checkVehicle", function(vehicleModel)
    local src = source

    for _, v in pairs(bannedVehicles) do
        if vehicleModel == v then
            print("[Anti-Cheat] " .. GetPlayerName(src) .. " Spawn รถโกง: " .. v)
            DropPlayer(src, "ตรวจพบการ Spawn รถต้องห้าม!")
        end
    end
end)

local MySQL = require "mysql-async"

function IsPlayerBanned(identifier, callback)
    MySQL.Async.fetchScalar("SELECT COUNT(*) FROM banned_players WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(result)
        callback(result > 0)
    end)
end

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    
    deferrals.defer()
    Wait(100) 

    IsPlayerBanned(steamIdentifier, function(isBanned)
        if isBanned then
            deferrals.done("You Got Permanent Ban From Server!")
        else
            deferrals.done()
        end
    end)
end)

function BanPlayer(identifier, reason)
    MySQL.Async.execute("INSERT INTO banned_players (identifier, reason) VALUES (@identifier, @reason)", {
        ['@identifier'] = identifier,
        ['@reason'] = reason
    })
end

RegisterServerEvent("anticheat:ban")
AddEventHandler("anticheat:ban", function(reason)

    print("[Anti-Cheat] " .. GetPlayerName(src) .. " Banned: " .. reason)
    BanPlayer(steamIdentifier, reason)
    DropPlayer(src, "You Got Permanent Ban From Server! Reson: " .. reason)
end)

