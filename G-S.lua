local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ModMenuIcon"

-- Icono "G" flotante y arrastrable
local iconButton = Instance.new("TextButton", gui)
iconButton.Size = UDim2.new(0, 60, 0, 60)
iconButton.Position = UDim2.new(0, 20, 0, 100)
iconButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
iconButton.Text = "G"
iconButton.TextScaled = true
iconButton.TextColor3 = Color3.new(1, 1, 1)
iconButton.Font = Enum.Font.GothamBold
iconButton.BorderSizePixel = 0
iconButton.ClipsDescendants = true
local corner = Instance.new("UICorner", iconButton)
corner.CornerRadius = UDim.new(1, 0)

-- Dragging variables
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	iconButton.Position = UDim2.new(
		0,
		math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - iconButton.AbsoluteSize.X),
		0,
		math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - iconButton.AbsoluteSize.Y)
	)
end

iconButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = iconButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

iconButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Menú desplegable con scroll
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 200, 0, 0)
menuFrame.Position = UDim2.new(0, 20, 0, 160)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.BorderSizePixel = 0
menuFrame.ClipsDescendants = true
local frameCorner = Instance.new("UICorner", menuFrame)
frameCorner.CornerRadius = UDim.new(0, 10)

local scrollFrame = Instance.new("ScrollingFrame", menuFrame)
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 100)
scrollFrame.ScrollBarThickness = 6

local uiListLayout = Instance.new("UIListLayout", scrollFrame)
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Noclip switch button
local noclipEnabled = false
local noclipButton = Instance.new("TextButton", scrollFrame)
noclipButton.Size = UDim2.new(1, -10, 0, 40)
noclipButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
noclipButton.TextColor3 = Color3.new(1, 1, 1)
noclipButton.Font = Enum.Font.GothamBold
noclipButton.TextSize = 18
noclipButton.Text = "Noclip: OFF"
noclipButton.LayoutOrder = 1

-- Función para activar/desactivar noclip
local function setNoclip(enabled)
	local character = LocalPlayer.Character
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not enabled
			end
		end
	end
end

noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	if noclipEnabled then
		noclipButton.Text = "Noclip: ON"
	else
		noclipButton.Text = "Noclip: OFF"
	end
	setNoclip(noclipEnabled)
end)

-- Ajustar CanvasSize para que el scroll funcione bien
local function updateCanvas()
	local contentSize = uiListLayout.AbsoluteContentSize
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
end

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

local menuOpen = false

local function toggleMenu()
	if menuOpen then
		TweenService:Create(menuFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 0)}):Play()
		menuOpen = false
	else
		local contentSize = uiListLayout.AbsoluteContentSize
		local height = math.clamp(contentSize.Y + 20, 100, 300) -- limite de tamaño visible
		TweenService:Create(menuFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, height)}):Play()
		menuOpen = true
	end
end

iconButton.MouseButton1Click:Connect(toggleMenu)

menuFrame.Size = UDim2.new(0, 200, 0, 0)
menuOpen = false

-- Limpieza: en caso de salir con noclip activado
LocalPlayer.CharacterAdded:Connect(function()
	if noclipEnabled then
		setNoclip(true)
	end
end)
