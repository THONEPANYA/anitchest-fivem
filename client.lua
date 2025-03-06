local lastHealth = nil
local lastArmor = nil

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local health = GetEntityHealth(playerPed)
        local armor = GetPedArmour(playerPed)

        if lastHealth and lastHealth < health then
            TriggerServerEvent("anticheat:ban", "Illegal Health Regeneration Detected")
        end

        if lastArmor and lastArmor < armor then
            TriggerServerEvent("anticheat:ban", "Illegal Armor Boost Detected")
        end

        lastHealth = health
        lastArmor = armor

    end
end)

local speedHistory = {}

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local speed = GetEntitySpeed(playerPed) * 3.6

        table.insert(speedHistory, speed)
        if #speedHistory > 5 then
            table.remove(speedHistory, 1)
        end

        local totalSpeed = 0
        for _, s in ipars(speedHistory) do
            totalSpeed = totalSpeed + s
        end

        local avgSpeed = totalSpeed / #speedHistory

        if avhSpeed > 180 then
            TriggerServerEvent("anticheat:ban", "Speed Hack Detected")
        end
    end
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(5000)
        for key, value in pairs(_G) do
            if type(value) == "function" then
                local info = debug.getinfo(value, "S")
                if info and not string.find(info.source, "@resources/") then
                    TriggerServerEvent("anticheat:ban", "Lua Injection Detected")
                end
            end
        end
    end
    
end)

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local height = GetEntityHeightAboveGround(playerPed)

        if height > 15.0 and not IsPedInAnyVehicle(playerPed, false) then
            TriggerServerEvent("anticheat:ban", "Fly Hack Detected")
        end
    end
end)

local lastHealth = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerPed = PlayerPedId()
        local health = GetEntityHealth(playerPed)
        local _, currentAmmo = GetAmmoInClip(playerPed, GetSelectedPedWeapon(playerPed))

        if lastHealth and (lastHealth - health) > 100 then
            TriggerServerEvent("anticheat:ban", "One-Hit Kill Detected")
        end

        if currentAmmo > 9999 then
            TriggerServerEvent("anticheat:ban", "Infinite Ammo Detected")
        end

        lastHealth = health
    end
end)

RegisterServerEvent("anticheat:checkMoney")
AddEventHandler("anticheat:checkMoney", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        local money = xPlayer.getMoney()
        local bank = xPlayer.getAccount('bank').money
        
        if money > 10000000 or bank > 10000000 then
            TriggerServerEvent("anticheat:ban", "Money Hack Detected")
        end
    end
end)

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
                TriggerServerEvent("anticheat:ban", "Restricted Native Function Used: " .. native)
            end
        end
    end
end)
