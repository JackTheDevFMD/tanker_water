RegisterNetEvent("createWaterParticles")
AddEventHandler("createWaterParticles", function(vehEntity)
    TriggerClientEvent("waterParticles", -1, vehEntity)

end)

RegisterNetEvent("setWaterTexture")
AddEventHandler("setWaterTexture", function()
    TriggerClientEvent("updateTexture", -1)

end)