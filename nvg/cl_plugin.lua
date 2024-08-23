local isNightVisionActive = false
local projectedTexture = nil

local function NightVisionThink()
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end
    local ply = LocalPlayer()
    local newPos = ply:EyePos()

    if IsValid(projectedTexture) then
        projectedTexture:SetPos(newPos)
        projectedTexture:SetAngles(ply:GetAimVector():Angle())
        projectedTexture:SetNearZ(12)
        projectedTexture:SetFarZ(2000)
        projectedTexture:SetFOV(140)
        projectedTexture:SetVerticalFOV(100)
        projectedTexture:SetTexture("effects/flashlight/soft")
        projectedTexture:SetColor(Color(0, 40, 0, 255))
        projectedTexture:SetBrightness(1)
        projectedTexture:SetEnableShadows(false)
        projectedTexture:Update()
    else
        projectedTexture = ProjectedTexture()
        projectedTexture:SetPos(newPos)
        projectedTexture:SetAngles(ply:GetAimVector():Angle())
        projectedTexture:SetNearZ(12)
        projectedTexture:SetFarZ(2000)
        projectedTexture:SetFOV(140)
        projectedTexture:SetVerticalFOV(100)
        projectedTexture:SetBrightness(1)
        projectedTexture:SetTexture("effects/flashlight/soft")
        projectedTexture:SetColor(Color(0, 40, 0, 255))
        projectedTexture:SetEnableShadows(false)
        projectedTexture:Update()
    end
end

local function NightVisionEffect()
    local colorMod = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.15,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0.1,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 0.1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }
    DrawColorModify(colorMod)

    DrawBloom(0.65, 3, 9, 9, 3, 2, 0, 1, 0)
end

function ToggleNightVision()
    isNightVisionActive = not isNightVisionActive
    if isNightVisionActive then
        hook.Add("Think", "NightVisionThink", NightVisionThink)
        hook.Add("RenderScreenspaceEffects", "NightVisionEffect", NightVisionEffect)
        LocalPlayer():EmitSound("NightVision.On")
    else
        hook.Remove("Think", "NightVisionThink")
        hook.Remove("RenderScreenspaceEffects", "NightVisionEffect")
        LocalPlayer():EmitSound("NightVision.Off")

        if IsValid(projectedTexture) then
            projectedTexture:Remove()
            projectedTexture = nil
        end

        DrawColorModify({
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        })

        DrawBloom(0, 0, 0, 0, 0, 0, 0, 0, 0)
    end
end