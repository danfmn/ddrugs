--[[---------------------------------------------------------------------------
This is an example of a custom entity.
---------------------------------------------------------------------------]]
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua") 
include("shared.lua")

util.AddNetworkString("ddrugs_openNPC")
util.AddNetworkString("ddrugs_sellDrug")
util.AddNetworkString("ddrugs_updateDrugs")
function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE )
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()

end


function ENT:AcceptInput( Name, a, Caller )	
	
	net.Start("ddrugs_openNPC")
	net.WriteEntity(self)
	net.Send(a)

end

net.Receive("ddrugs_sellDrug", function(len,ply)


	local class = net.ReadString() 
	local drugDealer = net.ReadEntity()
	if ply:GetPos():Distance(drugDealer:GetPos()) > 400 or not DDRUGS.NPC.DRUGS[class] then return end 

	local foundProducts = ents.FindInSphere(drugDealer:GetPos(), 100)
	for k,v in pairs(foundProducts) do
		print(v:GetClass(), class)
		if v:GetClass() == class then
			local drug = DDRUGS.NPC.DRUGS[class]
			local price = drug.price
			v:Remove()
			ply:ChatPrint("You received " .. DarkRP.formatMoney(price))
			ply:setDarkRPVar("money", ply:getDarkRPVar("money") + price)
			DDRUGS.NPC.DRUGS[class].sold = DDRUGS.NPC.DRUGS[class].sold + 1
			DDRUGS.NPC.DRUGS[class].oldprice = price
			DDRUGS.NPC.DRUGS[class].price = math.Clamp(math.floor(price * .98), drug.minprice, drug.maxprice)
			DDRUGS.NPC.DRUGS[class].guessvalue = math.Round(DDRUGS.NPC.DRUGS[class].price - (DDRUGS.NPC.DRUGS[class].price * ( .04 * math.random(-1, 1))))
			net.Start("ddrugs_updateDrugs")
			net.WriteString(class)
			net.WriteTable(DDRUGS.NPC.DRUGS[class])
			net.Broadcast()
			break
		end 
	end 
end)	

timer.Create("DDRUGS_UpdatePrices", 150, 0, function()
	for class,v in pairs(DDRUGS.NPC.DRUGS) do 
		local price = v.price
		DDRUGS.NPC.DRUGS[class].oldprice = price
		DDRUGS.NPC.DRUGS[class].price = math.Round(math.Clamp(price * 1.06, v.minprice, v.maxprice))
		DDRUGS.NPC.DRUGS[class].guessvalue = math.Round(DDRUGS.NPC.DRUGS[class].price - (DDRUGS.NPC.DRUGS[class].price * ( .04 * math.random(-1, 1))))
		net.Start("ddrugs_updateDrugs")
		net.WriteString(class)
		net.WriteTable(DDRUGS.NPC.DRUGS[class])
		net.Broadcast()
	end 

end)

util.AddNetworkString("ddrugs_save_npc")
util.AddNetworkString("ddrugs_delete_npc")
DDRUGS.NPC.NPCS = DDRUGS.NPC.NPCS or {}

local function SaveNPCData()

	if not file.Exists("ddrugs/npc", "DATA") then
		file.CreateDir("ddrugs/npc")
		print("Initiailizing DDRUGS directory.")
	end 
	file.Write("ddrugs/npc/data.txt", util.TableToJSON(DDRUGS.NPC.NPCS or {},true))

end 


net.Receive("ddrugs_save_npc", function(len, ply)

	local id = net.ReadInt(8)
	local ent = ply:GetEyeTrace().Entity
	if not DDRUGS.NPC.NPCS[id] then 
		if IsValid(ent) and ent:GetClass() == "ddrugs_npc" then
			local pos,ang = ent:GetPos(), ent:GetAngles()
			DDRUGS.NPC.NPCS[id] = {pos = pos, ang = ang, id = id}
			SaveNPCData()
			ent.id = id
			ply:ChatPrint("Successfully saved NPC: " .. id)
		else
			ply:ChatPrint("Entity is invalid or missing.")
		end 
	else
		ply:ChatPrint("That ID is already in use! Please remove/replace that previous ID.")
	end 


end)


net.Receive("ddrugs_delete_npc", function(len, ply)

	local id = net.ReadInt(8)
	local ent = ply:GetEyeTrace().Entity
	if DDRUGS.NPC.NPCS[id] then 
		for k,v in pairs(ents.FindByClass("ddrugs_npc")) do
			if v.id == id then
				v:Remove() 
			end 
		end 
		DDRUGS.NPC.NPCS[id] = nil 
		SaveNPCData()
		ply:ChatPrint("NPC successfully removed from database.")
	else
		ply:ChatPrint("That ID does not exist!")
	end 

end)

hook.Add("InitPostEntity", "LoadDDRUGSNPC", function()

	if file.Exists("ddrugs/npc/data.txt", "DATA") then
		local saveData = util.JSONToTable(file.Read("ddrugs/npc/data.txt", "DATA"))
		for k,v in pairs(saveData) do
			DDRUGS.NPC.NPCS[v.id] = v
			local npc = ents.Create("ddrugs_npc")
			npc:SetPos(v.pos)
			npc:SetAngles(v.ang)
			npc:Spawn()
			npc.id = v.id
		end 
	end 

end)