Cam = {}
Cam.Cache = {}

function Cam.Create(name)
    Cam.Cache[name] = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    return Cam.Cache[name]
end

function Cam.Destroy(name)
    Cam.SetActive(name, false, false, 0)
    DestroyCam(Cam.Cache[name], false)
    Cam.Cache[name] = nil
end

function Cam.SetPosition(name, position)
    SetCamCoord(Cam.Cache[name], position.x, position.y, position.z)
end

function Cam.SetRotation(name, rotation, rotationOrder)
    SetCamRot(Cam.Cache[name], rotation.x, rotation.y, rotation.z, rotationOrder)
end

function Cam.SetFov(name, fov)
    fov = tonumber(fov) or 0 -- Convert to number or default to 0 if conversion fails
    if fov % 1 == 0 then
        fov = fov + 0.0 -- Ensure it has a decimal point
    end
    SetCamFov(Cam.Cache[name], fov)
end

function Cam.SetActive(name, status, ease, easeTime)
    SetCamActive(Cam.Cache[name], status)
    RenderScriptCams(status, ease, easeTime, true, false)
end

function Cam.PointAtPosition(name, position)
    PointCamAtCoord(Cam.Cache[name], position.x, position.y, position.z)
end

-- Auto handle dof value to be focus on an entity based on the camera position
function Cam.HandleSmartDof(name, entity, dofValue)
    local camPos = GetCamCoord(Cam.Cache[name])
    local entityPos = GetEntityCoords(entity)
    local distance = #(camPos - entityPos)

    -- Set DOF values based on distance
    local nearDof = distance - 0.5 -- Slightly in front of the entity
    local farDof = distance + 0.9 -- Slightly behind the entity

    SetUseHiDof() -- Enable high depth of field
    SetCamNearDof(Cam.Cache[name], nearDof) -- Set calculated near DOF value
    SetCamFarDof(Cam.Cache[name], farDof) -- Set calculated far DOF value
    SetCamUseShallowDofMode(Cam.Cache[name], true) -- Enable shallow DOF mode
    SetCamDofStrength(Cam.Cache[name], dofValue) -- Set DOF strength based on dofValue

    -- Additional DOF settings
    SetCamDofMaxNearInFocusDistanceBlendLevel(Cam.Cache[name], nearDof) -- Set near DOF blend level
    SetCamDofMaxNearInFocusDistance(Cam.Cache[name], nearDof) -- Set near DOF distance
    SetCamDofFocusDistanceBias(Cam.Cache[name], farDof) -- Set DOF focus distance bias
end