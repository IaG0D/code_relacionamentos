local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Tools = module("vrp", "lib/Tools")
vRP = Proxy.getInterface("vRP")

vRPclient = Tunnel.getInterface("vRP")
Code = Tunnel.getInterface("code_relacionamentos")

vCode = {}
Tunnel.bindInterface("code_identidade",vCode)
Proxy.addInterface("code_identidade",vCode)

vRP._prepare("code_relacionamentos/get", "SELECT * FROM code_relacionamentos WHERE id = @id")
vRP._prepare("code_relacionamentos/get_id", "SELECT id FROM code_relacionamentos WHERE id = @id");
vRP._prepare("code_relacionamentos/get_status", "SELECT status FROM code_relacionamentos WHERE id = @id");
vRP._prepare("code_relacionamentos/set_id","INSERT INTO code_relacionamentos(id,status) VALUES(@id,@status)")
vRP.prepare("code_relacionamentos/update_status","UPDATE code_relacionamentos SET id2 = @id2, status = @status WHERE id = @id")
function getStatus(id)
    local result = vRP.query("code_relacionamentos/get",{id = id})
    local status = result[1].status
    return tostring(status)
end
function getId2(id)
    local result = vRP.query("code_relacionamentos/get",{id = id})
    local id2 = result[1].id2
    return id2
end
function getMyId(id)
    local result = vRP.query("code_relacionamentos/get",{id = id})
    local myid = result[1].id
    return myid
end
function setStatus(id,id2,status)
    vRP.execute("code_relacionamentos/update_status",{id = parseInt(id), id2 = parseInt(id2), status = status})
end
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    local id = vRP.getUserId(source);
    local verificar = vRP.query("code_relacionamentos/get_id", { id = tonumber(id) });
    if #verificar < 1 then
        vRP.execute("code_relacionamentos/set_id",{id = id, status = "Solteiro(a)"})
    end
    if not vRP.hasPermission(id, "cidadao.permissao") then
        vRP.addUserGroup(id, "Cidadao")
    end
    if vRP.hasPermission(user_id, "resgatar1.permissao") then
		
	else
        Citizen.Wait(15000)
		TriggerClientEvent('notify',source,'importante','Você tem veículos para serem resgatados /resgatarcarros',4000)
        TriggerClientEvent("vrp_sound:source",source,'coins',0.5)
	end
