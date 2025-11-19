local Papi = {
    Loaded = false,
    Commands = {},
    API = nil,
    ActiveAdminMod = nil,
}

local player = player
local type = type
local pairs = pairs

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

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
    queue(Papi.API.OnRoleChanges, identifier, func)
end

function Papi.IsSteamid64Banned(steamid64, callback)
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

    for _, mod in ipairs(ADMIN_MODS) do
        local api = mod.loader()
        if api then
            Papi.ActiveAdminMod = mod.name
            Papi.API = api
            Papi.Loaded = true
            return
        end
    end

    MsgC(Color(168, 95, 183), "[Papi]", Color(255, 255, 255), " No supported admin mod found! Papi will not function!\n")
end

local function Add(name, loader)
    table.insert(ADMIN_MODS, {
        name = name,
        loader = loader,
    })
end

Add("Lyn", function()
    local Lyn = Lyn -- avoid global lookups
    if not Lyn then return end

    local api = {
        Commands = {}
    }

    function api.AddPermission(name, min_access, category)
        Lyn.Permission.Add(name, category, min_access)
    end

    api.GetPermissions = Lyn.Permission.GetAll

    function api.PlayerHasPermission(ply, perm_name)
        return PLAYER.HasPermission(ply, perm_name)
    end

    function api.GetPlayersWithPermission(perm_name)
        return Lyn.Player.GetAllWithPermission(perm_name)
    end

    api.GetPlayerRoles = Lyn.Player.Role.GetAll

    function api.GetRoles()
        local all, n = {}, 1
        for role_name in pairs(Lyn.Role.GetAll()) do
            all[n] = role_name; n = n + 1
        end
        return all
    end

    function api.OnRoleChanges(identifier, func)
        if not func then
            hook.Remove("Lyn.Player.Role.Add", identifier)
            hook.Remove("Lyn.Player.Role.Remove", identifier)
            return
        end

        hook.Add("Lyn.Player.Role.Add", identifier, function(ply, steamid64)
            func(ply, steamid64)
        end)

        hook.Add("Lyn.Player.Role.Remove", identifier, function(ply, steamid64)
            func(ply, steamid64)
        end)
    end

    if SERVER then
        function api.IsSteamid64Banned(steamid64, callback)
            Lyn.Player.GetBanInfo(steamid64, function(err, res)
                -- err is already handled by Lyn
                if err or not res then
                    callback(false)
                    return
                end
                callback(true)
            end)
        end
    end

    function api.Commands.Kick(ply, reason)
        Lyn.Command.Execute("kick", ply, reason)
    end

    function api.Commands.BanID64(steamid64, length, reason)
        Lyn.Command.Execute("banid", steamid64, length, reason)
    end

    function api.Commands.Ban(ply, length, reason)
        return api.Commands.BanID64(ply:SteamID64(), length, reason)
    end

    function api.Commands.UnbanID64(steamid64)
        Lyn.Command.Execute("unban", steamid64)
    end

    function api.Commands.Freeze(ply)
        Lyn.Command.Execute("freeze", ply)
    end

    function api.Commands.Unfreeze(ply)
        Lyn.Command.Execute("unfreeze", ply)
    end

    if CLIENT then
        function api.Commands.Goto(ply)
            Lyn.Command.Execute("goto", ply)
        end

        function api.Commands.Bring(ply)
            Lyn.Command.Execute("bring", ply)
        end

        function api.Commands.Return(ply)
            Lyn.Command.Execute("return", ply)
        end
    end

    return api
end
)

