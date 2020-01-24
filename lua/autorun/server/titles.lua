hook.Add('PlayerAuthed', 'titles', function(ply)
	ply:SetNWString('title', ply:GetPData('title'))
end)
