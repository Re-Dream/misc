
if CLIENT then return end

local maps = {
	gm_flatgrass = function()
		local function SpawnScreenProp()
			local ent = ents.Create("prop_physics")
			ent:SetPos(Vector(939.50805664062, 34.173225402832, -12223.96875))
			ent:SetAngles(Angle(90, 180, 180))
			ent:SetModel("models/hunter/plates/plate3x4.mdl")
			ent:SetMaterial("models/props/de_inferno/woodfloor008a")
			ent.PhysgunDisabled = true
			ent.m_tblToolsAllowed = {}
			function ent:CanConstruct() return false end
			function ent:CanTool() return false end
			ent.ScreenProp = true
			ent:Spawn()
			local gpo = ent:GetPhysicsObject()
			if IsValid(gpo) then
				gpo:EnableMotion(false)
			end
		end

		hook.Add("InitPostEntity", "gm_flatgrass_screenprop", SpawnScreenProp)
		hook.Add("PostCleanupMap", "gm_flatgrass_screenprop", SpawnScreenProp)
	end
}

local map = game.GetMap()
if maps[map] then
	maps[map]()
end

