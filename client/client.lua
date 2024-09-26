PHOTOMODE = {}
PHOTOMODE.IsActive = false
PHOTOMODE.CameraName = "photoModeCam"
PHOTOMODE.FOV = 0

function PHOTOMODE.Start()
    -- Get gameplay camera properties
    local gameplayCamPos = GetFinalRenderedCamCoord()
    local gameplayCamRot = GetGameplayCamRot(2) -- Rotation in degrees
    local gameplayCamFov = GetGameplayCamFov()
    PHOTOMODE.FOV = gameplayCamFov

    print(gameplayCamPos)
    -- Create a new camera using the Cam library
    Cam.Create(PHOTOMODE.CameraName)
    Cam.SetPosition(PHOTOMODE.CameraName, gameplayCamPos)
    Cam.SetRotation(PHOTOMODE.CameraName, gameplayCamRot, 2)
    Cam.SetFov(PHOTOMODE.CameraName, gameplayCamFov)
    
    -- Set the new camera as active
    Cam.SetActive(PHOTOMODE.CameraName, true, false, 0)
    
    PHOTOMODE.IsActive = true
    Citizen.CreateThread(function()
        while PHOTOMODE.IsActive do
            PHOTOMODE.BlockMouvementsControls()
            local pPed = PlayerPedId()
            Cam.HandleSmartDof(PHOTOMODE.CameraName, pPed, 1.0)
    
            -- Check for mouse scroll input to adjust FOV
            if IsControlJustPressed(0, 241) then -- Scroll up
                local scaleFactor = gameplayCamFov / 20.0 -- Adjust the divisor to control sensitivity
                gameplayCamFov = math.max(gameplayCamFov - scaleFactor, 1.0) -- Decrease FOV, minimum 1.0
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) -- Play sound
            elseif IsControlJustPressed(0, 242) then -- Scroll down
                local scaleFactor = gameplayCamFov / 20.0 -- Adjust the divisor to control sensitivity
                gameplayCamFov = math.min(gameplayCamFov + scaleFactor, 120.0) -- Increase FOV, maximum 120.0
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) -- Play sound
            end
    
            PHOTOMODE.FOV = Utils.CalculateNextScalablePosition(gameplayCamFov, PHOTOMODE.FOV, 0.1)
            Cam.SetFov(PHOTOMODE.CameraName, PHOTOMODE.FOV)
    
            -- Get mouse movement to move the camera
            local mouseX = GetControlNormal(0, 1) -- INPUT_LOOK_LR
            local mouseY = GetControlNormal(0, 2) -- INPUT_LOOK_UD
    
            -- Retrieve the current FOV
            local currentFov = GetCamFov(Cam.Cache[PHOTOMODE.CameraName])
    
            -- Define a scaling factor based on the current FOV
            local scaleFactor = currentFov / 40.0 -- Adjust the divisor to control sensitivity
    

            -- Check if the left mouse button is held down
            if IsDisabledControlPressed(0, 24) then -- Left mouse button
                -- Adjust camera position based on mouse movement
                print("pressed")
                local camPos = GetCamCoord(Cam.Cache[PHOTOMODE.CameraName])
                camPos = vector3(camPos.x + mouseX * 0.1, camPos.y, camPos.z - mouseY * 0.1)
                Cam.SetPosition(PHOTOMODE.CameraName, camPos)
            else
                -- Adjust camera rotation based on mouse movement and scaling factor
                local camRot = GetCamRot(Cam.Cache[PHOTOMODE.CameraName], 2)
                camRot = vector3(camRot.x - mouseY * 5.0 * scaleFactor, camRot.y, camRot.z - mouseX * 5.0 * scaleFactor)
                Cam.SetRotation(PHOTOMODE.CameraName, camRot, 2)
            end
    
            Wait(1)
        end
        PHOTOMODE.IsActive = false
    end)
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

PHOTOMODE.Start()