--!strict
-- Sistema Principal do Jogo de Pesca (Server)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local DataStoreService = game:GetService("DataStoreService")

local FishDatabase = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FishDatabase"))
local fishingDataStore = DataStoreService:GetDataStore("FishingMemesSave_v1")

-- Criação dos RemoteEvents necessários
local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local fishCaughtEvent = sharedFolder:FindFirstChild("FishCaughtEvent") or Instance.new("RemoteEvent")
fishCaughtEvent.Name = "FishCaughtEvent"
fishCaughtEvent.Parent = sharedFolder

local startFishingEvent = sharedFolder:FindFirstChild("StartFishingEvent") or Instance.new("RemoteEvent")
startFishingEvent.Name = "StartFishingEvent"
startFishingEvent.Parent = sharedFolder

-- 1. Cria a Zona de Água / Lago e a Área de Venda no Mapa
local function setupFishingEnvironment()
    local existingZone = Workspace:FindFirstChild("FishingZone")
    if existingZone then existingZone:Destroy() end

    local fishingFolder = Instance.new("Folder")
    fishingFolder.Name = "FishingZone"
    fishingFolder.Parent = Workspace

    -- Lago de Pesca (Água em Neon Azul Luminoso no final da pista)
    local lake = Instance.new("Part")
    lake.Name = "LakeWater"
    lake.Size = Vector3.new(90, 8, 90)
    lake.Position = Vector3.new(0, -2, 100)
    lake.Anchored = true
    lake.CanCollide = false
    lake.Material = Enum.Material.Glass
    lake.Transparency = 0.3
    lake.Color = Color3.fromRGB(0, 160, 255)
    lake.Parent = fishingFolder

    -- Letreiro 3D do Lago
    local lakeGui = Instance.new("BillboardGui")
    lakeGui.Size = UDim2.fromOffset(250, 60)
    lakeGui.StudsOffset = Vector3.new(0, 10, 0)
    lakeGui.AlwaysOnTop = true
    lakeGui.Adornee = lake
    lakeGui.Parent = fishingFolder

    local lakeLabel = Instance.new("TextLabel")
    lakeLabel.Size = UDim2.fromScale(1, 1)
    lakeLabel.BackgroundTransparency = 1
    lakeLabel.Text = "🎣 LAGO DOS MEMES VIRIAIS 🌊"
    lakeLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
    lakeLabel.Font = Enum.Font.FredokaOne
    lakeLabel.TextSize = 22
    lakeLabel.TextStrokeTransparency = 0
    lakeLabel.Parent = lakeGui

    -- Zona de Venda (Sell Area / Círculo Dourado perto do Spawn)
    local sellPad = Instance.new("Part")
    sellPad.Name = "SellPad"
    sellPad.Shape = Enum.PartType.Cylinder
    sellPad.Size = Vector3.new(1, 16, 16)
    sellPad.CFrame = CFrame.new(0, 1, -20) * CFrame.Angles(0, 0, math.rad(90))
    sellPad.Anchored = true
    sellPad.Color = Color3.fromRGB(255, 215, 0)
    sellPad.Material = Enum.Material.Neon
    sellPad.Parent = fishingFolder

    local sellGui = Instance.new("BillboardGui")
    sellGui.Size = UDim2.fromOffset(200, 50)
    sellGui.StudsOffset = Vector3.new(0, 6, 0)
    sellGui.AlwaysOnTop = true
    sellGui.Adornee = sellPad
    sellGui.Parent = fishingFolder

    local sellLabel = Instance.new("TextLabel")
    sellLabel.Size = UDim2.fromScale(1, 1)
    sellLabel.BackgroundTransparency = 1
    sellLabel.Text = "💰 VENDER PEIXES 💰"
    sellLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    sellLabel.Font = Enum.Font.FredokaOne
    sellLabel.TextSize = 20
    sellLabel.TextStrokeTransparency = 0
    sellLabel.Parent = sellGui

    -- Vender peixes ao pisar no SellPad
    sellPad.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = character and Players:GetPlayerFromCharacter(character)
        if player then
            local inventory = player:FindFirstChild("FishInventory")
            local leaderstats = player:FindFirstChild("leaderstats")
            local money = leaderstats and leaderstats:FindFirstChild("Dinheiro")

            if inventory and money and #inventory:GetChildren() > 0 then
                local totalEarned = 0
                for _, fish in ipairs(inventory:GetChildren()) do
                    local priceVal = fish:FindFirstChild("Price")
                    if priceVal and priceVal:IsA("IntValue") then
                        totalEarned += priceVal.Value
                    end
                    fish:Destroy()
                end
                money.Value += totalEarned
                print("[Venda] " .. player.Name .. " vendeu peixes por $" .. totalEarned)
            end
        end
    end)
