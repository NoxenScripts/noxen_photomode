RegisterNetEvent("photomode:SetPlayerInPhotomode", function()
    TriggerClientEvent("photomode:SetPlayerInPhotomode", -1, source)
end)

RegisterNetEvent("photomode:RemovePlayerInPhotomode", function()
    TriggerClientEvent("photomode:RemovePlayerInPhotomode", -1, source)
end)

RegisterNetEvent('photomode:checkPermission', function()
    local source = source
    local hasPermission = false

    if Config.CheckJob then
        local jobName = API.GetPlayerJob(source)
        for _, allowedJob in ipairs(Config.AllowedJobs) do
            if jobName == allowedJob then
                hasPermission = true
                break
            end
        end
    end

    if Config.CheckGroup then
        local group = API.GetPlayerGroup(source)
        for _, allowedGroup in ipairs(Config.AllowedGroups) do
            if group == allowedGroup then
                hasPermission = true
                break
            end
        end
    end

    if Config.CheckVIP then
        local isVIP = Config.IsPlayerVIP(source)
        if isVIP then
            hasPermission = true
        end
    end

    if hasPermission then
        TriggerClientEvent('photomode:toggleMode', source)
    else
        API.SendNotification(source, Config.NoPermissionMessage)
    end
end)
