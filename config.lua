Config = {}

Config.MaxDistanceFromPlayer = 20.0 -- Max distance from player to camera
Config.ShowIconAbovePlayersInPhotomode = true

Config.CheckJob = false  -- Activate job check
Config.CheckGroup = false  -- Activate user group check
Config.CheckVIP = false  -- Activate VIP check

-- List of jobs authorized to use photo mode (if CheckJob is enabled)
Config.AllowedJobs = {'police', 'ambulance'}

-- List of groups authorized to use photo mode (if CheckGroup is enabled)
Config.AllowedGroups = {'admin', 'mod'}

-- Notification configuration
Config.NotificationType = 'esx' -- Can be 'esx', 'qb', or 'custom'.

-- Check for updates
Config.CheckForUpdates = true -- Check for updates

-- Message to display when a player does not have permission to use the command
Config.NoPermissionMessage = 'You do not have permission to use this command.'

Config.HideCommandTip = false -- Hide the "Press [e]" text

-- Function Triggered when a player enter photomode
-- You can use this function to toggle off your HUD
function Config.EnteredPhotomode()

end

-- Function Triggered when a player exit photomode
-- You can use this function to toggle on your HUD
function Config.ExitedPhotomode()

end

-- VIP CONFIGURATION
-- VIP logic has been moved to server/main.lua for security
-- You can configure the Discord role check framework at the very top of that file


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
