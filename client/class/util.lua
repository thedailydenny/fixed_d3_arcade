function showSubtitle(message, time)
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandPrint(time, 1)
end

function playerBuyTicketMenu()
    local options = {}

    for k, v in pairs(Config.ticketPrice) do
        table.insert(options, {
            title = _U("ticket_label", k),
            description = "$" .. v.price,
            icon = 'fas fa-ticket',
            onSelect = function()
                TriggerServerEvent("d3-arcade:buyTicket", k)
            end
        })
    end

    lib.registerContext({
        id = 'ticket_menu',
        title = _U("ticket_menu"),
        options = options
    })

    lib.showContext('ticket_menu')
end

function returnTicketMenu()
    lib.registerContext({
        id = 'return_menu',
        title = _U("give_back_ticket"),
        options = {
            {
                title = _U("yes"),
                icon = 'fas fa-check',
                onSelect = function()
                    minutes = 0
                    seconds = 0
                    gotTicket = false
                end
            },
            {
                title = _U("no"),
                icon = 'fas fa-times',
                onSelect = function()
                    -- Just close the menu
                end
            }
        }
    })

    lib.showContext('return_menu')
end

function showNotification(text)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
    DrawNotification(0, 1)
end

function createBlip(name, blip, coords, options)
    local x, y, z = table.unpack(coords)
    local ourBlip = AddBlipForCoord(x, y, z)
    SetBlipSprite(ourBlip, blip)
    if options.type then SetBlipDisplay(ourBlip, options.type) end
    if options.scale then SetBlipScale(ourBlip, options.scale) end
    if options.color then SetBlipColour(ourBlip, options.color) end
    if options.shortRange then SetBlipAsShortRange(ourBlip, options.shortRange) end
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(ourBlip)
    return ourBlip
end

function createLocalPed(pedType, model, position, heading, cb)
    requestModel(model, function()
        local ped = CreatePed(pedType, model, position.x, position.y, position.z, heading, false, false)
        SetPedComponentVariation(ped, 0, 0, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 0, 0, 0)
        SetPedComponentVariation(ped, 3, 0, 0, 0)
        SetPedComponentVariation(ped, 4, 0, 0, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 0, 0, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 0, 0, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 0, 0, 0)
        SetPedPropIndex(ped, 0, 1, 0, true)
        SetModelAsNoLongerNeeded(model)
        cb(ped)
    end)
end

function requestModel(modelName, cb)
    if type(modelName) ~= 'number' then
        modelName = GetHashKey(modelName)
    end

    local breaker = 0

    RequestModel(modelName)

    while not HasModelLoaded(modelName) do
        Citizen.Wait(1)
        breaker = breaker + 1
        if breaker >= 100 then
            break
        end
    end

    if breaker >= 100 then
        cb(false)
    else
        cb(true)
    end
end

function openComputerMenu(listGames, computer_)
    local computer = computer_
    if Config.enableGameHouse and not gotTicket and computer.isInGamingHouse then
        showNotification(_U("need_to_buy_ticket"))
        return
    end

    local options = {}

    for key, value in pairs(listGames) do
        table.insert(options, {
            title = value.name,
            icon = 'fas fa-gamepad',
            onSelect = function()
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local rot = GetEntityRotation(ped)
            local closestDistance = 6
            local closestPos = nil
            local closestObj = nil
            if computer.seatHash ~= nil then
                local obj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, computer.seatHash, false, true, true)
                if obj ~= nil and obj ~= 0 then
                    local objPos = GetEntityCoords(obj)
                    closestPos = objPos
                    closestObj = obj
                    local dict = "amb@prop_human_seat_computer@male@base"
                    RequestAnimDict(dict)
                    while not HasAnimDictLoaded(dict) do 
                        Citizen.Wait(100)
                    end
                    local rotation = GetEntityRotation(closestObj)
                    local targetPos = closestPos + vector3(0,0, 0.5)
                    DisableCamCollisionForEntity(closestObj)
                    FreezeEntityPosition(ped, true)
                    TaskPlayAnimAdvanced(ped, dict, "base", targetPos.x, targetPos.y, targetPos.z, rotation.x, rotation.y, rotation.z + 180, 1.0, 1.0, -1, 1, 0.0, 0, 0)
                    Wait(3000)
                end
            else
                local closestHash = nil
                for i = 1, #Config.ArcadeModels do
                    local hash = Config.ArcadeModels[i]
                    local obj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, hash, false, true, true)
                    if obj ~= nil and obj ~= 0 then
                        local objPos = GetEntityCoords(obj)
                        local distance = Absf(#(objPos - pos))
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPos = objPos
                            closestObj = obj
                            closestHash = hash
                        end
                    end
                end
                if closestObj ~= nil then
                    local dict = "anim_casino_a@amb@casino@games@arcadecabinet@maleright"
                    RequestAnimDict(dict)
                    while not HasAnimDictLoaded(dict) do 
                        Citizen.Wait(100)
                    end
                    local heading = GetEntityHeading(closestObj)
                    local forward, right, _, _ = GetEntityMatrix(closestObj)
                    local targetPos = closestPos + (forward * - 0.8) + (right * - 0.01)
                    if closestHash == -1991361770 then -- (qub3d machine) 2 joysticks instead of 1...
                        targetPos = targetPos + (right * - 0.18)
                    end
                    local sequence = OpenSequenceTask()
                    TaskPedSlideToCoord(0, targetPos.x, targetPos.y, targetPos.z, heading, 1.0)
                    TaskPlayAnim(0, dict, "insert_coins", 8.0, 8.0, -1, 0, 0, false, false, false)
                    TaskPlayAnim(0, dict, "playidle_v2", 8.0, 8.0, -1, 1, 0, false, false, false)
                    CloseSequenceTask(sequence)
                    TaskPerformSequence(ped, sequence)
                    ClearSequenceTask(sequence)
                    Wait(GetAnimDuration(dict, "insert_coins") * 1000)
                end
            end
            usingComputer = true
            CreateThread(function()
                while usingComputer do
                        -- disable all controls while in game
                        -- prevents gamepads from controlling gta character
                        Wait(0)   
                        DisableAllControlActions(0)
                        DisableAllControlActions(1)
                        DisableAllControlActions(2)
                end
            end)
            SendNUIMessage({
                type = "on",
                game = value.link,
                gpu = computer.computerGPU,
                cpu = computer.computerCPU
            })
            SetNuiFocus(true, true)
            end
        })
    end

    lib.registerContext({
        id = 'game_menu',
        title = _U("computer_menu"),
        options = options
    })

    lib.showContext('game_menu')
end

function hasPlayerRunOutOfTime()
    return (minutes == 0 and seconds <= 1)
end

function countTime()
    seconds = seconds - 1
    if seconds == 0 then
        seconds = 59
        minutes = minutes - 1
    end

    if minutes == -1 then
        minutes = 0
        seconds = 0
    end
end

function displayTime()
    showSubtitle(_U("time_left_count", minutes, seconds), 1001)
end