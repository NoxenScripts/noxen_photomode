UI = {}
UI.cooldown = false
UI.font = {}
UI.AnimatedFrames = {}
UI.lockedControls = {
    {24, 30, 31, 32, 33, 34, 35, 69, 70, 92, 114, 121, 140, 141, 142, 257, 263, 264, 331, 1, 2, 4, 5, 17, 16, 15, 14, 241, 242, 332, 333, 14, 15, 16, 17, 27, 50, 96, 97, 99, 115, 180, 181, 198, 241, 242, 261, 262, 334, 335, 336, 348, 81, 82, 83, 84, 85}
}
UI.fontToLoad = {}

function UI.ShowMouseThisFrame(lockControls)
    ShowCursorThisFrame()
    SetMouseCursorSprite(1)

    if lockControls then
        for k,v in pairs(UI.lockedControls[1]) do
            if v ~= nil then
                DisableControlAction(0, v, true)
            end
        end
    end
end


-- Duplicate, need to be removed
function UI.RealWait(ms, cb)
    local timer = GetGameTimer() + ms
    while GetGameTimer() < timer do
        if cb ~= nil then
            cb(function(stop)
                if stop then
                    timer = 0
                    return
                end
            end)
        end
        Wait(0)
    end
end

function UI.LoadStreamDict(dict)
    -- if HasStreamedTextureDictLoaded(dict) then
    --     SetStreamedTextureDictAsNoLongerNeeded(dict)
    --     while HasStreamedTextureDictLoaded(dict) do
    --         SetStreamedTextureDictAsNoLongerNeeded(dict)
    --         print("Waiting unload before load for", dict)
    --         Wait(1)
    --     end
    -- end
    while not HasStreamedTextureDictLoaded(dict) do
        RequestStreamedTextureDict(dict, 1)
        print("Loading dict ", dict)
        Wait(0)
    end
    print("Dict loaded! ", dict)
end

function UI.LoadFont(font)
    RegisterFontFile(font[1]) -- the name of your .gfx, without .gfx
    local fontId = RegisterFontId(font[2]) -- the name from the .xml

    UI.font[font[2]] = fontId
end


function UI.DrawSlider(screenX, screenY, width, height, backgroundColor, progressColor, value, max, settings, cb)
    if settings.devmod ~= nil and settings.devmod == true then
        local x = GetControlNormal(0, 239)
        local y = GetControlNormal(0, 240)


        screenX = x
        screenY = y


        if IsControlJustReleased(0, 38) then
            TriggerEvent("addToCopy", x..", "..y)
        end
    end

    if value > max then
        value = max
    end

    if settings.direction == nil then
        settings.direction = 1
    end

    local valueUpdated = false
    local newValue = value

    local pos = (vector2(screenX, screenY) + vector2(width, height) / 2.0)
    DrawRect(pos[1], pos[2], width, height, backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4])

    local progressWidth = (value/max) * width
    local progressHeight = height

    if settings.direction == 1 then -- left-to-right
        pos = (vector2(screenX, screenY) + vector2(progressWidth, height) / 2.0)
    elseif settings.direction == 2 then -- right-to-left
        pos = pos + vector2(width / 2.0, 0.0) - vector2(progressWidth / 2.0, 0.0)
    elseif settings.direction == 3 then -- bottom-to-top
        progressWidth = width
        progressHeight = (value/max) * width
        pos = pos + vector2(0.0, height / 2.0) - vector2(0.0, progressHeight / 2.0)
    elseif settings.direction == 4 then -- top-to-bottom
        progressWidth = width
        progressHeight = (value/max) * width
        pos = pos - vector2(0.0, height / 2.0) + vector2(0.0, progressHeight / 2.0)
    end

    DrawRect(pos[1], pos[2], progressWidth, progressHeight, progressColor[1], progressColor[2], progressColor[3], progressColor[4])

    if settings.noHover == false then
        if UI.isMouseOnButton({x = UI.GetControl(239) , y = UI.GetControl(240)}, {x = screenX, y = screenY}, width, height) then
            SetMouseCursorSprite(4)
            if IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) then
                local mouse = UI.GetControl(239)
                local size = ((mouse - screenX) * max) / width
                newValue = size

                --print(newValue)
                valueUpdated = true
            end
        end
    end

    cb(valueUpdated, newValue)
