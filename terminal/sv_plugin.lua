local function CreateEntriesTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            text TEXT NOT NULL,
            creator TEXT DEFAULT 'UNKNOWN',
            date TEXT DEFAULT 'UNKNOWN',
            user_id INTEGER NOT NULL,
            terminal_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES ix_accounts(id),
            FOREIGN KEY (terminal_id) REFERENCES ix_terminals(id)
        )
    ]])
end

local function CreateAccountsTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            pin TEXT NOT NULL
        )
    ]])
end

local function CreateSharedEntriesTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_shared_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            terminal_id INTEGER NOT NULL,
            FOREIGN KEY (entry_id) REFERENCES ix_entries(id),
            FOREIGN KEY (user_id) REFERENCES ix_accounts(id),
            FOREIGN KEY (terminal_id) REFERENCES ix_terminals(id)
        )
    ]])
end

local function CreateInteractedEntriesTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_datanav (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_id INTEGER NOT NULL,
            character_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            text TEXT NOT NULL,
            date TEXT NOT NULL,
            creator TEXT NOT NULL,
            FOREIGN KEY (entry_id) REFERENCES ix_entries(id),
            FOREIGN KEY (character_id) REFERENCES ix_characters(id)
        )
    ]])
end

local function CreateCurrentDateTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_current_date (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL DEFAULT '2552-11-04'
        )
    ]])
end

local function CreateTerminalsTable()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS ix_terminals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            terminal_id INTEGER NOT NULL UNIQUE,
            description TEXT DEFAULT 'UNKNOWN'
        )
    ]])
end

CreateAccountsTable()
CreateTerminalsTable()
CreateEntriesTable()
CreateSharedEntriesTable()
CreateInteractedEntriesTable()
CreateCurrentDateTable()

util.AddNetworkString("OpenLoginUI")
util.AddNetworkString("OpenDatapadUI")

util.AddNetworkString("RegisterAccount")
util.AddNetworkString("RegisterResult")
util.AddNetworkString("LoginAttempt")
util.AddNetworkString("LoginResult")
util.AddNetworkString("DeleteEntryResult")
util.AddNetworkString("EditEntryResult")
util.AddNetworkString("EditEntryAttempt")

util.AddNetworkString("GetEntries")
util.AddNetworkString("SendEntries")

util.AddNetworkString("AddEntry")
util.AddNetworkString("EditEntry")
util.AddNetworkString("DeleteEntry")
util.AddNetworkString("ShareEntry")

util.AddNetworkString("RequestEntryDetails")
util.AddNetworkString("SendEntryDetails")
util.AddNetworkString("GetDatapadEntries")
util.AddNetworkString("SendDatapadEntries")

util.AddNetworkString("RequestAccounts")
util.AddNetworkString("SendAccounts")
util.AddNetworkString("RequestTerminals")
util.AddNetworkString("SendTerminals")
util.AddNetworkString("SendUserID")

util.AddNetworkString("SetTerminalID")
util.AddNetworkString("OpenTerminalUI")

util.AddNetworkString("StoreInteractedEntries")
util.AddNetworkString("SendInteractedEntries")
util.AddNetworkString("GetInteractedEntries")

local function getUserID(username)
    local result = sql.QueryRow("SELECT id FROM ix_accounts WHERE username = " .. sql.SQLStr(username))
    return result and result.id or nil
end

net.Receive("GetEntries", function(len, ply)
    local userID = ply.userID
    print(userID)
    local personalEntries = sql.Query(("SELECT * FROM ix_entries WHERE user_id = %d"):format(userID)) or {}
    local sharedEntries = {}

    local sharedEntryIDs = {}
    local sharedResult = sql.Query(("SELECT entry_id FROM ix_shared_entries WHERE user_id = %d"):format(userID))
    if sharedResult then
        for _, row in ipairs(sharedResult) do
            table.insert(sharedEntryIDs, row.entry_id)
        end
    end

    for _, entryID in ipairs(sharedEntryIDs) do
        local entry = sql.QueryRow(("SELECT * FROM ix_entries WHERE id = %d"):format(entryID))
        if entry then
            table.insert(sharedEntries, entry)
        end
    end

    local allEntries = {}
    for _, entry in ipairs(personalEntries) do
        entry.shared = "NO"
        table.insert(allEntries, entry)
    end
    for _, entry in ipairs(sharedEntries) do
        entry.shared = "YES"
        table.insert(allEntries, entry)
    end

    net.Start("SendEntries")
    net.WriteTable(allEntries)
    net.Send(ply)
    print("Sent entries to " .. ply:Nick())
end)

