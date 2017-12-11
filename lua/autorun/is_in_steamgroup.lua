
local tag = "is_in_steamgroup"

local groupID = "103582791457553023" -- Re-Dream

if SERVER then
	local nextCheck = {}
	hook.Add("PlayerSpawn", tag, function(ply)
		if nextCheck[ply] and nextCheck[ply] > CurTime() then return end
		http.Fetch("http://steamcommunity.com/gid/" .. groupID .. "/memberslistxml/?xml=1", function(body, len, headers, code)
			if body:match("<steamID64>" .. ply:SteamID64() .. "</steamID64>") then
				ply:SetNWBool(tag, true)
			else
				ply:SetNWBool(tag, false)
			end
		end)
		nextCheck[ply] = CurTime() + 10
	end)

	if istable(GAMEMODE) then
		for _, ply in next, player.GetAll() do
			hook.GetTable().PlayerSpawn[tag](ply)
		end
	end
end

