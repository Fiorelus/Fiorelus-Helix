local VISRActive = false
local FACTION_ODST = FACTION_ODST

local function IsInList(ent, list)
    local class = ent:GetClass()
    for _, v in ipairs(list) do
        if class == v then
            return true
        end
    end
    return false
end

local function AddVISRHalo()
    if not VISRActive then return end

    local npcs = ents.GetAll()
    local allies = {}
    local enemies = {}
    local corpses = {}
    local neutrals = {}

    for _, ent in ipairs(npcs) do
        if ent:IsNPC() or ent:IsNextBot() then
            if IsInList(ent, HaloVISR.Friendly) then
                table.insert(allies, ent)
            elseif IsInList(ent, HaloVISR.Enemy) then
                table.insert(enemies, ent)
            elseif not IsInList(ent, HaloVISR.Vehicle) then
                table.insert(neutrals, ent)
            end
        elseif ent:IsRagdoll() then
            table.insert(corpses, ent)
        end
    end

    if #allies > 0 then
        halo.Add(allies, HaloVISR.HueAlly, 2, 2, 1, true, false)
    end
    if #enemies > 0 then
        halo.Add(enemies, HaloVISR.HueEnemy, 2, 2, 1, true, false)
    end
    if #corpses > 0 then
        halo.Add(corpses, HaloVISR.HueCorpse, 2, 2, 1, true, false)
    end
    if #neutrals > 0 then
        halo.Add(neutrals, HaloVISR.HueNeutral, 2, 2, 1, true, false)
    end
end

function ToggleVISR()
    local ply = LocalPlayer()

    if ply:Team() ~= FACTION_ODST then
        return
    end

    VISRActive = not VISRActive
    if VISRActive then
        hook.Add("PreDrawHalos", "AddVISRHalo", AddVISRHalo)
        LocalPlayer():EmitSound("VISR.On")
    else
        hook.Remove("PreDrawHalos", "AddVISRHalo")
        LocalPlayer():EmitSound("VISR.Off")
    end
end

concommand.Add("visr_toggle", function(ply, cmd, args)
    ToggleVISR()
end)