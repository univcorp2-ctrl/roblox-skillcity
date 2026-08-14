--!strict

local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage").SkillCity.Config)
local Analytics = require(script.Parent.Analytics)
local PlayerDataService = require(script.Parent.PlayerDataService)

local IncidentService = {}
local rng = Random.new()
local active: {[BasePart]: {id: string, needed: number, contributors: {[number]: boolean}, expiresAt: number}} = {}

local INCIDENTS = {
    {label = "SAFE CROSSING", needed = 2},
    {label = "DELIVERY RUSH", needed = 2},
    {label = "CITY RESPONSE", needed = 3},
    {label = "MARKET COUNT", needed = 2},
}

local function playerFromHit(hit: BasePart): Player?
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    return Players:GetPlayerFromCharacter(model)
end

local function clear(pad: BasePart, remote: RemoteEvent, success: boolean)
    local incident = active[pad]
    if not incident then return end
    if success then
        for userId in incident.contributors do
            local player = Players:GetPlayerByUserId(userId)
            if player then
                PlayerDataService.reward(player, Config.Rewards.IncidentTeamClear, 3, "IncidentClears")
                Analytics.event(player, "incident_cleared", {incident = incident.id, teamSize = incident.needed})
            end
        end
        remote:FireAllClients("toast", {text = "City incident cleared by teamwork!", kind = "success"})
    end
    pad.Color = Color3.fromRGB(255, 214, 77)
    pad:SetAttribute("IncidentLabel", "")
    active[pad] = nil
end

function IncidentService.start(map: Instance, remote: RemoteEvent)
    local folder = map:WaitForChild("IncidentPads")
    for _, child in folder:GetChildren() do
        if child:IsA("BasePart") then
            child.Touched:Connect(function(hit)
                local player = playerFromHit(hit)
                local incident = active[child]
                if not player or not incident or incident.contributors[player.UserId] then return end
                incident.contributors[player.UserId] = true
                PlayerDataService.reward(player, Config.Rewards.IncidentContribution, 1)
                remote:FireClient(player, "toast", {text = "Contribution counted. Bring teammates!", kind = "info"})
                local count = 0
                for _ in incident.contributors do count += 1 end
                if count >= incident.needed then
                    clear(child, remote, true)
                end
            end)
        end
    end

    task.spawn(function()
        while true do
            task.wait(Config.IncidentIntervalSeconds)
            local free = {}
            for _, child in folder:GetChildren() do
                if child:IsA("BasePart") and not active[child] then
                    table.insert(free, child)
                end
            end
            if #free == 0 then continue end
            local pad = free[rng:NextInteger(1, #free)]
            local def = INCIDENTS[rng:NextInteger(1, #INCIDENTS)]
            active[pad] = {id = def.label, needed = def.needed, contributors = {}, expiresAt = workspace:GetServerTimeNow() + 60}
            pad.Color = Color3.fromRGB(255, 94, 94)
            pad:SetAttribute("IncidentLabel", def.label)
            remote:FireAllClients("incident", {label = def.label, needed = def.needed, position = pad.Position, seconds = 60})
            task.delay(60, function()
                if active[pad] then clear(pad, remote, false) end
            end)
        end
    end)
end

return IncidentService
