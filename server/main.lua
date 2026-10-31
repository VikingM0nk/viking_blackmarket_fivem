print("[Blackmarket] server/main.lua loaded")

---------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------
local activeMarket = nil

---------------------------------------------------------------------
-- DEBUG
---------------------------------------------------------------------
local function bmDebug(msg)
    if Config.Debug then
        print("^3[Blackmarket]^7 " .. msg)
    end
end

---------------------------------------------------------------------
-- SYSTEM DETECTION
---------------------------------------------------------------------
local inventorySystem = Config.InventorySystem
local moneySystem     = Config.MoneySystem
local notifySystem    = Config.NotifySystem
local dispatchSystem  = Config.DispatchSystem

CreateThread(function()
    -- INVENTORY
    if inventorySystem == "auto" then
        if GetResourceState("ox_inventory") == "started" then inventorySystem = "ox"
        elseif GetResourceState("qb-inventory") == "started" then inventorySystem = "qb"
        elseif GetResourceState("lj-inventory") == "started" then inventorySystem = "lj"
        elseif GetResourceState("qs-inventory") == "started" then inventorySystem = "qs"
        elseif GetResourceState("codem-inventory") == "started" then inventorySystem = "codem"
        elseif GetResourceState("core_inventory") == "started" then inventorySystem = "core"
        else inventorySystem = "custom" end
    end

    -- MONEY
    if moneySystem == "auto" then
        if GetResourceState("qb-core") == "started" then moneySystem = "qb"
        elseif GetResourceState("es_extended") == "started" then moneySystem = "esx"
        elseif GetResourceState("ox_inventory") == "started" then moneySystem = "ox"
        else moneySystem = "custom" end
    end

    -- NOTIFY
    if notifySystem == "auto" then
        if GetResourceState("qb-core") == "started" then notifySystem = "qb"
        elseif GetResourceState("ox_lib") == "started" then notifySystem = "ox"
        elseif GetResourceState("okokNotify") == "started" then notifySystem = "okok"
        elseif GetResourceState("mythic_notify") == "started" then notifySystem = "mythic"
        elseif GetResourceState("es_extended") == "started" then notifySystem = "esx"
        else notifySystem = "custom" end
    end

    -- DISPATCH
    if dispatchSystem == "auto" then
        if GetResourceState("ps-dispatch") == "started" then dispatchSystem = "ps"
        elseif GetResourceState("cd_dispatch") == "started" then dispatchSystem = "cd"
        elseif GetResourceState("qs-dispatch") == "started" then dispatchSystem = "qs"
        elseif GetResourceState("core_dispatch") == "started" then dispatchSystem = "core"
        elseif GetResourceState("linden_outlawalert") == "started" then dispatchSystem = "linden"
        else dispatchSystem = "none" end
    end

    print("^3[Inventory]^7 Detected inventory system: " .. inventorySystem)
    print("^3[Money]^7 Detected money system: " .. moneySystem)
    print("^3[Notify]^7 Detected notify system: " .. notifySystem)
    print("^3[Police]^7 Detected dispatch system: " .. dispatchSystem)
end)

---------------------------------------------------------------------
-- SAFE UNIVERSAL INVENTORY WRAPPER
---------------------------------------------------------------------
local function AddItem(src, itemName, amount)
    amount = tonumber(amount)
    if not amount or amount < 1 or amount > 10 then
        print("[Blackmarket] BLOCKED: Invalid amount from src " .. src)
        return false
    end

    local valid = false
    if activeMarket and activeMarket.items then
        for _, item in ipairs(activeMarket.items) do
            if item.item == itemName then
                valid = true
                break
            end
        end
    end

    if not valid then
        print("[Blackmarket] BLOCKED: Invalid item '" .. tostring(itemName) .. "' from src " .. src)
        return false
    end

    local ok = false

    if inventorySystem == "ox" then
        ok = exports.ox_inventory:AddItem(src, itemName, amount)

    elseif inventorySystem == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then ok = Player.Functions.AddItem(itemName, amount) end

    elseif inventorySystem == "qs" then
        ok = exports['qs-inventory']:AddItem(src, itemName, amount)

    elseif inventorySystem == "codem" then
       ok = exports['codem-inventory']:AddItem(source, item, amount)

    elseif inventorySystem == "core" then
        ok = exports.core_inventory:addItem(src, itemName, amount, nil, nil)

    elseif inventorySystem == "custom" and Config.Inventory.AddItem then
        ok = Config.Inventory.AddItem(src, itemName, amount)
    end

    if ok then
        print(("[Blackmarket] Gave %sx %s to %s"):format(amount, itemName, src))
    else
        print(("[Blackmarket] FAILED to give %s to %s"):format(itemName, src))
    end

    return ok
end

