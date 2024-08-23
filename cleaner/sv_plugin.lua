local playerEntities = {}

hook.Add("PlayerSpawnedRagdoll", "TrackPlayerRagdolls", function(ply, model, ent)
    if IsValid(ent) then
        playerEntities[ent] = true
    end
end)

hook.Add("PlayerSpawnedProp", "TrackPlayerProps", function(ply, model, ent)
    if IsValid(ent) then
        playerEntities[ent] = true
    end
end)

hook.Add("EntityRemoved", "CleanupPlayerEntities", function(ent)
    if playerEntities[ent] then
        playerEntities[ent] = nil
    end
end)

local function CleanupEntities()
    local function IsPlayerRagdoll(ent)
        for _, ply in ipairs(player.GetAll()) do
            if ply.ixRagdoll and ply.ixRagdoll == ent then
                return true
            end
        end
        return false
    end

    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        if IsValid(ent) and not IsPlayerRagdoll(ent) and not playerEntities[ent] then
            ent:Remove()
        end
    end

    for _, ent in ipairs(ents.FindByClass("weapon_*")) do
        if IsValid(ent) then
            ent:Remove()
        end
    end

    for _, ent in ipairs( ents.FindByClass( "class C_HL2MPRagdoll" ) ) do
        if ( IsValid( ent:GetRagdollOwner() ) ) then
            print( ent:GetRagdollOwner() )
        end
    end
end

timer.Create("CleanupEntitiesTimer", 15, 0, CleanupEntities)