end)
RegisterCommand('relacionamento', function(source, args, RawCommand)
    vRP.antiflood(source,"relacionamento",3)
    local user_id = vRP.getUserId(source);
    local nuser_id = args[1];
    local identity = vRP.getUserIdentity(user_id)
    if args[1] == nil or args[1] == " " then
        if getId2(user_id) == 0 or getId2(user_id) == nil then
            TriggerClientEvent("notify",source,"aviso","<b>"..identity.name.." "..identity.firstname.."</b> | "..user_id..
            "<br><b>Status: </b>"..getStatus(user_id)..
            "<br><b>Parceiro(a): </b>Ninguém",10000)
        else
            local id2 = getId2(user_id)
            local identity2 = vRP.getUserIdentity(id2)
            TriggerClientEvent("notify",source,"aviso","<b>"..identity.name.." "..identity.firstname.."</b> | "..user_id..
            "<br><b>Status: </b>"..getStatus(user_id)..
            "<br><b>Parceiro(a): </b>"..identity2.name.." "..identity2.firstname.." | "..id2.."",10000)
        end
    else
        if vRP.hasPermission(user_id, "staff.permissao") then
            if getId2(nuser_id) == 0 or getId2(nuser_id) == nil then
                local identity = vRP.getUserIdentity(nuser_id)
                TriggerClientEvent("notify",source,"aviso","<b>"..identity.name.." "..identity.firstname.."</b> | "..nuser_id..
                "<br><b>Status: </b>"..getStatus(nuser_id)..
                "<br><b>Parceiro(a): </b>Ninguém",5000)
            else
                local id2 = getId2(nuser_id)
                local identity = vRP.getUserIdentity(nuser_id)
                local identity2 = vRP.getUserIdentity(id2)
                TriggerClientEvent("notify",source,"aviso","<b>"..identity.name.." "..identity.firstname.."</b> | "..nuser_id..
                "<br><b>Status: </b>"..getStatus(nuser_id)..
                "<br><b>Parceiro(a): </b>"..identity2.name.." "..identity2.firstname.." | "..id2.."",10000)
            end
        else
            local id2 = getId2(user_id)
            local identity2 = vRP.getUserIdentity(id2)
            TriggerClientEvent("notify",source,"aviso","<b>"..identity.name.." "..identity.firstname.."</b> | "..user_id..
            "<br><b>Status: </b>"..getStatus(user_id)..
            "<br><b>Parceiro(a): </b>"..identity2.name.." "..identity2.firstname.." | "..id2.."",10000)
        end
    end
end)
RegisterCommand('terminar', function(source, args, RawCommand)
    local user_id = vRP.getUserId(source);
    local identity = vRP.getUserIdentity(user_id)
    if getStatus(user_id) == "Solteiro(a)" then
        TriggerClientEvent("notify",source,"aviso","<b>Para terminar primeiro você precisa estar comprometido 😅!",10000)
     else
            local nuser_id = getId2(user_id)
            local identity2 = vRP.getUserIdentity(nuser_id)
        if vRP.request(source,"Você deseja terminar com: <b>"..identity2.name.." " ..identity2.firstname.."</b> ?",30) then
            TriggerClientEvent("notify",source,"aviso","Você terminou com <b>"..identity2.name.. " "..identity2.firstname.." 💔.",10000)
            TriggerClientEvent("notify",nuser_id,"aviso","<b>"..identity.name.. " "..identity.firstname.."</b> terminou com você 💔.",10000)
            TriggerClientEvent('chatMessage', -1, "", { 0, 0, 0 }," <b>"..identity.name.." " ..identity.firstname.. "</b> e <b>"
                        ..identity2.name.. " "..identity2.firstname.. "</b> terminaram💔!")
            Citizen.Wait(500)
            setStatus(user_id,0,"Solteiro(a)")
            Citizen.Wait(500)
            setStatus(nuser_id,0,"Solteiro(a)")
        end
    end

end)
RegisterCommand('namorar', function(source, args, RawCommand)
    vRP.antiflood(source,"namorar",5)
    local user_id = vRP.getUserId(source);
    local nplayer = vRPclient.getNearestPlayer(source,3)
    local nuser_id = vRP.getUserId(nplayer)
    
    local identity = vRP.getUserIdentity(user_id)
    if nuser_id == nil or nuser_id < 1 or nuser_id == " " then
        TriggerClientEvent("notify",source,"aviso","<b>Você precisa estar perto de alguém!",10000)
    else
        if vRP.getInventoryItemAmount(user_id,"aliancanamoro") >= 2 then
            local identity2 = vRP.getUserIdentity(nuser_id)
            if getStatus(user_id) == "Solteiro(a)" and getStatus(nuser_id) == "Solteiro(a)" then
                TriggerClientEvent("notify",source,"importante","<b>Pedido de namoro enviado para:</b> "..identity2.name.." "..identity2.firstname.."",10000)
                Citizen.Wait(500)
                TriggerClientEvent("emotes2",source,"ajoelhar")
                TriggerClientEvent("emotes2",source,"buque")
                if vRP.request(nplayer,"Você deseja aceitar o pedido de namoro de: <b>"..identity.name.." " ..identity.firstname.."</b> ?",30) then
                    if vRP.tryGetInventoryItem(user_id, "aliancanamoro", 2, true) then
                        TriggerClientEvent("notify",source,"sucesso","<b>Parabéns agora você está namorando🥰!</b>",10000)
                        TriggerClientEvent("notify",nplayer,"sucesso","<b>Parabéns agora você está namorando🥰!</b>",10000)
                        vRPclient._DeletarObjeto(source)
                        vRPclient._StopAnim(source)
                        Citizen.Wait(500)
                        TriggerClientEvent("syncAnim2",source,1.3)
					    TriggerClientEvent("syncAnimAll2",source,"abracar")
					    TriggerClientEvent("syncAnimAll2",nplayer,"abracar")
                        vRP.giveInventoryItem(user_id, "aliancanamorousada", 1, true)
                        vRP.giveInventoryItem(nuser_id, "aliancanamorousada", 1, true)
                        TriggerClientEvent('chatMessage', -1, "", { 255, 51, 102 }," <b>"..identity.name.." " ..identity.firstname.. "</b> e <b>"
                        ..identity2.name.. " "..identity2.firstname.. "</b> estão <b>namorando</b>💞!")
                        Citizen.Wait(200)
                        setStatus(user_id,nuser_id,"Namorando")
                        Citizen.Wait(200)
                        setStatus(nuser_id,user_id,"Namorando")
                    else
                        TriggerClientEvent("notify",source,"negado","Algo deu errado, tente novamente mais tarde!",10000)
                    end
                else
                    TriggerClientEvent("notify",source,"negado","<b>Você foi rejeitado😕!</b>",10000)
                    Citizen.Wait(500)
                    vRPclient._DeletarObjeto(source)
                    vRPclient._StopAnim(source)
                    Citizen.Wait(500)
                    TriggerClientEvent("emotes2",source,"triste")
                end
                --Nenhum Comprometido
            else
                --Algum comprometido
                TriggerClientEvent("notify",source,"negado","Um dos dois já é comprometido 😕!",10000)
            end
        else
            TriggerClientEvent("notify",source,"negado","Você precisa de duas Aliança de Namoro no inventário 💍!",10000)
        end
    end
    
end)

