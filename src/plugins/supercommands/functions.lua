---@diagnostic disable: missing-parameter
-- No prints here, feedback must be handled by the caller.

function SetMoney(player, amount)
	local controller = player:CCSPlayerController()
	if not controller:IsValid() then return end
	controller.InGameMoneyServices.Account = amount
	StateUpdate(controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function GiveMoney(player, amount)
	local controller = player:CCSPlayerController()
	if not controller:IsValid() then return end
	controller.InGameMoneyServices.Account = controller.InGameMoneyServices.Account + amount
	StateUpdate(controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function TakeMoney(player, amount)
	local controller = player:CCSPlayerController()
	if not controller:IsValid() then return end
	controller.InGameMoneyServices.Account = controller.InGameMoneyServices.Account - amount
	StateUpdate(controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function RestartRound(time)
	SetTimeout(time * 1000, function()
		server:Execute("sv_cheats 1; endround; sv_cheats 0"); -- Lazy solution but works
	end)
end

function RestartGame(time)
	server:Execute("mp_restartgame " .. time)
end

function FindPlayer(target, detectBots) -- Find a player by steamid, steamid64, name or userid.
	target = tostring(target):trim():lower()

	local matchedPlayer = nil

	for i = 0, playermanager:GetPlayerCap() - 1 do
		local fetchedPlayer = GetPlayer(i)
		if not fetchedPlayer then
			goto continue
		end

		if detectBots == false and fetchedPlayer:IsFakeClient() then
			goto continue
		end

		if tostring(fetchedPlayer:GetSteamID()) == target or fetchedPlayer:GetSteamID2() == target then
			if matchedPlayer then
				return nil
			end
			matchedPlayer = fetchedPlayer
		end

		local cbasePlayerController = fetchedPlayer:CBasePlayerController()
		if cbasePlayerController and cbasePlayerController:IsValid() then
			if cbasePlayerController.PlayerName:lower():find(target) then
				if matchedPlayer then
					return nil
				end
				matchedPlayer = fetchedPlayer
			end
		end

		if target:sub(1, 1) == "#" then
			local playerid = target:sub(2)
			if playerid and tonumber(playerid) == i then
				if matchedPlayer then
					return nil
				end
				matchedPlayer = fetchedPlayer
			end
		end

		::continue::
	end

	return matchedPlayer
end

function ToggleNoclip(player)
	local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
	if not playerCBaseEntity:IsValid() then return end

	local currentMoveType = playerCBaseEntity.ActualMoveType -- Read the ActualMoveType value

	if currentMoveType ~= 2 then
		playerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
		StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
	else
		playerCBaseEntity.ActualMoveType = 7 -- Noclip mode (7)
		StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
	end
end

function DisableNoclip(player)
	local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
	if not playerCBaseEntity:IsValid() then return end

	playerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
	StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function EnableNoclip(player)
	local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
	if not playerCBaseEntity:IsValid() then return end

	playerCBaseEntity.ActualMoveType = 7 -- Noclip mode (7)
	StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function FreezePlayer(player)
	local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
	if not playerCBaseEntity:IsValid() then return end

	playerCBaseEntity.ActualMoveType = 11 -- Invalid mode (11)
	StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function UnfreezePlayer(player)
	local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
	if not playerCBaseEntity:IsValid() then return end

	playerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
	StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function StringToVector(str)
	local x, y, z = str:match("Vector%(([^,]+),([^,]+),([^%)]+)%)")
	return Vector(tonumber(x), tonumber(y), tonumber(z))
end

function StringToQAngle(str)
	local pitch, yaw, roll = str:match("QAngle%(([^,]+),([^,]+),([^%)]+)%)")
	return QAngle(tonumber(pitch), tonumber(yaw), tonumber(roll))
end

function SetSpeed(player, speed)
	-- Get the player pawn
	local playerPawn = player:CCSPlayerPawn()
	if not playerPawn:IsValid() then return end  -- Ensure the pawn is valid

	-- Set the velocity modifier (speed) for the player
	playerPawn.VelocityModifier = speed
end

function SetGravity(player, gravity)
	-- Get the player pawn
	local playerPawn = player:CCSPlayerPawn()
	if not playerPawn:IsValid() then return end  -- Ensure the pawn is valid

	-- Apply the gravity scale to the player using CBaseEntity
	CBaseEntity(playerPawn:ToPtr()).GravityScale = (gravity or 1.0)
end