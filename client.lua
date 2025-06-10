local itemNames = {}

for item, data in pairs(exports.ox_inventory:Items()) do
    itemNames[item] = data.label
end

local function createMenu(i, menu, label, options)
    lib.registerMenu({
        id = 'KMENU:'..i..':'..menu,
        title = label..' Menu',
        options = options,
        position = 'bottom-right',
        onClose = function()
            lib.showMenu('KMENU:'.. i)
        end,
    }, function(selected)
        local data = options[selected]

        if data.type == 'weapon' or data.type == 'item' then 
            TriggerServerEvent('eazy:give', menu, selected)
        elseif data.type == 'teleport' then 
            DoScreenFadeOut(100) 
            StartPlayerTeleport(cache.playerId, data.coords, 0.0, false, true, true) 
            while IsPlayerTeleportActive() do Wait(0) end
            DoScreenFadeIn(1000)
        elseif data.type == 'teleport_category' then 
            lib.showMenu('KMENU:'..i..':TELEPORTS:'..data.label)
        elseif data.type == 'vehicles' then 
            lib.requestModel(data.car)

            local coords = GetEntityCoords(cache.ped)
            local vehicle = CreateVehicle(joaat(data.car), coords.xyz, 90, true, false)
            lib.waitFor(function()
                if vehicle then
                    SetVehicleOnGroundProperly(vehicle)
                    return TaskWarpPedIntoVehicle(cache.ped, vehicle, -1) 
                end
            end)       
        elseif data.type == 'Skin' then 
            TriggerEvent('illenium-appearance:client:openClothingShop')
        elseif data.type == 'Armor' then
            SetPedArmour(cache.ped, 100)
        else
            TriggerServerEvent(':clear')
        end
    end)
end

AddEventHandler('esx:playerLoaded', function ()
      

    for menu, data in pairs(Config) do 
        lib.addKeybind({
            name = 'menu'.. menu,
            description = 'Donate 4 More Options',
            defaultKey = data.keybind,
            onPressed = function()
                lib.showMenu('KMENU:'.. menu)

            end,
        })

        local menuOptions = {}

        if data.Teleports then 
            menuOptions[#menuOptions+1] = { icon = 'angles-right', label = 'Teleports', menu = 'TELEPORTS' }

            local options = {}

            for category, teleports in pairs(data.Teleports) do 
                local tps = {}

                for l = 1, #teleports do 
                    local teleport = teleports[l]
                    teleport.close = false
                    teleport.type = 'teleport'
                    teleport.category = category

                    tps[l] = teleport
                end

                createMenu(menu, 'TELEPORTS:'..category, category, tps)
                options[#options+1] = { label = category, type = 'teleport_category' }
            end

            createMenu(menu, 'TELEPORTS', 'Teleports', options)
        end 

        if data.Items then 
            menuOptions[#menuOptions + 1] = { icon = 'box', label = 'Items', menu = 'ITEMS' }

            local options = {}

            for k = 1, #data.Items do 
                local item = data.Items[k]
                local label = itemNames[item?.item] or 'No Label Found'
                options[k] = { label = label.. ((item.price and ' - $'.. lib.math.groupdigits(item.price)) or ''), type = 'item', close = false }
            end     

            createMenu(menu, 'ITEMS', 'Items', options)
        end

        if data.Vehicles then 
            menuOptions[#menuOptions + 1] = { icon = 'car', label = 'Vehicles', menu = 'VEHICLES' }

            local options = {}

            for k = 1, #data.Vehicles do 
                local car = data.Vehicles[k]
                options[k] = { label = GetDisplayNameFromVehicleModel(car), icon = 'car', car = car, type = 'vehicles', close = false }
            end     

            createMenu(menu, 'VEHICLES', 'Vehicles', options)
        end

        menuOptions[#menuOptions+1] = { icon = 'Gear', label = 'Misc', menu = 'Misc' }
        createMenu(menu, 'Misc', 'Misc', {
            {label = 'Clear Inventory', close = false},
            {label = 'Skin', type = 'Skin'},
            {label = '100% Armor', type = 'Armor'},
        })

        lib.registerMenu({
            id = 'KMENU:'..menu,
            title = 'Donate For MORE Options',
            options = menuOptions,
            position = 'bottom-right'
        }, function (selected)
            lib.showMenu('KMENU:'..menu..':'..menuOptions[selected].menu)
        end)

    end

end)