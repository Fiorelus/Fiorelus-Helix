local function CreateSquadsTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_squads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            squad_name TEXT UNIQUE,
            leader_cid INTEGER,
            created_at INTEGER
        )
    ]])
end

local function CreateSquadRolesTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_squad_roles (
            squad_id INTEGER,
            member_cid INTEGER,
            role TEXT,
            FOREIGN KEY(squad_id) REFERENCES ix_squads(id),
            PRIMARY KEY (squad_id, member_cid)
        )
    ]])
end

CreateSquadsTable()
CreateSquadRolesTable()

util.AddNetworkString("ixOpenSquadMenu")
util.AddNetworkString("ixGetSquadList")
util.AddNetworkString("ixSquadList")
util.AddNetworkString("ixGetSquadInfo")
util.AddNetworkString("ixSquadInfo")
util.AddNetworkString("ixSquadCreate")
util.AddNetworkString("ixSquadJoin")
util.AddNetworkString("ixSquadLeave")
util.AddNetworkString("ixSquadDisband")
util.AddNetworkString("ixSendPing")
util.AddNetworkString("ixReceivePing")
util.AddNetworkString("ixSquadLeaveClient")
util.AddNetworkString("ixSquadJoinClient")
util.AddNetworkString("ixSetSquadRole")
util.AddNetworkString("ixSquadUpdate")

local function SendSquadList()
    local squadData = {}

    local result = sql.Query("SELECT ix_squads.id, ix_squads.squad_name, ix_squads.leader_cid, COUNT(ix_squad_roles.member_cid) AS member_count FROM ix_squads LEFT JOIN ix_squad_roles ON ix_squads.id = ix_squad_roles.squad_id GROUP BY ix_squads.id")

    if result then
        for _, row in pairs(result) do
            local leaderName = sql.QueryValue("SELECT name FROM ix_characters WHERE id = " .. sql.SQLStr(row.leader_cid)) or "Unknown"
            table.insert(squadData, {
                name = row.squad_name,
                count = row.member_count,
                leader = leaderName
            })
        end
    end

    net.Start("ixSquadList")
    net.WriteTable(squadData)
    net.Broadcast()
end

local function GetPlayerByCharacterID(characterID)
    for _, ply in pairs(player.GetAll()) do
        if ply:GetCharacter() and ply:GetCharacter():GetID() == characterID then
            return ply
        end
    end
    return nil
end

local function GetHealthFromData(data)
    local decodedData = util.JSONToTable(data)
    if decodedData and decodedData.health then
        return tonumber(decodedData.health)
    end
    return 100
end

local function IsInSquad(ply)
    local characterID = ply:GetCharacter():GetID()
    local squadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)))
    local inSquad = squadID ~= nil

    return inSquad
end

net.Receive("ixSquadCreate", function(_, ply)
    local squadName = net.ReadString() or ""
    local characterID = ply:GetCharacter():GetID()

    local normalizedSquadName = string.lower(squadName)
    if normalizedSquadName == "" or not characterID then
        ply:ChatPrint("Invalid squad name or character.")
        return
    end

    local nameResult = sql.QueryValue("SELECT squad_name FROM ix_squads WHERE squad_name = " .. sql.SQLStr(normalizedSquadName))
    if nameResult then
        ply:ChatPrint("Squad already exists.")
        return
    end

    local leaderResult = sql.Query("SELECT squad_name FROM ix_squads WHERE leader_cid = " .. sql.SQLStr(characterID))
    if leaderResult and #leaderResult > 0 then
        ply:ChatPrint("You are already leading a squad. Disband your current squad before creating a new one.")
        return
    end

    local currentTime = os.time()
    sql.Query("INSERT INTO ix_squads (squad_name, leader_cid, created_at) VALUES (" .. sql.SQLStr(squadName) .. ", " .. sql.SQLStr(tostring(characterID)) .. ", " .. sql.SQLStr(tostring(currentTime)) .. ")")
    local squadID = sql.QueryValue("SELECT last_insert_rowid()")
    sql.Query("INSERT INTO ix_squad_roles (squad_id, member_cid, role) VALUES (" .. sql.SQLStr(squadID) .. ", " .. sql.SQLStr(tostring(characterID)) .. ", 'leader')")

    net.Start("ixSquadJoinClient")
    net.Send(ply)

    SendSquadList()
end)

