local display = false
local fillingUp = false


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if display then 
            -- If ped gets out of vehicle
            if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                SetDisplay(false)
            end
        elseif IsPedSittingInAnyVehicle(PlayerPedId()) and not display and fillingUp then

            local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)))
            local inVehicle = false

            if currentVeh == config.spawnCodes then 
                inVehicle = true
            end
            
            if inVehicle then 
                SetDisplay(true)
            end

        end
    end        
end)

-- Commands
RegisterCommand("fillpool", function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local currentVeh = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(ped, false)))
    local vehEntity = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    local inVehicle = False

    if currentVeh == config.spawnCode then 
        inVehicle = true
    end
    

    if inVehicle then
        if IsVehicleAConvertible(vehEntity, false) == 1 then
            fillingUp = true
            SetDisplay(true)
            SendNUIMessage({
                waterType = "filling"
            })

            TriggerServerEvent("setWaterTexture")

            local state = GetConvertibleRoofState(vehEntity)

            --if state == 2 then 
            SetConvertibleRoof(vehEntity)
            LowerConvertibleRoof(vehEntity, false)
            --end

            SetVehicleModKit(vehEntity, 0)
            SetVehicleMod(vehEntity, 37, GetNumVehicleMods(vehEntity, 37)-1, false)

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


    if currentVeh == config.spawnCode then 
        inVehicle = true
    end
    

    if inVehicle then
        if IsVehicleAConvertible(vehEntity, false) == 1 then 
            fillingUp = false
            SetDisplay(true)
            SendNUIMessage({
                waterType = "emptying"
            })

            local state = GetConvertibleRoofState(vehEntity)

            if state ~= 0 then 
                SetConvertibleRoof(vehEntity)
                RaiseConvertibleRoof(vehEntity, false)
            end

            Citizen.CreateThread(function()
                
            end)

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
    _G.duiObjDetail = duiObjDetail
    local duiDetail = GetDuiHandle(duiObjDetail)
    local txDetail = CreateRuntimeTextureFromDuiHandle(txdDetail, 'duiTexDetail', duiDetail)
    AddReplaceTexture(config.ytdName, config.detailTextureName, 'duiTxdDetail', 'duiTexDetail')

    -- Bump
    local txdBump = CreateRuntimeTxd("duiTxdBump")
    local duiObjBump = CreateDui(config.bumpTexture, config.bumpSizeX, config.bumpSizeY)
    _G.duiObjBump = duiObjBump
    local duiBump = GetDuiHandle(duiObjBump)
    local txBump = CreateRuntimeTextureFromDuiHandle(txdBump, 'duiTexBump', duiBump)
    AddReplaceTexture(config.ytdName, config.bumpTextureName, 'duiTxdBump', 'duiTexBump')

end)

RegisterNetEvent("resetTexture")
AddEventHandler("resetTexture", function()

    -- Detail
    local txdDetail = CreateRuntimeTxd("duiTxdDetail")
    local duiObjDetail = CreateDui(config.detailResetTexture, config.detailResetSizeX, config.detailResetSizeY)
    _G.duiObj = duiObjDetail
    local duiDetail = GetDuiHandle(duiObjDetail)
    local txDetail = CreateRuntimeTextureFromDuiHandle(txdDetail, 'duiTexDetail', duiDetail)
    AddReplaceTexture(config.ytdName, config.detailResetTextureName, 'duiTxdDetail', 'duiTexDetail')

    -- Bump
    local txdBump = CreateRuntimeTxd("duiTxdBump")
    local duiObjBump = CreateDui(config.bumpResetTexture, config.bumpResetSizeX, config.bumpResetSizeY)
    _G.duiObj = duiObjBump
    local duiBump = GetDuiHandle(duiObjBump)
    local txBump = CreateRuntimeTextureFromDuiHandle(txdBump, 'duiTexBump', duiBump)
    AddReplaceTexture(config.ytdName, config.bumpResetTextureName, 'duiTxdBump', 'duiTexBump')

end)

function notify(str)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(str)
    EndTextCommandThefeedPostTicker(true, false)
end


function SetDisplay(bool)
    display = bool
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end