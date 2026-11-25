--!strict
-- Loja de Varas de Pesca e Upgrades (Server)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local ShopManager = {}

function ShopManager.BuildRodShop()
    local existingShop = Workspace:FindFirstChild("RodShopArea")
    if existingShop then existingShop:Destroy() end

    local shopFolder = Instance.new("Folder")
    shopFolder.Name = "RodShopArea"
    shopFolder.Parent = Workspace

    -- Plataforma da Loja
    local shopPad = Instance.new("Part")
    shopPad.Name = "ShopPad"
    shopPad.Size = Vector3.new(18, 1.5, 18)
    shopPad.Position = Vector3.new(-35, 1, 15)
    shopPad.Anchored = true
    shopPad.Material = Enum.Material.Neon
    shopPad.Color = Color3.fromRGB(138, 43, 226) -- Roxo Místico
    shopPad.Parent = shopFolder

    -- Placa 3D
    local shopGui = Instance.new("BillboardGui")
    shopGui.Size = UDim2.fromOffset(260, 60)
    shopGui.StudsOffset = Vector3.new(0, 8, 0)
    shopGui.AlwaysOnTop = true
    shopGui.Adornee = shopPad
    shopGui.Parent = shopFolder

    local shopLabel = Instance.new("TextLabel")
    shopLabel.Size = UDim2.fromScale(1, 1)
    shopLabel.BackgroundTransparency = 1
    shopLabel.Text = "✨ UPGRADE DE VARA (R$ 200) ✨\n[Pise para Comprar a Vara Dourada]"
    shopLabel.TextColor3 = Color3.fromRGB(255, 230, 0)
    shopLabel.Font = Enum.Font.FredokaOne
    shopLabel.TextSize = 15
    shopLabel.TextStrokeTransparency = 0
    shopLabel.Parent = shopGui

    -- Lógica de Compra ao pisar
    local debounce = false
    shopPad.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = character and Players:GetPlayerFromCharacter(character)
        if player and not debounce then
            debounce = true
            local leaderstats = player:FindFirstChild("leaderstats")
            local money = leaderstats and leaderstats:FindFirstChild("Dinheiro")

            if money and money:IsA("IntValue") then
                if money.Value >= 200 then
                    money.Value -= 200

                    -- Dá a Vara Dourada de Meme
                    local goldenRod = Instance.new("Tool")
                    goldenRod.Name = "🌟 Vara Dourada Sigmática"
                    goldenRod.RequiresHandle = true
                    goldenRod.CanBeDropped = false

                    local handle = Instance.new("Part")
                    handle.Name = "Handle"
                    handle.Size = Vector3.new(0.5, 7, 0.5)
                    handle.Material = Enum.Material.Neon
                    handle.Color = Color3.fromRGB(255, 215, 0)
                    handle.Parent = goldenRod

                    goldenRod.Parent = player.Backpack
                    print("[Loja] " .. player.Name .. " comprou a Vara Dourada!")
                end
            end
            task.wait(2)
            debounce = false
        end
    end)
end

return ShopManager
