
if file.Exists("cfg/workshop_downloads.cfg", "GAME") then
	for _, line in next, file.Read("cfg/workshop_downloads.cfg", "GAME"):Split("\n") do
		resource.AddWorkshop(line:gsub("(//.+)", ""):Trim())
	end
end

local maps = {
	["gm_bluehills_test3"] = 243902601,
	["gm_freespace_09_extended"] = 278492798,
	["gm_freespace_13"] = 115510325,
	["gm_abstraction_ex-night"] = 741592270,
	["gm_abstraction_ex-sunset"] = 740691120,
	["gm_gmall"] = 207060996,
	["gm_excess_island"] = 115250988,
}

for name, id in next, maps do
	if game.GetMap() == name then
		resource.AddWorkshop(id)
	end
end


