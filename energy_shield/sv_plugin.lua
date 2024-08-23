local PLUGIN = PLUGIN

local function StartRecharge(ply)
    timer.Create("halo_shield:Recharge" .. ply:SteamID(), HaloShields.RechargeTime, 0, function()
        if ply:IsValid() then
            local plyteam = ply:Team()
            local chargeAmount = ply:GetNWInt("Shield_HP")
            local maxshield = nil
            maxshield = HaloShields.Whitelist[plyteam][2]

            if maxshield == nil then return end

            ply:SetNWInt("Shield_HP", math.Clamp(chargeAmount + HaloShields.RechargeAmount, 0, maxshield))
            timer.Remove("halo_shield:NoShieldEffect" .. ply:SteamID())

            local effectdata = EffectData()
            effectdata:SetOrigin(ply:GetPos())
            effectdata:SetEntity(ply)
            util.Effect("halo_shield_regenring", effectdata)

            ply.ShieldShldExplode = true

            if chargeAmount >= HaloShields.Whitelist[plyteam][2] then
                timer.Remove("halo_shield:Recharge" .. ply:SteamID())
            end
        end
    end)
end

function PLUGIN:PlayerSpawn(ply)
    local whitelist = self:getWhiteList(ply)
    if whitelist and whitelist[1] then
        local maxShield = whitelist[2]
        ply:SetNWInt("Shield_HP", maxShield)
        ply:SetBloodColor(-1)
        ply.ShieldShldExplode = true
    else
        ply:SetNWInt("Shield_HP", 0)
        ply:SetBloodColor(0)
        ply.ShieldShldExplode = false
    end
end

function PLUGIN:PlayerDeath(ply, inf, att)
    timer.Remove("halo_shield:RechargeDelay" .. ply:SteamID())
    timer.Remove("halo_shield:Recharge" .. ply:SteamID())
    timer.Remove("halo_shield:NoShieldEffect" .. ply:SteamID())
end

function PLUGIN:PlayerHurt( ply, att, healthRem, damTaken )
    if (self:getWhiteList( ply )) then
        local plyShield = ply:GetNWInt( "Shield_HP" )
        if plyShield > 0 then
            ply:SetHealth( healthRem + damTaken )
            ply:SetNWInt("Shield_HP", math.Clamp(math.Round(plyShield - damTaken), 0, plyShield))
            ply:SetBloodColor(-1)
            ply:EmitSound("hit" .. math.random(1,7) .. ".ogg", 80, 100)
        else
            ply:SetBloodColor(0)
            timer.Create("halo_shield:NoShieldEffect"..ply:SteamID(), 0.25, 0, function()
                if ply:IsValid() then
                    local ShoulderRPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"))
                    local ShoulderLPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Clavicle"))
                    local HipPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis")) - Vector(0, 0, 20)
                    local HeelRPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Foot"))
                    local HeelLPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Foot"))

                    local effectdata = EffectData()
                    effectdata:SetEntity(ply)
                    effectdata:SetOrigin(ShoulderRPos)
                    util.Effect("halo_shield_depleted", effectdata)
                    effectdata:SetOrigin(ShoulderLPos)
                    util.Effect("halo_shield_depleted", effectdata)
                    effectdata:SetOrigin(HipPos)
                    util.Effect("halo_shield_depleted", effectdata)
                    effectdata:SetOrigin(HeelRPos)
                    util.Effect("halo_shield_depleted", effectdata)
                    effectdata:SetOrigin(HeelLPos)
                    util.Effect("halo_shield_depleted", effectdata)
                end
            end)

            if ply.ShieldShldExplode == true then
                ply:EmitSound("pop" .. math.random(1,7) .. ".ogg", 80 ,100)
                local effectdata = EffectData()
                effectdata:SetEntity(ply)
                effectdata:SetOrigin(ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Pelvis")))
                util.Effect("halo_shield_explode", effectdata)
                ply.ShieldShldExplode = false
            end
        end

        if timer.Exists("halo_shield:RechargeDelay"..ply:SteamID()) then
            timer.Remove("halo_shield:RechargeDelay"..ply:SteamID())
        end

        if timer.Exists("halo_shield:Recharge"..ply:SteamID()) then
            timer.Remove("halo_shield:Recharge"..ply:SteamID())
        end

        timer.Create("halo_shield:RechargeDelay"..ply:SteamID(), 7, 1, function() if ply:IsValid() then StartRecharge( ply ) ply:EmitSound(Sound("ambient/energy/whiteflash.wav"),80,115) end end)
    end
end

function PLUGIN:EntityTakeDamage( target, dmginfo )
    if target:IsPlayer() then
        local ply = target
        if (self:getWhiteList( ply )) then
            local shields = ply:GetNWInt( "Shield_HP" )
            if shields > 0 then
                local effectdata = EffectData()
                effectdata:SetOrigin(dmginfo:GetDamagePosition())
                effectdata:SetEntity(ply)
                util.Effect("halo_shield_impact", effectdata)
            end
        end
    end
end