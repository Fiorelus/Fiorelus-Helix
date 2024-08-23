local loginFrame
local localUserID = nil
local customEntryPanels = {}

function OpenLoginUI(terminalID)
    loginFrame = vgui.Create("DFrame")
    loginFrame:SetSize(250, 200)
    loginFrame:SetTitle("")
    loginFrame:Center()
    loginFrame:SetDraggable(false)
    loginFrame:MakePopup()

    local usernameLabel = vgui.Create("DLabel", loginFrame)
    usernameLabel:SetPos(5, 30)
    usernameLabel:SetText("User:")
    usernameLabel:SizeToContents()

    local usernameEntry = vgui.Create("DTextEntry", loginFrame)
    usernameEntry:SetPos(5, 45)
    usernameEntry:SetSize(240, 25)
    usernameEntry:SetPlaceholderText("Username")

    local pinLabel = vgui.Create("DLabel", loginFrame)
    pinLabel:SetPos(5, 75)
    pinLabel:SetText("PIN:")
    pinLabel:SizeToContents()

    local pinEntry = vgui.Create("DTextEntry", loginFrame)
    pinEntry:SetPos(5, 90)
    pinEntry:SetSize(240, 25)
    pinEntry:SetNumeric(true)
    pinEntry:SetUpdateOnType(true)
    pinEntry:SetPlaceholderText("PIN")

    pinEntry.OnValueChange = function(self, value)
        if #value > 6 then
            self:SetText(string.sub(value, 1, 6))
        end
    end

    local loginButton = vgui.Create("DButton", loginFrame)
    loginButton:SetPos(5, 170)
    loginButton:SetSize(60, 25)
    loginButton:SetText("Login")
    loginButton.DoClick = function()
        local username = usernameEntry:GetValue()
        local pin = pinEntry:GetValue()
        net.Start("LoginAttempt")
        net.WriteString(username)
        net.WriteString(pin)
        net.WriteInt(terminalID, 32)
        net.SendToServer()
    end

    net.Receive("LoginResult", function(ply)
        local success = net.ReadBool()
        if success then
            if IsValid(loginFrame) then
                loginFrame:Close()
            end
        else
            CreateCustomMessageFrame("Login failed. Please check your credentials.", "Error", "OK")
        end

        net.Receive("SendUserID", function()
            localUserID = net.ReadInt(32)
        end)
    end)

    local registerButton = vgui.Create("DButton", loginFrame)
    registerButton:SetPos(185, 170)
    registerButton:SetSize(60, 25)
    registerButton:SetText("Register")
    registerButton.DoClick = function()
        local username = usernameEntry:GetValue()
        local pin = pinEntry:GetValue()
        net.Start("RegisterAccount")
        net.WriteString(username)
        net.WriteString(pin)
        net.SendToServer()
    end

    loginFrame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 195))
        draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
        draw.SimpleText("Login/Register", "TitleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

function CreateEntryPanel(entry)
    local panel = vgui.Create("DPanel")
    panel:SetSize(0, 125)
    panel.entryID = entry.id
    panel.isSelected = false
    panel.title = entry.title
    panel.text = entry.text
    panel.date = entry.date
    panel.creator = entry.creator
    panel.lastClickTime = 0

    panel.Paint = function(self, w, h)
        if self.isSelected then
            draw.RoundedBox(6, 0, 0, w, h, Color(200, 200, 200, 100))
        else
            draw.RoundedBox(6, 0, 0, w, h, Color(30, 30, 30, 235))
        end
        surface.SetDrawColor(241, 241, 241)

        draw.SimpleText(entry.title, "DermaLarge", 10, 5, Color(241, 241, 241), TEXT_ALIGN_LEFT)

        local textMaxWidth = w - 50
        local textWidth, _ = surface.GetTextSize(entry.text)

        if textWidth > textMaxWidth then
            local maxChars = math.floor(textMaxWidth / textWidth * #entry.text) - 3
            entry.text = string.sub(entry.text, 1, maxChars) .. "..."
        end
        draw.SimpleText(entry.text, "DermaDefault", 10, 45, Color(241, 241, 241), TEXT_ALIGN_LEFT)
        draw.SimpleText(entry.date, "DermaDefault", w - 67.5, 5, Color(241, 241, 241), TEXT_ALIGN_LEFT)
        draw.SimpleText("Origin: " .. entry.creator, "DermaDefault", 10, 105, Color(241, 241, 241), TEXT_ALIGN_LEFT)

        if entry.shared == "YES" then
            draw.SimpleText("Shared: YES", "DermaDefault", w - 67.5, 105, Color(241, 241, 241), TEXT_ALIGN_LEFT)
        else
            draw.SimpleText("Shared: NO", "DermaDefault", w - 65, 105, Color(241, 241, 241), TEXT_ALIGN_LEFT)
        end
    end

    panel.ClearSelection = function(self)
        self.isSelected = false
    end

    panel.OnMousePressed = function(self, key)
        if key == MOUSE_LEFT then
            local currentTime = CurTime()

            if currentTime - self.lastClickTime < 0.3 then
                if IsValid(panel) then
                    local entryID = panel.entryID
                    local title = panel.title
                    local text = panel.text
                    local date = panel.date
                    local creator = panel.creator
                    OpenDetailedView(entryID, title, text, date, creator)
                end
                return
            end

            if not self.isSelected then
                for _, otherPanel in ipairs(customEntryPanels) do
                    if otherPanel.ClearSelection then
                        otherPanel:ClearSelection()
                    end
                end
                self.isSelected = true
            end

            self.lastClickTime = currentTime
        end
    end

    table.insert(customEntryPanels, panel)
    return panel
end

function OpenTerminalUI(terminalID)
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.75, ScrH() * 0.75)
    frame:SetTitle("Terminal #" .. terminalID)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(3, 7, 16, 175))
        draw.RoundedBoxEx(4, 0, 0, w, 24, Color(3, 7, 16), true, true, false, false)
        draw.RoundedBoxEx(4, 0, 24, w, h - 24, Color(3, 7, 16, 175), false, false, true, true)

        local borderWidth = 4
        surface.SetDrawColor(Color(3, 7, 16))
        surface.DrawOutlinedRect(borderWidth / 2, borderWidth / 2, w - borderWidth, h - borderWidth)

        local buttonAreaHeight = 37.5
        draw.RoundedBox(0, 0, h - buttonAreaHeight, w, buttonAreaHeight, Color(3, 7, 16, 200))
    end
    frame.lblTitle:SetColor(Color(241, 241, 241))
    frame.btnClose:SetColor(Color(241, 241, 241))

    local entryList = vgui.Create("DPanelList", frame)
    entryList:Dock(FILL)
    entryList:DockMargin(0, 0, 0, 35)
    entryList:SetSpacing(5)
    entryList:EnableVerticalScrollbar(true)

    entryList.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(3, 7, 16, 10))
    end

    function entryList:ClearSelection(selectedPanel)
        for _, panel in ipairs(self:GetChildren()) do
            if panel ~= selectedPanel then
                panel.isSelected = false
            end
        end
    end

    function OpenDetailedView(entryID, title, text, date, creator)
        local detailFrame = vgui.Create("DFrame")
        detailFrame:SetSize(600, 500)
        detailFrame:SetTitle("")
        detailFrame:Center()
        detailFrame:MakePopup()
        detailFrame:DoModal()
        detailFrame:SetDraggable(false)

        detailFrame.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 175))
            draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
            draw.SimpleText("Entry Details", "TitleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local titleText = vgui.Create("DLabel", detailFrame)
        titleText:SetPos(280, 50)
        titleText:SetText(title)
        titleText:SetColor(Color(241, 241, 241))
        titleText:SetFont("HeadingFont")
        titleText:SizeToContents()

        local richTextPanel = vgui.Create("RichText", detailFrame)
        richTextPanel:SetPos(10, 85)
        richTextPanel:SetSize(580, 380)
        richTextPanel:AppendText(text)

        local textColor = Color(241, 241, 241)
        local backgroundColor = Color(1, 39, 66)
        richTextPanel:SetTextSelectionColors(textColor, backgroundColor)

        richTextPanel.Paint = function(self, w, h)
            self:SetFontInternal("TextFont")
            self:SetFGColor(Color(241, 241, 241))
        end

        local dateText = vgui.Create("DLabel", detailFrame)
        dateText:SetPos(530, 480)
        dateText:SetText(date)
        dateText:SetColor(Color(241, 241, 241))
        dateText:SetFont("TitleFont")
        dateText:SizeToContents()

        local creatorText = vgui.Create("DLabel", detailFrame)
        creatorText:SetPos(5, 480)
        creatorText:SetText("Origin: " .. creator)
        creatorText:SetColor(Color(241, 241, 241))
        creatorText:SetFont("TitleFont")
        creatorText:SizeToContents()

        local function CenterTitleText()
            local textWidth = titleText:GetWide()
            titleText:SetPos((detailFrame:GetWide() - textWidth) / 2, 50)
        end

        CenterTitleText()

        hook.Add("Think", "KeepFrameOnTop", function()
            if IsValid(detailFrame) then
                detailFrame:MakePopup()
            else
                hook.Remove("Think", "KeepFrameOnTop")
            end
        end)
    end

    local buttonWidth, buttonHeight = 60, 30
    local buttonSpacing = 10

    local totalButtonWidth = (buttonWidth * 4) + (buttonSpacing * 3)

    local startX = frame:GetWide() - totalButtonWidth - 5
    local startY = frame:GetTall() - buttonHeight - 5

    local function UpdateEntryList(entries)
        entryList:Clear()
        customEntryPanels = {}
        for _, entry in ipairs(entries) do
            local entryPanel = CreateEntryPanel(entry)
            entryList:AddItem(entryPanel)
        end
    end

    net.Start("GetEntries")
    net.SendToServer()

    net.Receive("SendEntries", function()
        local entries = net.ReadTable()
        UpdateEntryList(entries)
    end)

    local addButton = vgui.Create("DButton", frame)
    addButton:SetText("Add")
    addButton:SetSize(buttonWidth, buttonHeight)
    addButton:SetPos(startX, startY)
    addButton.DoClick = function()
        local addFrame = vgui.Create("DFrame")
        addFrame:SetSize(300, 250)
        addFrame:SetTitle("")
        addFrame:Center()
        addFrame:MakePopup()

        local titleLabel = vgui.Create("DLabel", addFrame)
        titleLabel:SetPos(5, 30)
        titleLabel:SetText("Title:")
        titleLabel:SizeToContents()

        local titleEntry = vgui.Create("DTextEntry", addFrame)
        titleEntry:SetPos(5, 45)
        titleEntry:SetSize(290, 25)

        local textLabel = vgui.Create("DLabel", addFrame)
        textLabel:SetPos(5, 75)
        textLabel:SetText("Text:")
        textLabel:SizeToContents()

        local textEntry = vgui.Create("DTextEntry", addFrame)
        textEntry:SetPos(5, 90)
        textEntry:SetSize(290, 50)
        textEntry:SetMultiline(true)

        local creatorLabel = vgui.Create("DLabel", addFrame)
        creatorLabel:SetPos(5, 145)
        creatorLabel:SetText("Creator:")
        creatorLabel:SizeToContents()

        local creatorEntry = vgui.Create("DTextEntry", addFrame)
        creatorEntry:SetPos(5, 160)
        creatorEntry:SetSize(290, 25)

        local submitButton = vgui.Create("DButton", addFrame)
        submitButton:SetPos(10, 220)
        submitButton:SetSize(290, 25)
        submitButton:SetText("Submit")
        submitButton.DoClick = function()
            net.Start("AddEntry")
            net.WriteString(titleEntry:GetValue())
            net.WriteString(textEntry:GetValue())
            net.WriteString(creatorEntry:GetValue())
            net.SendToServer()
            addFrame:Close()
        end

        addFrame.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 175))
            draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
            draw.SimpleText("Add Entry", "TitleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        hook.Add("Think", "KeepFrameOnTop", function()
            if IsValid(addFrame) then
                addFrame:MakePopup()
            else
                hook.Remove("Think", "KeepFrameOnTop")
            end
        end)
    end

    function EditEntryFrame(entryID, title, text, creator)
        local editFrame = vgui.Create("DFrame")
        editFrame:SetSize(300, 250)
        editFrame:SetTitle("")
        editFrame:Center()
        editFrame:MakePopup()

        local titleLabel = vgui.Create("DLabel", editFrame)
        titleLabel:SetPos(5, 30)
        titleLabel:SetText("Title:")
        titleLabel:SizeToContents()

        local titleEntry = vgui.Create("DTextEntry", editFrame)
        titleEntry:SetPos(5, 45)
        titleEntry:SetSize(290, 25)
        titleEntry:SetText(title)

        local textLabel = vgui.Create("DLabel", editFrame)
        textLabel:SetPos(5, 75)
        textLabel:SetText("Text:")
        textLabel:SizeToContents()

        local textEntry = vgui.Create("DTextEntry", editFrame)
        textEntry:SetPos(5, 90)
        textEntry:SetSize(290, 50)
        textEntry:SetText(text)
        textEntry:SetMultiline(true)

        local creatorLabel = vgui.Create("DLabel", editFrame)
        creatorLabel:SetPos(5, 145)
        creatorLabel:SetText("Creator:")
        creatorLabel:SizeToContents()

        local creatorEntry = vgui.Create("DTextEntry", editFrame)
        creatorEntry:SetPos(5, 160)
        creatorEntry:SetSize(290, 25)
        creatorEntry:SetText(creator)
        creatorEntry:SetEditable(false)

        local submitButton = vgui.Create("DButton", editFrame)
        submitButton:SetPos(5, 220)
        submitButton:SetSize(290, 25)
        submitButton:SetText("Submit")
        submitButton.DoClick = function()
            net.Start("EditEntry")
            net.WriteInt(entryID, 32)
            net.WriteString(titleEntry:GetValue())
            net.WriteString(textEntry:GetValue())
            net.WriteString(creatorEntry:GetValue())
            net.SendToServer()
            editFrame:Close()
        end

        editFrame.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 175))
            draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
            draw.SimpleText("Edit Entry", "TitleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        hook.Add("Think", "KeepFrameOnTop", function()
            if IsValid(editFrame) then
                editFrame:MakePopup()
            else
                hook.Remove("Think", "KeepFrameOnTop")
            end
        end)
    end

    local editButton = vgui.Create("DButton", frame)
    editButton:SetText("Edit")
    editButton:SetSize(buttonWidth, buttonHeight)
    editButton:SetPos(startX + buttonWidth + buttonSpacing, startY)
    editButton.DoClick = function()
        local selectedEntryID = nil

        for _, panel in ipairs(customEntryPanels) do
            if panel.isSelected then
                selectedEntryID = panel.entryID
                break
            end
        end

        if selectedEntryID then
            net.Start("EditEntryAttempt")
            net.WriteInt(selectedEntryID, 32)
            net.SendToServer()
        end
    end

    local deleteButton = vgui.Create("DButton", frame)
    deleteButton:SetText("Delete")
    deleteButton:SetSize(buttonWidth, buttonHeight)
    deleteButton:SetPos(startX + (buttonWidth + buttonSpacing) * 2, startY)
    deleteButton.DoClick = function()
        local selectedEntryIDs = {}

        for _, panel in ipairs(customEntryPanels) do
            if panel.isSelected then
                table.insert(selectedEntryIDs, panel.entryID)
            end
        end

        net.Start("DeleteEntry")
        net.WriteTable(selectedEntryIDs)
        net.SendToServer()
    end

    function OpenShareEntryFrame(entryID)
        local shareFrame = vgui.Create("DFrame")
        shareFrame:SetSize(300, 400)
        shareFrame:SetTitle("")
        shareFrame:Center()
        shareFrame:MakePopup()

        local userList = vgui.Create("DListView", shareFrame)
        userList:Dock(FILL)
        userList:AddColumn("Name")
        userList:AddColumn("ID")

        net.Start("RequestAccounts")
        net.SendToServer()

        net.Receive("SendAccounts", function()
            local accounts = net.ReadTable()
            for _, account in ipairs(accounts) do
                if tonumber(account.id) ~= localUserID then
                    userList:AddLine(account.username, account.id)
                end
            end
        end)

        net.Start("RequestTerminals")
        net.SendToServer()

        net.Receive("SendTerminals", function()
            local terminals = net.ReadTable()
            for _, terminal in ipairs(terminals) do
                if tonumber(terminal.terminal_id) ~= terminalID then
                    userList:AddLine(terminal.description, "T" .. terminal.terminal_id)
                end
            end
        end)

        local shareButton = vgui.Create("DButton", shareFrame)
        shareButton:SetText("Share")
        shareButton:SetSize(280, 20)
        shareButton:SetPos(10, 370)
        shareButton.DoClick = function()
            local selectedUsers = {}
            local selectedTerminals = {}
            for _, line in pairs(userList:GetSelected()) do
                local id = line:GetColumnText(2)
                if string.sub(id, 1, 1) == "T" then
                    table.insert(selectedTerminals, tonumber(string.sub(id, 2)))
                else
                    table.insert(selectedUsers, tonumber(id))
                end
            end
            net.Start("ShareEntry")
            net.WriteInt(entryID, 32)
            net.WriteTable(selectedUsers)
            net.WriteTable(selectedTerminals)
            net.WriteBool(false)
            net.SendToServer()

            shareFrame:Close()
        end

        shareFrame.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 175))
            draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
            draw.SimpleText("Share Entry", "TitleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        hook.Add("Think", "KeepFrameOnTop", function()
            if IsValid(shareFrame) then
                shareFrame:MakePopup()
            else
                hook.Remove("Think", "KeepFrameOnTop")
            end
        end)
    end

    local shareButton = vgui.Create("DButton", frame)
    shareButton:SetText("Share")
    shareButton:SetSize(buttonWidth, buttonHeight)
    shareButton:SetPos(startX + (buttonWidth + buttonSpacing) * 3, startY)
    shareButton.DoClick = function()
        local selectedEntryID = nil

        for _, panel in ipairs(customEntryPanels) do
            if panel.isSelected then
                selectedEntryID = panel.entryID
                break
            end
        end

        if selectedEntryID then
            OpenShareEntryFrame(selectedEntryID)
        end
    end
