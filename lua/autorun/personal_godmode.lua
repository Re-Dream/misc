
local tag = "personal_godmode"

if SERVER then
	local modes = {
		[0] = function(ply, attacker, allowFriends) -- mortal
			if attacker:IsPlayer() and attacker:IsFriend(ply) then
				return allowFriends
			end
			return true
		end,
		[1] = function(ply, attacker, allowFriends) -- godmode
			if attacker:IsPlayer() and attacker:IsFriend(ply) and allowFriends then
				return true
			end
			return false
		end,
		[2] = function(ply, attacker, allowFriends) -- world only
			if attacker:IsPlayer() and attacker:IsFriend(ply) then
				return allowFriends
			end
			return not attacker:IsPlayer()
		end,
		[3] = function(ply, attacker, allowFriends) -- protect from gods
			if attacker:IsPlayer() then
				if attacker:IsFriend(ply) then
					return allowFriends
				end
				local attackerGod = attacker:GetInfoNum("cl_godmode", -1) == 1
				return not attackerGod
			end
			return true
		end
	}
	hook.Add("PlayerShouldTakeDamage", tag, function(ply, attacker)
		local god = ply:GetInfoNum("cl_godmode", -1)
		local allowFriends = ply:GetInfoNum("cl_godmode_allowfriends", 1) == 1
		if attacker ~= NULL then
			local callback = modes[god]
			if callback then
				return callback(ply, attacker, allowFriends)
			end
		end
	end)
elseif CLIENT then
	local cl_godmode = CreateClientConVar("cl_godmode", "1", true, true)
	local cl_godmode_allowfriends = CreateClientConVar("cl_godmode_allowfriends", "1", true, true)

	language.Add(tag .. "_0", "Mortal")
	language.Add(tag .. "_1", "Godmode")
	language.Add(tag .. "_2", "World only")
	language.Add(tag .. "_3", "Protect from gods")
	hook.Add("PopulateToolMenu", tag, function()
		spawnmenu.AddToolMenuOption("Utilities",
			"User",
			tag,
			"God Mode", "", "",
			function(pnl)
				pnl:AddControl("Header", {
					Description = "Filter damage. What should be allowed to hurt you?"
				})

				pnl:AddControl("ListBox", {
					Options = {
						["#" .. tag .. "_0"] = { cl_godmode = 0 },
						["#" .. tag .. "_1"] = { cl_godmode = 1 },
						["#" .. tag .. "_2"] = { cl_godmode = 2 },
						["#" .. tag .. "_3"] = { cl_godmode = 3 },
					},
					Label = "Damage mode"
				})
				pnl:ControlHelp("\"World only\" will only protect from player damage.\n\"Protect from gods\" will disallow damage from god mode people while still allowing damage from vulnerable people.")

				pnl:AddControl("CheckBox", {
					Label = "Take damage from friends",
					Command = "cl_godmode_allowfriends",
				})
			end
		)
	end)
end

