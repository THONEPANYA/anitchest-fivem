local playerPed = PlayerPedId()
local health = GetEntityHealth(playerPed)
local speed = GetEntitySpeed(playerPed) * 3.6
local lastCoords = nill
local coords = GetEntityCoords(playerPed)
local height = GetEntityHeightAboveGround(playerPed)
local lastHealth = nill
local health = GetEntityHealth(playerPed)
local _, currentAmmo = GetAmmoInClip(playerPed, GetSelectedPedWeapon(playerPed))
local newHealth = GetEntityHealth(playerPed)

--  GodMod / Speed Hack Detected
Citizen.CreateThread(function ()
    while true do
        Citizem.Wait(500)

        if lastHealth then
            if lastHealth > health and (lastHealth - health) > 0 then
                Citizen.Wait(500)

                if newHealth >= lastHealth then
                    TriggerServerEvent("anticheat:ban", "God Mode Detected (No HP Reduction)")
                end
            end
        end

        if speed > 300 then
            TriggerEvent("anitcheat:ban", "Speed Hack Detected!")
        end

        for _, weapon in ipairs(Config.Weapons) do
            if HasPedGotWeapon(playerPed, weapon, false) then
                if not weaponList[weapon] then
                    weaponList[weapon] = true
                    TriggerServerEvent("anitcheat:ban", "Illegal Weapon Detected: " .. weapon)
                end
            end
        end


    end
    
end)

-- Teleport Hack Detected
Cititzen.CreateThread(function ()
    while true do
    Cititzen.Wait(10000)

        if lastCoords then
            local distance = #(coords - lastCoords)
            if distance > 500 then
                TriggerServerEvent("anticheat:ban", "Teleport Hack Detected!")
            end
            
        end
        lastCoords = coords

    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if height > 10.0 and not IsPedInAnyVehicle(playerPed, false) then
            TriggerServerEvent("anticheat:ban", "Fly Hack Detected!")
        end
    end
end)

-- One Hit Kill Detected
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)

        if lastHealth and (lastHealth - health) > 100 then
            TriggerServerEvent("anticheat:ban", "One-Hit Kill Detected!")
        end

        lastHealth = health
    end
end)

-- Infinite Ammo Detected
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
    
        if currentAmmo > 9999 then
            TriggerServerEvent("anticheat:ban", "Infinite Ammo Detected!")
        end
    end
end)