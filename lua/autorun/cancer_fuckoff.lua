
hook.Add("EntityEmitSound", "drown_fuckoff", function(data)
	local ent = data.Entity
	local snd = data.OriginalSoundName
	if not IsValid(ent) or not ent:IsPlayer() then return end
	if ent:WaterLevel() < 1 and snd == "Player.DrownStart" then return false end
end)

if SERVER then
	concommand.Remove("rb655_playsound_all")
end

