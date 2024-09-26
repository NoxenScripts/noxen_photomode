Config = {}

Config.MaxDistanceFromPlayer = 20.0 -- Max distance from player to camera
Config.ShowIconAbovePlayersInPhotomode = true

Config.CheckJob = true  -- Activate job check
Config.CheckGroup = true  -- Activate user group check
Config.CheckVIP = false  -- Activate VIP check

-- List of jobs authorized to use photo mode (if CheckJob is enabled)
Config.AllowedJobs = {'police', 'ambulance'}

-- List of groups authorized to use photo mode (if CheckGroup is enabled)
Config.AllowedGroups = {'admin', 'mod'}

-- Notification configuration
Config.NotificationType = 'esx' -- Can be 'esx', 'qb', or 'custom'.

-- Function Triggered when a player enter photomode
-- You can use this function to toggle off your HUD
function Config.EnteredPhotomode()

end

-- Function Triggered when a player exit photomode
-- You can use this function to toggle on your HUD
function Config.ExitedPhotomode()

end


-- Fonction Server Side
function Config.IsPlayerVIP(source)
    return false
end

function Config.SendNotification(source, message)
    if Config.NotificationType == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
    elseif Config.NotificationType == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, message, 'error')
    elseif Config.NotificationType == 'custom' then
        -- If the user wants to use his own notification system
        -- He can add a function here for his notifications
        -- Example: TriggerClientEvent('custom_notify', source, message, 'error')
    end
end