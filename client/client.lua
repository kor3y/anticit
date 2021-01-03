vRPanticheatC = {}
Tunnel.bindInterface("anticit",vRPanticheatC)
Proxy.addInterface("anticit",vRPanticheatC)
vRPanticheatS = Tunnel.getInterface("anticit","anticit")
vRP = Proxy.getInterface("vRP")

--------------------------------------------------------15 Secunde CHECK
--------------------------MASINI
function checkCar(ped)
    if IsPedInAnyVehicle(ped) then
        local veh = GetVehiclePedIsIn(ped, false)
            if GetPedInVehicleSeat(veh, -1) == ped then
                if veh then
                local carModel = GetEntityModel(veh)
                for _, masiniInterzise in pairs(cfg.masini) do
                    if carModel == GetHashKey(masiniInterzise) then
                        DeleteEntity(veh)
                        vRPanticheatS.banMuist({"Vehicul interzis ["..GetDisplayNameFromVehicleModel(carModel).."]"})
                    end
                end
            end
        end
    end
end
--------------------------MASINI
--------------------------GODMODE
function checkGodMode(ped)
    local health = GetEntityHealth(ped)
    local armour = GetPedArmour(ped)

    if health > 200 or armour > 200 then
        vRPanticheatS.banMuist({"GOD Mode"})
    end
end
--------------------------GODMODE
--------------------------NPC SPAM
function checkNpcs()
    thePeds = EnumeratePeds()
	PedStatus = 0
    for ped in thePeds do
		PedStatus = PedStatus + 1
		if PedStatus > 10 then
			if not (IsPedAPlayer(ped))then
				DeleteEntity(ped)
			end
        end
    end
end
--------------------------NPC SPAM
--------------------------ARME
function checkArme(ped)
    for _, armeInterzise in pairs(cfg.arme) do
        if HasPedGotWeapon(ped, GetHashKey(armeInterzise), false) then
            vRPanticheatS.banMuist({"Arma Interzisa ["..armeInterzise.."]"})
        end
    end
end
--------------------------ARME
--------------------------Lua Injection
function checkCommands()
    local blcmds = cfg.blcmd or {}
    local regcmds = GetRegisteredCommands()
    for _, command in ipairs(regcmds) do
        for _, blcmd in pairs(blcmds) do
            if (string.lower(command.name) == string.lower(blcmd) or
                string.lower(command.name) == string.lower('+' .. blcmd) or
                string.lower(command.name) == string.lower('_' .. blcmd) or
                string.lower(command.name) == string.lower('-' .. blcmd) or
                string.lower(command.name) == string.lower('/' .. blcmd)) then
                vRPanticheatS.banMuist({"Lua Injection"})
            end
        end
    end
end
--------------------------Lua Injection
--------------------------Objects Spawning
function checkObjects(ped)
    local attObject = GetEntityAttachedTo(ped)
    if attObject and not IsEntityAVehicle(attObject) then
        DetachEntity(ped, false, false)
        ReqAndDelete(attObject)
    end
    local handle, object = FindFirstObject()
    local finished = false
    repeat
        Wait(1)
        for i=1,#cfg.obiecte do
            if GetEntityModel(object) == GetHashKey(cfg.obiecte[i]) then
                ReqAndDelete(object)
            end
        end
        finished, object = FindNextObject(handle)
    until not finished
    EndFindObject(handle)
end
--------------------------Objects Spawning
--------------------------Spectate
function checkSpectate()
    if NetworkIsInSpectatorMode() then
        vRPanticheatS.banMuistPermission({"Spectate"})
    end
end
--------------------------Spectate
--------------------------Blips
function checkBlips()
    local blip = 0
    for i = 1, 256 do
        if i ~= PlayerId() then
            if DoesBlipExist(GetBlipFromEntity(GetPlayerPed(i))) then
                blip = blip + 1
            end
        end
        if blip > 0 then
            vRPanticheatS.banMuistPermission({"Blips"})
        end
    end
end
--------------------------Blips
--------------------------Jump
function checkJumpHack(pedId)
    if IsPedJumping(pedId) then
        local jumplength = 0
        repeat
            Wait(0)
            jumplength=jumplength+1
            local isStillJumping = IsPedJumping(pedId)
        until not isStillJumping
        if jumplength > 250 then
            vRPanticheatS.sendStaffMessage({"Jump Hack (Inaltime: "..jumplength..")"})
        end
    end
end
--------------------------Jump
function checkPlate(ped)
    local veh = GetVehiclePedIsIn(ped)
    if veh then
        local plate = GetVehicleNumberPlateText(veh)
        if plate then
            for _, placuta in pairs(cfg.plates) do
                if string.lower(GetVehicleNumberPlateText(veh)) == placuta then
                    vRPanticheatS.banMuist({"Car Spawner/Plate Changer"})
                end
            end
        end
    end
end
--------------------------------------------------------6 Secunde CHECK
Citizen.CreateThread(function()
    while true do
        local pedId = PlayerPedId()
        local ped = GetPlayerPed(-1)
        -----------------------------------
        vRPanticheatS.verificaGrad({})
        checkArme(pedId)
        checkJumpHack(pedId)
        checkGodMode(ped)
        checkCar(ped)
        checkObjects(ped)
        checkPlate(ped)
        -----
        checkBlips()
        checkNpcs()
        checkCommands()
        checkSpectate()
        -----------------------------------
        Wait(6000)
    end
end)
--------------------------------------------------------6 Secunde CHECK
--------------------------------------------------------Resource Stopper
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        TriggerServerEvent("porneste:anticheat")
	end
end)
--------------------------------------------------------Resource Stopper
--------------------------------------------------------EXPLOZII
Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1)
        local pedId = PlayerPedId()
        SetPedInfiniteAmmoClip(pedId, false)
        ResetEntityAlpha(pedId)
		SetEntityProofs(GetPlayerPed(-1), false, true, true, false, false, false, false, false)
	end
end)
--------------------------------------------------------EXPLOZII

-----------------------------ENUMERATORS
local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
}
  
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
end
  
function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

function GetAllEnumerators()
    return {vehicles = EnumerateVehicles, objects = EnumerateObjects, peds = EnumeratePeds, pickups = EnumeratePickups}
end

function ReqAndDelete(object)
	if DoesEntityExist(object) then
		NetworkRequestControlOfEntity(object)
		while not NetworkHasControlOfEntity(object) do
			Citizen.Wait(1)
        end
        if IsEntityAttached(object) then
			DetachEntity(object, false, false)
        end
		SetEntityCollision(object, false, false)
		SetEntityAlpha(object, 0.0, true)
		SetEntityAsMissionEntity(object, true, true)
		SetEntityAsNoLongerNeeded(object)
        DeleteEntity(object)
	end
end