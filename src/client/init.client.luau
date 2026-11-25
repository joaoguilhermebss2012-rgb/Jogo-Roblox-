--!strict
-- Cliente: Minigame Interativo de Pesca, HUD de Inventário e Seletor Gráfico
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GraphicsController = require(script.Parent:WaitForChild("GraphicsController"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local sharedFolder = ReplicatedStorage:WaitForChild("Shared")

local fishCaughtEvent = sharedFolder:WaitForChild("FishCaughtEvent") :: RemoteEvent
local startFishingEvent = sharedFolder:WaitForChild("StartFishingEvent") :: RemoteEvent

-- Sons divertidos
local function playSound(soundId: string, volume: number)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.8
    sound.Parent = playerGui
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

-- 1. SELETOR DE GRÁFICOS INICIAL
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
    mainCard.Size = UDim2.fromOffset(460, 330)
    mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
    mainCard.Position = UDim2.fromScale(0.5, 0.5)
    mainCard.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
    mainCard.BorderSizePixel = 0
    mainCard.Parent = backdrop

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 16)
    cardCorner.Parent = mainCard

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(0, 200, 255)
    cardStroke.Thickness = 2
    cardStroke.Parent = mainCard

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.fromOffset(0, 15)
    title.BackgroundTransparency = 1
    title.Text = "🎣 ESCOLHA SEUS GRÁFICOS"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 24
    title.Parent = mainCard

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 30)
    subtitle.Position = UDim2.fromOffset(20, 60)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Ajuste o visual para o melhor FPS na sua pescaria"
    subtitle.TextColor3 = Color3.fromRGB(170, 180, 210)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 13
    subtitle.Parent = mainCard

    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, -40, 0, 180)
    buttonsFrame.Position = UDim2.fromOffset(20, 105)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainCard

    local uiList = Instance.new("UIListLayout")
    uiList.FillDirection = Enum.FillDirection.Vertical
    uiList.Padding = UDim.new(0, 12)
    uiList.Parent = buttonsFrame

    local options = {
        { Name = "Low", Label = "🟢 BAIXO (Mobile / Celular Fraco - 60 FPS)", Color = Color3.fromRGB(46, 204, 113) },
        { Name = "Medium", Label = "🟡 MÉDIO (Equilibrado / Padrão)", Color = Color3.fromRGB(241, 196, 15) },
        { Name = "High", Label = "🔴 ALTO (Ultra / Água Realista)", Color = Color3.fromRGB(0, 200, 255) }
    }

    local function selectQuality(level: GraphicsController.QualityLevel)
        GraphicsController.Apply(level)
        playSound("rbxassetid://9069609200", 0.6) -- Click sound
        local tween = TweenService:Create(backdrop, TweenInfo.new(0.35), { BackgroundTransparency = 1 })
        TweenService:Create(mainCard, TweenInfo.new(0.35), { Position = UDim2.fromScale(0.5, 0.6), BackgroundTransparency = 1 }):Play()
        tween:Play()
        tween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
        btn.Text = opt.Label
        btn.TextColor3 = Color3.fromRGB(245, 245, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
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

-- 2. MINIGAME DE PESCA (BARRA DINÂMICA DE PUXAR)
local isFishing = false

local function startFishingMinigame()
    if isFishing then return end
    isFishing = true

    local minigameGui = Instance.new("ScreenGui")
    minigameGui.Name = "FishingMinigameGui"
    minigameGui.Parent = playerGui

    local barBackground = Instance.new("Frame")
    barBackground.Size = UDim2.fromOffset(60, 260)
    barBackground.AnchorPoint = Vector2.new(0.5, 0.5)
    barBackground.Position = UDim2.fromScale(0.5, 0.5)
    barBackground.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    barBackground.Parent = minigameGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = barBackground

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 255)
    stroke.Thickness = 2
    stroke.Parent = barBackground

    -- Zona Alvo Verde (Onde o peixe quer fugir)
    local greenZone = Instance.new("Frame")
    greenZone.Size = UDim2.new(1, -8, 0, 65)
    greenZone.Position = UDim2.new(0, 4, 0.35, 0)
    greenZone.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    greenZone.Parent = barBackground
    Instance.new("UICorner", greenZone).CornerRadius = UDim.new(0, 6)

    -- Anzol do Jogador (Barra Branca que sobe ao clicar)
    local hook = Instance.new("Frame")
    hook.Size = UDim2.new(1, -12, 0, 20)
    hook.Position = UDim2.new(0, 6, 0.85, 0)
    hook.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hook.Parent = barBackground
    Instance.new("UICorner", hook).CornerRadius = UDim.new(0, 4)

    local helpLabel = Instance.new("TextLabel")
    helpLabel.Size = UDim2.fromOffset(200, 30)
    helpLabel.AnchorPoint = Vector2.new(0.5, 0)
    helpLabel.Position = UDim2.fromScale(0.5, 1.05)
    helpLabel.BackgroundTransparency = 1
    helpLabel.Text = "CLIQUE RÁPIDO PARA SUBIR O ANZOL!"
    helpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    helpLabel.Font = Enum.Font.FredokaOne
    helpLabel.TextSize = 13
    helpLabel.Parent = barBackground

    -- Loop do Minigame de 3 segundos
    local hookY = 0.85
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            hookY = math.clamp(hookY - 0.15, 0.05, 0.9)
            playSound("rbxassetid://9069609200", 0.4)
        end
    end)

    local timer = 0
    local inZoneTime = 0
    task.spawn(function()
        while timer < 3 and minigameGui.Parent do
            task.wait(0.05)
            timer += 0.05
            hookY = math.clamp(hookY + 0.035, 0.05, 0.9) -- Gravidade puxando pra baixo
            hook.Position = UDim2.new(0, 6, hookY, 0)

            -- Verifica se o anzol está dentro da zona verde
            if hookY >= 0.3 and hookY <= 0.65 then
                inZoneTime += 0.05
            end
        end

        connection:Disconnect()
        minigameGui:Destroy()
        isFishing = false

        if inZoneTime >= 1.2 then
            -- Sucesso! Pescou!
            startFishingEvent:FireServer()
        else
            -- Peixe escapou
            playSound("rbxassetid://9069610486", 0.7)
            local failGui = Instance.new("BillboardGui")
            local char = player.Character
            if char and char:FindFirstChild("Head") then
                failGui.Size = UDim2.fromOffset(180, 40)
                failGui.StudsOffset = Vector3.new(0, 3, 0)
                failGui.AlwaysOnTop = true
                failGui.Adornee = char.Head
                failGui.Parent = playerGui

                local label = Instance.new("TextLabel")
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundTransparency = 1
                label.Text = "💨 O Peixe Escapou!"
                label.TextColor3 = Color3.fromRGB(255, 70, 70)
                label.Font = Enum.Font.FredokaOne
                label.TextSize = 16
                label.Parent = failGui

                task.delay(2, function() failGui:Destroy() end)
            end
        end
    end)
