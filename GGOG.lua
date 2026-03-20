-- Загрузка Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 FIXED HUB | Anti-Grab",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "All functions working",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FixedHub",
        FileName = "Config"
    },
    KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Utils
function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function GetHRP()
    local char = GetChar()
    return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
end

function GetHum()
    local char = GetChar()
    return char:FindFirstChildOfClass("Humanoid")
end

-- =====================
-- FIXED FLY (CFrame Based)
-- =====================
local PlayerTab = Window:CreateTab("Player", 4483362458)
local FlySection = PlayerTab:CreateSection("Fly System [FIXED]")

local Flying = false
local FlySpeed = 50
local FlyConnection = nil

-- Новый фикснутый Fly через CFrame (не ломается физика)
PlayerTab:CreateToggle({
    Name = "Fly [CFrame Method]",
    CurrentValue = false,
    Flag = "FixedFly",
    Callback = function(Value)
        Flying = Value
        local char = GetChar()
        local hrp = GetHRP()
        
        if Value then
            -- Отключаем гравитацию и физику
            FlyConnection = RunService.RenderStepped:Connect(function()
                if not Flying then return end
                local currentHRP = GetHRP()
                local camera = workspace.CurrentCamera
                
                local moveDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir = moveDir + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir = moveDir - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir = moveDir - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir = moveDir + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir = moveDir + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDir = moveDir - Vector3.new(0, 1, 0)
                end
                
                -- Применяем движение
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * (FlySpeed / 10)
                    currentHRP.CFrame = currentHRP.CFrame + moveDir
                end
                
                -- Останавливаем падение/физику
                currentHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                currentHRP.RotVelocity = Vector3.new(0, 0, 0)
            end)
            
            Rayfield:Notify({Title="Fly", Content="Fly enabled! WASD + Space/Shift", Duration=3})
        else
            if FlyConnection then
                FlyConnection:Disconnect()
                FlyConnection = nil
            end
        end
    end,
})

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

-- =====================
-- ANTI-GRAB [BETA]
-- =====================
local AntiGrabSection = PlayerTab:CreateSection("Anti-Grab [BETA]")

local AntiGrabEnabled = false
local PositionHistory = {} -- История позиций (3 секунды)
local LastInputTime = tick()
local IsTeleporting = false -- Чтобы не конфликтовать с телепортом

-- Отслеживаем нажатия клавиш (чтобы понимать, двигаемся ли мы сами)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or 
           input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or
           input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
            LastInputTime = tick()
        end
    end
end)

-- Сохраняем позицию каждый кадр
RunService.Heartbeat:Connect(function()
    if not AntiGrabEnabled then 
        PositionHistory = {}
        return 
    end
    
    if Flying or IsTeleporting then return end -- Не работает при полете/телепорте
    
    local hrp = GetHRP()
    if not hrp then return end
    
    -- Добавляем текущую позицию в ис��орию
    table.insert(PositionHistory, 1, {
        Time = tick(),
        Pos = hrp.Position,
        CFrame = hrp.CFrame
    })
    
    -- Удаляем старые записи (старше 3.5 секунд на всякий случай)
    for i = #PositionHistory, 1, -1 do
        if tick() - PositionHistory[i].Time > 3.5 then
            table.remove(PositionHistory, i)
        end
    end
end)

-- Проверка на граб (движение без управления или смена анимации)
local function CheckAntiGrab()
    if not AntiGrabEnabled then return end
    if Flying or IsTeleporting then return end
    
    local hrp = GetHRP()
    local hum = GetHum()
    if not hrp or not hum then return end
    
    -- Проверка 1: Движение без нажатия клавиш (нас тащат)
    local timeSinceInput = tick() - LastInputTime
    local velocity = hrp.AssemblyLinearVelocity
    
    -- Если движемся быстро, но не нажимали клавиши больше 0.5 секунды
    if velocity.Magnitude > 25 and timeSinceInput > 0.5 then
        -- Ищем позицию 3 секунды назад
        for _, data in ipairs(PositionHistory) do
            if tick() - data.Time >= 2.9 and tick() - data.Time <= 3.1 then
                -- Телепортируем назад
                IsTeleporting = true
                hrp.CFrame = data.CFrame
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                Rayfield:Notify({
                    Title = "🛡️ Anti-Grab",
                    Content = "Обнаружено принудительное движение! Возврат на 3 секунды назад.",
                    Duration = 4,
                    Image = 4483362458
                })
                
                task.wait(0.5)
                IsTeleporting = false
                break
            end
        end
    end
