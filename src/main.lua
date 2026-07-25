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
    ["Venom Spitter"]   = {tier = "Mythic", multi = true, price = 3800,  weight = 9.00},
    ["Venus Fly Trap"]  = {tier = "Mythic", multi = true, price = 3000,  weight = 3.00},
    ["Dragon's Breath"] = {tier = "Super", multi = true, price = 3400,  weight = 7.50},
    ["Hypno Bloom"]     = {tier = "Super", multi = true, price = 9500,  weight = 9.00},
    ["Moon Bloom"]      = {tier = "Super", multi = true, price = 9000,  weight = 9.00},
    ["Sun Bloom"]       = {tier = "Super", multi = true, price = 9000,  weight = 9.00},
    ["Star Fruit"]      = {tier = "Super", multi = true, price = 6000,  weight = 9.00},
    ["Eclipse Bloom"]   = {tier = "Secret", multi = true, price = 12000, weight = 9.00},
}

local TierColors = {
    ["Common"]    = Color3.fromRGB(150, 150, 150),
    ["Uncommon"]  = Color3.fromRGB(30, 180, 30),
    ["Rare"]      = Color3.fromRGB(30, 120, 255),
    ["Epic"]      = Color3.fromRGB(160, 50, 255),
    ["Legendary"] = Color3.fromRGB(255, 150, 30),
    ["Mythic"]    = Color3.fromRGB(255, 50, 100),
    ["Super"]     = Color3.fromRGB(0, 255, 200),
    ["Secret"]    = Color3.fromRGB(255, 215, 0),
}

local TierOrder = {Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5, Mythic=6, Super=7, Secret=8}
local AllTiers = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super", "Secret"}

-- ============================================================
-- INLINE: HARVESTER
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local active = false
local paused = false
local harvestLoop = nil
local filter = {}

-- Init filter (default semua ON)
for cropName, _ in pairs(CropData) do
    filter[cropName] = true
end

local jarakHarvest = 60
local delayPanen = 0.5
local totalHarvested = 0
local totalEarnings = 0
local lastHarvestedName = ""
local statusCallback = nil

local function cekFilter(namaObjek)
    for cropName, boleh in pairs(filter) do
        if boleh and namaObjek:lower():find(cropName:lower()) then
            return true
        end
    end
    return false
end

local function cariDanPanen()
    local karakter = player.Character
    if not karakter then return false, "Karakter tidak ditemukan" end
    
    local rootPart = karakter:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false, "RootPart tidak ditemukan" end
    
    local target = nil
    local jarakMin = jarakHarvest
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt and obj:IsA("BasePart") then
            if cekFilter(obj.Name) then
                local jarak = (obj.Position - rootPart.Position).Magnitude
                if jarak < jarakMin then
                    jarakMin = jarak
                    target = obj
                end
            end
        end
    end
    
    if target then
        rootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.15)
        
        local prompt = target:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            pcall(function()
                fireproximityprompt(prompt)
            end)
            
            totalHarvested = totalHarvested + 1
            lastHarvestedName = target.Name
            
            local cropInfo = CropData[target.Name]
            if cropInfo then
                totalEarnings = totalEarnings + cropInfo.price
            end
            
            return true, target.Name, cropInfo
        end
    end
    
    return false, nil, nil
end

local function startHarvest(statusFn)
    if active then return end
    active = true
    paused = false
    totalHarvested = 0
    totalEarnings = 0
    statusCallback = statusFn
    
    if statusCallback then statusCallback("🔍 Mencari tanaman...") end
    
    harvestLoop = RunService.Heartbeat:Connect(function()
        if paused then return end
        
        local sukses, nama, info = cariDanPanen()
        
        if sukses then
            if statusCallback and info then
                statusCallback(string.format("✅ #%d %s [%s] 💰%d | Total: 💰%d",
                    totalHarvested, nama, info.tier, info.price, totalEarnings))
            elseif statusCallback then
                statusCallback(string.format("✅ #%d %s", totalHarvested, nama))
            end
            task.wait(delayPanen)
        else
            if statusCallback then statusCallback("🔍 Nyari tanaman terdekat...") end
            task.wait(1.0)
        end
    end)
