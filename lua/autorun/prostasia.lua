
local tag = "prostasia"

local PLAYER = FindMetaTable("Player")

if not PLAYER.IsFriend then return end

prostasia = {}

if SERVER then
	prostasia.Disconnected = {}
	prostasia.DisconnectedCleanupDelay = CreateConVar(tag .. "_disconnected_cleanup_delay", "5", { FCVAR_ARCHIVE })
	prostasia.DisconnectedCleanup = CreateConVar(tag .. "_disconnected_cleanup", "1", { FCVAR_ARCHIVE })

	local PlayerSpawned = {
		Entities = {
			"SWEP",
			"SENT",
			"Vehicle",
			"NPC"
		},
		Props = {
			"Effect",
			"Prop",
			"Ragdoll"
		}
	}
	for _, tbl in next, PlayerSpawned do
		for _, typ in next, tbl do
			hook.Add("PlayerSpawned" .. typ, tag, function(ply, model, ent)
				if not ent then ent = model end
				ent.prostasia_Owner = ply
				ent.prostasia_OwnerSteamID = ply:SteamID()
				ent:SetNWString(tag .. "_owner", ply:SteamID())
			end)
		end
	end

	hook.Add("PlayerInitialSpawn", tag, function(ply)
		if prostasia.DisconnectedCleanup:GetBool() then
			prostasia.Disconnected[ply:SteamID()] = nil
		end
	end)
	hook.Add("PlayerDisconnected", tag, function(ply)
		if prostasia.DisconnectedCleanup:GetBool() then
			prostasia.Disconnected[ply:SteamID()] = CurTime()
		end
	end)
	hook.Add("Think", tag, function()
		if prostasia.DisconnectedCleanup:GetBool() then
			for sid, time in next, prostasia.Disconnected do
				if CurTime() - time > prostasia.DisconnectedCleanupDelay:GetInt() * 60 then
					for _, ent in next, ents.GetAll() do
						if ent.prostasia_OwnerSteamID == sid then
							ent:Remove()
						end
					end
					Notify(sid .. "'s props have been cleaned up!", NOTIFY_CLEANUP, 5, "buttons/lever" .. math.random(1, 8) .. ".wav")
					prstasia.Disconnected[sid] = nil
				end
			end
		end
	end)

	local function Check(ply, ent)
		if not ent:IsPlayer() and (IsValid(ent) or ent:IsWorld()) then
			if IsValid(ent.prostasia_Owner) then
				return (ent.prostasia_Owner == ply or ent.prostasia_Owner:IsFriend(ply) or ply:IsAdmin())
			else
				return ent:MapCreationID() == -1
			end
		end
	end
	hook.Add("PhysgunDrop", tag, function(ply, ent)
		if hook.GetTable().PhysgunDrop.player_grab then return end

		if ent:IsPlayer() and ent:GetMoveType() == MOVETYPE_NONE then
			ent:SetMoveType(MOVETYPE_WALK)
		end
	end)
	hook.Add("PhysgunPickup", tag, function(ply, ent)
		if not hook.GetTable().PhysgunDrop.player_grab then
			if ent:IsPlayer() then
				ent:SetMoveType(MOVETYPE_NONE)

				return (ent:IsFriend(ply) or ply:IsAdmin())
			end
		end

		local allowed = Check(ply, ent)
		return allowed
	end)
	hook.Add("CanTool", tag, function(ply, trace, tool)
		local ent = trace.Entity

		local allowed = Check(ply, ent)
		return allowed
	end)
end