end

function OpenDatapadUI(terminalID)
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.75, ScrH() * 0.75)
    frame:SetTitle("Datapad #" .. terminalID)
    frame:Center()
    frame:MakePopup()
    frame:DoModal()
    frame:SetDraggable(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(3, 7, 16, 175))
        draw.RoundedBoxEx(4, 0, 0, w, 24, Color(3, 7, 16), true, true, false, false)
        draw.RoundedBoxEx(4, 0, 24, w, h - 24, Color(3, 7, 16, 175), false, false, true, true)
    end
    frame.lblTitle:SetColor(Color(241, 241, 241))
    frame.btnClose:SetColor(Color(241, 241, 241))

    local entryList = vgui.Create("DPanelList", frame)
    entryList:Dock(FILL)
    entryList:DockMargin(0, 0, 0, 35)
    entryList:SetSpacing(5)
    entryList:EnableVerticalScrollbar(true)

    function entryList:ClearSelection(selectedPanel)
        for _, panel in ipairs(self:GetChildren()) do
            if panel ~= selectedPanel and panel.ClearSelection then
                panel:ClearSelection()
            end
        end
    end

    function OpenDetailedView(entryID, title, text, date, creator)
        local detailFrame = vgui.Create("DFrame")
        detailFrame:SetSize(600, 500)
        detailFrame:SetTitle("")
        detailFrame:Center()
        detailFrame:MakePopup()
        detailFrame:DoModal()
        detailFrame:SetDraggable(false)

        detailFrame.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 175))
            draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
            draw.SimpleText("Entry Details", "TitleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local titleText = vgui.Create("DLabel", detailFrame)
        titleText:SetPos(280, 50)
        titleText:SetText(title)
        titleText:SetColor(Color(241, 241, 241))
        titleText:SetFont("HeadingFont")
        titleText:SizeToContents()

        local textScrollPanel = vgui.Create("DScrollPanel", detailFrame)
        textScrollPanel:SetPos(10, 110)
        textScrollPanel:SetSize(580, 300)

        local textText = vgui.Create("DTextEntry", textScrollPanel)
        textText:SetPos(10, 0)
        textText:SetSize(560, 300)
        textText:SetMultiline(true)
        textText:SetText(text)
        textText:SetFont("TextFont")
        textText:SetEditable(false)
        textText:SetTall(textText:GetTall() + 1)

        local dateText = vgui.Create("DLabel", detailFrame)
        dateText:SetPos(530, 480)
        dateText:SetText(date)
        dateText:SetColor(Color(241, 241, 241))
        dateText:SetFont("TitleFont")
        dateText:SizeToContents()

        local creatorText = vgui.Create("DLabel", detailFrame)
        creatorText:SetPos(5, 480)
        creatorText:SetText("Origin: " .. creator)
        creatorText:SetColor(Color(241, 241, 241))
        creatorText:SetFont("TitleFont")
        creatorText:SizeToContents()

        textText.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 0))
            self:DrawTextEntryText(Color(241, 241, 241), Color(30, 144, 255), Color(241, 241, 241))
        end

        local function CenterTitleText()
            local textWidth = titleText:GetWide()
            titleText:SetPos((detailFrame:GetWide() - textWidth) / 2, 50)
        end

        CenterTitleText()

        hook.Add("Think", "KeepFrameOnTop", function()
            if IsValid(detailFrame) then
                detailFrame:MakePopup()
            else
                hook.Remove("Think", "KeepFrameOnTop")
            end
        end)

        net.Start("StoreInteractedEntries")
        net.WriteInt(entryID, 32)
        net.WriteString(title)
        net.WriteString(text)
        net.WriteString(date)
        net.WriteString(creator)
        net.SendToServer()
    end

    local function UpdateEntryList(entries)
        entryList:Clear()
        for _, entry in ipairs(entries) do
            local entryPanel = CreateEntryPanel(entry)
            entryList:AddItem(entryPanel)
        end
    end

    net.Start("GetDatapadEntries")
    net.WriteInt(terminalID, 32)
    net.SendToServer()

    net.Receive("SendEntries", function()
        local entries = net.ReadTable()
        UpdateEntryList(entries)
    end)
