-- !hp <target> <health> [armor] [helmet]
commands:Register("hp", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "c")
    
        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end
    
    if argsCount < 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.hp.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local health = tonumber(args[2])
    if not health then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.hp.invalid_health"))
    end

    local armor = nil
    if argsCount >= 3 then
        armor = tonumber(args[3])
        if not armor then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.hp.invalid_armor"))
        end
    end

    local helmet = nil
    if argsCount >= 4 then
        helmet = tonumber(args[4])
        if not helmet or helmet < 0 or helmet > 1 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.hp.invalid_helmet"))
        end
    end

    for i = 1, #players do
        local pl = players[i]
        pl:CBaseEntity().Health = health
        if helmet == 1 then
            pl:CCSPlayerController().PawnHasHelmet = true
        elseif helmet == 0 then
            pl:CCSPlayerController().PawnHasHelmet = false
        end
        pl:CCSPlayerPawn().ArmorValue = armor or pl:CCSPlayerPawn().ArmorValue

        if pl:CBaseEntity().Health <= 0 then
            pl:Kill()
        end
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        if argsCount == 2 then
            message = FetchTranslation("supercommands.hp.mult_message")
                :gsub("{ADMIN_NAME}", admin)
                :gsub("{PLAYER_COUNT}", tostring(#players))
                :gsub("{HEALTH}", tostring(health))
        elseif argsCount == 3 then
            message = FetchTranslation("supercommands.hp.mult_message_with_armor")
                :gsub("{ADMIN_NAME}", admin)
                :gsub("{PLAYER_COUNT}", tostring(#players))
                :gsub("{HEALTH}", tostring(health))
                :gsub("{ARMOR}", tostring(armor))
        elseif argsCount == 4 then
            message = FetchTranslation("supercommands.hp.mult_message_with_helmet")
                :gsub("{ADMIN_NAME}", admin)
                :gsub("{PLAYER_COUNT}", tostring(#players))
                :gsub("{HEALTH}", tostring(health))
                :gsub("{ARMOR}", tostring(armor))
                :gsub("{HELMET}", tostring(helmet))
        end
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        if argsCount == 2 then
            message = FetchTranslation("supercommands.hp.message")
                :gsub("{ADMIN_NAME}", admin)
                :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
                :gsub("{HEALTH}", tostring(health))
        elseif argsCount == 3 then
            message = FetchTranslation("supercommands.hp.message_with_armor")
                :gsub("{ADMIN_NAME}", admin)
                :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
                :gsub("{HEALTH}", tostring(health))
                :gsub("{ARMOR}", tostring(armor))
        elseif argsCount == 4 then
            message = FetchTranslation("supercommands.hp.message_with_helmet")
                :gsub("{ADMIN_NAME}", admin)
                :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
                :gsub("{HEALTH}", tostring(health))
                :gsub("{ARMOR}", tostring(armor))
                :gsub("{HELMET}", tostring(helmet))
        end
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !give <target> <weapon> -> only for weapon_name
commands:Register("give", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "c")
    
        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end
    
    if argsCount < 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.give.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local weapon = args[2]

    -- Add prefix weapon_ if not exists
    if not string.find(weapon, "weapon_") then
        weapon = "weapon_" .. weapon
    end

    if not IsValidWeapon(weapon) then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.give.invalid_weapon"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:GetWeaponManager():GiveWeapon(weapon)
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.give.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            :gsub("{WEAPON}", weapon)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.give.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
            :gsub("{WEAPON}", weapon)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !giveitem <target> <item>
commands:Register("giveitem", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "c")
    
        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end
    
    if argsCount < 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.giveitem.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local item = args[2]

    if not IsValidItem(item) then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.giveitem.invalid_item"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:GetInventory():AddItem(item)
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.giveitem.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            :gsub("{ITEM}", item)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.giveitem.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
            :gsub("{ITEM}", item)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !givemoney <target> <amount>
commands:Register("givemoney", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "c")
    
        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end
    
    if argsCount < 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.givemoney.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local amount = tonumber(args[2])
    if not amount then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.givemoney.invalid_amount"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:CCSPlayerController().InGameMoneyServices.Account = player:CCSPlayerController().InGameMoneyServices.Account + amount
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.givemoney.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            :gsub("{AMOUNT}", tostring(amount))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.givemoney.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
            :gsub("{AMOUNT}", tostring(amount))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !setmoney <target> <amount>
commands:Register("setmoney", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "c")
    
        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end
    
    if argsCount < 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.setmoney.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local amount = tonumber(args[2])
    if not amount then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.setmoney.invalid_amount"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:CCSPlayerController().InGameMoneyServices.Account = amount
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.setmoney.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            :gsub("{AMOUNT}", tostring(amount))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.setmoney.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
            :gsub("{AMOUNT}", tostring(amount))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !melee <target>
commands:Register("melee", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "c")
    
        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end
    
    if argsCount < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.melee.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:GetWeaponManager():RemoveWeapons()
        pl:GetWeaponManager():GiveWeapon("weapon_knife")
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.melee.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.melee.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !disarm <target>
commands:Register("disarm", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "c")
    
        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end
    
    if argsCount < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.disarm.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:GetWeaponManager():RemoveWeapons()
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.disarm.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.disarm.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)
