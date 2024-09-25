ITEM.name = "Squad Identifier Device"
ITEM.description = "A device used to manage squads."
ITEM.model = "models/props_lab/reciever01a.mdl"
ITEM.category = "Devices"
ITEM.width = 1
ITEM.height = 1

ITEM.functions.Use = {
    name = "Use",
    icon = "icon16/application.png",
    OnRun = function(item)
        if CLIENT then
            net.Start("ixOpenSquadMenu")
            net.SendToServer()
        else
            net.Start("ixOpenSquadMenu")
            net.Send(item.player)
        end

        return false
    end,

    OnCanRun = function(item)
        return not IsValid(item.entity)
    end
}

ITEM:Register()