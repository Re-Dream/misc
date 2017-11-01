banni = {}
local tag = "banni"

if CLIENT then
	local function emitsound(path,pitch)
		sound.PlayFile("sound/"..path,"",function(station) 
			station:SetPlaybackRate(pitch) 
			station:Play() 
			hook.Add("Think", "EMITSOUNDSSOSS", function() 
				station:SetVolume(system.HasFocus() and 1 or 0) 
			end) 
		end)
	end

	net.Receive(tag, function()
		local tbl = net.ReadTable()
		local sasdsa = player.GetBySteamID( tbl.steamid )
		local assdsa = player.GetBySteamID( tbl.who )
		local a = {
			assdsa and assdsa:Nick() or tbl.who
		}

		if(tbl.banned == true) then
			table.insert(a, Color(237,67,55))
			table.insert(a, " banned ")
			table.insert(a, Color(255,255,255))
			table.insert(a, sasdsa:IsPlayer() and sasdsa:Nick() or tbl.steamid)
			table.insert(a, " until "..os.date("%c", tbl.startedat+tbl.time)..", ")
		else
			table.insert(a, Color(75,181,67))
			table.insert(a, " unbanned ")
			table.insert(a, Color(255,255,255))
			table.insert(a, sasdsa and sasdsa:Nick() or tbl.steamid)
			table.insert(a, ",")
		end

		table.insert(a, " reason: ")
		table.insert(a, tbl.reason)

		chat.AddText(Color(255,255,255), a[1], a[2], a[3], a[4], a[5], a[2], a[6], Color(135,206,250), a[7], Color(255,255,255), a[8])

		if(tbl.banned == true) then
			emitsound("ambient/alarms/apc_alarm_pass1.wav", 1.25)
			surface.PlaySound("buttons/button6.wav")
		else
			surface.PlaySound("buttons/button5.wav")
		end

		if(sasdsa ~= false) then
			sasdsa.banni = tbl.banned
		end
	end)

	net.Receive(tag.."_bannedppl", function()
		local tbl = net.ReadTable()

		for k,v in pairs(tbl) do
			local player = player.GetBySteamID(v.steamid)

			if(player ~= false) then
				player.banni = true
			end
		end
	end)

	hook.Add("PrePlayerDraw", tag, function(ply)
		if ply.banni then
			render.SetMaterial(Material("debug/debugwhite"))
			render.SuppressEngineLighting(true)
		end
	end)
	
	hook.Add("PostPlayerDraw", tag, function(ply)
		if ply.banni then
			render.SuppressEngineLighting(false)
		end
	end)

	function NoJump( cmd )
	    if(LocalPlayer().banni) then
	    	cmd:RemoveKey( IN_JUMP )
	    end
	end
	hook.Add("CreateMove", tag, NoJump)

	net.Receive(tag.."_checkifhookshere", function()
		net.Start(tag.."_checkifhookshere")
		net.WriteEntity(LocalPlayer())
		net.WriteBool((hooks.CreateMove[tag] ~= nil))
		net.SendToServer()
	end)

	hook.Add("Think", tag, function()
		for k,v in pairs(player.GetAll()) do
			if(v.banni == true and v:GetColor() ~= Color(255,0,0)) then
				v.origmat = v:GetMaterial()
				v:SetMaterial( "models/debug/debugwhite" )
				v:SetColor(Color(255,0,0))
			elseif v.banni == false and v:GetColor() ~= Color(255,255,255) then
				v:SetMaterial( v.origmat )
				v:SetColor(Color(255,255,255))
			end
		end
	end)

	hook.Add("OnPlayerChat", tag, function(ply,txt)
		if(ply.banni) then
			for k,v in pairs(ents.FindInSphere(LocalPlayer():GetPos(),256)) do
				if(v == LocalPlayer()) then
					chat.AddText(Color(237,67,55), "[BANNI] ", team.GetColor(ply:Team()), ply:Nick(), Color(255,255,255), ": ", txt)
				end
			end
			return false
		end
	end)
