local PLUGIN = PLUGIN

PLUGIN.name = "Reclaimer HUD"
PLUGIN.author = "Fiorelus"
PLUGIN.desc = "Various HUD systems with whitelist capability for Reclaimer Networks"

ix.util.Include("cl_plugin.lua")

HaloHUD = HaloHUD or {}
HaloHUD.Whitelist = {
    [FACTION_SPARTAN] = "Spartan_HUD",
    [FACTION_ODST] = "ODST_HUD",
    [FACTION_MARINE] = "UNSC_HUD",
}

HaloHUD.Default = "MinimalHUD"

function PLUGIN:getHUD(client)
    return HaloHUD.Whitelist[client:Team()]
end

surface.CreateFont("BarFont", {
    font = "Coolvetica",
    size = ScrH() * 0.02,
    weight = 500,
})

surface.CreateFont("WeaponFont", {
    font = "Coolvetica",
    size = 20,
    weight = 700,
})
