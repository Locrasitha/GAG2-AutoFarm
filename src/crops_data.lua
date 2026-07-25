--[[
    crops_data.lua
    Data crops dari Grow a Garden 2 Wiki
    Source: https://growagarden2.fandom.com/wiki/Crops
    Last Updated: 2026-07-25
    
    Total Crops: 36
    Tiers: Common, Uncommon, Rare, Epic, Legendary, Mythic, Super, Secret
    
    Usage:
    local CropsModule = loadstring(game:HttpGet("RAW_URL/crops_data.lua"))()
    -- atau
    local CropsModule = require(script.Parent.crops_data)
]]

local CropsModule = {}

-- ============================================================
-- ALL CROP DATA (36 crops total)
-- Format: [CropName] = {tier, multi, price, weight}
-- ============================================================
CropsModule.CropData = {
    -- ============ COMMON (3 crops) ============
    ["Carrot"]       = {tier = "Common",    multi = false, price = 5,     weight = 0.80},
    ["Blueberry"]    = {tier = "Common",    multi = true,  price = 5,     weight = 1.15},
    ["Strawberry"]   = {tier = "Common",    multi = true,  price = 3,     weight = 1.00},

    -- ============ UNCOMMON (3 crops) ============
    ["Apple"]        = {tier = "Uncommon",  multi = true,  price = 12,    weight = 1.50},
    ["Tomato"]       = {tier = "Uncommon",  multi = true,  price = 9,     weight = 0.90},
    ["Tulip"]        = {tier = "Uncommon",  multi = false, price = 60,    weight = 0.50},

    -- ============ RARE (6 crops) ============
    ["Baby Cactus"]  = {tier = "Rare",      multi = true,  price = 70,    weight = 1.50},
    ["Bamboo"]       = {tier = "Rare",      multi = false, price = 800,   weight = 4.00},
    ["Cactus"]       = {tier = "Rare",      multi = true,  price = 40,    weight = 1.50},
    ["Corn"]         = {tier = "Rare",      multi = true,  price = 34,    weight = 3.00},
    ["Horned Melon"] = {tier = "Rare",      multi = true,  price = 200,   weight = 1.12},
    ["Pineapple"]    = {tier = "Rare",      multi = true,  price = 30,    weight = 5.00},

    -- ============ EPIC (7 crops) ============
    ["Banana"]        = {tier = "Epic",     multi = true,  price = 35,    weight = 1.50},
    ["Coconut"]       = {tier = "Epic",     multi = true,  price = 60,    weight = 1.50},
    ["Glow Mushroom"] = {tier = "Epic",     multi = true,  price = 700,   weight = 7.00},
    ["Grape"]         = {tier = "Epic",     multi = true,  price = 45,    weight = 2.00},
    ["Green Bean"]    = {tier = "Epic",     multi = true,  price = 10,    weight = 0.50},
    ["Mango"]         = {tier = "Epic",     multi = true,  price = 90,    weight = 3.00},
    ["Mushroom"]      = {tier = "Epic",     multi = false, price = 13000, weight = 5.00},

    -- ============ LEGENDARY (6 crops) ============
    ["Acorn"]         = {tier = "Legendary", multi = true,  price = 200,   weight = 1.50},
    ["Cherry"]        = {tier = "Legendary", multi = true,  price = 350,   weight = 1.50},
    ["Dragon Fruit"]  = {tier = "Legendary", multi = true,  price = 150,   weight = 3.00},
    ["Fire Fern"]     = {tier = "Legendary", multi = true,  price = 900,   weight = 9.00},
    ["Poison Ivy"]    = {tier = "Legendary", multi = true,  price = 1700,  weight = 2.10},
    ["Sunflower"]     = {tier = "Legendary", multi = true,  price = 1750,  weight = 6.00},

    -- ============ MYTHIC (5 crops) ============
    ["Ghost Pepper"]    = {tier = "Mythic", multi = true, price = 2500,  weight = 7.50},
    ["Poison Apple"]    = {tier = "Mythic", multi = true, price = 900,   weight = 2.25},
    ["Pomegranate"]     = {tier = "Mythic", multi = true, price = 900,   weight = 1.50},
    ["Venom Spitter"]   = {tier = "Mythic", multi = true, price = 3800,  weight = 9.00},
    ["Venus Fly Trap"]  = {tier = "Mythic", multi = true, price = 3000,  weight = 3.00},

    -- ============ SUPER (5 crops) ============
    ["Dragon's Breath"] = {tier = "Super", multi = true, price = 3400,  weight = 7.50},
    ["Hypno Bloom"]     = {tier = "Super", multi = true, price = 9500,  weight = 9.00},
    ["Moon Bloom"]      = {tier = "Super", multi = true, price = 9000,  weight = 9.00},
    ["Sun Bloom"]       = {tier = "Super", multi = true, price = 9000,  weight = 9.00},
    ["Star Fruit"]      = {tier = "Super", multi = true, price = 6000,  weight = 9.00},

    -- ============ SECRET (1 crop) ============
    ["Eclipse Bloom"]   = {tier = "Secret", multi = true, price = 12000, weight = 9.00},
}

