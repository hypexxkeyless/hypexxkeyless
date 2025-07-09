--// Hypexx Keyless Menu - Emergency Hamburg Script

-- Load Rayfield Library
local success, Rayfield = pcall(loadstring, game:HttpGet("https://sirius.menu/rayfield"))
if not success then
    warn("[Hypexx] Rayfield could not be loaded.")
    return
end
Rayfield = Rayfield()

-- Services and Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local AimbotEnabled = false
local ESPEnabled = false
local AimbotDistance = 500
local FOVRadius = 150
local SelectedPart = "HumanoidRootPart"
local FOVColor = Color3.fromRGB(255, 0, 0)

local ShowName = true
local ShowDistance = true

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Hypexx Keyless Menu",
    LoadingTitle = "Hypexx Keyless Menu loading...",
    LoadingSubtitle = "Powered by Hypexx",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local ExtraTab = Window:CreateTab("Extras", 4483362458)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Radius = FOVRadius
fovCircle.Color = FOVColor
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Visibility Check
local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 999
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

-- Closest Player
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimbotDistance
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(SelectedPart) then
            local part = player.Character:FindFirstChild(SelectedPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if part and humanoid and humanoid.Health > 25 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local distFromCenter = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                local distance = (Camera.CFrame.Position - part.Position).Magnitude
                if distance < shortestDistance and distFromCenter <= FOVRadius and IsVisible(part) then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot Tab
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value) AimbotEnabled = Value end
})

AimbotTab:CreateSlider({
    Name = "Aimbot Distance",
    Range = {0, 500},
    Increment = 10,
    CurrentValue = AimbotDistance,
    Callback = function(Value) AimbotDistance = Value end
})

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {0, 300},
    Increment = 5,
    CurrentValue = FOVRadius,
    Callback = function(Value) FOVRadius = Value end
})

AimbotTab:CreateColorPicker({
    Name = "FOV Color",
    Color = FOVColor,
    Callback = function(Value) FOVColor = Value end
})

AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = "HumanoidRootPart",
    Callback = function(Value)
        SelectedPart = Value
    end
})

-- ESP Tab
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value) ESPEnabled = Value end
})

ESPTab:CreateToggle({
    Name = "Show Player Name",
    CurrentValue = true,
    Callback = function(Value) ShowName = Value end
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Callback = function(Value) ShowDistance = Value end
})

-- FPS Booster
ExtraTab:CreateButton({
    Name = "FPS Booster",
    Callback = function()
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
        settings().Rendering.QualityLevel = 1
        setfpscap(60)
    end
})

-- UI Toggle (V Key)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        Window.Enabled = not Window.Enabled
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Aimbot
    fovCircle.Visible = AimbotEnabled
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = FOVRadius
    fovCircle.Color = FOVColor

    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(SelectedPart) then
            local part = target.Character[SelectedPart]
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
    end

    -- ESP
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    if ShowName then
                        local nameTag = Drawing.new("Text")
                        nameTag.Text = player.DisplayName
                        nameTag.Size = 14
                        nameTag.Center = true
                        nameTag.Outline = true
                        nameTag.Position = Vector2.new(screenPos.X, screenPos.Y - 15)
                        nameTag.Color = Color3.fromRGB(255, 255, 255)
                        nameTag.Visible = true
                        task.delay(0.03, function() nameTag:Remove() end)
                    end
                    if ShowDistance then
                        local distance = math.floor((Camera.CFrame.Position - head.Position).Magnitude)
                        local distanceTag = Drawing.new("Text")
                        distanceTag.Text = tostring(distance).."m"
                        distanceTag.Size = 14
                        distanceTag.Center = true
                        distanceTag.Outline = true
                        distanceTag.Position = Vector2.new(screenPos.X, screenPos.Y)
                        distanceTag.Color = Color3.fromRGB(0, 255, 0)
                        distanceTag.Visible = true
                        task.delay(0.03, function() distanceTag:Remove() end)
                    end
                end
            end
        end
    end
end)
