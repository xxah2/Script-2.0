-- 📜 PRISON LIFE MOD MENU (KRNL Android Friendly)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ⚙️ Estados
local noclipEnabled = false
local aimbotEnabled = false

-- 🧱 GUI Principal
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ModMenuG"

-- 🔘 Botón flotante "G"
local toggleButton = Instance.new("TextButton")
toggleButton.Text = "G"
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 20, 0, 120)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Draggable = true
toggleButton.Active = true
toggleButton.Parent = gui

-- 📋 Menú con scroll
local frame = Instance.new("ScrollingFrame", gui)
frame.Position = UDim2.new(0, 20, 0, 180)
frame.Size = UDim2.new(0, 220, 0, 250)
frame.CanvasSize = UDim2.new(0, 0, 0, 500)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Visible = false
frame.ScrollBarThickness = 6

-- 🧲 Mostrar/Ocultar menú
local menuOpen = false
toggleButton.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	frame.Visible = menuOpen
end)

-- 🟡 FUNCIONES ------------------------

-- 🔁 Noclip Loop
RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- 🎯 Aimbot: Apunta al jugador más cercano visible
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

-- 🧠 Disparo auto con M9 u otra arma al más cercano
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

-- 🧩 BOTONES ------------------------

-- 🔘 Botón Noclip
local noclipButton = Instance.new("TextButton", frame)
noclipButton.Size = UDim2.new(1, -10, 0, 40)
noclipButton.Position = UDim2.new(0, 5, 0, 10)
noclipButton.Text = "Noclip: OFF"
noclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.TextScaled = true
noclipButton.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipButton.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
end)

-- 🔘 Botón Aimbot
local aimbotButton = Instance.new("TextButton", frame)
aimbotButton.Size = UDim2.new(1, -10, 0, 40)
aimbotButton.Position = UDim2.new(0, 5, 0, 60)
aimbotButton.Text = "Aimbot: OFF"
aimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotButton.TextScaled = true
aimbotButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	aimbotButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

print("✅ Mod Menu Prison Life cargado correctamente.")
