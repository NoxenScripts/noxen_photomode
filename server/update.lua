-----------------For support, scripts, and more----------------
--------------- https://discord.gg/a9d5k3GUen  -------------
---------------------------------------------------------------
if not Config.CheckForUpdates then return end

    local resource = 'noxen_photomode'
    local resourceName = GetCurrentResourceName() ~= resource and resource .. '(' .. GetCurrentResourceName() .. ')' or resource
    local version = GetResourceMetadata(GetCurrentResourceName(), 'version')
    local repoLink = 'https://api.github.com/repos/Noxen-Versions/' .. resource .. '/releases/latest'
    
    -- Get the latest version from the repository
    local function getRepoVersion(callback)
        PerformHttpRequest(repoLink, function(err, response)
            if err == 200 then
                local data = json.decode(response)
                callback(data.tag_name)
            else
                callback(nil)
            end
        end, "GET")
    end
    
    -- Compare versions and display warnings if necessary
    local function checkVersion(repoVersion)
        if version ~= repoVersion then
            print(string.format("^0[^3WARNING^0] %s is ^1NOT ^0up to date!", resourceName))
            print(string.format("^0[^3WARNING^0] Your Version: ^1%s^0", version))
            print(string.format("^0[^3WARNING^0] Latest Version: ^2%s^0", repoVersion))
            print("^0[^3WARNING^0] ^1Get the latest version from keymaster!^0")
        end
    end
    
    -- Main thread to check for updates periodically
    CreateThread(function()
        if GetCurrentResourceName() ~= resource then
            Wait(4500)
            print(string.format('^0[^3WARNING^0] Rename the folder to "%s", otherwise this resource could experience problems!', resource))
        end
    
        while true do
            getRepoVersion(function(repoVersion)
                if repoVersion then
                    checkVersion(repoVersion)
                else
                    print("^0[^3ERROR^0] Failed to fetch the latest version information.")
                end
            end)
    
            Wait(3600000) -- Check every hour
        end
    end)
    