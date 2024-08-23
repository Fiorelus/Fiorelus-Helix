local PLUGIN = PLUGIN

PLUGIN.name = "Reclaimer Menu"
PLUGIN.author = "Fiorelus"
PLUGIN.desc = "Radial menu which handles all custom plugins for Reclaimer Networks"

ix.util.Include("cl_plugin.lua")
ix.util.Include("nvg/sh_plugin.lua")
ix.util.Include("visr/sh_plugin.lua")
ix.util.Include("hud/sh_plugin.lua")
ix.util.Include("terminal/sh_plugin.lua")
ix.util.Include("energy_shield/sh_plugin.lua")
ix.util.Include("energy_shield/sv_plugin.lua")

surface.CreateFont("TitleFont", {
    font = "Coolvetica",
    size = 14,
    weight = 500,
})

surface.CreateFont("TextFont", {
    font = "Coolvetica",
    size = 14,
    weight = 500,
})

surface.CreateFont("HeadingFont", {
    font = "Coolvetica",
    size = 24,
    weight = 700,
})

surface.CreateFont("Heading2Font", {
    font = "Coolvetica",
    size = 18,
    weight = 700,
})