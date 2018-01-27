if CLIENT then
	if(GG != nil and IsValid(GG.GameFrame))then
		GG.GameFrame:Close()
	end

	GG = {}
	GG.Games = {}
	GG.Ingame = false
	GG.TitleText = "Main menu"
	GG.TitleColor = Color(255,255,255,255)

	local function CreateFont()
		surface.CreateFont("GGTitleFont",{
			font = "Roboto Cn",
			extended = true,
			size = 20,
			weight = 800,
			antialias = true
		})
	end
	CreateFont() 

	GG.GetWindowPaint = function(panel)
		if(IsValid(panel))then
			return function()
				local h,w = panel:GetTall(),panel:GetWide()
				surface.SetDrawColor(200,200,200,200)
				surface.DrawRect(0,25,w,h-25)

				surface.SetDrawColor(50,50,50,255)
				surface.DrawRect(0,0,w,25)

				surface.SetDrawColor(0,0,0,200)
				surface.DrawOutlinedRect(0,0,w,h)

				draw.SimpleText(GG.TitleText,"GGTitleFont",panel:GetWide()/2,3,GG.TitleColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			end
		end
	end

	GG.GetButtonPaint = function(panel,r,g,b)
		if(IsValid(panel))then
			return function()
				surface.SetDrawColor(r,g,b,255)
				surface.DrawRect(0,0,25,25)
				surface.SetDrawColor(0,0,0,200)
				surface.DrawOutlinedRect(0,0,25,25)
			end
		end	
	end

	GG.AddGame = function(name,func)
		GG.Games[table.Count(GG.Games)] = {name,func}
	end

	GG.OpenMainGameMenu = function()
		GG.Ingame = false
		GG.TitleText = "Main menu"
		GG.TitleColor = Color(255,255,255,255)

		if(IsValid(GG.GameFrame))then
			GG.GameFrame:Close()
		end

		GG.GameFrame = vgui.Create("DFrame")
		GG.GameFrame:SetSize(500,525)
		GG.GameFrame:ShowCloseButton(false)
		GG.GameFrame:Center()
		GG.GameFrame:SetDraggable(false)
		GG.GameFrame:SetScreenLock(true)
		GG.GameFrame:SetTitle("")
		GG.GameFrame:MakePopup()
		local paint = GG.GetWindowPaint(GG.GameFrame)
		GG.GameFrame.Paint = paint

		local CloseButt = vgui.Create("DButton",GG.GameFrame)
		CloseButt:SetPos(0,0)
		CloseButt:SetSize(25,25)
		CloseButt:SetTooltip("Close")
		CloseButt:SetText("")
		CloseButt.Paint = GG.GetButtonPaint(CloseButt,255,0,0)
		CloseButt.DoClick = function()
			CloseButt:GetParent():Close()
		end

		local butts = {}

		for k,v in pairs(GG.Games)do
		local butt = vgui.Create("DButton",GG.GameFrame) --make a button for the current game in for
		butt:SetSize(50,50)
		butt:SetText(v[1])
		butt:SetPos(k*50,25)
		butt:SetTooltip(v[1])

		butt.DoClick = function()

			for k,v in pairs(butts)do --remove all buttons
				v:Remove()
			end
			butts = {}

			local bbutt = vgui.Create("DButton",GG.GameFrame) --make a 'back to menu' button
			bbutt:SetPos(25,0)
			bbutt:SetSize(25,25)
			bbutt:SetText("")
			bbutt:SetTooltip("Back to menu")
			bbutt.Paint = GG.GetButtonPaint(bbutt,0,255,0)
			bbutt.DoClick = function()
				GG.GameFrame:Close()
				GG.OpenMainGameMenu()
				bbutt:Remove()
			end

			GG.Games[k][2](GG.Games[k]) --start game
			GG.Ingame = true
		end
		butts[v[1]] = butt
	end
end

GG.AddGame("Game of Life",function(tbl)
	GG.GameFrame:SetSize(600,625)
	GG.GameFrame:Center()
	GG.TitleText = "Game of Life"
	GG.TitleColor = Color(100,255,100,255)

	tbl.Paused = false

	local celltbl = {}

	local clearbutt = vgui.Create("DButton",GG.GameFrame)
	clearbutt:SetPos(75,0)
	clearbutt:SetSize(25,25)
	clearbutt:SetText("")
	clearbutt:SetTooltip("Clear")
	clearbutt.Paint = GG.GetButtonPaint(clearbutt,0,0,255)
	clearbutt.DoClick = function()
		for k,v in pairs(celltbl)do
			v.alive = false
			v.setalive = false
			v.setdead = false
			tbl.Paused = false
			GG.TitleText = "Game of Life"
			GG.TitleColor = Color(100,255,100,255)
		end
	end

	local pausebutt = vgui.Create("DButton",GG.GameFrame)
	pausebutt:SetPos(100,0)
	pausebutt:SetSize(25,25)
	pausebutt:SetText("")
	pausebutt:SetTooltip("Pause")
	pausebutt.Paint = GG.GetButtonPaint(pausebutt,255,0,255)
	pausebutt.DoClick = function()
		if(!tbl.Paused)then
			tbl.Paused = true
			GG.TitleText = "Game of Life (PAUSED)"
			GG.TitleColor = Color(255,100,100,255)
		elseif(tbl.Paused)then
			tbl.Paused = false
			GG.TitleText = "Game of Life"
			GG.TitleColor = Color(100,255,100,255)

			for k,v in pairs(celltbl)do
				local neighbours = tbl.GetAliveNeighbours(v)
				if(v.alive and neighbours < 2)then
					v.setdead = true
				elseif(v.alive and neighbours > 3)then
					v.setdead = true
				elseif(!v.alive and neighbours == 3)then
					v.setalive = true
				end
			end
		end
	end

	for xx=0,GG.GameFrame:GetWide()-25,25 do
		for yy=25,GG.GameFrame:GetTall(),25 do
			celltbl[table.Count(celltbl)] = {alive=false,x=xx,y=yy,num = table.Count(celltbl),setalive = false,setdead = false}
		end
	end

	tbl.GetAliveNeighbours = function(cell)
		local neighbours = {celltbl[cell.num-26],
		celltbl[cell.num-25],
		celltbl[cell.num-24],
		celltbl[cell.num-1],
		celltbl[cell.num+1],
		celltbl[cell.num+24],
		celltbl[cell.num+25],
		celltbl[cell.num+26]}
		if(cell.x == 0)then
			neighbours[1] = nil
			neighbours[2] = nil
			neighbours[3] = nil
		end
		if(cell.y == 25)then
			neighbours[1] = nil
			neighbours[4] = nil
			neighbours[6] = nil
		end
		if(cell.x == 575)then
			neighbours[6] = nil
			neighbours[7] = nil
			neighbours[8] = nil
		end
		if(cell.y == 600)then
			neighbours[3] = nil
			neighbours[5] = nil
			neighbours[8] = nil
		end
		for k,v in pairs(neighbours)do
			if (!v.alive) then
				neighbours[k] = nil
			end
		end
		return table.Count(neighbours)
	end

	local last = 0
	GG.GameFrame.PaintOver = function()
		local delay = 0.5
		if (CurTime() - last > delay and !tbl.Paused) then
			for k,v in pairs(celltbl)do
				if(v.setalive)then
					v.alive = true
				end
				if(v.setdead)then
					v.alive = false
				end
				v.setalive = false
				v.setdead = false
			end
			for k,v in pairs(celltbl)do
				local neighbours = tbl.GetAliveNeighbours(v)
				if(v.alive and neighbours < 2)then
					v.setdead = true
				elseif(v.alive and neighbours > 3)then
					v.setdead = true
				elseif(!v.alive and neighbours == 3)then
					v.setalive = true
				end
			end
			last = CurTime()
		end
		for k,v in pairs(celltbl)do
			local c = 0
			if(v.alive)then
				c=255
			end
			surface.SetDrawColor(c,c,c,255)
			surface.DrawRect(v.x,v.y,25,25)
		end
		if(input.IsButtonDown(MOUSE_LEFT))then
			local mx,my = gui.MousePos()
			local wx,wy = GG.GameFrame:GetPos()
			local ww,wt = GG.GameFrame:GetSize()
			mx = mx-wx
			my = my-wy

			if((mx > 0 and my > 25) and (mx < ww and my < wt))then
				local x = math.Clamp(math.ceil((mx-25)/25)*25,0,GG.GameFrame:GetWide()-25)
				local y = math.Clamp(math.ceil((my-25)/25)*25,25,GG.GameFrame:GetTall()-25)
				for k,v in pairs(celltbl) do
					if(v.x == x and v.y == y)then
						local neighbours = tbl.GetAliveNeighbours(v)
						v.alive = true
					end
				end
			end
		elseif(input.IsButtonDown(MOUSE_RIGHT))then
			local mx,my = gui.MousePos()
			local wx,wy = GG.GameFrame:GetPos()
			local ww,wt = GG.GameFrame:GetSize()
			mx = mx-wx
			my = my-wy

			if((mx>0 or mx<ww) and (my>0 or my<wt))then
				local x = math.Clamp(math.ceil((mx-25)/25)*25,0,GG.GameFrame:GetWide()-25)
				local y = math.Clamp(math.ceil((my-25)/25)*25,25,GG.GameFrame:GetTall()-25)
				for k,v in pairs(celltbl) do
					if(v.x == x and v.y == y)then
						v.alive = false
					end
				end
			end
		end
	end
end)

concommand.Add("gg",function(ply,cmd,ta,args)
	RunConsoleCommand("cancelselect")
	GG.OpenMainGameMenu()
end)

concommand.Add("minigame",function(ply,cmd,ta,args)
	RunConsoleCommand("cancelselect")
	GG.OpenMainGameMenu()
end)
end
