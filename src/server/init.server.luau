--!strict
-- SISTEMA DEFINITIVO: JOGO DE PESCA DOS MEMES + AQUÁRIOS NAS PORTAS
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. CRIAÇÃO DE EVENTOS
local fishCaughtEvent = ReplicatedStorage:FindFirstChild("FishCaughtEvent") or Instance.new("RemoteEvent")
fishCaughtEvent.Name = "FishCaughtEvent"
fishCaughtEvent.Parent = ReplicatedStorage

local startFishingEvent = ReplicatedStorage:FindFirstChild("StartFishingEvent") or Instance.new("RemoteEvent")
startFishingEvent.Name = "StartFishingEvent"
startFishingEvent.Parent = ReplicatedStorage

-- 2. BANCO DE PEIXES MEMES (COM MODELOS/CORES)
local FishList = {
    { Name = "🐟 Tilápia Normal", Rarity = "Comum", Price = 25, Weight = 2, Color = Color3.fromRGB(160, 160, 160) },
    { Name = "🐠 Dourado Reluzente", Rarity = "Incomum", Price = 80, Weight = 5, Color = Color3.fromRGB(255, 215, 0) },
    { Name = "🐹 Hamster Tung Tung", Rarity = "Raro (Meme)", Price = 350, Weight = 9, Color = Color3.fromRGB(255, 180, 130) },
    { Name = "🍄 Shailushai (Smurf Cat)", Rarity = "Épico (Meme)", Price = 800, Weight = 18, Color = Color3.fromRGB(0, 150, 255) },
    { Name = "🦫 Peixe Chill Guy", Rarity = "Lendário (Meme)", Price = 2000, Weight = 35, Color = Color3.fromRGB(180, 110, 60) },
    { Name = "🗿 Peixe Mewing Mandíbula", Rarity = "Lendário (Brainrot)", Price = 4000, Weight = 60, Color = Color3.fromRGB(220, 220, 240) },
    { Name = "🦈 Skibidi Tubarão Titã", Rarity = "Mítico (Deus)", Price = 12000, Weight = 200, Color = Color3.fromRGB(255, 40, 40) }
}

