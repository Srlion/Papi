# Papi - Admin Mod Abstraction Library

A unified API for Garry's Mod admin mods. Write once, work with any supported admin system.

## Supported Admin Mods

- [**Lyn**](https://www.gmodstore.com/market/view/lyn)
- [**SAM**](https://www.gmodstore.com/market/view/sam)
- [**ULX**](https://github.com/TeamUlysses/ulx)
- **xAdmin** ([v1](https://www.gmodstore.com/market/view/xadmin) & [v2](https://www.gmodstore.com/market/view/xadmin-2-admin-mod))
- [**sAdmin**](https://www.gmodstore.com/market/view/sadmin-the-best-admin-mod)

## Quick Usage

### Permissions

```lua
local Papi = include("papi.lua")

-- Add a permission
-- It's inside a timer because loading order may vary between admin mods
timer.Simple(0, function()
    Papi.AddPermission("my_permission", "admin", "MyCategory")
end)

-- Check if player has permission
if Papi.PlayerHasPermission(ply, "my_permission") then
    -- Do something
end

-- Get all players with permission, returns an array of player, eg. {ply1, ply2, ...}
local players = Papi.GetPlayersWithPermission("my_permission")

-- Get all permissions, returns an array of permission names, eg. {"kick", "ban", ...}
local perms = Papi.GetPermissions()
```

### Roles

```lua
-- Get player's roles, returns an array of role names, eg. {"admin", "moderator", ...}
local roles = Papi.GetPlayerRoles(ply)

-- Get all available roles, returns an array of role names, eg. {"admin", "moderator", ...}
local allRoles = Papi.GetRoles()
```

### Commands

```lua
-- Kick player
Papi.Commands.Kick(ply, "Reason here")

-- Ban player (length in seconds)
Papi.Commands.Ban(ply, 3600, "Ban reason")

-- Ban by SteamID64 (length in seconds)
Papi.Commands.BanID64("76561198000000000", 3600, "Ban reason")

-- Unban by SteamID64
Papi.Commands.UnbanID64("76561198000000000")

-- Freeze/Unfreeze
Papi.Commands.Freeze(ply)
Papi.Commands.Unfreeze(ply)

-- Teleport commands (CLIENT only)
Papi.Commands.Goto(ply)    -- Teleport to player
Papi.Commands.Bring(ply)   -- Bring player to you
Papi.Commands.Return(ply)  -- Return player to original position
```

## Installation

Drop the file into your addon and include it where needed:

```lua
local Papi = include("path/to/papi.lua")
```

## Notes

- Automatically detects which admin mod is installed
- Errors if no supported admin mod is found
- Teleport commands (Goto, Bring, Return) are client-side only

## Credits

[MathsCalculator](https://github.com/MathsCalculator) - Helped implementing half of the admin mods and testing.