-- ============================================================
-- TIER COLORS (buat GUI)
-- ============================================================
CropsModule.TierColors = {
    ["Common"]    = Color3.fromRGB(150, 150, 150),   -- Gray
    ["Uncommon"]  = Color3.fromRGB(30, 180, 30),     -- Green
    ["Rare"]      = Color3.fromRGB(30, 120, 255),    -- Blue
    ["Epic"]      = Color3.fromRGB(160, 50, 255),    -- Purple
    ["Legendary"] = Color3.fromRGB(255, 150, 30),    -- Orange
    ["Mythic"]    = Color3.fromRGB(255, 50, 100),    -- Pink/Red
    ["Super"]     = Color3.fromRGB(0, 255, 200),     -- Cyan
    ["Secret"]    = Color3.fromRGB(255, 215, 0),     -- Gold
}

-- ============================================================
-- TIER ORDER (buat sorting)
-- ============================================================
CropsModule.TierOrder = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Super = 7,
    Secret = 8
}

-- ============================================================
-- ALL TIERS LIST
-- ============================================================
CropsModule.AllTiers = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Super",
    "Secret"
}

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Dapetin semua crop name
function CropsModule.GetAllCropNames()
    local names = {}
    for name, _ in pairs(CropsModule.CropData) do
        table.insert(names, name)
    end
    -- Sort alphabetically
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

-- Dapetin crops sorted by tier lalu alphabet
function CropsModule.GetSortedCrops()
    local sorted = {}
    for name, data in pairs(CropsModule.CropData) do
        table.insert(sorted, {
            name = name,
            tier = data.tier,
            multi = data.multi,
            price = data.price,
            weight = data.weight
        })
    end
    
    table.sort(sorted, function(a, b)
        local orderA = CropsModule.TierOrder[a.tier] or 99
        local orderB = CropsModule.TierOrder[b.tier] or 99
        if orderA ~= orderB then
            return orderA < orderB
        end
        return a.name:lower() < b.name:lower()
    end)
    
    return sorted
end

-- Dapetin crops by tier
function CropsModule.GetCropsByTier(tier)
    local result = {}
    for name, data in pairs(CropsModule.CropData) do
        if data.tier == tier then
            table.insert(result, {
                name = name,
                multi = data.multi,
                price = data.price,
                weight = data.weight
            })
        end
    end
    table.sort(result, function(a, b) return a.name:lower() < b.name:lower() end)
    return result
end

-- Dapetin total crops per tier
function CropsModule.GetTierCount(tier)
    local count = 0
    for _, data in pairs(CropsModule.CropData) do
        if data.tier == tier then
            count = count + 1
        end
    end
    return count
end

-- Dapetin total semua crops
function CropsModule.GetTotalCrops()
    local count = 0
    for _ in pairs(CropsModule.CropData) do
        count = count + 1
    end
    return count
end

-- Cek crop valid
function CropsModule.IsValidCrop(name)
    return CropsModule.CropData[name] ~= nil
end

-- Cek multi-harvest
function CropsModule.IsMultiHarvest(name)
    local data = CropsModule.CropData[name]
    return data and data.multi or false
end

-- Dapetin harga
function CropsModule.GetPrice(name)
    local data = CropsModule.CropData[name]
    return data and data.price or 0
end

-- Dapetin tier
function CropsModule.GetTier(name)
    local data = CropsModule.CropData[name]
    return data and data.tier or "Unknown"
end

-- Dapetin weight
function CropsModule.GetWeight(name)
    local data = CropsModule.CropData[name]
    return data and data.weight or 0
end

-- Dapetin warna tier
function CropsModule.GetTierColor(tier)
    return CropsModule.TierColors[tier] or Color3.fromRGB(100, 100, 100)
end

