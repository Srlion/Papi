---@meta

---@class PapiAPI
---@field Name string
---@field Commands PapiAPICommands
local PAPI_API = {}

---@param name string
---@param min_access string
---@param category? string
function PAPI_API.AddPermission(name, min_access, category) end

---@return string[]
function PAPI_API.GetPermissions() end

---@param ply Player
---@param perm_name string
---@return boolean
function PAPI_API.PlayerHasPermission(ply, perm_name) end

---@param perm_name string
---@return Player[]
function PAPI_API.GetPlayersWithPermission(perm_name) end

---@param ply Player
---@return string[]
function PAPI_API.GetPlayerRoles(ply) end

---@return string[]
function PAPI_API.GetRoles() end

---@param identifier string
---@param func? fun(ply:Player|false, steamid64:string)
function PAPI_API.OnRoleChanges(identifier, func) end

---@param steamid64 string
---@param callback fun(is_banned:boolean)
function PAPI_API.IsSteamid64Banned(steamid64, callback) end

---@class PapiAPICommands
PAPI_API.Commands = {}

---@param ply Player
---@param reason string
function PAPI_API.Commands.Kick(ply, reason) end

---@param steamid64 string
---@param length number
---@param reason string
function PAPI_API.Commands.BanID64(steamid64, length, reason) end

---@param ply Player
---@param length number
---@param reason string
function PAPI_API.Commands.Ban(ply, length, reason) end

---@param steamid64 string
function PAPI_API.Commands.UnbanID64(steamid64) end

---@param ply Player
function PAPI_API.Commands.Freeze(ply) end

---@param ply Player
function PAPI_API.Commands.Unfreeze(ply) end

---@param ply Player
function PAPI_API.Commands.Goto(ply) end

---@param ply Player
function PAPI_API.Commands.Bring(ply) end

---@param ply Player
function PAPI_API.Commands.Return(ply) end
