ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Terminal"
ENT.Author = "Fiorelus"
ENT.Category = "Reclaimer Data"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Skin")
    self:NetworkVar("Int", 1, "TerminalID")
    self:NetworkVar("String", 0, "TerminalName")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/valk/h3/unsc/props/office/office_monitor.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetSkin(0)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
        end
    end
end

function ENT:Use(activator, caller)
    if IsValid(caller) and caller:IsPlayer() and self:GetClass() == "ix_terminal" and not self.IsUsing then
        self.IsUsing = true
        local terminalID = self:GetTerminalID()
        net.Start("OpenLoginUI")
        net.WriteInt(terminalID, 32)
        net.Send(caller)
        timer.Simple(0.5, function()
            self.IsUsing = false
        end)
    end
end

properties.Add("terminal_id", {
    MenuLabel = "Set ID",
    Order = 5000,
    MenuIcon = "icon16/add.png",

    Filter = function(self, ent, ply)
        if not IsValid(ent) then return false end
        if not ply:IsAdmin() then return false end
        if ent:GetClass() ~= "ix_terminal" then return false end
        return true
    end,

    Action = function(self, ent)
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Set Terminal ID")
        frame:SetSize(300, 130)
        frame:Center()
        frame:MakePopup()

        local idEntry = vgui.Create("DTextEntry", frame)
        idEntry:SetPos(10, 30)
        idEntry:SetSize(280, 20)
        idEntry:SetText(ent:GetTerminalID())
        idEntry:SetNumeric(true)
        idEntry:SetUpdateOnType(true)

        local textEntry = vgui.Create("DTextEntry", frame)
        textEntry:SetPos(10, 60)
        textEntry:SetSize(280, 20)
        textEntry:SetText("")
        textEntry:SetUpdateOnType(true)

        local button = vgui.Create("DButton", frame)
        button:SetPos(10, 90)
        button:SetSize(280, 30)
        button:SetText("Set Terminal ID")

        button.DoClick = function()
            local terminalID = tonumber(idEntry:GetValue())
            local terminalName = textEntry:GetValue()
            if terminalID then
                net.Start("SetTerminalID")
                net.WriteEntity(ent)
                net.WriteInt(terminalID, 32)
                net.WriteString(terminalName)
                net.SendToServer()
                frame:Close()
            else
                Derma_Message("Please enter a valid number", "Error", "OK")
            end
        end
    end,

    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        local terminalID = net.ReadInt(32)
        local terminalName = net.ReadString()

        if IsValid(ent) and ent:GetClass() == "ix_terminal" then
            ent:SetTerminalID(terminalID)
            ent:SetTerminalName(terminalName)

            local query = string.format("UPDATE ix_terminals SET terminal_id = %d, terminal_name = '%s' WHERE id = %d",
                    terminalID, terminalName)

            sql.Query(query)
        end
    end
})