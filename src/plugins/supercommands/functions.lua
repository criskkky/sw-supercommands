---@diagnostic disable: missing-parameter
-- No prints here, feedback must be handled by the caller.

function SetMoney(player, amount)
    -- Get the player controller and ensure it is valid
    local controller = player:CCSPlayerController()
    if not controller:IsValid() then return end
    -- Set the amount of money
    controller.InGameMoneyServices.Account = amount
    StateUpdate(controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function GiveMoney(player, amount)
    -- Get the player controller and ensure it is valid
    local controller = player:CCSPlayerController()
    if not controller:IsValid() then return end
    -- Give the player money
    controller.InGameMoneyServices.Account = controller.InGameMoneyServices.Account + amount
    StateUpdate(controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function TakeMoney(player, amount)
    -- Get the player controller and ensure it is valid
    local controller = player:CCSPlayerController()
    if not controller:IsValid() then return end
    -- Take money from the player
    controller.InGameMoneyServices.Account = controller.InGameMoneyServices.Account - amount
    StateUpdate(controller:ToPtr(), "CCSPlayerController", "m_pInGameMoneyServices")
end

function RestartRound(time)
    -- Execute Native Command
    SetTimeout(time * 1000, function()
        server:Execute("sv_cheats 1; endround; sv_cheats 0"); -- Lazy solution but works
    end)
end

function RestartGame(time)
    -- Execute Native Command
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

        -- SteamID, SteamID64
        if tostring(fetchedPlayer:GetSteamID()) == target or fetchedPlayer:GetSteamID2() == target then
            if matchedPlayer then
                return nil
            end
            matchedPlayer = fetchedPlayer
        end

        local cbasePlayerController = fetchedPlayer:CBasePlayerController()
        if cbasePlayerController and cbasePlayerController:IsValid() then
            -- Check if the target matches the player's name
            if cbasePlayerController.PlayerName:lower():find(target) then
                if matchedPlayer then
                    return nil
                end
                matchedPlayer = fetchedPlayer
            end
        end

        -- Check if the target matches the player's userid
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
    -- Get the CBaseEntity of the player
    local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
    if not playerCBaseEntity:IsValid() then return end

    -- Read the current move type of the player from the CBaseEntity
    local currentMoveType = playerCBaseEntity.ActualMoveType -- Read the ActualMoveType value

    if currentMoveType ~= 2 then
        -- Set the player to walking mode
        playerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
        StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
    else
        -- Set the player to noclip mode
        playerCBaseEntity.ActualMoveType = 7 -- Noclip mode (7)
        StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
    end
end

function DisableNoclip(player)
    -- Get the CBaseEntity of the player
    local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
    if not playerCBaseEntity:IsValid() then return end

    -- Set the player to walking mode
    playerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
    StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function EnableNoclip(player)
    -- Get the CBaseEntity of the player
    local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
    if not playerCBaseEntity:IsValid() then return end

    -- Set the player to noclip mode
    playerCBaseEntity.ActualMoveType = 7 -- Noclip mode (7)
    StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function FreezePlayer(player)
    -- Get the CBaseEntity of the player
    local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
    if not playerCBaseEntity:IsValid() then return end

    -- Set the player to frozen mode
    playerCBaseEntity.ActualMoveType = 11 -- Invalid mode (11)
    StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end

function UnfreezePlayer(player)
    -- Get the CBaseEntity of the player
    local playerCBaseEntity = CBaseEntity(player:CCSPlayerPawn():ToPtr())
    if not playerCBaseEntity:IsValid() then return end

    -- Set the player to walking mode
    playerCBaseEntity.ActualMoveType = 2 -- Walking mode (2)
    StateUpdate(playerCBaseEntity:ToPtr(), "CBaseEntity", "m_MoveType")
end