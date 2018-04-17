
if not discordrpc then ErrorNoHalt("DiscordRPC: missing???") return end

discordrpc.state = "redream" -- hacken

local redream = {}
function redream:Init()
	discordrpc.clientID = "435613579560091650"

	timer.Create("discordrpc_state_redream", 15, 0, function()
		discordrpc.SetActivity(self:GetActivity(), discordrpc.Print)
	end)
end
function redream:GetDetails()
	return GetHostName() .. " (" .. ip .. ")"
end
function redream:GetState()
	return "Playing on " .. game.GetMap() .. " (" .. player.GetCount() .. " / " .. game.MaxPlayers() .. " players)"
end
local start = os.time() -- os.time since spawned in the server, do not edit
function redream:GetTimestamps()
	return {
		start = start,
		["end"] = nil -- nothing?
	}
end
function redream:GetAssets()
	local assets = {}

	assets.large_image = "redream"
	assets.large_text = "re-dream.org"
	assets.small_image = "gmod"
	assets.small_text = "Garry's Mod"

	return assets
end
function redream:GetActivity()
	return {
		details = self:GetDetails(),
		state = self:GetState(),
		timestamps = self:GetTimestamps(),
		assets = self:GetAssets()
	}
end
discordrpc.states.redream = redream

-- Follow these guidelines: https://discordapp.com/developers/docs/topics/gateway#activity-object
-- You cannot use these fields: party, secrets, instance, application_id, flags (I'm not sure actually but you should only try if you know what you're doing)
-- The default state will probably help you more than this

