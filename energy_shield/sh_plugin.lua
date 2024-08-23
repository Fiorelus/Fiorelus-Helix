local PLUGIN = PLUGIN

PLUGIN.name = "Reclaimer Shields"
PLUGIN.author = "Fiorelus"
PLUGIN.desc = "Fixed shields from Stan for Reclaimer Networks"
-- https://github.com/Stanstar22/Nutscript-Plugins-Stan/blob/master/plugins/halo_shields/sh_plugin.lua

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

HaloShields = HaloShields or {}

HaloShields.RechargeTime = 0.25
HaloShields.RechargeAmount = 2
HaloShields.Whitelist = {
	[FACTION_SPARTAN] = {true, 200},
}

function PLUGIN:getWhiteList(client)
	return HaloShields.Whitelist[client:Team()]
end