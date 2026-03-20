-- Загрузка Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 | GGOG HUB",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Modded by:Magfun_legend",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GGOGHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },

    -- =====================
    -- KEY SYSTEM (ВВОД 1 РАЗ)
    -- =====================
    KeySystem = true,
    KeySettings = {
        Title = "🔒 GGOG HUB | Key System",
        Subtitle = "Введите ключ для доступа",
        Note = "Ключ можно получить у разработчика",
        FileName = "GGOGHubKeyData",  -- Файл сохранения ключа
        SaveKey = true,               -- СОХРАНЯЕТ КЛЮЧ (вводишь 1 раз!)
        GrabKeyFromSite = false,
        Key = {"MagfunLegendUltraGey"}            -- Сам ключ
    }
})

-- =============================================
-- ДАЛЬШЕ ВЕСЬ ОСТАЛЬНОЙ КОД БЕЗ ИЗМЕНЕНИЙ:
-- =============================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHRP()
    local char = GetChar()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local char = GetChar()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local Flying = false
local IsTeleporting = false
local LastInputTime = tick()
local PositionHistory = {}

local AntiGrabEnabled = false
local AntiDetectedEnabled = false

local MovementKeys = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true,
    [Enum.KeyCode.LeftShift] = true,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if MovementKeys[input.KeyCode] then
            LastInputTime = tick()
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not AntiGrabEnabled and not AntiDetectedEnabled then
        PositionHistory = {}
        return
    end
    if Flying or IsTeleporting then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    table.insert(PositionHistory, 1, {
        Time = tick(),
        CFrame = hrp.CFrame,
        Velocity = hrp.AssemblyLinearVelocity
    })
    local now = tick()
    for i = #PositionHistory, 1, -1 do
        if now - PositionHistory[i].Time > 8.5 then
            table.remove(PositionHistory, i)
        end
    end
end)

