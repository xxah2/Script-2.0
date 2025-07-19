-- Variables principales
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Crear GUI base
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ModMenuIcon"

-- Icono "G" flotante y arrastrable
local iconButton = Instance.new("TextButton", gui)
iconButton.Name = "IconButton"
iconButton.Size = UDim2.new(0, 60, 0, 60)
iconButton.Position = UDim2.new(0, 20, 0, 100)
iconButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
iconButton.Text = "G"
iconButton.TextScaled = true
iconButton.TextColor3 = Color3.fromRGB(230, 230, 230)
iconButton.Font = Enum.Font.GothamBold
iconButton.BorderSizePixel = 0
iconButton.ClipsDescendants = true
iconButton.AutoButtonColor = true
local iconCorner = Instance.new("UICorner", iconButton)
iconCorner.CornerRadius = UDim.new(1, 0)

-- Drag variables
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

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

-- Crear menú desplegable
local menuFrame = Instance.new("Frame", gui)
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 220, 0, 0) -- cerrado al inicio
menuFrame.Position = UDim2.new(0, 20, 0, 170)
menuFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
menuFrame.BorderSizePixel = 0
menuFrame.ClipsDescendants = true
local menuCorner = Instance.new("UICorner", menuFrame)
menuCorner.CornerRadius = UDim.new(0, 12)

-- ScrollFrame para las opciones
local scrollFrame = Instance.new("ScrollingFrame", menuFrame)
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local uiListLayout = Instance.new("UIListLayout", scrollFrame)
uiListLayout.Padding = UDim.new(0, 8)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local uiPadding = Instance.new("UIPadding", scrollFrame)
uiPadding.PaddingTop = UDim.new(0, 8)
uiPadding.PaddingBottom = UDim.new(0, 8)
uiPadding.PaddingLeft = UDim.new(0, 8)
uiPadding.PaddingRight = UDim.new(0, 8)

-- Botón Noclip
local noclipEnabled = false
local noclipButton = Instance.new("TextButton", scrollFrame)
noclipButton.Name = "NoclipButton"
noclipButton.Size = UDim2.new(1, 0, 0, 45)
noclipButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
noclipButton.TextColor3 = Color3.fromRGB(240, 240, 240)
noclipButton.Font = Enum.Font.GothamBold
noclipButton.TextSize = 18
noclipButton.Text = "Noclip: OFF"
noclipButton.LayoutOrder = 1
noclipButton.AutoButtonColor = true
noclipButton.BorderSizePixel = 0
local noclipCorner = Instance.new("UICorner", noclipButton)
noclipCorner.CornerRadius = UDim.new(0, 8)

-- Función para aplicar noclip
local function applyNoclip(state)
	local character = LocalPlayer.Character
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not state
			end
		end
	end
end

-- Mantener noclip activado en bucle
RunService.Stepped:Connect(function()
	if noclipEnabled then
		applyNoclip(true)
	end
end)

-- Toggle noclip al presionar el botón
noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipButton.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
	applyNoclip(noclipEnabled)
end)

-- Ajustar canvas para scroll dinámico
local function updateCanvas()
	local sizeY = uiListLayout.AbsoluteContentSize.Y
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, sizeY + 10)
end

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- Animación abrir/cerrar menú
local menuOpen = false
local function toggleMenu()
	if menuOpen then
		TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 0)}):Play()
		menuOpen = false
	else
		local contentHeight = uiListLayout.AbsoluteContentSize.Y + 20
		local height = math.clamp(contentHeight, 100, 350)
		TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, height)}):Play()
		menuOpen = true
	end
end

iconButton.MouseButton1Click:Connect(toggleMenu)

-- Inicialmente cerrado
menuFrame.Size = UDim2.new(0, 220, 0, 0)
menuOpen = false

-- Reaplicar noclip al reaparecer personaje
LocalPlayer.CharacterAdded:Connect(function()
	if noclipEnabled then
		applyNoclip(true)
	end
end)