net.Receive("GetDatapadEntries", function(len, ply)
    local terminalID = net.ReadInt(32)

    if not terminalID or terminalID == 0 then
        return
    end

    local terminalEntries = {}

    local terminalResult = sql.Query(("SELECT entry_id FROM ix_shared_entries WHERE terminal_id = %d"):format(terminalID))

    if terminalResult then
        local entryIDs = {}
        for _, row in ipairs(terminalResult) do
            table.insert(entryIDs, row.entry_id)
        end

        if #entryIDs > 0 then
            local query = "SELECT * FROM ix_entries WHERE id IN (" .. table.concat(entryIDs, ",") .. ")"
            local entries = sql.Query(query)
            if entries then
                terminalEntries = entries
            end
        end
    end

    net.Start("SendEntries")
    net.WriteTable(terminalEntries)
    net.Send(ply)
    print("Sent entries for terminalID:", terminalID, " to ", ply:Nick())
end)

net.Receive("AddEntry", function(len, ply)
    local title = net.ReadString()
    local text = net.ReadString()
    local creator = net.ReadString()
    if creator == "" or not creator then
        creator = ply:Nick()
    end

    local userID = ply.userID

    local currentDate = sql.QueryValue("SELECT date FROM ix_current_date WHERE id = 1")
    sql.Query("INSERT INTO ix_entries (title, text, creator, date, user_id) VALUES (" .. sql.SQLStr(title) .. ", " .. sql.SQLStr(text) .. ", " .. sql.SQLStr(creator) .. ", " .. sql.SQLStr(currentDate) .. ", " .. sql.SQLStr(userID) .. ")")

    local personalEntries = sql.Query(("SELECT * FROM ix_entries WHERE user_id = %d"):format(userID)) or {}
    local sharedEntries = sql.Query(("SELECT e.* FROM ix_entries e INNER JOIN ix_shared_entries s ON e.id = s.entry_id WHERE s.user_id = %d"):format(userID)) or {}

    local updatedData = {}
    for _, entry in ipairs(personalEntries) do
        entry.shared = "NO"
        table.insert(updatedData, entry)
    end
    for _, entry in ipairs(sharedEntries) do
        entry.shared = "YES"
        table.insert(updatedData, entry)
    end

    net.Start("SendEntries")
    net.WriteTable(updatedData)
    net.Send(ply)
    print("Sent updated entries to " .. ply:Nick())
    print(updatedData)
end)

net.Receive("EditEntry", function(len, ply)
    local entryID = net.ReadInt(32)
    local newTitle = net.ReadString()
    local newText = net.ReadString()
    local newCreator = net.ReadString()

    sql.Query(("UPDATE ix_entries SET title = %s, text = %s, creator = %s WHERE id = %d AND user_id = %d"):format(sql.SQLStr(newTitle), sql.SQLStr(newText), sql.SQLStr(newCreator), entryID, ply.userID))

    local personalEntries = sql.Query(("SELECT * FROM ix_entries WHERE user_id = %d"):format(ply.userID)) or {}
    local sharedEntries = sql.Query(("SELECT e.* FROM ix_entries e INNER JOIN ix_shared_entries s ON e.id = s.entry_id WHERE s.user_id = %d"):format(ply.userID)) or {}

    local updatedData = {}
    for _, entry in ipairs(personalEntries) do
        entry.shared = "NO"
        table.insert(updatedData, entry)
    end
    for _, entry in ipairs(sharedEntries) do
        entry.shared = "YES"
        table.insert(updatedData, entry)
    end

    net.Start("SendEntries")
    net.WriteTable(updatedData)
    net.Send(ply)
    print("Sent updated entries to " .. ply:Nick())
end)

net.Receive("DeleteEntry", function(len, ply)
    local entryIDs = net.ReadTable()
    local userID = ply.userID

    for _, entryID in ipairs(entryIDs) do
        local entryOwner = sql.QueryValue(("SELECT user_id FROM ix_entries WHERE id = %d"):format(entryID))
        if entryOwner and (entryOwner == ply.userID) then
            sql.Query(("DELETE FROM ix_entries WHERE id = %d AND user_id = %d"):format(entryID, ply.userID))
        else
            net.Start("DeleteEntryResult")
            net.WriteBool(false)
            net.Send(ply)
            return
        end
    end

    local personalEntries = sql.Query(("SELECT * FROM ix_entries WHERE user_id = %d"):format(userID)) or {}
    local sharedEntries = sql.Query(("SELECT e.* FROM ix_entries e INNER JOIN ix_shared_entries s ON e.id = s.entry_id WHERE s.user_id = %d"):format(userID)) or {}

    local updatedData = {}
    for _, entry in ipairs(personalEntries) do
        entry.shared = "NO"
        table.insert(updatedData, entry)
    end
    for _, entry in ipairs(sharedEntries) do
        entry.shared = "YES"
        table.insert(updatedData, entry)
    end

    net.Start("SendEntries")
    net.WriteTable(updatedData)
    net.Send(ply)
    print("Sent updated entries to " .. ply:Nick())
end)