end



UI.HoveredCache = {}

function UI.CheckIfAlreadyHovered(textureDict, textureName, screenX, screenY)
    local uniqueID = textureDict .. textureName .. screenX .. screenY
    if UI.HoveredCache[uniqueID] == nil then
        UI.HoveredCache[uniqueID] = false
        return false, uniqueID
    else
        return UI.HoveredCache[uniqueID], uniqueID
    end
end

function UI.SetHoveredStatus(uniqueID, status)
    if UI.HoveredCache[uniqueID] ~= nil then
        UI.HoveredCache[uniqueID] = status
    end
end

function UI.GetControl(control)
    if not IsControlEnabled(0, control) then
        return GetDisabledControlNormal(0, control)
    else
        return GetControlNormal(0, control)
    end
end

function UI.DrawSpriteNew(textureDict, textureName, screenX, screenY, width, height, heading, red, green, blue, alpha, settings, cb)
    local onSelected = false
    local onHovered = false
    local pos
    if alpha <= 0 and not settings.drawEvenIfAlpha0 ~= nil and settings.drawEvenIfAlpha0 == false then
        return
    else
        alpha = math.floor(alpha)
    end

    if not HasStreamedTextureDictLoaded(textureDict) then
        RequestStreamedTextureDict(textureDict, true)
    else

        if settings.devmod ~= nil and settings.devmod == true then
            local x = GetControlNormal(0, 239)
            local y = GetControlNormal(0, 240)

           print(x, y)

            screenX = x
            screenY = y

            if IsControlJustReleased(0, 38) then
                TriggerEvent("addToCopy", x..", "..y)
            end
        end


        if settings.centerDraw ~= nil and settings.centerDraw == true then
            pos = vector2(screenX, screenY)
        else
            pos = (vector2(screenX, screenY) + vector2(width, height) / 2.0)
        end

        -- if Sheets.IsSpriteAnimated(textureDict, textureName) then
        --     textureName = textureName..Sheets.GetActualFrame(textureDict, textureName)
        -- end

        if settings.Draw3d ~= nil then
            SetDrawOrigin(settings.Draw3d.pos.x, settings.Draw3d.pos.y, settings.Draw3d.pos.z, 0)
            pos = (vector2(0.0, 0.0) + vector2(width, height) / 2.0)
        end

        if settings.NoHover ~= nil and settings.NoHover == true then
            DrawSprite(textureDict, textureName, pos[1], pos[2], width, height, heading, red, green, blue, alpha)
        else
            if settings.Draw3d ~= nil then
                _, screenX, screenY = GetScreenCoordFromWorldCoord(settings.Draw3d.pos.x, settings.Draw3d.pos.y, settings.Draw3d.pos.z)
            end
            local xControl = UI.GetControl(239)
            local yControl = UI.GetControl(240)

            if UI.isMouseOnButton({x = xControl , y = yControl}, {x = screenX, y = screenY}, width, height, settings.centerDraw) then
                onHovered = true
                local aleadyHovered, spriteUniqueId = UI.CheckIfAlreadyHovered(textureDict, textureName, screenX, screenY)
                if not aleadyHovered then
                    UI.SetHoveredStatus(spriteUniqueId, true)
                    if settings.sounds ~= nil and settings.sounds.hover ~= nil then
                        PlaySoundFrontend(-1, settings.sounds.hover[1], settings.sounds.hover[2], 1)
                    end
                end
                if settings.CustomHoverTexture ~= nil and settings.CustomHoverTexture ~= false then
                    if settings.CustomHoverTexture[3] ~= nil and settings.CustomHoverTexture[4] ~= nil then
                        local x,y = UI.ConvertToPixel(settings.CustomHoverTexture[3], settings.CustomHoverTexture[4])
                        width = x
                        height = y
                    end

                    DrawSprite(settings.CustomHoverTexture[1], settings.CustomHoverTexture[2], pos[1], pos[2], width, height, heading, red, green, blue, alpha)
                else
                    DrawSprite(textureDict, textureName, pos[1], pos[2], width, height, heading, red, green, blue, alpha)
                end
            else
                onHovered = false
                local aleadyHovered, spriteUniqueId = UI.CheckIfAlreadyHovered(textureDict, textureName, screenX, screenY)
                if aleadyHovered then
                    UI.SetHoveredStatus(spriteUniqueId, false)
                end
                DrawSprite(textureDict, textureName, pos[1], pos[2], width, height, heading, red, green, blue, alpha)
            end
        end


        if settings.NoSelect == nil or settings.NoSelect == false and not settings.devmod == true then
            if UI.isMouseOnButton({x = UI.GetControl(239) , y = UI.GetControl(240)}, {x = screenX, y = screenY}, width, height, settings.centerDraw) then
                SetMouseCursorSprite(4)
                onHovered = true
                if UI.HandleControl() then
                    --PlayCustomSound("FrontEnd/Navigate_Apply_01_Wave 0 0 0", 0.02)
                    onSelected = true
                end
            end
        end

        if settings.Draw3d ~= nil then
            ClearDrawOrigin()
        end
    end


    cb(onSelected, onHovered, pos)
