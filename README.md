# Papi - Admin Mod Abstraction Library

A unified API for Garry's Mod admin mods. Write once, work with any supported admin system.

## Supported Admin Mods

- [**Lyn**](https://www.gmodstore.com/market/view/lyn)
- [**SAM**](https://www.gmodstore.com/market/view/sam)
- [**ULX**](https://github.com/TeamUlysses/ulx)
- [**sAdmin**](https://www.gmodstore.com/market/view/sadmin-the-best-admin-mod)

## Quick Usage

### Active Admin Mod

```lua
local active_mod = Papi.GetActiveAdminMod()
if active_mod then
    print("Active admin mod:", active_mod) -- e.g. "Lyn", "SAM", "ULX"
else
    print("No supported admin mod detected")
end
```

### Permissions

```lua
local Papi = include("papi.lua")

-- Add a permission
Papi.AddPermission("my_permission", "admin", "MyCategory")

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

-- Listen for role changes, make sure identifier is unique as it's just a wrapper on top of hook.Add
Papi.OnRoleChanges("my_listener", function(ply, steamid64)
    -- Called when a player's role changes
    -- ply can be nil if player is not connected
end)

-- Remove listener
Papi.OnRoleChanges("my_listener", nil)
```

### Ban Checking

```lua
-- Check if SteamID64 is banned (SERVER only)
Papi.IsSteamid64Banned("76561198000000000", function(is_banned)
    if is_banned then
        print("Player is banned")
    else
        print("Player is not banned")
    end
end)
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

## TODO

- More common commands
- FAdmin support maybe?
- Allow registering custom commands? (Will be simple wrapper functions)

## Credits

[MathsCalculator](https://github.com/MathsCalculator) - Helped implementing half of the admin mods and testing.
