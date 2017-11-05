local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' --Dont worry about this and do not touch!

local GarryClicker = GarryClicker or {}
GarryClicker.Notify = function(Text)
	return chat.AddText(Color(0, 255, 255), "[GARRYCLICKER] ", Color(0, 0, 255), Text)
end
GarryClicker.Stats = {
	Garries = 0,
	GarriesPerClick = 1,
	GarriesPerSecond = 0,
	TotalClicks = 0,
	Interval = 1000,
	Multiplier = 1
}
GarryClicker.People = {
	{Name = "Kleiner", Amount = 0, Price = 15, Payout = 1},
	{Name = "Freeman", Amount = 0, Price = 100, Payout = 10},
	{Name = "Alyx", Amount = 0, Price = 1100, Payout = 80},
	{Name = "Chell", Amount = 0, Price = 1.2e4, Payout = 470},
	{Name = "Barney", Amount = 0, Price = 1.3e5, Payout = 2600},
	{Name = "Breen", Amount = 0, Price = 1.4e6, Payout = 14000},
	{Name = "Eli", Amount = 0, Price = 2.0e7, Payout = 78000},
	{Name = "GMan", Amount = 0, Price = 3.3e8, Payout = 440000},
	{Name = "Police", Amount = 0, Price = 5.1e9, Payout = 2600000},
	{Name = "Combine", Amount = 0, Price = 7.5e10, Payout = 16000000},
	{Name = "Vortigaunt", Amount = 0, Price = 1.0e11, Payout = 100000000},
	{Name = "Advisor", Amount = 0, Price = 1.0e12, Payout = 1000000000}
}
GarryClicker.UpgradeNames = {
	"Crowbar","Colt Python Revolver","Bug Bait","Crossbow","Emplacement Gun","Hopper Mine",
	"MK3A2 Grenade","MP7","AR2","Ravenholm Traps","RPG","Sentry Gun",
	"SPAS-12","USP Match","Physcannon","Tau Cannon","Jalopy","Combine's Balls",
	"Jeep","APC","Stun Baton","SLAM","Medkit"
}
GarryClicker.RandomOutcomes = {
	function() GarryClicker.Stats.GarriesPerSecond = GarryClicker.Stats.GarriesPerSecond * 4 end,
	function() for i,v in pairs(GarryClicker.People) do v.Payout = v.Payout * 4	end end,
	function() for i,v in pairs(GarryClicker.People) do v.Price = v.Price / 4 end end,
	function() for i,v in pairs(GarryClicker.People) do v.Payout = v.Payout * 10 end end,
	function() for i,v in pairs(GarryClicker.People) do v.Price = v.Price / 10 end end,
	function() for i,v in pairs(GarryClicker.People) do v.Payout = v.Payout * 17 end end,
	function() GarryClicker.Stats.GarriesPerClick = GarryClicker.Stats.GarriesPerClick * 5 end,
	function() GarryClicker.Stats.GarriesPerClick = GarryClicker.Stats.GarriesPerClick ^ 2 end,
}
GarryClicker.Upgrades = {
	{Name = "Nothing", Price = 0, OnBuy = print, Bought = true, Description = "Click on a button\nto buy something!"}
}
GarryClicker.AddGPS = function()
	timer.Create("AddGPS", GarryClicker.Stats.Interval / 1000, 0, function()
		GarryClicker.Stats.Garries = GarryClicker.Stats.Garries + GarryClicker.Stats.GarriesPerSecond
	end)	
end
do
	for i = 1, 96 do
		local Chance = math.random(1, 8)
		local Description = ""
		if Chance == 1 then Description = "Garries per second is\nmultiplied by 4."
		elseif Chance == 2 then Description = "People's payouts are\nmultiplied by 4."
		elseif Chance == 3 then Description = "People's prices are\ndivided by 4."
		elseif Chance == 4 then Description = "People's payouts are\nmultiplied by 10." 
		elseif Chance == 5 then Description = "People's prices are\ndivided by 10." 
		elseif Chance == 6 then Description = "People's payouts are\nmultiplied by 17." 
		elseif Chance == 7 then Description = "Per Click is\nmultiplied by 5." 
		else Description = "Per Click is\nsquared." end
		
		table.insert(GarryClicker.Upgrades, {
			Name = table.Random(GarryClicker.UpgradeNames),
			Price = 1e6 ^ (i/4.6),
			Bought = false,
			Description = Description,
			OnBuy = GarryClicker.RandomOutcomes[Chance]
		})
	end