end

function UI.DrawSimpleSprite(textureDict, textureName, screenX, screenY, width, height, heading, red, green, blue, alpha, settings)
    local pos
    if alpha <= 0 and not settings.drawEvenIfAlpha0 ~= nil and settings.drawEvenIfAlpha0 == false then
        return
    else
        alpha = math.floor(alpha)
    end

    if not HasStreamedTextureDictLoaded(textureDict) then
        RequestStreamedTextureDict(textureDict, true)
    else
        if settings.devmod ~= nil and settings.devmod == true then
            local x = GetControlNormal(0, 239)
            local y = GetControlNormal(0, 240)

            print(x, y)

            screenX = x
            screenY = y

            if IsControlJustReleased(0, 38) then
                TriggerEvent("addToCopy", x..", "..y)
            end
        end

        if settings.centerDraw ~= nil and settings.centerDraw == true then
            pos = vector2(screenX, screenY)
        else
            pos = (vector2(screenX, screenY) + vector2(width, height) / 2.0)
        end

        if settings.Draw3d ~= nil then
            SetDrawOrigin(settings.Draw3d.pos.x, settings.Draw3d.pos.y, settings.Draw3d.pos.z, 0)
            pos = (vector2(0.0, 0.0) + vector2(width, height) / 2.0)
        end

        DrawSprite(textureDict, textureName, pos[1], pos[2], width, height, heading, red, green, blue, alpha)

        if settings.Draw3d ~= nil then
            ClearDrawOrigin()
        end
    end
end