RegisterCommand('noivar', function(source, args, RawCommand)
    vRP.antiflood(source,"noivar",5)
    local user_id = vRP.getUserId(source);
    local nplayer = vRPclient.getNearestPlayer(source,3)
    local nuser_id = vRP.getUserId(nplayer)
    
    local identity = vRP.getUserIdentity(user_id)
    if nuser_id == nil or nuser_id < 1 or nuser_id == " " then
        TriggerClientEvent("notify",source,"aviso","<b>Você precisa estar perto de seu namorado(a)!",10000)
    else
        if vRP.getInventoryItemAmount(user_id,"aliancanoivado") >= 2 then
            local identity2 = vRP.getUserIdentity(nuser_id)
            if getStatus(user_id) == "Namorando" and getStatus(nuser_id) == "Namorando" then
            if getId2(user_id) == nuser_id then
                TriggerClientEvent("notify",source,"importante","<b>Pedido de noivado enviado para:</b> "..identity2.name.." "..identity2.firstname.."",10000)
                Citizen.Wait(500)
                TriggerClientEvent("emotes2",source,"ajoelhar")
                TriggerClientEvent("emotes2",source,"buque")
                if vRP.request(nplayer,"Você deseja aceitar o pedido de noivado de: <b>"..identity.name.." " ..identity.firstname.."</b> ?",30) then
                    if vRP.tryGetInventoryItem(user_id, "aliancanoivado", 2, true) then
                        TriggerClientEvent("notify",source,"sucesso","<b>Parabéns agora você está noivo(a)🥰!</b>",10000)
                        TriggerClientEvent("notify",nplayer,"sucesso","<b>Parabéns agora você está noivo(a)🥰!</b>",10000)
                        vRPclient._DeletarObjeto(source)
                        vRPclient._StopAnim(source)
                        Citizen.Wait(500)
                        TriggerClientEvent("syncAnim2",source,1.3)
					    TriggerClientEvent("syncAnimAll2",source,"beijar")
					    TriggerClientEvent("syncAnimAll2",nplayer,"beijar")
                        vRP.giveInventoryItem(user_id, "aliancanoivadousada", 1, true)
                        vRP.giveInventoryItem(nuser_id, "aliancanoivadousada", 1, true)
                        TriggerClientEvent('chatMessage', -1, "", { 199,21,133 }," <b>"..identity.name.." " ..identity.firstname.. "</b> e <b>"
                        ..identity2.name.. " "..identity2.firstname.. "</b> estão <b>noivos</b>💞!")
                        Citizen.Wait(200)
                        setStatus(user_id,nuser_id,"Noivo(a)")
                        Citizen.Wait(200)
                        setStatus(nuser_id,user_id,"Noivo(a)")
                    else
                        TriggerClientEvent("notify",source,"negado","Algo deu errado, tente novamente mais tarde!",10000)
                    end
                else
                    TriggerClientEvent("notify",source,"negado","<b>Seu pedido de noivado foi rejeitado😕!</b>",10000)
                    Citizen.Wait(500)
                    vRPclient._DeletarObjeto(source)
                    vRPclient._StopAnim(source)
                    Citizen.Wait(500)
                    TriggerClientEvent("emotes2",source,"triste")
                end
            else
                TriggerClientEvent("notify",source,"negado","Você só pode pedir em noivado seu/sua parceiro(a)!",10000)
            end
                --Nenhum Comprometido
            else
                --Algum comprometido
                TriggerClientEvent("notify",source,"negado","Primeiro você precisa estar namorando a pessoa utilize: /namorar ",10000)
            end
        else
            TriggerClientEvent("notify",source,"negado","Você precisa de duas Aliança de Noivado no inventário 💍!",10000)
        end
    end
    
end)

