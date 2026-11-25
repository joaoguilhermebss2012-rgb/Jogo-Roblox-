--!strict
-- Inicializador do Cliente e Interface do Seletor de Gráficos
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GraphicsController = require(script.Parent:WaitForChild("GraphicsController"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Função para criar a interface moderna na tela
local function createGraphicsSelectorUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GraphicsSelectorGui"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    screenGui.IgnoreGuiInset = true

    -- Fundo escurecido suave
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    backdrop.BackgroundTransparency = 0.35
    backdrop.Parent = screenGui

    -- Card Central
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
    cardStroke.Color = Color3.fromRGB(60, 65, 90)
    cardStroke.Thickness = 2
    cardStroke.Parent = mainCard

    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.fromOffset(0, 15)
    title.BackgroundTransparency = 1
    title.Text = "🎮 ESCOLHA SUA QUALIDADE"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = mainCard

    -- Subtítulo
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -40, 0, 30)
    subtitle.Position = UDim2.fromOffset(20, 60)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Ajuste o visual para o melhor desempenho no seu dispositivo"
    subtitle.TextColor3 = Color3.fromRGB(180, 185, 205)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 13
    subtitle.TextWrapped = true
    subtitle.Parent = mainCard

    -- Container dos Botões
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -40, 0, 180)
    buttonsFrame.Position = UDim2.fromOffset(20, 110)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainCard

    local uiList = Instance.new("UIListLayout")
    uiList.FillDirection = Enum.FillDirection.Vertical
    uiList.Padding = UDim.new(0, 12)
    uiList.Parent = buttonsFrame

    local options = {
        { Name = "Low", Label = "🟢 BAIXO (Batata / Mobile - FPS Máximo)", Color = Color3.fromRGB(46, 204, 113) },
        { Name = "Medium", Label = "🟡 MÉDIO (Equilibrado / Normal)", Color = Color3.fromRGB(241, 196, 15) },
        { Name = "High", Label = "🔴 ALTO (Ultra / PC Gamer - Gráficos Top)", Color = Color3.fromRGB(231, 76, 60) }
    }

    local function selectQuality(level: GraphicsController.QualityLevel)
        GraphicsController.Apply(level)
        
        -- Animação suave para fechar o menu
        local tween = TweenService:Create(backdrop, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        TweenService:Create(mainCard, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0.5, 0.6),
            BackgroundTransparency = 1
        }):Play()
        
        tween:Play()
        tween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Name = opt.Name .. "Btn"
        btn.Size = UDim2.new(1, 0, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
        btn.Text = opt.Label
        btn.TextColor3 = Color3.fromRGB(240, 240, 250)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.AutoButtonColor = false
        btn.Parent = buttonsFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Color = opt.Color
        stroke.Thickness = 1.5
        stroke.Transparency = 0.4
        stroke.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(48, 52, 72) }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(35, 38, 52) }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0.4 }):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            selectQuality(opt.Name :: GraphicsController.QualityLevel)
        end)
    end

    screenGui.Parent = playerGui
end

-- Inicia o seletor quando o jogador carregar
createGraphicsSelectorUI()