function UI.DrawRect(screenX, screenY, width, height, heading, red, green, blue, alpha, settings, cb)
    local onSelected = false
    local onHovered = false

    alpha = math.floor(alpha)
    if settings.devmod ~= nil and settings.devmod == true then
        local x = GetControlNormal(0, 239)
        local y = GetControlNormal(0, 240)

       print(x, y)

        screenX = x
        screenY = y

        if IsControlJustReleased(0, 38) then
            TriggerEvent("addToCopy", x..", "..y)
        end
    end

    local pos
    if settings.centerDraw ~= nil and settings.centerDraw == true then
        pos = vector2(screenX, screenY)
    else
        pos = (vector2(screenX, screenY) + vector2(width, height) / 2.0)
    end

    -- if Sheets.IsSpriteAnimated(textureDict, textureName) then
    --     textureName = textureName..Sheets.GetActualFrame(textureDict, textureName)
    -- end

    if settings.Draw3d ~= nil then
        SetDrawOrigin(settings.Draw3d.pos.x, settings.Draw3d.pos.y, settings.Draw3d.pos.z, 0)
        pos = (vector2(0.0, 0.0) + vector2(width, height) / 2.0)
    end

    if settings.NoHover ~= nil and settings.NoHover == true then
        --DrawSprite(textureDict, textureName, pos[1], pos[2], width, height, heading, red, green, blue, alpha)
        --print(pos[1], pos[2], width, height, heading, red, green, blue, alpha)
        if alpha >= 0 then
            DrawRect(pos[1], pos[2], width, height, red, green, blue, alpha)
        end

    else
        if settings.Draw3d ~= nil then
            _, screenX, screenY = GetScreenCoordFromWorldCoord(settings.Draw3d.pos.x, settings.Draw3d.pos.y, settings.Draw3d.pos.z)
        end
        if UI.isMouseOnButton({x = GetControlNormal(0, 239) , y = GetControlNormal(0, 240)}, {x = screenX, y = screenY}, width, height) then
            onHovered = true
            local aleadyHovered, spriteUniqueId = UI.CheckIfAlreadyHovered("RECT", "RECT", screenX, screenY)
            if not aleadyHovered then
                UI.SetHoveredStatus(spriteUniqueId, true)
            end
            if settings.CustomHoverTexture ~= nil and settings.CustomHoverTexture ~= false then
                if alpha >= 0 then
                    DrawRect(pos[1], pos[2], width, height, settings.CustomHoverTexture[1], settings.CustomHoverTexture[2], settings.CustomHoverTexture[3], settings.CustomHoverTexture[4])
                end
            else
                if alpha >= 0 then
                    DrawRect(pos[1], pos[2], width, height, red, green, blue, alpha)
                end

            end
        else
            onHovered = false
            local aleadyHovered, spriteUniqueId = UI.CheckIfAlreadyHovered("RECT", "RECT", screenX, screenY)
            if aleadyHovered then
                UI.SetHoveredStatus(spriteUniqueId, false)
            end
            if alpha >= 0 then
                DrawRect(pos[1], pos[2], width, height, red, green, blue, alpha)
            end

        end
    end


    if settings.NoSelect == nil or settings.NoSelect == false and not settings.devmod == true then
        if UI.isMouseOnButton({x = GetControlNormal(0, 239) , y = GetControlNormal(0, 240)}, {x = screenX, y = screenY}, width, height) then
            SetMouseCursorSprite(4)
            onHovered = true
            if UI.HandleControl() then
                --PlayCustomSound("FrontEnd/Navigate_Apply_01_Wave 0 0 0", 0.02)
                onSelected = true
            end
        end
    end

    if settings.Draw3d ~= nil then
        ClearDrawOrigin()
    end

    cb(onSelected, onHovered, pos)
end

-- Position = mouse pos
function UI.isMouseOnButton(position, buttonPos, Width, Heigh, isCenter)
    if isCenter ~= nil and isCenter == true then
       -- buttonPos = buttonPos - vector2(Width / 2.0, Heigh / 2.0)
        buttonPos.x = buttonPos.x - (Width / 2.0)
        buttonPos.y = buttonPos.y - (Heigh / 2.0)
    end
	return position.x >= buttonPos.x and position.y >= buttonPos.y and position.x < buttonPos.x + Width and position.y < buttonPos.y + Heigh
end



function UI.HandleCooldown()
    if not UI.cooldown then
        UI.cooldown = true
        Citizen.CreateThread(function()
            Wait(150)
            UI.cooldown = false
        end)
    end
end

local clickControl = {24, 176, 18, 69, 92, 106, 122, 135, 142, 144, 223, 229, 237, 257, 329, 346}
function UI.HandleControl()
    for k,v in pairs(clickControl) do
        if not UI.cooldown then
            if IsControlJustPressed(0, v) or IsDisabledControlJustPressed(0, v) then
                UI.HandleCooldown()
                return true
            end
        end
    end
    return false
end


function UI.DrawTexts(x, y, text, center, scale, rgb, font, rightJustify, devmod, shadow, forceWarp)
    if rgb[4] >= 0 then
        if devmod then
            local x2 = GetControlNormal(0, 239)
            local y2 = GetControlNormal(0, 240)

            x = x2
            y = y2

            if IsControlJustReleased(0, 38) then
                TriggerEvent("addToCopy", x..", "..y)
            end
        end

        if shadow == nil then
            shadow = false
        end

        if rightJustify ~= 0 and rightJustify ~= false then
            SetTextJustification(2)
            SetTextWrap(0.0, x)
        end

        if forceWarp then
            SetTextWrap(0.0, forceWarp)
        end

        SetTextFont(font)
        SetTextScale(scale, scale)
        if shadow ~= nil and shadow == true then
            SetTextDropshadow(1, 0, 0, 0, 100)
            --SetTextDropShadow()
        end
        SetTextColour(rgb[1], rgb[2], rgb[3], math.floor(rgb[4]))
        SetTextEntry("STRING")
        SetTextCentre(center)
        AddTextComponentString(text)
        EndTextCommandDisplayText(x,y)
    end

