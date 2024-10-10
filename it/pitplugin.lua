PLUGIN.name = "Personal /it"
PLUGIN.author = "cam & Val"
PLUGIN.desc = "Allows for use of personal /its, directed towards players."

ix.chat.Register("pit", {
	format = "%s",
	color = Color(180, 0, 0),
	deadCanChat = true,

	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(self.color, string.format(self.format, "** "..text))
	end
})

ix.command.Add("Pit", {
	description = "Send a personal action to a player that only you & the target can see.",
	adminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.text
	},
	OnRun = function(self, client, target, message)
		ix.chat.Send(client, "pit", message, false, {client, target}, {target = target})
	end
})

ix.chat.Register("think", {
	prefix = {"/mind", "/think"},
	format = "*\"%s\"*",
	color = Color(150, 150, 150),
	CanHear = ix.config.Get("chatRange", 280),
	deadCanChat = true,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		local formattedText = string.format(self.format, ix.chat.Format(text))
		if LocalPlayer() == speaker or data.target then
			chat.AddText(self.color, "** " .. formattedText)
		else
			chat.AddText(self.color, "** " .. speaker:GetName() .. " thinks " .. formattedText)
		end
	end,

	CanHear = function(self, speaker, listener)
		ix.config.Get("chatRange", 280)
		if speaker == listener then return true end

		if listener:GetEyeTrace().Entity == speaker then
			return true
		end

		return false
	end
})

ix.command.Add("Think", {
	description = "Bring a thought to life, visible only to you.",
	arguments = ix.type.text,
	OnRun = function(self, client, message)
		ix.chat.Send(client, "think", message)
	end
})

ix.command.Add("PitM", {
	prefix = {"/PitM", "/Telepathy"},
	description = "Plant a thought in someone's mind.",
	adminOnly = true,
	arguments = {
		ix.type.player,
		ix.type.text
	},
	OnRun = function(self, client, target, message)
		ix.chat.Send(client, "think", message, false, {client, target}, {target = target})
	end,
	OnCanRun = function(self, client)
		return client:IsAdmin()
	end
})