end

local function stopHarvest()
    active = false
    paused = false
    if harvestLoop then
        harvestLoop:Disconnect()
        harvestLoop = nil
    end
    if statusCallback then
        statusCallback(string.format("⏸️ Berhenti | Total: %d | 💰%d", totalHarvested, totalEarnings))
    end
end

-- ============================================================
-- GUI BUILDER
-- ============================================================
local function bikinGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GAG2_AutoHarvest"
    ScreenGui.Parent = game.CoreGui
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 330, 0, 520)
    Main.Position = UDim2.new(0.67, 0, 0.08, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui
    
    -- Corner rounding (simulasi pake UICorner kalau support)
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = Main
    end)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(0, 330, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 310, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Text = "🌿 AUTO HARVEST - Grow a Garden 2"
    Title.TextColor3 = Color3.fromRGB(0, 255, 100)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = TitleBar
    
    -- Toggle ON/OFF Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(0, 310, 0, 38)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 42)
    ToggleBtn.Text = "🔴 AUTO HARVEST: OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 13
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = ToggleBtn
    end)
    
    -- Info Label
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(0, 310, 0, 18)
    InfoLabel.Position = UDim2.new(0, 10, 0, 85)
    InfoLabel.Text = "Filter: Klik tier atau crop buat toggle ON/OFF"
    InfoLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 10
    InfoLabel.Parent = Main
    
    -- Tier Filter Buttons
    local TierFrame = Instance.new("Frame")
    TierFrame.Size = UDim2.new(0, 310, 0, 55)
    TierFrame.Position = UDim2.new(0, 10, 0, 108)
    TierFrame.BackgroundTransparency = 1
    TierFrame.Parent = Main
    
    local TierButtons = {}
    local tierStates = {}
    
    for i, tier in ipairs(AllTiers) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tier_" .. tier
        btn.Size = UDim2.new(0, 72, 0, 24)
        btn.Position = UDim2.new(0, ((i-1) % 4) * 78, 0, math.floor((i-1)/4) * 28)
        btn.Text = "✅ " .. tier
        btn.BackgroundColor3 = TierColors[tier] or Color3.fromRGB(100, 100, 100)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.AutoButtonColor = false
        btn.Parent = TierFrame
        
        pcall(function()
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn
        end)
        
        tierStates[tier] = true
        
        btn.MouseButton1Click:Connect(function()
            tierStates[tier] = not tierStates[tier]
            local on = tierStates[tier]
            
            btn.Text = (on and "✅ " or "❌ ") .. tier
            btn.BackgroundColor3 = on and (TierColors[tier] or Color3.fromRGB(100, 100, 100)) or Color3.fromRGB(55, 55, 55)
            
            -- Update filter & crop toggles
            for cropName, data in pairs(CropData) do
                if data.tier == tier then
                    filter[cropName] = on
                    -- Update crop toggle kalau udah dibuat
                    local cropToggle = Main:FindFirstChild("Crop_" .. cropName)
                    if cropToggle then
                        cropToggle.Text = (on and "✅ " or "❌ ") .. cropName .. " [" .. tier .. "] " .. (data.multi and "🔄 " : "") .. "💰" .. data.price
                        cropToggle.BackgroundColor3 = on and (TierColors[tier] or Color3.fromRGB(80, 80, 80)) or Color3.fromRGB(45, 45, 45)
                    end
                end
            end
        end)
        
        TierButtons[tier] = btn
    end
    
    -- Scrolling Frame buat Crop List
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "CropScroll"
    ScrollFrame.Size = UDim2.new(0, 310, 0, 270)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 168)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ScrollFrame.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = ScrollFrame
    end)
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.Parent = ScrollFrame
    
    -- Sort crops
    local sortedCrops = {}
    for name, data in pairs(CropData) do
        table.insert(sortedCrops, {name=name, tier=data.tier, multi=data.multi, price=data.price})
    end
    
    table.sort(sortedCrops, function(a, b)
        local oa = TierOrder[a.tier] or 99
        local ob = TierOrder[b.tier] or 99
        if oa ~= ob then return oa < ob end
        return a.name:lower() < b.name:lower()
    end)
    
    -- Crop Toggles
    local cropToggles = {}
    
    for _, crop in ipairs(sortedCrops) do
        local btn = Instance.new("TextButton")
        btn.Name = "Crop_" .. crop.name
        btn.Size = UDim2.new(0, 290, 0, 28)
        btn.Text = "✅ " .. crop.name .. " [" .. crop.tier .. "] " .. (crop.multi and "🔄 " : "") .. "💰" .. crop.price
        btn.BackgroundColor3 = TierColors[crop.tier] or Color3.fromRGB(80, 80, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.AutoButtonColor = false
        btn.Parent = ScrollFrame
        
        pcall(function()
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn
        end)
        
        btn.MouseButton1Click:Connect(function()
            filter[crop.name] = not filter[crop.name]
            local on = filter[crop.name]
            
            btn.Text = (on and "✅ " or "❌ ") .. crop.name .. " [" .. crop.tier .. "] " .. (crop.multi and "🔄 " : "") .. "💰" .. crop.price
            btn.BackgroundColor3 = on and (TierColors[crop.tier] or Color3.fromRGB(80, 80, 80)) or Color3.fromRGB(45, 45, 45)
            
            -- Update tier button juga kalau perlu
            local allOn = true
            local allOff = true
            for n, d in pairs(CropData) do
                if d.tier == crop.tier then
                    if filter[n] then allOff = false else allOn = false end
                end
            end
            tierStates[crop.tier] = allOn
            if TierButtons[crop.tier] then
                TierButtons[crop.tier].Text = (allOn and "✅ " or (allOff and "❌ " or "◐ ")) .. crop.tier
                TierButtons[crop.tier].BackgroundColor3 = allOn and (TierColors[crop.tier] or Color3.fromRGB(100, 100, 100)) or (allOff and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(80, 80, 40))
            end
        end)
        
        cropToggles[crop.name] = btn
    end
    
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #sortedCrops * 31 + 10)
    
    -- Status Text
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(0, 310, 0, 22)
    StatusText.Position = UDim2.new(0, 10, 0, 442)
    StatusText.Text = "📋 Siap! Pilih crop lalu tekan tombol ON"
    StatusText.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 10
    StatusText.TextTruncate = Enum.TextTruncate.AtEnd
    StatusText.Parent = Main
    
    -- Action Buttons Row 1
    local SelectAllBtn = Instance.new("TextButton")
    SelectAllBtn.Size = UDim2.new(0, 100, 0, 26)
    SelectAllBtn.Position = UDim2.new(0, 10, 0, 468)
    SelectAllBtn.Text = "✅ Select All"
    SelectAllBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SelectAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectAllBtn.Font = Enum.Font.GothamBold
    SelectAllBtn.TextSize = 9
    SelectAllBtn.AutoButtonColor = false
    SelectAllBtn.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = SelectAllBtn
    end)
    
    SelectAllBtn.MouseButton1Click:Connect(function()
        for name, data in pairs(CropData) do
            filter[name] = true
            local btn = cropToggles[name]
            if btn then
                btn.Text = "✅ " .. name .. " [" .. data.tier .. "] " .. (data.multi and "🔄 " : "") .. "💰" .. data.price
                btn.BackgroundColor3 = TierColors[data.tier] or Color3.fromRGB(80, 80, 80)
            end
        end
        for tier, btn in pairs(TierButtons) do
            tierStates[tier] = true
            btn.Text = "✅ " .. tier
            btn.BackgroundColor3 = TierColors[tier] or Color3.fromRGB(100, 100, 100)
        end
    end)
    
    local ClearAllBtn = Instance.new("TextButton")
    ClearAllBtn.Size = UDim2.new(0, 100, 0, 26)
    ClearAllBtn.Position = UDim2.new(0, 115, 0, 468)
    ClearAllBtn.Text = "❌ Clear All"
    ClearAllBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ClearAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClearAllBtn.Font = Enum.Font.GothamBold
    ClearAllBtn.TextSize = 9
    ClearAllBtn.AutoButtonColor = false
    ClearAllBtn.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = ClearAllBtn
    end)
    
    ClearAllBtn.MouseButton1Click:Connect(function()
        for name, data in pairs(CropData) do
            filter[name] = false
            local btn = cropToggles[name]
            if btn then
                btn.Text = "❌ " .. name .. " [" .. data.tier .. "] " .. (data.multi and "🔄 " : "") .. "💰" .. data.price
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end
        end
        for tier, btn in pairs(TierButtons) do
            tierStates[tier] = false
            btn.Text = "❌ " .. tier
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        end
    end)
    
    local InvertBtn = Instance.new("TextButton")
    InvertBtn.Size = UDim2.new(0, 100, 0, 26)
    InvertBtn.Position = UDim2.new(0, 220, 0, 468)
    InvertBtn.Text = "🔄 Invert"
    InvertBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    InvertBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    InvertBtn.Font = Enum.Font.GothamBold
    InvertBtn.TextSize = 9
    InvertBtn.AutoButtonColor = false
    InvertBtn.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = InvertBtn
    end)
    
    InvertBtn.MouseButton1Click:Connect(function()
        for name, data in pairs(CropData) do
            filter[name] = not filter[name]
            local on = filter[name]
            local btn = cropToggles[name]
            if btn then
                btn.Text = (on and "✅ " or "❌ ") .. name .. " [" .. data.tier .. "] " .. (data.multi and "🔄 " : "") .. "💰" .. data.price
                btn.BackgroundColor3 = on and (TierColors[data.tier] or Color3.fromRGB(80, 80, 80)) or Color3.fromRGB(45, 45, 45)
            end
        end
        -- Update tier buttons
        for tier, _ in pairs(TierButtons) do
            local allOn = true
            for n, d in pairs(CropData) do
                if d.tier == tier and not filter[n] then allOn = false end
            end
            tierStates[tier] = allOn
        end
    end)
    
    -- Action Buttons Row 2
    local OnlyMultiBtn = Instance.new("TextButton")
    OnlyMultiBtn.Size = UDim2.new(0, 100, 0, 26)
    OnlyMultiBtn.Position = UDim2.new(0, 10, 0, 498)
    OnlyMultiBtn.Text = "🔄 Multi Only"
    OnlyMultiBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    OnlyMultiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OnlyMultiBtn.Font = Enum.Font.GothamBold
    OnlyMultiBtn.TextSize = 9
    OnlyMultiBtn.AutoButtonColor = false
    OnlyMultiBtn.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = OnlyMultiBtn
    end)
    
    OnlyMultiBtn.MouseButton1Click:Connect(function()
        for name, data in pairs(CropData) do
            filter[name] = data.multi
            local on = filter[name]
            local btn = cropToggles[name]
            if btn then
                btn.Text = (on and "✅ " or "❌ ") .. name .. " [" .. data.tier .. "] " .. (data.multi and "🔄 " : "") .. "💰" .. data.price
                btn.BackgroundColor3 = on and (TierColors[data.tier] or Color3.fromRGB(80, 80, 80)) or Color3.fromRGB(45, 45, 45)
            end
        end
    end)
    
    local OnlyLegendaryBtn = Instance.new("TextButton")
    OnlyLegendaryBtn.Size = UDim2.new(0, 100, 0, 26)
    OnlyLegendaryBtn.Position = UDim2.new(0, 115, 0, 498)
    OnlyLegendaryBtn.Text = "💎 Legendary+"
    OnlyLegendaryBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    OnlyLegendaryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OnlyLegendaryBtn.Font = Enum.Font.GothamBold
    OnlyLegendaryBtn.TextSize = 9
    OnlyLegendaryBtn.AutoButtonColor = false
    OnlyLegendaryBtn.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = OnlyLegendaryBtn
    end)
    
    OnlyLegendaryBtn.MouseButton1Click:Connect(function()
        local highTiers = {Legendary=true, Mythic=true, Super=true, Secret=true}
        for name, data in pairs(CropData) do
            filter[name] = highTiers[data.tier] or false
            local on = filter[name]
            local btn = cropToggles[name]
            if btn then
                btn.Text = (on and "✅ " or "❌ ") .. name .. " [" .. data.tier .. "] " .. (data.multi and "🔄 " : "") .. "💰" .. data.price
                btn.BackgroundColor3 = on and (TierColors[data.tier] or Color3.fromRGB(80, 80, 80)) or Color3.fromRGB(45, 45, 45)
            end
        end
        for tier, btn in pairs(TierButtons) do
            local on = highTiers[tier] or false
            tierStates[tier] = on
            btn.Text = (on and "✅ " or "❌ ") .. tier
            btn.BackgroundColor3 = on and (TierColors[tier] or Color3.fromRGB(100, 100, 100)) or Color3.fromRGB(55, 55, 55)
        end
    end)
    
    local OnlySingleBtn = Instance.new("TextButton")
    OnlySingleBtn.Size = UDim2.new(0, 100, 0, 26)
    OnlySingleBtn.Position = UDim2.new(0, 220, 0, 498)
    OnlySingleBtn.Text = "🚫 Non-Multi"
    OnlySingleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    OnlySingleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OnlySingleBtn.Font = Enum.Font.GothamBold
    OnlySingleBtn.TextSize = 9
    OnlySingleBtn.AutoButtonColor = false
    OnlySingleBtn.Parent = Main
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = OnlySingleBtn
    end)
    
    OnlySingleBtn.MouseButton1Click:Connect(function()
        for name, data in pairs(CropData) do
            filter[name] = not data.multi
            local on = filter[name]
            local btn = cropToggles[name]
            if btn then
                btn.Text = (on and "✅ " or "❌ ") .. name .. " [" .. data.tier .. "] " .. (data.multi and "🔄 " : "") .. "💰" .. data.price
                btn.BackgroundColor3 = on and (TierColors[data.tier] or Color3.fromRGB(80, 80, 80)) or Color3.fromRGB(45, 45, 45)
            end
        end
    end)
    
    -- ============================================================
    -- TOGGLE ON/OFF FUNCTIONALITY
    -- ============================================================
    local autoActive = false
    
    ToggleBtn.MouseButton1Click:Connect(function()
        autoActive = not autoActive
        
        if autoActive then
            ToggleBtn.Text = "🟢 AUTO HARVEST: ON 🔥"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
            StatusText.Text = "🔍 Mencari tanaman..."
            
            startHarvest(function(msg)
                StatusText.Text = msg
            end)
        else
            ToggleBtn.Text = "🔴 AUTO HARVEST: OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
            
            stopHarvest()
            StatusText.Text = "📋 Siap! Pilih crop lalu tekan tombol ON"
        end
    end)
end

-- ============================================================
-- INIT
-- ============================================================
bikinGUI()

-- Console welcome message
print([[
╔══════════════════════════════════════════════╗
║   🌿 GROW A GARDEN 2 - AUTO HARVEST v1.0    ║
║   by ngab buat ngab                         ║
╠══════════════════════════════════════════════╣
║   ✅ GUI Loaded!                            ║
║   📋 36 Crops from Wiki                     ║
║   🎨 8 Tiers (Common → Secret)              ║
║   🔄 Multi-Harvest Filter                   ║
║   💰 Price Info                             ║
║                                             ║
║   Cara pakai:                               ║
║   1. Pilih filter crop/tier                 ║
║   2. Tekan tombol AUTO HARVEST: OFF         ║
║   3. Nikmati auto panen! 🔥                 ║
╚══════════════════════════════════════════════╝
]])
