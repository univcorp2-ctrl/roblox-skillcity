--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(game:GetService("ReplicatedStorage").SkillCity.Config)
local Analytics = require(script.Parent.Analytics)

local MonetizationService = {}

function MonetizationService.start()
    if not Config.Monetization.Enabled then
        warn("[SkillCity] Monetization disabled until real IDs and grants are configured.")
        return
    end

    local productById: {[number]: string} = {}
    for key, id in Config.Monetization.DeveloperProducts do
        if type(id) == "number" and id > 0 then
            productById[id] = key
        end
    end

    MarketplaceService.ProcessReceipt = function(receipt)
        local player = game:GetService("Players"):GetPlayerByUserId(receipt.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        local key = productById[receipt.ProductId]
        if not key then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        -- No paid product is acknowledged in v0.1.0. A durable, idempotent
        -- entitlement grant must be implemented before Monetization.Enabled=true.
        Analytics.event(player, "paid_receipt_blocked_safe", {product = key})
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

return MonetizationService
