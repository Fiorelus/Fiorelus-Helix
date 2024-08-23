local shieldDisplayEnabled = true

surface.CreateFont("SimpleHUDFont", {
    font = "Roboto",
    size = ScrH() * 0.015,
    weight = 700,
    antialias = true,
})

local function DrawCombinedHUD()
    if not hudEnabled and not shieldDisplayEnabled then return end

    local client = LocalPlayer()
    if not IsValid(client) then return end

    local faction = client:Team()

    local armor = client:Armor()
    local maxArmor = client:GetMaxArmor()
    local armorPercentage = armor / maxArmor
    local armorText = string.format("%d | %d", armor, maxArmor)

    local shield = client:GetNWInt("Shield_HP")
    local maxShields = HaloShields.Whitelist[faction] and HaloShields.Whitelist[faction][2] or 0
    local shieldPercentage = shield / maxShields
    local shieldText = string.format("%d | %d", shield, maxShields)

    local width = ScrW()
    local height = ScrH()

    local armorBoxWidth = width * 0.215
    local armorBoxHeight = height * 0.02
    local armorBoxX = width * 0.3925
    local armorBoxY = height * 0.1175

    local shieldBoxWidth = width * 0.215
    local shieldBoxHeight = height * 0.02
    local shieldBoxX = width * 0.3925
    local shieldBoxY = height * 0.1175

    if faction ~= FACTION_SPARTAN then
        draw.RoundedBox(6, armorBoxX, armorBoxY, armorBoxWidth, armorBoxHeight, Color(145, 195, 225, 205))
        local armorPadding = 2
        local armorWidth = (armorBoxWidth - armorPadding * 2) * armorPercentage
        draw.RoundedBox(6, armorBoxX + armorPadding, armorBoxY + armorPadding, armorWidth, armorBoxHeight - armorPadding * 2, Color(255, 255, 255, 175))
        draw.SimpleText(armorText, "BarFont", armorBoxX + armorBoxWidth / 2, armorBoxY + armorBoxHeight / 2 - armorPadding / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if shieldDisplayEnabled and faction == FACTION_SPARTAN then
        draw.RoundedBox(6, shieldBoxX, shieldBoxY, shieldBoxWidth, shieldBoxHeight, Color(145, 195, 225, 205))
        local shieldPadding = 2
        local shieldWidth = (shieldBoxWidth - shieldPadding * 2) * shieldPercentage
        draw.RoundedBox(6, shieldBoxX + shieldPadding, shieldBoxY + shieldPadding, shieldWidth, shieldBoxHeight - shieldPadding * 2, Color(255, 255, 255, 175))
        draw.SimpleText(shieldText, "BarFont", shieldBoxX + shieldBoxWidth / 2, shieldBoxY + shieldBoxHeight / 2 - shieldPadding / 2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

hook.Add("HUDPaint", "DrawCombinedHUD", function()
    DrawCombinedHUD()
end)

function ShieldHUD()
    shieldDisplayEnabled = not shieldDisplayEnabled
    if shieldDisplayEnabled then
        hook.Add("HUDPaint", "DrawShieldHUD", DrawShieldHUD)
    else
        hook.Remove("HUDPaint", "DrawShieldHUD")
    end
end