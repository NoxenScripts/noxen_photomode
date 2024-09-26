Utils = {}
function Utils.CalculateNextScalablePosition(targetPosition, actualPosition, speed)
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

    return actualPosition + ((targetPosition - actualPosition) * (speed * 1))
end