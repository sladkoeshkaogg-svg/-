-- ╔══════════════════════════════════════════════════════════╗
-- ║         DMM HUB — Extracted Features (DELTA FIX)        ║
-- ║  Fly | God Mode | Speed | Anti-Grab (WORKING)           ║
-- ║  Anti Detected | Anti All 6.9 | Auto Reset              ║
-- ║  👑 Pro Version Anti All — IMMOVABLE                     ║
-- ║  🎨 Dark-White Theme                                     ║
-- ╚══════════════════════════════════════════════════════════╝

-- ═══════ БЕЗОПАСНАЯ ЗАГРУЗКА RAYFIELD (FIX DELTA) ═══════
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("⚠️ Rayfield не загрузился с основного URL, пробуем запасной...")
    local success2, err2 = pcall(function()
        Rayfield = loadstring(game:HttpGet(
            'https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'
        ))()
    end)
    if not success2 or not Rayfield then
        -- Последняя попытка
        local success3, err3 = pcall(function()
            Rayfield = loadstring(game:HttpGet(
                'https://raw.githubusercontent.com/shlexware/Rayfield/main/source'
            ))()
        end)
        if not success3 or not Rayfield then
            warn("❌ Rayfield не удалось загрузить!")
            warn("Ошибка 1: " .. tostring(err))
            warn("Ошибка 2: " .. tostring(err2))
            warn("Ошибка 3: " .. tostring(err3))
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ DMM HUB",
                Text = "Rayfield не загрузился!\nПроверь интернет или попробуй позже.",
                Duration = 10
            })
            return
        end
    end
end

print("✅ Rayfield загружен успешно!")

-- ═══════ СЕРВИСЫ ═══════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")
local Debris            = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

-- ═══════ ЗАЩИЩЁННЫЕ ГЕТТЕРЫ ═══════
local function getChar()
    return LocalPlayer and LocalPlayer.Character
end
local function getHum()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

-- ═══════ ПЕРЕМЕННЫЕ ═══════
local Flying               = false
local IsTeleporting        = false
local LastInputTime        = tick()
local PositionHistory      = {}
local AntiGrabEnabled      = false
local AntiDetectedEnabled  = false
local AntiDetectedCooldown = false
local AntiAllHacksEnabled     = false
local AntiAllHacksConnections = {}
local ProAntiAllEnabled       = false
local ProAntiAllConnections   = {}
local LoopResetEnabled        = false
local GodModeEnabled          = false
local SpeedHackEnabled        = false
local FlySpeed                = 50
local SAFE_POSITION           = CFrame.new(322.31, 9.52, 489.68)
local _alive                  = true

local MovementKeys = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true,
    [Enum.KeyCode.LeftShift] = true,
}

pcall(function()
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if MovementKeys[input.KeyCode] then
                LastInputTime = tick()
            end
        end
    end)
end)

-- ═══════ ЗАПИСЬ ИСТОРИИ ПОЗИЦИЙ ═══════
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    if not AntiGrabEnabled and not AntiDetectedEnabled then
        PositionHistory = {}
        return
    end
    if Flying or IsTeleporting then return end
    local hrp = getHRP()
    if not hrp then return end
    pcall(function()
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
end)

local function GetPositionSecondsAgo(seconds)
    local targetTime = tick() - seconds
    local closest, closestDiff = nil, math.huge
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

function TeleportBack(seconds)
    local hrp = getHRP()
    if not hrp or not hrp.Parent then return false end
    local safeData = GetPositionSecondsAgo(seconds)
    if safeData then
        IsTeleporting = true
        hrp.CFrame = safeData.CFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        pcall(function()
            for _, child in pairs(hrp:GetChildren()) do
                if child:IsA("BodyVelocity") or child:IsA("BodyForce")
                or child:IsA("BodyThrust") or child:IsA("BodyAngularVelocity")
                or child:IsA("BodyPosition") or child:IsA("BodyGyro")
                or child:IsA("LinearVelocity") or child:IsA("VectorForce") then
                    child:Destroy()
                end
            end
        end)
        pcall(function()
            local char = getChar()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if (v:IsA("Weld") or v:IsA("WeldConstraint"))
                    and v.Part0 and v.Part1 then
                        if not v.Part0:IsDescendantOf(char)
                        or not v.Part1:IsDescendantOf(char) then
                            v:Destroy()
                        end
                    end
                end
            end
        end)
        pcall(function()
            local hum = getHum()
            if hum then
                hum.PlatformStand = false
                if hum.SeatPart
                and not hum.SeatPart:IsDescendantOf(getChar()) then
                    hum.Jump = true
                end
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end
            end
        end)
        task.defer(function()
            task.wait(0.4)
            IsTeleporting = false
        end)
        return true
    end
    return false
