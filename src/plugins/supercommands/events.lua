AddEventHandler("OnPlayerDamage", function(event, playerid)
    local player = GetPlayer(playerid)

    -- Check if the player is valid
    if not player then return end

    -- Check if the player has godmode enabled
    if player:GetVar("godmode") then return event:SetReturn(false) end
    -- Continue with event handling
    return EventResult.Continue
end)

AddEventHandler("OnPlayerSpawn", function(event)
    local playerid = event:GetInt("userid")
    local player = GetPlayer(playerid)

    -- Check if the player is valid
    if not player then return end

    -- Check if the player has godmode enabled
    if player:GetVar("godmode") then return player:SetVar("godmode", false) end
    -- Continue with event handling
    return EventResult.Continue
end)

AddEventHandler("OnPostPlayerDeath", function(event)
    print("Event Works!")
    local playerid = event:GetInt("userid")
    local player = GetPlayer(playerid)

    if not player then return print ("Player not found") end
    if player then
        -- Store the player's death position
        local pos = player:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
        local rot = player:CBaseEntity().CBodyComponent.SceneNode.AbsRotation

        player:SetVar("death_pos", tostring(pos))
        player:SetVar("death_rot", tostring(rot))
        print("Event OnPlayerDeath:")
        print(player:GetVar("death_pos"))
        print(player:GetVar("death_rot"))
        print("--------------------")
        end
    return EventResult.Continue
end)