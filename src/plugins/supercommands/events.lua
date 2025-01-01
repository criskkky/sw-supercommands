AddEventHandler("OnPlayerDamage", function(event, playerid)
	local player = GetPlayer(playerid)
	if not player then return end
	if player:GetVar("godmode") then return event:SetReturn(false) end
	return EventResult.Continue
end)

AddEventHandler("OnPlayerSpawn", function(event)
	local playerid = event:GetInt("userid")
	local player = GetPlayer(playerid)
	if not player then return end
	if player:GetVar("godmode") then return player:SetVar("godmode", false) end
	return EventResult.Continue
end)

AddEventHandler("OnPostPlayerDeath", function(event)
	local playerid = event:GetInt("userid")
	local player = GetPlayer(playerid)
	if not player then return end
	if player then
		local pos = player:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
		local rot = player:CBaseEntity().CBodyComponent.SceneNode.AbsRotation
		player:SetVar("death_pos", tostring(pos))
		player:SetVar("death_rot", tostring(rot))
	end
	return EventResult.Continue
end)