end

-- ═══════ ANTI-GRAB: ТРЕКЕР АНИМАЦИЙ ═══════
local _lastTrackedChar = nil

local function SetupAntiGrabAnimTracker(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        hum = char:WaitForChild("Humanoid", 5)
    end
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = hum:WaitForChild("Animator", 3)
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
                "grab", "hold", "carry", "punch", "stun", "ragdoll",
                "knock", "sleep", "drag", "pull", "throw", "slam",
                "choke", "bind", "tie", "capture", "arrest", "cuff",
                "kill", "eat", "swallow", "consume", "caught",
                "trapped", "picked", "lifted", "fling", "toss", "crush"
            }
            local isGrab = false
            for _, keyword in ipairs(grabKeywords) do
                if string.find(lowerName, keyword) then
                    isGrab = true
                    break
                end
            end
            local suspiciousPriority = (
                track.Priority == Enum.AnimationPriority.Action
                or track.Priority == Enum.AnimationPriority.Action2
                or track.Priority == Enum.AnimationPriority.Action3
                or track.Priority == Enum.AnimationPriority.Action4
            )
            if isGrab or (suspiciousPriority and not isSafe) then
                track:Stop(0)
                TeleportBack(3)
            end
        end
    end)
end

task.spawn(function()
    while _alive do
        task.wait(2)
        pcall(function()
            local char = getChar()
            if char and char ~= _lastTrackedChar then
                _lastTrackedChar = char
                task.wait(0.5)
                SetupAntiGrabAnimTracker(char)
            end
        end)
    end
end)

pcall(function()
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        _lastTrackedChar = char
        SetupAntiGrabAnimTracker(char)
    end)
end)

if getChar() then
    _lastTrackedChar = getChar()
    SetupAntiGrabAnimTracker(getChar())
end

-- ═══════ ANTI-GRAB: HEARTBEAT ═══════
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    if not AntiGrabEnabled then return end
    pcall(function()
        local char = getChar()
        local hum  = getHum()
        local hrp  = getHRP()
        if not char or not hrp then return end
        for _, v in pairs(char:GetDescendants()) do
            if (v:IsA("Weld") or v:IsA("WeldConstraint"))
            and v.Part0 and v.Part1 then
                if not v.Part0:IsDescendantOf(char)
                or not v.Part1:IsDescendantOf(char) then
                    v:Destroy()
                end
            end
        end
        if hum and hum.SeatPart then
            if not hum.SeatPart:IsDescendantOf(char) then
                hum.Jump = true
            end
            if hum.SeatPart.Parent
            and hum.SeatPart.Parent.Name:lower():find("blob") then
                hum.Jump = true
            end
        end
        if hum then hum.PlatformStand = false end
        if not Flying and not IsTeleporting then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyForce")
                or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity")
                or v:IsA("BodyPosition") or v:IsA("BodyGyro")
                or v:IsA("LinearVelocity") or v:IsA("VectorForce") then
                    v:Destroy()
                end
            end
            if hrp.AssemblyLinearVelocity.Magnitude > 300 then
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end)

-- ═══════ ANTI DETECTED HEARTBEAT ═══════
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    if not AntiDetectedEnabled then return end
    if Flying or IsTeleporting or AntiDetectedCooldown then return end
    local hrp = getHRP()
    if not hrp then return end
    pcall(function()
        local timeSinceInput  = tick() - LastInputTime
        local velocity        = hrp.AssemblyLinearVelocity
        local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        local fullSpeed       = velocity.Magnitude
        local detected = false
        if horizontalSpeed > 18 and timeSinceInput > 0.1 then
            detected = true
        end
        if fullSpeed > 50 and timeSinceInput > 0.08 then
            detected = true
        end
        if detected then
            AntiDetectedCooldown = true
            local teleportSuccess = TeleportBack(7)
            if teleportSuccess then
                pcall(function()
                    Rayfield:Notify({
                        Title = "🛡️ Anti Detected",
                        Content = "⚡ Возврат на 7 сек назад!",
                        Duration = 3,
                        Image = 4483362458
                    })
                end)
            end
            task.defer(function()
                task.wait(0.5)
                AntiDetectedCooldown = false
            end)
        end
    end)
