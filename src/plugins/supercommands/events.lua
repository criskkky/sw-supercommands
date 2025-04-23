AddEventHandler("OnPlayerDamage", function(p_Event, p_PlayerID)
	local l_Player = GetPlayer(p_PlayerID)
	if not l_Player then return end
	if l_Player:GetVar("godmode") then return p_Event:SetReturn(false) end
	return EventResult.Continue
end)

AddEventHandler("OnPlayerSpawn", function(p_Event)
	local l_PlayerID = p_Event:GetInt("userid")
	local l_Player = GetPlayer(l_PlayerID)
	if not l_Player then return end
	if l_Player:GetVar("godmode") then return l_Player:SetVar("godmode", false) end
	return EventResult.Continue
end)

AddEventHandler("OnPostPlayerDeath", function(p_Event)
	local l_PlayerID = p_Event:GetInt("userid")
	local l_Player = GetPlayer(l_PlayerID)
	if not l_Player then return end
	if l_Player then
		local l_Pos = l_Player:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
		local l_Rot = l_Player:CBaseEntity().CBodyComponent.SceneNode.AbsRotation
		l_Player:SetVar("death_pos", tostring(l_Pos))
		l_Player:SetVar("death_rot", tostring(l_Rot))
	end
	return EventResult.Continue
end)