end

function OpenDatanavUI()
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.75, ScrH() * 0.75)
    frame:SetTitle("UNSC Datanav")
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(3, 7, 16, 175))
        draw.RoundedBoxEx(4, 0, 0, w, 24, Color(3, 7, 16), true, true, false, false)
        draw.RoundedBoxEx(4, 0, 24, w, h - 24, Color(3, 7, 16, 175), false, false, true, true)
    end
    frame.lblTitle:SetColor(Color(241, 241, 241))
    frame.btnClose:SetColor(Color(241, 241, 241))

    local entryList = vgui.Create("DPanelList", frame)
    entryList:Dock(FILL)
    entryList:DockMargin(0, 0, 0, 35)
    entryList:SetSpacing(5)
    entryList:EnableVerticalScrollbar(true)

    function entryList:ClearSelection(selectedPanel)
        for _, panel in ipairs(self:GetChildren()) do
            if panel ~= selectedPanel and panel.ClearSelection then
                panel:ClearSelection()
            end
        end
    end

    function OpenDetailedView(entryID, title, text, date, creator)
        local detailFrame = vgui.Create("DFrame")
        detailFrame:SetSize(600, 500)
        detailFrame:SetTitle("")
        detailFrame:Center()
        detailFrame:MakePopup()
        detailFrame:DoModal()
        detailFrame:SetDraggable(false)

        detailFrame.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 175))
            draw.RoundedBoxEx(6, 0, 0, w, 25, Color(3, 7, 16), true, true, false, false)
            draw.SimpleText("Entry Details", "TitleFont", 8, 6, Color(241, 241, 241), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local titleText = vgui.Create("DLabel", detailFrame)
        titleText:SetPos(280, 50)
        titleText:SetText(title)
        titleText:SetColor(Color(241, 241, 241))
        titleText:SetFont("HeadingFont")
        titleText:SizeToContents()

        local textScrollPanel = vgui.Create("DScrollPanel", detailFrame)
        textScrollPanel:SetPos(10, 110)
        textScrollPanel:SetSize(580, 300)

        local textText = vgui.Create("DTextEntry", textScrollPanel)
        textText:SetPos(10, 0)
        textText:SetSize(560, 300)
        textText:SetMultiline(true)
        textText:SetText(text)
        textText:SetFont("TextFont")
        textText:SetEditable(false)
        textText:SetTall(textText:GetTall() + 1)

        local dateText = vgui.Create("DLabel", detailFrame)
        dateText:SetPos(530, 480)
        dateText:SetText(date)
        dateText:SetColor(Color(241, 241, 241))
        dateText:SetFont("TitleFont")
        dateText:SizeToContents()

        local creatorText = vgui.Create("DLabel", detailFrame)
        creatorText:SetPos(5, 480)
        creatorText:SetText("Origin: " .. creator)
        creatorText:SetColor(Color(241, 241, 241))
        creatorText:SetFont("TitleFont")
        creatorText:SizeToContents()

        textText.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 0))
            self:DrawTextEntryText(Color(241, 241, 241), Color(30, 144, 255), Color(241, 241, 241))
        end

        local function CenterTitleText()
            local textWidth = titleText:GetWide()
            titleText:SetPos((detailFrame:GetWide() - textWidth) / 2, 50)
        end

        CenterTitleText()

        hook.Add("Think", "KeepFrameOnTop", function()
            if IsValid(detailFrame) then
                detailFrame:MakePopup()
            else
                hook.Remove("Think", "KeepFrameOnTop")
            end
        end)
    end

    net.Start("GetInteractedEntries")
    net.SendToServer()

    net.Receive("SendInteractedEntries", function()
        local entries = net.ReadTable()
        entryList:Clear()
        for _, entry in ipairs(entries) do
            local entryPanel = CreateEntryPanel(entry)
            entryList:AddItem(entryPanel)
        end
    end)

    frame.OnClose = function()
        if DataNAVButton then
            DataNAVButton.clicked = false
            DataNAVButton.action(false)
        end
    end
