PHOTOMODE = {}
PHOTOMODE.IsActive = false
PHOTOMODE.CameraName = "photoModeCam"
PHOTOMODE.FOV = 0

PHOTOMODE.Settings = {
    UseStopTime = {value = true, label = "Slow down game time"},
    UseSmartDof = {value = true, label = "Use depth of field"},
    NearDofValue = {value = 1.0, label = "Near DOF value", minValue = 0.0, maxValue = 30.0},
    FarDofValue = {value = 1.0, label = "Far DOF value", minValue = 0.0, maxValue = 30.0},
}

PHOTOMODE.Cache = {}
PHOTOMODE.PlayersInPhotomode = {}

function PHOTOMODE.Start()
    local gameplayCamPos = GetFinalRenderedCamCoord()
    local gameplayCamRot = GetGameplayCamRot(2)
    local gameplayCamFov = GetGameplayCamFov()
    local baseX = 0.05
    local baseY = 0.2
    local actualX = 0.0
    PHOTOMODE.FOV = gameplayCamFov
    PHOTOMODE.Cache = {}
    PHOTOMODE.Cache.LastRot = gameplayCamRot
    PHOTOMODE.Cache.UIAlpha = 0
    PHOTOMODE.Cache.MenuAlpha = 0
    PHOTOMODE.Cache.IsUIActive = false

    Cam.Create(PHOTOMODE.CameraName)
    Cam.SetPosition(PHOTOMODE.CameraName, gameplayCamPos)
    Cam.SetRotation(PHOTOMODE.CameraName, gameplayCamRot, 2)
    Cam.SetFov(PHOTOMODE.CameraName, gameplayCamFov)
    Cam.SetActive(PHOTOMODE.CameraName, true, false, 0)
    SetTimeScale(0.0)

    -- Hide HUD and radar
    DisplayHud(false)
    DisplayRadar(false)
    Config.EnteredPhotomode()
    if Config.ShowIconAbovePlayersInPhotomode then
        TriggerServerEvent("photomode:SetPlayerInPhotomode")
    end

    PHOTOMODE.IsActive = true
    Citizen.CreateThread(function()
        while PHOTOMODE.IsActive do
            PHOTOMODE.Cache.Moved = false
            PHOTOMODE.BlockMouvementsControls()
            local pPed = PlayerPedId()
            if PHOTOMODE.Settings.UseSmartDof.value then
                Cam.HandleSmartDof(PHOTOMODE.CameraName, pPed, 1.0)
            end

            if PHOTOMODE.Settings.UseStopTime.value then
                SetTimeScale(0.0)
            else
                SetTimeScale(1.0)
            end

            if IsControlJustPressed(0, 241) then
                local scaleFactor = gameplayCamFov / 20.0
                gameplayCamFov = math.max(gameplayCamFov - scaleFactor, 1.0)
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                PHOTOMODE.Cache.Moved = true
            elseif IsControlJustPressed(0, 242) then
                local scaleFactor = gameplayCamFov / 20.0
                gameplayCamFov = math.min(gameplayCamFov + scaleFactor, 120.0)
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                PHOTOMODE.Cache.Moved = true
            end

            PHOTOMODE.FOV = Utils.CalculateNextScalablePosition(gameplayCamFov, PHOTOMODE.FOV, 0.1)
            Cam.SetFov(PHOTOMODE.CameraName, PHOTOMODE.FOV)

            local mouseX = GetControlNormal(0, 1)
            local mouseY = GetControlNormal(0, 2)

            local currentFov = GetCamFov(Cam.Cache[PHOTOMODE.CameraName])

            local scaleFactor = currentFov / 40.0

            local camPos = GetCamCoord(Cam.Cache[PHOTOMODE.CameraName])
            local camRot = GetCamRot(Cam.Cache[PHOTOMODE.CameraName], 2)
            local forwardVector = PHOTOMODE.RotationToDirection(camRot)
            local upVector = vector3(0.0, 0.0, 1.0)
            -- Right vector calculation using cross-product to ensure correct horizontal movement
            local rightVector = PHOTOMODE.CrossProduct(forwardVector, upVector)

            if IsDisabledControlPressed(0, 32) then -- W key
                camPos = camPos + forwardVector * 0.1
                PHOTOMODE.Cache.Moved = true
            end
            if IsDisabledControlPressed(0, 33) then -- S key
                camPos = camPos - forwardVector * 0.1
                PHOTOMODE.Cache.Moved = true
            end
            if IsDisabledControlPressed(0, 34) then -- A key
                camPos = camPos - rightVector * 0.1
                PHOTOMODE.Cache.Moved = true
            end
            if IsDisabledControlPressed(0, 35) then -- D key
                camPos = camPos + rightVector * 0.1
                PHOTOMODE.Cache.Moved = true
            end
            if IsDisabledControlPressed(0, 44) then -- Q key
                camPos = camPos - upVector * 0.1
                PHOTOMODE.Cache.Moved = true
            end
            if IsDisabledControlPressed(0, 45) then -- E key
                camPos = camPos + upVector * 0.1
                PHOTOMODE.Cache.Moved = true
            end

            if Config.MaxDistanceFromPlayer then
                local pPos = GetEntityCoords(pPed)
                local distance = #(camPos - pPos)
                if distance > Config.MaxDistanceFromPlayer then
                    local direction = camPos - pPos
                    direction = direction / distance
                    camPos = pPos + direction * Config.MaxDistanceFromPlayer
                    DrawMarker(28, pPos.x, pPos.y, pPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MaxDistanceFromPlayer, Config.MaxDistanceFromPlayer, Config.MaxDistanceFromPlayer, 255, 0, 0, 150, false, false, 2, false, nil, nil, false)
                end
            end

            Cam.SetPosition(PHOTOMODE.CameraName, camPos)

            if not IsDisabledControlPressed(0, 24) then
                camRot = vector3(camRot.x - mouseY * 5.0 * scaleFactor, camRot.y, camRot.z - mouseX * 5.0 * scaleFactor)
                Cam.SetRotation(PHOTOMODE.CameraName, camRot, 2)

                if PHOTOMODE.Cache.LastRot ~= camRot then
                    PHOTOMODE.Cache.Moved = true
                    PHOTOMODE.Cache.LastRot = camRot
                end
            end

            if PHOTOMODE.Cache.Moved then
                PHOTOMODE.Cache.MenuAlpha = math.min(PHOTOMODE.Cache.MenuAlpha + 5, 255)
            else
                PHOTOMODE.Cache.MenuAlpha = math.max(PHOTOMODE.Cache.MenuAlpha - 5, 0)
            end

            if PHOTOMODE.Cache.MenuAlpha > 0 then
                UI.DrawTexts(0.5, 0.9, "Press [E] to open the camera UI", true, 0.45, {255, 255, 255, PHOTOMODE.Cache.MenuAlpha}, 6, false, false, true, false)
            end

            if IsControlJustReleased(0, 38) then
                PHOTOMODE.Cache.IsUIActive = not PHOTOMODE.Cache.IsUIActive
            end

            if PHOTOMODE.Cache.IsUIActive or PHOTOMODE.Cache.UIAlpha > 0 then
                if PHOTOMODE.Cache.IsUIActive then
                    baseX = -0.05
                    baseY = 0.2
                    PHOTOMODE.Cache.UIAlpha = math.min(PHOTOMODE.Cache.UIAlpha + 10, 255)
                else
                    baseX = -0.15
                    baseY = 0.2
                    PHOTOMODE.Cache.UIAlpha = math.max(PHOTOMODE.Cache.UIAlpha - 10, 0)
                end
                actualX = UI.CalculateNextScalablePosition(baseX, actualX, 0.1)

                UI.ShowMouseThisFrame(true)

                local x, y = UI.ConvertToPixel(292, 440)
                UI.DrawSimpleSprite("photomode_ui", "frame", actualX, baseY, x, y, 0, 255, 255, 255, PHOTOMODE.Cache.UIAlpha , {})

                local x, y = UI.ConvertToPixel(15, 15)

                baseY = baseY + 0.10
                actualX = actualX + 0.01
                for k,v in pairs(PHOTOMODE.Settings) do
                    local type = type(v.value)
                    if type == "boolean" then
                        local sprite = "checkbox" .. (v.value and "_checked" or "")
                        UI.DrawSpriteNew("photomode_ui", sprite, actualX, baseY, x, y, 0, 255, 255, 255, PHOTOMODE.Cache.UIAlpha , {}, function(isSelected)
                            if isSelected then
                                PHOTOMODE.Settings[k].value = not PHOTOMODE.Settings[k].value
                            end
                        end)
                        UI.DrawTexts(actualX + 0.013, baseY - 0.004, v.label, false, 0.30, {255, 255, 255, PHOTOMODE.Cache.UIAlpha }, 6, false, false, true, false)
                    elseif type == "number" then
                        UI.DrawSlider(actualX, baseY, x + 0.05, y, {150, 150, 150, PHOTOMODE.Cache.UIAlpha - 200}, {250, 230, 10, PHOTOMODE.Cache.UIAlpha - 150}, v.value, v.maxValue, {direction = 1, noHover = false}, function(valueUpdated, newValue)
                            if valueUpdated then
                                PHOTOMODE.Settings[k].value = newValue
                            end
                        end)
                        UI.DrawTexts(actualX + 0.05 + 0.013, baseY - 0.004, v.label, false, 0.30, {255, 255, 255, PHOTOMODE.Cache.UIAlpha }, 6, false, false, true, false)
                    end

                    baseY = baseY + y + 0.01
                end
            end

            Wait(1)
        end
        SetTimeScale(1.0)
        PHOTOMODE.IsActive = false
        if Config.ShowIconAbovePlayersInPhotomode then
            TriggerServerEvent("photomode:RemovePlayerInPhotomode")
        end

        -- Show HUD and radar
        DisplayHud(true)
        DisplayRadar(true)
        Config.ExitedPhotomode()
    end)
