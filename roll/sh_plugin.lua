PLUGIN.name = "Improved Roll"
PLUGIN.author = "Fiorelus"
PLUGIN.description = "Improved roll system."

local attributeMap = {
    ["AGI"] = "Agility",
    ["STR"] = "Strength",
    ["FORT"] = "Fortitude",
    ["CHA"] = "Charisma",
    ["INT"] = "Intelligence",
    ["MED"] = "Medical",
    ["RNG"] = "Ranged"
}

local function getAttributeValue(client, attributeKey)
    if not attributeMap[attributeKey] then
        return 10
    end

    local value = client:GetCharacter():GetAttribute(attributeKey:lower(), 10)
    return value
end

local function findAttribute(attributeKey)
    local upperKey = attributeKey:upper()
    for key, name in pairs(attributeMap) do
        if key:lower() == upperKey:lower() or name:lower() == upperKey:lower() then
            return key
        end
    end
end

ix.chat.Register("improvedRoll", {
    format = "** %s has rolled %d",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local message = ""

        local rollColor = self.color
        if data.roll == 20 then
            rollColor = Color(0, 255, 41)
        elseif data.roll >= 15 then
            rollColor = Color(61, 154, 75)
        elseif data.roll >= 10 then
            rollColor = Color(207, 255, 0)
        elseif data.roll >= 5 then
            rollColor = Color(255, 109, 0)
        elseif data.roll >= 2 then
            rollColor = Color(255, 78, 0)
        elseif data.roll == 1 then
            rollColor = Color(255, 0, 0)
        end

        if data.critStatus == "CRITICAL SUCCESS" then
            if data.attributeName then
                message = string.format("** [%s] %s has rolled a %d out of 20 (CRITICAL SUCCESS)",
                        data.attributeName, speaker:Nick(), data.roll)
            else
                message = string.format("** %s has rolled a %d out of 20 (CRITICAL SUCCESS)", speaker:Nick(), data.roll)
            end
            chat.AddText(rollColor, message, Color(0, 255, 0))
        elseif data.critStatus == "CRITICAL FAILURE" then
            if data.attributeName then
                message = string.format("** [%s] %s has rolled a %d out of 20 (CRITICAL FAILURE)",
                        data.attributeName, speaker:Nick(), data.roll)
            else
                message = string.format("** %s has rolled a %d out of 20 (CRITICAL FAILURE)", speaker:Nick(), data.roll)
            end
            chat.AddText(rollColor, message, Color(0, 255, 0))
        else
            if data.attributeName then
                if data.attributeModifier > 0 then
                    if data.modifier > 0 then
                        message = string.format("** [%s] %s has rolled %d (%d + %d + %d) out of 20",
                                data.attributeName, speaker:Nick(), data.finalRoll, data.roll, data.attributeModifier, data.modifier)
                    elseif data.modifier < 0 then
                        message = string.format("** [%s] %s has rolled %d (%d + %d - %d) out of 20",
                                data.attributeName, speaker:Nick(), data.finalRoll, data.roll, math.abs(data.attributeModifier), math.abs(data.modifier))
                    else
                        message = string.format("** [%s] %s has rolled %d (%d + %d) out of 20",
                                data.attributeName, speaker:Nick(), data.finalRoll, data.roll, data.attributeModifier)
                    end
                elseif data.attributeModifier < 0 then
                    if data.modifier > 0 then
                        message = string.format("** [%s] %s has rolled %d (%d - %d + %d) out of 20",
                                data.attributeName, speaker:Nick(), data.finalRoll, data.roll, math.abs(data.attributeModifier), data.modifier)
                    elseif data.modifier < 0 then
                        message = string.format("** [%s] %s has rolled %d (%d - %d - %d) out of 20",
                                data.attributeName, speaker:Nick(), data.finalRoll, data.roll, math.abs(data.attributeModifier), math.abs(data.modifier))
                    else
                        message = string.format("** [%s] %s has rolled %d (%d - %d) out of 20",
                                data.attributeName, speaker:Nick(), data.finalRoll, data.roll, math.abs(data.attributeModifier))
                    end
                else
                    message = string.format("** [%s] %s has rolled %d out of 20",
                            data.attributeName, speaker:Nick(), data.finalRoll, data.roll)
                end
            else
                if data.modifier > 0 then
                    message = string.format("** %s has rolled %d (%d + %d) out of 20",
                            speaker:Nick(), data.finalRoll, data.roll, data.modifier)
                elseif data.modifier < 0 then
                    message = string.format("** %s has rolled %d (%d - %d) out of 20",
                            speaker:Nick(), data.finalRoll, data.roll, math.abs(data.modifier))
                else
                    message = string.format("** %s has rolled %d out of 20", speaker:Nick(), data.finalRoll)
                end
            end
            chat.AddText(rollColor, message)
        end
    end
})

