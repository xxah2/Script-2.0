-- 📜 PRISON LIFE MOD MENU (KRNL Android Friendly con Aimbot + Noclip) local Players = game:GetService("Players") local RunService = game:GetService("RunService") local UIS = game:GetService("UserInputService") local LocalPlayer = Players.LocalPlayer local Mouse = LocalPlayer:GetMouse() local Camera = workspace.CurrentCamera

-- Estados local noclipEnabled = false local aimbotEnabled = false

-- GUI local ScreenGui = Instance.new("ScreenGui", game.CoreGui) ScreenGui.Name = "ModMenuG"

local draggableButton = Instance.new("TextButton") draggableButton.Text = "G" draggableButton.Size = UDim2.new(0, 40, 0, 40) draggableButton.Position = UDim2.new(0, 20, 0, 120) draggableButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) draggableButton.TextColor3 = Color3.fromRGB(255, 255, 255) draggableButton.TextScaled = true draggableButton.Parent = ScreenGui

-- Drag handler local dragging = false local dragInput, mousePos, framePos

draggableButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true mousePos = input.Position framePos = draggableButton.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)\n draggableButton.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)

game:GetService("UserInputService").InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - mousePos draggableButton.Position = UDim2.new( framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y ) end end)

-- Frame scrollable con opciones local frame = Instance.new("ScrollingFrame", ScreenGui) frame.Position = UDim2.new(0, 20, 0, 180) frame.Size = UDim2.new(0, 220, 0, 250) frame.CanvasSize = UDim2.new(0, 0, 0, 500) frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) frame.Visible = false

-- Abrir/Cerrar menú con botón local menuOpen = false draggableButton.MouseButton1Click:Connect(function() menuOpen = not menuOpen frame.Visible = menuOpen end)

-- Función Noclip local function toggleNoclip() noclipEnabled = not noclipEnabled noclipButton.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF") end

RunService.Stepped:Connect(function() if noclipEnabled then for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end)

-- Función Aimbot (auto disparo al enemigo más cercano en pantalla) local function getClosestPlayer() local closest = nil local shortestDistance = math.huge

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
        local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
        if onScreen then
            local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = player
            end
        end
    end
end

return closest

end

UIS.InputBegan:Connect(function(input) if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then local target = getClosestPlayer() if target and target.Character and target.Character:FindFirstChild("Head") then local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") if tool and tool:FindFirstChild("Handle") then tool:Activate() end end end end)

-- Botón Noclip local noclipButton = Instance.new("TextButton", frame) noclipButton.Size = UDim2.new(1, -10, 0, 40) noclipButton.Position = UDim2.new(0, 5, 0, 10) noclipButton.Text = "Noclip: OFF" noclipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255) noclipButton.TextScaled = true noclipButton.MouseButton1Click:Connect(toggleNoclip)

-- Botón Aimbot local aimbotButton = Instance.new("TextButton", frame) aimbotButton.Size = UDim2.new(1, -10, 0, 40) aimbotButton.Position = UDim2.new(0, 5, 0, 60) aimbotButton.Text = "Aimbot: OFF" aimbotButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50) aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255) aimbotButton.TextScaled = true aimbotButton.MouseButton1Click:Connect(function() aimbotEnabled = not aimbotEnabled aimbotButton.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF") end)

print("✅ Mod Menu Prison Life cargado correctamente.")

