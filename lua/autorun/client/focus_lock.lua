
local tag = "focus_lock"

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
	if not system.HasFocus() and not IsValid(focus_panel) then
		print("Lost focus")
		CreatePanel()
	elseif system.HasFocus() and IsValid(focus_panel) then
		print("Gained focus")
		RemovePanel()
	end
end)