local function GetPositionSecondsAgo(seconds)
    local targetTime = tick() - seconds
    local closest = nil
    local closestDiff = math.huge
    for _, data in ipairs(PositionHistory) do
        local diff = math.abs(data.Time - targetTime)
        if diff < closestDiff then
            closestDiff = diff
            closest = data
        end
    end
    if not closest and #PositionHistory > 0 then
        closest = PositionHistory[#PositionHistory]
    end
    return closest
end

local function TeleportBack(seconds)
    local hrp = GetHRP()
    if not hrp then return false end
    local safeData = GetPositionSecondsAgo(seconds)
    if safeData then
        IsTeleporting = true
        hrp.CFrame = safeData.CFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local hum = GetHum()
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end
        end
        task.defer(function()
            task.wait(0.4)
            IsTeleporting = false
        end)
        return true
    end
    return false
end

-- =====================
-- PLAYER TAB
-- =====================
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSection("Fly System [FIXED]")

local FlySpeed = 50
local FlyConnection = nil

PlayerTab:CreateToggle({
    Name = "Fly [CFrame Method]",
    CurrentValue = false,
    Flag = "FixedFly",
    Callback = function(Value)
        Flying = Value
        if Value then
            if FlyConnection then FlyConnection:Disconnect() end
            FlyConnection = RunService.RenderStepped:Connect(function()
                if not Flying then return end
                local currentChar = LocalPlayer.Character
                if not currentChar then return end
                local currentHRP = currentChar:FindFirstChild("HumanoidRootPart")
                if not currentHRP then return end
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
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * (FlySpeed / 10)
                    currentHRP.CFrame = currentHRP.CFrame + moveDir
                end
                currentHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                pcall(function()
                    currentHRP.RotVelocity = Vector3.new(0, 0, 0)
                end)
            end)
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
    Range = {10, 300},
    Increment = 5,
    Suffix = " speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        FlySpeed = Value
    end,
})

-- =====================
-- ANTI-GRAB [BETA] OP
-- =====================
PlayerTab:CreateSection("Anti-Grab [BETA] 🔴OP")

local function SetupAntiGrabAnimTracker(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = hum:WaitForChild("Animator", 5)
    end
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not AntiGrabEnabled then return end
        if Flying or IsTeleporting then return end
        local timeSinceInput = tick() - LastInputTime
        if timeSinceInput > 0.15 then
            local animName = ""
            pcall(function()
                animName = track.Animation and track.Animation.Name or ""
            end)
            local lowerName = string.lower(animName)
            local safeAnimations = {
                "idle", "walk", "run", "jump", "fall", "climb",
                "sit", "swim", "tool", "wave", "point", "dance",
                "cheer", "laugh", "tilt", "movedirection"
            }
            local isSafe = false
            for _, safeName in ipairs(safeAnimations) do
                if string.find(lowerName, safeName) then
                    isSafe = true
                    break
                end
            end
            local grabKeywords = {
                "grab", "hold", "carry", "punch", "stun",
                "ragdoll", "knock", "sleep", "drag", "pull",
                "throw", "slam", "choke", "bind", "tie",
                "capture", "arrest", "cuff", "kill", "eat",
                "swallow", "consume", "caught", "trapped",
                "picked", "lifted", "fling", "toss", "crush"
            }
            local isGrab = false
            for _, keyword in ipairs(grabKeywords) do
                if string.find(lowerName, keyword) then
                    isGrab = true
                    break
                end
            end
            local suspiciousPriority = (
                track.Priority == Enum.AnimationPriority.Action or
                track.Priority == Enum.AnimationPriority.Action2 or
                track.Priority == Enum.AnimationPriority.Action3 or
                track.Priority == Enum.AnimationPriority.Action4
            )
            if isGrab or (suspiciousPriority and not isSafe) then
                track:Stop(0)
                TeleportBack(3)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    SetupAntiGrabAnimTracker(char)
end)
if LocalPlayer.Character then
    SetupAntiGrabAnimTracker(LocalPlayer.Character)
end

PlayerTab:CreateToggle({
    Name = "Anti-Grab [BETA] 🔴OP",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then PositionHistory = {} end
    end,
})

-- =====================
-- ANTI DETECTED [BETA Hacker]
-- =====================
PlayerTab:CreateSection("Anti Detected [BETA Hacker]")

local AntiDetectedCooldown = false

RunService.Heartbeat:Connect(function()
    if not AntiDetectedEnabled then return end
    if Flying or IsTeleporting or AntiDetectedCooldown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local timeSinceInput = tick() - LastInputTime
    local velocity = hrp.AssemblyLinearVelocity
    local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
    local fullSpeed = velocity.Magnitude
    local detected = false
    if horizontalSpeed > 18 and timeSinceInput > 0.1 then
        detected = true
    end
    if fullSpeed > 50 and timeSinceInput > 0.08 then
        detected = true
    end
    if detected then
        AntiDetectedCooldown = true
        local success = TeleportBack(7)
        if success then
            Rayfield:Notify({
                Title = "🛡️ Anti Detected [Hacker]",
                Content = "⚡ Принудительное перемещение!\nВозврат на 7 секунд назад.",
                Duration = 3,
                Image = 4483362458
            })
        end
        task.defer(function()
            task.wait(0.5)
            AntiDetectedCooldown = false
        end)
    end
end)

PlayerTab:CreateToggle({
    Name = "Anti Detected [BETA Hacker]",
    CurrentValue = false,
    Flag = "AntiDetected",
    Callback = function(Value)
        AntiDetectedEnabled = Value
        if Value then
            PositionHistory = {}
            Rayfield:Notify({
                Title = "🛡️ Anti Detected",
                Content = "Активировано! Мгновенная реакция.",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- =====================
-- MOVEMENT
-- =====================
PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local hum = GetHum()
        if hum then hum.WalkSpeed = Value end
    end,
})

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
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end
    end,
})

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
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local NoclipEnabled = false
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        NoclipEnabled = Value
    end,
})

RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

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
            Lighting.FogEnd = 1000000
        else
            Lighting.Brightness = 2
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            Lighting.FogEnd = 5000
        end
    end,
})

PlayerTab:CreateButton({
    Name = "God Mode (Max HP)",
    Callback = function()
        local hum = GetHum()
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local hum = GetHum()
        if hum then hum.Health = 0 end
    end,
})

-- =====================
-- ESP TAB
-- =====================
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateSection("Wallhack")

local ESP_ENABLED = false
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

