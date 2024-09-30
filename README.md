# In-Game Photo Mode Tool – Elevate Your In-Game Photography

[![Join our Discord](https://cdn.discordapp.com/attachments/845277808288202762/1290383775909286020/photomode-noxen.png?ex=66fc430a&is=66faf18a&hm=da4cd713ad7336d512160661d7b0bc04b1daf0130c4180e6d80bc328ef8773b4&)](https://discord.gg/6yZB4YwPdw)

Transform the way you capture in-game moments with our In-Game Photo Mode Tool. Designed for content creators and passionate players, this tool lets you take stunning, professional-grade screenshots effortlessly, without the need for external editors like Rockstar Editor.

## Why Choose Our Photo Mode Tool?
With our tool, you gain access to advanced features that put you in complete control of every shot. Whether you're looking to capture fast-paced action scenes or cinematic landscapes, our tool offers everything you need:

### 📸 Key Features:
- **Slow Motion (Time Scaling):**  
  Masterfully control the pace of the game by slowing down time locally. Perfect for capturing action shots with pinpoint precision.

- **Depth of Field Control:**  
  Add a professional touch to your screenshots by adjusting the depth of field in real time. Highlight key elements and create stunning cinematic effects with ease.

- **Seamless and Intuitive Controls:**  
  Our tool integrates directly into the game, allowing you to make adjustments instantly without pausing or interrupting gameplay.

- **Player Identification in Photo Mode:**  
  Players using the photo mode are easily identifiable by a visible icon above their heads, ensuring transparency during multiplayer sessions or content creation.

### 🚀 Why This Tool Stands Out:
- **Save Time:**  
  No need to exit the game or rely on third-party editors. Everything you need is built right into the game.

- **Boost Creativity:**  
  Elevate your content with full control over in-game photography. Perfect for social media, streams, and personal portfolios.

- **User-Friendly:**  
  Easy to use for both beginners and experienced content creators.

### 🎯 Community and Support:
We're constantly evolving, and your feedback is invaluable! Join us on Discord to share your ideas and request new features. We're always listening and eager to improve the tool to fit your needs.

Unlock the full potential of your in-game photography with this indispensable tool. Don't settle for basic screenshots—capture your moments with professional quality and precision.

Join our community on Discord to share your feedback, ideas, and connect with other users!

[![Join our Discord](https://cdn.discordapp.com/attachments/845277808288202762/1290383414624522330/banniere.png?ex=66fc42b4&is=66faf134&hm=c2c3a92145de0b1f93a37039842eb463bd1f2ecf1882098cfabcf91f0d91d0c5&)](https://discord.gg/6yZB4YwPdw)
https://discord.gg/6yZB4YwPdw

## ⚙️ Technical Configuration

Below is the configuration file for the In-Game Photo Mode Tool. You can customize it to suit your server's needs:

```lua
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

-- Function Triggered when a player enters photomode
-- You can use this function to toggle off your HUD
function Config.EnteredPhotomode()

end

-- Function Triggered when a player exits photomode
-- You can use this function to toggle on your HUD
function Config.ExitedPhotomode()

end

-- Function Server Side
-- This function currently returns false for all players.
-- To implement VIP checks, you need to edit this function to include the logic for determining if a player is a VIP.
-- Replace the 'return false' line with the appropriate VIP check logic.
function Config.IsPlayerVIP(source)
    -- Add your VIP check logic here
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
```

### Key Configuration Options:
- **MaxDistanceFromPlayer:** Maximum distance allowed between the player and the camera.
- **ShowIconAbovePlayersInPhotomode:** Shows an icon above players in photomode for better visibility.
- **CheckJob / CheckGroup / CheckVIP:** Enable or disable checks for jobs, groups, and VIP status.

### Job and Group Authorization:
- **AllowedJobs:** List of jobs that are authorized to use photo mode.
- **AllowedGroups:** List of groups that are authorized to use photo mode.

### Notifications:
- **NotificationType:** Specify the type of notification system to use (`'esx'`, `'qb'`, or `'custom'`).

### Custom Functions:
- **EnteredPhotomode:** Use this function to customize actions (e.g., hiding the HUD) when a player enters photo mode.
- **ExitedPhotomode:** Use this function to customize actions (e.g., showing the HUD) when a player exits photo mode.
- **IsPlayerVIP:** Implement your custom logic to determine if a player is a VIP.

---

Feel free to customize the config file as needed to adapt the tool to your server!
