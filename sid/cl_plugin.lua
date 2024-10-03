local squadFrame
local squadList
local isInSquad = false
local memberPanels = {}

local squadData = {
    name = "",
    members = {}
}

local roleMap = {
    leader = {name = "Squad Lead", icon = Material("sqlead.png"), order = 1},
    ["2ic"] = {name = "Squad 2IC", icon = Material("2ic.png"), order = 2},
    corpsman = {name = "Corpsman", icon = Material("corpsman.png"), order = 3},
    engineer = {name = "Engineer", icon = Material("engineer.png"), order = 4},
    member = {name = "Member", icon = Material("member.png"), order = 5},
}

local function UpdateSquadData(name, members)
    squadData.name = name
    squadData.members = members

    hook.Run("OnSquadDataUpdated")
end

net.Receive("ixSquadInfo", function()
    local squadName = string.upper(net.ReadString())
    local squadMembers = net.ReadTable()

    UpdateSquadData(squadName, squadMembers)
end)

net.Receive("ixSquadUpdate", function()
    local squadName = string.upper(net.ReadString())
    local updatedMembers = net.ReadTable()

    UpdateSquadData(squadName, updatedMembers)
end)

function CreateCustomFrame(message, title, confirmText, cancelText, confirmCallback, cancelCallback)
    local tempLabel = vgui.Create("DLabel")
    tempLabel:SetText(message)
    tempLabel:SizeToContents()

    local frameWidth = tempLabel:GetWide() + 50
    local frameHeight = 120

    local messageFrame = vgui.Create("DFrame")
    messageFrame:SetSize(frameWidth, frameHeight)
    messageFrame:Center()
    messageFrame:SetTitle("")
    messageFrame:MakePopup()

    messageFrame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 225))
        draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
        draw.SimpleText(title, "SquadListFont", 10, 5, Color(255, 0, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local messageLabel = vgui.Create("DLabel", messageFrame)
    messageLabel:SetText(message)
    messageLabel:SetTextColor(Color(241, 241, 241))
    messageLabel:SizeToContents()
    messageLabel:SetPos(25, 40)

    local confirmButton = vgui.Create("DButton", messageFrame)
    confirmButton:SetText(confirmText)
    confirmButton:SetPos(25, 80)
    confirmButton:SetSize(120, 30)
    confirmButton.DoClick = function()
        if confirmCallback then confirmCallback() end
        messageFrame:Close()
    end

    local cancelButton = vgui.Create("DButton", messageFrame)
    cancelButton:SetText(cancelText)
    cancelButton:SetPos(frameWidth - 145, 80)
    cancelButton:SetSize(120, 30)
    cancelButton.DoClick = function()
        if cancelCallback then cancelCallback() end
        messageFrame:Close()
    end

    tempLabel:Remove()
    return messageFrame
end

local function SquadMenu()
    if IsValid(squadFrame) then
        squadFrame:Show()
    else
        squadFrame = vgui.Create("DFrame")
        squadFrame:SetTitle("")
        squadFrame:SetSize(600, 400)
        squadFrame:Center()
        squadFrame:MakePopup()

        squadFrame.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 225))
            draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
            draw.SimpleText("Squad Identification System", "SquadRoleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local squadScroll = vgui.Create("DScrollPanel", squadFrame)
        squadScroll:SetSize(560, 275)
        squadScroll:SetPos(20, 30)

        local squadListPanel = vgui.Create("DIconLayout", squadScroll)
        squadListPanel:SetSize(560, 0)
        squadListPanel:SetSpaceY(5)

        local function PopulateSquadList(squads)
            squadListPanel:Clear()

            for _, squad in pairs(squads) do
                local squadEntry = squadListPanel:Add("DPanel")
                squadEntry:SetSize(560, 40)
                squadEntry.Paint = function(self, w, h)
                    local bgColor = self:IsHovered() and Color(4, 8, 18, 225) or Color(3, 7, 16, 175)
                    draw.RoundedBox(6, 0, 0, w, h, bgColor)
                    draw.SimpleText(squad.name, "SquadListFont", 20, h / 2 - 8, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Lead: " .. squad.leader, "SquadListFont", 20, h / 2 + 8, Color(225, 225, 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Members: " .. squad.count, "SquadListFont", w - 20, h / 2, Color(225, 225, 225), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end

                squadEntry.OnCursorEntered = function(self)
                    self:SetCursor("hand")
                end

                squadEntry.OnMousePressed = function()
                    net.Start("ixSquadJoin")
                    net.WriteString(squad.name)
                    net.SendToServer()
                end
            end
        end

        net.Receive("ixSquadList", function()
            local squads = net.ReadTable()
            PopulateSquadList(squads)
        end)

        local createButton = vgui.Create("DButton", squadFrame)
        createButton:SetText("")
        createButton:SetPos(20, 310)
        createButton:SetSize(560, 35)
        createButton:SetColor(Color(255, 255, 255))
        createButton.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and Color(4, 8, 18, 225) or Color(3, 7, 16, 175)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            draw.SimpleText("Create Squad", "SquadListFont", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        createButton.DoClick = function()
            Derma_StringRequest("Create Squad", "Enter new squad name:", "", function(squadName)
                if text ~= "" then
                    net.Start("ixSquadCreate")
                    net.WriteString(squadName)
                    net.SendToServer()
                end
            end)
        end

        local leaveButton = vgui.Create("DButton", squadFrame)
        leaveButton:SetText("")
        leaveButton:SetPos(20, 350)
        leaveButton:SetSize(270, 35)
        leaveButton.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and Color(4, 8, 18, 225) or Color(3, 7, 16, 175)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            draw.SimpleText("Leave Squad", "SquadListFont", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        leaveButton.DoClick = function()
            CreateCustomFrame(
                    "Are you sure you want to leave your current squad?",
                    "Leave Squad",
                    "Yes",
                    "No",
                    function()
                        net.Start("ixSquadLeave")
                        net.SendToServer()
                    end,
                    nil
            )
        end

        local disbandButton = vgui.Create("DButton", squadFrame)
        disbandButton:SetText("")
        disbandButton:SetPos(310, 350)
        disbandButton:SetSize(270, 35)
        disbandButton.Paint = function(self, w, h)
            local bgColor = self:IsHovered() and Color(4, 8, 18, 225) or Color(3, 7, 16, 175)
            draw.RoundedBox(6, 0, 0, w, h, bgColor)
            draw.SimpleText("Disband Squad", "SquadListFont", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        disbandButton.DoClick = function()
            CreateCustomFrame(
                    "Are you sure you want to disband your current squad?",
                    "Disband Squad",
                    "Yes",
                    "No",
                    function()
                        net.Start("ixSquadDisband")
                        net.SendToServer()
                    end,
                    nil
            )
        end
    end
end

local function GetHealthColor(healthPercent)
    local color
    if healthPercent > 75 then
        color = Color(0, 255, 0)
    elseif healthPercent > 50 then
        color = Color(255, 255, 0)
    elseif healthPercent > 25 then
        color = Color(255, 165, 0)
    else
        color = Color(255, 0, 0)
    end
    return color
end

local function GetRankAndLastName(name)
    local sections = string.Explode(" ", name)
    local rank = sections[1] or ""
    local lastName = sections[#sections] or ""
    return rank, lastName
end

local function DrawSquadOverlay()
    if squadData.name ~= "" and #squadData.members > 0 then
        isInSquad = true
    else
        isInSquad = false
    end

    table.sort(squadData.members, function(a, b)
        local roleA = a.role or "member"
        local roleB = b.role or "member"
        local orderA = roleMap[roleA] and roleMap[roleA].order or 99
        local orderB = roleMap[roleB] and roleMap[roleB].order or 99
        return orderA < orderB
    end)

    local function RequestSetSquadRole(memberCid, newRole)
        if memberCid then
            net.Start("ixSetSquadRole")
            net.WriteInt(memberCid, 32)
            net.WriteString(newRole)
            net.SendToServer()
        end

        hook.Remove("HUDPaintBackground", "DrawSquadOverlay")
        net.Start("ixGetSquadInfo")
        net.SendToServer()
        DrawSquadOverlay()
    end

    local function CreateSquadMemberPanel(member, x, y, width, memberHeight)
        local memberPanel = vgui.Create("DPanel")
        memberPanel:SetPos(x, y)
        memberPanel:SetSize(width, memberHeight)
        memberPanel.Paint = function() end

        memberPanel.OnMousePressed = function(_, mouseCode)
            if mouseCode == MOUSE_RIGHT then
                if member.cid ~= LocalPlayer():GetCharacter():GetID() then
                    local menu = vgui.Create("DMenu", memberPanel)
                    menu:AddOption("2IC", function()
                        RequestSetSquadRole(member.member_cid, "2ic")
                    end)
                    menu:AddOption("Corpsman", function()
                        RequestSetSquadRole(member.member_cid, "corpsman")
                    end)
                    menu:AddOption("Engineer", function()
                        RequestSetSquadRole(member.member_cid, "engineer")
                    end)
                    menu:AddOption("Member", function()
                        RequestSetSquadRole(member.member_cid, "member")
                    end)
                    menu:Open()
                end
            end
        end

        return memberPanel
    end

    hook.Add("HUDPaintBackground", "DrawSquadOverlay", function()
        if not isInSquad then return end

        local ply = LocalPlayer()
        if not ply:GetCharacter() then return end

        local x, y = ScrW() * 0.86, ScrH() * 0.35
        local width = 250
        local titleHeight = 40
        local memberHeight = 30
        local boxPadding = 10
        local boxRadius = 12
        local memberSpacing = 10

        local height = titleHeight + #squadData.members * (memberHeight + memberSpacing)

        draw.RoundedBox(boxRadius, x - boxPadding, y - titleHeight - boxPadding, width + boxPadding * 2, height + boxPadding, Color(0, 0, 0, 150))

        surface.SetFont("SquadTitleFont")
        local titleWidth = surface.GetTextSize(squadData.name)
        surface.SetTextColor(255, 255, 255)
        surface.SetTextPos(x + (width / 2) - (titleWidth / 2), y - titleHeight - 5)
        surface.DrawText(squadData.name)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(x, y - 10, width, 2)

        for i, member in ipairs(squadData.members) do
            local healthPercent = (member.health or 0)
            local healthText = healthPercent > 1 and (healthPercent .. "%") or "CRIT"
            local healthColor = (healthPercent == 0) and Color(255, 0, 0) or GetHealthColor(healthPercent)

            local rank, lastName = GetRankAndLastName(member.name)
            local roleDetails = roleMap[member.role] or {name = member.role, icon = nil}
            local roleName = roleDetails.name
            local roleIcon = roleDetails.icon

            if roleIcon then
                surface.SetMaterial(roleIcon)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(x + 2.5, y, 32, 32)
            end

            surface.SetFont("SquadMemberFont")
            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(x + 40, y)
            surface.DrawText(rank .. " " .. lastName)

            surface.SetFont("SquadMemberFont")
            local healthTextWidth = surface.GetTextSize(healthText)
            surface.SetTextColor(healthColor)
            surface.SetTextPos(x + width - healthTextWidth - 5, y + 5)
            surface.DrawText(healthText)

            y = y + 15

            surface.SetFont("SquadRoleFont")
            surface.SetTextColor(200, 200, 200)
            surface.SetTextPos(x + 40, y)
            surface.DrawText(roleName)

            if not memberPanels[member.member_cid] then
                memberPanels[member.member_cid] = CreateSquadMemberPanel(member, x, y - 15, width, memberHeight)
            end

            y = y + memberSpacing + 10

            if i < #squadData.members then
                surface.SetDrawColor(255, 255, 255, 55)
                surface.DrawRect(x, y, width, 1)
                y = y + 5
            end
        end
    end)
end

local function PingDisplay()
    local pingCooldown = false
    local activePing = nil
    local pingMarkerSize = 24
    local pingPadding = 10
    local pingDuration = 15

    net.Receive("ixReceivePing", function()
        local pingPos = net.ReadVector()
        local name = net.ReadString()

        activePing = { pos = pingPos, name = name, time = CurTime() }
    end)

    hook.Add("PlayerButtonDown", "PingSystem", function(ply, button)
        if button == KEY_X then
            if not pingCooldown then
                pingCooldown = true

                local tr = ply:GetEyeTrace()
                local pingPos = tr.HitPos

                net.Start("ixSendPing")
                net.WriteVector(pingPos)
                net.WriteString(ply:GetName())
                net.SendToServer()

                timer.Simple(3, function()
                    pingCooldown = false
                end)
            end
        end
    end)

    hook.Add("Think", "PingExpiration", function()
        if activePing and CurTime() - activePing.time > pingDuration then
            activePing = nil
        end
    end)

    hook.Add("HUDPaint", "DrawPingHUD", function()
        if not isInSquad then return end

        if activePing then
            local pos = activePing.pos
            local name = activePing.name

            local distance = LocalPlayer():GetPos():Distance(pos) * 0.01905

            if pos then
                local screenPos = pos:ToScreen()

                if screenPos.visible then
                    draw.SimpleText(name, "Trebuchet24", screenPos.x, screenPos.y - (pingMarkerSize / 2) - pingPadding, Color(180, 180, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

                    local materialWidth = 32
                    local materialHeight = 32
                    local materialX = screenPos.x - (materialWidth / 2)
                    local materialY = screenPos.y - (pingMarkerSize / 2) - pingPadding + 5

                    surface.SetDrawColor(180, 180, 180, 255)
                    surface.SetMaterial(Material("ping.png"))
                    surface.DrawTexturedRect(materialX, materialY, materialWidth, materialHeight)

                    draw.SimpleText(string.format("%.1f meters", distance), "Trebuchet24", screenPos.x, screenPos.y - (pingMarkerSize / 2) - pingPadding - 20, Color(180, 180, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                end
            end
        end
    end)
end

local function IFFDisplay()
    local iconSize = 32

    hook.Add("HUDPaint", "DrawSquadMemberNames", function()
        if not isInSquad then
            return
        end

        if not squadData or not squadData.members then
            return
        end

        local localPlayer = LocalPlayer()

        for _, ply in ipairs(player.GetAll()) do
            if ply ~= localPlayer and IsValid(ply) and ply:Alive() then
                local char = ply:GetCharacter()
                local name = char and char:GetName() or "Unknown"
                local playerID = char and tonumber(char:GetID()) or nil

                local isSquadMember = false
                for _, member in ipairs(squadData.members) do
                    local memberCID = tonumber(member.member_cid)

                    if memberCID == playerID then
                        isSquadMember = true
                        break
                    end
                end

                if isSquadMember then
                    local pos = ply:GetPos() + Vector(0, 0, 80)
                    local screenPos = pos:ToScreen()

                    draw.SimpleText(name, "Trebuchet24", screenPos.x, screenPos.y - iconSize / 2 - 10, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

                    local roleIcon = Material("member.png")
                    for _, member in ipairs(squadData.members) do
                        local memberCID = tonumber(member.member_cid)
                        if memberCID == playerID and roleMap[member.role] then
                            roleIcon = roleMap[member.role].icon
                        end
                    end

                    if roleIcon then
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.SetMaterial(roleIcon)
                        surface.DrawTexturedRect(screenPos.x - iconSize / 2, screenPos.y - iconSize / 2, iconSize, iconSize)
                    end
                end
            end
        end
    end)
end

net.Receive("ixOpenSquadMenu", function()
    SquadMenu()
    net.Start("ixGetSquadList")
    net.SendToServer()
end)

net.Receive("ixSquadLeaveClient", function()
    hook.Remove("HUDPaintBackground", "DrawSquadOverlay")
    hook.Remove("HUDPaint", "DrawPingHUD")
    hook.Remove("HUDPaint", "DrawSquadMemberNames")
end)

net.Receive("ixSquadJoinClient", function()
    net.Start("ixGetSquadInfo")
    net.SendToServer()
    DrawSquadOverlay()
    PingDisplay()
    IFFDisplay()
end)

hook.Add("CharacterLoaded", "DisplaySquadOverlay", function()
    net.Start("ixGetSquadInfo")
    net.SendToServer()
    DrawSquadOverlay()
    PingDisplay()
    IFFDisplay()
end)

hook.Add("OnSquadDataUpdated", "RefreshSquadDisplay", function()
    DrawSquadOverlay()
end)

hook.Add("OnSquadDataUpdated", "RefreshPingDisplay", function()
    PingDisplay()
end)

hook.Add("OnSquadDataUpdated", "RefreshIFFDisplay", function()
    IFFDisplay()
end)