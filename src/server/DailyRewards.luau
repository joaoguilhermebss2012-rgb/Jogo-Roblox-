--!strict
-- Roleta da Sorte / Recompensa Diária (Server)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local DailyRewards = {}

function DailyRewards.BuildWheel()
    local existingWheel = Workspace:FindFirstChild("DailyWheelArea")
    if existingWheel then existingWheel:Destroy() end

    local wheelFolder = Instance.new("Folder")
    wheelFolder.Name = "DailyWheelArea"
    wheelFolder.Parent = Workspace

    -- Plataforma da Roleta
    local platform = Instance.new("Part")
    platform.Name = "DailyPlatform"
    platform.Size = Vector3.new(16, 1.5, 16)
    platform.Position = Vector3.new(35, 1, 15)
    platform.Anchored = true
    platform.Material = Enum.Material.Neon
    platform.Color = Color3.fromRGB(0, 255, 180)
    platform.Parent = wheelFolder

    -- Painel 3D
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(280, 70)
    billboard.StudsOffset = Vector3.new(0, 8, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = platform
    billboard.Parent = wheelFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "🎁 ROLETA DA SORTE DIÁRIA 🎁\n[Pise para Girar e Ganhar Bônus]"
    label.TextColor3 = Color3.fromRGB(0, 255, 230)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 16
    label.TextStrokeTransparency = 0
    label.Parent = billboard

    -- Controle de tempo de resgate por jogador
    local cooldowns: { [number]: number } = {}

    platform.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = character and Players:GetPlayerFromCharacter(character)
        if player then
            local now = os.time()
            local lastClaim = cooldowns[player.UserId] or 0
            
            -- Cooldown de 60 segundos no teste (ou 24 horas em produção)
            if now - lastClaim >= 60 then
                cooldowns[player.UserId] = now
                
                local leaderstats = player:FindFirstChild("leaderstats")
                local money = leaderstats and leaderstats:FindFirstChild("Dinheiro")
                if money and money:IsA("IntValue") then
                    -- Prêmios aleatórios da roleta
                    local prizes = { 100, 250, 500, 1000 }
                    local won = prizes[math.random(1, #prizes)]
                    money.Value += won
                    print("[Roleta] " .. player.Name .. " ganhou $" .. won)
                end
            end
        end
    end)
end

return DailyRewards
