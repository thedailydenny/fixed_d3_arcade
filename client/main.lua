-------------------
-- variables for arcade and time left
-------------------
gotTicket = false
usingComputer = false

minutes = 0
seconds = 0
-------------------
function doesPlayerHaveTicket()
    return gotTicket
end

exports('doesPlayerHaveTicket', doesPlayerHaveTicket)

--count time
function TimerThread()
    while true do
        Citizen.Wait(1000)
        if gotTicket then
            if hasPlayerRunOutOfTime() then
                showNotification(_U("ticket_expired"))
                gotTicket = false
                TriggerEvent('d3-arcade:exit')                
            end

            countTime()
            displayTime()
        end
    end
end

local retrocomputer = {
    isInGamingHouse = true,
    computerType = Config.RetroMachine,
    computerGPU = Config.GPUList[2],
    computerCPU = Config.CPUList[2],
}
--create npc, blip, marker
Citizen.CreateThread(function()
    if Config.ArcadeModels ~= nil then
        local optionLabel = "Play Arcade"
        if Config.enableGameHouse then
            optionLabel = "Play Arcade for $" .. Config.singleUsePrice
        end
        exports.ox_target:addModel(Config.ArcadeModels, {
            {
                name = 'arcade_single_use',
                icon = "fas fa-gamepad",
                label = optionLabel,
                serverEvent = "d3-arcade:singleUse",
                canInteract = function() return not gotTicket end,
                distance = 2.5
            },
            {
                name = 'arcade_with_ticket',
                icon = "fas fa-gamepad",
                label = "Play Arcade (Ticket)",
                onSelect = function() openComputerMenu(retrocomputer.computerType, retrocomputer) end,
                canInteract = function() return gotTicket end,
                distance = 2.5
            },
        })
    end
    for k, v in pairs(Config.Arcade) do
        local npcId = "ComputerNPC-" .. k
        exports.ox_target:addBoxZone({
            coords = v.NPC.position,
            size = vec3(1, 1, 2),
            rotation = v.NPC.heading,
            debug = false,
            options = {
                {
                    name = npcId .. '_buy',
                    icon = "fas fa-dollar-sign",
                    label = "Buy Ticket",
                    onSelect = playerBuyTicketMenu,
                    canInteract = function() return Config.enableGameHouse and not gotTicket end,
                    distance = 2.5
                },
                {
                    name = npcId .. '_return',
                    icon = "fas fa-dollar-sign",
                    label = "Return Ticket",
                    onSelect = returnTicketMenu,
                    canInteract = function() return Config.enableGameHouse and gotTicket end,
                    distance = 2.5
                },
            }
        })

        if v.blip and v.blip.enable then
            createBlip(v.blip.name, v.blip.blipId, v.blip.position, v.blip)
        end

        createLocalPed(4, v.NPC.model, v.NPC.position, v.NPC.heading, function(ped)
            SetEntityAsMissionEntity(ped)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
        end)
    end
end)

--create targets for computers
Citizen.CreateThread(function()
    for k, v in pairs(Config.computerList) do
        local computerName = "Computer-" .. k
        exports.ox_target:addBoxZone({
            coords = v.position,
            size = vec3(1, 1, 2.5),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = computerName,
                    icon = "fas fa-gamepad",
                    label = "Play Games",
                    onSelect = function() openComputerMenu(v.computerType, v) end,
                    canInteract = function() return not v.isInGamingHouse or not Config.enableGameHouse or gotTicket end,
                    distance = 2.5
                },
            }
        })
    end
end)

RegisterNetEvent('d3-arcade:check:ticket', function(computer)
    openComputerMenu(computer.computerType, computer)
end) 