hhh2 

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
iconButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
iconButton.Text = "G"
iconButton.TextScaled = true
iconButton.TextColor3 = Color3.fromRGB(200, 200, 200)
iconButton.Font = Enum.Font.GothamBold
iconButton.BorderSizePixel = 0
iconButton.ClipsDescendants = true
iconButton.AutoButtonColor = true
local corner = Instance.new("UICorner", iconButton)
corner.CornerRadius = UDim.new(1, 0)

-- Variables para drag
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

-- Menú desplegable con scroll y diseño mejorado
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 0) -- empieza cerrado
menuFrame.Position = UDim2.new(0, 20, 0, 160)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.BorderSizePixel = 0
menuFrame.ClipsDescendants = true
local frameCorner = Instance.new("UICorner", menuFrame)
frameCorner.CornerRadius = UDim.new(0, 12)

local scrollFrame = Instance.new("ScrollingFrame", menuFrame)
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
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 5)

-- Noclip switch button
local noclipEnabled = false
local noclipButton = Instance.new("TextButton", scrollFrame)
noclipButton.Size = UDim2.new(1, 0, 0, 45)
noclipButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
noclipButton.TextColor3 = Color3.fromRGB(220, 220, 220)
noclipButton.Font = Enum.Font.GothamBold
noclipButton.TextSize = 18
noclipButton.Text = "Noclip: OFF"
noclipButton.LayoutOrder = 1
noclipButton.AutoButtonColor = true
noclipButton.BorderSizePixel = 0
local btnCorner = Instance.new("UICorner", noclipButton)
btnCorner.CornerRadius = UDim.new(0, 8)

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

-- Mantener noclip activo todo el tiempo mientras esté activado
RunService.Stepped:Connect(function()
	if noclipEnabled then
		setNoclip(true)
	end
end)

-- Ajustar CanvasSize para que scroll funcione bien
local function updateCanvas()
	local contentSize = uiListLayout.AbsoluteContentSize
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 10)
end

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

local menuOpen = false

local function toggleMenu()
	if menuOpen then
		TweenService:Create(menuFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 0)}):Play()
		menuOpen = false
	else
		local contentSize = uiListLayout.AbsoluteContentSize
		local height = math.clamp(contentSize.Y + 20, 100, 350)
		TweenService:Create(menuFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, height)}):Play()
		menuOpen = true
	end
end

iconButton.MouseButton1Click:Connect(toggleMenu)

-- Iniciar cerrado
menuFrame.Size = UDim2.new(0, 220, 0, 0)
menuOpen = false

-- Reaplicar noclip si el personaje respawnea
LocalPlayer.CharacterAdded:Connect(function()
	if noclipEnabled then
		setNoclip(true)
	end
end)
