

-- UI

local ui = false

RegisterCommand('showuitest', function(source, args)
    SetDisplay(not display)
end)

RegisterCommand('removeui', function(source, args)
    SetDisplay(not display)
end)



RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

function SetDisplay(bool)
    display = bool
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end


RegisterCommand("fillpool", function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(ped, false)))
    local vehEntity = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    local inVehicle = False


    for k,v in pairs(config.spawnCodes) do 
        if currentVeh == v then 
            inVehicle = true
        end
    end
    

    if inVehicle then
        if IsVehicleAConvertible(vehEntity, false) == 1 then
            SetDisplay(not display)

            TriggerServerEvent("setWaterTexture")

            local state = GetConvertibleRoofState(vehEntity)
            if state == 0 then 
                SetConvertibleRoof(vehEntity)
                LowerConvertibleRoof(vehEntity, false)
            end

            SetVehicleExtra(vehEntity, 12, false)

            TriggerServerEvent("createWaterParticles", vehEntity)

        end
    else 
        notify("You need to be in the tanker truck to do this!")
    end

end,false)


RegisterCommand("emptypool", function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(ped, false)))
    local vehEntity = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    local inVehicle = False


    for k,v in pairs(config.spawnCodes) do 
        if currentVeh == v then 
            inVehicle = true
        end
    end
    

    if inVehicle then
        if IsVehicleAConvertible(vehEntity, false) == 1 then 

            local state = GetConvertibleRoofState(vehEntity)
            if state ~= 0 then 
                SetConvertibleRoof(vehEntity)
                RaiseConvertibleRoof(vehEntity, false)
            end

            SetVehicleExtra(vehEntity, 12, true)

        end
    else 
        notify("You need to be in the tanker truck to do this!")
    end

end,false)


RegisterNetEvent("waterParticles")
AddEventHandler("waterParticles", function(vehEntity)

    local waterSpoutBone = config.bone
    local boneSpoutIndex = GetEntityBoneIndexByName(vehEntity, waterSpoutBone)

    if boneSpoutIndex ~= -1 then

        Citizen.CreateThread(function()
            UseParticleFxAssetNextCall('core')
            waterSpout = StartParticleFxLoopedOnEntityBone('water_cannon_jet', vehEntity, 0, 0, 0 , 180.0, 0.0, 0.0, boneSpoutIndex, 0.50, false, false, false)
            Citizen.Wait(50000) -- 50 Seconds
            StopParticleFxLooped(waterSpout)
        end)

    end

end)

RegisterNetEvent("updateTexture")
AddEventHandler("updateTexture", function()

    -- Detail
    local txdDetail = CreateRuntimeTxd("duiTxdDetail")
    local duiObjDetail = CreateDui(config.detailTexture, config.detailSizeX, config.detailSizeY)
    _G.duiObj = duiObjDetail
    local duiDetail = GetDuiHandle(duiObjDetail)
    local txDetail = CreateRuntimeTextureFromDuiHandle(txdDetail, 'duiTexDetail', duiDetail)
    AddReplaceTexture('ftanker', 'water_sign_1', 'duiTxdDetail', 'duiTexDetail')

    -- Bump
    local txdBump = CreateRuntimeTxd("duiTxdBump")
    local duiObjBump = CreateDui(config.bumpTexture, config.bumpSizeX, config.bumpSizeY)
    _G.duiObj = duiObjBump
    local duiBump = GetDuiHandle(duiObjBump)
    local txBump = CreateRuntimeTextureFromDuiHandle(txdBump, 'duiTexBump', duiBump)
    AddReplaceTexture('ftanker', 'waterbump_sign_1', 'duiTxdBump', 'duiTexBump')

end)

function notify(str)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(str)
    EndTextCommandThefeedPostTicker(true, false)
end