Add("SAM", function()
    local sam = sam
    if not sam then return end

    local api = { Commands = {} }

    function api.AddPermission(name, min_access, category)
        sam.permissions.add(name, category, min_access)
    end

    function api.GetPermissions()
        local sam_perms = sam.permissions.get()
        local copy = {}
        for i = 1, #sam_perms do
            copy[i] = sam_perms[i].name
        end
        return copy
    end

    function api.PlayerHasPermission(ply, perm_name)
        return PLAYER.HasPermission(ply, perm_name)
    end

    function api.GetPlayersWithPermission(perm_name)
        local players, n = {}, 1
        for _, ply in player.Iterator() do
            if PLAYER.HasPermission(ply, perm_name) then
                players[n] = ply
                n = n + 1
            end
        end
        return players
    end

    function api.GetPlayerRoles(ply)
        return { PLAYER.GetUserGroup(ply) }
    end

    function api.GetRoles()
        local all, n = {}, 1
        for role_name in pairs(sam.ranks.get_ranks()) do
            all[n] = role_name; n = n + 1
        end
        return all
    end

    function api.OnRoleChanges(identifier, func)
        if not func then
            hook.Remove("SAM.ChangedPlayerRank", identifier)
            hook.Remove("SAM.ChangedSteamIDRank", identifier)
            return
        end

        hook.Add("SAM.ChangedPlayerRank", identifier, function(ply)
            func(ply, ply:SteamID64())
        end)

        hook.Add("SAM.ChangedSteamIDRank", identifier, function(steamid)
            local ply = player.GetBySteamID(steamid)
            if ply and ply:IsValid() then
                func(ply, ply:SteamID64())
                return
            end

            local steamid64 = util.SteamIDTo64(steamid)
            if steamid64 == "0" then return end -- BOT or invalid

            func(nil, steamid64)
        end)
    end

    if SERVER then
        function api.IsSteamid64Banned(steamid64, callback)
            sam.player.is_banned(util.SteamIDFrom64(steamid64), function(res)
                if res then
                    callback(true)
                else
                    callback(false)
                end
            end)
        end
    end

    function api.Commands.Kick(ply, reason)
        RunConsoleCommand("sam", "kick", "#" .. ply:EntIndex(), reason)
    end

    function api.Commands.BanID64(steamid64, length, reason)
        RunConsoleCommand("sam", "banid", steamid64, length / 60, reason) -- sam ban length is in minutes, dumb
    end

    function api.Commands.Ban(ply, length, reason)
        return api.Commands.BanID64(ply:SteamID64(), length, reason)
    end

    function api.Commands.UnbanID64(steamid64)
        RunConsoleCommand("sam", "unban", steamid64)
    end

    function api.Commands.Freeze(ply)
        RunConsoleCommand("sam", "freeze", "#" .. ply:EntIndex())
    end

    function api.Commands.Unfreeze(ply)
        RunConsoleCommand("sam", "unfreeze", "#" .. ply:EntIndex())
    end

    if CLIENT then
        function api.Commands.Goto(ply)
            RunConsoleCommand("sam", "goto", "#" .. ply:EntIndex())
        end

        function api.Commands.Bring(ply)
            RunConsoleCommand("sam", "bring", "#" .. ply:EntIndex())
        end

        function api.Commands.Return(ply)
            RunConsoleCommand("sam", "return", "#" .. ply:EntIndex())
        end
    end

    return api
end
)

