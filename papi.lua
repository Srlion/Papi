local Papi = {}

local player = player
local type = type
local pairs = pairs

-- To avoid cost of Player.__index lookups
local PLAYER = FindMetaTable("Player")

function Papi.AddPermission(name, min_access, category)
    assert(type(name) == "string", "Permission name must be a string")
    assert(type(min_access) == "string", "Minimum access level must be a string")
    assert(category == nil or type(category) == "string", "Category must be a string or nil")
    if Lyn then
        Lyn.Permission.Add(name, category or "Papi", min_access)
    elseif sam then
        sam.permissions.add(name, category or "Papi", min_access)
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
    end
    error("No supported admin mod found!")
end

function Papi.PlayerHasPermission(ply, perm_name)
    if Lyn or sam then
        return PLAYER.HasPermission(ply, perm_name)
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
    end
    error("No supported admin mod found!")
end

function Papi.GetPlayerRoles(ply)
    if Lyn then
        return Lyn.Player.Role.GetAll(ply)
    elseif sam then
        return { PLAYER.GetUserGroup(ply) }
    end
    error("No supported admin mod found!")
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
    end
    error("No supported admin mod found!")
end

return Papi
