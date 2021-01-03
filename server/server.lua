local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","anticit")
MySQL = module("vrp_mysql", "MySQL")
discKori = Proxy.getInterface("kori_discord")

vRPanticheatS = {}
Tunnel.bindInterface("anticit",vRPanticheatS)
Proxy.addInterface("anticit",vRPanticheatS)
vRPanticheatC = Tunnel.getInterface("anticit","anticit")

local cfg = module("anticit", "cfg/config")

-------------------------------------------------------------------------------------------------------------------------
function vRPanticheatS.banMuistPermission(reason)
	local user_id = vRP.getUserId({source})
	if user_id then
		if reason == "Spectate" and not vRP.hasPermission({user_id, "admin.spectate"}) then
			vRPanticheatS.banMuist("Spectate")
		end
		if reason == "Blips" and not vRP.hasPermission({user_id, "player.blips"}) then
			vRPanticheatS.banMuist("Blips")
		end
	end
end


function vRPanticheatS.banMuist(reason)
	local user_id = vRP.getUserId({source})
	if user_id then
		local name = GetPlayerName(source)
		vRP.sendStaffMessage({"^1AntiCheat: ^4"..name.."^0[^4"..user_id.."^0] a fost prins! (^4"..reason.."^0)"})
		print("^1[AC]: "..name.."["..user_id.."] a primit BAN!\n "..reason.."^0")
		vRP.ban({source, reason, "AntiCheat"})
		vRP.logMsg({"AntiCheat", name.."["..user_id.."]  <=>  "..reason})
	end
end

-------------------------------------------------------------------------------------------------------------------------

for k, v in pairs(cfg.eventuri) do
	RegisterServerEvent(v[1])
	AddEventHandler(v[1], function()
		local user_id = vRP.getUserId({source})
		if user_id then
			local name = GetPlayerName(source)
			vRP.sendStaffMessage({"^1AntiCheat: ^4"..name.."^0[^4"..user_id.."^0] a fost prins! (^4"..v[2].."^0)"})
			print("^1[AC]: "..name.." ["..user_id.."] a primit BAN!\n Motiv: "..v[2].."^0")
			vRP.ban({source, v[2], "AntiCheat"})
			vRP.logMsg({"AntiCheat", name.."["..user_id.."]  <=>  "..v[2]})
		end
	end)
end

-------------------------------------------------------------------------------------------------------------------------

local function banCheaterGrup(ceGrup, name, user_id)
	if source then
		vRP.sendMessageB({"^2Anticheat: ^4"..name.."^0[^4"..user_id.."^0] a primit BAN deoarece avea un grad interzis! (Gradul: ^4"..ceGrup.." ^0)"})	
		print("^1[AC] Jucatorul: "..name.." [ID: "..user_id.."] a primit BAN\n Motiv: avea un grad interzis! (Gradul: "..ceGrup.." )^0")
		vRP.ban({source, "Grad Interzis", "AntiCheat"})
		vRP.logMsg({"AntiCheat", name.."["..user_id.."]  <=>  Grad Interzis ("..ceGrup..")"})
	end
end

function vRPanticheatS.verificaGrad()
	local user_id = vRP.getUserId({source})
	if user_id then
		local name = GetPlayerName(source)
		if vRP.hasGroup({user_id, "EMfondator"}) and user_id > 2 then
			banCheaterGrup("Fondator", name, user_id)
		end
		if vRP.hasGroup({user_id, "EMdev"}) and user_id ~= 3 then
			banCheaterGrup("Developer", name, user_id)
		end
		if vRP.hasGroup({user_id, "EMcofondator"}) and user_id ~= 4 then
			banCheaterGrup("Co-Fondator", name, user_id)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------
function vRPanticheatS.sendStaffMessage(reason)
	local user_id = vRP.getUserId({source})
	if user_id then
		local name = GetPlayerName(source)
		vRP.sendStaffMessage({"^1AntiCheat: ^4"..name.."^0[^4"..user_id.."^0] este suspect ca foloseste ^4"..reason})
	end
end
-------------------------------------------------------------------------------------------------------------------------
AddEventHandler('explosionEvent', function(sender, ev)
	local explosion = ev.explosionType
	if explosion and explosion ~= 13 and explosion ~= 39 then
		local user_id = vRP.getUserId({sender})
		if user_id then
			local name = GetPlayerName(sender)
			vRP.sendStaffMessage({"^1AntiCheat: ^4"..name.."^0[^4"..user_id.."^0] a creeat o explozie! (Type: ^4"..explosion.." ^0| ^0DMG: ^4"..ev.damageScale.."^0)"})
		end
	end
end)

-------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------