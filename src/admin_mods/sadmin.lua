local sAdmin = sAdmin
if not sAdmin then return end

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

---@type PapiAPI
local api = {
    Name = "sAdmin",
    Commands = {}
}

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
