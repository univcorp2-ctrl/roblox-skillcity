--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("SkillCityRemotes")
local event = remotes:WaitForChild("Event") :: RemoteEvent
local submitMath = remotes:WaitForChild("SubmitMath") :: RemoteFunction

local gui = Instance.new("ScreenGui")
gui.Name = "SkillCityHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local top = Instance.new("Frame")
top.Size = UDim2.fromOffset(330, 58)
top.Position = UDim2.fromOffset(18, 18)
top.BackgroundColor3 = Color3.fromRGB(19, 23, 31)
top.BackgroundTransparency = 0.08
top.Parent = gui
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1, -20, 1, 0)
stats.Position = UDim2.fromOffset(10, 0)
stats.BackgroundTransparency = 1
stats.TextColor3 = Color3.new(1, 1, 1)
stats.Font = Enum.Font.GothamBold
stats.TextSize = 16
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.Parent = top

local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromOffset(500, 48)
toast.Position = UDim2.new(0.5, -250, 0, 22)
toast.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
toast.BackgroundTransparency = 1
toast.TextTransparency = 1
toast.TextColor3 = Color3.new(1, 1, 1)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 16
toast.TextWrapped = true
toast.Parent = gui
Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 10)

local mathFrame = Instance.new("Frame")
mathFrame.Size = UDim2.fromOffset(430, 230)
mathFrame.Position = UDim2.new(0.5, -215, 0.5, -115)
mathFrame.BackgroundColor3 = Color3.fromRGB(22, 27, 36)
mathFrame.Visible = false
mathFrame.Parent = gui
Instance.new("UICorner", mathFrame).CornerRadius = UDim.new(0, 14)

local prompt = Instance.new("TextLabel")
prompt.Size = UDim2.new(1, -30, 0, 90)
prompt.Position = UDim2.fromOffset(15, 15)
prompt.BackgroundTransparency = 1
prompt.TextColor3 = Color3.new(1, 1, 1)
prompt.Font = Enum.Font.GothamBold
prompt.TextSize = 20
prompt.TextWrapped = true
prompt.Parent = mathFrame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -30, 0, 44)
input.Position = UDim2.fromOffset(15, 112)
input.BackgroundColor3 = Color3.fromRGB(38, 44, 58)
input.TextColor3 = Color3.new(1, 1, 1)
input.PlaceholderText = "Answer"
input.ClearTextOnFocus = false
input.Font = Enum.Font.Gotham
input.TextSize = 18
input.Parent = mathFrame
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

local submit = Instance.new("TextButton")
submit.Size = UDim2.new(1, -30, 0, 44)
submit.Position = UDim2.fromOffset(15, 170)
submit.BackgroundColor3 = Color3.fromRGB(70, 106, 255)
submit.TextColor3 = Color3.new(1, 1, 1)
submit.Text = "Submit"
submit.Font = Enum.Font.GothamBold
submit.TextSize = 16
submit.Parent = mathFrame
Instance.new("UICorner", submit).CornerRadius = UDim.new(0, 8)

local activeNonce: string? = nil

local function updateStats()
    stats.Text = string.format("💰 %d coins   ⭐ %d reputation", player:GetAttribute("Coins") or 0, player:GetAttribute("Reputation") or 0)
end
player:GetAttributeChangedSignal("Coins"):Connect(updateStats)
player:GetAttributeChangedSignal("Reputation"):Connect(updateStats)
updateStats()

local function showToast(text: string, kind: string?)
    toast.Text = text
    toast.BackgroundColor3 = if kind == "warning" then Color3.fromRGB(190, 70, 55) elseif kind == "success" then Color3.fromRGB(43, 142, 92) else Color3.fromRGB(35, 40, 52)
    TweenService:Create(toast, TweenInfo.new(0.15), {BackgroundTransparency = 0.08, TextTransparency = 0}):Play()
    task.delay(3.2, function()
        TweenService:Create(toast, TweenInfo.new(0.25), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    end)
end

submit.MouseButton1Click:Connect(function()
    if not activeNonce then return end
    submit.Active = false
    local ok, result = pcall(function()
        return submitMath:InvokeServer(activeNonce, input.Text)
    end)
    submit.Active = true
    mathFrame.Visible = false
    activeNonce = nil
    if ok and type(result) == "table" then
        showToast(result.message or "Done", if result.ok then "success" else "warning")
    else
        showToast("Connection issue. Try the next task.", "warning")
    end
end)

event.OnClientEvent:Connect(function(kind: string, payload: any)
    if kind == "toast" then
        showToast(payload.text, payload.kind)
    elseif kind == "math_task" then
        activeNonce = payload.nonce
        prompt.Text = "Market task\n" .. payload.prompt
        input.Text = ""
        mathFrame.Visible = true
        input:CaptureFocus()
    elseif kind == "incident" then
        showToast(string.format("TEAM EVENT: %s — %d players needed", payload.label, payload.needed), "info")
    elseif kind == "traffic_phase" then
        showToast("Central signal: " .. payload.phase .. " direction has green", "info")
    end
end)
