--[[
    main.lua
    Grow a Garden 2 - Auto Harvest GUI
    Gabungin semua module + GUI interaktif
    
    Cara pakai:
    1. Copy semua isi file ini
    2. Paste ke executor Roblox
    3. GUI muncul, atur filter, tekan ON
]]

-- ============================================================
-- LOAD MODULES (atau langsung inline kalau executor nggak support require)
-- ============================================================

-- Kalau executor support require, pake ini:
-- local CropsModule = require(script.Parent.crops_data)
-- local Harvester = require(script.Parent.harvester)

-- Kalau nggak support, copy-paste isi crops_data.lua & harvester.lua di sini
-- (Untuk kemudahan, semua udah digabung jadi satu)

-- ============================================================
-- INLINE: CROPS DATA
-- ============================================================
local CropData = {
    ["Carrot"]       = {tier = "Common",    multi = false, price = 5,     weight = 0.80},
    ["Blueberry"]    = {tier = "Common",    multi = true,  price = 5,     weight = 1.15},
    ["Strawberry"]   = {tier = "Common",    multi = true,  price = 3,     weight = 1.00},
    ["Apple"]        = {tier = "Uncommon",  multi = true,  price = 12,    weight = 1.50},
    ["Tomato"]       = {tier = "Uncommon",  multi = true,  price = 9,     weight = 0.90},
    ["Tulip"]        = {tier = "Uncommon",  multi = false, price = 60,    weight = 0.50},
    ["Baby Cactus"]  = {tier = "Rare",      multi = true,  price = 70,    weight = 1.50},
    ["Bamboo"]       = {tier = "Rare",      multi = false, price = 800,   weight = 4.00},
    ["Cactus"]       = {tier = "Rare",      multi = true,  price = 40,    weight = 1.50},
    ["Corn"]         = {tier = "Rare",      multi = true,  price = 34,    weight = 3.00},
    ["Horned Melon"] = {tier = "Rare",      multi = true,  price = 200,   weight = 1.12},
    ["Pineapple"]    = {tier = "Rare",      multi = true,  price = 30,    weight = 5.00},
    ["Banana"]        = {tier = "Epic",     multi = true,  price = 35,    weight = 1.50},
    ["Coconut"]       = {tier = "Epic",     multi = true,  price = 60,    weight = 1.50},
    ["Glow Mushroom"] = {tier = "Epic",     multi = true,  price = 700,   weight = 7.00},
    ["Grape"]         = {tier = "Epic",     multi = true,  price = 45,    weight = 2.00},
    ["Green Bean"]    = {tier = "Epic",     multi = true,  price = 10,    weight = 0.50},
    ["Mango"]         = {tier = "Epic",     multi = true,  price = 90,    weight = 3.00},
    ["Mushroom"]      = {tier = "Epic",     multi = false, price = 13000, weight = 5.00},
    ["Acorn"]         = {tier = "Legendary", multi = true,  price = 200,   weight = 1.50},
    ["Cherry"]        = {tier = "Legendary", multi = true,  price = 350,   weight = 1.50},
    ["Dragon Fruit"]  = {tier = "Legendary", multi = true,  price = 150,   weight = 3.00},
    ["Fire Fern"]     = {tier = "Legendary", multi = true,  price = 900,   weight = 9.00},
    ["Poison Ivy"]    = {tier = "Legendary", multi = true,  price = 1700,  weight = 2.10},
    ["Sunflower"]     = {tier = "Legendary", multi = true,  price = 1750,  weight = 6.00},
    ["Ghost Pepper"]    = {tier = "Mythic", multi = true, price = 2500,  weight = 7.50},
    ["Poison Apple"]    = {tier = "Mythic", multi = true, price = 900,   weight = 2.25},
    ["Pomegranate"]     = {tier = "Mythic", multi = true, price = 900,   weight = 1.50},
    ["Venom Spitter"]  
