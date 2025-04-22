function g_PermissionsCheck(p_PlayerID, p_Flags, p_Prefix, p_ConsoleBlock)
	local l_Admin = nil
	-- Check for console usage if disallowed
	if p_PlayerID == -1 then
		if p_ConsoleBlock then
			return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.console.cant_use"))
		end
		l_Admin = "CONSOLE"
	else
		local l_Player = GetPlayer(p_PlayerID)
		if not l_Player then return end

		local l_HasAccess = exports["admins"]:HasFlags(p_PlayerID, p_Flags)

		if not l_HasAccess then
			return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("admins.no_permission"), p_Prefix))
		end

		if l_Player:IsValid() then
			l_Admin = l_Player:CBasePlayerController().PlayerName
		end
	end
	return l_Admin
end

-- !hp <target> <health> [armor] [helmet]
commands:Register("hp", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "f", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount < 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.hp.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Health = tonumber(p_Args[2])
	if not l_Health then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.hp.invalid_health"))
	end

	local l_Armor = nil
	if p_ArgsCount >= 3 then
		l_Armor = tonumber(p_Args[3])
		if not l_Armor then
			return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.hp.invalid_armor"))
		end
	end

	local l_Helmet = nil
	if p_ArgsCount >= 4 then
		l_Helmet = tonumber(p_Args[4])
		if not l_Helmet or l_Helmet < 0 or l_Helmet > 1 then
			return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.hp.invalid_helmet"))
		end
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		l_Pl:CBaseEntity().Health = l_Health
		if l_Helmet == 1 then
			l_Pl:GetWeaponManager():GiveWeapon("item_assaultsuit")
		elseif l_Helmet == 0 then
			l_Pl:GetWeaponManager():RemoveByItemDefinition(51)
		end
		l_Pl:CCSPlayerPawn().ArmorValue = l_Armor or l_Pl:CCSPlayerPawn().ArmorValue

		if l_Pl:CBaseEntity().Health <= 0 then
			l_Pl:Kill()
		end
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		if p_ArgsCount == 2 then
			l_Message = FetchTranslation("supercommands.hp.mult_message")
				:gsub("{ADMIN_NAME}", l_Admin)
				:gsub("{PLAYER_COUNT}", tostring(#l_Players))
				:gsub("{HEALTH}", tostring(l_Health))
		elseif p_ArgsCount == 3 then
			l_Message = FetchTranslation("supercommands.hp.mult_message_with_armor")
				:gsub("{ADMIN_NAME}", l_Admin)
				:gsub("{PLAYER_COUNT}", tostring(#l_Players))
				:gsub("{HEALTH}", tostring(l_Health))
				:gsub("{ARMOR}", tostring(l_Armor))
		elseif p_ArgsCount == 4 then
			l_Message = FetchTranslation("supercommands.hp.mult_message_with_helmet")
				:gsub("{ADMIN_NAME}", l_Admin)
				:gsub("{PLAYER_COUNT}", tostring(#l_Players))
				:gsub("{HEALTH}", tostring(l_Health))
				:gsub("{ARMOR}", tostring(l_Armor))
				:gsub("{HELMET}", tostring(l_Helmet))
		end
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		if p_ArgsCount == 2 then
			l_Message = FetchTranslation("supercommands.hp.message")
				:gsub("{ADMIN_NAME}", l_Admin)
				:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
				:gsub("{HEALTH}", tostring(l_Health))
		elseif p_ArgsCount == 3 then
			l_Message = FetchTranslation("supercommands.hp.message_with_armor")
				:gsub("{ADMIN_NAME}", l_Admin)
				:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
				:gsub("{HEALTH}", tostring(l_Health))
				:gsub("{ARMOR}", tostring(l_Armor))
		elseif p_ArgsCount == 4 then
			message = FetchTranslation("supercommands.hp.message_with_helmet")
				:gsub("{ADMIN_NAME}", l_Admin)
				:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
				:gsub("{HEALTH}", tostring(l_Health))
				:gsub("{ARMOR}", tostring(l_Armor))
				:gsub("{HELMET}", tostring(l_Helmet))
		end
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !give <target> <weapon>
commands:Register("give", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.give.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Weapon = p_Args[2]

	-- Prefix "weapon_" if not present at input
	if string.find(l_Weapon, "weapon_") == nil then
		l_Weapon = "weapon_" .. l_Weapon
	end

	if IsValidWeapon(l_Weapon) == false then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.give.invalid_weapon"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		l_Pl:GetWeaponManager():GiveWeapon(l_Weapon)
	end

	-- Remove the "weapon_" prefix for better readability at the message
	if string.find(l_Weapon, "weapon_") == 1 then
		l_Weapon = l_Weapon:gsub("weapon_", "")
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.give.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{WEAPON}", l_Weapon)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.give.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{WEAPON}", l_Weapon)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !giveitem <target> <item>
commands:Register("giveitem", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.giveitem.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Item = p_Args[2]

	if not IsValidItem(l_Item) then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.giveitem.invalid_item"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		l_Pl:GetWeaponManager():GiveWeapon(l_Item)
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.giveitem.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{ITEM}", l_Item)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.giveitem.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{ITEM}", l_Item)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !givemoney <target> <amount>
commands:Register("givemoney", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.givemoney.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Amount = tonumber(p_Args[2])
	if not l_Amount then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.givemoney.invalid_amount"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		GiveMoney(l_Pl, l_Amount)
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.givemoney.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{AMOUNT}", tostring(l_Amount))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.givemoney.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{AMOUNT}", tostring(l_Amount))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !setmoney <target> <amount>
commands:Register("setmoney", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.setmoney.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Amount = tonumber(p_Args[2])
	if not l_Amount then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.setmoney.invalid_amount"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		SetMoney(l_Pl, l_Amount)
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.setmoney.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{AMOUNT}", tostring(l_Amount))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.setmoney.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{AMOUNT}", tostring(l_Amount))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !takemoney <target> <amount>
commands:Register("takemoney", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.takemoney.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Amount = tonumber(p_Args[2])
	if not l_Amount then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.takemoney.invalid_amount"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		TakeMoney(l_Pl, l_Amount)
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.takemoney.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{AMOUNT}", tostring(l_Amount))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.takemoney.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{AMOUNT}", tostring(l_Amount))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !melee <target>
commands:Register("melee", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.melee.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		l_Pl:GetWeaponManager():RemoveWeapons()
		l_Pl:GetWeaponManager():GiveWeapon("weapon_knife")
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.melee.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.melee.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !disarm <target>
commands:Register("disarm", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.disarm.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		l_Pl:GetWeaponManager():RemoveWeapons()
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.disarm.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.disarm.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !respawn <target>
commands:Register("respawn", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.respawn.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		l_Pl:Respawn()
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.respawn.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.respawn.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !rr <time> (restart round)
commands:Register("rr", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount > 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.rr.usage"), p_Prefix))
	end

	local l_Time = tonumber(p_Args[1])
	if not l_Time then l_Time = 1 end

	RestartRound(l_Time)

	local l_Message = nil
	l_Message = FetchTranslation("supercommands.rr.message")
		:gsub("{ADMIN_NAME}", l_Admin)
		:gsub("{TIME}", tostring(l_Time))

	ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
end)

-- !rg <time> (restart game)
commands:Register("rg", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount > 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.rg.usage"), p_Prefix))
	end

	local l_Time = tonumber(p_Args[1])
	if not l_Time then l_Time = 1 end

	if l_Time > 15 then l_Time = 15 end -- Too much time could cause unexpected behavior so we restrict it

	RestartGame(l_Time)

	local l_Message = nil
	l_Message = FetchTranslation("supercommands.rg.message")
		:gsub("{ADMIN_NAME}", l_Admin)
		:gsub("{TIME}", tostring(l_Time))

	ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
end)

-- !tp <player1> <player2>
commands:Register("tp", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.tp.usage"), p_Prefix))
	end

	if p_Args[1] == p_Args[2] then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.tp.usage"))
	end

	local l_Player1 = FindPlayer(p_Args[1], true)
	local l_Player2 = FindPlayer(p_Args[2], true)

	if not l_Player1 or not l_Player2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_DestPos = l_Player2:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
	l_DestPos.z = l_DestPos.z + 80
	l_Player1:CBaseEntity():Teleport(l_DestPos, l_Player1:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))

	local l_Message = FetchTranslation("supercommands.tp.message")
		:gsub("{ADMIN_NAME}", l_Admin)
		:gsub("{PLAYER1}", l_Player1:CBasePlayerController().PlayerName)
		:gsub("{PLAYER2}", l_Player2:CBasePlayerController().PlayerName)

	ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
end)

-- !goto <target> (teleport)
commands:Register("goto", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix, true)
	if not l_Admin then return end

	local l_Player = GetPlayer(p_PlayerID)
	if not l_Player then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.goto.usage"), p_Prefix))
	end

	local l_TargetPlayer = FindPlayer(p_Args[1], true)
	if not l_TargetPlayer then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_DestPos = l_TargetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
	l_DestPos.z = l_DestPos.z + 80
	l_Player:CBaseEntity():Teleport(l_DestPos, l_Player:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))

	local l_Message = FetchTranslation("supercommands.goto.message")
		:gsub("{ADMIN_NAME}", l_Admin)
		:gsub("{PLAYER_NAME}", l_TargetPlayer:CBasePlayerController().PlayerName)

	ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
end)

-- !bring <target> (teleport)
commands:Register("bring", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix, true)
	if not l_Admin then return end

	local l_Player = GetPlayer(p_PlayerID)
	if not l_Player then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.bring.usage"), p_Prefix))
	end

	local l_TargetPlayer = FindPlayer(p_Args[1], true)
	if not l_TargetPlayer then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_DestPos = l_Player:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
	l_DestPos.z = l_DestPos.z + 80
	l_TargetPlayer:CBaseEntity():Teleport(l_DestPos, l_TargetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))

	local l_Message = FetchTranslation("supercommands.bring.message")
		:gsub("{ADMIN_NAME}", l_Admin)
		:gsub("{PLAYER_NAME}", l_TargetPlayer:CBasePlayerController().PlayerName)

	ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
end)

-- !bury <target> (teleport to the ground)
commands:Register("bury", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.bury.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		local l_DestPos = l_Pl:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
		l_DestPos.z = l_DestPos.z - 50
		l_Pl:CBaseEntity():Teleport(l_DestPos, l_Pl:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.bury.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.bury.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !unbury <target> (teleport to up)
commands:Register("unbury", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.unbury.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		local l_DestPos = l_Pl:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
		l_DestPos.z = l_DestPos.z + 50
		l_Pl:CBaseEntity():Teleport(l_DestPos, l_Pl:CBaseEntity().CBodyComponent.SceneNode.AbsRotation, Vector(0,0,0))
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.unbury.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.unbury.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !noclip <target> [1/0] (1 = enable, 0 = disable) (optional) (default: toggle)
commands:Register("noclip", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix, true)
	if not l_Admin then return end

	local l_Player = GetPlayer(p_PlayerID)
	if not l_Player then return end

	if p_ArgsCount < 1 or p_ArgsCount > 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.noclip.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Enable = nil
	if p_ArgsCount == 2 then
		l_Enable = tonumber(p_Args[2])
		if not l_Enable or (l_Enable ~= 0 and l_Enable ~= 1) then
			return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.noclip.invalid_enable"))
		end
	end
	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		if l_Enable == 1 then
			EnableNoclip(l_Pl)
		elseif l_Enable == 0 then
			DisableNoclip(l_Pl)
		else
			ToggleNoclip(l_Pl)
		end
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.noclip.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{STATUS}", l_Enable == 1 and FetchTranslation("supercommands.noclip.enabled") or l_Enable == 0 and FetchTranslation("supercommands.noclip.disabled") or FetchTranslation("supercommands.noclip.toggled"))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.noclip.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{STATUS}", l_Enable == 1 and FetchTranslation("supercommands.noclip.enabled") or l_Enable == 0 and FetchTranslation("supercommands.noclip.disabled") or FetchTranslation("supercommands.noclip.toggled"))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !god <target> [1/0] (1 = enable, 0 = disable) (optional) (default: toggle)
commands:Register("god", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix, true)
	if not l_Admin then return end

	local l_Player = GetPlayer(p_PlayerID)
	if not l_Player then return end

	if p_ArgsCount < 1 or p_ArgsCount > 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.god.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Enable = nil
	if p_ArgsCount == 2 then
		l_Enable = tonumber(p_Args[2])
		if not l_Enable or (l_Enable ~= 0 and l_Enable ~= 1) then
			return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.god.invalid_enable"))
		end
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		if l_Enable == 1 then
			l_Pl:SetVar("godmode", true)
		elseif l_Enable == 0 then
			l_Pl:SetVar("godmode", false)
		else
			local l_Godmode = l_Pl:GetVar("godmode")
			if l_Godmode then
				l_Pl:SetVar("godmode", false)
			else
				l_Pl:SetVar("godmode", true)
			end
		end
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.god.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{STATUS}", l_Enable == 1 and FetchTranslation("supercommands.god.enabled") or l_Enable == 0 and FetchTranslation("supercommands.god.disabled") or FetchTranslation("supercommands.god.toggled"))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.god.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{STATUS}", l_Enable == 1 and FetchTranslation("supercommands.god.enabled") or l_Enable == 0 and FetchTranslation("supercommands.god.disabled") or FetchTranslation("supercommands.god.toggled"))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !freeze <target>
commands:Register("freeze", function (p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.freeze.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		FreezePlayer(l_Pl)
	end

	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.freeze.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.freeze.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !unfreeze <target>
commands:Register("unfreeze", function (p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.unfreeze.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		UnfreezePlayer(l_Pl)
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.unfreeze.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.unfreeze.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !cc
commands:Register("cc", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "j", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.cc.usage"), p_Prefix))
	end

	for i = 1, 10 do
		playermanager:SendMsg(MessageType.Chat, "ㅤ")
	end

	local l_Message = FetchTranslation("supercommands.cc.message")
		:gsub("{ADMIN_NAME}", l_Admin)
	ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
end)

-- !team <target> <team> (change team)
commands:Register("team", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.team.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_TeamInput = tostring(p_Args[2]):upper()
	local l_TeamMap = {
		S = 1,
		SPEC = 1,
		T = 2,
		TT = 2,
		CT = 3
	}
	local l_Team = l_TeamMap[l_TeamInput]
	if not l_Team then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.team.invalid_team"))
	end
	
	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		if not l_Pl:CBaseEntity():IsValid() then return end

		if l_Team == 1 then
			l_Pl:ChangeTeam(Team.Spectator)
		elseif l_Team == 2 then
			l_Pl:ChangeTeam(Team.T)
		elseif l_Team == 3 then
			l_Pl:ChangeTeam(Team.CT)
		end
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.team.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{TEAM}", l_Team == 1 and FetchTranslation("supercommands.team.spec") or l_Team == 2 and FetchTranslation("supercommands.team.t") or FetchTranslation("supercommands.team.ct"))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.team.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{TEAM}", l_Team == 1 and FetchTranslation("supercommands.team.spec") or l_Team == 2 and FetchTranslation("supercommands.team.t") or FetchTranslation("supercommands.team.ct"))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !swap <target> (swap team)
commands:Register("swap", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.swap.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		if not l_Pl:CBaseEntity():IsValid() then return end

		local l_Team = l_Pl:CBaseEntity().TeamNum

		if l_Team == Team.T then
			l_Pl:ChangeTeam(Team.CT)
		elseif l_Team == Team.CT then
			l_Pl:ChangeTeam(Team.T)
		end
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.swap.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.swap.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !1up <target> (revive in death position)
commands:Register("1up", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 1 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.1up.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		if l_Pl:CBaseEntity().Health <= 0 then
			l_Pl:Respawn()

			if l_Pl:GetVar("death_pos") and l_Pl:GetVar("death_rot") then
				local l_PosStr = l_Pl:GetVar("death_pos")
				local l_RotStr = l_Pl:GetVar("death_rot")

				local l_Pos = StringToVector(l_PosStr)
				local l_Rot = StringToQAngle(l_RotStr)

				if l_Pos and l_Rot then
					if l_Pos.x ~= 0 or l_Pos.y ~= 0 or l_Pos.z ~= 0 then
						l_Pl:CBaseEntity():Teleport(l_Pos, l_Rot, Vector(0, 0, 0))
						l_Pl:SetVar("death_pos", nil)
						l_Pl:SetVar("death_rot", nil)
					end
				end
			end
		end
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.1up.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.1up.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !xyz [target]
commands:Register("xyz", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "b", p_Prefix)
	if not l_Admin then return end

	local l_TargetPlayer = nil
	if p_ArgsCount == 0 then
		if p_PlayerID == -1 then
			return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.xyz.usage"), p_Prefix)
		end
		l_TargetPlayer = GetPlayer(p_PlayerID)
	elseif p_ArgsCount == 1 then
		l_TargetPlayer = FindPlayer(p_Args[1], true)
	else
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.xyz.usage"), p_Prefix))
	end

	if not l_TargetPlayer or not l_TargetPlayer:IsValid() then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Pos = l_TargetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
	local l_Rot = l_TargetPlayer:CBaseEntity().CBodyComponent.SceneNode.AbsRotation
	if p_PlayerID ~= -1 then
		local l_Player = GetPlayer(p_PlayerID)
		if not l_Player then return end
		l_Player:SendMsg(MessageType.Chat, string.format("{green}===== %s's Coords: =====", l_TargetPlayer:CBasePlayerController().PlayerName))
		l_Player:SendMsg(MessageType.Chat, string.format("{red}[POS] X: {default}%.2f, {red}Y: {default}%.2f, {red}Z: {default}%.2f", l_Pos.x, l_Pos.y, l_Pos.z))
		l_Player:SendMsg(MessageType.Chat, string.format("{blue}[ROT] " .. "X: {default}%.2f, {blue}Y: {default}%.2f, {blue}Z: {default}%.2f", l_Rot.x, l_Rot.y, l_Rot.z))
	else
		print(string.format("{green}===== %s's Coords: =====", l_TargetPlayer:CBasePlayerController().PlayerName))
		print(string.format("{red}[POS] X: {default}%.2f, {red}Y: {default}%.2f, {red}Z: {default}%.2f", l_Pos.x, l_Pos.y, l_Pos.z))
		print(string.format("{blue}[ROT] " .. "X: {default}%.2f, {blue}Y: {default}%.2f, {blue}Z: {default}%.2f", l_Rot.x, l_Rot.y, l_Rot.z))
	end
end)

-- !speed <target> <speed> (set speed)
commands:Register("speed", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.speed.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Speed = tonumber(p_Args[2])
	if not l_Speed then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.speed.invalid_speed"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		SetSpeed(l_Pl, l_Speed)
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.speed.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{SPEED}", tostring(l_Speed))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.speed.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{SPEED}", tostring(l_Speed))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !gravity <target> <value> (value must be between 0.0 and 1.0)
commands:Register("gravity", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.gravity.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end

	local l_Gravity = tonumber(p_Args[2])
	if not l_Gravity or l_Gravity < 0.0 or l_Gravity > 1.0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.gravity.invalid_gravity"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		SetGravity(l_Pl, l_Gravity)
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.gravity.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{GRAVITY}", tostring(l_Gravity))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.gravity.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{GRAVITY}", tostring(l_Gravity))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)

-- !armor <target> <armor> (set armor)
commands:Register("armor", function(p_PlayerID, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Admin = g_PermissionsCheck(p_PlayerID, "n", p_Prefix)
	if not l_Admin then return end

	if p_ArgsCount ~= 2 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), string.format(FetchTranslation("supercommands.armor.usage"), p_Prefix))
	end

	local l_Players = FindPlayersByTarget(p_Args[1], true)
	if #l_Players == 0 then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_player"))
	end
	
	local l_Armor = tonumber(p_Args[2])
	if not l_Armor then
		return ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), FetchTranslation("supercommands.armor.invalid_armor"))
	end

	for i = 1, #l_Players do
		local l_Pl = l_Players[i]
		l_Pl:CBaseEntity().Armor = l_Armor
	end
	-- Message handling for multiple players
	local l_Message = nil
	if #l_Players > 1 then
		l_Message = FetchTranslation("supercommands.armor.mult_message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_COUNT}", tostring(#l_Players))
			:gsub("{ARMOR}", tostring(l_Armor))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	else
		-- Message handling for single player
		local l_Pl = l_Players[1]
		l_Message = FetchTranslation("supercommands.armor.message")
			:gsub("{ADMIN_NAME}", l_Admin)
			:gsub("{PLAYER_NAME}", l_Pl:CBasePlayerController().PlayerName)
			:gsub("{ARMOR}", tostring(l_Armor))
		ReplyToCommand(p_PlayerID, config:Fetch("admins.prefix"), l_Message)
	end
end)
