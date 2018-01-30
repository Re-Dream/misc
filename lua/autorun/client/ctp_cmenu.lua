
hook.Add("HUDPaint", "ctp_cmenu", function()
	-- If you're wondering why I'm doing all this;
	-- Not ass looking icon. Why not?

	DImage._SetImage = DImage._SetImage or DImage.SetImage
	function DImage:SetImage(path, backup)
		if type(path) == "IMaterial" then
			self:SetMaterial(path)
		else
			self._SetImage(self, path, backup)
		end
	end

	local printed = false
	local w = Color(194, 210, 225)
	local g = Color(127, 255, 127)
	local mat = WebMaterial("icon64_ctp", "https://re-dream.org/fastdl/cmenu_zoom_extend.png", function(name, url, mat)
		list.Set(
			"DesktopWindows",
			"ZCTP",
			{
				title = "Thirdperson",
				icon = mat,
				width = 960,
				height = 700,
				onewindow = true,
				init = function(icn, pnl)
					pnl:Remove()
					if not printed then
						chat.AddText(w, "Go in the ", g, "Spawn Menu", w, " > ", g, "Utilities", w, " > ", g, "CTP", w, " category to customize the third person!")
						printed = true
					end
					RunConsoleCommand("ctp")

					return false
				end
			}
		)

		CreateContextMenu()
	end)

	hook.Remove("HUDPaint", "ctp_cmenu")
end)