RegisterCommand('casar', function(source, args, RawCommand)
    vRP.antiflood(source,"casar",5)
    local user_id = vRP.getUserId(source);
    local nplayer = vRPclient.getNearestPlayer(source,3)
    local nuser_id = vRP.getUserId(nplayer)
    
    local identity = vRP.getUserIdentity(user_id)
    if nuser_id == nil or nuser_id < 1 or nuser_id == " " then
        TriggerClientEvent("notify",source,"aviso","<b>Você precisa estar perto de seu noivo(a)!",10000)
    else
        if vRP.getInventoryItemAmount(user_id,"aliancacasamento") >= 2 then
            local identity2 = vRP.getUserIdentity(nuser_id)
            if getStatus(user_id) == "Noivo(a)" and getStatus(nuser_id) == "Noivo(a)" then
            if getId2(user_id) == nuser_id then
                TriggerClientEvent("notify",source,"importante","<b>Pedido de casamento enviado para:</b> "..identity2.name.." "..identity2.firstname.."",10000)
                Citizen.Wait(500)
                TriggerClientEvent("emotes2",source,"ajoelhar")
                TriggerClientEvent("emotes2",source,"buque")
                if vRP.request(nplayer,"Você deseja aceitar o pedido de casamento de: <b>"..identity.name.." " ..identity.firstname.."</b> ?",30) then
                    if vRP.tryGetInventoryItem(user_id, "aliancacasamento", 2, true) then
                        TriggerClientEvent("notify",source,"sucesso","<b>Parabéns agora você está casado(a)🥰!</b>",10000)
                        TriggerClientEvent("notify",nplayer,"sucesso","<b>Parabéns agora você está casado(a)🥰!</b>",10000)
                        vRPclient._DeletarObjeto(source)
                        vRPclient._StopAnim(source)
                        Citizen.Wait(500)
                        TriggerClientEvent("syncAnim2",source,1.3)
					    TriggerClientEvent("syncAnimAll2",source,"beijar")
					    TriggerClientEvent("syncAnimAll2",nplayer,"beijar")
                        vRP.giveInventoryItem(user_id, "aliancacasamentousada", 1, true)
                        vRP.giveInventoryItem(nuser_id, "aliancacasamentousada", 1, true)
                        TriggerClientEvent('chatMessage', -1, "", { 199,21,133 }," <b>"..identity.name.." " ..identity.firstname.. "</b> e <b>"
                        ..identity2.name.. " "..identity2.firstname.. "</b> estão <b>casados</b>💞!")
                        Citizen.Wait(200)
                        setStatus(user_id,nuser_id,"Casado(a)")
                        Citizen.Wait(200)
                        setStatus(nuser_id,user_id,"Casado(a)")
                    else
                        TriggerClientEvent("notify",source,"negado","Algo deu errado, tente novamente mais tarde!",10000)
                    end
                else
                    TriggerClientEvent("notify",source,"negado","<b>Seu pedido de casamento foi rejeitado😕!</b>",10000)
                    Citizen.Wait(500)
                    vRPclient._DeletarObjeto(source)
                    vRPclient._StopAnim(source)
                    Citizen.Wait(500)
                    TriggerClientEvent("emotes2",source,"triste")
                end
            else
                TriggerClientEvent("notify",source,"negado","Você só pode pedir em casamento seu/sua parceiro(a)!",10000)
            end
                --Nenhum Comprometido
            else
                --Algum comprometido
                TriggerClientEvent("notify",source,"negado","Primeiro você precisa estar casado(a) da pessoa utilize: /noivar ",10000)
            end
        else
            TriggerClientEvent("notify",source,"negado","Você precisa de duas Aliança de Casamento no inventário 💍!",10000)
        end
    end
    
end)

