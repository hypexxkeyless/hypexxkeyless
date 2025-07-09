--// Hypexx Keyless Menu - Emergency Hamburg Script

-- Load Rayfield Library
local success, Rayfield = pcall(loadstring, game:HttpGet("https://sirius.menu/rayfield"))
if not success then
    warn("[Hypexx] Rayfield could not be loaded.")
    return
end
Rayfield = Rayfield()

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local AimbotEnabled = false
local ESPEnabled = false
local FOVVisible = true
local VisibleCheck = true
local TeamCheck = true

local AimbotDistance = 500
local FOVRadius = 150
local FOVColor = Color3.fromRGB(255, 0, 0)
local SelectedPart = "HumanoidRootPart"

-- ESP Toggles
local UsernameESP = true
local DisplayNameESP = true
local RoleESP = true
local DistanceESP = true
local WantedESP = true
local CharmESP = true
local BoxESP = true

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Hypexx Keyless Menu",
    LoadingTitle = "Hypexx Keyless Menu loading...",
    LoadingSubtitle = "Powered by Hypexx",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false
})

-- Tabs
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local ExtraTab = Window:CreateTab("Extras", 4483362458)

-- Drawing FOV
local fovCircle = Drawing.new("Circle")
fovCircle.Filled = false
fovCircle.Thickness = 2
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
fovCircle.Color = FOVColor
fovCircle.Radius = FOVRadius
fovCircle.Visible = FOVVisible

-- Get Closest Player
local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 999
    local result = workspace:Raycast(origin, direction, RaycastParams.new())
    return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimbotDistance

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(SelectedPart) then
            local part = player.Character:FindFirstChild(SelectedPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if part and humanoid and humanoid.Health > 25 then
                if TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                if VisibleCheck and not IsVisible(part) then
                    continue
                end
                local screenPos = Camera:WorldToViewportPoint(part.Position)
                local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                local distance = (Camera.CFrame.Position - part.Position).Magnitude
                if distance < shortestDistance and distFromCenter <= FOVRadius then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Aimbot Tab UI
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
    Options = {"HumanoidRootPart", "Head"},
    CurrentOption = "HumanoidRootPart",
    Callback = function(Value) SelectedPart = Value end
})

AimbotTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = true,
    Callback = function(Value) VisibleCheck = Value end
})

AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(Value) TeamCheck = Value end
})

-- ESP Toggles
ESPTab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(v) ESPEnabled = v end })
ESPTab:CreateToggle({ Name = "Username ESP", CurrentValue = true, Callback = function(v) UsernameESP = v end })
ESPTab:CreateToggle({ Name = "Display Name ESP", CurrentValue = true, Callback = function(v) DisplayNameESP = v end })
ESPTab:CreateToggle({ Name = "Role ESP", CurrentValue = true, Callback = function(v) RoleESP = v end })
ESPTab:CreateToggle({ Name = "Distance ESP", CurrentValue = true, Callback = function(v) DistanceESP = v end })
ESPTab:CreateToggle({ Name = "Wanted ESP", CurrentValue = true, Callback = function(v) WantedESP = v end })
ESPTab:CreateToggle({ Name = "Charm ESP", CurrentValue = true, Callback = function(v) CharmESP = v end })
ESPTab:CreateToggle({ Name = "Box ESP", CurrentValue = true, Callback = function(v) BoxESP = v end })

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
        if setfpscap then setfpscap(60) end
    end
})

-- UI Toggle with V Key
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.V then
        Window.Enabled = not Window.Enabled
    end
end)

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Color = FOVColor
    fovCircle.Radius = FOVRadius
    fovCircle.Visible = AimbotEnabled and FOVVisible

    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(SelectedPart) then
            local part = target.Character[SelectedPart]
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
    end
end)

-- ESP Drawing (basic, her sistem tek tek detaylandırılabilir)
-- Bu kısmı dilersen ayrı fonksiyonlara bölüp optimize edebilirim
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local text = ""

                if DisplayNameESP then text = text .. player.DisplayName .. " " end
                if UsernameESP then text = text .. "(" .. player.Name .. ") " end
                if RoleESP and player.Team then text = "[" .. player.Team.Name .. "] " .. text end
                if WantedESP then text = "[Wanted] " .. text end
                if CharmESP then text = "[Charm] " .. text end
                if DistanceESP then
                    local dist = math.floor((Camera.CFrame.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                    text = text .. "[" .. dist .. "m]"
                end

                local esp = Drawing.new("Text")
                esp.Text = text
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Color = Color3.new(1, 1, 1)
                esp.Size = 16
                esp.Outline = true
                esp.Center = true
                esp.Visible = true

                task.delay(0.1, function() esp:Remove() end)
            end
        end
    end
end)