ix.command.Add("roll", {
    description = "Rolls a D20.",
    arguments = {
        bit.bor(ix.type.string, ix.type.optional),
        bit.bor(ix.type.number, ix.type.optional),
    },
    OnRun = function(self, client, attributeKey, modifier)
        local baseRoll = math.random(1, 20)

        local attributeValue = 10
        local attributeKeyFound = nil

        if attributeKey then
            attributeKeyFound = findAttribute(attributeKey)
            if attributeKeyFound then
                attributeValue = getAttributeValue(client, attributeKeyFound)
            else
                attributeKeyFound = nil
            end
        end

        local attributeModifier = attributeKeyFound and math.floor((attributeValue - 10) / 2) or 0
        modifier = (tonumber(modifier) and math.Clamp(modifier, -20, 20)) or 0
        local finalRoll = baseRoll + attributeModifier + modifier
        finalRoll = math.max(finalRoll, 1)

        local critStatus = nil
        if baseRoll == 20 then
            critStatus = "CRITICAL SUCCESS"
        elseif baseRoll == 1 then
            critStatus = "CRITICAL FAILURE"
        end

        local data = {
            roll = baseRoll,
            finalRoll = finalRoll,
            attributeModifier = attributeKeyFound and attributeModifier or nil,
            modifier = modifier,
            critStatus = critStatus,
            attributeName = attributeKeyFound and attributeMap[attributeKeyFound] or nil
        }

        ix.chat.Send(client, "improvedRoll", tostring(finalRoll), nil, nil, data)
    end
})

ix.chat.Register("advDisRoll", {
    format = "** %s has rolled %d",
    color = Color(155, 111, 176),
    CanHear = ix.config.Get("chatRange", 280),
    OnChatAdd = function(self, speaker, text, bAnonymous, data)
        local message = ""
        local rollColor = self.color
        local rollType = data.rollType

        if data.finalRoll == 20 then
            rollColor = Color(0, 255, 41)
        elseif data.finalRoll >= 15 then
            rollColor = Color(61, 154, 75)
        elseif data.finalRoll >= 10 then
            rollColor = Color(207, 255, 0)
        elseif data.finalRoll >= 5 then
            rollColor = Color(255, 109, 0)
        elseif data.finalRoll >= 2 then
            rollColor = Color(255, 78, 0)
        elseif data.finalRoll == 1 then
            rollColor = Color(255, 0, 0)
        end

        if data.critStatus == "CRITICAL SUCCESS" then
            message = string.format("** [%s] %s has rolled 20 with %s out of 20 (CRITICAL SUCCESS)",
                    data.attributeName, speaker:Nick(), rollType)
        elseif data.critStatus == "CRITICAL FAILURE" then
            message = string.format("** [%s] %s has rolled 1 with %s out of 20 %s (CRITICAL FAILURE)",
                    data.attributeName, speaker:Nick(), rollType)
        else
            if data.attributeName then
                if data.attributeModifier > 0 then
                    message = string.format("** [%s] %s has rolled %d with %s [%d + %d, %d + %d] out of 20",
                            data.attributeName, speaker:Nick(), data.finalRoll, rollType, data.roll1, math.abs(data.attributeModifier), data.roll2, math.abs(data.attributeModifier))
                elseif data.attributeModifier < 0 then
                    message = string.format("** [%s] %s has rolled %d with %s [%d - %d, %d - %d] out of 20",
                            data.attributeName, speaker:Nick(), data.finalRoll, rollType, data.roll1, math.abs(data.attributeModifier), data.roll2, math.abs(data.attributeModifier))
                else
                    message = string.format("** [%s] %s has rolled %d with %s [%d, %d] out of 20",
                            data.attributeName, speaker:Nick(), data.finalRoll, rollType, data.roll1, data.roll2)
                end
            else
                message = string.format("** %s has rolled %d with %s [%d, %d] out of 20",
                        speaker:Nick(), data.finalRoll, rollType, data.roll1, data.roll2)
            end
        end

        chat.AddText(rollColor, message)
    end
})

