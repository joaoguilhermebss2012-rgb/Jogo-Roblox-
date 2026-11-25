--!strict
-- Gerador do Lobby Central e Coletáveis de Meme
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LobbyManager = {}

function LobbyManager.BuildLobby()
    local lobbyFolder = Workspace:FindFirstChild("LobbyFolder")
    if lobbyFolder then
        lobbyFolder:Destroy()
    end

    lobbyFolder = Instance.new("Folder")
    lobbyFolder.Name = "LobbyFolder"
    lobbyFolder.Parent = Workspace

    -- 1. Plataforma Central do Lobby (Neon e Estilizada)
    local hubBase = Instance.new("Part")
    hubBase.Name = "HubSpawnPlatform"
    hubBase.Size = Vector3.new(120, 4, 120)
    hubBase.Position = Vector3.new(0, 2, 0)
    hubBase.Anchored = true
    hubBase.Material = Enum.Material.SmoothPlastic
    hubBase.Color = Color3.fromRGB(25, 27, 38)
    hubBase.Parent = lobbyFolder

    -- Borda iluminada em Neon Ciano
    local rim = Instance.new("Part")
    rim.Name = "NeonRim"
    rim.Size = Vector3.new(124, 4.2, 124)
    rim.Position = Vector3.new(0, 1.9, 0)
    rim.Anchored = true
    rim.Material = Enum.Material.Neon
    rim.Color = Color3.fromRGB(0, 230, 255)
    rim.CanCollide = false
    rim.Parent = lobbyFolder

    -- Ponto de Spawn Seguro
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "MainSpawn"
    spawnLocation.Size = Vector3.new(16, 1, 16)
    spawnLocation.Position = Vector3.new(0, 4.5, 0)
    spawnLocation.Anchored = true
    spawnLocation.Duration = 0
    spawnLocation.Material = Enum.Material.Neon
    spawnLocation.Color = Color3.fromRGB(46, 204, 113)
    spawnLocation.Parent = lobbyFolder

    -- 2. Letreiro Holográfico Central
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(300, 80)
    billboard.StudsOffset = Vector3.new(0, 14, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = spawnLocation
    billboard.Parent = lobbyFolder

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.fromScale(1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔥 BRAINROT MULTIVERSE 🔥"
    titleLabel.TextColor3 = Color3.fromRGB(255, 230, 0)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.TextSize = 28
    titleLabel.Parent = billboard

    -- 3. Gerar Moedas Flutuantes e Giratórias no Lobby
    local coinPositions = {
        Vector3.new(25, 6, 25),
        Vector3.new(-25, 6, 25),
        Vector3.new(25, 6, -25),
        Vector3.new(-25, 6, -25),
        Vector3.new(0, 6, 35),
        Vector3.new(0, 6, -35),
        Vector3.new(35, 6, 0),
        Vector3.new(-35, 6, 0)
    }

    for i, pos in ipairs(coinPositions) do
        local coin = Instance.new("Part")
        coin.Name = "MemeCoin_" .. i
        coin.Shape = Enum.PartType.Cylinder
        coin.Size = Vector3.new(1, 4, 4)
        coin.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
        coin.Color = Color3.fromRGB(255, 215, 0)
        coin.Material = Enum.Material.Neon
        coin.Anchored = true
        coin.CanCollide = false
        coin.Parent = lobbyFolder

        -- Animação de rotação contínua
        task.spawn(function()
            while coin.Parent do
                coin.CFrame = coin.CFrame * CFrame.Angles(math.rad(2), 0, 0)
                task.wait(0.02)
            end
        end)

        -- Coletar moeda ao tocar
        local debounce = false
        coin.Touched:Connect(function(hit)
            local character = hit.Parent
            local player = character and Players:GetPlayerFromCharacter(character)
            if player and not debounce then
                debounce = true
                local leaderstats = player:FindFirstChild("leaderstats")
                local coinsVal = leaderstats and leaderstats:FindFirstChild("Meme Coins")
                if coinsVal and coinsVal:IsA("IntValue") then
                    coinsVal.Value += 10
                end

                -- Efeito visual de coleta e respawn temporário
                coin.Transparency = 1
                task.wait(3)
                coin.Transparency = 0
                debounce = false
            end
        end)
    end

    print("🏰 Lobby dinâmico construído com sucesso no Workspace!")
end

return LobbyManager
