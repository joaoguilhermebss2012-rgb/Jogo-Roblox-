--!strict
-- SISTEMA MASTER VIRAL: PESCA + TYCOON DE AQUÁRIOS + RNG DE MEMES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- 1. CRIAÇÃO DE EVENTOS REMOTOS
local fishCaughtEvent = ReplicatedStorage:FindFirstChild("FishCaughtEvent") or Instance.new("RemoteEvent")
fishCaughtEvent.Name = "FishCaughtEvent"
fishCaughtEvent.Parent = ReplicatedStorage

local startFishingEvent = ReplicatedStorage:FindFirstChild("StartFishingEvent") or Instance.new("RemoteEvent")
startFishingEvent.Name = "StartFishingEvent"
startFishingEvent.Parent = ReplicatedStorage

local mythicalAlertEvent = ReplicatedStorage:FindFirstChild("MythicalAlertEvent") or Instance.new("RemoteEvent")
mythicalAlertEvent.Name = "MythicalAlertEvent"
mythicalAlertEvent.Parent = ReplicatedStorage

-- 2. BANCO DE DADOS DE PEIXES & CHANCES
local FishList = {
    { Name = "🐟 Tilápia Normal", Rarity = "Comum", Price = 25, Income = 2, Color = Color3.fromRGB(160, 160, 160), Chance = 450 },
    { Name = "🐠 Dourado Reluzente", Rarity = "Incomum", Price = 90, Income = 6, Color = Color3.fromRGB(255, 215, 0), Chance = 300 },
    { Name = "🐹 Hamster Tung Tung", Rarity = "Raro", Price = 380, Income = 25, Color = Color3.fromRGB(255, 180, 130), Chance = 140 },
    { Name = "🍄 Shailushai (Smurf Cat)", Rarity = "Épico", Price = 950, Income = 70, Color = Color3.fromRGB(0, 150, 255), Chance = 70 },
    { Name = "🦫 Peixe Chill Guy", Rarity = "Lendário", Price = 2500, Income = 180, Color = Color3.fromRGB(180, 110, 60), Chance = 30 },
    { Name = "🗿 Peixe Mewing Mandíbula", Rarity = "Lendário+", Price = 5000, Income = 400, Color = Color3.fromRGB(220, 220, 240), Chance = 9 },
    { Name = "🦈 Skibidi Tubarão Titã", Rarity = "MÍTICO", Price = 15000, Income = 1200, Color = Color3.fromRGB(255, 40, 40), Chance = 1 }
}