---------------------------------------------------------------------
-- MONEY WRAPPER
---------------------------------------------------------------------
local function RemoveMoney(src, amount)
    if moneySystem == "qb" then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        local acc = Config.BlackmarketMoneyAccount == "cash" and "cash" or "bank"
        if Player.Functions.RemoveMoney(acc, amount) then return true end

    elseif moneySystem == "esx" then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        local acc = Config.BlackmarketMoneyAccount == "cash" and "money" or "bank"
        if xPlayer.getAccount(acc).money >= amount then
            xPlayer.removeAccountMoney(acc, amount)
            return true
        end

    elseif moneySystem == "ox" then
        local acc = Config.BlackmarketMoneyAccount == "cash" and "cash" or "bank"
        return exports.ox_inventory:RemoveItem(src, acc, amount)

    elseif moneySystem == "custom" and Config.Money.Remove then
        return Config.Money.Remove(src, amount)
    end

    return false
end

---------------------------------------------------------------------
-- NOTIFY WRAPPERS
---------------------------------------------------------------------
local function NotifySuccess(src, msg)
    if notifySystem == "qb" then
        TriggerClientEvent('QBCore:Notify', src, msg, "success")
    elseif notifySystem == "ox" then
        TriggerClientEvent('ox_lib:notify', src, { description = msg, type = 'success' })
    elseif notifySystem == "okok" then
        TriggerClientEvent('okokNotify:Alert', src, "Blackmarket", msg, 5000, 'success')
    elseif notifySystem == "mythic" then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = msg })
    elseif notifySystem == "esx" then
        TriggerClientEvent('esx:showNotification', src, msg)
    elseif notifySystem == "custom" and Config.Notify.Success then
        Config.Notify.Success(src, msg)
    end
end

local function NotifyError(src, msg)
    if notifySystem == "qb" then
        TriggerClientEvent('QBCore:Notify', src, msg, "error")
    elseif notifySystem == "ox" then
        TriggerClientEvent('ox_lib:notify', src, { description = msg, type = 'error' })
    elseif notifySystem == "okok" then
        TriggerClientEvent('okokNotify:Alert', src, "Blackmarket", msg, 5000, 'error')
    elseif notifySystem == "mythic" then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = msg })
    elseif notifySystem == "esx" then
        TriggerClientEvent('esx:showNotification', src, msg)
    elseif notifySystem == "custom" and Config.Notify.Error then
        Config.Notify.Error(src, msg)
    end
end

---------------------------------------------------------------------
-- DISPATCH WRAPPER
---------------------------------------------------------------------
local lastAlert = 0

local function AlertPolice(coords)
    if not Config.PoliceAlert.Enabled then return end

    local now = os.time()
    if now - lastAlert < Config.PoliceAlert.Cooldown then return end
    if math.random(100) > Config.PoliceAlert.Chance then return end
    lastAlert = now

    local msg = Config.PoliceAlert.Message or "Suspicious activity reported"

    if dispatchSystem == "ps" then
        exports['ps-dispatch']:CustomAlert({
            coords = coords,
            message = msg,
            dispatchCode = "10-90",
            radius = 0,
            job = Config.PoliceAlert.Jobs
        })
    elseif dispatchSystem == "cd" then
        TriggerEvent('cd_dispatch:AddNotification', {
            job_table = Config.PoliceAlert.Jobs,
            coords = coords,
            title = "Blackmarket",
            message = msg,
            flash = 0,
            unique_id = tostring(math.random(11111, 99999)),
            sound = 1
        })
    elseif dispatchSystem == "qs" then
        exports['qs-dispatch']:CreateAlert({
            coords = coords,
            message = msg,
            jobs = Config.PoliceAlert.Jobs
        })
    elseif dispatchSystem == "core" then
        TriggerEvent('core_dispatch:addCall', "Blackmarket", msg, coords, Config.PoliceAlert.Jobs, false)
    elseif dispatchSystem == "linden" then
        TriggerEvent('linden_outlawalert:notify', msg, coords)
    elseif dispatchSystem == "custom" and Config.Dispatch.Alert then
        Config.Dispatch.Alert(coords, msg)
    end
end

---------------------------------------------------------------------
-- REPUTATION
---------------------------------------------------------------------
local repStore = {}

local function GetReputation(src)
    if not Config.Reputation.Enabled then return 0 end
    local id = tostring(src)
    if not repStore[id] then repStore[id] = Config.Reputation.Default or 0 end
    return repStore[id]
end

local function AddReputation(src, amount)
    if not Config.Reputation.Enabled then return end
    local id = tostring(src)
    local current = GetReputation(src)
    local new = current + (amount or 0)
    if new < Config.Reputation.Min then new = Config.Reputation.Min end
    if new > Config.Reputation.Max then new = Config.Reputation.Max end
    repStore[id] = new
end

local function ModifyPrice(basePrice, rep)
    if not Config.Reputation.Enabled then return basePrice end
    local modifier = 1.0
    for threshold, mult in pairs(Config.Reputation.PriceModifier) do
        if rep >= threshold and mult < modifier then
            modifier = mult
        end
    end
    return math.floor(basePrice * modifier)
end

