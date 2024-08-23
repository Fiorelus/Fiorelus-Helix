local PLUGIN = PLUGIN

local hudEnabled = true

local FACTION_SPARTAN = FACTION_SPARTAN

local hudTextures = {
    Spartan_HUD = {
        {
            path = "hud/h3_top_middle",
            width = 1,
            height = 0.3,
            yOffset = 0,
            color = Color(137, 200, 255, 80),
            rotation = 0,
        },
        {
            path = "hud/h3_bottom_middle",
            width = 1,
            height = 0.3,
            yOffset = 0.7,
            color = Color(137, 200, 255, 80),
            rotation = 0,
        },
    },
    ODST_HUD = {
        {
            path = "hud/odst_top_middle",
            width = 1,
            height = 0.3,
            yOffset = -0.01,
            color = Color(255, 239, 104, 40),
            rotation = 0,
        },
        {
            path = "hud/odst_bottom_middle",
            width = 1,
            height = 0.5,
            yOffset = 0.55,
            color = Color(255, 239, 104, 40),
            rotation = 0,
        },
    },
    UNSC_HUD = {
        {
            path = "hud/odst_shield_bottom",
            width = 1,
            height = 1,
            yOffset = -0.60,
            color = Color(255, 239, 104, 60),
            rotation = 0,
        },
        {
            path = "hud/h3_top_middle",
            width = 1,
            height = 0.3,
            yOffset = 0.775,
            color = Color(255, 239, 104, 75),
            rotation = 180,
        },
    },
}

local grenadeTexture = Material("hud/frag_icons")

local grenades = {
    {
        name = "Frag Grenade",
        u1 = 0, v1 = 0, u2 = 0.5, v2 = 1,
    },
    --[[
    {
        name = "Plasma Grenade",
        u1 = 0, v1 = 0, u2 = 0, v2 = 0,
    }
    ]]
}

