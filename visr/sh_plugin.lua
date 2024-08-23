local PLUGIN = PLUGIN

PLUGIN.name = "Reclaimer VISR"
PLUGIN.author = "Fiorelus"
PLUGIN.desc = "ODST visr system for Reclaimer Networks"

ix.util.Include("cl_plugin.lua")

HaloVISR = HaloVISR or {}

HaloVISR.HueAlly = Color(0, 215, 0, 80)
HaloVISR.HueNeutral = Color(0, 155, 155, 80)
HaloVISR.HueEnemy = Color(155, 0, 0, 80)
HaloVISR.HueCorpse = Color(165, 165, 100, 50)

HaloVISR.Friendly = {
    "npc_iv04_hr_human_civilian",
    "npc_iv04_hr_human_pilot",
    "npc_iv04_hr_human_trooper",
    "npc_iv04_hr_human_trooper_female",
    "npc_iv04_hr_human_marine",
    "npc_iv04_hr_human_militia",
    "npc_iv04_hr_human_odst",
    "npc_iv04_hr_human_odst_female",
    "npc_iv04_hr_human_spartan",
    "npc_iv04_hr_human_spartan_female"
}

HaloVISR.Enemy = {
    "npc_optre_urf_heavy",
    "npc_optre_urf_co",
    "npc_optre_urf_enlisted",
    "npc_optre_urf_medic",
    "npc_optre_urf_tanker",
    "npc_optre_urf_marksman",
    "npc_optre_urf_nco",
    "npc_optre_urf_radioman",
    "npc_optre_urf_sharpshooter",
    "npc_optre_urf_support",
    "npc_iv04_hr_brute_captain",
    "npc_iv04_hr_brute_chieftain",
    "npc_iv04_hr_brute_minor",
    "npc_iv04_hr_drone_captain",
    "npc_iv04_hr_drone_major",
    "npc_iv04_hr_drone_minor",
    "npc_iv04_hr_drone_ultra",
    "npc_iv04_hr_elite_field_marshall",
    "npc_iv04_hr_elite_general",
    "npc_iv04_hr_elite_major",
    "npc_iv04_hr_elite_minor",
    "npc_iv04_hr_elite_ranger",
    "npc_iv04_hr_elite_specops",
    "npc_iv04_hr_elite_ultra",
    "npc_iv04_hr_elite_zealot",
    "npc_iv04_hr_engineer",
    "npc_iv04_hr_grunt_heavy",
    "npc_iv04_hr_grunt_major",
    "npc_iv04_hr_grunt_minor",
    "npc_iv04_hr_grunt_specops",
    "npc_iv04_hr_grunt_ultra",
    "npc_iv04_hr_guta",
    "npc_iv04_hr_hunter",
    "npc_iv04_hr_jackal_major",
    "npc_iv04_hr_jackal_minor",
    "npc_iv04_hr_jackal_sniper",
    "npc_iv04_hr_skirmisher_champion",
    "npc_iv04_hr_skirmisher_commando",
    "npc_iv04_hr_skirmisher_major",
    "npc_iv04_hr_skirmisher_minor",
    "npc_iv04_hr_skirmisher_murmillo",
    "npc_vj_flood_carrier",
    "npc_vj_flood_combat",
    "npc_vj_flood_combat_brute",
    "npc_vj_flood_combat_elite",
    "sent_vj_flood_randcombat",
    "npc_vj_flood_egg",
    "npc_vj_flood_hivemind",
    "npc_vj_flood_infection",
    "sent_vj_flood_randinfection",
    "npc_vj_flood_mortar",
    "npc_vj_flood_ranged",
    "sent_vj_flood_randflood",
    "sent_vj_flood_squad_a",
    "sent_vj_flood_squad_b",
    "sent_vj_flood_squad_c",
    "npc_vj_flood_stalker",
    "npc_vj_flood_tank",
    "sent_vj_flood_director",
    "sent_vj_flood_randpureflood"
}

HaloVISR.Vehicle = {
    "npc_iv04_hr_turret_m95",
    "npc_iv04_hr_turret_scythe",
    "npc_iv04_hr_turret_mg",
    "npc_iv04_hr_droppod",
    "npc_iv04_hr_pelican",
    "npc_iv04_hr_pelican_oni",
    "npc_iv04_hr_phantom",
    "npc_iv04_hr_scarab",
    "npc_iv04_hr_spirit"
}

sound.Add({
    name = "VISR.On",
    channel = CHAN_STATIC,
    volume = 1.5,
    level = 75,
    pitch = 100,
    sound = "visr/visr_on.mp3"
})

sound.Add({
    name = "VISR.Off",
    channel = CHAN_STATIC,
    volume = 1.5,
    level = 75,
    pitch = 100,
    sound = "visr/visr_off.mp3"
})