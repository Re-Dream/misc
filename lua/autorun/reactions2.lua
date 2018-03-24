--
react = {}

if SERVER then
	util.AddNetworkString("R2_sendlist")
	util.AddNetworkString("R2_requestlist")
	util.AddNetworkString("R2_reaction")

	local dat = util.JSONToTable(file.Read("addons/misc/lua/autorun/reactions.json","GAME"))
	net.Receive("R2_requestlist",function(_,ply)
		net.Start("R2_sendlist")
		net.WriteTable(dat)
		net.Send(ply)
	end)
	net.Receive("R2_reaction",function(_,ply)
		local url = net.ReadString()
		local web = net.ReadBool()
		if(url == nil or web == nil)then
			return
		end
		net.Start("R2_reaction")
		net.WriteString(url)
		net.WriteBool(web)
		net.WriteEntity(ply)
		net.Broadcast()
	end)
end

if CLIENT then

	react.Reactions = {}

	net.Receive("R2_sendlist",function()
		react.Emotes = net.ReadTable()
		react.PopulateMenu()
	end)

	net.Receive("R2_reaction",function()
		local path = net.ReadString()
		local web = net.ReadBool()
		local ply = net.ReadEntity()
		print(path)
		if web then
			path = react.WebMaterial(path)
		end
		print(path)
		react.Reactions[ply] = {path = path,web = web,time = SysTime()}
		timer.Create(ply:SteamID(),7,1,function()
			react.Reactions[ply] = nil
		end)
		PrintTable(react.Reactions)
	end)

	local magicNumbers = {
		png = string.char(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A),
		jpg = string.char(0xFF, 0xD8, 0xFF, 0xDB)
	}

	react.WebMaterial = function(url)
		local filename = url:Split('/')
		filename = filename[#filename]:match('(.*)%.') .. '.png'
		file.CreateDir('webmaterial')
		MsgC('[WebMaterial] ') print('Fetching ', url)
		http.Fetch(url, function(body, len, headers, code)
			if not body:match('^' .. magicNumbers.png) and not body:match('^' .. magicNumbers.jpg) then return MsgC('[WebMaterial] '), print('Unsupported image format') end
			if code < 200 or code >= 400 then return MsgC('[WebMaterial] '), print('Issues fetching ', url) end
			MsgC('[WebMaterial] ') print('Successfully fetched ', url)
			file.Write('webmaterial/' .. filename, body)
			
		end)
		return "../data/webmaterial/"..filename
	end

	react.PopulateMenu = function()
		local CategoryTabs = vgui.Create("DPropertySheet",react.Menu)
		CategoryTabs:Dock(FILL)

		local size = (react.Menu:GetWide()/5)-5
		for k,v in pairs(react.Emotes) do
			local x = 0
			local y = 0
			local ScrollPanel = vgui.Create("DScrollPanel",CategoryTabs)
			ScrollPanel:Dock(FILL)
			if(v.files != nil)then
				for k,v in pairs(v.files)do
					local butt = ScrollPanel:Add("DButton")
					butt:SetText("")
					butt:SetImage(v)
					butt:SetSize(size,size)
					butt:SetPos(x,y)
					butt.DoClick = function()
						react.SendReaction(v,false)
					end
					x=x+size
					if(x==react.Menu:GetWide()-25)then
						x=0
						y=y+size
					end
				end
			end
			if(v.urls != nil)then
				for k,v in pairs(v.urls)do
					local butt = ScrollPanel:Add("DButton")
					butt:SetText(v)
					--butt:SetImage(v)
					butt:SetSize(size,size)
					butt:SetPos(x,y)
					butt.DoClick = function()
						react.SendReaction(v,true)
					end
					x=x+size
					if(x==react.Menu:GetWide()-25)then
						x=0
						y=y+size
					end
				end
			end
			CategoryTabs:AddSheet(k,ScrollPanel)
		end
	end

	react.CreateMenu = function()
		react.Menu = vgui.Create("DFrame")
		react.Menu:SetTitle("Reactions")
		react.Menu:SetSize(400,600)
		react.Menu:SetDeleteOnClose(false)
		react.Menu:SetScreenLock(true)
		react.Menu:Center()
		react.Menu:Hide()
		net.Start("R2_requestlist")
		net.SendToServer()
	end
	react.CreateMenu()

	react.OpenMenu = function()
		if(not IsValid(react.Menu))then
			react.CreateMenu()
		end

		react.Menu:Show()
		react.Menu:MakePopup()
	end

	react.SendReaction = function(path,web)
		net.Start("R2_reaction")
		net.WriteString(path)
		net.WriteBool(web)
		net.SendToServer()
	end

	hook.Add("PostDrawTranslucentRenderables", "Reactions", function()
		for k,v in pairs(react.Reactions) do
			render.SetMaterial(Material(v.path))
			local timeex = SysTime()-v.time
			local spos,ang = k:GetBonePosition(k:LookupBone("ValveBiped.Bip01_Head1"))
			ang2 = ang:Right():Angle():Forward()
			render.DrawQuadEasy(((ang:Forward()*3)+(ang2*7)+spos),ang2, 8, 8, Color(255, 255, 255, math.Clamp(255-(timeex-4)*255,0,255)),180)
		end
	end)
end