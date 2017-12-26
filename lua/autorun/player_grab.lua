
local tag = "player_grab"

local physgun_noplayergrab
if CLIENT then
	physgun_noplayergrab = CreateClientConVar("physgun_noplayergrab", "0", true, true)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetPhysgunner()
	if isentity(self.Physgunner) and not IsValid(self.Physgunner) then
		self.Physgunner = nil
	end
	return self.Physgunner
end
function PLAYER:GetPhysgunning()
	if isentity(self.Physgunning) and not IsValid(self.Physgunning) then
		self.Physgunning = nil
	end
	return self.Physgunning
end

hook.Add("PlayerCanGrabPlayer", tag, function(ply, ent)
	if ply.Unrestricted then return true end
	if ply:IsAdmin() or (ent:IsFriend(ply) and ent:GetInfoNum("physgun_noplayergrab", 1) == 0) or ent:IsBot() then
		return true
	end
end)

hook.Add("PhysgunPickup", tag, function(ply, ent)
	if IsValid(ply) and IsValid(ent) and ply:IsPlayer() and ent:IsPlayer() then
		local friend = hook.Run("PlayerCanGrabPlayer", ply, ent)
		if friend and not ply.Physgunning and not ent.Physgunner then
			ent:SetMoveType(MOVETYPE_NONE)
			ent:SetOwner(ply)
			ent.Physgunner = ply
			ply.Physgunning = ent
			return true
		end
	end
end)
hook.Add("PhysgunDrop", tag, function(ply, ent)
	if IsValid(ply) and IsValid(ent) and ply:IsPlayer() and ent:IsPlayer() then
		ent:SetMoveType((ply:KeyDown(IN_ATTACK2) and ply:IsAdmin()) and MOVETYPE_NOCLIP or MOVETYPE_WALK)
		ent:SetOwner()
		ent.Physgunner = nil
		ply.Physgunning = nil
	end
end)

hook.Add("PlayerDisconnected", tag, function(ply)
	hook.GetTable().PhysgunDrop[tag](ply, ply.Physgunning)
	hook.GetTable().PhysgunDrop[tag](ply.Physgunner, ply)
end)

if SERVER then
	hook.Add("PlayerNoClip", tag, function(ply)
		local physgunner = ply:GetPhysgunner()
		if not IsValid(physgunner) then return end
		if ply:IsFriend(physgunner) then
			physgunner:SelectWeapon("none")
			hook.GetTable().PhysgunDrop[tag](physgunner, ply)
		else
			return false
		end
	end)
end

