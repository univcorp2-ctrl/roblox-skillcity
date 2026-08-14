--!strict

local AnalyticsService = game:GetService("AnalyticsService")

local Analytics = {}

function Analytics.event(player: Player, name: string, fields: {[string]: any}?)
    pcall(function()
        AnalyticsService:LogCustomEvent(player, name, 1, fields or {})
    end)
end

return Analytics
