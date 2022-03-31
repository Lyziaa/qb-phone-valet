QBCore.Functions.CreateCallback("qb-phone:server:GetVehicleByPlate", function(source, cb, plate)
    local src = source
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?',{plate}, function(result)
        if result[1] ~= nil then
             cb(result)
        else
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('qb-phone:server:GetInvoicesAll', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
	MySQL.Async.fetchAll('SELECT SUM(amount) AS "amount" FROM phone_invoices WHERE citizenid = ?',{xPlayer.PlayerData.citizenid}, function(data)
		cb(tonumber(data[1]["amount"]))
	end)
    end
end)

RegisterNetEvent('qb-phone:server:GiveInvoice', function()
  local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        MySQL.Async.insert('INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (?, ?, ?, ?, ?)',{Player.PlayerData.citizenid, 100, "Garaj", "Vale", "Garaj"})
        TriggerClientEvent('qb-phone:RefreshPhone', Player.PlayerData.source)
        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'Yeni Fatura Alındı')
    end
end)
