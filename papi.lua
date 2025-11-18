---@diagnostics.globals Lyn sam ULib xAdmin sAdmin

local Papi = {}

local player = player
local type = type
local pairs = pairs

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

local function is_xadmin(t)
    if t == "1" then
        return xAdmin.Categories ~= nil
    elseif t == "2" then
        return xAdmin.ARG_PLAYER ~= nil
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

return Papi