-- 3. CRIAR OS AQUÁRIOS NAS BAIAS/PORTAS (ONDE ANTES ERAM PORTAS)
local function buildAquariums(folder: Folder)
    -- Posições exatas alinhadas com as 4 baias/portas do mapa do jogador
    local aquariumPositions = {
        { Pos = Vector3.new(-38, 5, -5), Name = "Aquário Comum (Tilápia & Dourado)", FishColor = Color3.fromRGB(255, 215, 0) },
        { Pos = Vector3.new(-13, 5, -5), Name = "Aquário Viral (Tung Tung Hamster)", FishColor = Color3.fromRGB(255, 180, 130) },
        { Pos = Vector3.new(13, 5, -5),  Name = "Aquário Shailushai & Chill Guy", FishColor = Color3.fromRGB(0, 180, 255) },
        { Pos = Vector3.new(38, 5, -5),  Name = "Aquário Mítico (Mewing & Skibidi)", FishColor = Color3.fromRGB(255, 50, 50) }
    }

    for i, data in ipairs(aquariumPositions) do
        local tankModel = Instance.new("Model")
        tankModel.Name = "Aquarium_" .. i
        tankModel.Parent = folder

        -- Água Translúcida com Efeito
        local water = Instance.new("Part")
        water.Name = "TankWater"
        water.Size = Vector3.new(18, 12, 14)
        water.Position = data.Pos
        water.Anchored = true
        water.CanCollide = false
        water.Material = Enum.Material.Glass
        water.Transparency = 0.4
        water.Color = Color3.fromRGB(0, 160, 255)
        water.Parent = tankModel

        -- Vidro de proteção frontal
        local glass = Instance.new("Part")
        glass.Name = "FrontGlass"
        glass.Size = Vector3.new(18.2, 12.2, 1)
        glass.Position = data.Pos + Vector3.new(0, 0, 7)
        glass.Anchored = true
        glass.Material = Enum.Material.Glass
        glass.Transparency = 0.7
        glass.Color = Color3.fromRGB(220, 240, 255)
        glass.Parent = tankModel

        -- Moldura Superior Neon
        local rim = Instance.new("Part")
        rim.Name = "NeonRim"
        rim.Size = Vector3.new(19, 1, 15)
        rim.Position = data.Pos + Vector3.new(0, 6.2, 0)
        rim.Anchored = true
        rim.Material = Enum.Material.Neon
        rim.Color = data.FishColor
        rim.Parent = tankModel

        -- Letreiro 3D do Aquário
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.fromOffset(220, 45)
        billboard.StudsOffset = Vector3.new(0, 8, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = water
        billboard.Parent = tankModel

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = "🫧 " .. data.Name .. " 🫧\n[+R$ 5/seg de Renda Passiva]"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 13
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        -- Peixinho 3D Animado Nadando em Círculos dentro da água
        local fish = Instance.new("Part")
        fish.Name = "SwimmingFish"
        fish.Size = Vector3.new(1.2, 0.8, 2.5)
        fish.Shape = Enum.PartType.Block
        fish.Color = data.FishColor
        fish.Material = Enum.Material.Neon
        fish.Anchored = true
        fish.CanCollide = false
        fish.Parent = tankModel

        -- Loop de Natação Suave
        task.spawn(function()
            local angle = math.random(0, 360)
            while fish.Parent do
                angle += 2.5
                local rad = math.rad(angle)
                local offsetX = math.cos(rad) * 6
                local offsetZ = math.sin(rad) * 4
                local targetCFrame = CFrame.new(data.Pos + Vector3.new(offsetX, math.sin(angle * 0.05) * 1.5, offsetZ)) * CFrame.Angles(0, -rad + math.pi/2, 0)
                fish.CFrame = targetCFrame
                task.wait(0.03)
            end
        end)
    end
end

-- 4. CONSTRUÇÃO COMPLETA DO MAPA MELHORADO
local function buildMap()
    local oldFolder = Workspace:FindFirstChild("FishingExpansion")
    if oldFolder then oldFolder:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "FishingExpansion"
    folder.Parent = Workspace

    -- Constrói os Aquários nas Baias
    buildAquariums(folder)

    -- Lago de Pesca Principal (Com Iluminação)
    local lake = Instance.new("Part")
    lake.Name = "LakeWater"
    lake.Size = Vector3.new(110, 6, 100)
    lake.Position = Vector3.new(0, -2, 105)
    lake.Anchored = true
    lake.CanCollide = false
    lake.Material = Enum.Material.Glass
    lake.Transparency = 0.25
    lake.Color = Color3.fromRGB(0, 170, 255)
    lake.Parent = folder

    local lakeLight = Instance.new("PointLight")
    lakeLight.Color = Color3.fromRGB(0, 220, 255)
    lakeLight.Range = 60
    lakeLight.Brightness = 2
    lakeLight.Parent = lake

    local lakeGui = Instance.new("BillboardGui")
    lakeGui.Size = UDim2.fromOffset(300, 60)
    lakeGui.StudsOffset = Vector3.new(0, 10, 0)
    lakeGui.AlwaysOnTop = true
    lakeGui.Adornee = lake
    lakeGui.Parent = folder
    local lakeTxt = Instance.new("TextLabel", lakeGui)
    lakeTxt.Size = UDim2.fromScale(1, 1)
    lakeTxt.BackgroundTransparency = 1
    lakeTxt.Text = "🎣 LAGO DOS MEMES VIRAIS 🌊"
    lakeTxt.TextColor3 = Color3.fromRGB(0, 255, 255)
    lakeTxt.Font = Enum.Font.FredokaOne
    lakeTxt.TextSize = 22
    lakeTxt.TextStrokeTransparency = 0

    -- Sell Pad (Venda de Peixes)
    local sellPad = Instance.new("Part")
    sellPad.Name = "SellPad"
    sellPad.Size = Vector3.new(14, 1.2, 14)
    sellPad.Position = Vector3.new(0, 1, -25)
    sellPad.Anchored = true
    sellPad.Material = Enum.Material.Neon
    sellPad.Color = Color3.fromRGB(255, 215, 0)
    sellPad.Parent = folder

    local sellGui = Instance.new("BillboardGui")
    sellGui.Size = UDim2.fromOffset(220, 50)
    sellGui.StudsOffset = Vector3.new(0, 6, 0)
    sellGui.AlwaysOnTop = true
    sellGui.Adornee = sellPad
    sellGui.Parent = folder
    local sellTxt = Instance.new("TextLabel", sellGui)
    sellTxt.Size = UDim2.fromScale(1, 1)
    sellTxt.BackgroundTransparency = 1
    sellTxt.Text = "💰 VENDER PEIXES 💰"
    sellTxt.TextColor3 = Color3.fromRGB(255, 255, 0)
    sellTxt.Font = Enum.Font.FredokaOne
    sellTxt.TextSize = 18
    sellTxt.TextStrokeTransparency = 0

    sellPad.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            local inv = player:FindFirstChild("FishInventory")
            local money = player.leaderstats:FindFirstChild("Dinheiro")
            if inv and money and #inv:GetChildren() > 0 then
                local total = 0
                for _, f in ipairs(inv:GetChildren()) do
                    total += f.Value
                    f:Destroy()
                end
                money.Value += total
            end
        end
    end)

    -- Roleta Diária
    local wheelPad = Instance.new("Part")
    wheelPad.Size = Vector3.new(14, 1.2, 14)
    wheelPad.Position = Vector3.new(45, 1, 15)
    wheelPad.Anchored = true
    wheelPad.Material = Enum.Material.Neon
    wheelPad.Color = Color3.fromRGB(0, 255, 180)
    wheelPad.Parent = folder

    local wheelGui = Instance.new("BillboardGui")
    wheelGui.Size = UDim2.fromOffset(260, 50)
    wheelGui.StudsOffset = Vector3.new(0, 6, 0)
    wheelGui.AlwaysOnTop = true
    wheelGui.Adornee = wheelPad
    wheelGui.Parent = folder
    local wheelTxt = Instance.new("TextLabel", wheelGui)
    wheelTxt.Size = UDim2.fromScale(1, 1)
    wheelTxt.BackgroundTransparency = 1
    wheelTxt.Text = "🎁 ROLETA DA SORTE (BÔNUS) 🎁"
    wheelTxt.TextColor3 = Color3.fromRGB(0, 255, 230)
    wheelTxt.Font = Enum.Font.FredokaOne
    wheelTxt.TextSize = 15
    wheelTxt.TextStrokeTransparency = 0

    local cooldowns = {}
    wheelPad.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player and (os.time() - (cooldowns[player.UserId] or 0) >= 30) then
            cooldowns[player.UserId] = os.time()
            local money = player.leaderstats:FindFirstChild("Dinheiro")
            if money then
                money.Value += math.random(150, 600)
            end
        end
    end)

    -- Loja de Varas
    local shopPad = Instance.new("Part")
    shopPad.Size = Vector3.new(14, 1.2, 14)
    shopPad.Position = Vector3.new(-45, 1, 15)
    shopPad.Anchored = true
    shopPad.Material = Enum.Material.Neon
    shopPad.Color = Color3.fromRGB(138, 43, 226)
    shopPad.Parent = folder

    local shopGui = Instance.new("BillboardGui")
    shopGui.Size = UDim2.fromOffset(260, 50)
    shopGui.StudsOffset = Vector3.new(0, 6, 0)
    shopGui.AlwaysOnTop = true
    shopGui.Adornee = shopPad
    shopGui.Parent = folder
    local shopTxt = Instance.new("TextLabel", shopGui)
    shopTxt.Size = UDim2.fromScale(1, 1)
    shopTxt.BackgroundTransparency = 1
    shopTxt.Text = "✨ VARA DOURADA (R$ 200) ✨"
    shopTxt.TextColor3 = Color3.fromRGB(255, 230, 0)
    shopTxt.Font = Enum.Font.FredokaOne
    shopTxt.TextSize = 15
    shopTxt.TextStrokeTransparency = 0

    shopPad.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            local money = player.leaderstats:FindFirstChild("Dinheiro")
            if money and money.Value >= 200 and not player.Backpack:FindFirstChild("🌟 Vara Dourada") then
                money.Value -= 200
                local rod = Instance.new("Tool")
                rod.Name = "🌟 Vara Dourada"
                local h = Instance.new("Part")
                h.Name = "Handle"
                h.Size = Vector3.new(0.4, 7, 0.4)
                h.Color = Color3.fromRGB(255, 215, 0)
                h.Material = Enum.Material.Neon
                h.Parent = rod
                rod.Parent = player.Backpack
            end
        end
    end)
