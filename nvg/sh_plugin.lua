local PLUGIN = PLUGIN

PLUGIN.name = "Reclaimer NVG"
PLUGIN.author = "Fiorelus"
PLUGIN.desc = "Night vision system for Reclaimer Networks"

ix.util.Include("cl_plugin.lua")

sound.Add({
    name = "NightVision.On",
    channel = CHAN_STATIC,
    volume = 1.5,
    level = 75,
    pitch = 100,
    sound = "nvg/night_vision_on.wav"
})

sound.Add({
    name = "NightVision.Off",
    channel = CHAN_STATIC,
    volume = 1.5,
    level = 75,
    pitch = 100,
    sound = "nvg/night_vision_off.wav"
})