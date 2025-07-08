local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Keyless Free Menu",
    LoadingTitle = "Keyless Free Menu Loading...",
    LoadingSubtitle = "Hypexx Script",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Ayarlar
local AimbotEnabled = false
local FOVEnabled = false
local TeamCheckEnabled = true
local VisibleCheckEnabled = true

local AimPart = "HumanoidRootPart"
local PredictionLevel = 5
local MaxDistance = 300

-- ESP ayarları
local ESPEnabled = false
local ESPTeamEnabled = false
local ESPDistanceEnabled = false
local ESPBoxEnabled = false
local ESPDisplayNameEnabled = false
local ESPUsernameEnabled = false

local TeamColors = {
    ["Prison"] = Color3.fromRGB(30,30,30),       -- Hapistekiler siyah
    ["Polizei"] = Color3.fromRGB(0,150,255),     -- Polisler mavi
    ["Criminal"] = Color3.fromRGB(255,0,0),      -- Suçlular kırmızı
    ["Fire"] = Color3.fromRGB(255,120,0),        -- İtfaiye turuncu
    ["BusDriver"] = Color3.fromRGB(0,255,0),     -- Otobüs yeşil (isteğe göre)
    ["TruckDriver"] = Color3.fromRGB(0,255,0),   -- Tırcılar yeşil (aynı yeşil)
    ["Citizen"] = Color3.fromRGB(255,255,255),   -- Normal beyaz
}

-- Yazı tipi için custom font ekleyebilirsen ekle, yoksa default bırakıyoruz
local HypexxFont = Enum.Font.GothamBold -- Rayfield default içinde yoksa değiştirilebilir

-- FOV ayarları
local FOVRadius = 100
local FOVColor = Color3.fromRGB(0, 150, 255)

-- FOV Çizimi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = FOVColor
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)

-- Aimbot Fonksiyonu
local function IsVisible(target)
    if not VisibleCheckEnabled then return true end
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit * (target.Position - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, target.Parent})
    if hit and (pos - target.Position).Magnitude > 1 then
        return false
    end
    return true
end

local function GetClosestTarget()
    local bestTarget = nil
    local bestDist = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 25 then -- Sağlık kontrolü
                if TeamCheckEnabled then
                    local myTeam = LocalPlayer.Team and LocalPlayer.Team.Name or ""
                    local targetTeam = player.Team and player.Team.Name or ""
                    if myTeam == targetTeam then
                        goto continue
                    end
                end

                if humanoid.Health <= 0 then goto continue end -- Ölü kontrolü

                local pos = player.Character[AimPart].Position
                if not IsVisible(player.Character[AimPart].Position) then goto continue end

                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    local dist2d = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    local dist3d = (LocalPlayer.Character.HumanoidRootPart.Position - pos).Magnitude
                    if dist2d < FOVRadius and dist3d <= MaxDistance then
                        if dist2d < bestDist then
                            bestDist = dist2d
                            bestTarget = player
                        end
                    end
                end
            end
        end
        ::continue::
    end
    return bestTarget
end

-- Aimbot aktifken her frame
RunService.RenderStepped:Connect(function()
    -- FOV pozisyonu güncellemesi (sabit ortada)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = FOVEnabled

    if AimbotEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local part = target.Character[AimPart]
            local predictPos = part.Position + part.Velocity * (0.03 * PredictionLevel)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictPos)
        end
    end
end)

-- ESP Yönetimi
local ESPFolder = Instance.new("Folder", workspace)
ESPFolder.Name = "HypexxESP"

local function RemoveESP()
    for _, v in pairs(ESPFolder:GetChildren()) do
        v:Destroy()
    end
end

local function CreateESPForPlayer(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    if ESPFolder:FindFirstChild(player.Name) then return end

    local espBox = Drawing.new("Square")
    espBox.Visible = false
    espBox.Color = Color3.new(1,1,1)
    espBox.Thickness = 2
    espBox.Transparency = 1
    espBox.Filled = false

    local espText = Drawing.new("Text")
    espText.Visible = false
    espText.Color = Color3.new(1,1,1)
    espText.Size = 16
    espText.Center = true
    espText.Outline = true
    espText.Font = 2 -- Custom font yoksa 2 (UI)

    local espDistanceText = Drawing.new("Text")
    espDistanceText.Visible = false
    espDistanceText.Color = Color3.new(1,1,1)
    espDistanceText.Size = 14
    espDistanceText.Center = true
    espDistanceText.Outline = true
    espDistanceText.Font = 2

    ESPFolder.ChildAdded:Connect(function(child)
        if child.Name == player.Name then
            -- eklendiğinde gerekli güncellemeleri yapabiliriz
        end
    end)

    -- Güncelleme fonksiyonu
    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then
            espBox.Visible = false
            espText.Visible = false
            espDistanceText.Visible = false
            return
        end

        if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            local headPos, onScreenHead = Camera:WorldToViewportPoint(player.Character.Head.Position)
            local rootPos, onScreenRoot = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreenHead and onScreenRoot then
                -- Box çizimi
                if ESPBoxEnabled then
                    local size = math.abs(headPos.Y - rootPos.Y)
                    espBox.Size = Vector2.new(size * 0.6, size)
                    espBox.Position = Vector2.new(headPos.X - espBox.Size.X / 2, headPos.Y - espBox.Size.Y / 2)
                    espBox.Color = TeamColors[player.Team and player.Team.Name or "Citizen"] or Color3.new(1,1,1)
                    espBox.Visible = true
                else
                    espBox.Visible = false
                end

                -- Username ve Display Name gösterimi
                if ESPDisplayNameEnabled or ESPUsernameEnabled or ESPTeamEnabled or ESPDistanceEnabled then
                    local texts = {}

                    if ESPDisplayNameEnabled then
                        table.insert(texts, player.DisplayName)
                    end
                    if ESPUsernameEnabled then
                        table.insert(texts, "User: "..player.Name)
                    end
                    if ESPTeamEnabled then
                        local teamName = player.Team and player.Team.Name or "Citizen"
                        table.insert(texts, "Team: "..teamName)
                    end
                    if ESPDistanceEnabled then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        table.insert(texts, string.format("Distance: %.0fm", dist))
                    end

                    local fullText = table.concat(texts, " | ")
                    espText.Text = fullText
                    espText.Size = 16
                    espText.Position = Vector2.new(headPos.X, headPos.Y - 20)
                    espText.Color = TeamColors[player.Team and player.Team.Name or "Citizen"] or Color3.new(1,1,1)
                    espText.Visible = true
                else
                    espText.Visible = false
