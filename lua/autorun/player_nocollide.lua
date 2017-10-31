
local tag = "player_nocollide"

local PLAYER = FindMetaTable("Player")

if CLIENT then
	local cl_player_nocollide = CreateConVar("cl_player_nocollide", "0", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "Do you want to collide with players or not?")

	cvars.AddChangeCallback("cl_player_nocollide", function(cvar, old, new)
		if old == new then return end

		LocalPlayer().CollideWithPlayers = not tobool(new)
		net.Start(tag)
		net.SendToServer()
	end, tag)

	net.Receive(tag, function()
		local ply = net.ReadEntity()
		local bool = net.ReadBool()

		ply.CollideWithPlayers = bool
	end)

	net.Receive(tag .. "_first", function()
		local data = net.ReadTable()

		for _, data in next, data do
			data.ply.CollideWithPlayers = data.bool
		end
	end)

	function PLAYER:GetCollideWithPlayers()
		return self.CollideWithPlayers
	end
end

hook.Add("ShouldCollide", tag, function(a, b)
	if IsValid(a) and a:IsPlayer() and IsValid(b) and b:IsPlayer() then
		local cond = false
		cond = cond or not a:GetCollideWithPlayers()
		cond = cond or not b:GetCollideWithPlayers()
		cond = cond and not b.TryingToPhysgun

		return not cond
	end
end)

if SERVER then
	util.AddNetworkString(tag)
	util.AddNetworkString(tag .. "_first")

	net.Receive(tag, function(_, ply)
		net.Start(tag)
			net.WriteEntity(ply)
			net.WriteBool(ply:GetCollideWithPlayers())
		net.Broadcast()
	end)

	function PLAYER:GetCollideWithPlayers()
		return self:GetInfoNum("cl_player_nocollide", 2) == 0
	end

	hook.Add("PlayerInitialSpawn", tag, function(ply)
		net.Start(tag .. "_first")
			local tbl = {}
			for _, ply in next, player.GetAll() do
				tbl[#tbl + 1] = { ply = ply, bool = ply:GetCollideWithPlayers() }
			end
			net.WriteTable(tbl)
		net.Send(ply)
	end)
	if istable(GAMEMODE) then
		for _, ply in next, player.GetAll() do
			hook.GetTable().PlayerInitialSpawn[tag](ply)
		end
	end

	hook.Add("PlayerSpawn", tag, function(ply)
		ply:SetCustomCollisionCheck(true)
	end)

	hook.Add("PlayerTick", tag, function(ply)
		if not IsValid(ply) or not IsValid(ply:GetActiveWeapon()) then return end

		if ply:HasWeapon("weapon_physgun") and ply:GetActiveWeapon():GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK) then
			local trace = ply:GetEyeTrace()
			if IsValid(trace.Entity) and trace.Entity:IsPlayer() and hook.Run("PlayerCanGrabPlayer", ply, trace.Entity) ~= false then
				ply.TryingToPhysgun = true
			else
				ply.TryingToPhysgun = false
			end
		else
			ply.TryingToPhysgun = false
		end
	end)
end

