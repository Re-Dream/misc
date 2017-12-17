
local tag = "nicks"

local PLAYER = FindMetaTable("Player")

PLAYER.SteamNick   = PLAYER.SteamNick or PLAYER.Nick
PLAYER.SteamName   = PLAYER.SteamNick or PLAYER.Nick
PLAYER.RealName    = PLAYER.SteamNick or PLAYER.Nick
PLAYER.RealNick    = PLAYER.SteamNick or PLAYER.Nick
PLAYER.GetRealName = PLAYER.SteamNick or PLAYER.Nick
PLAYER.GetRealNick = PLAYER.SteamNick or PLAYER.Nick

function PLAYER:Nick()
	local nick = self:GetNWString("Nick")
	return nick:Trim() == "" and self:RealName() or nick
end
PLAYER.Name = PLAYER.Nick
PLAYER.GetNick = PLAYER.Nick
-- PLAYER.GetName = PLAYER.Nick -- don't override this, SetName sues it

if CLIENT then
	function PLAYER:SetNick(nick)
		self:ConCommand("mingeban nick " .. nick)
	end

	net.Receive(tag, function()
		local ply = Player(net.ReadUInt(16))
		local oldNick = net.ReadString()
		local newNick = net.ReadString()

		if oldNick == newNick then return end

		chat.AddText(team.GetColor(ply:Team()), oldNick, Color(255, 255, 255, 255), " is now called ", team.GetColor(ply:Team()), newNick, Color(255, 255, 255, 255), ".")
	end)
else
	util.AddNetworkString(tag)

	function PLAYER:SetNick(nick)
		if not nick or nick:Trim() == "" then
			self:RemovePData("Nick")
		else
			self:SetPData("Nick", nick)
		end
		self:SetNWString("Nick", nick or "")
	end

	local nextChange = {}
	local nick = mingeban.CreateCommand({"name", "nick"}, function(caller, line)
		if string.len(line) > 32 then return false, "get a better nickname faggot" end
			
		local cd = nextChange[caller:UserID()]
		if cd and cd > CurTime() then
			return false, "You're changing nicks too quickly!"
		end

		local oldNick = caller:Nick()
		caller:SetNick(line)
		net.Start(tag)
			net.WriteUInt  (caller:UserID(), 16)
			net.WriteString(oldNick)
			net.WriteString(caller:Nick())
		net.Broadcast()
		nextChange[caller:UserID()] = CurTime() + 2
	end)

	hook.Add("PlayerInitialSpawn", tag, function(caller)
		if caller:GetPData("Nick") and caller:GetPData("Nick"):Trim() ~= "" then
			caller:SetNick(caller:GetPData("Nick"))
		end
	end)
end


