API = {}

-- Framework Detection
API.Framework = nil
API.ESX = nil
API.QBCore = nil

CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        API.Framework = 'ESX'
        API.ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        API.Framework = 'QBCore'
        API.QBCore = exports['qb-core']:GetCoreObject()
    end

    print("^7(^3!^7) Framework detected: " .. (API.Framework or "None"))
end)

-- Get Player Job
function API.GetPlayerJob(source)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        return xPlayer.job.name
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.job.name
    end
    return nil
end

-- Get Player Money (Cash)
function API.GetPlayerMoney(source)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        return xPlayer.getMoney()
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.money['cash']
    end
    return nil
end

-- Get Player Bank
function API.GetPlayerBank(source)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        return xPlayer.getAccount('bank').money
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.money['bank']
    end
    return nil
end

-- Add Money to Player (Cash)
function API.AddPlayerMoney(source, amount)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        xPlayer.addMoney(amount)
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.AddMoney('cash', amount)
    end
end

-- Remove Money from Player (Cash)
function API.RemovePlayerMoney(source, amount)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        xPlayer.removeMoney(amount)
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.RemoveMoney('cash', amount)
    end
end

-- Add Money to Player (Bank)
function API.AddPlayerBank(source, amount)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        xPlayer.addAccountMoney('bank', amount)
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.AddMoney('bank', amount)
    end
end

-- Remove Money from Player (Bank)
function API.RemovePlayerBank(source, amount)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        xPlayer.removeAccountMoney('bank', amount)
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.RemoveMoney('bank', amount)
    end
end

-- Set Player Job
function API.SetPlayerJob(source, jobName, jobGrade)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        xPlayer.setJob(jobName, jobGrade)
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.SetJob(jobName, jobGrade)
    end
end

-- Get Player Identifier (Steam ID or License)
function API.GetPlayerIdentifier(source)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        return xPlayer.identifier -- Typically the Steam ID or license
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.license
    end
    return nil
end

function API.GetPlayerItemCount(source, itemName)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        local item = xPlayer.getInventoryItem(itemName)
        return item and item.count or 0
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        local item = xPlayer.Functions.GetItemByName(itemName)
        return item and item.amount or 0
    end
    return 0
end

-- AddPlayerItem: Add item to the player's inventory
function API.AddPlayerItem(source, itemName, amount)
    if API.CanCarryItem(source, itemName, amount) then
        if API.Framework == 'ESX' then
            local xPlayer = API.ESX.GetPlayerFromId(source)
            xPlayer.addInventoryItem(itemName, amount)
        elseif API.Framework == 'QBCore' then
            local xPlayer = API.QBCore.Functions.GetPlayer(source)
            xPlayer.Functions.AddItem(itemName, amount)
        end
    else
        print("Player cannot carry more of this item.")
    end
end

function API.RemovePlayerItem(source, itemName, amount)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(itemName, amount)
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        xPlayer.Functions.RemoveItem(itemName, amount)
    end
end

function API.HasPlayerItem(source, itemName)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        local item = xPlayer.getInventoryItem(itemName)
        return item and item.count > 0
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        local item = xPlayer.Functions.GetItemByName(itemName)
        return item ~= nil
    end
    return false
end

-- CanCarryItem: Check if the player can carry a certain amount of an item
function API.CanCarryItem(source, itemName, amount)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        local item = xPlayer.getInventoryItem(itemName)

        -- Check if ESX is using limit or weight-based inventory
        if item.limit ~= -1 then
            -- ESX Limit System
            return (item.count + amount) <= item.limit
        else
            -- ESX Weight System
            local currentWeight = xPlayer.getWeight()
            local itemWeight = item.weight * amount
            local maxWeight = API.ESX.Config.MaxWeight or 24000 -- Default to 24000 if not set
            return (currentWeight + itemWeight) <= maxWeight
        end
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        local itemInfo = API.QBCore.Shared.Items[itemName]

        if itemInfo then
            local currentWeight = xPlayer.PlayerData.weight or 0
            local itemWeight = itemInfo.weight * amount -- Weight of the item being added
            local maxWeight = API.QBCore.Config.Player.MaxWeight -- Configured max weight in QBCore

            -- Check if adding the item exceeds the player's max weight
            return (currentWeight + itemWeight) <= maxWeight
        end
    end
    return false
end

-- Get Player Group (for admin, moderator etc.)
function API.GetPlayerGroup(source)
    if API.Framework == 'ESX' then
        local xPlayer = API.ESX.GetPlayerFromId(source)
        return xPlayer.getGroup() -- Ex: 'user', 'admin', 'mod'
    elseif API.Framework == 'QBCore' then
        local xPlayer = API.QBCore.Functions.GetPlayer(source)
        return xPlayer.PlayerData.group -- if QBCore use group
    end
    return 'user' -- Si aucune info, par défaut 'user'
end

-- QBCore Refresh logic (https://docs.qbcore.org/qbcore-documentation/qb-core/shared-exports)
RegisterNetEvent('QBCore:Server:UpdateObject', function()
	if source ~= '' then return false end
	API.QBCore = exports['qb-core']:GetCoreObject()
end)