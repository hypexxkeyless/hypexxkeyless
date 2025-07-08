-- // Load Rayfield UI //
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Emergency Hamburg | Keyless-Hypexx Menu",
	LoadingTitle = "Keyless-Hypexx Menu loading...",
	LoadingSubtitle = "Aimbot, ESP, Farm",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

-- // Services //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // Settings //
local AimbotEnabled = false
local ESPEnabled = false
local BoxESPEnabled = false
local TeamESPEnabled = false

local FOVRadius = 100
local MaxAimbotDistance = 300
local AimbotPart = "HumanoidRootPart"
local AimbotTeamCheck = true
local FOVColor = Color3.fromRGB(255, 0, 0)

local TeamColors = {
	["Prisoners"] = Color3.fromRGB(0, 0, 0),
	["Polizei"] = Color3.fromRGB(0, 150, 255),
	["Criminals"] = Color3.fromRGB(255, 0, 0),
	["Fire"] = Color3.fromRGB(255, 120, 0),
	["Trucker"] = Color3.fromRGB(0, 255, 0),
	["Bus"] = Color3.fromRGB(0, 255, 0),
	["Citizen"] = Color3.fromRGB(255, 255, 255)
}

-- // FOV Circle //
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Radius = FOVRadius
fovCircle.Color = FOVColor
fovCircle.Thickness = 1
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
	local mousePos = Vector2.new(Mouse.X, Mouse.Y)
	fovCircle.Position = mousePos
end)

-- // Aimbot Logic //
local function GetClosestPlayer()
	local closest = nil
	local shortest = math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimbotPart) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 25 then
			if not AimbotTeamCheck or (player.Team ~= LocalPlayer.Team) then
				local partPos, onScreen = Camera:WorldToViewportPoint(player.Character[AimbotPart].Position)
				local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(partPos.X, partPos.Y)).Magnitude
				local dist3d = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character[AimbotPart].Position).Magnitude
				if onScreen and dist < FOVRadius and dist < shortest and dist3d <= MaxAimbotDistance then
					shortest = dist
					closest = player
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if AimbotEnabled then
		local target = GetClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild(AimbotPart) then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimbotPart].Position)
		end
	end
end)

-- // ESP //
local function CreateESP(player)
	if player.Character and not player.Character:FindFirstChild("HypexxESP") and player.Character:FindFirstChild("Head") then
		local esp = Instance.new("BillboardGui", player.Character)
		esp.Name = "HypexxESP"
		esp.AlwaysOnTop = true
		esp.Size = UDim2.new(0, 200, 0, 100)
		esp.StudsOffset = Vector3.new(0, 3, 0)
		esp.Adornee = player.Character.Head

		local function createLabel(name, text, y)
			local label = Instance.new("TextLabel", esp)
			label.Name = name
			label.BackgroundTransparency = 1
			label.Size = UDim2.new(1, 0, 0, 18)
			label.Position = UDim2.new(0, 0, 0, y)
			label.Text = text
			label.TextScaled = true
			label.Font = Enum.Font.GothamBold
			label.TextStrokeTransparency = 0.5
			label.TextColor3 = TeamColors[player.Team and player.Team.Name] or Color3.new(1, 1, 1)
			return label
		end

		createLabel("Username", "User: "..player.Name, 0)
		createLabel("Display", "Display: "..player.DisplayName, 18)
		if TeamESPEnabled then
			createLabel("Team", "Team: "..(player.Team and player.Team.Name or "Unknown"), 36)
		end
		createLabel("Distance", "", 54)
	end
end

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and ESPEnabled then
			CreateESP(player)
			local esp = player.Character and player.Character:FindFirstChild("HypexxESP")
			if esp and player.Character:FindFirstChild("HumanoidRootPart") then
				local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
				local distanceLabel = esp:FindFirstChild("Distance")
				if distanceLabel then
					distanceLabel.Text = "Distance: "..dist.."m"
				end
			end
		elseif player.Character and player.Character:FindFirstChild("HypexxESP") then
			player.Character:FindFirstChild("HypexxESP"):Destroy()
		end
	end
end)

-- // Rayfield UI Controls //
local tab = Window:CreateTab("🎯 Aimbot / ESP")

tab:CreateToggle({ Name = "Enable Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end })
tab:CreateSlider({ Name = "FOV Radius", Range = {50, 500}, Increment = 10, CurrentValue = FOVRadius, Callback = function(v) FOVRadius = v; fovCircle.Radius = v end })
tab:CreateColorPicker({ Name = "FOV Color", Color = FOVColor, Callback = function(c) FOVColor = c; fovCircle.Color = c end })
tab:CreateDropdown({ Name = "Aim Part", Options = {"Head", "HumanoidRootPart"}, Callback = function(v) AimbotPart = v end })
tab:CreateToggle({ Name = "Team Check", CurrentValue = AimbotTeamCheck, Callback = function(v) AimbotTeamCheck = v end })

tab:CreateSection("ESP Settings")
tab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(v) ESPEnabled = v end })
tab:CreateToggle({ Name = "Team ESP", CurrentValue = true, Callback = function(v) TeamESPEnabled = v end })
