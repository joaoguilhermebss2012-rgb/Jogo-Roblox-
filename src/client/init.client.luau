--!strict
-- Cliente Master: Alertas Globais de RNG, Popups e Controle de Pesca
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 5) or ReplicatedStorage

local fishCaughtEvent = sharedFolder:WaitForChild("FishCaughtEvent") :: RemoteEvent
local startFishingEvent = sharedFolder:WaitForChild("StartFishingEvent") :: RemoteEvent
local mythicalAlertEvent = sharedFolder:WaitForChild("MythicalAlertEvent") :: RemoteEvent

-- 1. ALERTA GLOBAL ESTILO SOL'S RNG (Quando alguém tira peixe raro)
mythicalAlertEvent.OnClientEvent:Connect(function(luckyPlayerName: string, fishName: string, rarity: string)
    local alertGui = playerGui:FindFirstChild("GlobalAlertGui") or Instance.new("ScreenGui")
    alertGui.Name = "GlobalAlertGui"
    alertGui.DisplayOrder = 999
    alertGui.Parent = playerGui

    local banner = Instance.new("Frame")
    banner.Size = UDim2.fromOffset(500, 70)
    banner.AnchorPoint = Vector2.new(0.5, 0)
    banner.Position = UDim2.fromScale(0.5, -0.15)
    banner.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    banner.Parent = alertGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = banner

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 100)
    stroke.Thickness = 3
    stroke.Parent = banner

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = string.format("⚡ SORTE GLOBAL! ⚡\n%s acabou de pescar [%s] (%s)!", luckyPlayerName, fishName, rarity)
    text.TextColor3 = Color3.fromRGB(255, 230, 0)
    text.Font = Enum.Font.FredokaOne
    text.TextSize = 16
    text.TextStrokeTransparency = 0
    text.Parent = banner

    -- Desce o banner do topo da tela
    TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.05)
    }):Play()

    task.delay(4.5, function()
        if banner.Parent then
            local tween = TweenService:Create(banner, TweenInfo.new(0.4), { Position = UDim2.fromScale(0.5, -0.15) })
            tween:Play()
            tween.Completed:Connect(function() alertGui:Destroy() end)
        end
    end)
end)

-- 2. NOTIFICAÇÃO PESSOAL DE CAPTURA
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
    label.Text = string.format("🎣 FISGADO COM SUCESSO!\n%s\n⭐ %s | 💰 R$ %d\n[Deposite no Aquário para Renda!]", fishName, rarity, price)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 14
    label.Parent = card

    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.22)
    }):Play()

    task.delay(3.5, function()
        if card.Parent then
            local fade = TweenService:Create(card, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
            fade:Play()
            fade.Completed:Connect(function() screenGui:Destroy() end)
        end
    end)
end)

-- Conecta a Vara do jogador
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