net.Receive("ixSquadJoin", function(_, ply)
    local squadName = net.ReadString() or ""
    local characterID = ply:GetCharacter():GetID()

    if squadName == "" or not characterID then
        ply:ChatPrint("Invalid squad name or character.")
        return
    end

    local currentLeadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)) .. " AND role = 'leader'")
    if currentLeadID then
        ply:ChatPrint("You are already a leader of a squad and cannot join another squad.")
        return
    end

    local currentSquadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)))
    if currentSquadID then
        sql.Query("DELETE FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)))
    end

    local squadID = sql.QueryValue("SELECT id FROM ix_squads WHERE squad_name = " .. sql.SQLStr(squadName))
    if not squadID then
        ply:ChatPrint("Squad not found.")
        return
    end

    local isMember = sql.Query("SELECT 1 FROM ix_squad_roles WHERE squad_id = " .. sql.SQLStr(squadID) .. " AND member_cid = " .. sql.SQLStr(tostring(characterID)))
    if isMember and #isMember > 0 then
        ply:ChatPrint("You are already a member of this squad.")
        return
    end

    sql.Query("INSERT INTO ix_squad_roles (squad_id, member_cid, role) VALUES (" .. sql.SQLStr(squadID) .. ", " .. sql.SQLStr(tostring(characterID)) .. ", 'member')")

    net.Start("ixSquadJoinClient")
    net.Send(ply)

    SendSquadList()
end)

net.Receive("ixSquadDisband", function(_, ply)
    local characterID = ply:GetCharacter():GetID()

    local squadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)) .. " AND role = 'leader'")
    if not squadID then
        ply:ChatPrint("You are not a leader of any squad.")
        return
    end

    local squadMembers = sql.Query("SELECT member_cid FROM ix_squad_roles WHERE squad_id = " .. sql.SQLStr(squadID))

    for _, member in ipairs(squadMembers) do
        local player = GetPlayerByCharacterID(tonumber(member.member_cid))
        if IsValid(player) then
            net.Start("ixSquadLeaveClient")
            net.Send(player)

            player:ChatPrint("Your squad has been disbanded by the leader.")
        end
    end

    local rolesQuery = "DELETE FROM ix_squad_roles WHERE squad_id = " .. sql.SQLStr(squadID)
    local rolesSuccess = sql.Query(rolesQuery)

    if rolesSuccess == false then
        ply:ChatPrint("Failed to delete squad roles.")
        return
    end

    local squadQuery = "DELETE FROM ix_squads WHERE id = " .. sql.SQLStr(squadID)
    local squadSuccess = sql.Query(squadQuery)

    if squadSuccess == false then
        ply:ChatPrint("Failed to disband squad.")
    else
        ply:ChatPrint("Squad disbanded successfully.")
    end

    net.Start("ixSquadLeaveClient")
    net.Send(ply)

    SendSquadList()
end)

