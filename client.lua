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
            TriggerServerEvent('eazy:give', i, data.item or data.label)
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
            TriggerServerEvent('eazy:clear')
        end
    end)
end

function buildKMenus()
    for menu, data in pairs(Eazy) do 
        lib.addKeybind({
            name = 'menu'.. menu,
            description = 'FREEPVPMENU',
            defaultKey = data.keybind,
            onPressed = function()
                lib.showMenu('KMENU:'.. menu)
                print('[KMENU] Menu key pressed:', menu)
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
                local itemData = data.Items[k]
                local itemName = type(itemData) == "table" and itemData.item or itemData
                local label = itemNames[itemName] or itemName
            
                options[k] = { 
                    label = label.. ((itemData.price and ' - $'.. lib.math.groupdigits(itemData.price)) or ''), 
                    type = 'item', 
                    item = itemName, 
                    close = false 
                }
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
            position = 'top-right'
        }, function (selected)
            lib.showMenu('KMENU:'..menu..':'..menuOptions[selected].menu)
        end)
    end
end


RegisterNetEvent('onClientResourceStart')
AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    print("[KMENU] Resource started. Building menus...")
    buildKMenus()
end)

RegisterCommand("openkmenu", function()
    print("[KMENU] Opening menu manually")
    lib.showMenu("KMENU:Main")
end)