local function ApplyESPToPlayer(player)
    if player == LocalPlayer then return end
    local function DoESP(character)
        if not character then return end
        local old = character:FindFirstChild("ESP_Highlight")
        if old then old:Destroy() end
        if ESP_ENABLED then
            local h = Instance.new("Highlight")
            h.Name = "ESP_Highlight"
            h.FillColor = ESP_COLOR
            h.OutlineColor = Color3.new(1, 1, 1)
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.Parent = character
            local head = character:FindFirstChild("Head")
            if head and not head:FindFirstChild("ESP_Name") then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ESP_Name"
                bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0, 200, 0, 50)
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.Parent = head
                local txt = Instance.new("TextLabel")
                txt.Name = "NameLabel"
                txt.Size = UDim2.new(1, 0, 0.5, 0)
                txt.BackgroundTransparency = 1
                txt.Text = player.Name
                txt.TextColor3 = ESP_COLOR
                txt.TextStrokeTransparency = 0
                txt.TextScaled = true
                txt.Font = Enum.Font.GothamBold
                txt.Parent = bb
                local dist = Instance.new("TextLabel")
                dist.Name = "DistLabel"
                dist.Size = UDim2.new(1, 0, 0.5, 0)
                dist.Position = UDim2.new(0, 0, 0.5, 0)
                dist.BackgroundTransparency = 1
                dist.Text = "0m"
                dist.TextColor3 = Color3.new(1, 1, 1)
                dist.TextStrokeTransparency = 0
                dist.TextScaled = true
                dist.Font = Enum.Font.Gotham
                dist.Parent = bb
            end
        end
    end
    if player.Character then DoESP(player.Character) end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if ESP_ENABLED then DoESP(char) end
    end)
end

RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local bb = head:FindFirstChild("ESP_Name")
                if bb then
                    local distLabel = bb:FindFirstChild("DistLabel")
                    if distLabel then
                        local theirHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if theirHRP then
                            local d = math.floor((myHRP.Position - theirHRP.Position).Magnitude)
                            distLabel.Text = "["..d.."m]"
                        end
                    end
                end
            end
        end
    end
end)

ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESP_ENABLED = Value
        for _, player in pairs(Players:GetPlayers()) do
            ApplyESPToPlayer(player)
        end
        if not Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local h = player.Character:FindFirstChild("ESP_Highlight")
                    if h then h:Destroy() end
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local bb = head:FindFirstChild("ESP_Name")
                        if bb then bb:Destroy() end
                    end
                end
            end
        end
    end,
})

Players.PlayerAdded:Connect(function(player)
    if ESP_ENABLED then ApplyESPToPlayer(player) end
end)

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        ESP_COLOR = Value
        if ESP_ENABLED then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local h = player.Character:FindFirstChild("ESP_Highlight")
                    if h then h.FillColor = Value end
                end
            end
        end
    end,
})

-- =====================
-- TELEPORT TAB
-- =====================
local TPTab = Window:CreateTab("Teleport", 4483362458)
TPTab:CreateSection("Teleport System")

local ClickTP = false
TPTab:CreateToggle({
    Name = "Click TP (Ctrl + Click)",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value)
        ClickTP = Value
    end,
})

Mouse.Button1Down:Connect(function()
    if ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        IsTeleporting = true
        local hrp = GetHRP()
        if hrp and Mouse.Hit then
            hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
        task.defer(function()
            task.wait(0.5)
            IsTeleporting = false
        end)
    end
end)

TPTab:CreateSection("Teleport to Player")

local SelectedTPPlayer = nil
local PlayerList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(PlayerList, p.Name) end
end

local TPDropdown = TPTab:CreateDropdown({
    Name = "Select Player",
    Options = PlayerList,
    CurrentOption = "",
    Flag = "TPPlayerSelect",
    Callback = function(Option)
        SelectedTPPlayer = Option
    end,
})

local function RefreshPlayerList()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    pcall(function() TPDropdown:Refresh(names, true) end)
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

TPTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if SelectedTPPlayer then
            IsTeleporting = true
            local target = Players:FindFirstChild(SelectedTPPlayer)
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = GetHRP()
                if targetHRP and myHRP then
                    myHRP.CFrame = targetHRP.CFrame + Vector3.new(3, 0, 0)
                end
            end
            task.defer(function()
                task.wait(0.5)
                IsTeleporting = false
            end)
        end
    end,
})

TPTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- =====================
-- SETTINGS TAB
-- =====================
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Hub Settings")

SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Flying = false
        AntiGrabEnabled = false
        AntiDetectedEnabled = false
        if FlyConnection then FlyConnection:Disconnect() end
        Rayfield:Destroy()
    end,
})

SettingsTab:CreateParagraph({
    Title = "🔥 GGOG HUB",
    Content = "Modded by: Magfun_legend\nKey: C00lGMAN (вводится 1 раз)\n\nAnti-Grab 🔴OP = Анимации (3 сек)\nAnti Detected = Перемещение (7 сек)"
})

SettingsTab:CreateLabel("Version 2.1 | Key System Added")
