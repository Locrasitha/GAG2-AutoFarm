--[[
    harvester.lua
    Auto Harvest Logic Module untuk Grow a Garden 2
    
    Usage:
    local Harvester = require(path.to.harvester)
    local bot = Harvester.new(cropData, filter)
    bot.onHarvest = function(name, data) print("Panen:", name) end
    bot:start()
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Harvester = {}
Harvester.__index = Harvester
Harvester.VERSION = "1.0.0"

-- ============================================================
-- CONSTRUCTOR
-- ============================================================
function Harvester.new(cropData, filter)
    local self = setmetatable({}, Harvester)
    
    -- Core
    self.player = Players.LocalPlayer
    self.cropData = cropData or {}
    self.filter = filter or {}
    
    -- State
    self.active = false
    self.paused = false
    self.loop = nil
    
    -- Config (bisa diubah)
    self.jarakHarvest = 60        -- Jarak maksimal deteksi (stud)
    self.delayPanen = 0.5         -- Jeda antar panen (detik)
    self.delaySearch = 1.0        -- Jeda saat nggak nemu crop (detik)
    self.teleportOffset = Vector3.new(0, 3, 0)  -- Offset posisi saat teleport
    self.teleportDelay = 0.15     -- Jeda setelah teleport sebelum harvest
    
    -- Stats
    self.totalHarvested = 0
    self.totalEarnings = 0
    self.lastHarvested = nil
    self.lastHarvestTime = nil
    
    -- Callbacks
    self.onHarvest = nil    -- function(cropName, cropData)
    self.onStatus = nil     -- function(statusText)
    self.onError = nil      -- function(errorMessage)
    self.onStart = nil      -- function()
    self.onStop = nil       -- function()
    
    return self
end

-- ============================================================
-- FILTER CHECK
-- ============================================================
function Harvester:cekFilter(namaObjek)
    -- Kalau filter kosong, return false (nggak panen apa-apa)
    if next(self.filter) == nil then
        return false
    end
    
    -- Cek apakah ada crop di filter yang match
    for cropName, boleh in pairs(self.filter) do
        if boleh and namaObjek:lower():find(cropName:lower()) then
            return true
        end
    end
    
    return false
end

-- ============================================================
-- CARI TANAMAN TERDEKAT
-- ============================================================
function Harvester:cariTanamanTerdekat()
    local karakter = self.player.Character
    if not karakter then
        if self.onError then self.onError("Karakter tidak ditemukan") end
        return nil
    end
    
    local rootPart = karakter:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        if self.onError then self.onError("HumanoidRootPart tidak ditemukan") end
        return nil
    end
    
    local target = nil
    local jarakMin = self.jarakHarvest
    local totalChecked = 0
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Cek apakah object punya ProximityPrompt (tanda bisa dipanen)
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt and obj:IsA("BasePart") then
            totalChecked = totalChecked + 1
            
            -- Cek filter
            if self:cekFilter(obj.Name) then
                local jarak = (obj.Position - rootPart.Position).Magnitude
                if jarak < jarakMin then
                    jarakMin = jarak
                    target = obj
                end
            end
        end
    end
    
    return target, totalChecked
end

-- ============================================================
-- PANEN TANAMAN
-- ============================================================
function Harvester:panen(target)
    local karakter = self.player.Character
    if not karakter then return false, "Karakter tidak ditemukan" end
    
    local rootPart = karakter:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false, "HumanoidRootPart tidak ditemukan" end
    
    -- Simpan posisi awal (buat teleport balik, optional)
    -- local posisiAwal = rootPart.CFrame
    
    -- Teleport ke dekat tanaman
    rootPart.CFrame = target.CFrame + self.teleportOffset
    task.wait(self.teleportDelay)
    
    -- Trigger ProximityPrompt
    local prompt = target:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        local success, err = pcall(function()
            fireproximityprompt(prompt)
        end)
        
        if not success then
            -- Fallback: coba klik manual
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.1)
                prompt:InputHoldEnd()
            end)
        end
        
        return true, nil
    end
    
    return false, "ProximityPrompt tidak ditemukan"
end

