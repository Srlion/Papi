local Papi = {}
Papi.Commands = {}

local player = player
local type = type
local pairs = pairs

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

local function is_xadmin(t)
    if not xAdmin then return false end
    if t == "1" then
        return xAdmin.Categories ~= nil
    elseif t == "2" then
        return xAdmin.ARG_PLAYER ~= nil
    end
end

function Papi.GetActiveAdminMod()
    if Lyn then
        return "Lyn"
    elseif sam then
        return "SAM"
    elseif ULib then
        return "ULX"
    elseif is_xadmin("1") then
        return "xAdmin1"
    elseif is_xadmin("2") then
        return "xAdmin2"
    elseif sAdmin then
        return "sAdmin"
    else
        return nil
    end
end

function Papi.AddPermission(name, min_access, category)
    assert(type(name) == "string", "Permission name must be a string")
    assert(type(min_access) == "string", "Minimum access level must be a string")
    assert(category == nil or type(category) == "string", "Category must be a string or nil")
    if Lyn then
        Lyn.Permission.Add(name, category or "Papi", min_access)
    elseif sam then
        sam.permissions.add(name, category or "Papi", min_access)
    elseif ULib then
        ULib.ucl.registerAccess(name, min_access, "A privilege from Papi", category or "Papi")
    elseif is_xadmin("1") then
        xAdmin.RegisterPermission(name, name, category) -- No point in fallback to Papi, xAdmin will set it to misc anyway
    elseif is_xadmin("2") then
        xAdmin.RegisterPermission(name, name, category or "Papi")
    elseif sAdmin then
        sAdmin.registerPermission(name, category or "Papi", false, true)
    else
        error("No supported admin mod found!")
    end
end

function Papi.GetPermissions()
    if Lyn then
        return Lyn.Permission.GetAll()
    elseif sam then
        local sam_perms = sam.permissions.get()
        local copy = {}
        for i = 1, #sam_perms do
            copy[i] = sam_perms[i].name
        end
        return copy
    elseif ULib then
        local all = {}
        local n = 1
        for perm_name, _ in pairs(ULib.ucl.accessStrings) do
            all[n] = perm_name
            n = n + 1
        end
        return all
    elseif is_xadmin("1") or is_xadmin("2") then
        local all = {}
        local n = 1
        for perm_name, _ in pairs(xAdmin.Permissions) do
            all[n] = perm_name
            n = n + 1
        end
        return all
    elseif sAdmin then
        local all = {}
        local n = 1
        for perm in pairs(sAdmin.getPermissionsKeys()) do
            all[n] = perm
            n = n + 1
        end
        return all
    end
    error("No supported admin mod found!")
end

function Papi.PlayerHasPermission(ply, perm_name)
    if Lyn or sam then
        return PLAYER.HasPermission(ply, perm_name)
    elseif ULib then
        -- https://github.com/TeamUlysses/ulib/blob/147657e31a15bdcc5b5fec89dd9f5650aebeb54a/lua/ulib/shared/cami_ulib.lua#L16
        local priv = perm_name:lower()
        local result = ULib.ucl.query(ply, priv, true)
        return not not result
    elseif is_xadmin("1") or is_xadmin("2") then
        return PLAYER.xAdminHasPermission(ply, perm_name)
    elseif sAdmin then
        return sAdmin.hasPermission(ply, perm_name)
    end
    return false
end

function Papi.GetPlayersWithPermission(perm_name)
    if Lyn then
        return Lyn.Player.GetAllWithPermission(perm_name)
    elseif sam then
        local players = {}
        local n = 1
        for _, ply in player.Iterator() do
            if PLAYER.HasPermission(ply, perm_name) then
                players[n] = ply
                n = n + 1
            end
        end
        return players
    elseif ULib then
        local players = {}
        local n = 1
        for _, ply in player.Iterator() do
            if Papi.PlayerHasPermission(ply, perm_name) then
                players[n] = ply
                n = n + 1
            end
        end
        return players
    elseif is_xadmin("1") or is_xadmin("2") then
        local players = {}
        local n = 1
        for _, ply in player.Iterator() do
            if PLAYER.xAdminHasPermission(ply, perm_name) then
                players[n] = ply
                n = n + 1
            end
        end
        return players
    elseif sAdmin then
        return sAdmin.FindByPerm(perm_name)
    end
    error("No supported admin mod found!")
end

function Papi.GetPlayerRoles(ply)
    if Lyn then
        return Lyn.Player.Role.GetAll(ply)
    elseif is_xadmin("1") or is_xadmin("2") then
        local all = {}
        all[1] = PLAYER.GetUserGroup(ply)
        local n = 2
        for role_name in pairs(PLAYER.GetExtraUserGroups(ply)) do
            all[n] = role_name
            n = n + 1
        end
        return all
    else
        return { PLAYER.GetUserGroup(ply) }
    end
end

function Papi.GetRoles()
    if Lyn then
        local all = {}
        local n = 1
        for role_name in pairs(Lyn.Role.GetAll()) do
            all[n] = role_name
            n = n + 1
        end
        return all
    elseif sam then
        local all = {}
        local n = 1
        for role_name in pairs(sam.ranks.get_ranks()) do
            all[n] = role_name
            n = n + 1
        end
        return all
    elseif ULib then
        local all = {}
        local n = 1
        for role_name in pairs(ULib.ucl.groups) do
            all[n] = role_name
            n = n + 1
        end
        return all
    elseif is_xadmin("1") or is_xadmin("2") then
        local all = {}
        local n = 1
        for role_name in pairs(xAdmin.Groups) do
            all[n] = role_name
            n = n + 1
        end
        return all
    elseif sAdmin then
        local all = {}
        local n = 1
        for role_name in pairs(sAdmin.usergroups) do
            all[n] = role_name
            n = n + 1
        end
        return all
    end
    error("No supported admin mod found!")
