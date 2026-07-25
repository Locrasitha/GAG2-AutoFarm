# 🌿 Grow a Garden 2 - Auto Harvest Script

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Roblox](https://img.shields.io/badge/Game-Grow%20a%20Garden%202-red)](https://www.roblox.com/games/...)

Script Lua untuk auto harvest di game **Grow a Garden 2** Roblox dengan fitur filter tanaman berdasarkan tier, multi-harvest, dan harga.

> ⚠️ **DISCLAIMER**: Script ini untuk **EDUKASI** saja. Gunakan di **private server** untuk menghindari ban. Saya tidak bertanggung jawab atas penyalahgunaan.

---

## ✨ Fitur

- ✅ **GUI Interaktif** - Draggable panel dengan toggle per crop
- 🎨 **Filter by Tier** - Common, Uncommon, Rare, Epic, Legendary, Mythic, Super, Secret
- 🔄 **Filter Multi-Harvest** - Pilih hanya crop yang bisa multi-harvest
- 💰 **Info Harga** - Tampilkan base price tiap crop
- 🚀 **Auto Teleport** - Karakter otomatis mendekati crop
- 📋 **Data Asli Wiki** - 36 crops dari [Wiki Resmi](https://growagarden2.fandom.com/wiki/Crops)

---

## 📦 Instalasi

### Cara 1: Copy Paste (Recommended)
1. Buka file [`src/main.lua`](src/main.lua)
2. Copy seluruh isinya
3. Paste ke executor Roblox kamu (Krnl, Fluxus, Delta, dll)
4. Execute!

### Cara 2: Loadstring
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/GAG2-AutoFarm/main/src/main.lua"))()
