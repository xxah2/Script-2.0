-- Mod Menu con ícono redondo "G" flotante (KRNL Android Friendly)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Crear GUI principal
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ModMenuIcon"

-- Crear el botón flotante (ícono redondo con G)
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
iconButton.BackgroundTransparency = 0
iconButton.AutoButtonColor = true
iconButton.Name = "Launcher"

-- Hacerlo redondo
local corner = Instance.new("UICorner", iconButton)
corner.CornerRadius = UDim.new(1, 0)

-- Crear el Frame del menú (vacío por ahora)
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 200, 0, 250)
menuFrame.Position = UDim2.new(0, 100, 0, 80)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.Visible = false

local frameCorner = Instance.new("UICorner", menuFrame)
frameCorner.CornerRadius = UDim.new(0, 10)

-- Botón de cerrar dentro del menú
local closeButton = Instance.new("TextButton", menuFrame)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.Text = "X"
closeButton.TextScaled = true
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)

-- Mostrar el menú al tocar el ícono
iconButton.MouseButton1Click:Connect(function()
	menuFrame.Visible = true
end)

-- Cerrar el menú
closeButton.MouseButton1Click:Connect(function()
	menuFrame.Visible = false
end)
