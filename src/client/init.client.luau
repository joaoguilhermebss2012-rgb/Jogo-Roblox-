--!strict
-- Cliente: Notificações de Peixes, Minigame e Efeitos Visuais
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 5) or ReplicatedStorage

local fishCaughtEvent = sharedFolder:WaitForChild("FishCaughtEvent") :: RemoteEvent
local startFishingEvent = sharedFolder:WaitForChild("StartFishingEvent") :: RemoteEvent

-- Notificação estilizada ao pescar
fishCaughtEvent.OnClientEvent:Connect(function(fishName: string, rarity: string, price: number, weight: number)
    local screenGui = playerGui:FindFirstChild("CatchCardGui") or Instance.new("ScreenGui")
    screenGui.Name = "CatchCardGui"
    screenGui.Parent = playerGui

    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(360, 110)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.05)
    card.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
    card.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 255)
    stroke.Thickness = 2
    stroke.Parent = card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = string.format("🎣 FISGADO COM SUCESSO!\n%s\n⭐ %s | ⚖️ %d kg | 💰 R$ %d", fishName, rarity, weight, price)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 16
    label.Parent = card

    -- Animação de descida
    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.2)
    }):Play()

    task.delay(3.5, function()
        if card.Parent then
            local fade = TweenService:Create(card, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
            fade:Play()
            fade.Completed:Connect(function() screenGui:Destroy() end)
        end
    end)
end)

-- Conecta a Vara para Pescar ao clicar
local function setupRod(char: Model)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name:find("Vara") then
            child.Activated:Connect(function()
                startFishingEvent:FireServer()
            end)
        end
    end)
end

if player.Character then setupRod(player.Character) end
player.CharacterAdded:Connect(setupRod)
