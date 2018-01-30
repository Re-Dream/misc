
local tag = "hostname"

hostname = {}

if CLIENT then
	function GetHostName()
		return GetGlobalString("ServerName")
	end
else
	local prefix = "Re-Dream: "
	local titles = -- STOP INDENTING IT, IT BREAKS.
[[We do shit better.
:blox:
:sadbarf:
sexual tension
We have blackjack and hookers
GCompute inside
come fuck around
build stupid shit
code stupid shit
make stupid shit
professionalism itself
out of hostnames
pac4 when?
better than outfitter
trust no one, not even the workshop
re-dream.org
re-dream.org
re-dream.org
The Lounge]]
-------------------------------------->            max hostname size i believe

	titles = string.Split(titles, "\n")
	for k, title in next, titles do
		if title:Trim():len() < 1 then
			table.remove(titles, k)
		end
	end
	hostname.Titles = titles

	function hostname.Set(name)
		hostname.StopTimer()
		RunConsoleCommand("hostname", tostring(name))
		SetGlobalString("ServerName", tostring(name))
	end

	function hostname.Pick()
		local name = prefix .. titles[math.random(1, #titles)]
		RunConsoleCommand("hostname", name)
		SetGlobalString("ServerName", name)
	end

	timer.Create(tag, 15, 0, function()
		hostname.Pick()
	end)
	timer.Destroy("HostnameThink")

	function hostname.StartTimer()
		return timer.Start(tag)
	end
	function hostname.StopTimer()
		return timer.Stop(tag)
	end
end

hostname.Get = GetHostName

