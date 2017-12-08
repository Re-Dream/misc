
local tag = "focus_lock"

local windowed = system.IsWindowed()
local firstInput = false
local function HasFocus()
	if windowed and not firstInput then
		return false
	else
		return system.HasFocus()
	end
end
local function RemovePanel()
	focus_panel:Remove()
end
local function CreatePanel()
	focus_panel = vgui.Create("EditablePanel")
	focus_panel:SetKeyboardInputEnabled(false)
	focus_panel:SetVisible(true)
	focus_panel:MakePopup()
end

hook.Add("Think", tag, function()
	if not HasFocus() and not IsValid(focus_panel) then
		if GetConVarNumber("developer") == 1 then
			print("Lost focus")
		end
		hook.Run("OnFocusChanged", false)
		CreatePanel()
	elseif HasFocus() and IsValid(focus_panel) then
		if GetConVarNumber("developer") == 1 then
			print("Gained focus")
		end
		hook.Run("OnFocusChanged", true)
		RemovePanel()
	end
end)

hook.Add("PlayerButtonDown", tag, function()
	firstInput = true
	hook.Remove("PlayerButtonDown", tag)
end)

