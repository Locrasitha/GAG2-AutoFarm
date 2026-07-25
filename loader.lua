-- Loader Auto Harvest GAG2
-- Execute ini aja: loadstring(game:HttpGet("https://raw.githubusercontent.com/Locrasitha/GAG2-AutoFarm/main/loader.lua"))()

local function notif(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
    print("[" .. title .. "] " .. text)
end

notif("🌿 GAG2 Loader", "Mulai download script...")

-- Download main script
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/Locrasitha/GAG2-AutoFarm/main/src/main.lua")
end)

if success and result then
    notif("✅ Download OK", "Menjalankan script...")
    
    local execSuccess, execErr = pcall(function()
        loadstring(result)()
    end)
    
    if not execSuccess then
        notif("❌ ERROR", "Gagal execute: " .. tostring(execErr))
        warn("Error: " .. tostring(execErr))
    else
        notif("✅ SUKSES", "GUI Auto Harvest muncul!")
    end
else
    notif("❌ GAGAL", "Script nggak ke-download. Cek URL!")
    warn("Gagal download script dari GitHub")
end
