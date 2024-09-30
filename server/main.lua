RegisterNetEvent("photomode:SetPlayerInPhotomode", function()
    TriggerClientEvent("photomode:SetPlayerInPhotomode", -1, source)
end)

RegisterNetEvent("photomode:RemovePlayerInPhotomode", function()
    TriggerClientEvent("photomode:RemovePlayerInPhotomode", -1, source)
end)

-- Server-side command logging with integrated permissions check
RegisterCommand("photomode", function(source, args, rawCommand)
    if source == 0 then
        print("This command can only be executed by a player.")
        return
    end -- Checks if the command is executed by a player (source > 0)

    local hasPermission = true

    -- Job check (if enabled in config)
    if Config.CheckJob then
        local jobName = API.GetPlayerJob(source)
        for _, allowedJob in ipairs(Config.AllowedJobs) do
            if jobName == allowedJob then
                hasPermission = true
                break
            end
        end
    end

    -- Group check (if enabled in config)
    if Config.CheckGroup then
        local group = API.GetPlayerGroup(source)
        for _, allowedGroup in ipairs(Config.AllowedGroups) do
            if group == allowedGroup then
                hasPermission = true
                break
            end
        end
    end

    -- VIP status check (if enabled in config)
    if Config.CheckVIP then
        local isVIP = Config.IsPlayerVIP(source)
        if isVIP then
            hasPermission = true
        end
    end

    -- If the player has the necessary permissions
    if hasPermission then
        -- Send event to customer to activate or deactivate photo mode
        TriggerClientEvent('photomode:toggleMode', source)
    else
        -- Notification to player that he does not have the necessary permissions
        Config.SendNotification(source, Config.NoPermissionMessage)
    end

end, false) -- false means that the command is not restricted via ACE by default
