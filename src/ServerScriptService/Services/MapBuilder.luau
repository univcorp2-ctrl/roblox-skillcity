--!strict

local MapBuilder = {}

local function part(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function billboard(parent: Instance, text: string)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(220, 54)
    gui.StudsOffset = Vector3.new(0, 4, 0)
    gui.AlwaysOnTop = true
    gui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
    label.BackgroundTransparency = 0.15
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = text
    label.Parent = gui
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)
end

function MapBuilder.build()
    local old = workspace:FindFirstChild("SkillCityMap")
    if old then
        old:Destroy()
    end

    local map = Instance.new("Folder")
    map.Name = "SkillCityMap"
    map.Parent = workspace

    part(map, "Ground", Vector3.new(420, 2, 420), CFrame.new(0, -1, 0), Color3.fromRGB(99, 156, 89), Enum.Material.Grass)
    part(map, "MainRoadNS", Vector3.new(46, 0.6, 360), CFrame.new(0, 0.15, 0), Color3.fromRGB(48, 51, 58), Enum.Material.Asphalt)
    part(map, "MainRoadEW", Vector3.new(360, 0.6, 46), CFrame.new(0, 0.17, 0), Color3.fromRGB(48, 51, 58), Enum.Material.Asphalt)

    for _, x in {-10, 10} do
        for z = -160, 160, 20 do
            part(map, "LaneMark", Vector3.new(0.6, 0.1, 9), CFrame.new(x, 0.52, z), Color3.fromRGB(240, 230, 164), Enum.Material.Neon)
        end
    end
    for _, z in {-10, 10} do
        for x = -160, 160, 20 do
            part(map, "LaneMark", Vector3.new(9, 0.1, 0.6), CFrame.new(x, 0.54, z), Color3.fromRGB(240, 230, 164), Enum.Material.Neon)
        end
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "CityHallSpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Position = Vector3.new(-62, 1, -62)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Color = Color3.fromRGB(85, 165, 255)
    spawn.Parent = map
    billboard(spawn, "CITY HALL")

    local jobs = {
        {"CourierHub", Vector3.new(70, 2, 62), "COURIER HUB", Color3.fromRGB(255, 164, 72)},
        {"Market", Vector3.new(-70, 2, 62), "MARKET", Color3.fromRGB(87, 201, 131)},
        {"Dispatch", Vector3.new(70, 2, -62), "DISPATCH", Color3.fromRGB(234, 91, 91)},
        {"DrivingSchool", Vector3.new(-70, 2, -62), "DRIVING SCHOOL", Color3.fromRGB(121, 107, 255)},
    }
    for _, item in jobs do
        local p = part(map, item[1], Vector3.new(28, 4, 24), CFrame.new(item[2]), item[4], Enum.Material.Concrete)
        billboard(p, item[3])
        p:SetAttribute("JobHub", item[1])
    end

    local intersection = Instance.new("Folder")
    intersection.Name = "CentralIntersection"
    intersection.Parent = map

    local stopNS = part(intersection, "StopZoneNS", Vector3.new(40, 6, 4), CFrame.new(0, 3, -25), Color3.new(1, 0, 0))
    stopNS.Transparency = 1
    stopNS.CanCollide = false
    stopNS:SetAttribute("TrafficAxis", "NS")
    local stopEW = part(intersection, "StopZoneEW", Vector3.new(4, 6, 40), CFrame.new(-25, 3, 0), Color3.new(1, 0, 0))
    stopEW.Transparency = 1
    stopEW.CanCollide = false
    stopEW:SetAttribute("TrafficAxis", "EW")

    local light = part(intersection, "TrafficLight", Vector3.new(4, 12, 4), CFrame.new(25, 6, 25), Color3.fromRGB(30, 30, 34), Enum.Material.Metal)
    billboard(light, "CENTRAL SIGNAL")

    local incidentPads = Instance.new("Folder")
    incidentPads.Name = "IncidentPads"
    incidentPads.Parent = map
    for i, pos in {Vector3.new(120, 1, 120), Vector3.new(-120, 1, 120), Vector3.new(120, 1, -120), Vector3.new(-120, 1, -120)} do
        local pad = part(incidentPads, "IncidentPad" .. i, Vector3.new(18, 1, 18), CFrame.new(pos), Color3.fromRGB(255, 214, 77), Enum.Material.Neon)
        billboard(pad, "INCIDENT ZONE")
    end

    return map
end

return MapBuilder