end

buildMap()

-- 5. RENDA PASSIVA DOS AQUÁRIOS (Gera dinheiro automaticamente a cada segundo)
task.spawn(function()
    while true do
        task.wait(1)
        for _, player in ipairs(Players:GetPlayers()) do
            local leaderstats = player:FindFirstChild("leaderstats")
            local money = leaderstats and leaderstats:FindFirstChild("Dinheiro")
            if money and money:IsA("IntValue") then
                money.Value += 5 -- Cada aquário ativo gera renda passiva para os jogadores no mapa
            end
        end
    end
end)

-- 6. DADOS DO JOGADOR & VARA INICIAL
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local money = Instance.new("IntValue")
    money.Name = "Dinheiro"
    money.Value = 100 -- Já começa com 100 moedas
    money.Parent = leaderstats

    local totalCaught = Instance.new("IntValue")
    totalCaught.Name = "Peixes"
    totalCaught.Value = 0
    totalCaught.Parent = leaderstats

    local inv = Instance.new("Folder")
    inv.Name = "FishInventory"
    inv.Parent = player

    local function giveRod()
        if player.Backpack:FindFirstChild("🎣 Vara de Pescar") then return end
        local tool = Instance.new("Tool")
        tool.Name = "🎣 Vara de Pescar"
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.4, 6, 0.4)
        handle.Material = Enum.Material.Wood
        handle.Color = Color3.fromRGB(139, 69, 19)
        handle.Parent = tool
        tool.Parent = player.Backpack
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        giveRod()
    end)
    giveRod()
end)

-- 7. LÓGICA DE PESCAR
startFishingEvent.OnServerEvent:Connect(function(player)
    local inv = player:FindFirstChild("FishInventory")
    local leaderstats = player:FindFirstChild("leaderstats")
    if not inv or not leaderstats then return end

    local roll = math.random(1, #FishList)
    local fish = FishList[roll]

    local val = Instance.new("IntValue")
    val.Name = fish.Name
    val.Value = fish.Price
    val.Parent = inv

    local caughtVal = leaderstats:FindFirstChild("Peixes")
    if caughtVal then caughtVal.Value += 1 end

    fishCaughtEvent:FireClient(player, fish.Name, fish.Rarity, fish.Price, fish.Weight)
end)

print("🌊 Sistema de Pesca com Aquários das Portas Ativado!")
