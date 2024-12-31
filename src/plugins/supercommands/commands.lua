---@diagnostic disable: param-type-mismatch, redundant-parameter
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

        local hasAccess = exports["admins"]:HasFlags(playerid, "f")

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
            pl:GetWeaponManager():GiveWeapon("item_assaultsuit")
        elseif helmet == 0 then
            pl:GetWeaponManager():RemoveByItemDefinition(51)
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

-- !give <target> <weapon>
commands:Register("give", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "n")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 2 or argsCount > 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.give.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local weapon = args[2]

    if string.find(weapon, "weapon_") == nil then
        weapon = "weapon_" .. weapon
    end

    if IsValidWeapon(weapon) == false then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.give.invalid_weapon"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:GetWeaponManager():GiveWeapon(weapon)
    end

    -- Better for translation handling
    if string.find(weapon, "weapon_") then
        weapon = weapon:gsub("weapon_", "")
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

        local hasAccess = exports["admins"]:HasFlags(playerid, "n")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 2 or argsCount > 2 then
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
        pl:GetWeaponManager():GiveWeapon(item)
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

        local hasAccess = exports["admins"]:HasFlags(playerid, "n")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 2 or argsCount > 2 then
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
        GiveMoney(pl, amount)
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

        local hasAccess = exports["admins"]:HasFlags(playerid, "n")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 2 or argsCount > 2 then
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
        SetMoney(pl, amount)
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

commands:Register("takemoney", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "n")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 2 or argsCount > 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.takemoney.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local amount = tonumber(args[2])
    if not amount then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.takemoney.invalid_amount"))
    end

    for i = 1, #players do
        local pl = players[i]
        TakeMoney(pl, amount)
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.takemoney.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            :gsub("{AMOUNT}", tostring(amount))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.takemoney.message")
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

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 1 or argsCount > 1 then
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

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 1 or argsCount > 1 then
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

-- !respawn <target>
commands:Register("respawn", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 1 or argsCount > 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.respawn.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        pl:Respawn()
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.respawn.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.respawn.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !rr <time> (restart round)
commands:Register("rr", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    local time = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount > 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.rr.usage"), prefix))
    end

    time = tonumber(args[1])
    if not time then time = 1 end

    RestartRound(time)

    local message = nil

    message = FetchTranslation("supercommands.rr.message")
        :gsub("{ADMIN_NAME}", admin)
        :gsub("{TIME}", tostring(time))

    ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
end)

-- !rg <time> (restart game)
commands:Register("rg", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    local time = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount > 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.rg.usage"), prefix))
    end

    time = tonumber(args[1])
    if not time then time = 1 end

    if time > 15 then time = 15 end -- Too much time can cause unexpected behavior

    RestartGame(time)

    local message = nil

    message = FetchTranslation("supercommands.rg.message")
        :gsub("{ADMIN_NAME}", admin)
        :gsub("{TIME}", tostring(time))

    ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
end)

-- !tp <player1> <player2>
commands:Register("tp", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount ~= 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.tp.usage"), prefix))
    end

    if args[1] == args[2] then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.tp.usage"))
    end

    local player1 = FindPlayer(args[1], true)
    local player2 = FindPlayer(args[2], true)

    if not player1 or not player2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local pos = player2:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
    pos.z = pos.z + 80
    player1:CBaseEntity():Teleport(pos, player1:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))

    local message = FetchTranslation("supercommands.tp.message")
        :gsub("{ADMIN_NAME}", admin)
        :gsub("{PLAYER1}", player1:CBasePlayerController().PlayerName)
        :gsub("{PLAYER2}", player2:CBasePlayerController().PlayerName)

    ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
end)

-- !goto <target> (teleport)
commands:Register("goto", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.console.cant_use")) end

    local player = GetPlayer(playerid)
    if not player then return end

    local hasAccess = exports["admins"]:HasFlags(playerid, "b")

    -- Permission Check
    if not hasAccess then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
    end

    if player:IsValid() then
        admin = player:CBasePlayerController().PlayerName
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.goto.usage"), prefix))
    end

    local targetPlayer = FindPlayer(args[1], true)
    if not targetPlayer then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local pos = targetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
    pos.z = pos.z + 80
    player:CBaseEntity():Teleport(pos, player:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))

    local message = FetchTranslation("supercommands.goto.message")
        :gsub("{ADMIN_NAME}", admin)
        :gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName)

    ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
end)

-- !bring <target> (teleport)
commands:Register("bring", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.console.cant_use")) end

    local player = GetPlayer(playerid)
    if not player then return end

    local hasAccess = exports["admins"]:HasFlags(playerid, "b")

    -- Permission Check
    if not hasAccess then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
    end

    if player:IsValid() then
        admin = player:CBasePlayerController().PlayerName
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.bring.usage"), prefix))
    end

    local targetPlayer = FindPlayer(args[1], true)
    if not targetPlayer then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local pos = player:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
    pos.z = pos.z + 80
    targetPlayer:CBaseEntity():Teleport(pos, targetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))

    local message = FetchTranslation("supercommands.bring.message")
        :gsub("{ADMIN_NAME}", admin)
        :gsub("{PLAYER_NAME}", targetPlayer:CBasePlayerController().PlayerName)

    ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