end

function CreateCustomMessageFrame(message, title, buttonText)
    local tempLabel = vgui.Create("DLabel")
    tempLabel:SetText(message)
    tempLabel:SizeToContents()

    local frameWidth = tempLabel:GetWide() + 50

    local messageFrame = Derma_Message(message, title, buttonText)

    messageFrame:SetSize(frameWidth, 100)
    messageFrame:SetTitle(title)
    messageFrame.lblTitle:SetColor(Color(255, 0, 0))
    messageFrame.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(3, 7, 16, 250))
    end

    tempLabel:Remove()
    return messageFrame
end

net.Receive("RegisterResult", function()
    local success = net.ReadBool()
    if success then
        CreateCustomMessageFrame("Registration successful. You can now log in.", "Success", "OK")
    else
        CreateCustomMessageFrame("Registration failed. Username may already be taken.", "Error", "OK")
    end
end)

net.Receive("DeleteEntryResult", function()
    local success = net.ReadBool()

    if not success then
        CreateCustomMessageFrame("You don't have permission to delete this entry.", "Error", "OK")
    end
end)

net.Receive("EditEntryResult", function()
    local success = net.ReadBool()

    if success then
        local selectedEntryID = nil

        for _, panel in ipairs(customEntryPanels) do
            if panel.isSelected then
                selectedEntryID = panel.entryID
                local title, text, creator = panel.title, panel.text, panel.creator
                EditEntryFrame(selectedEntryID, title, text, creator)
                break
            end
        end
    else
        CreateCustomMessageFrame("You don't have permission to edit this entry.", "Error", "OK")
    end
end)

net.Receive("OpenLoginUI", function()
    local terminalID = net.ReadInt(32)
    OpenLoginUI(terminalID)
end)

net.Receive("OpenTerminalUI", function()
    local terminalID = net.ReadInt(32)
    OpenTerminalUI(terminalID)
end)

net.Receive("OpenDatapadUI", function()
    local terminalID = net.ReadInt(32)
    OpenDatapadUI(terminalID)
end)