local gestures = {
	robot    = "ACT_GMOD_TAUNT_ROBOT",
	salute   = "ACT_GMOD_TAUNT_SALUTE",
	agree    = "ACT_GMOD_GESTURE_AGREE",
	becon    = "ACT_GMOD_GESTURE_BECON",
	bow      = "ACT_GMOD_GESTURE_BOW",
	cheer    = "ACT_GMOD_TAUNT_CHEER",
	dance    = "ACT_GMOD_TAUNT_DANCE",
	disagree = "ACT_GMOD_GESTURE_DISAGREE",
	forward  = "ACT_SIGNAL_FORWARD",
	group    = "ACT_SIGNAL_GROUP",
	halt     = "ACT_SIGNAL_HALT",
	laugh    = "ACT_GMOD_TAUNT_LAUGH",
	muscle   = "ACT_GMOD_TAUNT_MUSCLE",
	pers     = "ACT_GMOD_TAUNT_PERSISTENCE",
	wave     = "ACT_GMOD_GESTURE_WAVE",
	zombie   = "ACT_GMOD_GESTURE_TAUNT_ZOMBIE",
	throw    = "ACT_GMOD_GESTURE_ITEM_THROW",
	place    = "ACT_GMOD_GESTURE_ITEM_PLACE",
	give     = "ACT_GMOD_GESTURE_ITEM_GIVE",
	drop     = "ACT_GMOD_GESTURE_ITEM_DROP",
	shove    = "ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND",
	frenzy   = "ACT_GMOD_GESTURE_RANGE_FRENZY",
	attack   = "ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL",
	melee    = "ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE",
	melee2   = "ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2",
	poke     = "ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM",
	fist     = "ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST",
	stab     = "ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE",
}

for k, v in next, gestures do
	local id = _G[v]
	gestures[k] = {
		name = v,
		id = id
	}
end
local function gestureByID(id)
	for name, gesture in next, gestures do
		if gesture.id == id then return { name = name, gesture = gesture } end
	end
end

local function act(ply, _, args, line)
	if CLIENT then
		RunConsoleCommand("cmd", "act", unpack(args))
	end

	local name = args[1]
	local data = gestures[name]
	if not data then return end

	act_extended = true
	if hook.Run("PlayerShouldTaunt", ply, id) == false then
		act_extended = false
		return
	end
	act_extended = false

	ply:DoAnimationEvent(data.id)

end
local function autoComplete(cmd, args)
	local autoComplete = {}

	for name in next, gestures do
		if name:match(args:Trim():lower()) then
			autoComplete[#autoComplete + 1] = cmd .. " " .. name
		end
	end

	return autoComplete
end
concommand.Add("actx", act, autoComplete) -- Meta compatibility

if SERVER then
	hook.Add("PlayerShouldTaunt", "act_extended", function(ply, id)
		if not act_extended then
			ply:ConCommand("actx " .. tostring(gestureByID(id).name))
			return false
		end
	end)

	return
end

local add = {
	"place",
	"give",
	"drop",
	"shove",
	"frenzy",
	"attack",
	"melee",
	"melee2",
	"poke",
	"fist",
	"stab",
}
hook.Add("PopulateMenuBar", "act_extended", function(bar)
	if not gmc then return end

	timer.Simple(0, function()
		gmc.Menu:AddSpacer()

		local extra, option = gmc.Menu:AddSubMenu("Extra")
		option:SetIcon("icon16/add.png")
		extra:SetDeleteSelf(false)

		for _, name in next, add do
			extra:AddOption(name:sub(1, 1):upper() .. name:sub(2), function()
				RunConsoleCommand("actx", name)
			end)
		end
	end)
end)

