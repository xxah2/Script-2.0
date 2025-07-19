-- 📜 STEAL A BRAINROT MOD MENU (KRNL Android Friendly)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Estados
local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false
local espEnabled = false
local autoStealEnabled = false

local flySpeed = 50
local walkSpeedOriginal = 16

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealBrainrotModMenu"
ScreenGui.Parent = game.CoreGui

-- Botón flotante "S" (redondo, arrastrable)
local dragButton = Instance.new("TextButton")
dragButton.Name = "DragButton"
dragButton.Text = "S"
dragButton.Font = Enum.Font.GothamBold
dragButton.TextSize = 30
dragButton.TextColor3 = Color3.new(1,1,1)
dragButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
dragButton.Size = UDim2.new(0, 50, 0, 50)
dragButton.Position = UDim2.new(0, 20, 0, 120)
dragButton.AutoButtonColor = false
dragButton.Parent = ScreenGui

local dragUICorner = Instance.new("UICorner", dragButton)
dragUICorner.CornerRadius = UDim.new(1,0)

-- Variables para drag sin errores
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

-- Frame scrollable menú
local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 260, 0, 350)
frame.Position = UDim2.new(0, 20, 0, 180)
frame.CanvasSize = UDim2.new(0, 0, 0, 800)
frame.ScrollBarThickness = 8
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = ScreenGui

local frameUICorner = Instance.new("UICorner", frame)
frameUICorner.CornerRadius = UDim.new(0, 10)

-- Toggle menú con botón "S"
local menuOpen = false
dragButton.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	frame.Visible = menuOpen
end)

-- Funciones básicas

-- Noclip
local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
end

-- Fly Handler
local bodyVelocity, bodyGyro
local function toggleFly()
	flyEnabled = not flyEnabled
	if flyEnabled then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local root = character.HumanoidRootPart
			bodyVelocity = Instance.new("BodyVelocity", root)
			bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
			bodyVelocity.Velocity = Vector3.new(0,0,0)

			bodyGyro = Instance.new("BodyGyro", root)
			bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
			bodyGyro.CFrame = root.CFrame
		end
		flyBtn.Text = "Fly: ON"
	else
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end
		if bodyGyro then
			bodyGyro:Destroy()
			bodyGyro = nil
		end
		flyBtn.Text = "Fly: OFF"
	end
end

-- Speed toggle
local function toggleSpeed()
	speedEnabled = not speedEnabled
	if speedEnabled then
		LocalPlayer.Character.Humanoid.WalkSpeed = flySpeed
		speedBtn.Text = "Speed: ON"
	else
		LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedOriginal
		speedBtn.Text = "Speed: OFF"
	end
end

-- ESP para bases y jugadores (simple box + name)
local espObjects = {}

local function createESP(part, color)
	local adorn = Instance.new("BoxHandleAdornment")
	adorn.Adornee = part
	adorn.AlwaysOnTop = true
	adorn.ZIndex = 10
	adorn.Size = part.Size + Vector3.new(0.1,0.1,0.1)
	adorn.Transparency = 0.5
	adorn.Color3 = color
	adorn.Parent = part
	return adorn
end

local function toggleESP()
	espEnabled = not espEnabled
	if espEnabled then
		-- ESP jugadores
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if rootPart and not espObjects[player.Name] then
					espObjects[player.Name] = createESP(rootPart, Color3.fromRGB(0, 255, 0))
				end
			end
		end

		-- ESP bases (buscando partes específicas, puede variar)
		for _, base in pairs(workspace:GetChildren()) do
			if base.Name:lower():find("base") then
				for _, part in pairs(base:GetChildren()) do
					if part:IsA("BasePart") and not espObjects[part:GetDebugId()] then
						espObjects[part:GetDebugId()] = createESP(part, Color3.fromRGB(255, 0, 0))
					end
				end
			end
		end
		espBtn.Text = "ESP: ON"
	else
		for _, adorn in pairs(espObjects) do
			adorn:Destroy()
		end
		espObjects = {}
		espBtn.Text = "ESP: OFF"
	end
end

-- Auto Steal: automático al detectar base abierta cerca
local function toggleAutoSteal()
	autoStealEnabled = not autoStealEnabled
	if autoStealEnabled then
		autoStealBtn.Text = "Auto Steal: ON"
	else
		autoStealBtn.Text = "Auto Steal: OFF"
	end
