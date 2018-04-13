
hook.Add("Initialize", "gmod_camera_override", function()
	local SWEP = weapons.GetStored("gmod_camera")

	SWEP._Reload = SWEP._Reload or SWEP.Reload
	SWEP.NextReload = 0
	function SWEP:Reload()
		if self.NextReload > CurTime() then return end

		if self.Owner:KeyDown(IN_USE) then
			self:SetNWBool("Hidden", not self:GetNWBool("Hidden"))
			if self:GetNWBool("Hidden") then
				self:SetHoldType("normal")
			else
				self:SetHoldType("camera")
			end
			self.NextReload = CurTime() + 1
			return
		end

		self:_Reload()
	end

	function SWEP:DrawWorldModel()
		if not self:GetNWBool("Hidden") then
			self:DrawModel()
		end
	end

	function SWEP:Tick()
		if not CLIENT then return end
		if self.Owner ~= LocalPlayer() then return end

		local cmd = self.Owner:GetCurrentCommand()

		if not cmd:KeyDown(IN_ATTACK2) then return end
		if self:GetLocked() then return end

		self:SetZoom(math.Clamp(self:GetZoom() + cmd:GetMouseY() * 0.1, 0.1, 175))
		self:SetRoll(self:GetRoll() + cmd:GetMouseX() * 0.025) -- Handles rotation
	end

	local gmod_camera_fov
	local gmod_camera_roll
	local gmod_camera_locked
	local gmod_camera_showhud
	if CLIENT then
		gmod_camera_fov = CreateClientConVar("gmod_camera_fov", "70", false, true)
		gmod_camera_roll = CreateClientConVar("gmod_camera_roll", "0", false, true)
		gmod_camera_locked = CreateClientConVar("gmod_camera_locked", "0", false, true)
		gmod_camera_showhud = CreateClientConVar("gmod_camera_showhud", "1", false, true)

		function SWEP:Deploy()
			if not IsValid(self.HUD) then
				self.HUD = vgui.Create("EditablePanel")
				self.HUD:SetPos(0, 0)
				self.HUD:SetSize(ScrW(), ScrH())
				self.HUD:SetRenderInScreenshots(false)
				function self.HUD.Paint(s, w, h)
					if not gmod_camera_showhud:GetBool() then return end

					local txt = "FOV: " .. math.Round(self:GetZoom(), 1)
					txt = txt .. "\nRoll: " .. math.Round(self:GetRoll(), 1)
					draw.DrawText(txt, "DermaDefault", w * 0.5, h * 0.5 + 16, color_white, TEXT_ALIGN_CENTER)
				end
			end
			if IsValid(g_ContextMenu) and not IsValid(self.Options) then
				local container = vgui.Create("DPanel", g_ContextMenu)
				container:SetSize(math.min(ScrW(), 350), math.min(ScrH(), 200))
				container:SetMouseInputEnabled(true)
				container:SetPos(ScrW() * 0.5 - container:GetWide() * 0.5, menubar and menubar.Control:GetTall() + 16 or ScrH() * 0.05)
				self.Options = container

				local form = vgui.Create("DForm", container)
				form:SetName("Camera SWEP Options")
				form:SetPaintBackgroundEnabled(true)
				form:Dock(FILL)

				form:NumSlider("Field of View", "gmod_camera_fov", 0, 175)
				form:NumSlider("Roll", "gmod_camera_roll", -180, 180)
				form:CheckBox("Lock", "gmod_camera_locked")
				form:ControlHelp("This will lock the above values from being changed with the secondary attack button, to prevent accidents.")
				form:CheckBox("Show HUD", "gmod_camera_showhud")
			end
		end
		function SWEP:Holster()
			if IsValid(self.HUD) then self.HUD:Remove() end
			if IsValid(self.Options) then self.Options:Remove() end
		end

		local lookupBinding = function(bind)
			local key = input.LookupBinding(bind)
			key = key and key:upper() or "[KEY NOT FOUND]"
			return key
		end

		SWEP.PrintWeaponInfo = weapons.Get("weapon_base").PrintWeaponInfo -- Get that functionality back
		SWEP.DrawWeaponInfoBox = true
		local instructions = ""
		instructions = instructions .. ("%s: Change field of view and view roll angle"):format(lookupBinding("+attack2"))
		instructions = instructions .. ("\n%s + %s: Keep view roll angle as 0"):format(lookupBinding("+reload"), lookupBinding("+attack2"))
		instructions = instructions .. ("\n%s + %s: Toggle holdtype\n(normal &lt;-&gt; camera)"):format(lookupBinding("+use"), lookupBinding("+reload"))
		instructions = instructions .. "\n\nOpen the Context Menu for more options"
		SWEP.Author = "GMod Team & Tenrys"
		SWEP.Instructions = instructions
	end

	if CLIENT then
		function SWEP:GetZoom() return gmod_camera_fov:GetFloat() end
		function SWEP:GetRoll() return gmod_camera_roll:GetFloat() end
		function SWEP:GetLocked() return gmod_camera_locked:GetBool() end

		function SWEP:SetZoom(f) gmod_camera_fov:SetFloat(f) end
		function SWEP:SetRoll(f) gmod_camera_roll:SetFloat(f) end
		function SWEP:SetLocked(b) gmod_camera_locked:SetBool(b) end
	else
		function SWEP:GetZoom() return self.Owner:GetInfoNum("gmod_camera_fov", 70) end
		function SWEP:GetRoll() return self.Owner:GetInfoNum("gmod_camera_roll", 0) end
		function SWEP:GetLocked() return tobool(self.Owner:GetInfoNum("gmod_camera_locked", 0)) end

		function SWEP:SetZoom(f) self.Owner:ConCommand("gmod_camera_fov " .. f) end
		function SWEP:SetRoll(f) self.Owner:ConCommand("gmod_camera_roll " .. f) end
		function SWEP:SetLocked(b) self.Owner:ConCommand("gmod_camera_locked " .. (b and "1" or "0")) end
	end

	SWEP._SetupDataTables = SWEP._SetupDataTables or SWEP.SetupDataTables
	function SWEP:SetupDataTables()	end
end)
if GAMEMODE then
	hook.GetTable().Initialize.gmod_camera_override()
end

