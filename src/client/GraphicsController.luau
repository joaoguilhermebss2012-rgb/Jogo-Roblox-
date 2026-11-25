--!strict
-- Módulo de Controle de Qualidade Gráfica (Client-side)
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local GraphicsController = {}

export type QualityLevel = "Low" | "Medium" | "High"

-- Aplica as configurações no mundo do jogador
function GraphicsController.Apply(level: QualityLevel)
    if level == "Low" then
        -- 🟢 MODO BATATA / CELULAR FRACO (Foco em FPS máximo)
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        
        -- Remove efeitos de pós-processamento pesados
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostProcessEffect") then
                effect.Enabled = false
            end
        end

        -- Otimiza renderização de terreno/peças
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false -- Desativa grama 3D pesada
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end

    elseif level == "Medium" then
        -- 🟡 MODO EQUILIBRADO
        Lighting.GlobalShadows = true
        Lighting.Technology = Enum.Technology.ShadowMap
        
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostProcessEffect") then
                effect.Enabled = true
            end
        end

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterWaveSize = 0.1
            terrain.WaterWaveSpeed = 10
        end

    elseif level == "High" then
        -- 🔴 MODO ULTRA / PC GAMER (Visual Máximo)
        Lighting.GlobalShadows = true
        Lighting.Technology = Enum.Technology.Future
        
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostProcessEffect") then
                effect.Enabled = true
            end
        end

        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = true -- Grama 3D ondulante
            terrain.WaterWaveSize = 0.25
            terrain.WaterWaveSpeed = 20
        end
    end
end

return GraphicsController
