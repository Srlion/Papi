local sAdmin = sAdmin
if not sAdmin then return end

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

local NetMessageName = "Papi_sAdmin_" .. PAPI_UNIQUE_TAG
local NET_TYPE_ROLE_CHANGE = 1
local NET_BITS = 8

---@type PapiAPI
local api = {
    Name = "sAdmin",
    Commands = {}
}

local ROLE_CHANGE_LISTENERS; if CLIENT then
    ROLE_CHANGE_LISTENERS = {}
end
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

local send_role_change; if SERVER then
    function send_role_change(steamid64)
        net.Start(NetMessageName)
        net.WriteUInt(NET_TYPE_ROLE_CHANGE, NET_BITS)
        net.WriteUInt64(steamid64)
        net.Broadcast()
    end
end

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

function api.OnRoleChanges(identifier, func)
    -- sAdmin does not call role change hooks on clientside
    if CLIENT then
        ROLE_CHANGE_LISTENERS[identifier] = func
        return
    end

    if not func then
        hook.Remove("CAMI.PlayerUsergroupChanged", identifier)
        return
    end

    hook.Add("CAMI.PlayerUsergroupChanged", identifier, function(ply, _, _, source)
        if source ~= "sAdmin" then return end

        send_role_change(ply:SteamID64())
        func(ply, ply:SteamID64())
    end)
end

if SERVER then
    function api.IsSteamid64Banned(steamid64, callback)
        callback(sAdmin.isBanned(steamid64))
    end
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
