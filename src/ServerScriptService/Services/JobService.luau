--!strict

local Players = game:GetService("Players")

local MathTasks = require(game:GetService("ReplicatedStorage").SkillCity.MathTasks)
local Config = require(game:GetService("ReplicatedStorage").SkillCity.Config)
local Analytics = require(script.Parent.Analytics)
local PlayerDataService = require(script.Parent.PlayerDataService)

local JobService = {}
local rng = Random.new()
local active: {[number]: {task: any, nonce: string, expiresAt: number}} = {}

local function playerFromHit(hit: BasePart): Player?
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    return Players:GetPlayerFromCharacter(model)
end

function JobService.start(map: Instance, remote: RemoteEvent, submit: RemoteFunction)
    local market = map:WaitForChild("Market") :: BasePart
    market.Touched:Connect(function(hit)
        local player = playerFromHit(hit)
        if not player or active[player.UserId] then
            return
        end
        local taskData = MathTasks.generate(rng)
        local nonce = string.format("%d-%d", player.UserId, rng:NextInteger(100000, 999999))
        active[player.UserId] = {task = taskData, nonce = nonce, expiresAt = workspace:GetServerTimeNow() + 40}
        remote:FireClient(player, "math_task", {prompt = taskData.prompt, nonce = nonce, seconds = 40})
        Analytics.event(player, "math_task_started", {context = taskData.context})
    end)

    submit.OnServerInvoke = function(player: Player, nonce: string, rawAnswer: any)
        local item = active[player.UserId]
        if not item or item.nonce ~= nonce then
            return {ok = false, message = "Task expired."}
        end
        active[player.UserId] = nil
        if workspace:GetServerTimeNow() > item.expiresAt then
            Analytics.event(player, "math_task_timeout", {context = item.task.context})
            return {ok = false, message = "Too slow — try another market order."}
        end
        local answer = tonumber(rawAnswer)
        if not answer or math.abs(answer - item.task.answer) > 0.001 then
            Analytics.event(player, "math_task_wrong", {context = item.task.context})
            return {ok = false, message = "Not quite. Check the quantities and try again."}
        end
        PlayerDataService.reward(player, Config.Rewards.MathPerfect, 2, "PerfectMath")
        Analytics.event(player, "math_task_correct", {context = item.task.context})
        return {ok = true, message = "Perfect calculation! +coins +reputation"}
    end
end

return JobService