-- 3. CONSTRUÇÃO DO MAPA (AQUÁRIOS NAS 4 PORTAS)
local function buildMap()
    local oldFolder = Workspace:FindFirstChild("FishingExpansion")
    if oldFolder then oldFolder:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "FishingExpansion"
    folder.Parent = Workspace

    -- As 4 Baias/Portas virando Aquários de Tycoon Interativos
    local bays = {
        { Pos = Vector3.new(-38, 5, -5), Name = "Aquário 1" },
        { Pos = Vector3.new(-13, 5, -5), Name = "Aquário 2" },
        { Pos = Vector3.new(13, 5, -5),  Name = "Aquário 3" },
        { Pos = Vector3.new(38, 5, -5),  Name = "Aquário 4" }
    }

    for i, bay in ipairs(bays) do
        local tank = Instance.new("Model")
        tank.Name = "BayAquarium_" .. i
        tank.Parent = folder

        -- Tanque de Água
        local water = Instance.new("Part")
        water.Name = "Water"
        water.Size = Vector3.new(18, 12, 14)
        water.Position = bay.Pos
        water.Anchored = true
        water.CanCollide = false
        water.Material = Enum.Material.Glass
        water.Transparency = 0.35
        water.Color = Color3.fromRGB(0, 150, 255)
        water.Parent = tank

        -- Vidro de proteção
        local glass = Instance.new("Part")
        glass.Name = "Glass"
        glass.Size = Vector3.new(18.2, 12.2, 1)
        glass.Position = bay.Pos + Vector3.new(0, 0, 7)
        glass.Anchored = true
        glass.Material = Enum.Material.Glass
        glass.Transparency = 0.75
        glass.Color = Color3.fromRGB(200, 240, 255)
        glass.Parent = tank

        -- Moldura Superior
        local rim = Instance.new("Part")
        rim.Name = "Rim"
        rim.Size = Vector3.new(19, 1, 15)
        rim.Position = bay.Pos + Vector3.new(0, 6.2, 0)
        rim.Anchored = true
        rim.Material = Enum.Material.Neon
        rim.Color = Color3.fromRGB(0, 255, 255)
        rim.Parent = tank

        -- Botão no chão para DEPOSITAR PEIXES no aquário
        local depositPad = Instance.new("Part")
        depositPad.Name = "DepositPad"
        depositPad.Size = Vector3.new(8, 0.8, 8)
        depositPad.Position = bay.Pos + Vector3.new(0, -4.5, 9)
        depositPad.Anchored = true
        depositPad.Material = Enum.Material.Neon
        depositPad.Color = Color3.fromRGB(0, 255, 150)
        depositPad.Parent = tank

        local padGui = Instance.new("BillboardGui")
        padGui.Size = UDim2.fromOffset(200, 50)
        padGui.StudsOffset = Vector3.new(0, 4, 0)
        padGui.AlwaysOnTop = true
        padGui.Adornee = depositPad
        padGui.Parent = tank

        local padTxt = Instance.new("TextLabel", padGui)
        padTxt.Size = UDim2.fromScale(1, 1)
        padTxt.BackgroundTransparency = 1
        padTxt.Text = "📥 DEPOSITAR PEIXE\n[Pise para Guardar no Aquário]"
        padTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        padTxt.Font = Enum.Font.FredokaOne
        padTxt.TextSize = 12
        padTxt.TextStrokeTransparency = 0

        -- Placa Holográfica do Aquário
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.fromOffset(260, 60)
        billboard.StudsOffset = Vector3.new(0, 8.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = water
        billboard.Parent = tank

        local infoTxt = Instance.new("TextLabel", billboard)
        infoTxt.Name = "InfoLabel"
        infoTxt.Size = UDim2.fromScale(1, 1)
        infoTxt.BackgroundTransparency = 1
        infoTxt.Text = "🫧 " .. bay.Name .. " 🫧\n[Vazio - Deposite Peixes]"
        infoTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoTxt.Font = Enum.Font.FredokaOne
        infoTxt.TextSize = 14
        infoTxt.TextStrokeTransparency = 0

        -- Pasta para guardar os peixes colocados neste aquário
        local tankFishFolder = Instance.new("Folder")
        tankFishFolder.Name = "FishFolder"
        tankFishFolder.Parent = tank

        -- Lógica de Depositar ao pisar
        local debounce = false
        depositPad.Touched:Connect(function(hit)
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player and not debounce then
                debounce = true
                local inv = player:FindFirstChild("FishInventory")
                if inv and #inv:GetChildren() > 0 then
                    -- Pega o peixe mais valioso da mochila e coloca no aquário
                    local bestFish = inv:GetChildren()[#inv:GetChildren()] :: IntValue
                    local fishColorVal = bestFish:FindFirstChild("Color") :: Color3Value?
                    local fishColor = fishColorVal and fishColorVal.Value or Color3.fromRGB(255, 215, 0)
                    local incomeVal = bestFish:FindFirstChild("Income") :: IntValue?
                    local income = incomeVal and incomeVal.Value or 5

                    bestFish.Parent = tankFishFolder

                    -- Cria o peixe 3D nadando dentro desse aquário
                    local swimmingFish = Instance.new("Part")
                    swimmingFish.Name = "SwimmingFish"
                    swimmingFish.Size = Vector3.new(1.4, 0.9, 2.8)
                    swimmingFish.Color = fishColor
                    swimmingFish.Material = Enum.Material.Neon
                    swimmingFish.Anchored = true
                    swimmingFish.CanCollide = false
                    swimmingFish.Parent = tank

                    -- Loop de natação individual
                    task.spawn(function()
                        local angle = math.random(0, 360)
                        while swimmingFish.Parent do
                            angle += 3
                            local rad = math.rad(angle)
                            swimmingFish.CFrame = CFrame.new(bay.Pos + Vector3.new(math.cos(rad) * 6, math.sin(angle * 0.05) * 2, math.sin(rad) * 4)) * CFrame.Angles(0, -rad + math.pi/2, 0)
                            task.wait(0.03)
                        end
                    end)

                    -- Atualiza letreiro do aquário
                    infoTxt.Text = string.format("🫧 %s 🫧\n[%d Peixe(s) | +R$ %d/s Renda]", bay.Name, #tankFishFolder:GetChildren(), #tankFishFolder:GetChildren() * 15)
                end
                task.wait(1.5)
                debounce = false
            end
        end)
    end

    -- Lago de Pesca Principal
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
    lakeLight.Range = 65
    lakeLight.Brightness = 2.5
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

    -- Sell Pad (Vender Peixes)
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
                    total += (f:IsA("IntValue") and f.Value or 20)
                    f:Destroy()
                end
                money.Value += total
            end
        end
    end)

    -- Roleta da Sorte
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
    wheelTxt.Text = "🎁 ROLETA DA SORTE 🎁"
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
            if money then money.Value += math.random(150, 600) end
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

-- 4. RENDA PASSIVA DINÂMICA (Gera dinheiro baseado nos peixes dentro dos aquários)
task.spawn(function()
    while true do
        task.wait(1)
        local expansion = Workspace:FindFirstChild("FishingExpansion")
        local totalIncomePerSec = 5 -- Renda base

        if expansion then
            for _, child in ipairs(expansion:GetChildren()) do
                if child.Name:find("BayAquarium") then
                    local fishFolder = child:FindFirstChild("FishFolder")
                    if fishFolder then
                        for _, fish in ipairs(fishFolder:GetChildren()) do
                            local incVal = fish:FindFirstChild("Income") :: IntValue?
                            totalIncomePerSec += (incVal and incVal.Value or 5)
                        end
                    end
                end
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            local leaderstats = player:FindFirstChild("leaderstats")
            local money = leaderstats and leaderstats:FindFirstChild("Dinheiro")
            if money and money:IsA("IntValue") then
                money.Value += totalIncomePerSec
            end
        end
    end
end)

-- 5. LEADERSTATS & VARA DO JOGADOR
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local money = Instance.new("IntValue")
    money.Name = "Dinheiro"
    money.Value = 150
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

-- 6. LÓGICA DE PESCAR COM RNG & ANÚNCIO DE PEIXES MÍTICOS
startFishingEvent.OnServerEvent:Connect(function(player)
    local inv = player:FindFirstChild("FishInventory")
    local leaderstats = player:FindFirstChild("leaderstats")
    if not inv or not leaderstats then return end

    -- Sorteio ponderado por chances
    local totalWeight = 0
    for _, f in ipairs(FishList) do totalWeight += f.Chance end
    local roll = math.random(1, totalWeight)

    local current = 0
    local selectedFish = FishList[1]
    for _, f in ipairs(FishList) do
        current += f.Chance
        if roll <= current then
            selectedFish = f
            break
        end
    end

    -- Cria o item no inventário com cor e renda
    local fishItem = Instance.new("IntValue")
    fishItem.Name = selectedFish.Name
    fishItem.Value = selectedFish.Price

    local colorVal = Instance.new("Color3Value")
    colorVal.Name = "Color"
    colorVal.Value = selectedFish.Color
    colorVal.Parent = fishItem

    local incVal = Instance.new("IntValue")
    incVal.Name = "Income"
    incVal.Value = selectedFish.Income
    incVal.Parent = fishItem

    fishItem.Parent = inv

    local caughtVal = leaderstats:FindFirstChild("Peixes")
    if caughtVal then caughtVal.Value += 1 end

    -- Se for Lendário ou Mítico, dispara Alerta Global para todo o servidor!
    if selectedFish.Rarity == "Lendário" or selectedFish.Rarity == "Lendário+" or selectedFish.Rarity == "MÍTICO" then
        mythicalAlertEvent:FireAllClients(player.Name, selectedFish.Name, selectedFish.Rarity)
    end

    fishCaughtEvent:FireClient(player, selectedFish.Name, selectedFish.Rarity, selectedFish.Price, math.random(2, 50))
end)

print("🚀 Sistema Master Brainrot Fishing Tycoon Operacional!")
