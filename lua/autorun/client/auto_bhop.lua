
local bhop = CreateClientConVar("auto_bhop", "0", true)

hook.Add("CreateMove", "auto_bhop", function(cmd)
	local lply = LocalPlayer()
	if not bhop:GetBool() then return end
	if not IsValid(lply) then return end
	if not lply:Alive() then return end

	local wep = lply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "weapon_archerbow" then return end -- grapplefuck

	if bit.band(cmd:GetButtons(), IN_JUMP) == 2 and lply:GetMoveType() ~= MOVETYPE_NOCLIP and lply:WaterLevel() <= 1 and not lply:OnGround() then
		cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
	end
end)

