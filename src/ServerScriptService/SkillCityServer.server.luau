--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local services = script.Parent:WaitForChild("Services")
local MapBuilder = require(services.MapBuilder)
local PlayerDataService = require(services.PlayerDataService)
local TrafficService = require(services.TrafficService)
local JobService = require(services.JobService)
local IncidentService = require(services.IncidentService)
local MonetizationService = require(services.MonetizationService)
local Analytics = require(services.Analytics)

local folder = ReplicatedStorage:FindFirstChild("SkillCityRemotes") or Instance.new("Folder")
folder.Name = "SkillCityRemotes"
folder.Parent = ReplicatedStorage

local remote = folder:FindFirstChild("Event") or Instance.new("RemoteEvent")
remote.Name = "Event"
remote.Parent = folder

local submitMath = folder:FindFirstChild("SubmitMath") or Instance.new("RemoteFunction")
submitMath.Name = "SubmitMath"
submitMath.Parent = folder

local map = MapBuilder.build()
TrafficService.start(map, remote :: RemoteEvent)
JobService.start(map, remote :: RemoteEvent, submitMath :: RemoteFunction)
IncidentService.start(map, remote :: RemoteEvent)
MonetizationService.start()

Players.PlayerAdded:Connect(function(player)
    PlayerDataService.load(player)
    Analytics.event(player, "session_started", {version = require(ReplicatedStorage.SkillCity.Config).Version})
    task.delay(3, function()
        if player.Parent then
            remote:FireClient(player, "toast", {text = "Welcome to SkillCity. Learn by doing, earn status by helping.", kind = "info"})
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    PlayerDataService.remove(player)
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        PlayerDataService.save(player)
    end
end)
