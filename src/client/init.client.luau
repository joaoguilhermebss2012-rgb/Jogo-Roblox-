--!strict
-- Cliente: Interface do Seletor de Gráficos e Notificação de Pesca
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GraphicsController = require(script.Parent:WaitForChild("GraphicsController"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared")

local fishCaughtEvent = sharedFolder:WaitForChild("FishCaughtEvent") :: RemoteEvent
local startFishingEvent = sharedFolder:WaitForChild("StartFishingEvent") :: RemoteEvent

-- 1. Interface de Qualidade Gráfica
local function createGraphicsSelectorUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GraphicsSelectorGui"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    screenGui.IgnoreGuiInset = true

    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    backdrop.BackgroundTransparency = 0.35
    backdrop.Parent = screenGui

    local mainCard = Instance.new("Frame")
    mainCard.Name = "MainCard"
    mainCard.Size = UDim2.fromOffset(450, 320)
    mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
    mainCard.Position = UDim2.fromScale(0.5, 0.5)
    mainCard.BackgroundColor3 = Color3.fromRGB(24, 25, 34)
    mainCard.BorderSizePixel = 0
    mainCard.Parent = backdrop

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 16)
    cardCorner.Parent = mainCard

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(0, 180, 255)
    cardStroke.Thickness = 2
    cardStroke.Parent = mainCard

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.fromOffset(0, 15)
    title.BackgroundTransparency = 1
    title.Text = "🎣 ESCOLHA SEUS GRÁFICOS"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = mainCard

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 30)
    subtitle.Position = UDim2.fromOffset(20, 60)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Ajuste o visual para o melhor desempenho durante a pescaria"
    subtitle.TextColor3 = Color3.fromRGB(180, 185, 205)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 13
    subtitle.Parent = mainCard

    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, -40, 0, 180)
    buttonsFrame.Position = UDim2.fromOffset(20, 110)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainCard

    local uiList = Instance.new("UIListLayout")
    uiList.FillDirection = Enum.FillDirection.Vertical
    uiList.Padding = UDim.new(0, 12)
    uiList.Parent = buttonsFrame

    local options = {
        { Name = "Low", Label = "🟢 BAIXO (Mobile / Batata - 60 FPS)", Color = Color3.fromRGB(46, 204, 113) },
        { Name = "Medium", Label = "🟡 MÉDIO (Equilibrado / Normal)", Color = Color3.fromRGB(241, 196, 15) },
        { Name = "High", Label = "🔴 ALTO (Ultra / Água Realista)", Color = Color3.fromRGB(0, 200, 255) }
    }

    local function selectQuality(level: GraphicsController.QualityLevel)
        GraphicsController.Apply(level)
        local tween = TweenService:Create(backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
        TweenService:Create(mainCard, TweenInfo.new(0.4), { Position = UDim2.fromScale(0.5, 0.6), BackgroundTransparency = 1 }):Play()
        tween:Play()
        tween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
        btn.Text = opt.Label
        btn.TextColor3 = Color3.fromRGB(240, 240, 250)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.Parent = buttonsFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = opt.Color
        stroke.Thickness = 1.5
        stroke.Parent = btn

        btn.MouseButton1Click:Connect(function()
            selectQuality(opt.Name :: GraphicsController.QualityLevel)
        end)
    end

    screenGui.Parent = playerGui
end

createGraphicsSelectorUI()

-- 2. Popup ao Pescar um Peixe Meme
fishCaughtEvent.OnClientEvent:Connect(function(fishName: string, rarity: string, price: number, weight: number)
    local screenGui = playerGui:FindFirstChild("CatchNotification") or Instance.new("ScreenGui")
    screenGui.Name = "CatchNotification"
    screenGui.Parent = playerGui

    local popup = Instance.new("Frame")
    popup.Size = UDim2.fromOffset(360, 110)
    popup.Position = UDim2.fromScale(0.5, 0.15)
    popup.AnchorPoint = Vector2.new(0.5, 0.5)
    popup.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
    popup.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = popup

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 2
    stroke.Parent = popup

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = string.format("🎣 VOCÊ PISCOU!\n%s\nRaridade: %s | Peso: %dkg | Valor: $%d", fishName, rarity, weight, price)
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.FredokaOne
    text.TextSize = 16
    text.Parent = popup

    -- Animação de entrada e saída
    popup.Position = UDim2.fromScale(0.5, 0.05)
    TweenService:Create(popup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.18)
    }):Play()

    task.delay(4, function()
        if popup.Parent then
            local fadeOut = TweenService:Create(popup, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                popup:Destroy()
            end)
        end
    end)
end)

-- 3. Ativar Pesca com a Vara (Quando o jogador equipar e clicar)
local function setupTool(character: Model)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name:find("Vara") then
            child.Activated:Connect(function()
                startFishingEvent:FireServer()
            end)
        end
    end)
end

if player.Character then setupTool(player.Character) end
player.CharacterAdded:Connect(setupTool)
