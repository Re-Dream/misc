
hook.Add("CanTool", "ToolAbuseRestrict", function(ply, _, tool)
	if tool == "duplicator" and not ply:IsAdmin() then
		ply:ChatPrint("We don't allow the duplicator to be used here at this point in time, sorry!")
		return false
	end

	if tool == "fading_door" and not table.HasValue(list.Get("FDoorMaterials"), ply:GetInfo("fading_door_mat")) then
		ply:ChatPrint("Restricted to allowed materials only!")
		return false
	end
	
	if(type(tr.Entity) == "Player" and tool == "material") then
		return false	
	end
	
	if(tr.Entity == game.GetWorld() and tool == "rope") then
		return false	
	end
end)

