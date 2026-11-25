--!strict
-- Gerenciador de Leaderstats e Dados do Servidor
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local LobbyManager = require(script.Parent:WaitForChild("LobbyManager"))

-- Constrói o Lobby proceduralmente no Workspace
LobbyManager.BuildLobby()

local playerDataStore = DataStoreService:GetDataStore("MemeMultiverseData_v1")

local function onPlayerAdded(player: Player)
    -- Cria a pasta leaderstats nativa do Roblox
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    -- 🪙 Moedas de Meme (Meme Coins)
    local coins = Instance.new("IntValue")
    coins.Name = "Meme Coins"
    coins.Value = 0
    coins.Parent = leaderstats

    -- 🏆 Vitórias (Wins)
    local wins = Instance.new("IntValue")
    wins.Name = "Vitórias"
    wins.Value = 0
    wins.Parent = leaderstats

    -- 🗿 Aura / Streak
    local aura = Instance.new("IntValue")
    aura.Name = "Aura"
    aura.Value = 100
    aura.Parent = leaderstats

    -- Carregar dados salvos do jogador
    local playerKey = "Player_" .. player.UserId
    local success, data = pcall(function()
        return playerDataStore:GetAsync(playerKey)
    end)

    if success and data then
        coins.Value = data.Coins or 0
        wins.Value = data.Wins or 0
        aura.Value = data.Aura or 100
        print("[DataStore] Dados carregados para " .. player.Name)
    else
        print("[DataStore] Novo jogador ou dados padrão para " .. player.Name)
    end
end

local function onPlayerRemoving(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end

    local coins = leaderstats:FindFirstChild("Meme Coins")
    local wins = leaderstats:FindFirstChild("Vitórias")
    local aura = leaderstats:FindFirstChild("Aura")

    local dataToSave = {
        Coins = coins and coins.Value or 0,
        Wins = wins and wins.Value or 0,
        Aura = aura and aura.Value or 100
    }

    local playerKey = "Player_" .. player.UserId
    pcall(function()
        playerDataStore:SetAsync(playerKey, dataToSave)
    end)
    print("[DataStore] Dados salvos para " .. player.Name)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Garante que se o servidor fechar, todos os dados sejam salvos
game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerRemoving(player)
    end
end)

print("🚀 Sistema de Leaderstats & DataStore iniciado com sucesso!")
