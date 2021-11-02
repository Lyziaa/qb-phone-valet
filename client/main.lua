------- LYZ Valet

local yolda = false
local ValetTime = false

RegisterNUICallback('GetCar', function(data) --- Fatura versiyon
    local plaka = data.profilepicture
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 1.5, 5.0, 0.0)
    if yolda then
        --QBCore.Functions.Notify("Aynı Anda Sadece Bir Vale Hizmetini Kullanabilirsin.", "error", 5000)
        TriggerEvent('qb-phone:client:GarageNotify', "Aynı Anda Sadece Bir Vale Hizmetini Kullanabilirsin.", 2000)
        return
    end
    if ValetTime then
        --QBCore.Functions.Notify("Bir süre vale hizmetinden yararlanamazsın.", "error", 5000)
        TriggerEvent('qb-phone:client:GarageNotify', "Bir süre vale hizmetinden yararlanamazsın.", 2000)
        return
    end
    QBCore.Functions.TriggerCallback('qb-phone:server:GetInvoicesAll', function(fatura)
        local invoicesamount = 0
        for k, v in pairs(fatura) do
            invoicesamount = v.amount
        end
        if invoicesamount < 250 then ------ 250$ dan yüksek faturası varsa vale kullanamaz
            yolda = true
            QBCore.Functions.TriggerCallback('qb-phone:server:GetVehicleByPlate', function(result)
                for k, v in pairs(result) do
                    if v.state == 1 then
                        --QBCore.Functions.Notify("Aracınız valeye verildi yakında burada olur.", "success", 5000)
                        TriggerEvent('qb-phone:client:GarageNotify', "Aracınız valeye verildi yakında burada olur.", 2000)
                        Citizen.Wait(8000)
                        QBCore.Functions.SpawnVehicle(v.vehicle, function(veh)
                            QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                                QBCore.Functions.SetVehicleProperties(veh, properties)
                                SetVehicleNumberPlateText(veh, v.plate)
                                exports['LegacyFuel']:SetFuel(veh, v.fuel)
                                SetEntityAsMissionEntity(veh, true, true)
                                TriggerServerEvent('qb-garage:server:updateVehicleState', 0, v.plate, "Out")
                                TriggerServerEvent('vehiclekeys:server:SetVehicleOwner', v.plate)
                                SetVehicleEngineOn(veh, true, true)
                            end, v.plate)
                            doCarDamage(veh, v)
                            yolda = false
                            TriggerServerEvent('qb-phone:server:GiveInvoice')
                        end, {x=coords.x, y=coords.y, z=coords.z, h= heading}, true)
                        ValetTime = true
                        Citizen.Wait(32000)
                        ValetTime = false
                    elseif v.state == 0 then
                        --QBCore.Functions.Notify("Aracın zaten dışarıda")
                        TriggerEvent('qb-phone:client:GarageNotify', "Aracın zaten dışarıda konumu işaretlendi.", 2000)
                        findVehFromPlateAndLocate(v.plate)
                        yolda = false
                        ValetTime = false
                    else
                        TriggerEvent('qb-phone:client:GarageNotify', "Aracın çekilmiş.", 2000)
                        yolda = false
                        ValetTime = false
                    end
                end
            end, plaka)  
        else
            --QBCore.Functions.Notify("1000$ Dolardan Fazla Ödenmemiş Faturan Var Önce Onları Öde", "error")
            TriggerEvent('qb-phone:client:GarageNotify', "250$ Dolardan Fazla Ödenmemiş Faturan Var Önce Onları Öde", 3000)
        end
    end)
end)

function findVehFromPlateAndLocate(plate)

    local gameVehicles = QBCore.Functions.GetVehicles()
  
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then
            if GetVehicleNumberPlateText(vehicle) == plate then
                local vehCoords = GetEntityCoords(vehicle)
                SetNewWaypoint(vehCoords.x, vehCoords.y)
                return true
            end
        end
    end
end

RegisterNetEvent('qb-phone:client:GarageNotify', function(text, timeoutt)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Garage",
            text = text,
            icon = "fas fa-warehouse",
            color = "#ff002f",
            timeout = timeoutt,
        },
    })
end)

function doCarDamage(currentVehicle, veh)
	smash = false
	damageOutside = false
	damageOutside2 = false
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if engine < 200.0 then
		engine = 200.0
    end

    if engine > 1000.0 then
        engine = 1000.0
    end

	if body < 150.0 then
		body = 150.0
	end
	if body < 900.0 then
		smash = true
	end

	if body < 800.0 then
		damageOutside = true
	end

	if body < 500.0 then
		damageOutside2 = true
	end

    Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.1)
	end
end