end)

-- ═══════════════════════════════════════════════════
-- 🎨 КАСТОМНАЯ ТЁМНО-БЕЛАЯ ТЕМА ДЛЯ RAYFIELD
-- ═══════════════════════════════════════════════════
local DarkWhiteTheme = {
    TextColor = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(18, 18, 22),
    Topbar = Color3.fromRGB(24, 24, 30),
    Shadow = Color3.fromRGB(10, 10, 12),

    NotificationBackground = Color3.fromRGB(28, 28, 34),
    NotificationActionsBackground = Color3.fromRGB(22, 22, 28),

    TabBackground = Color3.fromRGB(28, 28, 34),
    TabStroke = Color3.fromRGB(50, 50, 60),
    TabBackgroundSelected = Color3.fromRGB(45, 45, 55),
    TabTextColor = Color3.fromRGB(180, 180, 190),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

    ElementBackground = Color3.fromRGB(30, 30, 38),
    ElementBackgroundHover = Color3.fromRGB(38, 38, 48),
    SecondaryElementBackground = Color3.fromRGB(22, 22, 28),
    ElementStroke = Color3.fromRGB(55, 55, 65),
    SecondaryElementStroke = Color3.fromRGB(45, 45, 55),

    SliderBackground = Color3.fromRGB(35, 35, 42),
    SliderProgress = Color3.fromRGB(220, 220, 230),
    SliderStroke = Color3.fromRGB(60, 60, 70),

    ToggleBackground = Color3.fromRGB(35, 35, 42),
    ToggleEnabled = Color3.fromRGB(230, 230, 240),
    ToggleDisabled = Color3.fromRGB(80, 80, 90),
    ToggleEnabledStroke = Color3.fromRGB(200, 200, 210),
    ToggleDisabledStroke = Color3.fromRGB(60, 60, 70),
    ToggleEnabledOuterStroke = Color3.fromRGB(180, 180, 190),
    ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 60),

    InputBackground = Color3.fromRGB(25, 25, 32),
    InputStroke = Color3.fromRGB(55, 55, 65),
    PlaceholderColor = Color3.fromRGB(120, 120, 130),
}

-- ═══════════════════════════════════════
-- ОКНО RAYFIELD С ТЁМНО-БЕЛОЙ ТЕМОЙ
-- ═══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "💀 DMM HUB — Features",
    Icon = 0,
    LoadingTitle = "💀 DMM HUB",
    LoadingSubtitle = "Loading Features for Delta...",
    Theme = DarkWhiteTheme,
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DMM_HUB",
        FileName = "Feat_Config"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("⭐ Features", 4483362458)

-- ╔═══════════════════════════╗
-- ║      ✈️ ЛЕТАНИЕ (FLY)     ║
-- ╚═══════════════════════════╝
Tab:CreateSection("✈️ Летание (Fly)")

local flyBV, flyBG

Tab:CreateToggle({
    Name = "✈️ Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(V)
        Flying = V
        if V then
            local hrp = getHRP()
            if not hrp then
                Flying = false
                return
            end
            pcall(function()
                flyBV = Instance.new("BodyVelocity")
                flyBV.Name = "_DMM_FlyBV"
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Velocity = Vector3.zero
                flyBV.Parent = hrp

                flyBG = Instance.new("BodyGyro")
                flyBG.Name = "_DMM_FlyBG"
                flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBG.P = 9e4
                flyBG.Parent = hrp
            end)

            task.spawn(function()
                while Flying do
                    RunService.Heartbeat:Wait()
                    pcall(function()
                        local cam = Workspace.CurrentCamera
                        local hum = getHum()
                        if hum and flyBV and flyBG then
                            if hum.MoveDirection.Magnitude > 0 then
                                flyBV.Velocity = cam.CFrame.LookVector * FlySpeed
                            else
                                flyBV.Velocity = Vector3.zero
                            end
                            flyBG.CFrame = cam.CFrame
                        end
                    end)
                end
            end)
        else
            pcall(function() if flyBV then flyBV:Destroy() end end)
            pcall(function() if flyBG then flyBG:Destroy() end end)
        end
    end,
})

Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    Suffix = " spd",
    CurrentValue = 50,
    Flag = "FlySpd",
    Callback = function(V)
        FlySpeed = V
    end,
})

-- ╔═══════════════════════════╗
-- ║      🛡️ GOD MODE          ║
-- ╚═══════════════════════════╝
Tab:CreateSection("🛡️ God Mode")

