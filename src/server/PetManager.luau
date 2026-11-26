--!strict
-- Sistema de Pets Memes Flutuantes (Server)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PetManager = {}

export type PetInfo = {
    Name: string,
    Price: number,
    Color: Color3,
    LuckMultiplier: number
}

PetManager.Pets = {
    ["HamsterPet"] = {
        Name = "🐹 Pet Hamster Triste",
        Price = 500,
        Color = Color3.fromRGB(255, 180, 130),
        LuckMultiplier = 1.5
    },
    ["ChillPet"] = {
        Name = "🦫 Pet Chill Guy",
        Price = 2000,
        Color = Color3.fromRGB(160, 100, 50),
        LuckMultiplier = 2.5
    }
}

-- Cria o Pet visual e faz ele seguir o ombro do jogador
function PetManager.EquipPet(player: Player, petKey: string)
    local petData = PetManager.Pets[petKey]
    if not petData then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart") :: BasePart

    -- Remove pet antigo se tiver
    local oldPet = character:FindFirstChild("EquippedMemePet")
    if oldPet then oldPet:Destroy() end

    local petModel = Instance.new("Model")
    petModel.Name = "EquippedMemePet"

    local petPart = Instance.new("Part")
    petPart.Name = "PetBody"
    petPart.Shape = Enum.PartType.Ball
    petPart.Size = Vector3.new(2, 2, 2)
    petPart.Color = petData.Color
    petPart.Material = Enum.Material.Neon
    petPart.CanCollide = false
    petPart.Anchored = false
    petPart.Parent = petModel

    -- Nome flutuante em cima do Pet
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(160, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = petPart
    billboard.Parent = petModel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = petData.Name .. "\n[+" .. petData.LuckMultiplier .. "x Sorte]"
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 12
    label.Parent = billboard

    -- Mecânica de seguir com BodyPosition/AlignPosition
    local attachment0 = Instance.new("Attachment", petPart)
    local attachment1 = Instance.new("Attachment", hrp)
    attachment1.Position = Vector3.new(3, 2.5, 2) -- Fica flutuando no ombro direito

    local alignPos = Instance.new("AlignPosition")
    alignPos.Attachment0 = attachment0
    alignPos.Attachment1 = attachment1
    alignPos.Responsiveness = 15
    alignPos.MaxForce = 50000
    alignPos.Parent = petPart

    local alignRot = Instance.new("AlignOrientation")
    alignRot.Attachment0 = attachment0
    alignRot.Attachment1 = attachment1
    alignRot.Responsiveness = 15
    alignRot.MaxTorque = 50000
    alignRot.Parent = petPart

    petModel.PrimaryPart = petPart
    petModel.Parent = character
    print("[Pet] " .. player.Name .. " equipou " .. petData.Name)
end

-- Loja de Pets no Hub
function PetManager.BuildPetShop()
    local existingShop = Workspace:FindFirstChild("PetShopArea")
    if existingShop then existingShop:Destroy() end

    local shopFolder = Instance.new("Folder")
    shopFolder.Name = "PetShopArea"
    shopFolder.Parent = Workspace

    -- Plataforma da Loja de Pets
    local petPad = Instance.new("Part")
    petPad.Name = "PetShopPad"
    petPad.Size = Vector3.new(16, 1.2, 16)
    petPad.Position = Vector3.new(-35, 1, -20)
    petPad.Anchored = true
    petPad.Material = Enum.Material.Neon
    petPad.Color = Color3.fromRGB(255, 105, 180) -- Rosa Choque Neon
    petPad.Parent = shopFolder

    local shopGui = Instance.new("BillboardGui")
    shopGui.Size = UDim2.fromOffset(260, 60)
    shopGui.StudsOffset = Vector3.new(0, 7, 0)
    shopGui.AlwaysOnTop = true
    shopGui.Adornee = petPad
    shopGui.Parent = shopFolder

    local shopLabel = Instance.new("TextLabel")
    shopLabel.Size = UDim2.fromScale(1, 1)
    shopLabel.BackgroundTransparency = 1
    shopLabel.Text = "🐾 ADOTAR PET HAMSTER (R$ 500) 🐾\n[Pise para Comprar e Ganhar +1.5x Sorte]"
    shopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    shopLabel.Font = Enum.Font.FredokaOne
    shopLabel.TextSize = 13
    shopLabel.TextStrokeTransparency = 0
    shopLabel.Parent = shopGui

    local debounce = false
    petPad.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = character and Players:GetPlayerFromCharacter(character)
        if player and not debounce then
            debounce = true
            local leaderstats = player:FindFirstChild("leaderstats")
            local money = leaderstats and leaderstats:FindFirstChild("Dinheiro")
            if money and money:IsA("IntValue") then
                if money.Value >= 500 then
                    money.Value -= 500
                    PetManager.EquipPet(player, "HamsterPet")
                end
            end
            task.wait(2)
            debounce = false
        end
    end)
end

return PetManager
