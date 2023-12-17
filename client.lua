local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("code_relacionamentos",src)

vSERVER = Tunnel.getInterface("code_relacionamentos")

vHOSPITAL = Tunnel.getInterface("vrp_player")

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMATIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local animacoes = {
	{ nome = "ajoelhar" , dict = "amb@medic@standing@kneel@idle_a" , anim = "idle_a" , andar = false , loop = true },
	{ nome = "buque" , prop = "prop_snow_flower_02" , flag = 50 , hand = 60309 , pos1 = 0.0 , pos2 = 0.0 , pos3 = 0.0 , pos4 = 300.0 , pos5 = 0.0 , pos6 = 0.0 },
}
RegisterNetEvent('animations:UseWandelStok')
AddEventHandler('animations:UseWandelStok', function()
    local ped = PlayerPedId()
    if not WalkstickUsed then
        RequestAnimSet('move_heist_lester')
        while not HasAnimSetLoaded('move_heist_lester') do
            Citizen.Wait(1)
        end
        SetPedMovementClipset(ped, 'move_heist_lester', 1.0) 
        WandelstokObject = CreateObject(GetHashKey("prop_cs_walking_stick"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(WandelstokObject, ped, GetPedBoneIndex(ped, 57005), 0.16, 0.06, 0.0, 335.0, 300.0, 120.0, true, true, false, true, 5, true)
    else
        ResetPedMovementClipset(ped,0.25)
        DetachEntity(WandelstokObject, 0, 0)
        DeleteEntity(WandelstokObject)
    end
    WalkstickUsed = not WalkstickUsed
end)


RegisterNetEvent('emotes2')
AddEventHandler('emotes2',function(nome)
	local ped = PlayerPedId()
	if GetEntityHealth(ped) > 101 then
		if not vRP.isHandcuffed() then
			vRP.DeletarObjeto("one")
			for _,emote in pairs(animacoes) do
				if not IsPedInAnyVehicle(ped) and not emote.carros then
					if nome == emote.nome then
						if emote.extra then emote.extra() end
						if emote.propAnim then 
							vRP.CarregarObjeto(emote.dict,emote.anim,emote.prop,emote.flag,emote.hand,emote.pos1,emote.pos2,emote.pos3,emote.pos4,emote.pos5,emote.pos6)
						elseif emote.pos1 then
							vRP.CarregarObjeto("","",emote.prop,emote.flag,emote.hand,emote.pos1,emote.pos2,emote.pos3,emote.pos4,emote.pos5,emote.pos6)
						elseif emote.prop then
							vRP.CarregarObjeto(emote.dict,emote.anim,emote.prop,emote.flag,emote.hand)
						elseif emote.dict then
							vRP._playAnim(emote.andar,{emote.dict,emote.anim},emote.loop)
						else
							vRP._playAnim(false,{task=emote.anim},false)
						end
					end
				else
					if IsPedInAnyVehicle(ped) and emote.carros then
						local vehicle = GetVehiclePedIsIn(ped,false)
						if nome == emote.nome then
							if (GetPedInVehicleSeat(vehicle,-1) == ped or GetPedInVehicleSeat(vehicle,1) == ped) and emote.nome == "sexo4" then
								vRP._playAnim(emote.andar,{emote.dict,emote.anim},emote.loop)
							elseif (GetPedInVehicleSeat(vehicle,0) == ped or GetPedInVehicleSeat(vehicle,2) == ped) and (emote.nome == "sexo5" or emote.nome == "sexo6") then
								vRP._playAnim(emote.andar,{emote.dict,emote.anim},emote.loop)
							end
						end
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCED ANIMATIONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('syncAnim2')
AddEventHandler('syncAnim2',function(pos)
	local ped = PlayerPedId()
 	local pedInFront = GetPlayerPed(GetClosestPlayer())
    local heading = GetEntityHeading(pedInFront)
    local coords = GetOffsetFromEntityInWorldCoords(pedInFront,0.0,pos,0.0)
    SetEntityHeading(ped,heading-180.1)
    SetEntityCoordsNoOffset(ped,coords.x,coords.y,coords.z,0)
end)

RegisterNetEvent('syncAnimAll2')
AddEventHandler('syncAnimAll2',function(status,person)
	vRP.DeletarObjeto()
	if status == "beijar" then
		vRP._playAnim(false, {"mp_ped_interaction", "kisses_guy_a"}, false)
		vRP._playAnim(false,{"mp_ped_interaction","kisses_guy_a"},false)
	elseif status == "abracar" then
		vRP._playAnim(false,{"mp_ped_interaction","hugs_guy_a"},false)
	elseif status == "abracar2" then
		vRP._playAnim(false,{"mp_ped_interaction","kisses_guy_b"},false)
	elseif status == "abracar3" then
		vRP._playAnim(false,{"mp_ped_interaction","handshake_guy_a"},false)
	elseif status == "abracar4" then
		vRP._playAnim(false,{"mp_ped_interaction","handshake_guy_b"},false)
	elseif status == "dancar257" then
		vRP._playAnim(false,{"anim@amb@nightclub@lazlow@hi_railing@","ambclub_13_mi_hi_sexualgriding_laz"},false)
		vRP.CarregarObjeto("","","ba_prop_battle_glowstick_01",49,28422,0.0700,0.1400,0.0,-80.0,20.0)
		vRP.CarregarObjeto2("","","ba_prop_battle_glowstick_01",49,60309,0.0700,0.0900,0.0,-120.0,-20.0)
	elseif status == "dancar258" then
		vRP._playAnim(false,{"anim@amb@nightclub@lazlow@hi_railing@","ambclub_12_mi_hi_bootyshake_laz"},false)
		vRP.CarregarObjeto("","","ba_prop_battle_glowstick_01",49,28422,0.0700,0.1400,0.0,-80.0,20.0)
		vRP.CarregarObjeto2("","","ba_prop_battle_glowstick_01",49,60309,0.0700,0.0900,0.0,-120.0,-20.0)
	elseif status == "dancar259" then
		vRP._playAnim(false,{"anim@amb@nightclub@lazlow@hi_dancefloor@","crowddance_hi_11_handup_laz"},false)
		vRP.CarregarObjeto("","","ba_prop_battle_hobby_horse",49,28422,0.0,0.0,0.0,0.0,0.0,0.0)
	elseif status == "casal" then
		if person == 1 then
			vRP._playAnim(false,{"misscarsteal2chad_goodbye","chad_armsaround_girl"},true)
		elseif person == 2 then
			vRP._playAnim(false,{"misscarsteal2chad_goodbye","chad_armsaround_chad"},true)
		end
	elseif status == "casal2" then
		if person == 1 then
			vRP._playAnim(false,{"timetable@trevor@ig_1","ig_1_thedontknowwhy_patricia"},true)
		elseif person == 2 then
			vRP._playAnim(false,{"timetable@trevor@ig_1","ig_1_thedontknowwhy_trevor"},true)
		end
	elseif status == "casal3" then
		if person == 1 then
			vRP._playAnim(false,{"timetable@trevor@ig_1","ig_1_thedesertissobeautiful_patricia"},true)
		elseif person == 2 then
			vRP._playAnim(false,{"timetable@trevor@ig_1","ig_1_thedesertissobeautiful_trevor"},true)
		end
	end
end)