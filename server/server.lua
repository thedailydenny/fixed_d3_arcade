local supercomputer = {
    isInGamingHouse = false,
    computerType = Config.SuperMachine,
    computerGPU = Config.GPUList[1],
    computerCPU = Config.CPUList[1],
}
local retrocomputer = {
    isInGamingHouse = false,
    computerType = Config.RetroMachine,
    computerGPU = Config.GPUList[2],
    computerCPU = Config.CPUList[2],
}

lib.addCommand('testgames', {
    help = 'Opens an arcade supercomputer for testing purposes',
    restricted = 'group.admin'
}, function(source)
    local src = source
    TriggerClientEvent('d3-arcade:check:ticket', src, supercomputer)
end)

RegisterNetEvent('d3-arcade:singleUse', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local price = Config.singleUsePrice
    if not Config.enableGameHouse or player.Functions.RemoveMoney("cash", price, "arcade") then
        TriggerClientEvent('d3-arcade:check:ticket', src, retrocomputer)
    else
        TriggerClientEvent("d3-arcade:nomoney", src)
    end
end)

RegisterNetEvent("d3-arcade:buyTicket")
AddEventHandler("d3-arcade:buyTicket", function(ticket)
    local src = source
    local data = Config.ticketPrice[ticket]
    local player = exports.qbx_core:GetPlayer(src)
    if player.Functions.RemoveMoney("cash", data.price, "arcade") then
        TriggerClientEvent("d3-arcade:ticketResult", src, ticket)
    else
        TriggerClientEvent("d3-arcade:nomoney", src)
    end
end)