end
GarryClicker.Speed = {
	Price = 5.0e4,
	OnBuy = function()
		GarryClicker.Speed.Price = GarryClicker.Speed.Price * 1.3
		GarryClicker.Stats.Interval = GarryClicker.Stats.Interval - 10
		GarryClicker.AddGPS()
	end,
	Max = false
}
GarryClicker.Click = {
	Price = 20000,
	OnBuy = function()
		GarryClicker.Click.Price = GarryClicker.Click.Price * 3
		GarryClicker.Stats.GarriesPerClick = GarryClicker.Stats.GarriesPerClick * 2
	end,
}
GarryClicker.Current = 1
GarryClicker.VerdanaSize13 = surface.CreateFont("VerdanaSize13", {
	font = "Verdana",
	extended = false,
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
GarryClicker.VerdanaSize23 = surface.CreateFont("VerdanaSize23", {
	font = "Verdana",
	extended = false,
	size = 23,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
GarryClicker.Coolvetica = surface.CreateFont("GC_Coolvetica", {
	font = "coolvetica",
	size = ScreenScale(54)
})
GarryClicker.BigNumToString = function(Number)
	if Number < 1e14 then return Number end
	
	local Base, Power, Final
	Power = string.gsub(Number, "(.-)e++", "")
	Base = string.gsub(Number, "e++(.-)", ""):gsub(Power, "")
	Final = tostring(Base)
	for i = 1, string.len(Final) - 1 do
		Base = Base * 10
		Power = Power - 1
	end
	return Base..string.rep(0, Power)
end
GarryClicker.BiggerNumToString = function(String)
	if tonumber(String) < 1e308 then return String end
	local Base, Power, Final
	Power = string.gsub(String, "(.-)e++", "")
	Base = string.gsub(String, "e++(.-)", ""):gsub(Power, "")
	Final = tostring(Base)
	for i = 1, string.len(Final) - 1 do
		Base = Base * 10
		Power = Power - 1
	end
	return Base..string.rep(0, Power)
end
GarryClicker.EncodeData = function(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
GarryClicker.DecodeData = function(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end
GarryClicker.MoneySuffixes = {
	"Thousand","Million","Billion","Trillion","Quadrillion","Quintillion",
	"Sextillion","Septillion","Octillion","Nonillion","Decillion","Undecillion",
	"Duodecillion","Tredecillion","Quattuordecillion","Quindecillion","Sedecillion","Septendecillion",
	"Octodecillion","Novendecillion","Vigintillion","Unvigintillion","Duovigintillion","Tresvigintillion",
	"Quattuorvigintillion","Quinvigintillion","Sevigintillion","Septevigintillion","Octovigintillion","Novemvigintillion",
	"Trigintillion","Untrigintillion","Duotrigintillion","Trestrigintillion","Quattuortrigintillion","Quintrigintillion",
	"Sestrigintillion","Septentrigintillion","Octotrigintillion","Noventrigintillion","Quadragintillion"
}
GarryClicker.HandleMoney = function(Input)
	local Negative = Input < 0
	Input = math.abs(Input)

	local Paired = false
	for i,v in pairs(GarryClicker.MoneySuffixes) do
		if not (Input >= 10^(3*i)) then
			Input = Input / 10^(3*(i - 1))
			local isComplex = (string.find(tostring(Input),".") and string.sub(tostring(Input),4,4) ~= ".")
			Input = string.sub(tostring(Input),1,(isComplex and 4) or 3) .." ".. (GarryClicker.MoneySuffixes[i-1] or "")
			Paired = true
			break;
		end
	end
	if not Paired then
		local Rounded = math.floor(Input)
		Input = tostring(Rounded)
	end

	if Negative then
		return "(-¢"..(Input)..")"
	end
	return "¢"..(Input)
end
GarryClicker.Filename = "garryclickerdatav2.txt"
GarryClicker.SaveStats = function()
	local TablesToSave = {
		GarryClicker.Stats,
		GarryClicker.People,
		GarryClicker.Upgrades,
		GarryClicker.Speed,
		GarryClicker.Click
	}
	TablesToSave = util.TableToJSON(TablesToSave)
	TablesToSave = GarryClicker.EncodeData(TablesToSave)
	
	file.Write("garryclickerdatav2.txt", TablesToSave)
end
GarryClicker.LoadStats = function()
	if not file.Exists("garryclickerdatav2.txt", "DATA") then
		GarryClicker.Notify("Save file not found! Creating new one!")
		GarryClicker.SaveStats()
	else
		local Data = file.Read("garryclickerdatav2.txt")
		Data = GarryClicker.DecodeData(Data)
		Data = util.JSONToTable(Data)
		
		GarryClicker.Notify("GarryClicker save found!")
		GarryClicker.Notify("Size: "..(file.Size("garryclickerdatav2.txt", "DATA")/1000).."KB")
		
		GarryClicker.Stats = Data[1]
		GarryClicker.People = Data[2]
		for k,v in pairs(GarryClicker.Upgrades) do
			v.Bought = Data[3][k].Bought
		end
		GarryClicker.Speed.Price = Data[4].Price
		GarryClicker.Speed.Max = Data[4].Max
		GarryClicker.Click.Price = Data[5].Price
	end
end
GarryClicker.DefaultColor = Color(0, 127, 255, 255)
GarryClicker.CreateGUI = function()
	local Pressed = false
	local Increment = 45
	
	hook.Add("Think", "MousePress", function()
		if(input.IsMouseDown(MOUSE_LEFT) == true) then
			if(Pressed == false) then
				local x,y = input.GetCursorPos()
				hook.Call("MouseDown", nil, { x = x, y = y })
				Pressed = true
			end
		else
			Pressed = false
		end
	end)
	
	GarryClicker.Frame = vgui.Create("DFrame")
	GarryClicker.Frame:SetSize(800,800)
	GarryClicker.Frame:SetTitle("")
	GarryClicker.Frame:Center()
	GarryClicker.Frame:MakePopup()
	--y = 270 420; x = 470 620
	GarryClicker.Frame.Paint = function()
		local X,Y = GarryClicker.Frame:LocalToScreen()
		local Condition1 = gui.MouseX() > X + 150 and gui.MouseX() < X + 300
		local Condition2 = gui.MouseY() > Y + 200 and gui.MouseY() < Y + 350
		
		draw.RoundedBox(8, 0, 0, GarryClicker.Frame:GetWide(), GarryClicker.Frame:GetTall(), Color(30, 30, 30, 255))
		draw.RoundedBox(8, 0, 0, GarryClicker.Frame:GetWide(), 30, GarryClicker.DefaultColor)
		
		if Condition1 and Condition2 and Pressed == true then
			draw.RoundedBox(8, 150 - 10, 200 - 10, 170, 170, Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255))
		end
		draw.RoundedBox(8, 150, 200, 150, 150, GarryClicker.DefaultColor)
	end
	GarryClicker.Frame.OnClose = function()
		GarryClicker.Frame:Hide()
		hook.Remove("Think", "Update")
		hook.Remove("Think", "MousePress")
		gui.EnableScreenClicker(false)
	end

	local TitleLabel = vgui.Create("DLabel", GarryClicker.Frame)
	TitleLabel:SetFont("VerdanaSize13")
	TitleLabel:SetSize(GarryClicker.Frame:GetWide(), 23)
	TitleLabel:SetPos(5, 4)
	TitleLabel:SetText("Garry Clicker V2. Welcome, "..LocalPlayer():Nick()..
		". Total Clicks: "..GarryClicker.Stats.TotalClicks)
	
	local MoneyLabel = vgui.Create("DLabel", GarryClicker.Frame)
	MoneyLabel:SetFont("VerdanaSize13")
	MoneyLabel:SetSize(GarryClicker.Frame:GetWide(), 400)
	MoneyLabel:SetPos(10, -125)
	MoneyLabel:SetText("Garries:")
	
	local PeopleLabel = vgui.Create("DLabel", GarryClicker.Frame)
	PeopleLabel:SetFont("VerdanaSize13")
	PeopleLabel:SetSize(GarryClicker.Frame:GetWide(), 700)
	PeopleLabel:SetPos(10, 150)
		
	for k,v in pairs(GarryClicker.People) do
		local ButtonForPerson = vgui.Create("DButton", GarryClicker.Frame)
		ButtonForPerson:SetSize(250, 35)
		ButtonForPerson:SetPos(450, 15 + (Increment * k))
		ButtonForPerson:SetText("Buy "..v.Name.." - ¢"..string.Comma(v.Price))
		ButtonForPerson:SetFont("VerdanaSize13")
		ButtonForPerson:SetColor(Color(255, 255, 255))
		ButtonForPerson.Paint = function()
			draw.RoundedBox(8, 0, 0, ButtonForPerson:GetWide(), ButtonForPerson:GetTall(), GarryClicker.DefaultColor)
			ButtonForPerson:SetText("Buy "..v.Name.." - "..GarryClicker.HandleMoney(math.Round(v.Price)))
		end
		ButtonForPerson.DoClick = function()
			if GarryClicker.Stats.Garries >= v.Price then
				GarryClicker.Stats.Garries = math.Round(GarryClicker.Stats.Garries - v.Price)
				GarryClicker.Stats.GarriesPerSecond = GarryClicker.Stats.GarriesPerSecond + v.Payout
				
				v.Price = math.ceil(v.Price * 1.2)
				v.Amount = v.Amount + 1
				sound.Play( "garrysmod/balloon_pop_cute.wav", LocalPlayer():GetPos() )
			end
		end
	
		local ButtonForPersonX10 = vgui.Create("DButton", GarryClicker.Frame)
		ButtonForPersonX10:SetSize(35, 35)
		ButtonForPersonX10:SetPos(705, 15 + (Increment * k))
		ButtonForPersonX10:SetText("X10")
		ButtonForPersonX10:SetFont("VerdanaSize13")
		ButtonForPersonX10:SetColor(Color(255, 255, 255))
		ButtonForPersonX10.Paint = function()
			draw.RoundedBox(8, 0, 0, ButtonForPersonX10:GetWide(), ButtonForPersonX10:GetTall(), GarryClicker.DefaultColor)
		end
		ButtonForPersonX10.DoClick = function()
			if GarryClicker.Stats.Garries >= v.Price * 10 then
				GarryClicker.Stats.Garries = math.Round(GarryClicker.Stats.Garries - (v.Price * 10))
				GarryClicker.Stats.GarriesPerSecond = GarryClicker.Stats.GarriesPerSecond + (v.Payout * 10)
				
				v.Price = math.ceil(v.Price * 5)
				v.Amount = v.Amount + 10
				sound.Play( "garrysmod/balloon_pop_cute.wav", LocalPlayer():GetPos() )
			end
		end
	
		local ButtonForPersonX50 = vgui.Create("DButton", GarryClicker.Frame)
		ButtonForPersonX50:SetSize(35, 35)
		ButtonForPersonX50:SetPos(710 + 35, 15 + (Increment * k))
		ButtonForPersonX50:SetText("X50")
		ButtonForPersonX50:SetFont("VerdanaSize13")
		ButtonForPersonX50:SetColor(Color(255, 255, 255))
		ButtonForPersonX50.Paint = function()
			draw.RoundedBox(8, 0, 0, ButtonForPersonX50:GetWide(), ButtonForPersonX50:GetTall(), GarryClicker.DefaultColor)
		end
		ButtonForPersonX50.DoClick = function()
			if GarryClicker.Stats.Garries >= v.Price * 100 then
				GarryClicker.Stats.Garries = math.Round(GarryClicker.Stats.Garries - (v.Price * 100))
				GarryClicker.Stats.GarriesPerSecond = GarryClicker.Stats.GarriesPerSecond + (v.Payout * 50)
				
				v.Price = math.ceil(v.Price * 125)
				v.Amount = v.Amount + 50
				sound.Play( "garrysmod/balloon_pop_cute.wav", LocalPlayer():GetPos() )
			end
		end
	end

	GarryClicker.AddGPS()
	
	hook.Add("MouseDown", "Click", function(curpos)
		local X,Y = GarryClicker.Frame:LocalToScreen()
		local Condition1 = gui.MouseX() > X + 150 and gui.MouseX() < X + 300
		local Condition2 = gui.MouseY() > Y + 200 and gui.MouseY() < Y + 350
		
		if Condition1 and Condition2 then
			GarryClicker.Stats.Garries = GarryClicker.Stats.Garries + GarryClicker.Stats.GarriesPerClick
			GarryClicker.Stats.TotalClicks = GarryClicker.Stats.TotalClicks + 1
			
			surface.PlaySound("garrysmod/balloon_pop_cute.wav")
		end
	end)
	
	hook.Add("Think", "Update", function()
		local Text = ""
		TitleLabel:SetText("Garry Clicker V2. Welcome, "..LocalPlayer():Nick()..
			". Total Clicks: "..GarryClicker.Stats.TotalClicks)
		MoneyLabel:SetText("Garries: "..GarryClicker.HandleMoney(GarryClicker.Stats.Garries)..
			"\nGarries Per Second: "..GarryClicker.HandleMoney(GarryClicker.Stats.GarriesPerSecond)..
			"\nGarries Per Click: "..GarryClicker.HandleMoney(GarryClicker.Stats.GarriesPerClick))
		for i,v in pairs(GarryClicker.People) do
			Text = (Text..v.Name..": "..v.Amount.."\n")	
		end
		PeopleLabel:SetText(Text)
	end)
end
GarryClicker.CreateShop = function()
	local StartingPos, Incrementt, A = {180, 50}, 45, 0
	GarryClicker.SFrame = vgui.Create("DFrame")
	GarryClicker.SFrame:SetSize(600,335 + (Incrementt * 6))
	GarryClicker.SFrame:SetTitle("")
	GarryClicker.SFrame:Center()
	GarryClicker.SFrame:MakePopup()
	GarryClicker.SFrame.Paint = function()
		draw.RoundedBox(8, 0, 0, GarryClicker.SFrame:GetWide(), GarryClicker.SFrame:GetTall(), Color(30, 30, 30, 255))
		draw.RoundedBox(8, 0, 0, GarryClicker.SFrame:GetWide(), 30, GarryClicker.DefaultColor)
	end
	GarryClicker.SFrame.OnClose = function()
		GarryClicker.SFrame:Hide()
		hook.Remove("Think", "Update2")
		gui.EnableScreenClicker(false)
	end
	
	local TitleLabel = vgui.Create("DLabel", GarryClicker.SFrame)
	TitleLabel:SetFont("VerdanaSize13")
	TitleLabel:SetSize(GarryClicker.SFrame:GetWide(), 23)
	TitleLabel:SetPos(5, 4)
	TitleLabel:SetText("Garry Clicker V2 Shop")
	
	local DescriptionLabel = vgui.Create("DLabel", GarryClicker.SFrame)
	DescriptionLabel:SetFont("VerdanaSize13")
	DescriptionLabel:SetSize(200, 100)
	DescriptionLabel:SetPos(5, 20)
	
	local BuyNow = vgui.Create("DButton", GarryClicker.SFrame)
	BuyNow:SetFont("VerdanaSize23")
	BuyNow:SetSize(205, 30)
	BuyNow:SetText("Buy now!")
	BuyNow:SetColor(Color(255, 255, 255))
	BuyNow:SetPos(0, 150)
	BuyNow.Paint = function()
		draw.RoundedBox(8, 0, 0, BuyNow:GetWide(), BuyNow:GetTall(), GarryClicker.DefaultColor)	
	end
	BuyNow.DoClick = function()
		local curr = GarryClicker.Upgrades[GarryClicker.Current]
		if GarryClicker.Stats.Garries >= curr.Price then
			GarryClicker.Stats.Garries = GarryClicker.Stats.Garries - curr.Price
			GarryClicker.Current = 1
			
			curr.Bought = true
			curr.OnBuy()
		end
	end
	
	local Speed = vgui.Create("DButton", GarryClicker.SFrame)
	Speed:SetFont("VerdanaSize13")
	Speed:SetSize(205, 30)
	Speed:SetText("Speed Upgrade")
	Speed:SetColor(Color(255, 255, 255))
	Speed:SetPos(0, 210)
	Speed.Paint = function()
		if GarryClicker.Stats.Interval <= 10 then
			GarryClicker.Speed.Max = true
		end
		
		if GarryClicker.Speed.Max == true then
			draw.RoundedBox(8, 0, 0, Speed:GetWide(), Speed:GetTall(), Color(127, 127, 127, 255))
			Speed:SetText("Speed Upgrade - MAXED")
		else
			draw.RoundedBox(8, 0, 0, Speed:GetWide(), Speed:GetTall(), GarryClicker.DefaultColor)
			Speed:SetText("Speed Upgrade - "..GarryClicker.HandleMoney(GarryClicker.Speed.Price))
		end
	end
	Speed.DoClick = function()
		if GarryClicker.Stats.Interval <= 10 then
			GarryClicker.Speed.Max = true
		end
		
		if GarryClicker.Stats.Garries >= GarryClicker.Speed.Price then
			GarryClicker.Stats.Garries = GarryClicker.Stats.Garries - GarryClicker.Speed.Price
			GarryClicker.Speed.OnBuy()
		end
	end

	local Click = vgui.Create("DButton", GarryClicker.SFrame)
	Click:SetFont("VerdanaSize13")
	Click:SetSize(205, 30)
	Click:SetText("Speed Upgrade")
	Click:SetColor(Color(255, 255, 255))
	Click:SetPos(0, 250)
	Click.Paint = function()
		draw.RoundedBox(8, 0, 0, Click:GetWide(), Click:GetTall(), GarryClicker.DefaultColor)
		Click:SetText("Click Upgrade - "..GarryClicker.HandleMoney(GarryClicker.Click.Price))
	end
	Click.DoClick = function()
		if GarryClicker.Stats.Garries >= GarryClicker.Click.Price then
			GarryClicker.Stats.Garries = GarryClicker.Stats.Garries - GarryClicker.Click.Price
			GarryClicker.Click.OnBuy()
		end
	end
	
	for i = 2, #GarryClicker.Upgrades do
		A = A + 1
		if i >= 9 and A >= 9 then
			StartingPos[2] = StartingPos[2] + (Incrementt)
			StartingPos[1] = 180
			A = 1
		end
		
		local v = GarryClicker.Upgrades[i]
		local UpgradeButton = vgui.Create("DButton", GarryClicker.SFrame)
		UpgradeButton:SetSize(40, 40)
		UpgradeButton:SetText(i - 1)
		UpgradeButton:SetPos(StartingPos[1] + (Incrementt * (A)), StartingPos[2] )
		UpgradeButton:SetFont("VerdanaSize23")
		UpgradeButton:SetColor(Color(255, 255, 255))
		UpgradeButton.Paint = function()
			if v.Bought == false then
				UpgradeButton:SetText(i - 1)
				draw.RoundedBox(8, 0, 0, UpgradeButton:GetWide(), UpgradeButton:GetTall(), GarryClicker.DefaultColor)
			else
				UpgradeButton:SetText("X")
				draw.RoundedBox(8, 0, 0, UpgradeButton:GetWide(), UpgradeButton:GetTall(), Color(127, 127, 127, 255))
			end
		end
		UpgradeButton.DoClick = function()
			if v.Bought == false then
				GarryClicker.Current = i
			else return end
		end
	end
	
	hook.Add("Think", "Update2", function()
		local ToGo = ""
		if GarryClicker.Stats.Garries < GarryClicker.Upgrades[GarryClicker.Current].Price then
			ToGo = GarryClicker.HandleMoney(GarryClicker.Upgrades[GarryClicker.Current].Price - GarryClicker.Stats.Garries)
		else
			ToGo = "None!"
		end
		
		DescriptionLabel:SetText("Name: "..GarryClicker.Upgrades[GarryClicker.Current].Name..
			"\nDescription: "..GarryClicker.Upgrades[GarryClicker.Current].Description..
			"\nPrice: "..GarryClicker.HandleMoney(GarryClicker.Upgrades[GarryClicker.Current].Price)..
			"\nGarries Left: \n"..ToGo)
	end)
end
GarryClicker.LoadStats()

concommand.Add("gc_gui", GarryClicker.CreateGUI)
concommand.Add("gc_shop", GarryClicker.CreateShop)
timer.Create("Autosave", 1, 0, GarryClicker.SaveStats)
surface.PlaySound("garrysmod/save_load1.wav")

GarryClicker.Notify("Welcome to Garry Clicker V2, "..LocalPlayer():GetName().."!")
GarryClicker.Notify("To start playing, use the console command 'gc_gui'!")
