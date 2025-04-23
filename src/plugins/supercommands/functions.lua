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