---------------------------------------------------------------------
-- POLICE STATION EXCLUSION (SERVER-SIDE CHECK)
---------------------------------------------------------------------
local PoliceStations = {
    { coords = vector3(441.2, -981.9, 30.7), radius = 200.0 },
    { coords = vector3(1851.2, 3683.5, 34.2), radius = 200.0 },
    { coords = vector3(-449.8, 6012.8, 31.7), radius = 200.0 },
    { coords = vector3(825.0, -1290.0, 28.2), radius = 200.0 },
}

local function isNearPoliceStation(coords)
    for _, station in ipairs(PoliceStations) do
        if #(coords - station.coords) < station.radius then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------
-- SAFE COORD REQUEST (CLIENT PROBE)
---------------------------------------------------------------------
local pendingCallbacks = {}

local function requestSafeCoord(callback)
    local ticket = math.random(100000, 999999)
    pendingCallbacks[ticket] = callback
    TriggerClientEvent("blackmarket:requestSafeCoord", -1, ticket)
end

RegisterNetEvent("blackmarket:returnSafeCoord", function(ticket, coords)
    local cb = pendingCallbacks[ticket]
    if not cb then return end
    pendingCallbacks[ticket] = nil

    if isNearPoliceStation(coords) then
        print("[Blackmarket] Client returned coords near police station, retrying...")
        requestSafeCoord(cb)
        return
    end

    cb(coords)
end)

---------------------------------------------------------------------
-- BUILD MARKET OBJECT (INCLUDES ITEMS FOR NUI)
---------------------------------------------------------------------
local function buildMarket(coords)
    local base = Config.Blackmarkets[1]

    return {
        name       = base.name or "Dynamic Blackmarket",
        coords     = coords,
        heading    = math.random(0, 360),
        ped        = base.ped or "g_m_m_chicold_01",
        items      = base.items or {},
        categories = base.categories or {} }
    end


---------------------------------------------------------------------
-- PICK RANDOM MARKET
---------------------------------------------------------------------
local function pickRandomMarket()
    print("[Blackmarket] Selecting dynamic random market...")

    requestSafeCoord(function(coords)
        if not coords then
            print("[Blackmarket] ERROR: No coords returned from client")
            return
        end

        activeMarket = buildMarket(coords)

        print(("[Blackmarket] Active market set to: %.2f %.2f %.2f")
            :format(coords.x, coords.y, coords.z))

        TriggerClientEvent("blackmarket:syncMarket", -1, activeMarket)
    end)
end

---------------------------------------------------------------------
-- ROTATION THREAD
---------------------------------------------------------------------
CreateThread(function()
    Wait(500)
    pickRandomMarket()

    if not Config.RotateMarkets then return end

    while true do
        Wait(Config.RotationInterval * 1000)
        pickRandomMarket()
    end
end)

---------------------------------------------------------------------
-- CLIENT REQUESTS ACTIVE MARKET
---------------------------------------------------------------------
RegisterNetEvent("blackmarket:requestActiveMarket", function()
    local src = source
    if activeMarket then
        TriggerClientEvent("blackmarket:syncMarket", src, activeMarket)
    end
end)

---------------------------------------------------------------------
-- ITEM LOOKUP
---------------------------------------------------------------------
local function getItem(marketName, itemName)
    for _, market in ipairs(Config.Blackmarkets) do
        if market.name == marketName then
            for _, item in ipairs(market.items) do
                if item.item == itemName then
                    return item
                end
            end
        end
    end
    return nil
end

---------------------------------------------------------------------
-- PURCHASE
---------------------------------------------------------------------
RegisterNetEvent("blackmarket:purchaseItem", function(marketName, itemName, srcOverride)
    local src = srcOverride or source
    bmDebug(("Purchase request from %s for %s in %s"):format(src, itemName, marketName))

    local item = getItem(marketName, itemName)
    if not item then
        bmDebug("Invalid item purchase attempt: " .. tostring(itemName))
        return
    end

    local rep = GetReputation(src)
    if item.rep and rep < item.rep then
        NotifyError(src, "You are not trusted enough for this item.")
        return
    end

    local finalPrice = ModifyPrice(item.price, rep)

    if not RemoveMoney(src, finalPrice) then
        NotifyError(src, "You don't have enough money.")
        return
    end

    if not AddItem(src, item.item, 1) then
        NotifyError(src, "Failed to give item.")
        return
    end

    AddReputation(src, 1)
    NotifySuccess(src, "You bought a " .. item.label)

    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        local coords = GetEntityCoords(ped)
        AlertPolice(coords)
    end
end)

---------------------------------------------------------------------
-- CHECKOUT (CART)
---------------------------------------------------------------------
RegisterNetEvent("blackmarket:checkout", function(marketName, cart)
    local src = source

    if not activeMarket or activeMarket.name ~= marketName then
        print("[Blackmarket] Checkout blocked — market mismatch")
        return
    end

    for _, entry in ipairs(cart) do
        local itemName = entry.item
        local quantity = tonumber(entry.quantity) or 1

        for i = 1, quantity do
            TriggerEvent("blackmarket:purchaseItem", marketName, itemName, src)
        end
    end
end)