end

-- Function to calculate the cross product of two vectors
function PHOTOMODE.CrossProduct(v1, v2)
    return vector3(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x
    )
end

function PHOTOMODE.RotationToDirection(rotation)
    local radZ = math.rad(rotation.z)
    local radX = math.rad(rotation.x)
    local num = math.abs(math.cos(radX))
    return vector3(-math.sin(radZ) * num, math.cos(radZ) * num, math.sin(radX))
end

function PHOTOMODE.BlockMouvementsControls()
    if PHOTOMODE.IsActive then
        DisableControlAction(0, 30, true) -- INPUT_MOVE_LR
        DisableControlAction(0, 31, true) -- INPUT_MOVE_UD
        DisableControlAction(0, 32, true) -- INPUT_MOVE_UP_ONLY
        DisableControlAction(0, 33, true) -- INPUT_MOVE_DOWN_ONLY
        DisableControlAction(0, 34, true) -- INPUT_MOVE_LEFT_ONLY
        DisableControlAction(0, 35, true) -- INPUT_MOVE_RIGHT_ONLY

        -- Also block attacks controls
        DisableControlAction(0, 24, true) -- INPUT_ATTACK
        DisableControlAction(0, 25, true) -- INPUT_AIM
    end
end

function PHOTOMODE.Stop()
    PHOTOMODE.IsActive = false
    Cam.SetActive(PHOTOMODE.CameraName, false, true, 1000)
    Wait(1000)
    Cam.Destroy(PHOTOMODE.CameraName)