net.Receive("RequestAccounts", function(len, ply)
    local accounts = sql.Query("SELECT id, username FROM ix_accounts") or {}
    net.Start("SendAccounts")
    net.WriteTable(accounts)
    net.Send(ply)
end)

net.Receive("ShareEntry", function(len, ply)
    local entryID = net.ReadInt(32)
    local selectedUsers = net.ReadTable()
    local selectedTerminals = net.ReadTable()

    local userID = ply.userID

    for _, targetUserID in ipairs(selectedUsers) do
        if targetUserID ~= userID then
            sql.Query(string.format("INSERT INTO ix_shared_entries (entry_id, user_id, terminal_id) VALUES (%d, %d, %d)",
                    entryID, targetUserID, 0))
        end
    end

    for _, terminalID in ipairs(selectedTerminals) do
        sql.Query(string.format("INSERT INTO ix_shared_entries (entry_id, user_id, terminal_id) VALUES (%d, %d, %d)",
                entryID, userID, terminalID))
    end
end)

net.Receive("RegisterAccount", function(len, ply)
    local username = net.ReadString()
    local pin = net.ReadString()

    print("Received registration request for username:", username)
    print("PIN:", pin)

    if username == "" or pin == "" then
        print("Empty username or PIN. Registration failed.")
        net.Start("RegisterResult")
        net.WriteBool(false)
        net.Send(ply)
        return
    end

    local id = getUserID(username)
    if id then
        print("Username already exists. Registration failed.")
        net.Start("RegisterResult")
        net.WriteBool(false)
        net.Send(ply)
    else
        local query = string.format("INSERT INTO ix_accounts (username, pin) VALUES (%s, %s)",
                sql.SQLStr(username),
                sql.SQLStr(pin))
        print("SQL Query:", query)

        local result = sql.Query(query)
        local lastError = sql.LastError()

        if lastError then
            print("Error registering account:", lastError)
            net.Start("RegisterResult")
            net.WriteBool(false)
            net.Send(ply)
        else
            print("Account registered successfully.")
            net.Start("RegisterResult")
            net.WriteBool(true)
            net.Send(ply)
        end
    end
end)

net.Receive("LoginAttempt", function(len, ply)
    local username = net.ReadString()
    local pin = net.ReadString()
    local terminalID = net.ReadInt(32)
    print("Login Attempt on Terminal ID: " .. terminalID)
    local result = sql.QueryRow("SELECT id FROM ix_accounts WHERE username = " .. sql.SQLStr(username) .. " AND pin = " .. sql.SQLStr(pin))

    if result then
        ply.userID = result.id
        local id = getUserID(username)
        net.WriteInt(terminalID, 32)
        net.Start("LoginResult")
        net.WriteBool(true)
        net.Send(ply)

        net.Start("OpenTerminalUI")
        net.WriteInt(terminalID, 32)
        net.Send(ply)

        net.Start("SendUserID")
        net.WriteInt(id, 32)
        net.Send(ply)
    else
        net.WriteInt(terminalID, 32)
        net.Start("LoginResult")
        net.WriteBool(false)
        net.Send(ply)
    end
end)

net.Receive("EditEntryAttempt", function(len, ply)
    local selectedEntryID = net.ReadInt(32)

    if selectedEntryID then
        local entryOwner = sql.QueryValue(("SELECT user_id FROM ix_entries WHERE id = %d"):format(selectedEntryID))

        if entryOwner and entryOwner == ply.userID then
            net.Start("EditEntryResult")
            net.WriteBool(true)
            net.Send(ply)
        else
            net.Start("EditEntryResult")
            net.WriteBool(false)
            net.Send(ply)
        end
    else
        print("No entry selected for editing.")
    end
end)

net.Receive("RequestTerminals", function(len, ply)
    local terminals = sql.Query("SELECT * FROM ix_terminals") or {}

    net.Start("SendTerminals")
    net.WriteTable(terminals)
    net.Send(ply)
end)

