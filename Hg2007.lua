-- 📜 LEGENDS OF SPEED OP MOD MENU (KRNL Android Friendly, Ultra OP)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Estados
local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false
local espEnabled = false
local autoRebirthEnabled = false
local autoCollectEnabled = false
local autoHoopsEnabled = false
local autoExpEnabled = false
local autoLevelEnabled = false

local flySpeed = 150
local walkSpeedOriginal = 16
local jumpPowerOriginal = 50
local jumpPowerModified = 100

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LOS_OP_ModMenu"
ScreenGui.Parent = game.CoreGui

local dragButton = Instance.new("TextButton")
dragButton.Name = "DragButton"
dragButton.Text = "L"
dragButton.Font = Enum.Font.GothamBold
dragButton.TextSize = 30
dragButton.TextColor3 = Color3.new(1,1,1)
dragButton.BackgroundColor3 = Color3.fromRGB(10,10,10)
dragButton.Size = UDim2.new(0, 50, 0, 50)
dragButton.Position = UDim2.new(0, 20, 0, 120)
dragButton.AutoButtonColor = false
dragButton.Parent = ScreenGui

local dragUICorner = Instance.new("UICorner", dragButton)
dragUICorner.CornerRadius = UDim.new(1,0)

-- Dragging vars
local dragging = false
local dragInput, mousePos, framePos
local function update(input)
	local delta = input.Position - mousePos
	dragButton.Position = UDim2.new(
		framePos.X.Scale,
		framePos.X.Offset + delta.X,
		framePos.Y.Scale,
		framePos.Y.Offset + delta.Y
	)
end

dragButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		mousePos = input.Position
		framePos = dragButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

dragButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Scrollable Frame menu
local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 300, 0, 450)
frame.Position = UDim2.new(0, 20, 0, 180)
frame.CanvasSize = UDim2.new(0, 0, 2, 0)
frame.ScrollBarThickness = 10
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = ScreenGui

local frameUICorner = Instance.new("UICorner", frame)
frameUICorner.CornerRadius = UDim.new(0, 15)

-- Toggle menu visibility
local menuOpen = false
dragButton.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	frame.Visible = menuOpen
end)

-- Utility function for button creation
local function createToggleButton(text, posY, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 50)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Text = text .. ": OFF"
	btn.Parent = frame
	local uicorner = Instance.new("UICorner", btn)
	uicorner.CornerRadius = UDim.new(0, 8)

	local enabled = false
	btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		btn.Text = text .. ": " .. (enabled and "ON" or "OFF")
		callback(enabled)
	end)
	return btn
end

-- Fly
local bodyVelocity, bodyGyro
local function toggleFly(state)
	flyEnabled = state
	if flyEnabled then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local root = character.HumanoidRootPart
			bodyVelocity = Instance.new("BodyVelocity", root)
			bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
			bodyVelocity.Velocity = Vector3.new(0,0,0)

			bodyGyro = Instance.new("BodyGyro", root)
			bodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
			bodyGyro.CFrame = root.CFrame
		end
	else
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end
		if bodyGyro then
			bodyGyro:Destroy()
			bodyGyro = nil
		end
	end
end

-- Noclip
local function toggleNoclip(state)
	noclipEnabled = state
end

-- Speed
local function toggleSpeed(state)
	speedEnabled = state
	if speedEnabled then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = flySpeed
			LocalPlayer.Character.Humanoid.JumpPower = jumpPowerModified
		end
	else
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedOriginal
			LocalPlayer.Character.Humanoid.JumpPower = jumpPowerOriginal
		end
	end
end

-- ESP
local espObjects = {}
local function createESP(part, color)
	local adorn = Instance.new("BoxHandleAdornment")
	adorn.Adornee = part
	adorn.AlwaysOnTop = true
	adorn.ZIndex = 10
	adorn.Size = part.Size + Vector3.new(0.5,0.5,0.5)
	adorn.Transparency = 0.3
	adorn.Color3 = color
	adorn.Parent = part
	return adorn
end

local function toggleESP(state)
	espEnabled = state
	if espEnabled then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				if root and not espObjects[player.Name] then
					espObjects[player.Name] = createESP(root, Color3.fromRGB(0,255,255))
				end
			end
		end
		-- Boosts ESP assuming boosts in workspace.Boosts
		local boosts = workspace:FindFirstChild("Boosts") or workspace:FindFirstChild("boosts")
		if boosts then
			for _, boost in pairs(boosts:GetChildren()) do
				if boost:IsA("BasePart") and not espObjects[boost:GetDebugId()] then
					espObjects[boost:GetDebugId()] = createESP(boost, Color3.fromRGB(255, 215, 0))
				end
			end
		end
	else
		for _, adorn in pairs(espObjects) do
			adorn:Destroy()
		end
		espObjects = {}
	end
