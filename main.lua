-- Hypexx Keyless Menu - Rayfield UI
local Rayfield = loadstring(game:HttpGet("(loadstring, game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Hypexx-Keyless Menu",
	LoadingTitle = "Hypexx Loader",
	LoadingSubtitle = "Free & Clean UI",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "Hypexx", -- Config klasörü
		FileName = "HypexxKeyless"
	},
	Discord = {
		Enabled = false
	},
	KeySystem = false,
})

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local noclip = false
local noclipConn
local walkspeedBoost = 0

-- 🌟 Home Tab
local HomeTab = Window:CreateTab("Home", 4483345998)
HomeTab:CreateParagraph({Title = "© 2025 Hypexx Scripts", Content = ""})

HomeTab:CreateButton({
	Name = "Copy Discord",
	Callback = function()
		setclipboard("https://discord.gg/yourlink")
		Rayfield:Notify({Title = "Discord", Content = "Link Copied", Duration = 5})
	end
})

HomeTab:CreateButton({
	Name = "Copy YouTube",
	Callback = function()
		setclipboard("https://youtube.com/@yourchannel")
		Rayfield:Notify({Title = "YouTube", Content = "Link Copied", Duration = 5})
	end
})

-- 🔧 Player Settings
local PlayerTab = Window:CreateTab("Player Settings", 4483345998)

PlayerTab:CreateButton({
	Name = "Reset Character",
	Callback = function()
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = 0 end
	end
})

-- Noclip Toggle
PlayerTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Callback = function(Value)
		noclip = Value
		if noclip then
			noclipConn = RunService.Stepped:Connect(function()
				for _, part in pairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end)
		else
			if noclipConn then noclipConn:Disconnect() end
		end
	end
})

-- Walkspeed Boost
PlayerTab:CreateSlider({
	Name = "Walkspeed Boost",
	Range = {0, 80},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 0,
	Callback = function(Value)
		walkspeedBoost = Value / 30
	end
})

RunService.Heartbeat:Connect(function()
	local char = player.Character
	if char and walkspeedBoost > 0 then
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if hum and root and hum.MoveDirection.Magnitude > 0 then
			root.CFrame = root.CFrame + root.CFrame.LookVector * walkspeedBoost
		end
	end
end)

-- Anti-Death
PlayerTab:CreateToggle({
	Name = "Anti-Death (Freeze Health)",
	CurrentValue = false,
	Callback = function(Value)
		if Value then
			getfenv().antideath = player.Character:FindFirstChildOfClass("Humanoid").HealthChanged:Connect(function()
				player.Character:FindFirstChildOfClass("Humanoid").Health = 100
			end)
		else
			if getfenv().antideath then
				getfenv().antideath:Disconnect()
				getfenv().antideath = nil
			end
		end
	end
})

-- Anti-Fall
PlayerTab:CreateToggle({
	Name = "Anti-Fall",
	CurrentValue = false,
	Callback = function(Value)
		if Value then
			getfenv().nofall = RunService.RenderStepped:Connect(function()
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if root and root.Velocity.Y < -50 then
					root.Velocity = Vector3.zero
				end
			end)
		else
			if getfenv().nofall then
				getfenv().nofall:Disconnect()
				getfenv().nofall = nil
			end
		end
	end
})

-- Zoom
PlayerTab:CreateSlider({
	Name = "Camera Max Zoom",
	Range = {20, 1000},
	Increment = 10,
	Suffix = "Zoom",
	CurrentValue = 20,
	Callback = function(Value)
		player.CameraMaxZoomDistance = Value
	end
})

-- Infinite Stamina (experimental)
PlayerTab:CreateButton({
	Name = "Infinite Stamina",
	Callback = function()
		for _, f in pairs(getgc(true)) do
			if typeof(f) == "function" and debug.getinfo(f).name == "setStamina" then
				hookfunction(f, function(self, stamina)
					return self, math.huge
				end)
				break
			end
		end
	end
})
