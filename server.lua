local oxInv = exports.ox_inventory

RegisterNetEvent('eazy:give', function(menu, itemName)
    local xPlayer = source
    local menuData = Eazy[menu]
    if not menuData or not menuData.Items then 
        print("[EAZY ERROR] Menu not found:", menu)
        return 
    end

    for _, item in pairs(menuData.Items) do
        if type(item) == "string" and item == itemName then
            exports.ox_inventory:AddItem(xPlayer, itemName, 1)
            return
        elseif type(item) == "table" and item.item == itemName then
            exports.ox_inventory:AddItem(xPlayer, itemName, item.amount or 1)
            return
        end
    end

    print("[EAZY ERROR] Item not found in menu:", itemName)
end)

RegisterNetEvent('eazy:clear', function ()
    oxInv:ClearInventory(source)
end)
