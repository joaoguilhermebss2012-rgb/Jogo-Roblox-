--!strict
-- Banco de Dados Expandido de Peixes e Memes Brainrot
export type FishData = {
    Name: string,
    Rarity: string,
    Price: number,
    WeightRange: { min: number, max: number },
    Color: Color3,
    Description: string
}

local FishDatabase: { [string]: FishData } = {
    ["TilapiaBasica"] = {
        Name = "🐟 Tilápia Normal",
        Rarity = "Comum",
        Price = 20,
        WeightRange = { min = 1, max = 5 },
        Color = Color3.fromRGB(150, 150, 150),
        Description = "Apenas um peixe comum tentando sobreviver."
    },
    ["PeixeDourado"] = {
        Name = "🐠 Dourado Reluzente",
        Rarity = "Incomum",
        Price = 75,
        WeightRange = { min = 3, max = 10 },
        Color = Color3.fromRGB(255, 215, 0),
        Description = "Brilha tanto que cega os outros peixes."
    },
    ["TungTungHamster"] = {
        Name = "🐹 Hamster Tung Tung Triste",
        Rarity = "Raro (Meme)",
        Price = 300,
        WeightRange = { min = 4, max = 12 },
        Color = Color3.fromRGB(255, 175, 120),
        Description = "Toca violino e chora com olhos gigantes."
    },
    ["SmurfCat"] = {
        Name = "🍄 Peixe Gato Smurf (Shailushai)",
        Rarity = "Épico (Meme)",
        Price = 750,
        WeightRange = { min = 8, max = 22 },
        Color = Color3.fromRGB(50, 150, 255),
        Description = "We live, we love, we lie..."
    },
    ["ChillFish"] = {
        Name = "🦫 Peixe Chill Guy",
        Rarity = "Lendário (Meme)",
        Price = 1800,
        WeightRange = { min = 15, max = 45 },
        Color = Color3.fromRGB(180, 110, 60),
        Description = "Ele não liga pra nada. Apenas um cara tranquilo."
    },
    ["MewingCatfish"] = {
        Name = "🗿 Peixe Mewing / Mandíbula Quadrada",
        Rarity = "Lendário (Brainrot)",
        Price = 3500,
        WeightRange = { min = 25, max = 70 },
        Color = Color3.fromRGB(220, 220, 240),
        Description = "Silêncio! Ele está no mewing streak há 3 meses."
    },
    ["SkibidiShark"] = {
        Name = "🦈 Skibidi Tubarão Titã",
        Rarity = "Mítico (Deus Brainrot)",
        Price = 10000,
        WeightRange = { min = 80, max = 300 },
        Color = Color3.fromRGB(255, 40, 40),
        Description = "O terror dos 7 mares digitais!"
    }
}

return FishDatabase
