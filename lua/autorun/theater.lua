
local tag = "theater"

local reload = theater and theater.Screen
theater = { Screen = reload }

theater.Locations = {
	gm_bluehills_test3 = {
		offset = Vector(0, 0, 0),
		angle  = Angle(-90, 90, 0),
		height = 352,
		width  = 704,
		mins   = Vector(353, 81, -35),
		maxs   = Vector(1184, 1184, 434),
		mpos   = Vector(416.03125, 1175.3011474609, 351.95498657227),
		mang   = Angle(0, -90, 0),
	},
	["gm_abstraction_ex-sunset"] = {
		offset = Vector(0, 0, 0),
		angle  = Angle(-90, 90, 0),
		height = 200,
		width  = 320,
		mins   = Vector(-764, -2142, 0),
		maxs   = Vector(-145, -1507, 914),
		mpos   = Vector(-720, -2080, 249),
		mang   = Angle(0, 0, 0),
	},
	redream_waterlands = {
		offset = Vector(0, 0, 0),
		angle  = Angle(-90, -90, 0),
		height = 232,
		width  = 412,
		mins   = Vector(4752.1904296875, 9023.96875, -160.29290771484),
		maxs   = Vector(5320.71875, 8122.2255859375, -661.05981445312),
		mpos   = Vector(4822.17578125, 9022.96875, -168.15637207031),
		mang   = Angle(180, 90, 0),
	},
}

theater.Locations["gm_abstraction_ex-night"] = theater.Locations["gm_abstraction_ex-sunset"]

local l
for map, _ in next, theater.Locations do
	local match = game.GetMap():match(map)
	if match and (not l or #l < #match) then
		l = match
	end
end
l = theater.Locations[l]
if not l then
	theater.Spawn = function() ErrorNoHalt("No theater location for this map! " .. game.GetMap() .. "\n") end

	return
end

local ENT = {}
ENT.ClassName = "theater_screen"
ENT.PrintName = "Theater Screen"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Base = "mediaplayer_base"
ENT.Type = "point"

ENT.PlayerConfig = l
ENT.IsMediaPlayerEntity = true

if SERVER then
	local box = ents.FindInBox

	function ENT:Initialize()
		local mp = self:InstallMediaPlayer("entity")

		function mp:UpdateListeners()
			local listeners = {}
			for _, v in ipairs(box(l.mins, l.maxs)) do
				if v:IsPlayer() then
					listeners[#listeners + 1] = v
				end
			end

			self:SetListeners(listeners)
		end
	end
end
scripted_ents.Register(ENT, ENT.ClassName)

local i = 0
if CLIENT then
	hook.Add("GetMediaPlayer", "theater", function()
		local ply = LocalPlayer()

		if ply:GetPos():WithinBox(l.mins, l.maxs) then
			local ent = ents.FindByClass("theater_screen")[1]

			if ent then
				return MediaPlayer.GetByObject(ent)
			end
		end
	end)
else
	function theater.Spawn()
		if IsValid(theater.Screen) then
			theater.Screen:Remove()
		end

		theater.Screen = ents.Create("theater_screen")
		local screen = theater.Screen
		local pos, ang = l.mpos, l.mang
		pos = pos + ang:Forward() * 1
		screen:SetPos(pos)
		screen:SetAngles(ang)
		screen:SetMoveType(MOVETYPE_NONE)
		screen:Spawn()
		screen:Activate()

		return screen
	end
	local function Hook()
		theater.Spawn() -- DON'T RETURN
	end

	if reload then theater.Spawn() end
	hook.Add("InitPostEntity", "theater", Hook)
	hook.Add("PostCleanupMap", "theater", Hook)
end

