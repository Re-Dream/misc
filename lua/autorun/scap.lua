--
if SERVER then
	util.AddNetworkString("ccap_data")
	util.AddNetworkString("scap_data")
	util.AddNetworkString("ccap_seen")
	util.AddNetworkString("scap_seen")
	net.Receive("ccap_data",function(len,ply)
		local recipient = net.ReadString()
		local data = net.ReadData(1024*1024)
		net.Start("scap_data")
		net.WriteString(ply:SteamID())
		net.WriteData(data,string.len(data))
		net.Send(player.GetBySteamID(recipient))
	end)
	
	net.Receive("ccap_seen",function(len,ply)
		net.Start("scap_seen")
		net.WriteString(ply:SteamID())
		net.Send(player.GetBySteamID(net.ReadString()))
	end)
end

if CLIENT then
	
	local scapq = {}
	
	local function CreateFont()
		
		surface.CreateFont( "NotiFont", {
			font = "Roboto Cn",
			extended = true,
			size = 60,
			weight = 800,
			antialias = true
		})

		surface.CreateFont( "NotiFontSmall", {
			font = "Roboto Cn",
			extended = true,
			size = 40,
			weight = 800,
			antialias = true
		})
	end
    CreateFont() -- create font twice just in case   
    
    net.Receive( "scap_data", function()
    	local s = net.ReadString()
    	local d = util.Decompress(net.ReadData(1024*1024))
    	table.insert(scapq,{s,d})
    end)

    net.Receive("scap_seen",function()
    	local ply = player.GetBySteamID(net.ReadString())
    	chat.AddText(Color(255,255,255),ply:GetName(),Color(0,100,0)," opened your scap!")
    end)

    local f4 = true

    hook.Add("Think","f4check",function()
    	if(not input.IsButtonDown( KEY_F4 ) and f4 == false)then
    		f4 = true
    	end
    end)

    hook.Add("PlayerButtonDown","scapcheck",function(ply,butt)
    	if(butt == KEY_F4 and table.Count(scapq) != 0 and f4)then
    		f4 = false

    		local playr = player.GetBySteamID(scapq[1][1])
    		local data = scapq[1][2]

    		net.Start("ccap_seen")
    		net.WriteString(scapq[1][1])
    		net.SendToServer()

    		local Frame = vgui.Create( "DFrame" )
    		Frame:SetSize( 500, 500 )
    		Frame:Center()
    		Frame:SetTitle("Capture from "..playr:GetName())
    		Frame:MakePopup()
    		Frame:SetDeleteOnClose(true)
    		Frame.OnClose = function()
    			table.remove(scapq,1)
    		end

    		local butt = vgui.Create( "DButton", Frame )
    		butt:SetText("Save!")
    		butt.DoClick = function()

    			file.CreateDir("captures")
    			local fstr = SysTime()..playr:SteamID64()
    			print(fstr)			
    			local f = file.Open( "captures/"..fstr..".jpg", "wb", "DATA" )

    			f:Write( data )
    			f:Close()

    			chat.AddText(Color(0,100,0),"Image saved! Check your",Color(255,255,255)," GarrysMod/garrysmod/data/captures ",Color(0,100,0),"folder!")
    		end

    		local img = vgui.Create( "DHTML", Frame )

    		img:SetPos( -2, 21 )
    		img:SetSize( 500, 500 )

    		img:AddFunction('gmod','size',function(w,h)
    			Frame:SetSize(math.Clamp(w+12,30,ScrW()),math.Clamp(h+69,45,ScrH()))
    			img:SetSize(math.Clamp(w+18,20,ScrW()),math.Clamp(h+20,20,ScrH()))
    			Frame:Center()
    			butt:SetSize(Frame:GetWide()-10,30)
    			butt:SetPos(5,Frame:GetTall()-35)
    		end)
    		img:SetHTML('<body style="overflow:hidden"><img src="data:image/jpeg;base64,'..util.Base64Encode(data)..'" onload="gmod.size(this.width,this.height)"></body>')
    	end
    end)

    hook.Add("PostRenderVGUI","showcap",function()
    	if(table.Count(scapq) != 0)then
    		draw.DrawText( "New capture from "..player.GetBySteamID(scapq[1][1]):GetName().."!", "NotiFont", ScrW()/2, 50, Color( 255, 255, 170, 255 ), TEXT_ALIGN_CENTER )
    		draw.DrawText( "Press F4 to view!", "NotiFontSmall", ScrW()/2, 110, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    	end
    end)

    function selectcapt(recipient)
    	local pressed = false
    	local x1 = 0
    	local x2 = 0
    	local y1 = 0
    	local y2 = 0
    	local done = false
    	local mat_Screen = Material( "pp/fb" )
    	local a = 255

    	hook.Add("PostRenderVGUI","selectcapt",function()
    		render.UpdateScreenEffectTexture()
    		hook.Add("RenderScene","cancerscene",function()
    			cam.Start2D()					
    			render.SetMaterial( mat_Screen )
    			render.DrawScreenQuad()
    			cam.End2D()
    			if(not done)then
    				return true
    			end
    		end)
    		surface.SetDrawColor( Color( 0, 0, 0, 50 ) )
    		surface.DrawRect(0,0,ScrW(),ScrH())
    		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
    		surface.DrawOutlinedRect(0,0,ScrW(),ScrH())
    		surface.DrawOutlinedRect(1,1,ScrW()-2,ScrH()-2)
    		draw.DrawText( "Click and drag to select, right click to send", "NotiFont", ScrW()/2, 50, Color( 200, 200, 200, a ), TEXT_ALIGN_CENTER )
    		draw.DrawText( "Escape to cancel", "NotiFontSmall", ScrW()/2, 110, Color( 220, 220, 220, a ), TEXT_ALIGN_CENTER )
    		gui.EnableScreenClicker(true)
    		if(input.IsButtonDown(MOUSE_LEFT))then
    			if(pressed == false)then
    				x1,y1 = gui.MousePos()
    			end
    			pressed = true
    			x2,y2 = gui.MousePos()
    		end
    		if(not input.IsButtonDown(MOUSE_LEFT))then
    			pressed = false
    		end
    		surface.DrawOutlinedRect(x1,y1,x2-x1,y2-y1)
    		if(input.IsButtonDown(KEY_ESCAPE))then
    			RunConsoleCommand("cancelselect")
    			hook.Remove("PostRenderVGUI","selectcapt")
    			done = true
    			gui.EnableScreenClicker(false)
    		end
    		if(input.IsButtonDown(MOUSE_RIGHT) and not(x2 - x1 == 0 or y2 - y1 == 0))then
    			a = 0
    			done = true
    			local x = x1
    			local y = y1
    			local wide = x2-x1
    			local tall = y2-y1

    			if(wide <0)then
    				x = x2-1
    				wide = (x1-x2)+2
    			end
    			if(tall <0)then
    				y = y2-1
    				tall = (y1-y2)+2
    			end

    			hook.Remove("PostRenderVGUI","selectcapt")
    			if(table.Count(recipient) == 0)then
    				capture(x,y,wide,tall,"")
    			else
    				capture(x,y,wide,tall,recipient[1])
    			end
    		end
    	end)
    end

    function capture(x,y,w,h,recipient)
    	cdata = render.Capture({
    		format = "jpeg",
    		quality = 70,
    		h = math.Clamp(h,40,ScrH()),
    		w = math.Clamp(w,40,ScrW()),
    		x = math.Clamp(x,0,ScrW()),
    		y = math.Clamp(y,0,ScrH()),
    	})
    	local compdata = util.Compress(cdata)
    	if(#compdata > 63978)then
    		chat.AddText(Color(255,0,0),"Image too big to send! select a smaller area!")
    		gui.EnableScreenClicker(false)
    		return
    	end
    	if(recipient == "")then
    		playerselect(compdata)
    	else
    		net.Start("ccap_data")
    		net.WriteString(recipient)
    		net.WriteData(compdata,#compdata)
    		net.SendToServer()
    		chat.AddText(Color(0,100,0),"Image sent to ",Color(255,255,255),player.GetBySteamID(recipient):GetName(),Color(0,100,0),"!")
    		gui.EnableScreenClicker(false)
    	end
    end

    function playerselect(dat)

    	local fram = vgui.Create( "DFrame" )
    	fram:SetSize( 200, 250 )
    	fram:Center()
    	fram:SetTitle( "Select player(s)" )
    	fram:SetDraggable( true )
    	fram:SetDeleteOnClose(true)
    	fram:MakePopup()

    	local plist = vgui.Create( "DListView", fram )
    	plist:SetSize(fram:GetWide()-8,fram:GetTall()-66)
    	plist:Dock( TOP )
    	plist:SetMultiSelect( true )
    	plist:AddColumn( "Players" )
    	for k,v in pairs(player.GetAll())do
    		plist:AddLine(v:GetName(),v:SteamID())
    	end

    	local butt = vgui.Create( "DButton", fram ) 
    	butt:SetText( "Select" )
    	butt:SetPos( 4, fram:GetTall()-34 )
    	butt:SetSize( fram:GetWide()-8, 30 )
    	butt.DoClick = function()

    		local tbl = {}
    		local rstr = ""
    		local alt = ""
    		if(table.Count(plist:GetSelected()) > 0)then
    			fram:Close()
    			for k,v in pairs(plist:GetSelected()) do
    				table.insert(tbl,v:GetValue(2))
    			end

    			for k,v in pairs(tbl) do
    				net.Start("ccap_data")
    				net.WriteString(v)
    				net.WriteData(dat,#dat)
    				net.SendToServer()
    				rstr = rstr.."\n"..player.GetBySteamID(v):GetName()
    				alt = player.GetBySteamID(v):GetName()
    				gui.EnableScreenClicker(false)
    			end
    			if(table.Count(tbl)!=1)then
    				chat.AddText(Color(0,100,0),"Image sent to: ",Color(255,255,255),rstr)
    			else
    				chat.AddText(Color(0,100,0),"Image sent to ",Color(255,255,255),alt,Color(0,100,0),"!")
    			end
    		end
    	end
    end

    hook.Add("OnPlayerChat","commandHook",function(ply,text)
    	local txt = string.Left(string.lower( text ),5)
    	if (txt == "!scap" or txt == ".scap" or txt == "/scap") and (ply == LocalPlayer()) then
    		local playername = string.sub(text,7,string.len(text))
    		if(string.len(playername) > 0)then
    			for _,ply in pairs(player.GetHumans()) do
    				if ply:Nick():lower():find(playername,1,true)==1 then
    					selectcapt({ply:SteamID()})
    				end
    			end
    		else
    			selectcapt({})
    		end
    	end
    end)
    concommand.Add("scap",function(ply,cmd,ta,args)
    	if (args != "")then
    		for _,ply in pairs(player.GetHumans()) do
    			if ply:Nick():lower():find(args,1,true)==1 then
    				RunConsoleCommand("cancelselect")
    				selectcapt({ply:SteamID()})
    			end
    		end
    	else
    		RunConsoleCommand("cancelselect")
    		selectcapt({})
    	end
    end)
end