ix.command.Add("rolladv", {
    description = "Rolls a D20 twice and takes the highest roll.",
    arguments = {
        bit.bor(ix.type.string, ix.type.optional),
    },
    OnRun = function(self, client, attributeKey)
        local attributeValue = 10
        local attributeKeyFound = nil

        if attributeKey then
            attributeKeyFound = findAttribute(attributeKey)
            if attributeKeyFound then
                attributeValue = getAttributeValue(client, attributeKeyFound)
            else
                attributeKeyFound = nil
            end
        end

        local attributeModifier = attributeKeyFound and math.floor((attributeValue - 10) / 2) or 0

        local roll1 = math.random(1, 20)
        local roll2 = math.random(1, 20)
        local finalRoll = math.max(roll1, roll2) + attributeModifier
        finalRoll = math.max(finalRoll, 1)

        local critStatus = nil
        if roll1 == 20 or roll2 == 20 then
            critStatus = "CRITICAL SUCCESS"
        elseif roll1 == 1 and roll2 == 1 then
            critStatus = "CRITICAL FAILURE"
        end

        local data = {
            roll = finalRoll,
            roll1 = roll1,
            roll2 = roll2,
            finalRoll = finalRoll,
            attributeModifier = attributeKeyFound and attributeModifier or nil,
            critStatus = critStatus,
            attributeName = attributeKeyFound and attributeMap[attributeKeyFound] or nil,
            rollType = "Advantage"
        }

        ix.chat.Send(client, "advDisRoll", tostring(finalRoll), nil, nil, data)
    end
})

ix.command.Add("rolldis", {
    description = "Rolls a D20 twice and takes the lowest roll.",
    arguments = {
        bit.bor(ix.type.string, ix.type.optional),
    },
    OnRun = function(self, client, attributeKey)
        local attributeValue = 10
        local attributeKeyFound = nil

        if attributeKey then
            attributeKeyFound = findAttribute(attributeKey)
            if attributeKeyFound then
                attributeValue = getAttributeValue(client, attributeKeyFound)
            end
        end

        local attributeModifier = attributeKeyFound and math.floor((attributeValue - 10) / 2) or 0

        local roll1 = math.random(1, 20)
        local roll2 = math.random(1, 20)
        local finalRoll = math.min(roll1, roll2)
        finalRoll = math.max(finalRoll, 1)

        local critStatus = nil
        if roll1 == 20 and roll2 == 20 then
            critStatus = "CRITICAL SUCCESS"
        elseif roll1 == 1 or roll2 == 1 then
            critStatus = "CRITICAL FAILURE"
        end

        local data = {
            roll = finalRoll,
            roll1 = roll1,
            roll2 = roll2,
            finalRoll = finalRoll,
            attributeModifier = attributeKeyFound and attributeModifier or nil,
            modifier = modifier,
            critStatus = critStatus,
            attributeName = attributeKeyFound and attributeMap[attributeKeyFound] or nil,
            rollType = "Disadvantage"
        }

        ix.chat.Send(client, "advDisRoll", tostring(finalRoll), nil, nil, data)
    end
})