end

setupFishingEnvironment()

-- 2. Leaderstats e Carregamento de Dados
local function onPlayerAdded(player: Player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local money = Instance.new("IntValue")
    money.Name = "Dinheiro"
    money.Value = 0
    money.Parent = leaderstats

    local totalCaught = Instance.new("IntValue")
    totalCaught.Name = "Peixes Pegos"
    totalCaught.Value = 0
    totalCaught.Parent = leaderstats

    -- Inventário de Peixes
    local inventory = Instance.new("Folder")
    inventory.Name = "FishInventory"
    inventory.Parent = player

    -- Carregar dados salvos
    local key = "FishingPlayer_" .. player.UserId
    local success, data = pcall(function()
        return fishingDataStore:GetAsync(key)
    end)
    if success and data then
        money.Value = data.Money or 0
        totalCaught.Value = data.TotalCaught or 0
    end

    -- Dar a Vara de Pescar para a Mochila (Backpack) do jogador
    local function giveFishingRod()
        local tool = Instance.new("Tool")
        tool.Name = "🎣 Vara de Pescar"
        tool.RequiresHandle = true
        tool.CanBeDropped = false

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
        giveFishingRod()
    end)
    giveFishingRod()
end

local function onPlayerRemoving(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end

    local money = leaderstats:FindFirstChild("Dinheiro")
    local totalCaught = leaderstats:FindFirstChild("Peixes Pegos")

    local data = {
        Money = money and money.Value or 0,
        TotalCaught = totalCaught and totalCaught.Value or 0
    }
    pcall(function()
        fishingDataStore:SetAsync("FishingPlayer_" .. player.UserId, data)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- 3. Lógica do Sorteio do Peixe ao Pescar
startFishingEvent.OnServerEvent:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    local inventory = player:FindFirstChild("FishInventory")
    if not leaderstats or not inventory then return end

    -- Sorteio de raridade baseado em chance
    local roll = math.random(1, 100)
    local selectedFishKey = "TilapiaBasica"

    if roll <= 45 then
        selectedFishKey = "TilapiaBasica" -- 45%
    elseif roll <= 75 then
        selectedFishKey = "PeixeDourado" -- 30%
    elseif roll <= 90 then
        selectedFishKey = "TungTungHamster" -- 15%
    elseif roll <= 98 then
        selectedFishKey = "ChillFish" -- 8%
    else
        selectedFishKey = "SkibidiShark" -- 2% Super Raro!
    end

    local fishInfo = FishDatabase[selectedFishKey]
    local weight = math.random(fishInfo.WeightRange.min, fishInfo.WeightRange.max)

    -- Adiciona ao inventário do jogador
    local fishItem = Instance.new("Configuration")
    fishItem.Name = fishInfo.Name
    
    local priceVal = Instance.new("IntValue")
    priceVal.Name = "Price"
    priceVal.Value = fishInfo.Price
    priceVal.Parent = fishItem

    local weightVal = Instance.new("NumberValue")
    weightVal.Name = "Weight"
    weightVal.Value = weight
    weightVal.Parent = fishItem

    fishItem.Parent = inventory

    local totalCaught = leaderstats:FindFirstChild("Peixes Pegos")
    if totalCaught then totalCaught.Value += 1 end

    -- Avisa o cliente para mostrar na tela o que pescou
    fishCaughtEvent:FireClient(player, fishInfo.Name, fishInfo.Rarity, fishInfo.Price, weight)
end)

print("🎣 Sistema de Pesca Memes carregado no servidor!")
