if not SERVER then return end

local tag = 'seen'
seen = {}

seen.Init = function()
	sql.Query[[CREATE TABLE IF NOT EXISTS seen(name TEXT, steamid TEXT, lastseen TEXT)]]
end
seen.Init()

seen.Remove = function(steamid)
	return sql.Query(([[DELETE FROM seen WHERE steamid = %s]]):format(
		sql.SQLStr(steamid)
	))
end

seen.Add = function(name, steamid, lastseen)
	lastseen = lastseen or os.date('%m/%d/%Y at %H:%M', os.time())

	seen.Remove(steamid)
	return sql.Query(([[INSERT OR REPLACE INTO seen(name, steamid, lastseen) VALUES(%s, %s, %s)]]):format(
			sql.SQLStr(name),
			sql.SQLStr(steamid),
			sql.SQLStr(lastseen)
		))
end

seen.Get = function(name)
	return sql.Query(
		([[SELECT * FROM seen WHERE name LIKE '%%%s%%']]):format(
			sql.SQLStr(name):Trim([[']])
		))
end

seen.Compute = function(name, limit)
	limit = limit or 5
	local str = ''
	local data = table.Copy(seen.Get(name))
	if not data or type(data) ~= 'table' then
		return ([[Sorry, I haven't seen %s around.]]):format(name)
	end
	
	for i = 1, #data do
		if i == limit then break end

		local data = data[i]
		local rank = mingeban.users.superadmin[data.steamid] or mingeban.users.admin[data.steamid] and 'Admin' or 'Player'
		str = str .. '\n' .. ([[%s %s was last seen on %s]]):format(rank, data.name, data.lastseen)
	end

	return str:TrimLeft('\n')
end

hook.Add('player_disconnect', tag, function(data)
	if data.bot == 1 then return end

	seen.Add(data.name, data.networkid)
end)

mingeban.CreateCommand(tag, function(caller, line)
	local ply = easylua and easylua.FindEntity(line) or Entity(-1) -- uhh, maybe will change in future???

	if IsValid(ply) and type(ply) == 'Player' then ChatAddText(Color(100, 101, 255), ply:Name(), ' is currently online.') return end

	ChatAddText(Color(100, 101, 255), seen.Compute(line))
end)