end

function Papi.Commands.Kick(ply, reason)
    if Lyn then
        Lyn.Command.Execute("kick", ply, reason)
    elseif sam then
        RunConsoleCommand("sam", "kick", "#" .. ply:EntIndex(), reason)
    elseif ULib then
        RunConsoleCommand("ulx", "kick", "$" .. ply:UserID(), reason)
    elseif is_xadmin("1") or is_xadmin("2") then
        RunConsoleCommand("xadmin", "kick", ply:SteamID(), reason)
    elseif sAdmin then
        RunConsoleCommand("sa", "kick", ply:SteamID64(), reason)
    else
        error("No supported admin mod found!")
    end
end

function Papi.Commands.BanID64(steamid64, length, reason)
    if Lyn then
        Lyn.Command.Execute("banid", steamid64, length, reason)
    elseif sam then
        RunConsoleCommand("sam", "banid", steamid64, length / 60, reason) -- sam ban length is in minutes
    elseif ULib then
        RunConsoleCommand("ulx", "banid", util.SteamIDFrom64(steamid64), reason)
    elseif is_xadmin("1") or is_xadmin("2") then
        RunConsoleCommand("xadmin", "banid", util.SteamIDFrom64(steamid64), reason)
    elseif sAdmin then
        RunConsoleCommand("sa", "banid", steamid64, length, reason)
    else
        error("No supported admin mod found!")
    end
end

function Papi.Commands.Ban(ply, length, reason)
    return Papi.Commands.BanID64(ply:SteamID64(), length, reason)
end

function Papi.Commands.UnbanID64(steamid64)
    if Lyn then
        Lyn.Command.Execute("unban", steamid64)
    elseif sam then
        RunConsoleCommand("sam", "unban", steamid64)
    elseif ULib then
        RunConsoleCommand("ulx", "unban", util.SteamIDFrom64(steamid64))
    elseif is_xadmin("1") or is_xadmin("2") then
        RunConsoleCommand("xadmin", "unban", util.SteamIDFrom64(steamid64))
    elseif sAdmin then
        RunConsoleCommand("sa", "unban", steamid64)
    else
        error("No supported admin mod found!")
    end
end

function Papi.Commands.Freeze(ply)
    if Lyn then
        Lyn.Command.Execute("freeze", ply)
    elseif sam then
        RunConsoleCommand("sam", "freeze", "#" .. ply:EntIndex())
    elseif ULib then
        RunConsoleCommand("ulx", "freeze", "$" .. ply:UserID())
    elseif is_xadmin("1") or is_xadmin("2") then
        RunConsoleCommand("xadmin", "freeze", ply:SteamID())
    elseif sAdmin then
        RunConsoleCommand("sa", "freeze", ply:SteamID64())
    else
        error("No supported admin mod found!")
    end
end

function Papi.Commands.Unfreeze(ply)
    if Lyn then
        Lyn.Command.Execute("unfreeze", ply)
    elseif sam then
        RunConsoleCommand("sam", "unfreeze", "#" .. ply:EntIndex())
    elseif ULib then
        RunConsoleCommand("ulx", "unfreeze", "$" .. ply:UserID())
    elseif is_xadmin("1") or is_xadmin("2") then
        RunConsoleCommand("xadmin", "unfreeze", ply:SteamID())
    elseif sAdmin then
        RunConsoleCommand("sa", "unfreeze", ply:SteamID64())
    else
        error("No supported admin mod found!")
    end
end

if CLIENT then
    function Papi.Commands.Goto(ply)
        if Lyn then
            Lyn.Command.Execute("goto", ply)
        elseif sam then
            RunConsoleCommand("sam", "goto", "#" .. ply:EntIndex())
        elseif ULib then
            RunConsoleCommand("ulx", "goto", "$" .. ply:UserID())
        elseif is_xadmin("1") or is_xadmin("2") then
            RunConsoleCommand("xadmin", "goto", ply:SteamID())
        elseif sAdmin then
            RunConsoleCommand("sa", "goto", ply:SteamID64())
        else
            error("No supported admin mod found!")
        end
    end

    function Papi.Commands.Bring(ply)
        if Lyn then
            Lyn.Command.Execute("bring", ply)
        elseif sam then
            RunConsoleCommand("sam", "bring", "#" .. ply:EntIndex())
        elseif ULib then
            RunConsoleCommand("ulx", "bring", "$" .. ply:UserID())
        elseif is_xadmin("1") or is_xadmin("2") then
            RunConsoleCommand("xadmin", "bring", ply:SteamID())
        elseif sAdmin then
            RunConsoleCommand("sa", "bring", ply:SteamID64())
        else
            error("No supported admin mod found!")
        end
    end

    function Papi.Commands.Return(ply)
        if Lyn then
            Lyn.Command.Execute("return", ply)
        elseif sam then
            RunConsoleCommand("sam", "return", "#" .. ply:EntIndex())
        elseif ULib then
            RunConsoleCommand("ulx", "return", "$" .. ply:UserID())
        elseif is_xadmin("1") or is_xadmin("2") then
            RunConsoleCommand("xadmin", "return", ply:SteamID())
        elseif sAdmin then
            RunConsoleCommand("sa", "return", ply:SteamID64())
        else
            error("No supported admin mod found!")
        end
    end
end

return Papi