end

function UI.DrawTextsNoLimitOld(x, y, center, scale, rgb, font, rightJustify, devmod, shadow, entry)
    -- if text == nil then
    --     return
    -- end

    if devmod then
        local x2 = GetControlNormal(0, 239)
        local y2 = GetControlNormal(0, 240)
        x = x2
        y = y2

        if IsControlJustReleased(0, 38) then
            TriggerEvent("addToCopy", x .. ", " .. y)
        end
    end

    if shadow == nil then
        shadow = false
    end

    if rightJustify ~= 0 and rightJustify ~= false then
        SetTextJustification(2)
        SetTextWrap(0.0, x)
    end

    SetTextFont(font)
    SetTextScale(scale, scale)
    if shadow ~= nil and shadow == true then
        SetTextDropshadow(1, 0, 0, 0, 100)
        --SetTextDropShadow()
    end
    SetTextColour(rgb[1], rgb[2], rgb[3], rgb[4])
    SetTextEntry(entry)
    SetTextCentre(center)
    --AddTextComponentString(text)
    EndTextCommandDisplayText(x, y)
end

local entrys = {}
function UI.DrawTextsNoLimit(x, y, text, center, scale, rgb, font, rightJustify, devmod, shadow, entry, forceWarp)
    -- if text == nil then
    --     return
    -- end
    if entrys[entry] == nil then
        entrys[entry] = text
        AddTextEntry(entry, text)
    else
        if entrys[entry] ~= text then
            entrys[entry] = text
            AddTextEntry(entry, text)
        end
    end
    
    if devmod then
        local x2 = GetControlNormal(0, 239)
        local y2 = GetControlNormal(0, 240)
        x = x2
        y = y2

        if IsControlJustReleased(0, 38) then
            TriggerEvent("addToCopy", x .. ", " .. y)
        end
    end

    if shadow == nil then
        shadow = false
    end

    if rightJustify ~= 0 and rightJustify ~= false then
        SetTextJustification(2)
        SetTextWrap(0.0, x)
    end

    if forceWarp then
        SetTextWrap(0.0, forceWarp)
    end

    SetTextFont(font)
    SetTextScale(scale, scale)
    if shadow ~= nil and shadow == true then
        SetTextDropshadow(1, 0, 0, 0, 100)
        --SetTextDropShadow()
    end
    SetTextColour(rgb[1], rgb[2], rgb[3], rgb[4])
    SetTextEntry(entry)
    SetTextCentre(center)
    --AddTextComponentString(text)
    EndTextCommandDisplayText(x, y)
end

