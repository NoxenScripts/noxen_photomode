RegisterNetEvent("photomode:SetPlayerInPhotomode", function()
    TriggerClientEvent("photomode:SetPlayerInPhotomode", -1, source)
end)

RegisterNetEvent("photomode:RemovePlayerInPhotomode", function()
    TriggerClientEvent("photomode:RemovePlayerInPhotomode", -1, source)
end)

-- SECURE SERVER-SIDE DISCORD VIP CONFIG
local DiscordVIP = {
    BotToken = "YOUR_BOT_TOKEN_HERE", -- Your Discord Bot Token
    GuildID = "YOUR_GUILD_ID_HERE",   -- Your Discord Server ID
    RoleID = "YOUR_ROLE_ID_HERE"      -- The ID of the VIP Role
}

-- Isolated server-side VIP check function
local function IsPlayerVIP(source)
    -- Checks if bot token is properly set up
    if DiscordVIP.BotToken == "YOUR_BOT_TOKEN_HERE" or DiscordVIP.BotToken == "" then
        print("^1[Photomode] ERROR: Config.CheckVIP is true, but Discord Bot Token is missing in main.lua!^0")
        return false 
    end

    local discordId = nil
    
    -- Extract the player's Discord identifier from FiveM
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end

    -- If the player doesn't have Discord linked, deny VIP
    if not discordId then return false end

    -- Create a promise to halt the script while we wait for Discord to reply
    local p = promise.new()
    local endpoint = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(DiscordVIP.GuildID, discordId)
    
    PerformHttpRequest(endpoint, function(errorCode, resultData, resultHeaders)
        if errorCode == 200 and resultData then
            local data = json.decode(resultData)
            if data and data.roles then
                -- Check if the player has the matching Role ID
                for _, role in ipairs(data.roles) do
                    if role == DiscordVIP.RoleID then
                        p:resolve(true)
                        return
                    end
                end
            end
        end
        p:resolve(false)
    end, "GET", "", {
        ["Authorization"] = "Bot " .. DiscordVIP.BotToken,
        ["Content-Type"] = "application/json"
    })

    -- Await the result of the HTTP request before continuing
    return Citizen.Await(p)
end

-- Server-side command logging with integrated permissions check
RegisterCommand("photomode", function(source, args, rawCommand)
    if source == 0 then
        print("This command can only be executed by a player.")
        return
    end -- Checks if the command is executed by a player (source > 0)

    local hasPermission = false

    -- Check if all config options are disabled
    if not Config.CheckJob and not Config.CheckGroup and not Config.CheckVIP then
        hasPermission = true
    end

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
        local isVIP = IsPlayerVIP(source) -- Now calling the clean local function
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

end, false)
