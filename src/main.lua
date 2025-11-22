AddCSLuaFile()

-- Replaced by build.py --
local PAPI_UNIQUE_TAG = "_PAPI_VERSION_"

local Papi = {
    Loaded = false,
    Commands = {},
    API = nil,
    ActiveAdminMod = nil,
}

local type = type

local function check_load()
    -- Try loading, in case this is called right after all addons load and before next tick
    Papi.Load()
    if not Papi.Loaded then
        return error("Papi is not loaded yet!")
    end
end

local function queue(func, ...)
    Papi.Load()
    if not Papi.Loaded then
        local args, n = { ... }, select("#", ...)
        timer.Simple(0, function()
            func(unpack(args, 1, n))
        end)
        return
    end
    func(...)
end

function Papi.GetActiveAdminMod()
    if not Papi.Loaded then check_load() end
    return Papi.ActiveAdminMod
end

function Papi.AddPermission(name, min_access, category)
    assert(type(name) == "string", "Permission name must be a string")
    assert(type(min_access) == "string", "Minimum access level must be a string")
    assert(category == nil or type(category) == "string", "Category must be a string or nil")

    queue(Papi.API.AddPermission, name, min_access, category or "Papi")
end

function Papi.GetPermissions()
    if not Papi.Loaded then check_load() end
    return Papi.API.GetPermissions()
end

function Papi.PlayerHasPermission(ply, perm_name)
    if not Papi.Loaded then check_load() end
    return Papi.API.PlayerHasPermission(ply, perm_name)
end

function Papi.GetPlayersWithPermission(perm_name)
    if not Papi.Loaded then check_load() end
    return Papi.API.GetPlayersWithPermission(perm_name)
end

function Papi.GetPlayerRoles(ply)
    if not Papi.Loaded then check_load() end
    return Papi.API.GetPlayerRoles(ply)
end

function Papi.GetRoles()
    if not Papi.Loaded then check_load() end
    return Papi.API.GetRoles()
end

function Papi.OnRoleChanges(identifier, func)
    assert(func == nil or type(func) == "function", "func must be a function or nil")
    queue(Papi.API.OnRoleChanges, identifier, func)
end

function Papi.IsSteamid64Banned(steamid64, callback)
    assert(type(callback) == "function", "callback must be a function")
    queue(Papi.API.IsSteamid64Banned, steamid64, callback)
end

function Papi.Commands.Kick(ply, reason)
    queue(Papi.API.Commands.Kick, ply, reason)
end

function Papi.Commands.BanID64(steamid64, length, reason)
    queue(Papi.API.Commands.BanID64, steamid64, length, reason)
end

function Papi.Commands.Ban(ply, length, reason)
    queue(Papi.API.Commands.Ban, ply, length, reason)
end

function Papi.Commands.UnbanID64(steamid64)
    queue(Papi.API.Commands.UnbanID64, steamid64)
end

function Papi.Commands.Freeze(ply)
    queue(Papi.API.Commands.Freeze, ply)
end

function Papi.Commands.Unfreeze(ply)
    queue(Papi.API.Commands.Unfreeze, ply)
end

if CLIENT then
    function Papi.Commands.Goto(ply)
        queue(Papi.API.Commands.Goto, ply)
    end

    function Papi.Commands.Bring(ply)
        queue(Papi.API.Commands.Bring, ply)
    end

    function Papi.Commands.Return(ply)
        queue(Papi.API.Commands.Return, ply)
    end
end

local ADMIN_MODS = {}

function Papi.Load()
    if Papi.Loaded then return end

    if not gmod.GetGamemode() then
        timer.Simple(0, Papi.Load)
        return
    end

    for _, loader in ipairs(ADMIN_MODS) do
        ---@type PapiAPI?
        local api = loader()
        if api then
            Papi.ActiveAdminMod = api.Name
            Papi.API = api
            Papi.Loaded = true
            return
        end
    end

    MsgC(Color(168, 95, 183), "[Papi]", Color(255, 255, 255), " No supported admin mod found! Papi will not function!\n")
end

---@diagnostic disable-next-line: unused-function, unused-local
local function Add(loader)
    table.insert(ADMIN_MODS, loader)
end

--[[ Admin Mod Loaders ]] --

Papi.Load()

return Papi
