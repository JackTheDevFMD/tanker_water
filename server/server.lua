AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= config.resourceName ) then
        print("\n\n\n^8TANKER_WATER SCRIPT ERROR ^3\n\nPLEASE ENSURE THE NAME OF THE RESOURCE MATCHES THE NAME IN THE CONFIG.LUA^7\n\n\n")
    end
end)

RegisterNetEvent("createWaterParticles")
AddEventHandler("createWaterParticles", function(vehEntity)
    TriggerClientEvent("waterParticles", -1, vehEntity)
end)

RegisterNetEvent("setWaterTexture")
AddEventHandler("setWaterTexture", function()
    TriggerClientEvent("updateTexture", -1)
end)