Add("ULX", function()
    local ULib = ULib
    if not ULib then return end

    local api = { Commands = {} }

    function api.AddPermission(name, min_access, category)
        ULib.ucl.registerAccess(name, min_access, "A privilege from Papi", category)
    end

    function api.GetPermissions()
        local all, n = {}, 1
        for perm_name in pairs(ULib.ucl.accessStrings) do
            all[n] = perm_name; n = n + 1
        end
        return all
    end

    -- https://github.com/TeamUlysses/ulib/blob/147657e31a15bdcc5b5fec89dd9f5650aebeb54a/lua/ulib/shared/cami_ulib.lua#L16
    function api.PlayerHasPermission(ply, perm_name)
        local priv = perm_name:lower()
        local result = ULib.ucl.query(ply, priv, true)
        return not not result
    end

    function api.GetPlayersWithPermission(perm_name)
        local players, n = {}, 1
        for _, ply in player.Iterator() do
            if api.PlayerHasPermission(ply, perm_name) then
                players[n] = ply; n = n + 1
            end
        end
        return players
    end

    function api.GetPlayerRoles(ply)
        return { PLAYER.GetUserGroup(ply) }
    end

    function api.GetRoles()
        local all, n = {}, 1
        for role_name in pairs(ULib.ucl.groups) do
            all[n] = role_name; n = n + 1
        end
        return all
    end

    function api.OnRoleChanges(identifier, func)
        -- TODO: ULX does not signal role changes for clientside, we need to send a net message from server to client

        if not func then
            hook.Remove(ULib.HOOK_USER_GROUP_CHANGE, identifier)
            return
        end

        hook.Add(ULib.HOOK_USER_GROUP_CHANGE, identifier, function(steamid)
            ---@cast steamid string

            local ply = player.GetBySteamID(steamid)
            if ply and ply:IsValid() then
                func(ply, ply:SteamID64())
                return
            end

            -- ULX can pass SteamID64 or SteamID32, who the heck knows
            if steamid:StartsWith("7") then -- Already SteamID64
                func(ply, steamid)
                return
            end

            local steamid64 = util.SteamIDTo64(steamid)
            func(ply, steamid64)
        end)
    end

    if SERVER then
        -- https://github.com/TeamUlysses/ulib/blob/147657e31a15bdcc5b5fec89dd9f5650aebeb54a/lua/ulib/server/bans.lua#L59
        function api.IsSteamid64Banned(steamid64, callback)
            local steamid = util.SteamIDFrom64(steamid64)
            local ban_data = ULib.bans[steamid]
            if not ban_data
                or (not ban_data.admin and not ban_data.reason and not ban_data.unban and not ban_data.time)
            then
                callback(false)
                return
            end
            callback(true)
        end
    end

    function api.Commands.Kick(ply, reason)
        RunConsoleCommand("ulx", "kick", "$" .. ply:UserID(), reason)
    end

    function api.Commands.BanID64(steamid64, length, reason)
        RunConsoleCommand("ulx", "banid", util.SteamIDFrom64(steamid64), length / 60, reason) -- ulx ban length is in minutes, dumb
    end

    function api.Commands.Ban(ply, length, reason)
        return api.Commands.BanID64(ply:SteamID64(), length, reason)
    end

    function api.Commands.UnbanID64(steamid64)
        RunConsoleCommand("ulx", "unban", util.SteamIDFrom64(steamid64))
    end

    function api.Commands.Freeze(ply)
        RunConsoleCommand("ulx", "freeze", "$" .. ply:UserID())
    end

    function api.Commands.Unfreeze(ply)
        RunConsoleCommand("ulx", "unfreeze", "$" .. ply:UserID())
    end

    if CLIENT then
        function api.Commands.Goto(ply)
            RunConsoleCommand("ulx", "goto", "$" .. ply:UserID())
        end

        function api.Commands.Bring(ply)
            RunConsoleCommand("ulx", "bring", "$" .. ply:UserID())
        end

        function api.Commands.Return(ply)
            RunConsoleCommand("ulx", "return", "$" .. ply:UserID())
        end
    end

    return api
end
)

Add("sAdmin",
    function()
        local sAdmin = sAdmin
        if not sAdmin then return end

        local api = { Commands = {} }

        function api.AddPermission(name, min_access, category)
            sAdmin.registerPermission(name, category, false, true)
        end

        function api.GetPermissions()
            local all, n = {}, 1
            for perm in pairs(sAdmin.getPermissionsKeys()) do
                all[n] = perm; n = n + 1
            end
            return all
        end

        api.PlayerHasPermission = sAdmin.hasPermission
        api.GetPlayersWithPermission = sAdmin.FindByPerm

        function api.GetPlayerRoles(ply)
            return { PLAYER.GetUserGroup(ply) }
        end

        function api.GetRoles()
            local all, n = {}, 1
            for role_name in pairs(sAdmin.usergroups) do
                all[n] = role_name; n = n + 1
            end
            return all
        end

        function api.Commands.Kick(ply, reason)
            RunConsoleCommand("sa", "kick", ply:SteamID64(), reason)
        end

        function api.Commands.BanID64(steamid64, length, reason)
            RunConsoleCommand("sa", "banid", steamid64, length, reason)
        end

        function api.Commands.Ban(ply, length, reason)
            return api.Commands.BanID64(ply:SteamID64(), length, reason)
        end

        function api.Commands.UnbanID64(steamid64)
            RunConsoleCommand("sa", "unban", steamid64)
        end

        function api.Commands.Freeze(ply)
            RunConsoleCommand("sa", "freeze", ply:SteamID64())
        end

        function api.Commands.Unfreeze(ply)
            RunConsoleCommand("sa", "unfreeze", ply:SteamID64())
        end

        if CLIENT then
            function api.Commands.Goto(ply)
                RunConsoleCommand("sa", "goto", ply:SteamID64())
            end

            function api.Commands.Bring(ply)
                RunConsoleCommand("sa", "bring", ply:SteamID64())
            end

            function api.Commands.Return(ply)
                RunConsoleCommand("sa", "return", ply:SteamID64())
            end
        end

        return api
    end
)

Papi.Load()

return Papi