end

-- Отслеживание смены анимации (граб обычно форсит анимацию)
local function SetupAnimationTracker(char)
    local hum = char:WaitForChild("Humanoid")
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    
    animator.AnimationPlayed:Connect(function(track)
        if not AntiGrabEnabled then return end
        if Flying then return end
        
        -- Если анимация сменилась, а мы не нажимали клавиши (возможно, нас схватили)
        if tick() - LastInputTime > 0.3 then
            local animName = track.Animation and track.Animation.Name or "Unknown"
            
            -- Проверяем на типичные названия граб-анимаций
            local grabKeywords = {"grab", "hold", "carry", "punch", "stun", "ragdoll", "knock", "sleep"}
            local isGrabAnim = false
            
            for _, keyword in ipairs(grabKeywords) do
                if string.find(string.lower(animName), keyword) then
                    isGrabAnim = true
                    break
                end
            end
            
            -- Также срабатываем на резкую смену анимации без управления
            if isGrabAnim or track.Priority == Enum.AnimationPriority.Action4 then
                task.wait(0.1) -- Небольшая задержка чтобы точно поймать момент
                
                if AntiGrabEnabled then
                    local hrp = GetHRP()
                    if hrp then
                        -- Ищем позицию 3 секунды назад
                        for _, data in ipairs(PositionHistory) do
                            if tick() - data.Time >= 2.9 and tick() - data.Time <= 3.1 then
                                IsTeleporting = true
                                hrp.CFrame = data.CFrame
                                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                track:Stop() -- Останавливаем граб-анимацию
                                
                                Rayfield:Notify({
                                    Title = "🛡️ Anti-Grab",
                                    Content = "Обнаружена граб-анимация ("..animName..")! Возврат...",
                                    Duration = 4,
                                    Image = 4483362458
                                })
                                
                                task.wait(0.5)
                                IsTeleporting = false
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Подключаем отслеживание анимаций
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1) -- Ждем загрузки
    SetupAnimationTracker(char)
end)

if LocalPlayer.Character then
    SetupAnimationTracker(LocalPlayer.Character)
end

-- Основной цикл проверки
RunService.Heartbeat:Connect(CheckAntiGrab)

-- UI Toggle для Anti-Grab
PlayerTab:CreateToggle({
    Name = "Anti-Grab [BETA]",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "🛡️ Anti-Grab",
                Content = "Включено! При грабе вернет на 3 секунды назад.",
                Duration = 4
            })
            PositionHistory = {} -- Очищаем историю при включении
        end
    end,
})

-- =====================
-- ОСТАЛЬНЫЕ ФУНКЦИИ (Speed, Noclip, etc)
-- =====================
PlayerTab:CreateSection("Movement")

-- WalkSpeed (Работает стабильно)
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local hum = GetHum()
        if hum then
            hum.WalkSpeed = Value
        end
    end,
})

-- JumpPower
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    Suffix = " power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local hum = GetHum()
        if hum then
            hum.JumpPower = Value
            hum.UseJumpPower = true
        end
    end,
})

-- Infinite Jump
local InfJump = false
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        InfJump = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if InfJump then
        local hum = GetHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip (Улучшенный)
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

-- =====================
-- TELEPORT (с защитой от Anti-Grab)
-- =====================
local TPTab = Window:CreateTab("Teleport", 4483362458)

-- Click TP
local ClickTP = false
TPTab:CreateToggle({
    Name = "Click TP (Ctrl + Click)",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value)
        ClickTP = Value
    end,
})

local Mouse = LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    if ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        IsTeleporting = true -- Отключаем Anti-Grab на момент телепорта
        local hrp = GetHRP()
        if hrp and Mouse.Hit then
            hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
        task.wait(0.5)
        IsTeleporting = false
    end
end)

-- Settings
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- Уведомление при запуске
task.wait(1)
Rayfield:Notify({
    Title = "✅ Script Loaded",
    Content = "Fly: CFrame метод | Anti-Grab: 3 секунды истории",
    Duration = 5,
    Image = 4483362458,
})
