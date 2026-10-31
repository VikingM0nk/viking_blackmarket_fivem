Viking Blackmarket
A modular, framework‑agnostic, reputation‑driven blackmarket system for FiveM.
Viking Blackmarket is a fully modular, highly optimized, and framework‑agnostic blackmarket system designed for immersive RP servers. It supports cart‑based purchasing, dynamic pricing, reputation tiers, multiple inventory/money/notify systems, and automatic target detection — all wrapped in a clean, branded UI.
This system is built for reliability, extensibility, and drop‑in deployment.

✨ Features
🛒 Cart‑Based Purchasing (NEW)
• 	Players can add multiple items to a cart and purchase them in a single transaction.
• 	Server‑side validation for every item.
• 	Prevents exploits, double‑buys, and invalid items.
💸 Dynamic Pricing & Reputation System
• 	Prices automatically adjust based on player reputation.
• 	Reputation increases with each purchase.
• 	Configurable min/max reputation and price modifiers.
🧩 Universal System Detection
Automatically detects and integrates with:
• 	Inventory: ox_inventory, qb-inventory, lj, qs, codem, core, or custom.
• 	Money: QB, ESX, OX, or custom.
• 	Notifications: QB, OX, okokNotify, mythic, ESX, or custom.
• 	Dispatch: ps-dispatch, cd_dispatch, qs-dispatch, core_dispatch, linden_outlawalert, or custom.
No configuration required — it just works.
🎯 Universal Target Support
Auto-detects and supports:
• 	ox_target
• 	qb-target
• 	qtarget
• 	Fallback 3D text + E‑key
Includes a fix for qb-target zone duplication.
🧍 Dynamic NPC Dealer
• 	Spawns a dealer at the active market.
• 	Supports scenarios/animations.
• 	Invincible, frozen, and non-reactive for RP stability.
📍 Rotating Markets
• 	Random market selection on startup.
• 	Optional timed rotation.
• 	Automatic client sync.
🚨 Police Alert System
• 	Configurable chance and cooldown.
• 	Supports all major dispatch systems.
• 	Sends alerts with coordinates and custom messages.
🛡️ Anti‑Exploit Protections
• 	Validates item existence.
• 	Validates quantity.
• 	Validates market match.
• 	Prevents invalid purchases.
• 	Prevents double‑execution.
• 	Prevents zone duplication.

📦 Installation
1. 	Drag the  folder into your  directory.
2. 	Add to your :

3. 	Configure markets and items in .

🧠 How It Works
Server
• 	Picks a random market on startup.
• 	Broadcasts the active market to all clients.
• 	Handles purchase validation, money removal, item giving, and reputation.
• 	Handles cart checkout by looping through items and calling the purchase handler.
Client
• 	Receives market sync.
• 	Spawns NPC and creates the target zone.
• 	Opens NUI when interacting with the dealer.
• 	Sends cart data to the server for processing.
• 	Closes NUI cleanly with focus reset.
Includes a guard to prevent double‑open flicker.

🛠️ Configuration
All settings are in :
• 	Markets & items
• 	Inventory/money/notify/dispatch systems
• 	Reputation settings
• 	Police alert settings
• 	Market rotation
• 	Debug mode

📚 Events
Client → Server
• 	 — Sends cart for processing.
• 	 — Requests current market on join.
Server → Client
• 	 — Sends active market data.
• 	 — Opens the UI.

🧪 Recent Fixes & Improvements (NEW)
• 	Fixed NUI flicker caused by duplicate zones.
• 	Fixed qb-target typo ( → ).
• 	Fixed server crash caused by  in server code.
• 	Added open‑guard to prevent double UI activation.
• 	Cleaned up market sync flow to prevent double sync.
• 	Improved cart checkout with proper src override.
• 	Improved server-side validation for items and markets.

👤 Author
VikingM0nk
Built with modularity, performance, and RP immersion in mind.

📄 License
This resource is licensed for use on your server. Redistribution or resale is prohibited unless explicitly permitted.