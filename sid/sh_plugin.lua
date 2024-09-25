PLUGIN.name = "Squad System"
PLUGIN.author = "Fiorelus"
PLUGIN.description = "A plugin for squad management using a Squad Identifier Device."

ix.util.Include("items/sh_sid.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")

local function GetSquadMembers(characterID)
    local squadID = sql.QueryValue("SELECT squad_id FROM ix_squad_roles WHERE member_cid = " .. sql.SQLStr(tostring(characterID)))

    if not squadID then return {} end

    local members = sql.Query("SELECT member_cid FROM ix_squad_roles WHERE squad_id = " .. sql.SQLStr(squadID))
    local memberIDs = {}

    if members then
        for _, member in ipairs(members) do
            table.insert(memberIDs, tonumber(member.member_cid))
        end
    end

    return memberIDs
end

local function GetPlayerByCharacterID(characterID)
    for _, ply in pairs(player.GetAll()) do
        if ply:GetCharacter() and ply:GetCharacter():GetID() == characterID then
            return ply
        end
    end
    return nil
end

local function FormatMessage(message)
    message = message:sub(1, 1):upper() .. message:sub(2)

    if not message:match("[.!?]$") then
        message = message .. "."
    end

    return message
end

function PLUGIN:InitializedChatClasses()
    ix.chat.Register("squad", {
        format = "[SQUAD] %s says \"%s\"",
        color = Color(255, 255, 255),
    })
end

ix.command.Add("Squad", {
    description = "Send a message to your squad.",
    arguments = ix.type.text,
    OnRun = function(self, client, message)
        local formattedMessage = FormatMessage(message)

        if not message or message == "" then
            client:ChatPrint("Please provide a message to send.")
            return
        end

        local squadMembers = GetSquadMembers(client:GetCharacter():GetID())

        for _, memberID in ipairs(squadMembers) do
            local member = GetPlayerByCharacterID(memberID)
            if IsValid(member) then
                ix.chat.Send(member, "squad", formattedMessage, false, client)
            end
        end
    end
})