Tab:CreateToggle({
    Name = "🛡️ God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(V)
        GodModeEnabled = V
        if V then
            task.spawn(function()
                while GodModeEnabled do
                    pcall(function()
                        local hum = getHum()
                        if hum then
                            hum.Health = hum.MaxHealth
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- ╔═══════════════════════════╗
-- ║       🏃 SPEED            ║
-- ╚═══════════════════════════╝
Tab:CreateSection("🏃 Speed")

Tab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = " spd",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(V)
        pcall(function()
            local hum = getHum()
            if hum then hum.WalkSpeed = V end
        end)
    end,
})

Tab:CreateToggle({
    Name = "⚡ Speed Hack (CFrame)",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(V)
        SpeedHackEnabled = V
        if V then
            task.spawn(function()
                while SpeedHackEnabled do
                    RunService.Heartbeat:Wait()
                    pcall(function()
                        local hum = getHum()
                        local hrp = getHRP()
                        if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                            hrp.CFrame = hrp.CFrame + hum.MoveDirection * 2
                        end
                    end)
                end
            end)
        end
    end,
})

-- ╔═══════════════════════════════════════╗
-- ║   🛡️ ANTI-GRAB [WORKING]             ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("🛡️ Anti-Grab [WORKING]")

Tab:CreateParagraph({
    Title = "⭐ Anti-Grab Info",
    Content = "• Трекер grab-анимаций + откат 3 сек\n• Разрыв внешних Weld/WeldConstraint\n• Удаление BodyVelocity/Force\n• Выход из чужих сидений\n• Анти-ragdoll (PlatformStand)"
})

Tab:CreateToggle({
    Name = "🛡️ Anti-Grab [WORKING] 🔴OP",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then
            PositionHistory = {}
            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Anti-Grab",
                    Content = "АКТИВИРОВАН!",
                    Duration = 3,
                    Image = 4483362458
                })
            end)
        else
            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Anti-Grab",
                    Content = "Выключен.",
                    Duration = 2,
                    Image = 4483362458
                })
            end)
        end
    end,
})

-- ╔═══════════════════════════════════════╗
-- ║   🛡️ ANTI DETECTED [BETA]            ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("🛡️ Anti Detected [BETA]")

Tab:CreateParagraph({
    Title = "⭐ Anti Detected Info",
    Content = "Отслеживает принудительное перемещение.\nОткат на 7 сек. Защита от Fling/Velocity."
})

Tab:CreateToggle({
    Name = "Anti Detected [BETA]",
    CurrentValue = false,
    Flag = "AntiDetected",
    Callback = function(Value)
        AntiDetectedEnabled = Value
        if Value then
            PositionHistory = {}
            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Anti Detected",
                    Content = "АКТИВИРОВАН!",
                    Duration = 3,
                    Image = 4483362458
                })
            end)
        else
            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Anti Detected",
                    Content = "Выключен.",
                    Duration = 2,
                    Image = 4483362458
                })
            end)
        end
    end,
})

-- ╔═══════════════════════════════════════════════════╗
-- ║   💛 ANTI ALL HACKS v6.9                          ║
-- ╚═══════════════════════════════════════════════════╝
Tab:CreateSection("💛 Anti All Hacks v6.9")

Tab:CreateParagraph({
    Title = "⭐ Anti All v6.9 Info",
    Content = "10x ТП КАЖДЫЙ КАДР на безопасную позицию.\nX:322.31 Y:9.52 Z:489.68\n3 потока: Render + Heartbeat + Stepped"
})