end)

-- !bury <target> (teleport to the ground)
commands:Register("bury", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    local player = GetPlayer(playerid)
    if not player then return end

    local hasAccess = exports["admins"]:HasFlags(playerid, "b")

    -- Permission Check
    if not hasAccess then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
    end

    if player:IsValid() then
        admin = player:CBasePlayerController().PlayerName
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.bury.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        local pos = pl:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
        pos.z = pos.z - 50
        pl:CBaseEntity():Teleport(pos, pl:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.bury.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.bury.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !unbury <target> (teleport to up)
commands:Register("unbury", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    local player = GetPlayer(playerid)
    if not player then return end

    local hasAccess = exports["admins"]:HasFlags(playerid, "b")

    -- Permission Check
    if not hasAccess then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
    end

    if player:IsValid() then
        admin = player:CBasePlayerController().PlayerName
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.unbury.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        local pos = pl:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
        pos.z = pos.z + 50
        pl:CBaseEntity():Teleport(pos, pl:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.unbury.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.unbury.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !noclip <target> [1/0] (1 = enable, 0 = disable) (optional) (default: toggle)
commands:Register("noclip", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "n")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 1 or argsCount > 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.noclip.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local enable = nil
    if argsCount == 2 then
        enable = tonumber(args[2])
        if not enable or (enable ~= 0 and enable ~= 1) then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.noclip.invalid_enable"))
        end
    end

    for i = 1, #players do
        local pl = players[i]
        if enable == 1 then
            EnableNoclip(pl)
        elseif enable == 0 then
            DisableNoclip(pl)
        else
            ToggleNoclip(pl)
        end
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.noclip.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            :gsub("{STATUS}", enable == 1 and FetchTranslation("supercommands.noclip.enabled") or enable == 0 and FetchTranslation("supercommands.noclip.disabled") or FetchTranslation("supercommands.noclip.toggled"))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.noclip.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
            :gsub("{STATUS}", enable == 1 and FetchTranslation("supercommands.noclip.enabled") or enable == 0 and FetchTranslation("supercommands.noclip.disabled") or FetchTranslation("supercommands.noclip.toggled"))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !god <target> [1/0] (1 = enable, 0 = disable) (optional) (default: toggle)
commands:Register("god", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "n")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount < 1 or argsCount > 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.god.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    local enable = nil
    if argsCount == 2 then
        enable = tonumber(args[2])
        if not enable or (enable ~= 0 and enable ~= 1) then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.god.invalid_enable"))
        end
    end

    for i = 1, #players do
        local pl = players[i]
        if enable == 1 then
            pl:SetVar("godmode", true)
        elseif enable == 0 then
            pl:SetVar("godmode", false)
        else
            local godmode = pl:GetVar("godmode")
            if godmode then
                pl:SetVar("godmode", false)
            else
                pl:SetVar("godmode", true)
            end
        end
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.god.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            :gsub("{STATUS}", enable == 1 and FetchTranslation("supercommands.god.enabled") or enable == 0 and FetchTranslation("supercommands.god.disabled") or FetchTranslation("supercommands.god.toggled"))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.god.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
            :gsub("{STATUS}", enable == 1 and FetchTranslation("supercommands.god.enabled") or enable == 0 and FetchTranslation("supercommands.god.disabled") or FetchTranslation("supercommands.god.toggled"))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !freeze <target>
commands:Register("freeze", function (playerid, args, argsCount, silent, prefix)
    local admin = nil
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.freeze.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        FreezePlayer(pl)
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.freeze.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.freeze.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

commands:Register("unfreeze", function (playerid, args, argsCount, silent, prefix)
    local admin = nil
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.unfreeze.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        UnfreezePlayer(pl)
    end

    -- Message handling for multiple players
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.unfreeze.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        -- Message handling for single player
        local pl = players[1]
        message = FetchTranslation("supercommands.unfreeze.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !cc
commands:Register("cc", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    if playerid == -1 then
        -- Set admin name to CONSOLE if executed by the server console
        admin = "CONSOLE"
    else
        -- Set admin name to the player name if executed by a player
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "j")

        -- Permission Check
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    for i = 1, 10 do
        playermanager:SendMsg(MessageType.Chat, "ㅤ")
    end

    local message = FetchTranslation("supercommands.cc.message")
        :gsub("{ADMIN_NAME}", admin)

    ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
end)

-- !team <target> <team> (change team)
commands:Register("team", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    local team = nil
    
    if playerid == -1 then
        admin = "CONSOLE"
    else
        local player = GetPlayer(playerid)
        if not player then return end
        
        local hasAccess = exports["admins"]:HasFlags(playerid, "b")
        
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount ~= 2 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.team.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end
    
    team = tostring(args[2]):upper()
    
    local teamMap = {
        S = 1,
        SPEC = 1,
        T = 2,
        TT = 2,
        CT = 3
    }

    -- Verificar si el equipo es válido y convertirlo a su valor correspondiente
    if not teamMap[team] then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("supercommands.team.invalid_team"))
    end

    team = teamMap[team]

    for i = 1, #players do
        local pl = players[i]
        if not pl:CBaseEntity():IsValid() then return end

        if team == 1 then
            pl:ChangeTeam(Team.Spectator)
        elseif team == 2 then
            pl:ChangeTeam(Team.T)
        elseif team == 3 then
            pl:ChangeTeam(Team.CT)
        end
    end
    
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.team.mult_message")
        :gsub("{ADMIN_NAME}", admin)
        :gsub("{PLAYER_COUNT}", tostring(#players))
        :gsub("{TEAM}", team == 1 and FetchTranslation("supercommands.team.spec") or team == 2 and FetchTranslation("supercommands.team.t") or FetchTranslation("supercommands.team.ct"))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        local pl = players[1]
        message = FetchTranslation("supercommands.team.message")
        :gsub("{ADMIN_NAME}", admin)
        :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        :gsub("{TEAM}", team == 1 and FetchTranslation("supercommands.team.spec") or team == 2 and FetchTranslation("supercommands.team.t") or FetchTranslation("supercommands.team.ct"))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !swap <target> (swap team)
commands:Register("swap", function(playerid, args, argsCount, silent, prefix)
    local admin = nil
    
    if playerid == -1 then
        admin = "CONSOLE"
    else
        local player = GetPlayer(playerid)
        if not player then return end
        
        local hasAccess = exports["admins"]:HasFlags(playerid, "b")
        
        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.swap.usage"), prefix))
    end
    
    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end
    
    for i = 1, #players do
        local pl = players[i]
        if not pl:CBaseEntity():IsValid() then return end
        
        local team = pl:CBaseEntity().TeamNum
        
        if team == Team.T then
            pl:ChangeTeam(Team.CT)
        elseif team == Team.CT then
            pl:ChangeTeam(Team.T)
        end
    end
    
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.swap.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
            ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        local pl = players[1]
        message = FetchTranslation("supercommands.swap.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !1up <target> (revive in death position)
commands:Register("1up", function(playerid, args, argsCount, silent, prefix)
    local admin = nil

    if playerid == -1 then
        admin = "CONSOLE"
    else
        local player = GetPlayer(playerid)
        if not player then return end

        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end

        if player:IsValid() then
            admin = player:CBasePlayerController().PlayerName
        end
    end

    if argsCount ~= 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.1up.usage"), prefix))
    end

    local players = FindPlayersByTarget(args[1], true)
    if #players == 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
    end

    for i = 1, #players do
        local pl = players[i]
        if pl:CBaseEntity().Health <= 0 then
            pl:Respawn()

            if pl:GetVar("death_pos") and pl:GetVar("death_rot") then
                local pos_str = pl:GetVar("death_pos")
                local rot_str = pl:GetVar("death_rot")

                local pos = StringToVector(pos_str)
                local rot = StringToQAngle(rot_str)

                if pos and rot then
                    if pos.x ~= 0 or pos.y ~= 0 or pos.z ~= 0 then
                        pl:CBaseEntity():Teleport(pos, rot, Vector(0, 0, 0))
                        pl:SetVar("death_pos", nil)
                        pl:SetVar("death_rot", nil)
                    end
                end
            end
        end
    end
    
    local message = nil
    if #players > 1 then
        message = FetchTranslation("supercommands.1up.mult_message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_COUNT}", tostring(#players))
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    else
        local pl = players[1]
        message = FetchTranslation("supercommands.1up.message")
            :gsub("{ADMIN_NAME}", admin)
            :gsub("{PLAYER_NAME}", pl:CBasePlayerController().PlayerName)
        ReplyToCommand(playerid, config:Fetch("admins.prefix"), message)
    end
end)

-- !xyz get own coords
commands:Register("xyz", function(playerid, args, argsCount, silent, prefix)
    local target = nil
    local player = GetPlayer(playerid)
    if not player then return end

    if playerid == -1 then
        if not target then
            return player:SendMsg(MessageType.Chat, FetchTranslation("admins.invalid_player"))
        end
    else
        local hasAccess = exports["admins"]:HasFlags(playerid, "b")

        if not hasAccess then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), prefix))
        end
    end

    if argsCount > 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.xyz.usage"), prefix))
    end

    local targetPlayer = FindPlayer(args[1], true)
    if not targetPlayer then targetPlayer = player end

    local pos = targetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
    local rot = targetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsRotation
    player:SendMsg(MessageType.Chat, string.format("{green}===== %s's Coords: =====", targetPlayer:CBasePlayerController().PlayerName))
    player:SendMsg(MessageType.Chat, string.format("{red}[POS] X: {default}%.2f, {red}Y: {default}%.2f, {red}Z: {default}%.2f", pos.x, pos.y, pos.z))
    player:SendMsg(MessageType.Chat, string.format("{blue}[ROT] " .. "X: {default}%.2f, {blue}Y: {default}%.2f, {blue}Z: {default}%.2f", rot.x, rot.y, rot.z))
end)