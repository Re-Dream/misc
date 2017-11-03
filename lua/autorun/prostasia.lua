if(game.SinglePlayer()) then return end

local tag = "prostasia"

local PLAYER = FindMetaTable("Player")

if not PLAYER.IsFriend then
	MsgC( "["..tag.."]", Color(255,0,0), " lua_helpers required! https://github.com/Re-Dream/lua_helpers/ \n")
	return
end

if not easylua then
	MsgC( "["..tag.."]", Color(255,0,0), " LuaDev required! https://github.com/Noiwex/luadev/ \n")
	return
end

if SERVER then
	util.AddNetworkString(tag.."_propspawned")
	util.AddNetworkString(tag.."_clean")

	local convarb = CreateConVar("pss_ar_delay","5", FCVAR_NONE, "Prostasia's convar, changes auto-remove delay")
	local convara = CreateConVar("pss_ar_enable","1", FCVAR_NONE, "Prostasia's convar, enables/disables auto-remove functionality.")

	local enable_autoremove = convara:GetBool()
	local prostasia_howmanymins = convarb:GetFloat()

	prostasia_leavers = {}

	local args = {
		two = {
			"SWEP",
			"SENT",
			"Vehicle",
			"NPC"
		},
		three = {
			"Effect",
			"Prop",
			"Ragdoll"
		}
	}

	local function netshit(ply,ent)
		net.Start(tag.."_propspawned")
		net.WriteTable({
			owner = ply:EntIndex(),
			entity = ent:EntIndex()
		})
		net.Broadcast()
	end

	local function forthree(ply,model,ent)
		ent.Owner = ply
		ent.OSteamID = ply:SteamID()
	end

	local function fortwo(ply,ent)
		ent.Owner = ply
		ent.OSteamID = ply:SteamID()
	end

	for i = 1,4 do
		if(i < #args.three or i == #args.three) then
			hook.Add("PlayerSpawned"..args.three[i], tag.."_onspawn", forthree)
		end

		if(i < #args.two or i == #args.two) then
			hook.Add("PlayerSpawned"..args.two[i], tag.."_onspawn", fortwo)
		end
	end
    
	local ERR_NOTVALID_NOTPLAYER = 1
	local ERR_SOMETHING_GONE_WRONG = 2

	local function check(ply,ent)
		if type(ent) ~= "Player" and IsValid(ent) and IsValid(ent.Owner) then
			return (ent.Owner == ply or ent.Owner:IsFriend(ply) or ply:IsAdmin())
		end

		return 2
	end

	hook.Add("PlayerDisconnected", tag.."_disconnect", function(ply)
		if enable_autoremove == true then
			prostasia_leavers[ply:SteamID()] = CurTime()
		end
	end)

	local function noticecleanup(steamid)
		for k,v in pairs(player.GetAll()) do
			if v:IsAdmin() == true then
				net.Start(tag.."_clean")
				net.WriteString(steamid)
				net.Send(v)
			end
		end

		for k,v in pairs(ents.GetAll()) do
			if(v.OSteamID == steamid) then
				v:Remove()
			end
		end
	end

	hook.Add("Think", tag.."_think", function()
		enable_autoremove = convara:GetBool()
		prostasia_howmanymins = convarb:GetFloat()

		if enable_autoremove == true then
			for k,v in pairs(prostasia_leavers) do
				if(CurTime()-v > prostasia_howmanymins*60) then
					noticecleanup(k)
					prostasia_leavers[k] = nil
				end
			end
		end
	end)

	hook.Add("PlayerInitialSpawn", tag.."_connect", function(ply)
		prostasia_leavers[ply:SteamID()] = nil
	end)

	hook.Add("PhysgunDrop", tag.."_physdrop", function(ply,ent)
		if(ent:IsPlayer() and ent:GetMoveType() == MOVETYPE_NONE) then
			ent:SetMoveType(MOVETYPE_WALK)
		end
	end)

	hook.Add("PhysgunPickup", tag.."_physpickup", function(ply,ent)
		if(ent:IsPlayer()) then
			ent:SetMoveType(MOVETYPE_NONE)

			return (ent:IsFriend(ply) or ply:IsAdmin())
		end

		local chooch = check(ply,ent)

		if(chooch == ERR_SOMETHING_GONE_WRONG) then
			return false
		end



		if(type(chooch) ~= "number") then
			return chooch
		end

		return false
	end)

	hook.Add("CanTool", tag.."_toolrestrict", function(ply,tr,tool)
		local ent = tr.Entity
		
		local chooch = check(ply,ent)

		if(chooch == ERR_SOMETHING_GONE_WRONG) then
			return false
		end

		if(type(chooch) ~= "number") then
			return chooch
		end

		return false
	end)
elseif CLIENT then
	net.Receive(tag.."_clean", function()
		local stid = net.ReadString()

		notification.AddLegacy("[PROSTASIA] "..stid.."'s props have been cleaned up!",NOTIFY_CLEANUP,5)
		surface.PlaySound("buttons/lever"..math.random(1,8)..".wav")
	end)
end