end

RunService.Heartbeat:Connect(function()
	if flyEnabled and bodyVelocity and bodyGyro and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local root = LocalPlayer.Character.HumanoidRootPart
		local moveDirection = Vector3.new(0,0,0)
		if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + (Camera.CFrame.LookVector) end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - (Camera.CFrame.LookVector) end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - (Camera.CFrame.RightVector) end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + (Camera.CFrame.RightVector) end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0,1,0) end

		moveDirection = moveDirection.Unit * flySpeed
		if moveDirection.Magnitude < 1 then
			bodyVelocity.Velocity = Vector3.new(0,0,0)
		else
			bodyVelocity.Velocity = Vector3.new(moveDirection.X, moveDirection.Y, moveDirection.Z)
		end
		bodyGyro.CFrame = Camera.CFrame
	end

	if noclipEnabled and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	if autoStealEnabled then
		-- Buscamos base abierta cerca para robar automáticamente
		for _, base in pairs(workspace:GetChildren()) do
			if base.Name:lower():find("base") and base:FindFirstChild("Locked") and base.Locked.Value == false then
				-- Teletransportarse a la base para robar
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = base.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
					-- Si hay evento remoto para robar, lo activamos (esto depende del juego)
				end
			end
		end
	end
end)

-- Botones UI en el menú scrollable

local noclipBtn = Instance.new("TextButton")
noclipBtn.Size = UDim2.new(1, -20, 0, 50)
noclipBtn.Position = UDim2.new(0, 10, 0, 10)
noclipBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
noclipBtn.TextColor3 = Color3.new(1,1,1)
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextScaled = true
noclipBtn.Text = "Noclip: OFF"
noclipBtn.Parent = frame
local noclipUICorner = Instance.new("UICorner", noclipBtn)
noclipUICorner.CornerRadius = UDim.new(0, 6)

noclipBtn.MouseButton1Click:Connect(toggleNoclip)

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(1, -20, 0, 50)
flyBtn.Position = UDim2.new(0, 10, 0, 70)
flyBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextScaled = true
flyBtn.Text = "Fly: OFF"
flyBtn.Parent = frame
local flyUICorner = Instance.new("UICorner", flyBtn)
flyUICorner.CornerRadius = UDim.new(0, 6)

flyBtn.MouseButton1Click:Connect(toggleFly)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -20, 0, 50)
speedBtn.Position = UDim2.new(0, 10, 0, 130)
speedBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBtn.TextColor3 = Color3.new(1,1,1)
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextScaled = true
speedBtn.Text = "Speed: OFF"
speedBtn.Parent = frame
local speedUICorner = Instance.new("UICorner", speedBtn)
speedUICorner.CornerRadius = UDim.new(0, 6)

speedBtn.MouseButton1Click:Connect(toggleSpeed)

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, -20, 0, 50)
espBtn.Position = UDim2.new(0, 10, 0, 190)
espBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
espBtn.TextColor3 = Color3.new(1,1,1)
espBtn.Font = Enum.Font.GothamBold
espBtn.TextScaled = true
espBtn.Text = "ESP: OFF"
espBtn.Parent = frame
local espUICorner = Instance.new("UICorner", espBtn)
espUICorner.CornerRadius = UDim.new(0, 6)

espBtn.MouseButton1Click:Connect(toggleESP)

local autoStealBtn = Instance.new("TextButton")
autoStealBtn.Size = UDim2.new(1, -20, 0, 50)
autoStealBtn.Position = UDim2.new(0, 10, 0, 250)
autoStealBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
autoStealBtn.TextColor3 = Color3.new(1,1,1)
autoStealBtn.Font = Enum.Font.GothamBold
autoStealBtn.TextScaled = true
autoStealBtn.Text = "Auto Steal: OFF"
autoStealBtn.Parent = frame
local autoStealUICorner = Instance.new("UICorner", autoStealBtn)
autoStealUICorner.CornerRadius = UDim.new(0, 6)

autoStealBtn.MouseButton1Click:Connect(toggleAutoSteal)

print("✅ Mod Menu Steal a Brainrot cargado correctamente.")
