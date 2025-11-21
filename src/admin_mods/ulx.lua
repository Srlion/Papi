local ULib = ULib
if not ULib then return end

local player = player
local pairs = pairs

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

local NetMessageName = "Papi_ULX_" .. PAPI_UNIQUE_TAG
local NET_TYPE_ROLE_CHANGE = 1
local NET_BITS = 8

---@type PapiAPI
local api = {
    Name = "ULX",
    Commands = {},
}

local ROLE_CHANGE_LISTENERS = {}
if SERVER then
    util.AddNetworkString(NetMessageName)
else
    net.Receive(NetMessageName, function()
        local change_type = net.ReadUInt(8)
        if change_type == NET_TYPE_ROLE_CHANGE then
            local steamid64 = net.ReadUInt64()
            local ply = player.GetBySteamID64(steamid64)
            for _, func in pairs(ROLE_CHANGE_LISTENERS) do
                func(ply, steamid64)
            end
        end
    end)
end

local function send_role_change(steamid64)
    net.Start(NetMessageName)
    net.WriteUInt(NET_TYPE_ROLE_CHANGE, NET_BITS)
    net.WriteUInt64(steamid64)
    net.Broadcast()
end

local PERMISSIONS; if CLIENT then
    PERMISSIONS = {}
end

function api.AddPermission(name, min_access, category)
    if CLIENT then
        PERMISSIONS[name] = { min_access = min_access, category = category }
        return
    end
    ULib.ucl.registerAccess(name, min_access, "A privilege from Papi", category)
end

function api.GetPermissions()
    local all, n = {}, 1
    for perm_name in pairs(PERMISSIONS or ULib.ucl.accessStrings) do
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
    -- ULX does not call role change hooks on clientside
    if CLIENT then
        ROLE_CHANGE_LISTENERS[identifier] = func
        return
    end

    if not func then
        hook.Remove(ULib.HOOK_USER_GROUP_CHANGE, identifier)
        return
    end

    hook.Add(ULib.HOOK_USER_GROUP_CHANGE, identifier, function(steamid)
        ---@cast steamid string

        local ply = player.GetBySteamID(steamid)
        if ply and ply:IsValid() then
            local steamid64 = ply:SteamID64()
            send_role_change(steamid64)
            func(ply, steamid64)
            return
        end

        -- ULX can pass SteamID64 or SteamID32, who the heck knows
        if steamid:StartsWith("7") then -- Already SteamID64
            func(ply, steamid)
            return
        end

        local steamid64 = util.SteamIDTo64(steamid)
        send_role_change(steamid64)
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
