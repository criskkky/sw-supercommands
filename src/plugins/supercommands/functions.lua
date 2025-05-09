-- No prints here, feedback must be handled by the caller.

function SetMoney(p_Player, p_Amount)
	local l_Controller = p_Player:CCSPlayerController()
	if not l_Controller:IsValid() then return end
	l_Controller.InGameMoneyServices.Account = p_Amount
	StateUpdate(l_Controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function GiveMoney(p_Player, p_Amount)
	local l_Controller = p_Player:CCSPlayerController()
	if not l_Controller:IsValid() then return end
	l_Controller.InGameMoneyServices.Account = l_Controller.InGameMoneyServices.Account + p_Amount
	StateUpdate(l_Controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function TakeMoney(p_Player, p_Amount)
	local l_Controller = p_Player:CCSPlayerController()
	if not l_Controller:IsValid() then return end
	l_Controller.InGameMoneyServices.Account = l_Controller.InGameMoneyServices.Account - p_Amount
	StateUpdate(l_Controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function RestartRound(p_Time)
	SetTimeout(p_Time * 1000, function()
		server:Execute("sv_cheats 1; endround; sv_cheats 0"); -- Lazy solution but works
	end)
end

function RestartGame(p_Time)
	server:Execute("mp_restartgame " .. p_Time)
end

function FindPlayer(p_Target, p_DetectBots) -- Find a player by steamid, steamid64, name or userid.
	-- String Lower: to make the search case insensitive.
	p_Target = tostring(p_Target):trim():lower()

	local l_MatchedPlayer = nil

	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_FetchedPlayer = GetPlayer(i)
		if not l_FetchedPlayer then
			goto continue
		end

		if p_DetectBots == false and l_FetchedPlayer:IsFakeClient() then
			goto continue
		end

		if tostring(l_FetchedPlayer:GetSteamID()) == p_Target or l_FetchedPlayer:GetSteamID2() == p_Target then
			if l_MatchedPlayer then
				return nil
			end
			l_MatchedPlayer = l_FetchedPlayer
		end

		local l_CBasePlayerController = l_FetchedPlayer:CBasePlayerController()
		if l_CBasePlayerController and l_CBasePlayerController:IsValid() then
			if l_CBasePlayerController.PlayerName:lower():find(p_Target) then
				if l_MatchedPlayer then
					return nil
				end
				l_MatchedPlayer = l_FetchedPlayer
			end
		end

		if p_Target:sub(1, 1) == "#" then
			local l_PlayerID = p_Target:sub(2)
			if l_PlayerID and tonumber(l_PlayerID) == i then
				if l_MatchedPlayer then
					return nil
				end
				l_MatchedPlayer = l_FetchedPlayer
			end
		end

		::continue::
	end

	return l_MatchedPlayer
end

function ToggleNoclip(p_Player)
	local l_PlayerCBaseEntity = CBaseEntity(p_Player:CCSPlayerPawn():ToPtr())
	if not l_PlayerCBaseEntity:IsValid() then return end

	local l_CurrentMoveType = l_PlayerCBaseEntity.ActualMoveType -- Read the ActualMoveType value

	if l_CurrentMoveType ~= 2 then
		l_PlayerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
		StateUpdate(l_PlayerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
	else
		l_PlayerCBaseEntity.ActualMoveType = 7 -- Noclip mode (7)
		StateUpdate(l_PlayerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
	end
end

function DisableNoclip(p_Player)
	local l_PlayerCBaseEntity = CBaseEntity(p_Player:CCSPlayerPawn():ToPtr())
	if not l_PlayerCBaseEntity:IsValid() then return end

	l_PlayerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
	StateUpdate(l_PlayerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function EnableNoclip(p_Player)
	local l_PlayerCBaseEntity = CBaseEntity(p_Player:CCSPlayerPawn():ToPtr())
	if not l_PlayerCBaseEntity:IsValid() then return end

	l_PlayerCBaseEntity.ActualMoveType = 7 -- Noclip mode (7)
	StateUpdate(l_PlayerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function FreezePlayer(p_Player)
	local l_PlayerCBaseEntity = CBaseEntity(p_Player:CCSPlayerPawn():ToPtr())
	if not l_PlayerCBaseEntity:IsValid() then return end

	l_PlayerCBaseEntity.ActualMoveType = 11 -- Invalid mode (11)
	StateUpdate(l_PlayerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function UnfreezePlayer(p_Player)
	local l_PlayerCBaseEntity = CBaseEntity(p_Player:CCSPlayerPawn():ToPtr())
	if not l_PlayerCBaseEntity:IsValid() then return end

	l_PlayerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
	StateUpdate(l_PlayerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function StringToVector(p_String)
	local x, y, z = p_String:match("Vector%(([^,]+),([^,]+),([^%)]+)%)")
	return Vector(tonumber(x), tonumber(y), tonumber(z))
end

function StringToQAngle(p_String)
	local pitch, yaw, roll = p_String:match("QAngle%(([^,]+),([^,]+),([^%)]+)%)")
	return QAngle(tonumber(pitch), tonumber(yaw), tonumber(roll))
end

function SetSpeed(p_Player, p_Speed)
	local l_PlayerPawn = p_Player:CCSPlayerPawn()
	if not l_PlayerPawn:IsValid() then return end

	l_PlayerPawn.VelocityModifier = p_Speed
end

function SetGravity(p_Player, p_Gravity)
	local l_PlayerPawn = p_Player:CCSPlayerPawn()
	if not l_PlayerPawn:IsValid() then return end

	CBaseEntity(l_PlayerPawn:ToPtr()).GravityScale = (p_Gravity or 1.0)
end

function BroadcastCommand(p_Prefix, p_String, p_AdminOnly, p_Silent)
	if p_Silent then goto skip end
	if p_AdminOnly ~= nil and type(p_AdminOnly) ~= "boolean" then
		error("Check your configs/plugins/supercommands.json. 'print_only_admins' must be a boolean value.")
	end

	if p_AdminOnly then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			local l_Player = GetPlayer(i)
			if l_Player and exports["admins"]:HasFlags(i, "b") then -- b = ADMFLAG_GENERIC
				l_Player:SendMsg(MessageType.Chat, p_Prefix .. " " .. p_String)
			end
		end
	else
		playermanager:SendMsg(MessageType.Chat, p_Prefix .. " " .. p_String)
	end
	:: skip ::
	print(p_Prefix .. " " .. p_String) -- KEEP FOR CONSOLE LOGS
end

function GetFlagsAsLetters(player)
    local flags = player:GetVar("admin.flags") or 0
    local letters = ""
    local bitToLetterMap = {
        [0] = "a", -- ADMFLAG_RESERVATION
        [1] = "b", -- ADMFLAG_GENERIC
        [2] = "c", -- ADMFLAG_KICK
        [3] = "d", -- ADMFLAG_BAN
        [4] = "e", -- ADMFLAG_UNBAN
        [5] = "f", -- ADMFLAG_SLAY
        [6] = "g", -- ADMFLAG_CHANGEMAP
        [7] = "h", -- ADMFLAG_CONVARS
        [8] = "i", -- ADMFLAG_CONFIG
        [9] = "j", -- ADMFLAG_CHAT
        [10] = "k", -- ADMFLAG_VOTE
        [11] = "l", -- ADMFLAG_PASSWORD
        [12] = "m", -- ADMFLAG_RCON
        [13] = "n", -- ADMFLAG_CHEATS
        [14] = "z", -- ADMFLAG_ROOT
        [15] = "o", -- ADMFLAG_CUSTOM1
        [16] = "p", -- ADMFLAG_CUSTOM2
        [17] = "q", -- ADMFLAG_CUSTOM3
        [18] = "r", -- ADMFLAG_CUSTOM4
        [19] = "s", -- ADMFLAG_CUSTOM5
        [20] = "t"  -- ADMFLAG_CUSTOM6
    }

    -- Iterar sobre los bits del valor "flags"
    for bit = 0, 20 do
        if (flags & (1 << bit)) ~= 0 then
            letters = letters .. (bitToLetterMap[bit] or "?") -- Agregar la letra correspondiente
        end
    end

    return letters
end
