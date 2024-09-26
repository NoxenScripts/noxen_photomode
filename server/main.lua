RegisterNetEvent("photomode:SetPlayerInPhotomode", function()
    TriggerClientEvent("photomode:SetPlayerInPhotomode", -1, source)
end)

RegisterNetEvent("photomode:RemovePlayerInPhotomode", function()
    TriggerClientEvent("photomode:RemovePlayerInPhotomode", -1, source)
end)