
include("shared.lua")
surface.CreateFont( "ddrugs_24", { font = "Roboto", size = 24, weight = 600, bold = true, strikeout = false, outline = false, shadow = false, outline = false,})
surface.CreateFont( "ddrugs_18", { font = "Roboto", size = 18, weight = 600, bold = true, strikeout = false, outline = false, shadow = false, outline = false,})
local moneyColor = Color(50,207,89,255)
function ENT:Draw()
    self:DrawModel()
    if self.ShowTitle then 
    	if LocalPlayer():GetPos():Distance(self:GetPos()) < 350 then
		    local ang = self:GetAngles()
			ang:RotateAroundAxis(self:GetAngles():Right(), 90)
			ang:RotateAroundAxis(self:GetAngles():Forward(), 90)
			local z = math.sin(CurTime() * 2) * 10

		    cam.Start3D2D(self:GetPos() + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
		 	surface.SetDrawColor(0,0,0,200)
		 	surface.SetFont("ddrugs_24")
		 	local text = "Drug Dealer"
		 	local tW, tH = surface.GetTextSize( text) + 20
		 	surface.DrawRect(-tW / 2, -800 - z, tW, 50)
		    draw.SimpleText(text, "ddrugs_24", 0, -800 + 25 - z, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		    cam.End3D2D()
		end 
	end 
end

local barClr = Color(0,0,0,150)
local theme = moneyColor
local function paintSbar(sbar)

local bar = sbar:GetVBar()

local buttH = 0
function bar.btnUp:Paint( w, h )
	buttH = h
end

function bar:Paint( w, h )
	draw.RoundedBox( 8, w / 2 - w / 2, buttH, w / 2, h - buttH * 2, barClr )
end

function bar.btnDown:Paint( w, h )
	
end
function bar.btnGrip:Paint( w, h )
	draw.RoundedBox( 8, w / 2 - w / 2, 0, w / 2, h , theme )
end
 
end 

local blur = Material( "pp/blurscreen" )
local function BlurMenu( panel, layers, density, alpha )
	if LocalPlayer():GetNetVar( "HungerGames.HUD.EnableBlur" ) == false then return end
    -- Its a scientifically proven fact that blur improves a script
    local x, y = panel:LocalToScreen( 0, 0 )

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )

    for i = 1, 5 do
        blur:SetFloat( "$blur", ( i / 4 ) * 4 )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end



local function OpenDrugs(npc)

	if IsValid(DDRUGS.MENU) then

		DDRUGS.MENU:Remove()

	end 
	local scrw, scrh = ScrW(), ScrH()

	DDRUGS.MENU = vgui.Create("DFrame")
	DDRUGS.MENU:SetSize(scrw * .3, scrh * .6)
	DDRUGS.MENU:Center()
	DDRUGS.MENU:SetTitle("")
	DDRUGS.MENU:MakePopup()
	DDRUGS.MENU.npc = npc 
	DDRUGS.MENU:ShowCloseButton(false)
	DDRUGS.MENU.Paint = function(me,w,h)
		BlurMenu(me, 22, 22, 255)
		surface.SetDrawColor(0,0,0,200)
		surface.DrawRect(0,0,w,h)
		surface.DrawRect(0,0,w,h * .05)
		draw.SimpleText("Drug Dealer", "ddrugs_18", w / 2, h * .025, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	local frameW,frameH = DDRUGS.MENU:GetWide(), DDRUGS.MENU:GetTall()
	local closeButton = vgui.Create("DButton", DDRUGS.MENU)
	local closeSize = frameH * .05
	closeButton:SetPos(frameW - closeSize + 1, 0)
	closeButton:SetText("")
	closeButton:SetSize(closeSize, closeSize)
	closeButton.DoClick = function()
		DDRUGS.MENU:Remove()
	end 
	closeButton.Paint = function(me,w,h)
		surface.SetDrawColor(222, 14, 49)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("X", "ddrugs_18", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end 
	local drugsScroll = vgui.Create("DScrollPanel", DDRUGS.MENU)
	drugsScroll:SetPos(0, frameH * .05)
	drugsScroll:SetSize(frameW, frameH * .95)
	paintSbar(drugsScroll)
	local ypos = frameH * .02
	local priceColor = Color(255,255,255)
	local badValue = Color(217,15,62)
	for k,v in ipairs(DDRUGS.NPC.DRUGSID) do --  for i = 1, 15 do
		local v = DDRUGS.NPC.DRUGS[v.classname]
		local drugPanel = vgui.Create("DPanel", drugsScroll)
		drugPanel:SetPos(frameW * .05, ypos)
		drugPanel:SetSize(frameW * .9, frameH * .15)
		drugPanel.priceColor = priceColor
		drugPanel.Paint = function(me,w,h)
			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(0,0,w,h)
			local curVal = "Current Value: "
			surface.SetFont("ddrugs_18")
			local tW,tH = surface.GetTextSize(curVal)
			draw.SimpleText(curVal, "ddrugs_18", drugPanel:GetTall() * 1.1, h * .1 + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			if v.price > v.oldprice then
				me.priceColor = moneyColor
			elseif v.price < v.oldprice then
				me.priceColor = badValue
			else
				me.priceColor = priceColor
			end 
			draw.SimpleText(DarkRP.formatMoney(v.price), "ddrugs_18", drugPanel:GetTall() * 1.1 + tW, h * .1 + 5, me.priceColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText("Previous Value: " .. DarkRP.formatMoney(v.oldprice), "ddrugs_18", drugPanel:GetTall() * 1.1, h * .3 + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText("Sold Today: " .. v.sold, "ddrugs_18", drugPanel:GetTall() * 1.1, h * .5 + 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		local drugModel = vgui.Create("DModelPanel", drugPanel)
		drugModel:SetPos(5,5)
		drugModel:SetSize(drugPanel:GetTall() - 10, drugPanel:GetTall() - 10)
		drugModel:SetModel(v and v.model or "models/dxans/alprazolam_pills_packed.mdl")
		function drugModel:LayoutEntity( Entity ) return end 
		drugModel.Entity:SetPos( drugModel.Entity:GetPos() + Vector(0,0,-2))
		drugModel:SetFOV(50)
		local num = .7
		local min, max = drugModel.Entity:GetRenderBounds()
		drugModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
		drugModel:SetLookAt((max + min) / 2)
		local oldPaint = drugModel.Paint
		drugModel.Paint = function(me,w,h)
			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(0,0,w,h)
			oldPaint(me,w,h)
			draw.SimpleText(v and v.name or "UNKOWN", "ddrugs_18", w / 2, h * .1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end 

		local drugSell = vgui.Create("DButton", drugPanel)
		drugSell:SetSize(drugPanel:GetWide() * .2, drugPanel:GetTall() * .25)
		drugSell:SetPos(drugPanel:GetWide() - drugPanel:GetWide() * .2 - 5, drugPanel:GetTall() / 2 - drugSell:GetTall() / 2)
		drugSell:SetText("")
		local hoverColor = Color(moneyColor.r, moneyColor.g, moneyColor.b, 10)
		drugSell.Paint = function(me,w,h)
			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(0,0,w,h)
			draw.SimpleText("Sell", "ddrugs_18", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			if me:IsHovered() then
				surface.SetDrawColor(hoverColor)
				surface.DrawRect(0,0,w,h)
			end 
		end
		drugSell.DoClick = function()

			net.Start("ddrugs_sellDrug")
			net.WriteString(v.classname)
			net.WriteEntity(npc)
			net.SendToServer()

		end 
		ypos = ypos + frameH * .17
	end 


end 

net.Receive("ddrugs_updateDrugs", function()

	local class = net.ReadString()
	local data = net.ReadTable()
	DDRUGS.NPC.DRUGS[class] = data

	if IsValid(DDRUGS.MENU) then
		OpenDrugs(DDRUGS.MENU.npc)
	end 

end)


net.Receive("ddrugs_openNPC", function()

	local drugdealer = net.ReadEntity()
	OpenDrugs(drugdealer)
	
end)

concommand.Add("ddrugs_save_npc", function(ply, cmd, args)
	if args[1] and type(tonumber(args[1])) == "number" then
		net.Start("ddrugs_save_npc")
		net.WriteInt(tonumber(args[1]), 8)
		net.SendToServer()
		ply:ChatPrint("Attempting to save NPC.")
	end 

end)


concommand.Add("ddrugs_delete_npc", function(ply, cmd, args)
	if args[1] and type(tonumber(args[1])) == "number" then
		net.Start("ddrugs_delete_npc")
		net.WriteInt(tonumber(args[1]), 8)
		net.SendToServer()
		ply:ChatPrint("Attempting to delete NPC.")
	end 

end)