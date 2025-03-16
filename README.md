# ME Warehouse Dashboard (CC:Tweaked + Advanced Peripherals)

wget run https://raw.githubusercontent.com/shenniko/CCTweaked_AE2_Minecolonies/main/installer.lua

A multi-monitor, auto-crafting dashboard for ComputerCraft/CC:Tweaked using the ME System and MineColonies integration.

## 🔧 Features

- Real-time colony work request monitoring
- ME crafting and item export automation
- Separate main and debug monitor displays
- Color-coded logs and alerts
- Colonist health and builder progress display

## 📦 Requirements

- [CC:Tweaked](https://tweaked.cc/)
- [Advanced Peripherals](https://www.curseforge.com/minecraft/mc-mods/advanced-peripherals)
- A working **ME System** with a `meBridge`
- A **Colony Integrator** placed within your MineColonies bounds
- Dual monitors (for dashboard + debug)

## 📁 File Overview

- `MEWarehouse_MultiMonitor.lua` – main dashboard script (can be used as `startup.lua`)
- `mewarehouse.log` – log file (ignored by git)
- `/modules/` (planned) – modular breakdown for easier extension

## 🧰 Setup

1. Place the script in your turtle or computer.
2. Rename it to `startup.lua` (optional).
3. Adjust monitor/peripheral IDs in the config section.
4. Boot it up!

## 📝 License

This project is licensed under the [MIT License](LICENSE).