local weaponMaterialConfig = {
    ["tfa_rebirth_br55"]     = { path = "vgui/weapon_icons/drchalo_br", width = 192, height = 192 },
    ["tfa_rebirth_m392"]     = { path = "vgui/weapon_icons/drchalo_dmr", width = 192, height = 192 },
    ["tfa_rebirth_m394"]     = { path = "vgui/weapon_icons/drchalo_dmr", width = 192, height = 192 },
    ["tfa_rebirth_m394b"]    = { path = "vgui/weapon_icons/drchalo_dmr", width = 192, height = 192 },
    ["tfa_rebirth_m41"]      = { path = "vgui/weapon_icons/drchalo_spnkr", width = 192, height = 192, scale = 1.25 },
    ["tfa_rebirth_m45e"]     = { path = "vgui/weapon_icons/drchalo_m45", width = 192, height = 192 },
    ["tfa_rebirth_m45s"]     = { path = "vgui/weapon_icons/drchalo_m45", width = 192, height = 192 },
    ["tfa_rebirth_m6c"]      = { path = "vgui/weapon_icons/drchalo_m6c", width = 192, height = 192, scale = 0.5, positionAdjustment = Vector(-50, 0, 0) },
    ["tfa_rebirth_m6cp"]     = { path = "vgui/weapon_icons/drchalo_m6c", width = 192, height = 192, scale = 0.5, positionAdjustment = Vector(-50, 0, 0) },
    ["tfa_rebirth_m6cs"]     = { path = "vgui/weapon_icons/drchalo_m6s", width = 192, height = 192, scale = 0.6, positionAdjustment = Vector(-40, 0, 0) },
    ["tfa_rebirth_m6g"]      = { path = "vgui/weapon_icons/drchalo_m6h", width = 192, height = 192, scale = 0.5, positionAdjustment = Vector(-50, 0, 0) },
    ["tfa_rebirth_m7d"]      = { path = "vgui/weapon_icons/drchalo_m7", width = 192, height = 192, scale = 0.75, positionAdjustment = Vector(-25, 0, 0) },
    ["tfa_rebirth_m7d2"]     = { path = "vgui/weapon_icons/drchalo_m7", width = 192, height = 192, scale = 0.75, positionAdjustment = Vector(-25, 0, 0) },
    ["tfa_rebirth_m7ds"]     = { path = "vgui/weapon_icons/drchalo_m7s", width = 192, height = 192 },
    ["tfa_rebirth_m90"]      = { path = "vgui/weapon_icons/drchalo_m45", width = 192, height = 192 },
    ["tfa_rebirth_m90c"]     = { path = "vgui/weapon_icons/drchalo_m45", width = 192, height = 192 },
    ["tfa_rebirth_ma37"]     = { path = "vgui/weapon_icons/drchalo_ma37", width = 192, height = 192 },
    ["tfa_rebirth_ma37g"]    = { path = "vgui/weapon_icons/drchalo_ma37", width = 192, height = 192 },
    ["tfa_rebirth_ma37m"]    = { path = "vgui/weapon_icons/drchalo_ma37", width = 192, height = 192 },
    ["tfa_rebirth_ma37s"]    = { path = "vgui/weapon_icons/drchalo_ma37", width = 192, height = 192 },
    ["tfa_rebirth_ma5d"]     = { path = "vgui/weapon_icons/drchalo_ma5d", width = 192, height = 192 },
    ["tfa_rebirth_ma5c"]     = { path = "vgui/weapon_icons/drchalo_ma5c", width = 192, height = 192 },
    ["tfa_rebirth_srs99s2am"]= { path = "vgui/weapon_icons/drchalo_srs99am", width = 192, height = 192, scale = 1.25 },
    ["tfa_rebirth_srs99s4am"]= { path = "vgui/weapon_icons/drchalo_srs99am", width = 192, height = 192, scale = 1.25 },
    ["tfa_rebirth_srs99c2s"] = { path = "vgui/weapon_icons/drchalo_srs99am", width = 192, height = 192, scale = 1.25 },
    ["tfa_rebirth_srs99c2b"] = { path = "vgui/weapon_icons/drchalo_srs99am", width = 192, height = 192, scale = 1.25 },
    ["tfa_rebirth_xbr55"]    = { path = "vgui/weapon_icons/drchalo_br", width = 192, height = 192 },
    ["tfa_rebirth_xbr55s"]   = { path = "vgui/weapon_icons/drchalo_br", width = 192, height = 192 },
    ["tfa_rebirth_xbr55c"]   = { path = "vgui/weapon_icons/drchalo_br", width = 192, height = 192 },
}

local factionConfigs = {
    [FACTION_SPARTAN] = {
        color = Color(137, 200, 255),
        grenadeX = 0.89,
        grenadeY = 0.086,
        grenadeSize = 40,
        spacing = 25,
        weaponX = 0.8,
        weaponY= 0.025
    },
    [FACTION_ODST] = {
        color = Color(255, 239, 104),
        grenadeX = 0.89,
        grenadeY = 0.86,
        grenadeSize = 40,
        spacing = 25,
        weaponX = 0.8,
        weaponY= 0.8
    },
    [FACTION_MARINE] = {
        color = Color(255, 239, 104),
        grenadeX = 0.905,
        grenadeY = 0.86,
        grenadeSize = 40,
        spacing = 25,
        weaponX = 0.815,
        weaponY= 0.8
    },
}

local function DrawTexturedRectUV(x, y, width, height, u1, v1, u2, v2, texture, color)
    surface.SetDrawColor(color)
    surface.SetMaterial(texture)
    surface.DrawTexturedRectUV(x, y, width, height, u1, v1, u2, v2)
end

local function DrawHUDTextures(hudName)
    if not hudEnabled then return end

    local textures = hudTextures[hudName]
    if not textures then return end

    local screenWidth, screenHeight = ScrW(), ScrH()

    for _, textureInfo in pairs(textures) do
        local textureWidth = screenWidth * textureInfo.width
        local textureHeight = screenHeight * textureInfo.height
        local textureX = (screenWidth - textureWidth) / 2
        local textureY = screenHeight * textureInfo.yOffset

        surface.SetDrawColor(textureInfo.color)
        surface.SetMaterial(Material(textureInfo.path))
        surface.DrawTexturedRectRotated(textureX + textureWidth / 2, textureY + textureHeight / 2, textureWidth, textureHeight, textureInfo.rotation)
    end
