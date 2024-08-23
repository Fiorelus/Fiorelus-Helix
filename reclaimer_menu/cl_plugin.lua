local RadialMenuButtons = {}
local registeredButtons = {}
local currentFactionWhitelist = nil
local isOpen = false
local isClicking = false

function RegisterRadialMenuButton(icon, text, subtext, factionWhitelist, action)
    if not icon or not text or not action then
        return
    end

    table.insert(registeredButtons, {icon = icon, text = text, subtext = subtext, factionWhitelist = factionWhitelist, action = action, clicked = false})
end

local function UpdateRadialMenuButtons()
    RadialMenuButtons = {}
    local localPlayerFaction = LocalPlayer():Team()
    for _, button in ipairs(registeredButtons) do
        if not button.factionWhitelist or button.factionWhitelist[localPlayerFaction] then
            table.insert(RadialMenuButtons, button)
        end
    end
end

hook.Add("OnPlayerChangedTeam", "UpdateFactionWhitelist", function(ply, oldTeam, newTeam)
    if ply == LocalPlayer() then
        currentFactionWhitelist = HaloFaction.Whitelist[newTeam]
        UpdateRadialMenuButtons()
    end
end)

local function CalculateButtonPosition(centerX, centerY, radius, angle)
    local buttonX = centerX + math.cos(math.rad(angle)) * radius
    local buttonY = centerY + math.sin(math.rad(angle)) * radius
    return buttonX, buttonY
end

local function DrawCircle(x, y, radius, seg)
    local cir = {}
    table.insert(cir, {x = x, y = y})
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius})
    end
    local a = math.rad(0)
    table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius})
    surface.DrawPoly(cir)
end

local function DrawRadialMenu()
    if not isOpen then return end

    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local radius = 300
    local buttonRadius = 60
    local numButtons = #RadialMenuButtons
    local angleIncrement = 360 / numButtons

    surface.SetDrawColor(3, 7, 16, 175)
    DrawCircle(centerX, centerY, radius, 100)

    local mouseX, mouseY = gui.MousePos()

    for i, button in ipairs(RadialMenuButtons) do
        local angle = i * angleIncrement
        local buttonX, buttonY = CalculateButtonPosition(centerX, centerY, radius - buttonRadius, angle)

        surface.SetDrawColor(241, 241, 241)

        local distance = math.sqrt((mouseX - buttonX)^2 + (mouseY - buttonY)^2)
        local isHovering = distance <= buttonRadius

        if button.clicked then
            surface.SetDrawColor(60, 160, 255, 215)
        elseif isHovering then
            surface.SetDrawColor(125, 195, 255, 215)
        end

        surface.SetMaterial(button.icon)
        surface.DrawTexturedRect(buttonX - 32, buttonY - 32, 32, 32)

        if isHovering then
            draw.SimpleText(button.text, "Heading2Font", centerX, centerY - 50, Color(241, 241, 241), TEXT_ALIGN_CENTER)
            draw.SimpleText(button.subtext, "TextFont", centerX, centerY - 25, Color(241, 241, 241), TEXT_ALIGN_CENTER)
        end

        if isHovering and input.IsMouseDown(MOUSE_LEFT) and not isClicking then
            button.clicked = not button.clicked
            if button.action then
                button.action(button.clicked)
            end
            isOpen = false
            hook.Remove("HUDPaint", "DrawRadialMenu")
            gui.EnableScreenClicker(false)
            isClicking = true
        elseif not input.IsMouseDown(MOUSE_LEFT) then
            isClicking = false
        end
    end
end

local function HandleRadialMenu()
    hook.Add("Think", "OpenRadialMenu", function()
        if input.IsKeyDown(KEY_V) and not isOpen then
            isOpen = true
            UpdateRadialMenuButtons()
            hook.Add("HUDPaint", "DrawRadialMenu", DrawRadialMenu)
            gui.EnableScreenClicker(true)
        elseif not input.IsKeyDown(KEY_V) and isOpen then
            isOpen = false
            hook.Remove("HUDPaint", "DrawRadialMenu")
            gui.EnableScreenClicker(false)
        end
    end)
end

HandleRadialMenu()

local NVGWhitelist = {
    [FACTION_SPARTAN] = true,
    [FACTION_ODST] = true,
}

local VISRWhitelist = {
    [FACTION_ODST] = true,
}

local HUDWhitelist = {
    [FACTION_ODST] = true,
    [FACTION_SPARTAN] = true,
    [FACTION_MARINE] = true,
}

local DataNAVWhitelist = {
    [FACTION_ODST] = true,
    [FACTION_SPARTAN] = true,
    [FACTION_MARINE] = true,
}

RegisterRadialMenuButton(Material("VISR.png"), "VISR", "Toggles VISR", VISRWhitelist, function()
    ToggleVISR()
end)

RegisterRadialMenuButton(Material("NVG.png"), "NVG", "Toggles Night Vision", NVGWhitelist, function()
    ToggleNightVision()
end)

RegisterRadialMenuButton(Material("HUD.png"), "HUD", "Toggles HUD", HUDWhitelist, function()
    ToggleHUD()
    ShieldHUD()
end)

DataNAVButton = {
    icon = Material("DataNAV.png"),
    text = "DataNAV",
    subtext = "Displays DataNAV Entries",
    factionWhitelist = DataNAVWhitelist,
    action = function(clicked)
        if clicked then
            OpenDatanavUI()
        end
    end,
    clicked = false
}
table.insert(registeredButtons, DataNAVButton)

UpdateRadialMenuButtons()