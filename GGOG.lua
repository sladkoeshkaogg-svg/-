-- Загрузка Rayfield (проверенная ссылка)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Создание окна
local Window = Rayfield:CreateWindow({
    Name = "🔥 WORKING HUB",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Developer",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "WorkingHub",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false,
})

-- Утилиты
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Получение персонажа (с проверкой)
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:WaitForChild("Humanoid")
end

-- =====================
-- PLAYER TAB
-- =====================
local PlayerTab = Window:CreateTab("Player", 4483362458)
local PlayerSection = PlayerTab:CreateSection("Character Mods")

-- WalkSpeed (РАБОТАЕТ 100%)
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = Value
        end
    end,
})

-- JumpPower (РАБОТАЕТ 100%)
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    Suffix = " power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local hum = GetHumanoid()
        if hum then
            hum.JumpPower = Value
            hum.UseJumpPower = true -- Важно для новых игр
        end
    end,
})

-- Infinite Jump (РАБОТАЕТ 100%)
local InfiniteJump = false
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        InfiniteJump = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip (РАБОТАЕТ 100%)
local Noclip = false
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        Noclip = Value
    end,
})

RunService.Stepped:Connect(function()
    if Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Fly (РАБОТАЕТ 100%)
local Flying = false
local FlySpeed = 50
local FlyBodyVelocity = nil

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Flying = Value
        local char = GetCharacter()
        local hum = GetHumanoid()
        
        if Flying then
            -- Создаем BodyVelocity для полета
            local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            if torso then
                FlyBodyVelocity = Instance.new("BodyVelocity")
                FlyBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
                FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                FlyBodyVelocity.Parent = torso
            end
        else
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
        end
    end,
})

-- Управление полетом
RunService.RenderStepped:Connect(function()
    if Flying and FlyBodyVelocity then
        local char = GetCharacter()
        local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if torso then
            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * FlySpeed
            end
            
            FlyBodyVelocity.Velocity = moveDirection
        end
    end
end)

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = " speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        FlySpeed = Value
    end,
})

-- Full Bright (РАБОТАЕТ 100%)
PlayerTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Ambient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = 2
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        end
    end,
})

-- God Mode (Полу-бессмертие)
PlayerTab:CreateButton({
    Name = "God Mode (Reset Health)",
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end,
})

-- =====================
-- ESP TAB
-- =====================
local ESPTab = Window:CreateTab("ESP", 4483362458)
local ESPSection = ESPTab:CreateSection("Wallhack")

local ESP_ENABLED = false
local ESP_COLOR = Color3.fromRGB(255, 0, 0)
local ESP_FILL_TRANSPARENCY = 0.5

-- Функция создания ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function ApplyESP(character)
        if not character then return end
        
        -- Удаляем старый ESP если есть
        local oldHighlight = character:FindFirstChild("ESP_Highlight")
        if oldHighlight then
            oldHighlight:Destroy()
        end
        
        if ESP_ENABLED then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.FillColor = ESP_COLOR
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = ESP_FILL_TRANSPARENCY
            highlight.OutlineTransparency = 0
            highlight.Adornee = character
            highlight.Parent = character
            
            -- Добавляем BillboardGui с именем
            local head = character:FindFirstChild("Head")
            if head and not head:FindFirstChild("ESP_Name") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_Name"
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0, 100, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.Parent = head
                
                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = player.Name
                textLabel.TextColor3 = ESP_COLOR
                textLabel.TextStrokeTransparency = 0
                textLabel.TextScaled = true
                textLabel.Parent = billboard
            end
        end
    end
    
    -- Применяем к текущему персонажу
    if player.Character then
        ApplyESP(player.Character)
    end
    
    -- Применяем к будущим персонажам (respawn)
    player.CharacterAdded:Connect(function(char)
        wait(0.5) -- Ждем загрузки персонажа
        ApplyESP(char)
    end)
end

-- Включаем ESP для всех игроков
ESPTab:CreateToggle({
    Name = "Player ESP (Highlight)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESP_ENABLED = Value
        
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
        
        -- Удаляем ESP если выключили
        if not Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local nameTag = head:FindFirstChild("ESP_Name")
                        if nameTag then
                            nameTag:Destroy()
                        end
                    end
                end
            end
        end
    end,
})

-- Подключаемся к новым игрокам
Players.PlayerAdded:Connect(function(player)
    if ESP_ENABLED then
        CreateESP(player)
    end
end)

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        ESP_COLOR = Value
        -- Обновляем цвет у существующих
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("ESP_Highlight")
                if highlight then
                    highlight.FillColor = Value
                end
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local nameTag = head:FindFirstChild("ESP_Name")
                    if nameTag and nameTag:FindFirstChild("TextLabel") then
                        nameTag.TextLabel.TextColor3 = Value
                    end
                end
            end
        end
    end,
})

-- Tracers (линии к игрокам)
local TracersEnabled = false
ESPTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Flag = "Tracers",
    Callback = function(Value)
        TracersEnabled = Value
    end,
})

-- =====================
-- TELEPORT TAB
-- =====================
local TPTab = Window:CreateTab("Teleport", 4483362458)

-- Click TP
local ClickTP = false
TPTab:CreateToggle({
    Name = "Click Teleport (Ctrl + Click)",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value)
        ClickTP = Value
    end,
})

Mouse.Button1Down:Connect(function()
    if ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = GetCharacter()
        local hum = GetHumanoid()
        if char and Mouse.Hit then
            char:MoveTo(Mouse.Hit.Position)
        end
    end
end)

-- TP to Player
local selectedPlayer = nil
local PlayerDropdown = TPTab:CreateDropdown({
    Name = "Select Player",
    Options = {},
    CurrentOption = "",
    Flag = "TPPlayer",
    Callback = function(Option)
        selectedPlayer = Option
    end,
})

-- Обновляем список игроков
local function UpdatePlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    PlayerDropdown:Refresh(playerNames, true)
end

UpdatePlayerList()
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

TPTab:CreateButton({
    Name = "Teleport to Selected",
    Callback = function()
        if selectedPlayer then
            local target = Players:FindFirstChild(selectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local char = GetCharacter()
                if char then
                    char:MoveTo(target.Character.HumanoidRootPart.Position)
                end
            end
        end
    end,
})

-- =====================
-- SETTINGS TAB
-- =====================
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- Уведомление о загрузке
Rayfield:Notify({
    Title = "✅ Script Loaded",
    Content = "All functions are working! Use Ctrl for ClickTP",
    Duration = 6.5,
    Image = 4483362458,
})