-- Dapetin semua info crop
function CropsModule.GetCropInfo(name)
    local data = CropsModule.CropData[name]
    if not data then return nil end
    return {
        name = name,
        tier = data.tier,
        multi = data.multi,
        price = data.price,
        weight = data.weight,
        color = CropsModule.TierColors[data.tier]
    }
end

-- Dapetin crops yang multi-harvest aja
function CropsModule.GetMultiHarvestCrops()
    local result = {}
    for name, data in pairs(CropsModule.CropData) do
        if data.multi then
            table.insert(result, name)
        end
    end
    table.sort(result, function(a, b) return a:lower() < b:lower() end)
    return result
end

-- Dapetin crops yang single-harvest aja
function CropsModule.GetSingleHarvestCrops()
    local result = {}
    for name, data in pairs(CropsModule.CropData) do
        if not data.multi then
            table.insert(result, name)
        end
    end
    table.sort(result, function(a, b) return a:lower() < b:lower() end)
    return result
end

-- Dapetin crops dengan harga minimum
function CropsModule.GetCropsByMinPrice(minPrice)
    local result = {}
    for name, data in pairs(CropsModule.CropData) do
        if data.price >= minPrice then
            table.insert(result, {
                name = name,
                tier = data.tier,
                multi = data.multi,
                price = data.price
            })
        end
    end
    table.sort(result, function(a, b) return a.price > b.price end)
    return result
end

-- Dapetin top N crops termahal
function CropsModule.GetTopExpensive(n)
    local all = {}
    for name, data in pairs(CropsModule.CropData) do
        table.insert(all, {
            name = name,
            tier = data.tier,
            multi = data.multi,
            price = data.price
        })
    end
    table.sort(all, function(a, b) return a.price > b.price end)
    n = n or 10
    local result = {}
    for i = 1, math.min(n, #all) do
        table.insert(result, all[i])
    end
    return result
end

-- Print summary
function CropsModule.PrintSummary()
    print("=" .. string.rep("=", 55))
    print("   🌿 GROW A GARDEN 2 - CROP DATA SUMMARY")
    print("=" .. string.rep("=", 55))
    print("   Total Crops : " .. CropsModule.GetTotalCrops())
    print("   Source      : https://growagarden2.fandom.com/wiki/Crops")
    print("   Last Update : 2026-07-25")
    print("-" .. string.rep("-", 55))
    print(string.format("   %-12s | %-5s | %s", "TIER", "COUNT", "CROPS"))
    print("-" .. string.rep("-", 55))
    
    for _, tier in ipairs(CropsModule.AllTiers) do
        local count = CropsModule.GetTierCount(tier)
        local crops = CropsModule.GetCropsByTier(tier)
        local names = {}
        for _, c in ipairs(crops) do
            local icon = c.multi and "🔄" or "⚠️"
            table.insert(names, c.name .. " " .. icon)
        end
        print(string.format("   %-12s | %-5d | %s", tier, count, table.concat(names, ", ")))
    end
    
    print("-" .. string.rep("-", 55))
    
    -- Multi vs Single stats
    local multi = CropsModule.GetMultiHarvestCrops()
    local single = CropsModule.GetSingleHarvestCrops()
    print(string.format("   Multi-Harvest  : %d crops", #multi))
    print(string.format("   Single-Harvest : %d crops (%s)", #single, table.concat(single, ", ")))
    
    print("-" .. string.rep("-", 55))
    
    -- Top 5 termahal
    print("   TOP 5 TERMAHAL:")
    local top5 = CropsModule.GetTopExpensive(5)
    for i, crop in ipairs(top5) do
        print(string.format("   %d. %-20s [%-10s] 💰%d", i, crop.name, crop.tier, crop.price))
    end
    
    print("=" .. string.rep("=", 55))
end

-- Print detail satu crop
function CropsModule.PrintCropDetail(name)
    local info = CropsModule.GetCropInfo(name)
    if not info then
        print("❌ Crop '" .. name .. "' tidak ditemukan!")
        return
    end
    
    print("┌" .. string.rep("─", 40) .. "┐")
    print("│  📦 " .. info.name)
    print("├" .. string.rep("─", 40) .. "┤")
    print("│  Tier          : " .. info.tier)
    print("│  Multi-Harvest : " .. (info.multi and "✅ Ya" or "❌ Tidak"))
    print("│  Base Price    : 💰" .. info.price .. " Sheckles")
    print("│  Base Weight   : " .. info.weight .. " kg")
    print("└" .. string.rep("─", 40) .. "┘")
end

return CropsModule
