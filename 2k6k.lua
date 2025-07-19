-- 📜 PRISON LIFE MOD MENU (KRNL Android Friendly)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Estados
local noclipEnabled = false
local aimbotEnabled = false

-- Crear ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuG"
ScreenGui.Parent = game.CoreGui

-- Botón flotante "G" completamente redondo
local draggableButton = Instance.new("TextButton")
draggableButton.Name = "DraggableButton"
draggableButton.Text = "G"
draggableButton.Font = Enum.Font.GothamBold
draggableButton.TextSize = 30
draggableButton.TextColor3 = Color3.new(1,1,1)
draggableButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
draggableButton.Size = UDim2.new(0, 50, 0, 50)
draggableButton.Position = UDim2.new(0, 20, 0, 120)
draggableButton.AnchorPoint = Vector2.new(0,0)
draggableButton.AutoButtonColor = false
draggableButton.Parent = ScreenGui

-- Hacerlo completamente redondo
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(1,0)
uicorner.Parent = draggableButton

-- Variables para arrastrar
local dragging = false
local dragInput, mousePos, framePos

draggableButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = draggableButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

draggableButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		draggableButton.Position = UDim2.new(
			framePos.X.Scale,
			framePos.X.Offset + delta.X,
			framePos.Y.Scale,
			framePos.Y.Offset + delta.Y
		)
	end
end)

-- Frame del menú con scroll
local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 180)
frame.CanvasSize = UDim2.new(0, 0, 0, 600)
frame.ScrollBarThickness = 8
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = ScreenGui

local uicornerFrame = Instance.new("UICorner", frame)
uicornerFrame.CornerRadius = UDim.new(0, 10)

-- Abrir/cerrar menú con el botón "G"
local menuOpen = false
draggableButton.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	frame.Visible = menuOpen
end)

-- Función noclip (loop para que siempre atraviese)
RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Función para encontrar jugador más cercano visible
local function getClosestPlayer()
	local closest = nil
	local shortestDistance = math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
				if dist < shortestDistance then
					shortestDistance = dist
					closest = player
				end
			end
		end
	end
	return closest
end

-- Auto disparo aimbot al tocar pantalla (con arma equipada)
UIS.InputBegan:Connect(function(input)
	if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
			if tool and tool:FindFirstChild("Handle") then
				tool:Activate()
			end
		end
	end
end)

-- Botón Noclip
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(1, -20, 0, 50)
noclipButton.Position = UDim2.new(0, 10, 0, 10)
noclipButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
noclipButton.TextColor3 = Color3.new(1,1,1)
noclipButton.Font = Enum.Font.GothamBold
noclipButton.TextScaled = true
noclipButton.Text = "Noclip: OFF"
noclipButton.Parent = frame
local noclipUICorner = Instance.new("UICorner", noclipButton)
noclipUICorner.CornerRadius = UDim.new(0, 6)

noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipButton.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
end)

-- Botón Aimbot
local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(1, -20, 0, 50)
aimbotButton.Position = UDim2.new(0, 10, 0, 70)
aimbotButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
aimbotButton.TextColor3 = Color3.new(1,1,1)
aimbotButton.Font = Enum.Font.GothamBold
aimbotButton.TextScaled = true
aimbotButton.Text = "Aimbot: OFF"
aimbotButton.Parent = frame
local aimbotUICorner = Instance.new("UICorner", aimbotButton)
aimbotUICorner.CornerRadius = UDim.new(0, 6)

aimbotButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	aimbotButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

print("✅ Mod Menu Prison Life cargado correctamente.")
