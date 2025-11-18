local Papi = {}

function Papi.AddPermission(name, min_access, category)
    assert(type(name) == "string", "Permission name must be a string")
    assert(type(min_access) == "string", "Minimum access level must be a string")
    assert(category == nil or type(category) == "string", "Category must be a string or nil")
    if Lyn then
        Lyn.Permission.Add(name, category or "Papi", min_access)
    elseif sam then
        sam.permissions.add(name, category or "Papi", min_access)
    end
end

function Papi.GetPermissions()
    if Lyn then
        error("TODO")
    elseif sam then
        return sam.permissions.get()
    end
end

function Papi.PlayerHasPermission(ply, perm_name)

end

function Papi.GetPlayersWithPermission(perm_name)

end

function Papi.GetPlayerRoles(ply)

end

function Papi.PlayerHasRole(ply, role_name)

end

function Papi.SteamIDHasPermission(steam_id, perm_name, callback)

end

function Papi.GetRoles()

end

return Papi