net.Receive("SetTerminalID", function(len, ply)
    if not ply:IsAdmin() then return end

    local ent = net.ReadEntity()
    local terminalID = net.ReadInt(32)
    local terminalName = net.ReadString()

    if IsValid(ent) and (ent:GetClass() == "ix_unsc_datapad" or ent:GetClass() == "ix_terminal" or ent:GetClass() == "ix_cov_datapad") then
        ent:SetTerminalID(terminalID)
        ent:SetTerminalName(terminalName)

        local existingTerminal = sql.QueryRow(("SELECT * FROM ix_terminals WHERE terminal_id = %d"):format(terminalID))

        if existingTerminal then
            sql.Query(("UPDATE ix_terminals SET description = '%s' WHERE terminal_id = %d"):format(sql.SQLStr(terminalName, true), terminalID))
        else
            sql.Query(("INSERT INTO ix_terminals (terminal_id, description) VALUES (%d, '%s')"):format(terminalID, sql.SQLStr(terminalName, true)))
        end
    end
end)

net.Receive("StoreInteractedEntries", function(len, ply)
    local entryID = net.ReadInt(32)
    local title = net.ReadString()
    local text = net.ReadString()
    local date = net.ReadString()
    local creator = net.ReadString()

    local character = ply:GetCharacter()
    local characterID = character:GetID()
    print(characterID)

    local existingEntry = sql.Query(string.format("SELECT * FROM ix_datanav WHERE entry_id = %d AND character_id = %d",
        entryID, characterID
    ))

    if not existingEntry then
        sql.Query(string.format("INSERT INTO ix_datanav (entry_id, character_id, title, text, date, creator) VALUES (%d, %d, %s, %s, %s, %s)",
            entryID, characterID, sql.SQLStr(title), sql.SQLStr(text), sql.SQLStr(date), sql.SQLStr(creator)
        ))
        print("Stored interacted entry for " .. ply:Nick())
    else
        print("Entry already exists for " .. ply:Nick())
    end
end)

net.Receive("GetInteractedEntries", function(len, ply)
    local character = ply:GetCharacter()
    local characterID = character:GetID()

    if characterID then
        local results = sql.Query(string.format("SELECT * FROM ix_datanav WHERE character_id = %d", characterID)) or {}

        net.Start("SendInteractedEntries")
        net.WriteTable(results)
        net.Send(ply)
    else
        print("Error: User ID is nil for " .. ply:Nick())
    end
end)

local function updateDate()
    local currentDate = sql.QueryValue("SELECT date FROM ix_current_date WHERE id = 1")
    local year, month, day = currentDate:match("(%d+)-(%d+)-(%d+)")
    local nextDate = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day)}) + 24 * 60 * 60
    local newDate = os.date("%Y-%m-%d", nextDate)
    sql.Query("UPDATE ix_current_date SET date = " .. sql.SQLStr(newDate) .. " WHERE id = 1")
end

local function checkTime()
    local currentHour = os.date("!*t").hour
    if currentHour == 0 then
        updateDate()
    end
end

timer.Create("CheckForDateChange", 60, 0, checkTime)

concommand.Add("reclaimer_force_date", function(ply, cmd, args)
    if not ply:IsAdmin() then return end

    local newDate = args[1]

    if not newDate or not newDate:match("^%d%d%d%d%-%d%d%-%d%d$") then
        ply:ChatPrint("Invalid date format. Use YYYY-MM-DD.")
        return
    end

    local year, month, day = newDate:match("(%d+)-(%d+)-(%d+)")

    month = tonumber(month)
    day = tonumber(day)

    if month < 1 or month > 12 then
        ply:ChatPrint("Invalid month. Month must be between 1 and 12.")
        return
    end

    local daysInMonth = {
        [1] = 31, [2] = 28, [3] = 31, [4] = 30, [5] = 31, [6] = 30,
        [7] = 31, [8] = 31, [9] = 30, [10] = 31, [11] = 30, [12] = 31
    }

    if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
        daysInMonth[2] = 29
    end

    if day < 1 or day > daysInMonth[month] then
        ply:ChatPrint("Invalid day. Day must be between 1 and " .. daysInMonth[month] .. ".")
        return
    end

    sql.Query("UPDATE ix_current_date SET date = " .. sql.SQLStr(newDate) .. " WHERE id = 1")
    ply:ChatPrint("Date set to " .. newDate)
end)