end

-- Commands
RegisterCommand("photomode", function()
    if not PHOTOMODE.IsActive then
        PHOTOMODE.Start()
    else
        PHOTOMODE.Stop()
    end
end, false)

if Config.ShowIconAbovePlayersInPhotomode then
    local PlayersPedInPhotomode = {}
    -- Player filtering thread
    Citizen.CreateThread(function()
        while true do
            for k,v in pairs(GetActivePlayers()) do
                local sID = GetPlayerServerId(v)
                if PHOTOMODE.PlayersInPhotomode[sID] then
                    local pPed = GetPlayerPed(v)
                    if not PlayersPedInPhotomode[sID] then
                        PlayersPedInPhotomode[sID] = pPed
                    end
                else
                    if PlayersPedInPhotomode[sID] then
                        PlayersPedInPhotomode[sID] = nil
                    end
                end
            end

            Wait(3000)
        end
    end)

    -- Main thread for icon display
    Citizen.CreateThread(function()
        local x, y = UI.ConvertToPixel(30, 30)
        while true do
            local HandlingUI = false
            local pCoords = GetEntityCoords(PlayerPedId())

            for k,v in pairs(PlayersPedInPhotomode) do
                local entityCoords = GetEntityCoords(v)
                local distance = #(pCoords - entityCoords)
                if distance <= 15 then
                    HandlingUI = true

                    UI.DrawSimpleSprite("photomode_ui", "camera_icon", 0.5, 0.5, x, y, 0, 255, 255, 255, 255, {Draw3d = {pos = vector3(entityCoords.x, entityCoords.y, entityCoords.z + 1.0)}})
                    print("Drawing icon", entityCoords, x, y)
                end
            end

            if HandlingUI then
                Wait(1)
            else
                Wait(500)
            end
        end
    end)
end

RegisterNetEvent("photomode:SetPlayerInPhotomode", function(serverID)
    local ownServerID = GetPlayerServerId(PlayerId())
    if serverID == ownServerID then
        return
    end
    PHOTOMODE.PlayersInPhotomode[serverID] = true
end)

RegisterNetEvent("photomode:RemovePlayerInPhotomode", function(serverID)
    PHOTOMODE.PlayersInPhotomode[serverID] = nil
end)