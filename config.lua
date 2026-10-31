Config = {}

Config.Debug = true

-- SYSTEM MODES: "auto" or one of the explicit values below
Config.InventorySystem = "auto" -- "auto","ox","qb","lj","qs","codem","core","custom"
Config.MoneySystem     = "auto" -- "auto","qb","esx","ox","custom"
Config.NotifySystem    = "auto" -- "auto","qb","ox","okok","mythic","esx","custom"
Config.DispatchSystem  = "auto" -- "auto","ps","cd","qs","core","linden","none","custom"

Config.BlackmarketMoneyAccount = "bank" -- "cash" or "bank"

-- OPTIONAL CUSTOM OVERRIDES (used when system = "custom")
Config.Inventory = {
    AddItem = function(src, item, amount)
        -- custom inventory add here
        return false
    end
}

Config.Money = {
    Remove = function(src, amount)
        -- custom money remove here
        return false
    end
}

Config.Notify = {
    Success = function(src, msg) end,
    Error   = function(src, msg) end,
    Info    = function(src, msg) end
}

Config.Dispatch = {
    Alert = function(coords, message) end
}

-- POLICE / DISPATCH
Config.PoliceAlert = {
    Enabled  = true,
    Chance   = 25, -- %
    Cooldown = 30, -- seconds
    Message  = "Suspicious blackmarket activity reported",
    Jobs     = { "police", "sheriff", "trooper" }
}

-- REPUTATION
Config.Reputation = {
    Enabled = true,
    Default = 0,
    Min     = 0,
    Max     = 100,
    PriceModifier = {
        [0]  = 1.2,
        [20] = 1.0,
        [50] = 0.9,
        [80] = 0.8
    }
}

-- MARKET ROTATION
Config.RotateMarkets    = true
Config.RotationInterval = 120 -- seconds
Config.BlackmarketSpawns = {

    -----------------------------------------------------------------
    -- LOS SANTOS (Industrial Examples)
    -----------------------------------------------------------------
    vector3(713.42, -963.55, 23.48),
    vector3(847.12, -1023.44, 28.19),
    vector3(540.11, -1623.44, 28.28),

    -----------------------------------------------------------------
    -- SANDY SHORES (Mixed Examples)
    -----------------------------------------------------------------
    vector3(1935.55, 3820.33, 32.44),
    vector3(1785.44, 3890.33, 34.02),
    vector3(2100.33, 3835.44, 32.52),

    -----------------------------------------------------------------
    -- GRAPESEED (Industrial Farm Examples)
    -----------------------------------------------------------------
    vector3(1702.44, 4729.55, 42.12),
    vector3(1732.55, 4768.21, 42.14),
    vector3(1801.33, 4922.11, 48.08),

    -----------------------------------------------------------------
    -- PALETO BAY (Industrial Examples)
    -----------------------------------------------------------------
    vector3(-441.22, 6020.33, 31.52),
    vector3(-475.33, 6205.44, 31.72),
    vector3(-715.44, 6040.22, 31.22),
}

-- Blip settings
Config.ShowMarketBlip = true
Config.MarketBlipSprite = 431
Config.MarketBlipScale = 0.9
Config.MarketBlipColor = 1
Config.MarketBlipName = "Blackmarket"



-- BLACKMARKETS
Config.Blackmarkets = {
    {
        name  = "Docks Blackmarket",
        coords = vec3(-522.61, 58.73, 52.58),
        npc = {
            model    = `g_m_m_chigoon_02`,
            coords   = vec4(-522.61, 58.73, 52.58, 0.0),
            heading  = 90.0,
            scenario = "WORLD_HUMAN_SMOKING"
        },
        alerts = true,
        items = {
            { item = "lockpick",         label = "Lockpick",          price = 750,  rep = 0  },
            { item = "advancedlockpick", label = "Advanced Lockpick", price = 1500, rep = 10 },
            { item = "thermite",         label = "Thermite",          price = 5000, rep = 25 }
        }
    }
}