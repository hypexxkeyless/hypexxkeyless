--// Rayfield UI Yükle
local success, Rayfield = pcall(loadstring, game:HttpGet("https://sirius.menu/rayfield"))
if not success then
    warn("[Hypexx] Rayfield could not be loaded.")
    return
end

Rayfield = Rayfield()

--// Servisler ve Oyuncu
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Aimbot Ayarları
local AimbotEnabled = false
local TeamCheck = true
local SelectedTeam = "All"
local SelectedPart = "Head"
local VisibleCheck = true
local Prediction = 5
local AimbotDistance = 500

--// FOV Ayarları
local ShowFOV = true
local FOVRadius = 100
local FOVColor = Color3.fromRGB(255, 255, 255)

--// FOV Çizimi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Thickness = 2
FOVCircle.Transparency = 1
FOVCircle.Color = FOVColor
FOVCircle.Visible = ShowFOV

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = FOVRadius
    FOVCircle.Color = FOVColor
    FOVCircle.Visible = ShowFOV
end)

--// Görünürlük Kontrolü
local function IsVisible(targetPart)
    if not VisibleCheck then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true

    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 1000
    local result = workspace:Raycast(origin, direction, rayParams)

    return result and result.Instance:IsDescendantOf(targetPart.Parent)
end

--// En Yakın Oyuncu
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimbotDistance

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 25 then
                local part = player.Character:FindFirstChild(SelectedPart)
                if part then
                    if not (TeamCheck and player.Team == LocalPlayer.Team) then
                        if SelectedTeam == "All" or player.Team.Name == SelectedTeam then
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
            end
        end
    end

    return closestPlayer
end

--// Aimbot Aktifse Çalıştır
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end

    local target = GetClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild(SelectedPart) then
        local part = target.Character[SelectedPart]
        local predictedPosition = part.Position + (part.Velocity * (Prediction / 10))
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
    end
end)

--// Rayfield UI Oluştur
local Window = Rayfield:CreateWindow({
    Name = "Hypexx Keyless Menu",
    LoadingTitle = "Hypexx Keyless Menu loading...",
    LoadingSubtitle = "Powered by Hypexx",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

-- Aimbot Seçenekleri
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

AimbotTab:CreateToggle({
    Name = "Team Check (Ignore Same Team)",
    CurrentValue = true,
    Callback = function(Value)
        TeamCheck = Value
    end
})

AimbotTab:CreateDropdown({
    Name = "Target Team",
    Options = {"All", "Police", "Criminals", "Citizens", "Fire Department"},
    CurrentOption = "All",
    Callback = function(Value)
        SelectedTeam = Value
    end
})

AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart"},
    CurrentOption = "Head",
    Callback = function(Value)
        SelectedPart = Value
    end
})

AimbotTab:CreateToggle({
    Name = "Visible Check (Wall Check)",
    CurrentValue = true,
    Callback = function(Value)
        VisibleCheck = Value
    end
})

AimbotTab:CreateSlider({
    Name = "Prediction Accuracy",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(Value)
        Prediction = Value
    end
})

AimbotTab:CreateSlider({
    Name = "Max Aimbot Distance",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 500,
    Callback = function(Value)
        AimbotDistance = Value
    end
})

AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Callback = function(Value)
        ShowFOV = Value
        FOVCircle.Visible = ShowFOV
    end
})

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {10, 300},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(Value)
        FOVRadius = Value
    end
})

AimbotTab:CreateColorPicker({
    Name = "FOV Circle Color",
    Color = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        FOVColor = Value
    end
})
