
hook.Add("Initialize", "gmod_tool_override", function()
	local SWEP = weapons.GetStored("gmod_tool")

	function SWEP:DoShootEffect(hitpos, hitnormal, entity, physbone, bFirstTimePredicted)
		local left = math.random(1, 2) == 1
		local snd
		if left then
			snd = "npc/stalker/stalker_footstep_left" .. math.random(1, 2) .. ".wav"
		else
			snd = "npc/stalker/stalker_footstep_right" .. math.random(1, 2) .. ".wav"
		end
		self:EmitSound(snd, 75, math.random(96, 104), 1)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation

		-- There's a bug with the model that's causing a muzzle to
		-- appear on everyone's screen when we fire this animation.
		self.Owner:SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation

		if not bFirstTimePredicted then return end

		local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
		effectdata:SetEntity(entity)
		effectdata:SetAttachment(physbone)
		util.Effect("selection_indicator", effectdata)

		local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetStart(self.Owner:GetShootPos())
		effectdata:SetAttachment(1)
		effectdata:SetEntity(self)
		util.Effect("ToolTracer", effectdata)
	end
end)
if GAMEMODE then
	hook.GetTable().Initialize.gmod_tool_override()
end


