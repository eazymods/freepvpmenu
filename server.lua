local oxInv = exports.ox_inventory

RegisterNetEvent('eazy:give', function (menu, index)
    local data = Config[menu].Items[index]
    if not data then return end 
    oxInv:AddItem(source, data.item, data.amount or 1)
end)

RegisterNetEvent('eazy:clear', function ()
    oxInv:ClearInventory(source)
end)