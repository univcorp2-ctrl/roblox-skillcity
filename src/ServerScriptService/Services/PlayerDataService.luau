--!strict

local DataStoreService = game:GetService("DataStoreService")

local Config = require(game:GetService("ReplicatedStorage").SkillCity.Config)

local PlayerDataService = {}
local store = DataStoreService:GetDataStore("SkillCity_Player_v1")
local cache: {[number]: {[string]: any}} = {}

local function defaults()
    return {
        Coins = Config.StartingCoins,
        Reputation = Config.StartingReputation,
        CompletedJobs = 0,
        PerfectMath = 0,
        CleanTrafficRuns = 0,
        IncidentClears = 0,
        LastLoginDay = "",
    }
end

local function dayKey(): string
    local now = os.date("!*t")
    return string.format("%04d-%03d", now.year, now.yday)
end

function PlayerDataService.load(player: Player)
    local data = defaults()
    local ok, saved = pcall(function()
        return store:GetAsync(tostring(player.UserId))
    end)
    if ok and type(saved) == "table" then
        for key, value in saved do
            data[key] = value
        end
    end

    local today = dayKey()
    if data.LastLoginDay ~= today then
        data.LastLoginDay = today
        data.Coins += Config.DailyBonusCoins
    end

    cache[player.UserId] = data
    player:SetAttribute("Coins", data.Coins)
    player:SetAttribute("Reputation", data.Reputation)
end

function PlayerDataService.get(player: Player): {[string]: any}
    return cache[player.UserId] or defaults()
end

function PlayerDataService.reward(player: Player, coins: number, reputation: number, stat: string?)
    local data = cache[player.UserId]
    if not data then
        return
    end
    data.Coins += math.max(0, math.floor(coins))
    data.Reputation += math.max(0, math.floor(reputation))
    if stat then
        data[stat] = (data[stat] or 0) + 1
    end
    player:SetAttribute("Coins", data.Coins)
    player:SetAttribute("Reputation", data.Reputation)
end

function PlayerDataService.save(player: Player)
    local data = cache[player.UserId]
    if not data then
        return
    end
    pcall(function()
        store:UpdateAsync(tostring(player.UserId), function()
            return data
        end)
    end)
end

function PlayerDataService.remove(player: Player)
    PlayerDataService.save(player)
    cache[player.UserId] = nil
end

return PlayerDataService
