--[[---------------------------------------------------------------------------
This is an example of a custom entity.
---------------------------------------------------------------------------]]
ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "Drug NPC"
ENT.Author = "Dan"
ENT.Spawnable = true
ENT.AdminSpawnable = true 
ENT.Category = "DDrugs"
ENT.WorldModel = "models/Humans/Group01/Male_04.mdl"
ENT.ShowTitle = true
 
DDRUGS = {}
DDRUGS.NPC = {} 
DDRUGS.NPC.DRUGS = DDRUGS.NPC.DRUGS or {}
DDRUGS.NPC.DRUGSID = {}

function DDRUGS.RegisterDrug(class, data)
	if not DDRUGS.NPC.DRUGS[class] then 
		data.oldprice = data.price
		data.sold = 0
		data.guessvalue = math.Round(data.price - (data.price * ( .04 * math.random(-1, 1))))
		DDRUGS.NPC.DRUGS[class] = data
		DDRUGS.NPC.DRUGSID[#DDRUGS.NPC.DRUGSID + 1 or 1] = data
	end 
 
end 