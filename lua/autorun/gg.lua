if CLIENT then
	if(GG != nil and IsValid(GG.GameFrame))then
		GG.GameFrame:Close()
	end

	GG = {}
	GG.Games = {}
	GG.Ingame = false
	GG.CurGame = -1
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

	GG.GetWindowPaint = function(panel,succ,fucc)
		if(IsValid(panel))then
			return function()
				local h,w = panel:GetTall(),panel:GetWide()
				surface.SetDrawColor(200,200,200,200)
				surface.DrawRect(0,25,w,h-25)

				surface.SetDrawColor(50,50,50,255)
				surface.DrawRect(0,0,w,25)

				surface.SetDrawColor(0,0,0,200)
				surface.DrawOutlinedRect(0,0,w,h)

				if succ then
					draw.SimpleText(succ,"GGTitleFont",(panel:GetWide()/2)+2,(panel:GetTall()/2)+2,Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					draw.SimpleText(succ,"GGTitleFont",panel:GetWide()/2,panel:GetTall()/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end

				if fucc == nil then
					draw.SimpleText(GG.TitleText,"GGTitleFont",panel:GetWide()/2,3,GG.TitleColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				else
					draw.SimpleText(fucc,"GGTitleFont",panel:GetWide()/2,3,GG.TitleColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				end
			end
		end
	end

	GG.GetButtonPaint = function(panel,col,succ)
		if(IsValid(panel))then
			return function()
				surface.SetDrawColor(col.r,col.g,col.b,255)
				surface.DrawRect(0,0,panel:GetWide(),panel:GetTall())
				surface.SetDrawColor(0,0,0,200)
				surface.DrawOutlinedRect(0,0,panel:GetWide(),panel:GetTall())
				if succ then
					draw.SimpleText(succ,"GGTitleFont",panel:GetWide()/2,panel:GetTall()/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end
			end
		end	
	end

	GG.GameOverScreen = function(text,curgame)
		if(IsValid(GG.GameOverFrame))then
			GG.GameOverFrame:Close()
		end

		GG.GameOverFrame = vgui.Create("DFrame")
		GG.GameOverFrame:SetSize(300,100)
		GG.GameOverFrame:DoModal(true)
		GG.GameOverFrame:ShowCloseButton(false)
		GG.GameOverFrame:SetPos((ScrW()/2)-(GG.GameOverFrame:GetWide()/2),(ScrH()/2)-(GG.GameOverFrame:GetTall()/2))
		GG.GameOverFrame:SetDraggable(false)
		GG.GameOverFrame:SetScreenLock(true)
		GG.GameOverFrame:SetTitle("")
		GG.GameOverFrame.Paint = GG.GetWindowPaint(GG.GameOverFrame,text,"Game over")
		GG.GameOverFrame:MakePopup()

		local ExitButt = vgui.Create("DButton",GG.GameOverFrame)
		ExitButt:SetPos(0,GG.GameOverFrame:GetTall()-25)
		ExitButt:SetSize(GG.GameOverFrame:GetWide()/2,25)
		ExitButt:SetText("")
		ExitButt.Paint = GG.GetButtonPaint(ExitButt,Color(255,0,0),"Main menu")
		ExitButt.DoClick = function()
			GG.GameOverFrame:DoModal(false)
			GG.GameOverFrame:Close()
			GG.OpenMainGameMenu()
		end

		local TryAgainButt = vgui.Create("DButton",GG.GameOverFrame)
		TryAgainButt:SetPos(GG.GameOverFrame:GetWide()/2,GG.GameOverFrame:GetTall()-25)
		TryAgainButt:SetSize(GG.GameOverFrame:GetWide()/2,25)
		TryAgainButt:SetText("")
		TryAgainButt.Paint = GG.GetButtonPaint(TryAgainButt,Color(0,255,0),"Try again")
		TryAgainButt.DoClick = function()
			GG.GameOverFrame:DoModal(false)
			GG.GameOverFrame:Close()
			GG.StartGame(curgame)
		end
	end

	GG.AddGame = function(name,func)
		GG.Games[table.Count(GG.Games)] = {name,func}
	end

	GG.StartGame = function(gam)
		local bbutt = vgui.Create("DButton",GG.GameFrame)
		bbutt:SetPos(25,0)
		bbutt:SetSize(25,25)
		bbutt:SetText("")
		bbutt:SetTooltip("Back to menu")
		bbutt.Paint = GG.GetButtonPaint(bbutt,Color(0,255,0))
		bbutt.DoClick = function()
			GG.GameFrame:Close()
			GG.OpenMainGameMenu()
			bbutt:Remove()
		end

		GG.CurGame = gam
		GG.Games[gam][2]()
		GG.Ingame = true
	end

	GG.OpenMainGameMenu = function()
		GG.Ingame = false
		GG.CurGame = -1
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
		GG.GameFrame.Paint = GG.GetWindowPaint(GG.GameFrame)

		local CloseButt = vgui.Create("DButton",GG.GameFrame)
		CloseButt:SetPos(0,0)
		CloseButt:SetSize(25,25)
		CloseButt:SetTooltip("Close")
		CloseButt:SetText("")
		CloseButt.Paint = GG.GetButtonPaint(CloseButt,Color(255,0,0))
		CloseButt.DoClick = function()
			CloseButt:GetParent():Close()
		end

		local butts = {}

		for k,v in pairs(GG.Games)do
			local butt = vgui.Create("DButton",GG.GameFrame)
			butt:SetSize(50,50)
			butt:SetText(v[1])
			butt:SetPos(k*50,25)
			butt:SetTooltip(v[1])

			butt.DoClick = function()
				butt:Remove()
				for k,v in pairs(butts)do
					v:Remove()
				end
				butts = {}
				GG.StartGame(k)
			end
			butts[table.Count(butts)] = butt
		end
		PrintTable(butts)
	end

	GG.AddGame("Snake",function()
		GG.GameFrame:SetSize(600,625)
		GG.GameFrame:Center()
		GG.TitleText = "Snake"
		GG.TitleColor = Color(100,255,100,255)

		local celltbl = {}

		for xx=0,GG.GameFrame:GetWide()-25,25 do
			for yy=25,GG.GameFrame:GetTall(),25 do
				celltbl[table.Count(celltbl)] = {snake=false,x=xx,y=yy,num = table.Count(celltbl)}
			end
		end

		local snakelength = 3
		local snaketbl = {}
		local snakehead = celltbl[table.Count(celltbl)/2]
		snakehead.snake = true
		local dir = 4
		local nextdir = 4
		local fruit = table.Random(celltbl)

		--  1
		--4	  2
		--  3

		local function GetNeighbours(cell)
			local neighbours = {celltbl[cell.num-1],
			celltbl[cell.num+25],
			celltbl[cell.num+1],
			celltbl[cell.num-25]}
			if(cell.x == 0)then
				neighbours[4] = false
			end
			if(cell.y == 25)then
				neighbours[1] = false
			end
			if(cell.x == 575)then
				neighbours[2] = false
			end
			if(cell.y == 600)then
				neighbours[3] = false
			end
			return neighbours
		end

		local last = 0
		local paused = false
		GG.GameFrame.PaintOver = function()
			local delay = 0.2
			
			if (CurTime() - last > delay and not paused) then
				dir = nextdir
				if(snakehead.x == fruit.x and snakehead.y == fruit.y)then
					fruit = table.Random(celltbl)
					snakelength = snakelength+1
				end
				if((GetNeighbours(snakehead)[dir] == false))then
					GG.GameOverScreen("You stepped off the screen!",GG.CurGame)
					paused = true
				elseif(GetNeighbours(snakehead)[dir].snake)then
					GG.GameOverScreen("You stepped on snek!",GG.CurGame)
					paused = true
				else
					table.insert(snaketbl,snakehead)
					if(table.Count(snaketbl)>snakelength-1)then
						snaketbl[1].snake = false
						table.remove(snaketbl,1)
					end
					snakehead = GetNeighbours(snakehead)[dir]
					snakehead.snake = true
				end
				last = CurTime()
			end
			for k,v in pairs(celltbl)do
				local r = 0
				local g = 0
				local b = 0
				if(v.snake and v != snakehead)then
					r = 200
					g = 255
					b = 200
				elseif(v.snake and v == snakehead)then
					r = 150
					g = 255
					b = 150
				elseif(v == fruit)then
					r = 255
					g = 100
					b = 100
				end
				surface.SetDrawColor(r,g,b,255)
				surface.DrawRect(v.x,v.y,25,25)
			end
			if((input.IsKeyDown(KEY_DOWN) or input.IsKeyDown(KEY_S)) and dir != 1)then
				nextdir = 3
			elseif((input.IsKeyDown(KEY_UP) or input.IsKeyDown(KEY_W)) and dir != 3)then
				nextdir = 1
			elseif((input.IsKeyDown(KEY_LEFT) or input.IsKeyDown(KEY_A)) and dir != 2)then
				nextdir = 4
			elseif((input.IsKeyDown(KEY_RIGHT) or input.IsKeyDown(KEY_D)) and dir != 4)then
				nextdir = 2
			end
		end
	end)

	GG.AddGame("Conway's Game of Life",function()
		GG.GameFrame:SetSize(600,625)
		GG.GameFrame:Center()
		GG.TitleText = "Conway's Game of Life"
		GG.TitleColor = Color(100,255,100,255)

		local Paused = false

		local celltbl = {}

		local function GetAliveNeighbours(cell)
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

		local clearbutt = vgui.Create("DButton",GG.GameFrame)
		clearbutt:SetPos(75,0)
		clearbutt:SetSize(25,25)
		clearbutt:SetText("")
		clearbutt:SetTooltip("Clear")
		clearbutt.Paint = GG.GetButtonPaint(clearbutt,Color(0,0,255))
		clearbutt.DoClick = function()
			for k,v in pairs(celltbl)do
				v.alive = false
				v.setalive = false
				v.setdead = false
				Paused = false
				GG.TitleText = "Conway's Game of Life"
				GG.TitleColor = Color(100,255,100,255)
			end
		end

		local pausebutt = vgui.Create("DButton",GG.GameFrame)
		pausebutt:SetPos(100,0)
		pausebutt:SetSize(25,25)
		pausebutt:SetText("")
		pausebutt:SetTooltip("Pause")
		pausebutt.Paint = GG.GetButtonPaint(pausebutt,Color(255,0,255))
		pausebutt.DoClick = function()
			if(!Paused)then
				Paused = true
				GG.TitleText = "Conway's Game of Life (PAUSED)"
				GG.TitleColor = Color(255,100,100,255)
			elseif(Paused)then
				Paused = false
				GG.TitleText = "Conway's Game of Life"
				GG.TitleColor = Color(100,255,100,255)

				for k,v in pairs(celltbl)do
					local neighbours = GetAliveNeighbours(v)
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

		local last = 0
		GG.GameFrame.PaintOver = function()
			local delay = 0.5
			if (CurTime() - last > delay and !Paused) then
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
					local neighbours = GetAliveNeighbours(v)
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
end