elseif SERVER then
	util.AddNetworkString(tag)
	util.AddNetworkString(tag.."_bannedppl")
	util.AddNetworkString(tag.."_checkifhookshere")

	timer.Create(tag.."_dontyoudare", 1, 0, function()
		net.Start(tag.."_checkifhookshere")
		net.Broadcast()
	end)

	net.Receive(tag.."_checkifhookshere", function()
		local ass = net.ReadBool()
		local ent = net.ReadEntity()

		if not ass then
			print(ent:Nick().." has no 'CreateMove' hook!")
		end
	end)

	local hookss = {}

	hookss.ShutDown = function()
		file.Write(util.TableToJSON(banni.bannedppl))
	end

	hookss.Think = function()
		for k,v in pairs(banni.bannedppl) do
			if(os.time() > (v.startedat + v.time)) then
				banni.unban("Server",v.steamid,"Ban time expired.")
			end
		end
	end

	hookss.PlayerInitialSpawn = function(ply)
		local ass = {}

		for k,v in pairs(banni.bannedppl) do
			if(v.steamid == ply:SteamID()) then
				ply.banni = true
				ply:StripWeapons()
				ply:SetRunSpeed(ply:GetWalkSpeed())
				ply:SetJumpPower(0)

				ass = v
			end
		end

		ass.banned = true

		banni.net(ass)
	end

	hookss.PlayerSpawn = function(ply)
		if(ply.banni == true) then
			timer.Simple(0.5, function()
				ply:SetRunSpeed(ply:GetWalkSpeed())
				ply:SetJumpPower(0)
			end)
			ply:StripWeapons()
		end
	end

	hookss.PhysgunPickup = function(ply,ent)
		if(ent:IsPlayer() and ent.banni) then
			ent:SetMoveType(MOVETYPE_NONE)
			return true
		end
	end

	hookss.PhysgunDrop = function(ply,ent)
		if(ent:IsPlayer() and ent.banni) then
			ent:SetMoveType(MOVETYPE_NONE)
		end
	end

	hookss.PlayerCanPickupWeapon = function (ply)
		if(ply.banni == true) then
			return false
		end
	end

	hookss.MingebanCommand = function(caller)
		if(caller.banni) then return false,"You cannot execute command while you're banned!" end
	end

	hookss.pac_WearOutfit = function(owner)
		if(owner.banni) then return false,"owner is a banned person" end
	end

	hookss.PlayerNoClip = function(ply)
		if(ply.banni) then return false end
	end

	local args = {
		"SWEP",
		"SENT",
		"Vehicle",
		"NPC",
		"Effect",
		"Prop",
		"Ragdoll"
	}

	for k,v in pairs(args) do
		hookss["PlayerSpawn"..v] = function(ply)
			if(ply.banni) then
				return false
			end
		end
	end

	for k,v in pairs(hookss) do
		hook.Add(k, tag, v)
	end

	banni.bannedppl = util.JSONToTable(file.Read("banni.txt", "DATA") or "{}")
	banni.net = function(tbl)
		net.Start(tag)
		net.WriteTable(tbl)
		net.Broadcast()
	end

	banni.ban = function(whosteamid,steamid,time,reason)
		if(time == nil or steamid == nil or reason == nil or whosteamid == nil) then
			return "fuck no, a nil value"
		end

		local key = -1

		for k,v in pairs(banni.bannedppl) do
			if(v.steamid == steamid) then 
				key = k 
			end
		end

		if(key ~= -1) then return "player is already banned" end

		local food = (type(steamid) == "table") and steamid or {
			time = time,
			steamid = steamid,
			startedat = os.time(),
			banned = true,
			who = whosteamid,
			reason = reason
		}

		banni.net(food)

		food.banned = nil

		table.insert(banni.bannedppl, food)

		local ply = player.GetBySteamID(steamid)

		if(ply ~= false) then
			ply:ConCommand("gmod_cleanup")
			ply:ConCommand("pac_clear_parts")

			if ply:GetMoveType() == MOVETYPE_NOCLIP then
				ply:SetMoveType(MOVETYPE_WALK)
			end

			ply.banni = true

			ply:StripWeapons()
			ply:SetRunSpeed(ply:GetWalkSpeed())
			ply:SetJumpPower(0)
		end
	end

	banni.unban = function(whosteamid, steamid,reason)
		if(steamid == nil or reason == nil or whosteamid == nil) then
			return "fuck no, a nil value"
		end

		local key = -1

		for k,v in pairs(banni.bannedppl) do
			if(v.steamid == steamid) then 
				key = k 
				banni.bannedppl[k] = nil
			end
		end

		if(key == -1) then return "player is not banned" end

		banni.net({
			steamid = steamid,
			reason = reason,
			who = whosteamid,
			banned = false
		})

		local ply = player.GetBySteamID(steamid)

		if(ply ~= false) then
			ply.banni = false
			ply:SetRunSpeed(400)
			ply:SetJumpPower(200)

			hook.Run("PlayerLoadout", ply)
		end
	end
end