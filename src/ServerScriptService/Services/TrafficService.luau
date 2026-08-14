--!strict

local Players = game:GetService("Players")

local Analytics = require(script.Parent.Analytics)
local PlayerDataService = require(script.Parent.PlayerDataService)
local Config = require(game:GetService("ReplicatedStorage").SkillCity.Config)

local TrafficService = {}
local phase = "NS"
local phaseEndsAt = 0
local violations: {[number]: number} = {}
local debounce: {[number]: number} = {}

local function playerFromHit(hit: BasePart): Player?
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then
        return nil
    end
    return Players:GetPlayerFromCharacter(model)
end

function TrafficService.getPhase(): string
    return phase
end

function TrafficService.start(map: Instance, remote: RemoteEvent)
    phaseEndsAt = workspace:GetServerTimeNow() + 18
    task.spawn(function()
        while true do
            if workspace:GetServerTimeNow() >= phaseEndsAt then
                phase = if phase == "NS" then "EW" else "NS"
                phaseEndsAt = workspace:GetServerTimeNow() + 18
                remote:FireAllClients("traffic_phase", {phase = phase, endsAt = phaseEndsAt})
            end
            task.wait(0.5)
        end
    end)

    local intersection = map:WaitForChild("CentralIntersection")
    for _, zone in intersection:GetChildren() do
        if zone:IsA("BasePart") and zone:GetAttribute("TrafficAxis") then
            zone.Touched:Connect(function(hit)
                local player = playerFromHit(hit)
                if not player then
                    return
                end
                local now = os.clock()
                if debounce[player.UserId] and now - debounce[player.UserId] < 3 then
                    return
                end
                debounce[player.UserId] = now
                local axis = zone:GetAttribute("TrafficAxis")
                if axis ~= phase then
                    violations[player.UserId] = (violations[player.UserId] or 0) + 1
                    Analytics.event(player, "traffic_violation", {axis = axis, phase = phase})
                    remote:FireClient(player, "toast", {text = "Red signal: stop before the line.", kind = "warning"})
                else
                    PlayerDataService.reward(player, Config.Rewards.TrafficPerfect, 1, "CleanTrafficRuns")
                    Analytics.event(player, "traffic_clean_crossing", {axis = axis})
                    remote:FireClient(player, "toast", {text = "+ clean traffic decision", kind = "success"})
                end
            end)
        end
    end
end

return TrafficService