end

-- 3. NOTIFICAÇÃO DO PEIXE MEME FISGADO
fishCaughtEvent.OnClientEvent:Connect(function(fishName: string, rarity: string, price: number, weight: number)
    playSound("rbxassetid://9069609489", 0.9) -- Som alegre de recompensa

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "MemeCatchCard"
    notifGui.Parent = playerGui

    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(360, 120)
    card.Position = UDim2.fromScale(0.5, 0.2)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.BackgroundColor3 = Color3.fromRGB(24, 27, 38)
    card.Parent = notifGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 2.5
    stroke.Parent = card

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = string.format("🎣 FISGADO COM SUCESSO!\n%s\n⭐ %s | ⚖️ %d kg\n💰 Vale: $%d (Venda no Sell Pad)", fishName, rarity, weight, price)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 15
    label.Parent = card

    -- Efeito de salto
    card.Position = UDim2.fromScale(0.5, 0.05)
    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.22)
    }):Play()

    task.delay(4, function()
        if card.Parent then
            local fade = TweenService:Create(card, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
            fade:Play()
            fade.Completed:Connect(function() notifGui:Destroy() end)
        end
    end)
end)

-- Conectar com a vara
local function bindRod(character: Model)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name:find("Vara") then
            child.Activated:Connect(function()
                startFishingMinigame()
            end)
        end
    end)
end

if player.Character then bindRod(player.Character) end
player.CharacterAdded:Connect(bindRod)