function UI.Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY, alpha)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*15
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, alpha or 255)		-- You can change the text color here
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function UI.Draw3DTextNoDownsize(x,y,z,textInput,fontId,scaleX,scaleY, alpha)
    local dontDrawHowOfScreen = false
    local draw = false
    if dontDrawHowOfScreen == false then
        draw = true
    else
        local get, x,y = GetScreenCoordFromWorldCoord(x,y,z)
        if not get or x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0 then
            draw = false
        else
            draw = true
        end
    end

    if draw then
        local dist = #(GetFinalRenderedCamCoord().xy - vector2(x,y))
        local fov = (scaleX / GetGameplayCamFov()) * 100
        local scale = ((scaleX / dist) * 2) * fov
        if scale > 1 then
            scale = 1
        end

        SetDrawOrigin(x,y,z, 0)
        SetTextScale(scaleX * scale, scaleY * scale)
        SetTextFont(fontId)
        SetTextColour(250, 250, 250, alpha or 255)		-- You can change the text color here
        SetTextDropshadow(1, 1, 1, 1, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(textInput)
        DrawText(0.0, 0.0)
        ClearDrawOrigin()
    end
    return draw

end


-- pos.xyz
-- textureDict
-- textureName
-- x
-- y
-- width
-- height
-- heading
-- r
-- g
-- b
-- a
function UI.DrawSprite3d(data, dontDrawHowOfScreen)
    if dontDrawHowOfScreen == nil then
        dontDrawHowOfScreen = false
    end

    local draw = false
    if dontDrawHowOfScreen == false then
        draw = true
    else
        local get, x,y = GetScreenCoordFromWorldCoord(data.pos.x, data.pos.y, data.pos.z)
        --print(get, x, y)
        if not get or x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0 then
            draw = false
        else
            draw = true
        end
    end

    if draw then
        local dist = #(GetGameplayCamCoords().xy - data.pos.xy)
        local fov = (1 / GetGameplayCamFov()) * 100
        local scale = ((1 / dist) * 2) * fov
        SetDrawOrigin(data.pos.x, data.pos.y, data.pos.z, 0)
        DrawSprite(
            data.textureDict,
            data.textureName,
            (data.x or 0) * scale,
            (data.y or 0) * scale,
            data.width * scale,
            data.height * scale,
            data.heading or 0,
            data.r or 255,
            data.g or 255,
            data.b or 255,
            data.a or 255
        )
        ClearDrawOrigin()
    end
    return draw
end

function UI.DrawSprite3dNoDownSize(data, dontDrawHowOfScreen)
    if dontDrawHowOfScreen == nil then
        dontDrawHowOfScreen = false
    end

    local draw = false
    if dontDrawHowOfScreen == false then
        draw = true
    else
        local get, x,y = GetScreenCoordFromWorldCoord(data.pos.x, data.pos.y, data.pos.z)
        if not get or x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0 then
            draw = false
        else
            draw = true
        end
    end

    if draw then
        local scale = 1
        SetDrawOrigin(data.pos.x, data.pos.y, data.pos.z, 0)
        DrawSprite(
            data.textureDict,
            data.textureName,
            data.x or (0 * scale),
            data.y or (0 * scale),
            data.width * scale,
            data.height * scale,
            data.heading or 0,
            data.r or 255,
            data.g or 255,
            data.b or 255,
            data.a or 255
        )
        ClearDrawOrigin()
    end
    return draw

end

-- function UI.ConvertToPixel(x, y)
--     return (x * 1920), (y * 1080)
-- end

function UI.ConvertToPixel(x, y)
    return (x / 1920), (y / 1080)
end

function UI.ConvertToRes(x, y)
    return (x * 1920), (y * 1080)
end

FADE_UI = {}
FADE_UI.Alpha = 0
FADE_UI.IsScreenFaded = false
FADE_UI.DoingFade = false
FADE_UI.IsUIAlreadyActive = false


function FADE_UI.DoFadeOut(camNames, cam_param)
    FADE_UI.DoingFade = true
    FADE_UI.IsScreenFaded = true
    FADE_UI.RunFadeLogic()
    while FADE_UI.Alpha < 255 do
        if cam_param ~= nil then
            Cam.dof(camNames[1], cam_param.cam1.dof[1], cam_param.cam1.dof[2], cam_param.cam1.dof[3])
            Cam.dof(camNames[2], cam_param.cam2.dof[1], cam_param.cam2.dof[2], cam_param.cam2.dof[3])
        end
        FADE_UI.Alpha = FADE_UI.Alpha + 2
        Wait(1)
    end
    FADE_UI.Alpha = 255
    FADE_UI.DoingFade = false
end

function FADE_UI.DoFadeIn(camNames, cam_param)
    FADE_UI.DoingFade = true
    while FADE_UI.Alpha > 0 do
        if cam_param ~= nil then
            Cam.dof(camNames[1], cam_param.cam1.dof[1], cam_param.cam1.dof[2], cam_param.cam1.dof[3])
            Cam.dof(camNames[2], cam_param.cam2.dof[1], cam_param.cam2.dof[2], cam_param.cam2.dof[3])
        end
        FADE_UI.Alpha = FADE_UI.Alpha - 2
        Wait(1)
    end
    FADE_UI.Alpha = 0
    FADE_UI.IsScreenFaded = false
    FADE_UI.DoingFade = false
end

function FADE_UI.DrawFade()
    SetScriptGfxDrawOrder(100)
    DrawRect(0.5, 0.5, 1.0, 1.0, 0, 0, 0, FADE_UI.Alpha)
    SetScriptGfxDrawOrder(0)
end 

function FADE_UI.RunFadeLogic()
    if FADE_UI.IsUIAlreadyActive then
        return
    end
    Citizen.CreateThread(function()
        FADE_UI.IsUIAlreadyActive = true
        while FADE_UI.Alpha > 0 do
            FADE_UI.DrawFade()
    
            if FADE_UI.Alpha > 0 then
                Wait(1)
            else
                Wait(100)
            end
        end
        FADE_UI.IsUIAlreadyActive = false
    end)
end

function UI.CalculateNextScalablePosition(targetPosition, actualPosition, speed)
    if targetPosition > actualPosition then
        local dist = targetPosition - actualPosition
        if dist < 0.0001 then
            return targetPosition
        end
    else
        local dist = actualPosition - targetPosition
        if dist < 0.0001 then
            return targetPosition
        end
    end

    return actualPosition + ((targetPosition - actualPosition) * (speed * Utils.TimeFrame))
end

function UI.CalculateLinearScalablePosition(targetPosition, actualPosition, speed)
    if targetPosition > actualPosition then
        local dist = targetPosition - actualPosition
        if dist < 0.0001 then
            return targetPosition
        end
    else
        local dist = actualPosition - targetPosition
        if dist < 0.0001 then
            return targetPosition
        end
    end

    if targetPosition > actualPosition then
        if actualPosition + (speed * Utils.TimeFrame) > targetPosition then
            return targetPosition
        else
            return actualPosition + (speed * Utils.TimeFrame)
        end
    else
        if actualPosition - (speed * Utils.TimeFrame) < targetPosition then
            return targetPosition
        else
            return actualPosition - (speed * Utils.TimeFrame)
        end
    end
end

UI.CacheSize = {}
function UI.CalculateCorrecteSizeForUI(ui_name, dict, sprite, maxX, maxY)
    if UI.CacheSize[ui_name] == nil then
        UI.CacheSize[ui_name] = {}
    end

    if UI.CacheSize[ui_name][dict..sprite] == nil then
        if HasStreamedTextureDictLoaded(dict) then
            local data = GetTextureResolution(dict, sprite)
            local x,y = UI.ConvertToPixel(data.x, data.y)
            UI.CacheSize[ui_name][dict..sprite] = {}
            UI.CacheSize[ui_name][dict..sprite].size = {x, y}
            UI.CacheSize[ui_name][dict..sprite].resizeDone = false
            local maxXsize, maxYsize = UI.ConvertToPixel(maxX, maxY)
            UI.CacheSize[ui_name][dict..sprite].maxSize = {maxXsize, maxYsize}
            print("new", ui_name, dict, sprite, data.x, data.y, maxXsize, maxYsize)
        else
            RequestStreamedTextureDict(dict, false)
        end
    end

    if UI.CacheSize[ui_name][dict..sprite] ~= nil then
        local self = UI.CacheSize[ui_name][dict..sprite]
        if not UI.CacheSize[ui_name][dict..sprite].resizeDone then
            if UI.CacheSize[ui_name][dict..sprite].size[1] > self.maxSize[1] then
                UI.CacheSize[ui_name][dict..sprite].size[1] = UI.CacheSize[ui_name][dict..sprite].size[1] / 1.1
                UI.CacheSize[ui_name][dict..sprite].size[2] = UI.CacheSize[ui_name][dict..sprite].size[2] / 1.1
            end
        
            if UI.CacheSize[ui_name][dict..sprite].size[2] > self.maxSize[2] then
                UI.CacheSize[ui_name][dict..sprite].size[2] = UI.CacheSize[ui_name][dict..sprite].size[2] / 1.1
                UI.CacheSize[ui_name][dict..sprite].size[1] = UI.CacheSize[ui_name][dict..sprite].size[1] / 1.1
            end
    
            if UI.CacheSize[ui_name][dict..sprite].size[1] <= self.maxSize[1] and UI.CacheSize[ui_name][dict..sprite].size[2] <= self.maxSize[2] then
                print("done", ui_name, dict, sprite, UI.CacheSize[ui_name][dict..sprite].size[1], UI.CacheSize[ui_name][dict..sprite].size[2], self.maxSize[1], self.maxSize[2])
                UI.CacheSize[ui_name][dict..sprite].resizeDone = true
            end
        end
    else
        return 0, 0, false
    end


    return UI.CacheSize[ui_name][dict..sprite].size[1], UI.CacheSize[ui_name][dict..sprite].size[2], UI.CacheSize[ui_name][dict..sprite].resizeDone
end