Tab:CreateToggle({
    Name = "Anti All Hacks v6.9 ⚡ULTRA 10x",
    CurrentValue = false,
    Flag = "AntiAllHacks",
    Callback = function(Value)
        AntiAllHacksEnabled = Value
        if Value then
            for _, conn in pairs(AntiAllHacksConnections) do
                pcall(function() conn:Disconnect() end)
            end
            AntiAllHacksConnections = {}

            local function forceTP()
                if not AntiAllHacksEnabled then return end
                local hrp = getHRP()
                if not hrp then return end
                pcall(function()
                    for _i = 1, 10 do
                        hrp.CFrame = SAFE_POSITION
                        hrp.AssemblyLinearVelocity  = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                    for _, child in pairs(hrp:GetChildren()) do
                        if child:IsA("BodyVelocity") or child:IsA("BodyForce")
                        or child:IsA("BodyThrust") or child:IsA("BodyAngularVelocity")
                        or child:IsA("BodyPosition") or child:IsA("BodyGyro")
                        or child:IsA("LinearVelocity") or child:IsA("VectorForce") then
                            child:Destroy()
                        end
                    end
                end)
            end

            table.insert(AntiAllHacksConnections,
                RunService.RenderStepped:Connect(forceTP))
            table.insert(AntiAllHacksConnections,
                RunService.Heartbeat:Connect(forceTP))
            table.insert(AntiAllHacksConnections,
                RunService.Stepped:Connect(function() forceTP() end))

            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Anti All v6.9",
                    Content = "⚡ULTRA 10x × 3 потока!",
                    Duration = 4,
                    Image = 4483362458
                })
            end)
        else
            for _, conn in pairs(AntiAllHacksConnections) do
                pcall(function() conn:Disconnect() end)
            end
            AntiAllHacksConnections = {}
            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Anti All v6.9",
                    Content = "Выключен.",
                    Duration = 2,
                    Image = 4483362458
                })
            end)
        end
    end,
})

-- ╔═══════════════════════════════════════════════════╗
-- ║   💛 LOOP RESET ⚡                                ║
-- ╚═══════════════════════════════════════════════════╝
Tab:CreateSection("💛 Loop Reset ⚡")

Tab:CreateParagraph({
    Title = "⭐ Loop Reset Info",
    Content = "Ультра-быстрый ресет персонажа.\nСмерть → респавн → повтор."
})

Tab:CreateToggle({
    Name = "🔄 Loop Reset ⚡ULTRA FAST",
    CurrentValue = false,
    Flag = "LoopReset",
    Callback = function(Value)
        LoopResetEnabled = Value
        if Value then
            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Loop Reset",
                    Content = "АКТИВИРОВАН!",
                    Duration = 3,
                    Image = 4483362458
                })
            end)
            task.spawn(function()
                while LoopResetEnabled do
                    pcall(function()
                        local hum = getHum()
                        if hum and hum.Health > 0 then
                            hum.Health = 0
                        end
                    end)
                    if LoopResetEnabled then
                        local waited = 0
                        repeat
                            task.wait(0.05)
                            waited = waited + 0.05
                        until (getHum() and getHum().Health > 0)
                            or waited > 10
                            or not LoopResetEnabled
                        task.wait(0.05)
                    end
                end
            end)
        else
            pcall(function()
                Rayfield:Notify({
                    Title = "⭐ Loop Reset",
                    Content = "Выключен.",
                    Duration = 2,
                    Image = 4483362458
                })
            end)
        end
    end,
})

-- ╔═══════════════════════════════════════════════════════════╗
-- ║   👑 PRO VERSION ANTI ALL — IMMOVABLE                     ║
-- ╚═══════════════════════════════════════════════════════════╝
Tab:CreateSection("👑 Pro Version Anti All")

Tab:CreateParagraph({
    Title = "👑 Pro Anti All",
    Content = "1000x TP/кадр × 3 потока\nAnchor+CFrame Lock\nForce Kill+Weld Break\nFull Protection"
})

