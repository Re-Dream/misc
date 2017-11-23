
if SERVER then
	util.AddNetworkString("creact")
	util.AddNetworkString("sreact")
	net.Receive( "creact", function()
		net.Start("sreact")
		net.WriteTable(net.ReadTable())
		net.Send(player.GetHumans())
	end)
end

if CLIENT then
	
	local iconlist = 
	{"icon16/accept.png","icon16/award_star_gold_1.png","icon16/bomb.png",
	"icon16/bin_empty.png","icon16/box.png","icon16/cake.png",
	"icon16/cancel.png","icon16/computer_error.png","icon16/emoticon_evilgrin.png","icon16/emoticon_grin.png",
	"icon16/emoticon_happy.png","icon16/emoticon_smile.png","icon16/emoticon_surprised.png","icon16/emoticon_tongue.png",
	"icon16/emoticon_unhappy.png","icon16/emoticon_waii.png","icon16/emoticon_wink.png","icon16/error.png",
	"icon16/fire.png","icon16/heart.png","icon16/information.png","icon16/monkey.png",
	"icon16/music.png","icon16/rainbow.png","icon16/sound_mute.png","icon16/star.png",
	"icon16/thumb_down.png","icon16/thumb_up.png","icon16/tick.png","icon16/water.png"}
	
	net.Receive( "sreact", function()
		tbl = net.ReadTable()
		DrawReaction(tbl[1],tbl[2])
	end)
	
	concommand.Add( "react", SelectReaction,0)
	
	hook.Add("OnPlayerChat","commandHook",function(ply,text)
		local txt = string.Left(string.lower( text ),2)
		if (txt == "!r" or txt == ".r" or txt == "/r" or txt == "!react" or txt == ".react" or txt == "/react") and (ply == LocalPlayer()) then
			SelectReaction()
		end
	end)
	
	function SelectReaction()
		local Fram = vgui.Create( "DFrame" )
		Fram:SetSize( 266, (table.Count(iconlist)*24)/10+70 )
		Fram:Center()
		Fram:SetTitle( "Select reaction" )
		Fram:ShowCloseButton(false)
		Fram:MakePopup()
		
		local butt = vgui.Create( "DButton", Fram )
		butt:SetText("Close")
		butt:SetSize(Fram:GetWide()-8,31)
		butt:SetPos(4,Fram:GetTall()-35)
		butt.DoClick = function()
			Fram:Close()
		end
		
		local y = 28
		local x = 4
		
		for k,v in pairs(iconlist) do
			if(x == 264)then
				x = 4
				y = y+26
			end
			local bttn = vgui.Create( "DButton", Fram )
			bttn:SetText("")
			bttn:SetSize(24,24)
			bttn:SetPos(x,y)
			bttn:SetIcon(v)
			bttn.ass = k
			bttn.DoClick = function()
				SendReaction(LocalPlayer():EntIndex(),bttn.ass)
			end
			x = x+26
		end
	end

	function SendReaction(target,num)
		net.Start("creact")
		net.WriteTable({target,num})
		net.SendToServer()
	end
	
	function DrawReaction(target,num)
		hook.Remove( "PostDrawTranslucentRenderables", "test")
		local mat1 = Material(iconlist[num])
		mat1 = Material(iconlist[num])
		hook.Add( "PostDrawTranslucentRenderables", "test", function()
			render.SetMaterial( mat1 )
			local spos,ang = Entity(target):GetBonePosition(Entity(target):LookupBone( "ValveBiped.Bip01_Head1" ))
			spos = spos+Vector(0,0,3)
			render.DrawQuadEasy( spos+ang:Right():Angle():Forward()*8,ang:Right():Angle():Forward(), 8, 8, Color( 255, 255, 255, 255 ),180)
			render.DrawQuadEasy( spos+ang:Right():Angle():Forward()*8,-ang:Right():Angle():Forward(), 8, 8, Color( 255, 255, 255, 255 ),180)
		end )
		timer.Create( "reactiontimer", 5, 1, function() hook.Remove( "PostDrawTranslucentRenderables", "test") end )
	end
end