end

hook.Add("HUDPaint", "DrawHUDTextures", function()
    local client = LocalPlayer()
    if not client:IsValid() then return end

    local hudName = PLUGIN:getHUD(client)
    if hudName then
        DrawHUDTextures(hudName)
    end
end)

local function DrawHealthBar(x, y, width, height, healthPercentage, health, maxHealth, padding)
    if not hudEnabled then return end

    local barWidth = (width - padding * 2) * healthPercentage

    draw.RoundedBox(6, x, y, width, height, Color(145, 195, 225, 205))
    draw.RoundedBox(6, x + padding, y + padding, barWidth, height - padding * 2, Color(255, 0, 0, 235))

    local healthText = health .. " | " .. maxHealth
    surface.SetFont("BarFont")
    surface.SetTextColor(Color(255, 255, 255))
    local textWidth, textHeight = surface.GetTextSize(healthText)
    surface.SetTextPos(x + (width - textWidth) / 2, y + (height - textHeight) / 2)
    surface.DrawText(healthText)
end

local function DrawGrenadesHUD()
    if not hudEnabled then return end

    local client = LocalPlayer()
    local screenWidth, screenHeight = ScrW(), ScrH()
    local faction = client:Team()

    local config = factionConfigs[faction]

    local grenadeX = screenWidth * config.grenadeX
    local grenadeY = screenHeight * config.grenadeY
    local grenadeSize = config.grenadeSize
    local spacing = config.spacing

    for i, grenade in ipairs(grenades) do
        local x = grenadeX + (grenadeSize + spacing) * (i - 1)

        DrawTexturedRectUV(
                x,
                grenadeY,
                grenadeSize,
                grenadeSize,
                grenade.u1,
                grenade.v1,
                grenade.u2,
                grenade.v2,
                grenadeTexture,
                config.color
        )

        local ammoCount = client:GetAmmoCount(10)
        draw.SimpleText(
                "| " .. ammoCount,
                "WeaponFont",
                x + grenadeSize,
                grenadeY + grenadeSize / 2,
                config.color,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
        )
    end
end

hook.Add("HUDPaint", "DrawGrenadesHUD", function()
    local client = LocalPlayer()
    if not client:IsValid() then return end

    DrawGrenadesHUD()
end)

local bulletMaterials = {
    generic = Material("vgui/weapon_icons/bullet_generic"),
    rocket = Material("vgui/weapon_icons/bullet_rocket"),
    shell = Material("vgui/weapon_icons/bullet_shotgun")
}

local function getAmmoTypeMaterial(ammoType)
    if ammoType == 1 or ammoType == 3 or ammoType == 4 or ammoType == 5 then
        return bulletMaterials.generic
    elseif ammoType == 8 then
        return bulletMaterials.rocket
    elseif ammoType == 7 then
        return bulletMaterials.shell
    else
        return bulletMaterials.generic
    end
end

