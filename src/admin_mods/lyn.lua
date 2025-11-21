local Lyn = Lyn -- avoid global lookups
if not Lyn then return end

local pairs = pairs

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

---@type PapiAPI
local api = {
    Name = "Lyn",
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