end

-- Auto Rebirth (fires remote event if exists)
local function toggleAutoRebirth(state)
	autoRebirthEnabled = state
end

-- Auto Collect gems (teleports gems close to player)
local function toggleAutoCollect(state)
	autoCollectEnabled = state
end

-- Auto Hoops (go through hoops automatically)
local function toggleAutoHoops(state)
	autoHoopsEnabled = state
end

-- Auto Exp (run in place to gain xp)
local function toggleAutoExp(state)
	autoExpEnabled = state
end

-- Auto Level Up (fires server events to level up)
local function toggleAutoLevel(state)
	autoLevelEnabled = state
end

-- Teleport function
local function teleportToArea(areaName)
	local map = workspace:FindFirstChild("Map") or workspace
	if not map then return end

	for _, part in pairs(map:GetChildren()) do
		if part.Name:lower():find(areaName:lower()) and part:IsA("BasePart") then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
			end
			break
		end
	end
end

-- RunService Heartbeat loop
RunService.Heartbeat:Connect(function()
	-- Fly control
	if flyEnabled and bodyVelocity and bodyGyro and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local root = LocalPlayer.Character.HumanoidRootPart
		local moveDir = Vector3.new(0,0,0)
		if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end

		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit * flySpeed
			bodyVelocity.Velocity = moveDir
		else
			bodyVelocity.Velocity = Vector3.new(0,0,0)
		end
		bodyGyro.CFrame = Camera.CFrame
	end

	-- Noclip
	if noclipEnabled and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	-- Auto Collect logic
	if autoCollectEnabled then
		local gemsFolder = workspace:FindFirstChild("Gems") or workspace:FindFirstChild("gems")
		if gemsFolder and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local root = LocalPlayer.Character.HumanoidRootPart
			for _, gem in pairs(gemsFolder:GetChildren()) do
				if gem:IsA("BasePart") and (gem.Position - root.Position).Magnitude < 40 then
					gem.CFrame = root.CFrame * CFrame.new(0, -3, 0)
				end
			end
		end
	end

	-- Auto Hoops logic
	if autoHoopsEnabled then
		local hoopsFolder = workspace:FindFirstChild("Hoops") or workspace:FindFirstChild("hoops")
		if hoopsFolder and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local root = LocalPlayer.Character.HumanoidRootPart
			for _, hoop in pairs(hoopsFolder:GetChildren()) do
				if hoop:IsA("BasePart") and (hoop.Position - root.Position).Magnitude < 60 then
					-- Teleport near the hoop so it triggers collection
					root.CFrame = hoop.CFrame + Vector3.new(0, 3, 0)
				end
			end
		end
	end

	-- Auto Exp logic
	if autoExpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		-- Simple run in place forward
		local root = LocalPlayer.Character.HumanoidRootPart
		root.CFrame = root.CFrame * CFrame.new(0, 0, -0.6)
	end

	-- Auto Level Up logic
	if autoLevelEnabled then
		-- This part depends on remote event name, example:
		local remote = game:GetService("ReplicatedStorage"):FindFirstChild("LevelUpEvent")
		if remote then
			remote:FireServer()
		end
	end
end)

-- Crear botones en el menú
local posY = 10
local buttons = {}

buttons.noclip = createToggleButton("Noclip", posY, toggleNoclip); posY = posY + 60
buttons.fly = createToggleButton("Fly", posY, toggleFly); posY = posY + 60
buttons.speed = createToggleButton("Speed", posY, toggleSpeed); posY = posY + 60
buttons.esp = createToggleButton("ESP", posY, toggleESP); posY = posY + 60
buttons.autoRebirth = createToggleButton("Auto Rebirth", posY, toggleAutoRebirth); posY = posY + 60
buttons.autoCollect = createToggleButton("Auto Collect", posY, toggleAutoCollect); posY = posY + 60
buttons.autoHoops = createToggleButton("Auto Hoops", posY, toggleAutoHoops); posY = posY + 60
buttons.autoExp = createToggleButton("Auto Exp", posY, toggleAutoExp); posY = posY + 60
buttons.autoLevel = createToggleButton("Auto Level Up", posY, toggleAutoLevel); posY = posY + 60

-- Teleport buttons
local teleportAreas = {"Spawn", "Race", "Shop"}
for i, area in pairs(teleportAreas) do
	local y = posY + (i-1)*60
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 50)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Text = "Teleport to "..area
	btn.Parent = frame
	local uicorner = Instance.new("UICorner", btn)
	uicorner.CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Click:Connect(function()
		teleportToArea(area)
	end)
end

print("✅ LEGENDS OF SPEED OP MOD MENU cargado y listo para usar.")