local function DrawWeaponIconAndAmmo()
    if not hudEnabled then return end

    local client = LocalPlayer()
    local faction = client:Team()

    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return end

    local weaponClass = weapon:GetClass()
    local wep_config = weaponMaterialConfig[weaponClass]

    if not wep_config then return end
    local config = factionConfigs[faction]

    local wep_material = Material(wep_config.path)
    if wep_material:IsError() then return end

    local iconX = ScrW() * config.weaponX
    local iconY = ScrH() * config.weaponY
    local iconWidth = wep_config.width
    local iconHeight = wep_config.height

    local centerX = iconX + iconWidth / 2
    local centerY = iconY + iconHeight / 2

    local scaleFactor = wep_config.scale or 1
    local newIconWidth = iconWidth * scaleFactor
    local newIconHeight = iconHeight * scaleFactor

    local positionAdjustment = wep_config.positionAdjustment or Vector(0, 0, 0)
    local newX = centerX - newIconWidth / 2 + positionAdjustment.x
    local newY = centerY - newIconHeight / 2 + positionAdjustment.y

    surface.SetDrawColor(config.color)
    surface.SetMaterial(wep_material)
    surface.DrawTexturedRect(newX, newY, newIconWidth, newIconHeight)

    local ammoCount = weapon:Clip1()
    local reserveAmmo = client:GetAmmoCount(weapon:GetPrimaryAmmoType())
    local maxClip = weapon:GetMaxClip1()
    local ammoType = weapon:GetPrimaryAmmoType()

    local bulletWidth = 8
    local bulletHeight = 16
    local bulletRotation = 0
    local isRotated = false

    local ammoX = iconX
    local ammoY = iconY + (iconHeight / 1.4)
    local bulletsPerLine = 20
    local maxLines = 3

    if weaponClass == "tfa_rebirth_m41" then
        bulletWidth = 20
        bulletHeight = 60
        bulletRotation = 270
        isRotated = true
    elseif weaponClass == "tfa_rebirth_m45e" or weaponClass == "tfa_rebirth_m45s" or weaponClass == "tfa_rebirth_m90" or weaponClass == "tfa_rebirth_m90c" then
        bulletWidth = 10
        bulletHeight = 20
        ammoY = iconY + (iconHeight / 1.75) + (bulletHeight / 2)
    elseif weaponClass == "tfa_rebirth_srs99s2am" or weaponClass == "tfa_rebirth_srs99s4am" or weaponClass == "tfa_rebirth_srs99c2s" or weaponClass == "tfa_rebirth_srs99c2b" then
        bulletWidth = 8
        bulletHeight = 20
        ammoY = iconY + (iconHeight / 1.75) + (bulletHeight / 2)
    end

    local bulletMaterial = getAmmoTypeMaterial(ammoType)

    for i = 1, maxClip do
        local line = math.floor((i - 1) / bulletsPerLine)
        local col = (i - 1) % bulletsPerLine

        if line < maxLines then
            local bulletX
            if isRotated then
                bulletX = ammoX + (bulletWidth + 48) * col
            else
                bulletX = ammoX + (bulletWidth + 2) * col
            end

            local bulletY = ammoY + (bulletHeight + 2) * line

            local color = i <= ammoCount and config.color or Color(50, 50, 50, 255)

            surface.SetDrawColor(color)
            surface.SetMaterial(bulletMaterial)

            if isRotated then
                surface.DrawTexturedRectRotated(bulletX + 20, bulletY + 16, bulletWidth, bulletHeight, bulletRotation)
            else
                surface.DrawTexturedRect(bulletX, bulletY + 8, bulletWidth, bulletHeight)
            end
        end
    end

    local textX = ammoX - 60
    local textY = iconY + (iconHeight / 2.25)
    draw.SimpleText(reserveAmmo .. " |", "WeaponFont", textX, textY, config.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

hook.Add("HUDPaint", "DrawWeaponIconAndAmmo", function()
    local client = LocalPlayer()
    if not client:IsValid() then return end

    DrawWeaponIconAndAmmo()
end)

hook.Add("HUDPaint", "DrawHealthBar", function()
    local client = LocalPlayer()
    if not client:IsValid() then return end

    local width = ScrW()
    local height = ScrH()
    local health = LocalPlayer():Health()
    local maxHealth = LocalPlayer():GetMaxHealth()

    local healthPercentage = health / maxHealth

    local barX = width * 0.39
    local barY = height * 0.095
    local barWidth = width * 0.22
    local barHeight = height * 0.02

    local padding = 2.5

    DrawHealthBar(barX, barY, barWidth, barHeight, healthPercentage, health, maxHealth, padding)
end)

function PLUGIN:ShouldHideBars()
    return true
end

function ToggleHUD()
    hudEnabled = not hudEnabled
end