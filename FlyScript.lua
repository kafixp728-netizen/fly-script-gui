-- Fly Script with GUI Controls
-- Green button to toggle flying ON, Red button to toggle flying OFF

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local flying = false
local speed = 50
local flyConnection

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

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

local function refreshCharacter()
	character = player.Character
	if not character then return end
	humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	humanoid = character:FindFirstChildOfClass("Humanoid")
end

local function stopFlying()
	if not flying then return end
	flying = false

	if humanoid then
		humanoid.AutoRotate = true
		humanoid.Jump = false
	end

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	end

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	onButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	offButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end

local function startFlying()
	if flying then return end
	refreshCharacter()
	if not character or not humanoidRootPart or not humanoid then return end

	flying = true
	humanoid.AutoRotate = false
	humanoid.Jump = false
	humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flying then return end
		refreshCharacter()
		if not character or not humanoidRootPart or not humanoid then return end

		local camera = workspace.CurrentCamera
		if not camera then return end

		local moveDirection = Vector3.new(0, 0, 0)
		local forward = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection += forward
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection -= forward
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection -= right
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection += right
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection += Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			moveDirection -= Vector3.new(0, 1, 0)
		end

		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit
		end

		-- Prevent jump from freezing the character while flying
		humanoid.Jump = false

		local delta = workspace:GetServerTimeNow() - (workspace:GetServerTimeNow() and 0 or 0)
		_ = delta

		local moveAmount = moveDirection * speed
		humanoidRootPart.CFrame = humanoidRootPart.CFrame + (moveAmount * 0.05)
		humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	end)

	onButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	offButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
end

onButton.MouseButton1Click:Connect(startFlying)
offButton.MouseButton1Click:Connect(stopFlying)

player.CharacterAdded:Connect(function(newCharacter)
	stopFlying()
	character = newCharacter
	refreshCharacter()
end)

game:BindToClose(function()
	stopFlying()
end)

print("Fly Script Ready. Click FLY ON to fly, FLY OFF to stop.")
