--!strict
-- Definição dos Peixes Memes e Configurações
export type FishData = {
    Name: string,
    Rarity: string,
    Price: number,
    WeightRange: { min: number, max: number },
    Color: Color3
}

local FishDatabase: { [string]: FishData } = {
    ["TilapiaBasica"] = {
        Name = "🐟 Tilápia Normal",
        Rarity = "Comum",
        Price = 15,
        WeightRange = { min = 1, max = 5 },
        Color = Color3.fromRGB(150, 150, 150)
    },
    ["PeixeDourado"] = {
        Name = "🐠 Dourado Brilhante",
        Rarity = "Raro",
        Price = 60,
        WeightRange = { min = 3, max = 10 },
        Color = Color3.fromRGB(255, 215, 0)
    },
    ["TungTungHamster"] = {
        Name = "🐹 Tung Tung Hamster Aquático",
        Rarity = "Épico (Meme)",
        Price = 250,
        WeightRange = { min = 5, max = 15 },
        Color = Color3.fromRGB(255, 175, 120)
    },
    ["ChillFish"] = {
        Name = "🦫 Peixe Chill Guy",
        Rarity = "Lendário (Meme)",
        Price = 800,
        WeightRange = { min = 10, max = 35 },
        Color = Color3.fromRGB(180, 100, 50)
    },
    ["SkibidiShark"] = {
        Name = "🦈 Skibidi Tubarão Mítico",
        Rarity = "Mítico (Brainrot)",
        Price = 2500,
        WeightRange = { min = 50, max = 150 },
        Color = Color3.fromRGB(230, 50, 50)
    }
}

return FishDatabase