-- ============================================================
-- START AUTO HARVEST
-- ============================================================
function Harvester:start()
    if self.active then
        if self.onStatus then self.onStatus("⚠️ Auto harvest sudah berjalan") end
        return
    end
    
    self.active = true
    self.paused = false
    
    if self.onStart then self.onStart() end
    if self.onStatus then self.onStatus("🔍 Mencari tanaman...") end
    
    -- Reset stats
    self.totalHarvested = 0
    self.totalEarnings = 0
    
    self.loop = RunService.Heartbeat:Connect(function()
        if self.paused then return end
        
        local target, totalChecked = self:cariTanamanTerdekat()
        
        if target then
            local sukses, err = self:panen(target)
            
            if sukses then
                self.totalHarvested = self.totalHarvested + 1
                self.lastHarvested = target.Name
                self.lastHarvestTime = os.time()
                
                -- Update earnings
                local cropInfo = self.cropData[target.Name]
                if cropInfo then
                    self.totalEarnings = self.totalEarnings + cropInfo.price
                end
                
                -- Callback
                if self.onHarvest then
                    self.onHarvest(target.Name, cropInfo)
                end
                
                if self.onStatus then
                    if cropInfo then
                        self.onStatus(string.format("✅ #%d %s [%s] 💰%d | Total: 💰%d",
                            self.totalHarvested, target.Name, cropInfo.tier,
                            cropInfo.price, self.totalEarnings))
                    else
                        self.onStatus(string.format("✅ #%d %s",
                            self.totalHarvested, target.Name))
                    end
                end
                
                task.wait(self.delayPanen)
            else
                if self.onError then self.onError(err or "Gagal panen") end
                task.wait(0.5)
            end
        else
            if self.onStatus then
                if totalChecked and totalChecked > 0 then
                    self.onStatus(string.format("🔍 Nggak nemu crop... (checked: %d objects)", totalChecked))
                else
                    self.onStatus("🔍 Nyari tanaman terdekat...")
                end
            end
            task.wait(self.delaySearch)
        end
    end)
end

-- ============================================================
-- STOP AUTO HARVEST
-- ============================================================
function Harvester:stop()
    self.active = false
    self.paused = false
    
    if self.loop then
        self.loop:Disconnect()
        self.loop = nil
    end
    
    if self.onStop then self.onStop() end
    if self.onStatus then
        self.onStatus(string.format("⏸️ Berhenti | Total panen: %d | 💰%d",
            self.totalHarvested, self.totalEarnings))
    end
end

-- ============================================================
-- PAUSE / RESUME
-- ============================================================
function Harvester:pause()
    if not self.active then return end
    self.paused = true
    if self.onStatus then
        self.onStatus("⏸️ Paused | Total: " .. self.totalHarvested .. " crops")
    end
end

function Harvester:resume()
    if not self.active then return end
    self.paused = false
    if self.onStatus then self.onStatus("▶️ Resumed...") end
end

function Harvester:togglePause()
    if self.paused then
        self:resume()
    else
        self:pause()
    end
end

-- ============================================================
-- SETTERS
-- ============================================================
function Harvester:setJarak(jarak)
    self.jarakHarvest = jarak or 60
end

function Harvester:setDelay(delay)
    self.delayPanen = delay or 0.5
end

function Harvester:setSearchDelay(delay)
    self.delaySearch = delay or 1.0
end

function Harvester:updateFilter(filter)
    self.filter = filter or {}
end

-- ============================================================
-- GETTERS
-- ============================================================
function Harvester:isActive()
    return self.active
end

function Harvester:isPaused()
    return self.paused
end

function Harvester:getStats()
    return {
        totalHarvested = self.totalHarvested,
        totalEarnings = self.totalEarnings,
        lastHarvested = self.lastHarvested,
        lastHarvestTime = self.lastHarvestTime,
        active = self.active,
        paused = self.paused,
        jarakHarvest = self.jarakHarvest,
        delayPanen = self.delayPanen
    }
end

-- ============================================================
-- PRINT STATS
-- ============================================================
function Harvester:printStats()
    local stats = self:getStats()
    print("=" .. string.rep("=", 40))
    print("   📊 HARVESTER STATS")
    print("=" .. string.rep("=", 40))
    print(string.format("   Status        : %s", stats.active and (stats.paused and "PAUSED" or "RUNNING") or "STOPPED"))
    print(string.format("   Total Panen   : %d crops", stats.totalHarvested))
    print(string.format("   Total Earnings: 💰%d Sheckles", stats.totalEarnings))
    print(string.format("   Terakhir      : %s", stats.lastHarvested or "N/A"))
    print(string.format("   Jarak Deteksi : %d studs", stats.jarakHarvest))
    print(string.format("   Delay Panen   : %.2f detik", stats.delayPanen))
    print("=" .. string.rep("=", 40))
end

return Harvester