Tab:CreateToggle({
    Name = "👑 Pro Anti All ⚡IMMOVABLE",
    CurrentValue = false,
    Flag = "ProAntiAll",
    Callback = function(Value)
        ProAntiAllEnabled = Value
        if Value then
            for _, conn in pairs(ProAntiAllConnections) do
                pcall(function() conn:Disconnect() end)
            end
            ProAntiAllConnections = {}

            local function ultraLock()
                if not ProAntiAllEnabled then return end
                local hrp  = getHRP()
                local hum  = getHum()
                local char = getChar()
                if not hrp or not char then return end

                pcall(function()
                    -- 1000x TP
                    for _i = 1, 1000 do
                        hrp.CFrame = SAFE_POSITION
                        hrp.AssemblyLinearVelocity  = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end

                    -- Anchor lock
                    hrp.Anchored = true
                    hrp.CFrame   = SAFE_POSITION

                    -- Удаление сил HRP
                    for _, child in pairs(hrp:GetChildren()) do
                        if child:IsA("BodyVelocity") or child:IsA("BodyForce")
                        or child:IsA("BodyThrust") or child:IsA("BodyAngularVelocity")
                        or child:IsA("BodyPosition") or child:IsA("BodyGyro")
                        or child:IsA("LinearVelocity") or child:IsA("VectorForce")
                        or child:IsA("AlignPosition") or child:IsA("AlignOrientation")
                        or child:IsA("LineForce") then
                            child:Destroy()
                        end
                    end

                    -- Все части: Massless + Zero Velocity
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.AssemblyLinearVelocity  = Vector3.zero
                            part.AssemblyAngularVelocity = Vector3.zero
                            part.Massless = true
                            for _, child in pairs(part:GetChildren()) do
                                if child:IsA("BodyVelocity") or child:IsA("BodyForce")
                                or child:IsA("BodyThrust") or child:IsA("BodyAngularVelocity")
                                or child:IsA("LinearVelocity") or child:IsA("VectorForce")
                                or child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
                                    child:Destroy()
                                end
                            end
                        end
                    end

                    -- Разрыв внешних Weld
                    for _, v in pairs(char:GetDescendants()) do
                        if (v:IsA("Weld") or v:IsA("WeldConstraint")
                        or v:IsA("RigidConstraint") or v:IsA("BallSocketConstraint")
                        or v:IsA("HingeConstraint") or v:IsA("RopeConstraint")
                        or v:IsA("SpringConstraint") or v:IsA("RodConstraint"))
                        and v.Part0 and v.Part1 then
                            if not v.Part0:IsDescendantOf(char)
                            or not v.Part1:IsDescendantOf(char) then
                                v:Destroy()
                            end
                        end
                    end

                    -- Seat eject
                    if hum and hum.SeatPart
                    and not hum.SeatPart:IsDescendantOf(char) then
                        hum.Jump = true
                    end

                    -- Anti-Ragdoll + God Mode
                    if hum then
                        hum.PlatformStand = false
                        hum.Health = hum.MaxHealth
                    end

                    -- Anti-Effects
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("Fire") or v:IsA("Smoke")
                        or v:IsA("Sparkles") then
                            v:Destroy()
                        end
                    end

                    -- Стоп grab-анимаций
                    if hum then
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if animator then
                            for _, track in pairs(
                                animator:GetPlayingAnimationTracks()
                            ) do
                                local an = ""
                                pcall(function()
                                    an = track.Animation
                                        and track.Animation.Name or ""
                                end)
                                local ln = string.lower(an)
                                local safe = false
                                for _, s in ipairs({
                                    "idle", "walk", "run",
                                    "jump", "fall", "climb",
                                    "sit", "swim"
                                }) do
                                    if string.find(ln, s) then
                                        safe = true
                                        break
                                    end
                                end
                                if not safe then track:Stop(0) end
                            end
                        end
                    end

                    -- Финальный лок
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame   = SAFE_POSITION
                    hrp.Anchored = true
                end)
            end

            table.insert(ProAntiAllConnections,
                RunService.RenderStepped:Connect(ultraLock))
            table.insert(ProAntiAllConnections,
                RunService.Heartbeat:Connect(ultraLock))
            table.insert(ProAntiAllConnections,
                RunService.Stepped:Connect(function() ultraLock() end))

            pcall(function()
                Rayfield:Notify({
                    Title = "👑 Pro Anti All",
                    Content = "⚡ IMMOVABLE АКТИВИРОВАН!",
                    Duration = 5,
                    Image = 4483362458
                })
            end)
        else
            for _, conn in pairs(ProAntiAllConnections) do
                pcall(function() conn:Disconnect() end)
            end
            ProAntiAllConnections = {}
            pcall(function()
                local hrp = getHRP()
                if hrp then hrp.Anchored = false end
                local char = getChar()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Massless = false
                        end
                    end
                end
            end)
            pcall(function()
                Rayfield:Notify({
                    Title = "👑 Pro Anti All",
                    Content = "Выключен. Anchor снят.",
                    Duration = 2,
                    Image = 4483362458
                })
            end)
        end
    end,
})

-- ═══════════════════════════════════════
-- ✅ ЗАГРУЖЕНО
-- ═══════════════════════════════════════
pcall(function()
    Rayfield:Notify({
        Title = "💀 DMM HUB — Delta",
        Content = "✅ ВСЁ ЗАГРУЖЕНО!\n🎨 Dark-White Theme",
        Duration = 5,
        Image = 0,
    })
end)

print("═══════════════════════════════════════")
print("  ✅ DMM HUB — Features Loaded!")
print("  ✅ Delta Compatible!")
print("  🎨 Dark-White Theme Applied!")
print("═══════════════════════════════════════")
