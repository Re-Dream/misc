if SERVER then
	util.AddNetworkString("ccap_data")
	util.AddNetworkString("scap_data")
	net.Receive("ccap_data",function(len,ply)
		local recipient = net.ReadString()
		local data = net.ReadData(1024*1024)
		net.Start("scap_data")
		net.WriteString(ply:SteamID())
		net.WriteData(data,string.len(data))
		net.Send(player.GetBySteamID(recipient))
	end)
end

if CLIENT then
	
	local scapq = {}
	
	local function CreateFont()
	    surface.CreateFont( "NotiFont", {
	    font = "Roboto Cn",
	    extended = true,
	    size = 60,
	    weight = 500,
	    antialias = true
    } )
    end
    CreateFont() -- create font twice just in case
    
	net.Receive( "scap_data", function()
		local s = net.ReadString()
		local d = util.Decompress(net.ReadData(1024*1024))
		table.insert(scapq,{s,d})
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
			local Frame = vgui.Create( "DFrame" )
			Frame:SetSize( 500, 500 )
			Frame:Center()
			Frame:SetTitle("Capture from "..playr:GetName())
			Frame:MakePopup()
			Frame:SetDeleteOnClose(true)
			
			local butt = vgui.Create( "DButton", Frame )
			butt:SetText("Save!")
			butt.DoClick = function()
				
				if(file.Exists( "CAPTURE.jpg", "DATA" ))then
					file.Delete("CAPTURE.jpg")
				end
				
				local f = file.Open( "CAPTURE.jpg", "wb", "DATA" )
				
				f:Write( data )
				f:Close()
				
				chat.AddText(Color(0,100,0),"Image saved! Check your",Color(255,255,255)," GarrysMod/garrysmod/data ",Color(0,100,0),"folder!")
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
	    	table.remove(scapq,1)
		end
	end)
	
	hook.Add("PostRenderVGUI","showcap",function()
		if(table.Count(scapq) != 0)then
			draw.DrawText( "New capture from "..player.GetBySteamID(scapq[1][1]):GetName().."! Press F4 to view!", "NotiFont", ScrW()/2, 50, Color( 255, 255, 170, 255 ), TEXT_ALIGN_CENTER )
		end
	end)
	
	function selectcapt(recipient)
		local pressed = false
		local x1 = 0
		local x2 = ScrW()
		local y1 = 0
		local y2 = ScrH()
		local done = false
		local mat_Screen = Material( "pp/fb" )
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
			draw.DrawText( "Click and drag to select, right click to cancel", "NotiFont", ScrW()/2, 50, Color( 200, 200, 200, 255 ), TEXT_ALIGN_CENTER )
			gui.EnableScreenClicker(true)
			if(input.IsButtonDown(MOUSE_LEFT))then
				if(pressed == false)then
					x1,y1 = gui.MousePos()
				end
				pressed = true
				x2,y2 = gui.MousePos()
			end
			surface.DrawOutlinedRect(x1,y1,x2-x1,y2-y1)
			if(input.IsButtonDown(MOUSE_RIGHT))then
				done = true
				hook.Remove("PostRenderVGUI","selectcapt")
				gui.EnableScreenClicker(false)
			end
			if(not input.IsButtonDown(MOUSE_LEFT) and pressed == true)then
				
				local capt = capture(x1,y1,x2-x1,y2-y1,recipient)
				if(capt == true)then
					done = true
					hook.Remove("PostRenderVGUI","selectcapt")
					gui.EnableScreenClicker(false)
				else
					chat.AddText(Color(255,0,0),"Image too big to send! select a smaller area!")
					done = true
					hook.Remove("PostRenderVGUI","selectcapt")
					gui.EnableScreenClicker(false)
				end
			end
		end)
	end
	
	function capture(x,y,w,h,recipient)
		cdata = render.Capture({
			format = "jpeg",
			quality = 70,
			h = h,
			w = w,
			x = x,
			y = y,
		})
		local compdata = util.Compress(cdata)
		if(#compdata > 63978)then return false end
		net.Start("ccap_data")
		net.WriteString(recipient)
		net.WriteData(compdata,#compdata)
		net.SendToServer()
		chat.AddText(Color(0,100,0),"Image sent to "..player.GetBySteamID(recipient):GetName().."!")
		return true
	end
	
	function playerselect()
		local fram = vgui.Create( "DFrame" )
		fram:SetSize( 200, 250 )
		fram:Center()
		fram:SetTitle( "Select player" )
		fram:SetDraggable( true )
		fram:SetDeleteOnClose(true)
		fram:MakePopup()
		
		local plist = vgui.Create( "DListView", fram )
		plist:SetSize(fram:GetWide()-8,fram:GetTall()-66)
		plist:Dock( TOP )
		plist:SetMultiSelect( false )
		plist:AddColumn( "Player" )
		for k,v in pairs(player.GetAll())do
			plist:AddLine(v:GetName(),v:SteamID())
		end
		
		local butt = vgui.Create( "DButton", fram ) 
		butt:SetText( "Select" )
		butt:SetPos( 4, fram:GetTall()-34 )
		butt:SetSize( fram:GetWide()-8, 30 )
		butt.DoClick = function()
			fram:Close()
			selectcapt(plist:GetSelected()[1]:GetValue(2))
		end
	end
	
	hook.Add("OnPlayerChat","commandHook",function(ply,text)
		local txt = string.Left(string.lower( text ),5)
		if(txt == "!scap" or txt == ".scap" or txt == "/scap" and ply == LocalPlayer()) then
			local playername = string.sub(text,7,string.len(text))
			if(string.len(playername) > 0)then
				for _,ply in pairs(player.GetHumans()) do
					if ply:Nick():lower():find(playername,1,true)==1 then
						selectcapt(ply:SteamID())
					end
				end
			else
				playerselect()
			end
		end
	end)
end