net.Receive("ixSquadLeave", function(_, ply)
    local characterID = ply:GetCharacter():GetID()

    local squadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)))
    if not squadID then
        ply:ChatPrint("You are not part of any squad.")
        return
    end

    local isLeader = sql.QueryValue("SELECT COUNT(*) FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)) .. " AND role = 'leader'")
    if tonumber(isLeader) > 0 then
        ply:ChatPrint("You are leading a squad. Disband your squad if you wish to leave.")
        return
    end

    local rolesQuery = "DELETE FROM ix_squad_roles WHERE squad_id = " .. sql.SQLStr(squadID) .. " AND member_cid = " .. sql.SQLStr(tostring(characterID))
    local rolesSuccess = sql.Query(rolesQuery)

    if rolesSuccess == false then
        ply:ChatPrint("Failed to delete squad roles.")
        return
    end

    ply:ChatPrint("You have left the squad successfully.")

    net.Start("ixSquadLeaveClient")
    net.Send(ply)

    local query = [[
        SELECT ix_squad_roles.member_cid, ix_squad_roles.role, ix_characters.name, ix_characters.data, ix_squads.squad_name
        FROM ix_squad_roles
        JOIN ix_characters ON ix_squad_roles.member_cid = ix_characters.id
        JOIN ix_squads ON ix_squads.id = ix_squad_roles.squad_id
        WHERE ix_squad_roles.squad_id = ]] .. sql.SQLStr(squadID)

    local squadMembers = sql.Query(query)

    for _, member in ipairs(squadMembers) do
        local player = GetPlayerByCharacterID(tonumber(member.member_cid))

        if IsValid(player) then
            local healthPercentage = (player:Health() / player:GetMaxHealth()) * 100
            member.health = math.Round(healthPercentage)
        else
            member.health = GetHealthFromData(member.data) or 100
        end
    end

    for _, member in ipairs(squadMembers) do
        local player = GetPlayerByCharacterID(tonumber(member.member_cid))
        if IsValid(player) then
            net.Start("ixSquadInfo")
            net.WriteString(squadMembers[1].squad_name)
            net.WriteTable(squadMembers)
            net.Send(player)
        end
    end

    SendSquadList()
end)

net.Receive("ixGetSquadList", function(_, ply)
    SendSquadList()
end)

net.Receive("ixGetSquadInfo", function(_, ply)
    local characterID = ply:GetCharacter():GetID()
    local squadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)))

    if not squadID then
        return
    end

    local query = [[
        SELECT ix_squad_roles.member_cid, ix_squad_roles.role, ix_characters.name, ix_characters.data, ix_squads.squad_name
        FROM ix_squad_roles
        JOIN ix_characters ON ix_squad_roles.member_cid = ix_characters.id
        JOIN ix_squads ON ix_squads.id = ix_squad_roles.squad_id
        WHERE ix_squad_roles.squad_id = ]] .. sql.SQLStr(squadID)

    local squadMembers = sql.Query(query)

    if not squadMembers then
        return
    end

    for _, member in ipairs(squadMembers) do
        local player = GetPlayerByCharacterID(tonumber(member.member_cid))

        if IsValid(player) then
            local healthPercentage = (player:Health() / player:GetMaxHealth()) * 100
            member.health = math.Round(healthPercentage)
        else
            member.health = GetHealthFromData(member.data) or 100
        end
    end

    for _, member in ipairs(squadMembers) do
        local player = GetPlayerByCharacterID(tonumber(member.member_cid))
        if IsValid(player) then
            net.Start("ixSquadInfo")
            net.WriteString(squadMembers[1].squad_name)
            net.WriteTable(squadMembers)
            net.Send(player)
        end
    end
end)

net.Receive("ixSendPing", function(len, ply)
    local pingPos = net.ReadVector()
    local name = net.ReadString()

    for _, v in ipairs(player.GetAll()) do
        if IsInSquad(v) then
            net.Start("ixReceivePing")
            net.WriteVector(pingPos)
            net.WriteString(name)
            net.Send(v)
        end
    end
end)

net.Receive("ixSetSquadRole", function(_, ply)
    local memberCid = net.ReadInt(32)
    local newRole = net.ReadString()

    if not ply:GetCharacter() then return end

    local characterID = ply:GetCharacter():GetID()
    local currentSquadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(characterID) .. " AND role = 'leader'")

    if not currentSquadID then
        ply:ChatPrint("You must be a squad leader to change roles.")
        return
    end

    local query = "UPDATE ix_squad_roles SET role = " .. sql.SQLStr(newRole) .. " WHERE member_cid = " .. sql.SQLStr(tostring(memberCid)) .. " AND squad_id = " .. sql.SQLStr(currentSquadID)
    local success = sql.Query(query)

    if success then
        ply:ChatPrint("Role updated successfully.")
    end
end)