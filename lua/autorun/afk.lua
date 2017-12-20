
local tag = "AFK"

afk = {}
afk.AFKTime = CreateConVar("mp_afktime", "90", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY }, "The time it takes for a player to become AFK when inactive.")

local PLAYER = FindMetaTable("Player")

function PLAYER:IsAFK()
	return self.AFK_Is
end
function PLAYER:AFKTime()
	return self.AFK_Time
end

if SERVER then
	util.AddNetworkString(tag)

	net.Receive(tag, function(_, ply)
		local is = net.ReadBool()
		ply.AFK_Is = is
		hook.Run("AFK", ply, is, ply.AFK_Time)
		ply.AFK_Time = is and CurTime() - afk.AFKTime:GetInt() or nil
		net.Start(tag)
			net.WriteUInt(ply:EntIndex(), 8)
			net.WriteBool(is)
		net.Broadcast()
	end)

	local w = Color(194, 210, 225)
	local g = Color(127, 255, 127)
	hook.Add("AFK", "AFKNotification", function(ply, is, time)
		ply:EmitSound(not is and "replay/cameracontrolmodeentered.wav" or "replay/cameracontrolmodeexited.wav")
		if not is and time then
			ply:ChatAddText(g, "Welcome back! ", w, "You were away for ", g, string.NiceTime(math.max(0, CurTime() - time - afk.AFKTime:GetInt())), w, ".")
		end
	end)
elseif CLIENT then
	afk.Mouse = { x = 0, y = 0 }
	afk.Focus = system.HasFocus()
	afk.Back = CurTime()
	afk.Gone = CurTime()
	afk.Is = false

	hook.Add("RenderScene", tag, function()
		if LocalPlayer() == NULL or not LocalPlayer() or CurTime() < 1 then return end
		afk.Back = 0
		afk.Gone = CurTime()
		hook.Remove("RenderScene", tag)
	end)
	local function Input()
		if not afk.Gone then return end
		if afk.Is then
			afk.Back = afk.Gone
			net.Start(tag)
				net.WriteBool(false)
			net.SendToServer()
		end
		afk.Gone = CurTime()
		afk.Is = false
	end
	hook.Add("StartCommand", tag, function(ply, cmd)
		if ply ~= LocalPlayer() or not afk.Gone then return end
		local mouseMoved = system.HasFocus() and (afk.Mouse.x ~= gui.MouseX() or afk.Mouse.y ~= gui.MouseY()) or false
		if  mouseMoved or
			cmd:GetMouseX() ~= 0 or
			cmd:GetMouseY() ~= 0 or
			cmd:GetButtons() ~= 0 or
			(afk.Focus == false and afk.Focus ~= system.HasFocus())
		then
			Input()
		end
		if afk.Gone + afk.AFKTime:GetInt() < CurTime() and not afk.Is then
			afk.Is = true
			net.Start(tag)
				net.WriteBool(true)
			net.SendToServer()
		end
	end)
	hook.Add("KeyPress", tag, Input)
	hook.Add("KeyRelease", tag, Input)
	hook.Add("PlayerBindPress", tag, Input)
	local lastAFK = CurTime()
	local function getAFKtime()
		local lastInput
		if afk.Is then
		 	lastInput = afk.Gone
		 	lastAFK = CurTime()
		else
		 	lastInput = afk.Back
		end
		-- return time since last input since time it takes to get afk as well as
		-- the time it was before we came back
		return math.max(lastAFK - (lastInput + afk.AFKTime:GetInt()), 0), lastAFK
	end

	net.Receive(tag, function()
		local ply = Entity(net.ReadUInt(8))
		local is = net.ReadBool()
		ply.AFK_Is = is
		hook.Run("AFK", ply, is, ply.AFK_Time)
		ply.AFK_Time = is and CurTime() - afk.AFKTime:GetInt() or nil
	end)

	surface.CreateFont(tag, {
		font = "Roboto Cn",
		size = 36,
		italic = true,
		weight = 800,
	})
	surface.CreateFont(tag .. "_time", {
		font = "Roboto Bk",
		size = 48,
		italic = false,
		weight = 800,
	})

	local a = 0
	local function DrawTranslucentText(txt, x, y, col)
		surface.SetTextPos(x + 2, y + 2)
		surface.SetTextColor(Color(0, 0, 0, 127))
		surface.DrawText(txt)

		surface.SetTextPos(x, y)
		if col then
			surface.SetTextColor(Color(col.r, col.g, col.b, 164))
		else
			surface.SetTextColor(Color(255, 255, 255, 164))
		end
		surface.DrawText(txt)
	end
	afk.Draw = CreateConVar("cl_afk_hud_draw", "1", { FCVAR_ARCHIVE })
	hook.Add("HUDPaint", tag, function()
		if not afk.Draw:GetBool() then return end
		afk.Focus = system.HasFocus()

		local AFKTime, lastAFK = getAFKtime()

		-- wait 3 seconds before hiding
		local show = afk.Is
		show = show or CurTime() < lastAFK + 3
		a = Lerp(FrameTime() * 3, a, show and 1 or 0)
		if a <= 0.005 then return end

		surface.SetAlphaMultiplier(a)

		surface.SetFont(tag)
		local txt = "You've been away for"
		local txtW, txtH = surface.GetTextSize(txt)

		surface.SetFont(tag .. "_time")
		local timeString = string.NiceTime(AFKTime)
		local timeW, timeH = surface.GetTextSize(timeString)

		local wH = txtH + timeH

		surface.SetDrawColor(Color(0, 0, 0, 127))
		surface.DrawRect(0, ScrH() * 0.5 * 0.5 - wH * 0.5 - txtH * 0.33, ScrW(), wH + txtH * 0.33 * 2 - 3)

		surface.SetFont(tag)
		DrawTranslucentText(txt, ScrW() / 2 - txtW / 2, ScrH() / 2 / 2 - wH / 2)

		surface.SetFont(tag .. "_time")
		local col
		if afk.Is then
			col = Color(140, 159, 231)
		else
			col = Color(167, 255, 167)
		end
		DrawTranslucentText(timeString, ScrW() / 2 - timeW / 2, ScrH() / 2 / 2 - wH / 2 + txtH, col)

		surface.SetAlphaMultiplier(1)
	end)

end

