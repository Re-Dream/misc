
hook.Add("MingebanInitialized", "autorestart", function()
	local autorestarting = false
	local function abort()
		mingeban.utils.print(mingeban.colors.Cyan, "Restart cancelled, players are on")
		game.ConsoleCommand("mingeban abort\n")
		autorestarting = false
	end
	timer.Create("autorestart", 60, 0, function()
		if (CurTime() / 60 / 60) >= 8 then
			if player.GetCount() < 1 and not mingeban.IsCountdownActive() and not autorestarting then
				mingeban.utils.print(mingeban.colors.Cyan, "Automatic restart, CurTime is imprecise")
				game.ConsoleCommand("mingeban restart 30\n")
				autorestarting = true
			elseif player.GetCount() > 0 and mingeban.IsCountdownActive() and autorestarting then
				abort()
			end
		end
	end)
	hook.Add("ShutDown", "autorestart", function()
		if not DiscordRelay or not autorestarting then return end

		local msg = {
			{
				author = {
					name = GetHostName(),
					url = "http://gmlounge.us/join",
					icon_url = "https://gmlounge.us/media/redream-logo.png"
				},
				description = "is autorestarting, was playing `" .. game.GetMap() .. "`.",
				color = DiscordRelay.HexColors.Red
			}
		}
		DiscordRelay.SendToDiscordRaw(nil, nil, msg)

		autorestarting = false
	end)

	hook.Add("PlayerConnect", "autorestart", function()
		if mingeban.IsCountdownActive() and autorestarting then
			abort()
		end
	end)
end)

