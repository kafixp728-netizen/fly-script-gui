-- Fly Script with GUI Controls
-- Green button to toggle flying ON, Red button to toggle flying OFF

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Flight variables
local flying = false
local speed = 50
local bodyVelocity
local bodyGyro

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ON Button (Green)
local onButton = Instance.new("TextButton")
onButton.Name = "OnButton"
onButton.Size = UDim2.new(0, 100, 0, 50)
onButton.Position = UDim2.new(0, 10, 0, 10)
onButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
onButton.TextColor3 = Color3.fromRGB(0, 0, 0)
onButton.TextScaled = true
onButton.Text = "FLY ON"
onButton.Font = Enum.Font.GothamBold
onButton.Parent = screenGui

-- OFF Button (Red)
local offButton = Instance.new("TextButton")
offButton.Name = "OffButton"
offButton.Size = UDim2.new(0, 100, 0, 50)
offButton.Position = UDim2.new(0, 120, 0, 10)
offButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
offButton.TextColor3 = Color3.fromRGB(255, 255, 255)
offButton.TextScaled = true
offButton.Text = "FLY OFF"
offButton.Font = Enum.Font.GothamBold
offButton.Parent = screenGui

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(0, 150, 0, 30)
speedLabel.Position = UDim2.new(0, 10, 0, 70)
speedLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Text = "Speed: " .. speed
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = screenGui

-- Function to start flying
local function startFlying()
	if flying then return end
	flying = true
	
	character = player.Character
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	-- Create BodyVelocity
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
	bodyVelocity.Parent = humanoidRootPart
	
	-- Create BodyGyro
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
	bodyGyro.P = 10000
	bodyGyro.Parent = humanoidRootPart
	
	-- Flying loop
	local flyConnection
	flyConnection = RunService.RenderStepped:Connect(function()
		if not flying or not character.Parent then
			flyConnection:Disconnect()
			return
		end
		
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end
		
		-- Get camera direction
		local camera = workspace.CurrentCamera
		local moveDirection = Vector3.new(0, 0, 0)
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + (camera.CFrame.LookVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - (camera.CFrame.LookVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - (camera.CFrame.RightVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + (camera.CFrame.RightVector)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			moveDirection = moveDirection - Vector3.new(0, 1, 0)
		end
		
		-- Normalize and apply speed
		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit
		end
		
		bodyVelocity.Velocity = moveDirection * speed
		bodyGyro.CFrame = camera.CFrame
	end)
	
	onButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	offButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
end

-- Function to stop flying
local function stopFlying()
	if not flying then return end
	flying = false
	
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
	
	onButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	offButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end

-- Button connections
onButton.MouseButton1Click:Connect(startFlying)
offButton.MouseButton1Click:Connect(stopFlying)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	stopFlying()
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Cleanup on script removal
game:BindToClose(function()
	stopFlying()
end)

print("Fly Script Loaded! Click FLY ON to start flying, FLY OFF to stop.")
