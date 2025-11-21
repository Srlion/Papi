local sam = sam
if not sam then return end

local player = player
local pairs = pairs

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

---@type PapiAPI
local api = {
    Name = "SAM",
    Commands = {}
}

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

local CD = 0.70
local last_run = 0
local function run_command(...)
    if SERVER then
        RunConsoleCommand("sam", ...)
        return
    end
    local now = SysTime()
    local diff = now - last_run
    if diff >= CD then
        last_run = now
        RunConsoleCommand("sam", ...)
    else
        local args, n = { ... }, select("#", ...)
        last_run = last_run + CD
        local delay = last_run - now
        timer.Simple(delay, function()
            RunConsoleCommand("sam", unpack(args, 1, n))
        end)
    end
end

function api.Commands.Kick(ply, reason)
    run_command("kick", "#" .. ply:EntIndex(), reason)
end

function api.Commands.BanID64(steamid64, length, reason)
    run_command("banid", steamid64, length / 60, reason) -- sam ban length is in minutes, dumb
end

function api.Commands.Ban(ply, length, reason)
    return api.Commands.BanID64(ply:SteamID64(), length, reason)
end

function api.Commands.UnbanID64(steamid64)
    run_command("unban", steamid64)
end

function api.Commands.Freeze(ply)
    run_command("freeze", "#" .. ply:EntIndex())
end

function api.Commands.Unfreeze(ply)
    run_command("unfreeze", "#" .. ply:EntIndex())
end

if CLIENT then
    function api.Commands.Goto(ply)
        run_command("goto", "#" .. ply:EntIndex())
    end

    function api.Commands.Bring(ply)
        run_command("bring", "#" .. ply:EntIndex())
    end

    function api.Commands.Return(ply)
        run_command("return", "#" .. ply:EntIndex())
    end
end

return api
