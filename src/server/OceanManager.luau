--!strict
-- Gerenciador da Ilha Secreta dos Memes e Barco Rápido
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local OceanManager = {}

function OceanManager.BuildOceanExpansion()
    local existingExpansion = Workspace:FindFirstChild("OceanExpansion")
    if existingExpansion then existingExpansion:Destroy() end

    local expansionFolder = Instance.new("Folder")
    expansionFolder.Name = "OceanExpansion"
    expansionFolder.Parent = Workspace

    -- 1. Ilha Misteriosa de Pesca em Alto Mar
    local islandBase = Instance.new("Part")
    islandBase.Name = "MemeIslandBase"
    islandBase.Size = Vector3.new(120, 10, 120)
    islandBase.Position = Vector3.new(0, 0, 320)
    islandBase.Anchored = true
    islandBase.Material = Enum.Material.Sand
    islandBase.Color = Color3.fromRGB(240, 215, 160)
    islandBase.Parent = expansionFolder

    -- Pedestal Neon Central da Ilha
    local holyRock = Instance.new("Part")
    holyRock.Name = "HolyMemeRock"
    holyRock.Size = Vector3.new(20, 25, 20)
    holyRock.Position = Vector3.new(0, 17, 320)
    holyRock.Anchored = true
    holyRock.Material = Enum.Material.Neon
    holyRock.Color = Color3.fromRGB(255, 0, 128)
    holyRock.Parent = expansionFolder

    local islandGui = Instance.new("BillboardGui")
    islandGui.Size = UDim2.fromOffset(300, 70)
    islandGui.StudsOffset = Vector3.new(0, 16, 0)
    islandGui.AlwaysOnTop = true
    islandGui.Adornee = holyRock
    islandGui.Parent = expansionFolder

    local islandLabel = Instance.new("TextLabel")
    islandLabel.Size = UDim2.fromScale(1, 1)
    islandLabel.BackgroundTransparency = 1
    islandLabel.Text = "🏝️ ILHA DO BRAINROT SUPREMO 🏝️\n[Chance x3 de Peixes Míticos!]"
    islandLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    islandLabel.Font = Enum.Font.FredokaOne
    islandLabel.TextSize = 16
    islandLabel.TextStrokeTransparency = 0
    islandLabel.Parent = islandGui

    -- 2. Plataforma para alugar prancha a jato / barco rápido
    local boatPad = Instance.new("Part")
    boatPad.Name = "SpawnBoatPad"
    boatPad.Size = Vector3.new(14, 1.2, 14)
    boatPad.Position = Vector3.new(35, 1, 95)
    boatPad.Anchored = true
    boatPad.Material = Enum.Material.Neon
    boatPad.Color = Color3.fromRGB(0, 200, 255)
    boatPad.Parent = expansionFolder

    local boatGui = Instance.new("BillboardGui")
    boatGui.Size = UDim2.fromOffset(260, 60)
    boatGui.StudsOffset = Vector3.new(0, 6, 0)
    boatGui.AlwaysOnTop = true
    boatGui.Adornee = boatPad
    boatGui.Parent = expansionFolder

    local boatLabel = Instance.new("TextLabel")
    boatLabel.Size = UDim2.fromScale(1, 1)
    boatLabel.BackgroundTransparency = 1
    boatLabel.Text = "🚤 VIAJAR PARA A ILHA SECRETA 🚤\n[Pise para Viajar]"
    boatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    boatLabel.Font = Enum.Font.FredokaOne
    boatLabel.TextSize = 15
    boatLabel.TextStrokeTransparency = 0
    boatLabel.Parent = boatGui

    local debounce = false
    boatPad.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = character and Players:GetPlayerFromCharacter(character)
        local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?

        if player and hrp and not debounce then
            debounce = true
            hrp.CFrame = CFrame.new(0, 8, 275)
            print("[Viagem] " .. player.Name .. " chegou na Ilha Secreta!")
            task.wait(2)
            debounce = false
        end
    end)

    -- Portal de Volta para o Hub inicial na ilha
    local returnPad = Instance.new("Part")
    returnPad.Name = "ReturnPad"
    returnPad.Size = Vector3.new(12, 1, 12)
    returnPad.Position = Vector3.new(0, 6, 270)
    returnPad.Anchored = true
    returnPad.Material = Enum.Material.Neon
    returnPad.Color = Color3.fromRGB(46, 204, 113)
    returnPad.Parent = expansionFolder

    local returnGui = Instance.new("BillboardGui")
    returnGui.Size = UDim2.fromOffset(220, 50)
    returnGui.StudsOffset = Vector3.new(0, 5, 0)
    returnGui.AlwaysOnTop = true
    returnGui.Adornee = returnPad
    returnGui.Parent = expansionFolder

    local returnLabel = Instance.new("TextLabel")
    returnLabel.Size = UDim2.fromScale(1, 1)
    returnLabel.BackgroundTransparency = 1
    returnLabel.Text = "🏠 VOLTAR AO LOBBY"
    returnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    returnLabel.Font = Enum.Font.FredokaOne
    returnLabel.TextSize = 14
    returnLabel.Parent = returnGui

    local returnDebounce = false
    returnPad.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = character and Players:GetPlayerFromCharacter(character)
        local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
        if player and hrp and not returnDebounce then
            returnDebounce = true
            hrp.CFrame = CFrame.new(0, 6, 0)
            task.wait(2)
            returnDebounce = false
        end
    end)
end

return OceanManager
