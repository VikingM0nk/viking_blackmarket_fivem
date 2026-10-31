print("[Blackmarket] client/main.lua loaded")

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------
local activeMarket = nil
local marketPed = nil
local marketBlip = nil
local targetType = "fallback"
local InventoryType = "custom"
local isBlackmarketOpen = false
local openCooldown = false

---------------------------------------------------------------------
-- DEBUG
---------------------------------------------------------------------
local function bmDebug(msg)
    if Config.Debug then
        print("^3[Blackmarket]^7 " .. msg)
    end
end

---------------------------------------------------------------------
-- CONFIG-DRIVEN SPAWNS
---------------------------------------------------------------------
local BlackmarketSpawns = Config.BlackmarketSpawns

local function getRandomSpawn()
    return BlackmarketSpawns[math.random(1, #BlackmarketSpawns)]
end

RegisterCommand("bm_add", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    print(("[Blackmarket] vector3(%.2f, %.2f, %.2f), -- heading %.2f")
        :format(coords.x, coords.y, coords.z, heading))
end, false)

---------------------------------------------------------------------
-- SERVER REQUEST FOR SAFE COORD
---------------------------------------------------------------------
RegisterNetEvent("blackmarket:requestSafeCoord", function(ticket)
    local coords = getRandomSpawn()
    TriggerServerEvent("blackmarket:returnSafeCoord", ticket, coords)
end)

---------------------------------------------------------------------
-- BLIP HANDLING
---------------------------------------------------------------------
local function removeMarketBlip()
    if marketBlip then
        RemoveBlip(marketBlip)
        marketBlip = nil
    end
end

local function createMarketBlip(coords)
    if not Config.ShowMarketBlip then return end

    removeMarketBlip()

    marketBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(marketBlip, Config.MarketBlipSprite)
    SetBlipDisplay(marketBlip, 4)
    SetBlipScale(marketBlip, Config.MarketBlipScale)
    SetBlipColour(marketBlip, Config.MarketBlipColor)
    SetBlipAsShortRange(marketBlip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.MarketBlipName)
    EndTextCommandSetBlipName(marketBlip)
end

---------------------------------------------------------------------
-- PED SPAWNING (GROUND-SAFE)
---------------------------------------------------------------------
local function removeMarketPed()
    if DoesEntityExist(marketPed) then
        DeleteEntity(marketPed)
        marketPed = nil
    end
end

local function spawnMarketPed(coords, heading, pedModel)
    removeMarketPed()

    local model = GetHashKey(pedModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    -- Ground probe
    local groundZ = coords.z
    local found, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 50.0, false)
    if found then groundZ = z end

    marketPed = CreatePed(
        4,
        model,
        coords.x,
        coords.y,
        groundZ,
        heading,
        false,
        true
    )

    SetEntityInvincible(marketPed, true)
    SetBlockingOfNonTemporaryEvents(marketPed, true)
    FreezeEntityPosition(marketPed, true)

    SetModelAsNoLongerNeeded(model)
end

---------------------------------------------------------------------
-- UNIVERSAL PED-BASED TARGET SYSTEM
---------------------------------------------------------------------
local function removeMarketTarget()
    if not marketPed then return end

    if targetType == "qb" and exports['qb-target'] then
        exports['qb-target']:RemoveTargetEntity(marketPed)

    elseif targetType == "ox" and exports.ox_target then
        exports.ox_target:removeLocalEntity(marketPed)

    elseif targetType == "qtarget" and exports.qtarget then
        exports.qtarget:RemoveTargetEntity(marketPed)
    end
end

local function createMarketTarget(market)
    if not marketPed then return end

    local options = {
        {
            label = "Talk to Dealer",
            icon = "fas fa-user-secret",
            action = function()
                TriggerEvent("blackmarket:openNUI", market)
            end
        }
    }

    -- OX TARGET
    if targetType == "ox" and exports.ox_target then
        exports.ox_target:addLocalEntity(marketPed, {
            {
                name = "blackmarket_" .. market.name,
                label = "Talk to Dealer",
                icon = "fas fa-user-secret",
                onSelect = function()
                    TriggerEvent("blackmarket:openNUI", market)
                end
            }
        })
        return
    end

    -- QB TARGET
    if targetType == "qb" and exports['qb-target'] then
        exports['qb-target']:AddTargetEntity(marketPed, {
            options = options,
            distance = 2.0
        })
        return
    end

    -- QTARGET
    if targetType == "qtarget" and exports.qtarget then
        exports.qtarget:AddTargetEntity(marketPed, {
            options = options,
            distance = 2.0
        })
        return
    end

    -- FALLBACK (E-PRESS)
    CreateThread(function()
        while DoesEntityExist(marketPed) do
            Wait(0)
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - GetEntityCoords(marketPed))

            if dist < 2.0 then
                SetTextFont(4)
                SetTextScale(0.35, 0.35)
                SetTextColour(255, 255, 255, 215)
                SetTextCentre(true)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName("[E] Talk to Dealer")
                EndTextCommandDisplayText(0.5, 0.9)

                if IsControlJustReleased(0, 38) then
                    TriggerEvent("blackmarket:openNUI", market)
                end
            end
        end
    end)
end

---------------------------------------------------------------------
-- TARGET + INVENTORY DETECTION
---------------------------------------------------------------------
CreateThread(function()
    if GetResourceState("ox_target") == "started" then
        targetType = "ox"
    elseif GetResourceState("qb-target") == "started" then
        targetType = "qb"
    elseif GetResourceState("qtarget") == "started" then
        targetType = "qtarget"
    else
        targetType = "fallback"
    end

    print("^3[Target]^7 Detected target system: " .. targetType)
end)

CreateThread(function()
    if GetResourceState("ox_inventory") == "started" then
        InventoryType = "ox"
    elseif GetResourceState("qb-inventory") == "started" then
        InventoryType = "qb"
    elseif GetResourceState("qs-inventory") == "started" then
        InventoryType = "qs"
    end

    print("^2[BlackMarket]^7 Inventory detected: " .. InventoryType)
end)

---------------------------------------------------------------------
-- MARKET SYNC (BLIP + PED + TARGET)
---------------------------------------------------------------------
RegisterNetEvent("blackmarket:syncMarket", function(market)
    activeMarket = market

    if market and market.coords then
        createMarketBlip(market.coords)

        spawnMarketPed(
            market.coords,
            market.heading or 0.0,
            market.ped or "g_m_m_chicold_01"
        )

        removeMarketTarget()
        createMarketTarget(market)

    else
        removeMarketBlip()
        removeMarketPed()
        removeMarketTarget()
    end
end)

---------------------------------------------------------------------
-- NUI
---------------------------------------------------------------------
RegisterNetEvent("blackmarket:openNUI", function(market)
    if isBlackmarketOpen or openCooldown then return end

    activeMarket = market or activeMarket
    if not activeMarket then return end

    isBlackmarketOpen = true
    openCooldown = true

    SetNuiFocus(true, true)

    SendNUIMessage({
        action    = "open",
        market    = activeMarket,
        inventory = InventoryType
    })

    SetTimeout(500, function()
        openCooldown = false
    end)
end)

RegisterNUICallback("checkout", function(data, cb)
    if not isBlackmarketOpen then cb("ok") return end

    isBlackmarketOpen = false
    activeMarket = nil

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    TriggerServerEvent("blackmarket:checkout", data.market, data.cart)

    cb("ok")
end)

RegisterNUICallback("close", function(_, cb)
    if not isBlackmarketOpen then cb("ok") return end

    isBlackmarketOpen = false
    activeMarket = nil

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    cb("ok")
end)