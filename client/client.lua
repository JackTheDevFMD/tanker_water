local display = false
local fillingUp = false

local txdDetail
local duiObjDetail
local duiDetail 
local txDetail

local txdBump
local duiObjBump
local duiBump
local txBump


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

            if config.useUI then 
                SetDisplay(true)
                SendNUIMessage({
                    waterType = "filling"
                })
            end

            TriggerServerEvent("setWaterTexture")

            local state = GetConvertibleRoofState(vehEntity)

            --if state == 2 then 
            SetConvertibleRoof(vehEntity)
            LowerConvertibleRoof(vehEntity, false)
            --end

            SetVehicleModKit(vehEntity, 0)
            SetVehicleMod(vehEntity, 37, GetNumVehicleMods(vehEntity, 37)-1, false)

            TriggerServerEvent("createWaterParticles", vehEntity)

            Citizen.CreateThread(function()
                Citizen.Wait(50000) -- 50 Seconds

                fillingUp = false
            end)

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
        if not fillingUp then 
            if IsVehicleAConvertible(vehEntity, false) == 1 then 
                fillingUp = false

                if config.useUI then 
                    SetDisplay(true)
                    SendNUIMessage({
                        waterType = "emptying"
                    })
                end

                local state = GetConvertibleRoofState(vehEntity)

                if state ~= 0 then 
                    SetConvertibleRoof(vehEntity)
                    RaiseConvertibleRoof(vehEntity, false)
                end

                Citizen.CreateThread(function()
                    Citizen.Wait(50000) -- 50 Seconds

                    TriggerServerEvent("resetWaterTexture")
                end)

            end
        else 
            notify("You need to wait to complete filling up before emptying.")
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
AddEventHandler("updateTexture", function(toggle)

    if toggle then 

        -- Detail
        txdDetail = CreateRuntimeTxd("duiTxdDetail")
        duiObjDetail = CreateDui(config.detailTexture, config.detailSizeX, config.detailSizeY)
        _G.duiObjDetail = duiObjDetail
        duiDetail = GetDuiHandle(duiObjDetail)
        txDetail = CreateRuntimeTextureFromDuiHandle(txdDetail, 'duiTexDetail', duiDetail)
        AddReplaceTexture(config.ytdName, config.detailTextureName, 'duiTxdDetail', 'duiTexDetail')

        -- Bump
        txdBump = CreateRuntimeTxd("duiTxdBump")
        duiObjBump = CreateDui(config.bumpTexture, config.bumpSizeX, config.bumpSizeY)
        _G.duiObjBump = duiObjBump
        duiBump = GetDuiHandle(duiObjBump)
        txBump = CreateRuntimeTextureFromDuiHandle(txdBump, 'duiTexBump', duiBump)
        AddReplaceTexture(config.ytdName, config.bumpTextureName, 'duiTxdBump', 'duiTexBump')

    else 

        RemoveReplaceTexture(config.ytdName, config.detailTextureName)
        RemoveReplaceTexture(config.ytdName, config.bumpTextureName)

    end

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
