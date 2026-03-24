-- ╔══════════════════════════════════════════════════════════╗
-- ║         DMM HUB — Pro Anti All v3 (FIXED+INVIS)         ║
-- ║  👑 РЕАЛЬНО РАБОТАЕТ — другие ВИДЯТ тебя на месте       ║
-- ║  👻 НЕВИДИМ ДЛЯ ТЕБЯ — другие видят нормально          ║
-- ║  ❌ Убран Anchored (ломал репликацию)                    ║
-- ║  ✅ BodyPosition/BodyGyro с бесконечной силой            ║
-- ║  ✅ Анимации реально блокируются                         ║
-- ║  🎨 Dark-White Theme | Delta Compatible                  ║
-- ╚══════════════════════════════════════════════════════════╝

-- ═══════ БЕЗОПАСНАЯ ЗАГРУЗКА RAYFIELD ═══════
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success or not Rayfield then
    pcall(function()
        Rayfield = loadstring(game:HttpGet(
            'https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'
        ))()
    end)
end
if not Rayfield then
    pcall(function()
        Rayfield = loadstring(game:HttpGet(
            'https://raw.githubusercontent.com/shlexware/Rayfield/main/source'
        ))()
    end)
end
if not Rayfield then
    warn("❌ Rayfield не загрузился!")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ DMM HUB",
            Text = "Rayfield не загрузился!",
            Duration = 10
        })
    end)
    return
end
print("✅ Rayfield загружен!")

-- ═══════ СЕРВИСЫ ═══════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

-- ═══════ ГЕТТЕРЫ ═══════
local function getChar()
    return LocalPlayer and LocalPlayer.Character
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
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
local LoopResetEnabled     = false
local GodModeEnabled       = false
local SpeedHackEnabled     = false
local FlySpeed             = 50
local SAFE_POSITION        = CFrame.new(322.31, 9.52, 489.68)
local _alive               = true

-- ═══════ ЛОКАЛЬНАЯ НЕВИДИМОСТЬ ═══════
local LocalInvisEnabled    = false
local LocalInvisConnection = nil
local LocalInvisCharConn   = nil

local OUR_BP_NAME = "_DMM_PRO_BP"
local OUR_BG_NAME = "_DMM_PRO_BG"
local OUR_FLY_BV  = "_DMM_FlyBV"
local OUR_FLY_BG  = "_DMM_FlyBG"

local MovementKeys = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true, [Enum.KeyCode.LeftShift] = true,
}

pcall(function()
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if MovementKeys[input.KeyCode] then LastInputTime = tick() end
        end
    end)
end)

-- ═══════ БЕЗОПАСНЫЕ / ОПАСНЫЕ АНИМАЦИИ ═══════
local SAFE_ANIM_KEYWORDS = {
    "idle", "walk", "run", "jump", "fall", "climb",
    "sit", "swim", "tool", "wave", "point", "dance",
    "cheer", "laugh", "tilt", "movedirection", "land"
}

local GRAB_ANIM_KEYWORDS = {
    "grab", "hold", "carry", "punch", "stun", "ragdoll",
    "knock", "sleep", "drag", "pull", "throw", "slam",
    "choke", "bind", "tie", "capture", "arrest", "cuff",
    "kill", "eat", "swallow", "consume", "caught", "trapped",
    "picked", "lifted", "fling", "toss", "crush", "blob",
    "devour", "absorb", "digest", "vore", "mouth", "tongue",
    "bite", "chew", "gulp", "inhale", "suck", "squeeze",
    "wrap", "coil", "engulf", "envelop", "smother",
    "kidnap", "abduct", "snatch", "seize", "yank",
    "attack", "strike", "hit", "smash", "pummel",
    "kick", "stomp", "trample", "flatten", "squish"
}

local function isAnimSafe(name)
    local ln = string.lower(name or "")
    if ln == "" then return false end
    for _, s in ipairs(SAFE_ANIM_KEYWORDS) do
        if string.find(ln, s) then return true end
    end
    return false
end

local function isAnimGrab(name)
    local ln = string.lower(name or "")
    for _, kw in ipairs(GRAB_ANIM_KEYWORDS) do
        if string.find(ln, kw) then return true end
    end
    return false
end

local function isOurObject(obj)
    local n = obj.Name
    return n == OUR_BP_NAME or n == OUR_BG_NAME
        or n == OUR_FLY_BV or n == OUR_FLY_BG
end

local FORCE_TYPES = {
    "BodyVelocity", "BodyForce", "BodyThrust",
    "BodyAngularVelocity", "BodyPosition", "BodyGyro",
    "LinearVelocity", "VectorForce", "AlignPosition",
    "AlignOrientation", "LineForce", "Torque"
}

local function isForceType(obj)
    for _, ft in ipairs(FORCE_TYPES) do
        if obj:IsA(ft) then return true end
    end
    return false
end

local CONSTRAINT_TYPES = {
    "Weld", "WeldConstraint", "RigidConstraint",
    "BallSocketConstraint", "HingeConstraint",
    "RopeConstraint", "SpringConstraint", "RodConstraint",
    "CylindricalConstraint", "PrismaticConstraint",
    "UniversalConstraint", "NoCollisionConstraint"
}

local function isConstraintType(obj)
    for _, ct in ipairs(CONSTRAINT_TYPES) do
        if obj:IsA(ct) then return true end
    end
    return false
end

-- ═══════════════════════════════════════════════════════
-- 👻 СИСТЕМА ЛОКАЛЬНОЙ НЕВИДИМОСТИ
-- LocalTransparencyModifier — ТОЛЬКО клиент видит
-- Сервер НЕ знает → другие игроки видят тебя НОРМАЛЬНО
-- Нулевая нагрузка — одно свойство на часть
-- ═══════════════════════════════════════════════════════

local function ApplyLocalInvisibility(char)
    if not char then return end
    for _, desc in pairs(char:GetDescendants()) do
        pcall(function()
            if desc:IsA("BasePart") then
                desc.LocalTransparencyModifier = 1
            elseif desc:IsA("Decal") or desc:IsA("Texture") then
                -- Лица и текстуры — прячем локально
                desc.Transparency = 1
            elseif desc:IsA("ParticleEmitter")
                or desc:IsA("BillboardGui")
                or desc:IsA("SurfaceGui") then
                desc.Enabled = false
            end
        end)
    end
end

local function RemoveLocalInvisibility(char)
    if not char then return end
    for _, desc in pairs(char:GetDescendants()) do
        pcall(function()
            if desc:IsA("BasePart") then
                desc.LocalTransparencyModifier = 0
            elseif desc:IsA("Decal") or desc:IsA("Texture") then
                desc.Transparency = 0
            elseif desc:IsA("ParticleEmitter")
                or desc:IsA("BillboardGui")
                or desc:IsA("SurfaceGui") then
                desc.Enabled = true
            end
        end)
    end
end

local function StartLocalInvisLoop()
    -- Убираем старое соединение
    if LocalInvisConnection then
        pcall(function() LocalInvisConnection:Disconnect() end)
        LocalInvisConnection = nil
    end
    if LocalInvisCharConn then
        pcall(function() LocalInvisCharConn:Disconnect() end)
        LocalInvisCharConn = nil
    end

    -- Каждый кадр форсим невидимость (чтобы Roblox не сбрасывал)
    LocalInvisConnection = RunService.RenderStepped:Connect(function()
        if not LocalInvisEnabled then return end
        local char = getChar()
        if not char then return end
        for _, desc in pairs(char:GetDescendants()) do
            pcall(function()
                if desc:IsA("BasePart") then
                    desc.LocalTransparencyModifier = 1
                end
            end)
        end
    end)

    -- При респавне — сразу применяем
    LocalInvisCharConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        if not LocalInvisEnabled then return end
        task.wait(0.5)
        ApplyLocalInvisibility(newChar)
        -- Когда добавляется новый потомок (аксессуар и т.д.)
        newChar.DescendantAdded:Connect(function(desc)
            if not LocalInvisEnabled then return end
            task.wait()
            pcall(function()
                if desc:IsA("BasePart") then
                    desc.LocalTransparencyModifier = 1
                elseif desc:IsA("Decal") or desc:IsA("Texture") then
                    desc.Transparency = 1
                end
            end)
        end)
    end)

    -- Применяем сейчас
    ApplyLocalInvisibility(getChar())

    -- Подписка на новые потомки текущего персонажа
    pcall(function()
        local char = getChar()
        if char then
            char.DescendantAdded:Connect(function(desc)
                if not LocalInvisEnabled then return end
                task.wait()
                pcall(function()
                    if desc:IsA("BasePart") then
                        desc.LocalTransparencyModifier = 1
                    elseif desc:IsA("Decal") or desc:IsA("Texture") then
                        desc.Transparency = 1
                    end
                end)
            end)
        end
    end)
end

local function StopLocalInvisLoop()
    if LocalInvisConnection then
        pcall(function() LocalInvisConnection:Disconnect() end)
        LocalInvisConnection = nil
    end
    if LocalInvisCharConn then
        pcall(function() LocalInvisCharConn:Disconnect() end)
        LocalInvisCharConn = nil
    end
    RemoveLocalInvisibility(getChar())
end

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
            Time = tick(), CFrame = hrp.CFrame,
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
        if diff < closestDiff then closestDiff = diff; closest = data end
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
                if isForceType(child) and not isOurObject(child) then
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
                hum.Sit = false
                hum.Jump = true
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop(0)
                    end
                end
            end
        end)
        task.defer(function() task.wait(0.4); IsTeleporting = false end)
        return true
    end
    return false
end

-- ═══════ ANTI-GRAB: ТРЕКЕР АНИМАЦИЙ ═══════
local _lastTrackedChar = nil

local function SetupAntiGrabAnimTracker(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then hum = char:WaitForChild("Humanoid", 5) end
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = hum:WaitForChild("Animator", 3) end
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not AntiGrabEnabled then return end
        if Flying or IsTeleporting then return end
        local timeSinceInput = tick() - LastInputTime
        if timeSinceInput > 0.15 then
            local animName = ""
            pcall(function() animName = track.Animation and track.Animation.Name or "" end)
            local isSafe = isAnimSafe(animName)
            local isGrab = isAnimGrab(animName)
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
    if not _alive or not AntiGrabEnabled then return end
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
            if not hum.SeatPart:IsDescendantOf(char) then hum.Jump = true end
            if hum.SeatPart.Parent
            and hum.SeatPart.Parent.Name:lower():find("blob") then
                hum.Jump = true
            end
        end
        if hum then hum.PlatformStand = false end
        if not Flying and not IsTeleporting then
            for _, v in pairs(hrp:GetChildren()) do
                if isForceType(v) and not isOurObject(v) then
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
    if not _alive or not AntiDetectedEnabled then return end
    if Flying or IsTeleporting or AntiDetectedCooldown then return end
    local hrp = getHRP()
    if not hrp then return end
    pcall(function()
        local timeSinceInput  = tick() - LastInputTime
        local velocity        = hrp.AssemblyLinearVelocity
        local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
        local fullSpeed       = velocity.Magnitude
        local detected = false
        if horizontalSpeed > 18 and timeSinceInput > 0.1 then detected = true end
        if fullSpeed > 50 and timeSinceInput > 0.08 then detected = true end
        if detected then
            AntiDetectedCooldown = true
            local ok = TeleportBack(7)
            if ok then
                pcall(function() Rayfield:Notify({
                    Title = "🛡️ Anti Detected",
                    Content = "⚡ Возврат на 7 сек!",
                    Duration = 3, Image = 4483362458
                }) end)
            end
            task.defer(function() task.wait(0.5); AntiDetectedCooldown = false end)
        end
    end)
end)

-- ═══════ ТЁМНО-БЕЛАЯ ТЕМА ═══════
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

-- ═══════ ОКНО RAYFIELD ═══════
local Window = Rayfield:CreateWindow({
    Name = "💀 DMM HUB — v3 FIXED+INVIS",
    Icon = 0,
    LoadingTitle = "💀 DMM HUB v3",
    LoadingSubtitle = "FIXED+INVIS — Невидим для себя!",
    Theme = DarkWhiteTheme,
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true, FolderName = "DMM_HUB",
        FileName = "v3_Invis_Config"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("⭐ Features", 4483362458)

-- ═══════════════════════════════════════
-- 👻 ЛОКАЛЬНАЯ НЕВИДИМОСТЬ (ПЕРВАЯ СЕКЦИЯ)
-- ═══════════════════════════════════════
Tab:CreateSection("👻 Невидимость (только для тебя)")

Tab:CreateParagraph({
    Title = "👻 Как работает",
    Content = "✅ ТЫ не видишь себя\n"
        .. "✅ ДРУГИЕ видят тебя НОРМАЛЬНО\n"
        .. "✅ Скорость/FPS без изменений\n"
        .. "✅ LocalTransparencyModifier = клиент\n"
        .. "✅ Сервер НЕ знает → 0% бана"
})

Tab:CreateToggle({
    Name = "👻 Невидим для себя (другие видят)",
    CurrentValue = false, Flag = "LocalInvis",
    Callback = function(V)
        LocalInvisEnabled = V
        if V then
            StartLocalInvisLoop()
            pcall(function() Rayfield:Notify({
                Title = "👻 Невидимость",
                Content = "ТЫ невидим для себя!\nДругие видят тебя нормально.",
                Duration = 3, Image = 4483362458
            }) end)
        else
            StopLocalInvisLoop()
            pcall(function() Rayfield:Notify({
                Title = "👻 Невидимость",
                Content = "Выключена. Ты снова видишь себя.",
                Duration = 2, Image = 4483362458
            }) end)
        end
    end,
})

-- ═══════ FLY ═══════
Tab:CreateSection("✈️ Летание (Fly)")

local flyBV, flyBG

Tab:CreateToggle({
    Name = "✈️ Fly",
    CurrentValue = false, Flag = "Fly",
    Callback = function(V)
        Flying = V
        if V then
            local hrp = getHRP()
            if not hrp then Flying = false; return end
            pcall(function()
                flyBV = Instance.new("BodyVelocity")
                flyBV.Name = OUR_FLY_BV
                flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Velocity = Vector3.zero
                flyBV.Parent = hrp
                flyBG = Instance.new("BodyGyro")
                flyBG.Name = OUR_FLY_BG
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
    Name = "Fly Speed", Range = {10, 500}, Increment = 5,
    Suffix = " spd", CurrentValue = 50, Flag = "FlySpd",
    Callback = function(V) FlySpeed = V end,
})

-- ═══════ GOD MODE ═══════
Tab:CreateSection("🛡️ God Mode")

Tab:CreateToggle({
    Name = "🛡️ God Mode",
    CurrentValue = false, Flag = "GodMode",
    Callback = function(V)
        GodModeEnabled = V
        if V then task.spawn(function()
            while GodModeEnabled do
                pcall(function()
                    local hum = getHum()
                    if hum then hum.Health = hum.MaxHealth end
                end)
                task.wait(0.1)
            end
        end) end
    end,
})

-- ═══════ SPEED ═══════
Tab:CreateSection("🏃 Speed")

Tab:CreateSlider({
    Name = "Walk Speed", Range = {16, 500}, Increment = 1,
    Suffix = " spd", CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(V)
        pcall(function()
            local hum = getHum()
            if hum then hum.WalkSpeed = V end
        end)
    end,
})

Tab:CreateToggle({
    Name = "⚡ Speed Hack (CFrame)",
    CurrentValue = false, Flag = "SpeedHack",
    Callback = function(V)
        SpeedHackEnabled = V
        if V then task.spawn(function()
            while SpeedHackEnabled do
                RunService.Heartbeat:Wait()
                pcall(function()
                    local hum = getHum(); local hrp = getHRP()
                    if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + hum.MoveDirection * 2
                    end
                end)
            end
        end) end
    end,
})

-- ═══════ ANTI-GRAB ═══════
Tab:CreateSection("🛡️ Anti-Grab [WORKING]")

Tab:CreateToggle({
    Name = "🛡️ Anti-Grab 🔴OP",
    CurrentValue = false, Flag = "AntiGrab",
    Callback = function(V)
        AntiGrabEnabled = V
        if V then PositionHistory = {} end
        pcall(function() Rayfield:Notify({
            Title = "⭐ Anti-Grab",
            Content = V and "АКТИВИРОВАН!" or "Выключен.",
            Duration = 2, Image = 4483362458
        }) end)
    end,
})

-- ═══════ ANTI DETECTED ═══════
Tab:CreateSection("🛡️ Anti Detected [BETA]")

Tab:CreateToggle({
    Name = "Anti Detected [BETA]",
    CurrentValue = false, Flag = "AntiDetected",
    Callback = function(V)
        AntiDetectedEnabled = V
        if V then PositionHistory = {} end
    end,
})

-- ═══════ ANTI ALL v6.9 ═══════
Tab:CreateSection("💛 Anti All Hacks v6.9")

Tab:CreateToggle({
    Name = "Anti All v6.9 ⚡10x",
    CurrentValue = false, Flag = "AntiAllHacks",
    Callback = function(V)
        AntiAllHacksEnabled = V
        if V then
            for _, c in pairs(AntiAllHacksConnections) do
                pcall(function() c:Disconnect() end)
            end
            AntiAllHacksConnections = {}
            local function forceTP()
                if not AntiAllHacksEnabled then return end
                local hrp = getHRP()
                if not hrp then return end
                pcall(function()
                    for _ = 1, 10 do
                        hrp.CFrame = SAFE_POSITION
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                    for _, child in pairs(hrp:GetChildren()) do
                        if isForceType(child) and not isOurObject(child) then
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
        else
            for _, c in pairs(AntiAllHacksConnections) do
                pcall(function() c:Disconnect() end)
            end
            AntiAllHacksConnections = {}
        end
    end,
})

-- ═══════ LOOP RESET ═══════
Tab:CreateSection("💛 Loop Reset ⚡")

Tab:CreateToggle({
    Name = "🔄 Loop Reset",
    CurrentValue = false, Flag = "LoopReset",
    Callback = function(V)
        LoopResetEnabled = V
        if V then task.spawn(function()
            while LoopResetEnabled do
                pcall(function()
                    local hum = getHum()
                    if hum and hum.Health > 0 then hum.Health = 0 end
                end)
                local w = 0
                repeat task.wait(0.05); w = w + 0.05
                until (getHum() and getHum().Health > 0) or w > 10 or not LoopResetEnabled
                task.wait(0.05)
            end
        end) end
    end,
})

-- ═══════ PRO ANTI ALL v3 ═══════
Tab:CreateSection("👑 Pro Anti All v3 — FIXED")

Tab:CreateParagraph({
    Title = "👑 v3 — ЧТО ИСПРАВЛЕНО",
    Content = "❌ УБРАН Anchored (ломал репликацию!)\n"
        .. "✅ BodyPosition + BodyGyro (бесконечная сила)\n"
        .. "✅ CFrame РЕПЛИЦИРУЕТСЯ → другие ВИДЯТ\n"
        .. "✅ Анимации РЕАЛЬНО блокируются\n"
        .. "✅ Sit/Jump цикл ломает Blobman\n"
        .. "✅ Внешние Weld из Workspace удаляются\n"
        .. "━━━━━━━━━━━━━━━━━━━\n"
        .. "Координаты: X:322.31 Y:9.52 Z:489.68"
})

local ProAnimBlockerConn = nil
local ProLastCharSetup   = nil

local function SetupProAnimBlocker(char)
    if not char then return end
    if ProAnimBlockerConn then
        pcall(function() ProAnimBlockerConn:Disconnect() end)
        ProAnimBlockerConn = nil
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then hum = char:WaitForChild("Humanoid", 5) end
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = hum:WaitForChild("Animator", 3) end
    if not animator then return end
    ProAnimBlockerConn = animator.AnimationPlayed:Connect(function(track)
        if not ProAntiAllEnabled then return end
        local animName = ""
        pcall(function()
            animName = track.Animation and track.Animation.Name or ""
        end)
        local safe = isAnimSafe(animName)
        local grab = isAnimGrab(animName)
        local suspiciousPriority = (
            track.Priority == Enum.AnimationPriority.Action
            or track.Priority == Enum.AnimationPriority.Action2
            or track.Priority == Enum.AnimationPriority.Action3
            or track.Priority == Enum.AnimationPriority.Action4
        )
        if grab or (suspiciousPriority and not safe) or (not safe and animName == "") then
            pcall(function() track:Stop(0) end)
            task.defer(function() pcall(function() track:Stop(0) end) end)
            task.delay(0.05, function() pcall(function() track:Stop(0) end) end)
            task.delay(0.1, function() pcall(function() track:Stop(0) end) end)
            task.delay(0.15, function() pcall(function() track:Stop(0) end) end)
            pcall(function()
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = SAFE_POSITION
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end
    end)
end

local function DestroyExternalConnections(char)
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if isConstraintType(v) then
            local p0, p1 = nil, nil
            pcall(function() p0 = v.Part0 end)
            pcall(function() p1 = v.Part1 end)
            if p0 and p1 then
                if not p0:IsDescendantOf(char)
                or not p1:IsDescendantOf(char) then
                    pcall(function() v:Destroy() end)
                end
            end
            local a0, a1 = nil, nil
            pcall(function() a0 = v.Attachment0 end)
            pcall(function() a1 = v.Attachment1 end)
            if a0 and a1 then
                local a0p = a0.Parent
                local a1p = a1.Parent
                if a0p and a1p then
                    if not a0p:IsDescendantOf(char)
                    or not a1p:IsDescendantOf(char) then
                        pcall(function() v:Destroy() end)
                    end
                end
            end
        end
    end
    pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsDescendantOf(char) then continue end
            if v:IsA("Weld") or v:IsA("WeldConstraint")
            or v:IsA("RigidConstraint") then
                local p0, p1 = nil, nil
                pcall(function() p0 = v.Part0 end)
                pcall(function() p1 = v.Part1 end)
                if (p0 and p0:IsDescendantOf(char))
                or (p1 and p1:IsDescendantOf(char)) then
                    pcall(function() v:Destroy() end)
                end
            end
        end
    end)
end

local function DestroyForeignForces(char)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, child in pairs(part:GetChildren()) do
                if isForceType(child) and not isOurObject(child) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local function EnsureBodyPosition(hrp)
    local bp = hrp:FindFirstChild(OUR_BP_NAME)
    if not bp then
        bp = Instance.new("BodyPosition")
        bp.Name = OUR_BP_NAME
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 1e7
        bp.D = 1e5
        bp.Parent = hrp
    end
    bp.Position = SAFE_POSITION.Position
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    return bp
end

local function EnsureBodyGyro(hrp)
    local bg = hrp:FindFirstChild(OUR_BG_NAME)
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = OUR_BG_NAME
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 1e7
        bg.Parent = hrp
    end
    bg.CFrame = SAFE_POSITION
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    return bg
end

Tab:CreateToggle({
    Name = "👑 Pro Anti All v3 ⚡FIXED",
    CurrentValue = false, Flag = "ProAntiAll",
    Callback = function(Value)
        ProAntiAllEnabled = Value
        if Value then
            for _, conn in pairs(ProAntiAllConnections) do
                pcall(function() conn:Disconnect() end)
            end
            ProAntiAllConnections = {}

            pcall(function()
                local char = getChar()
                if char then
                    SetupProAnimBlocker(char)
                    ProLastCharSetup = char
                end
            end)

            local charConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if not ProAntiAllEnabled then return end
                task.wait(0.3)
                SetupProAnimBlocker(newChar)
                ProLastCharSetup = newChar
            end)
            table.insert(ProAntiAllConnections, charConn)

            task.spawn(function()
                while ProAntiAllEnabled do
                    task.wait(0.15)
                    pcall(function()
                        local hum  = getHum()
                        local hrp  = getHRP()
                        local char = getChar()
                        if not hum or not hrp or not char then return end
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end)
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if animator then
                            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                local an = ""
                                pcall(function()
                                    an = track.Animation and track.Animation.Name or ""
                                end)
                                if not isAnimSafe(an) then
                                    pcall(function() track:Stop(0) end)
                                end
                            end
                        end
                        hum.Sit = false
                        hum.PlatformStand = false
                        hum.Jump = true
                        if char ~= ProLastCharSetup then
                            ProLastCharSetup = char
                            SetupProAnimBlocker(char)
                        end
                    end)
                end
            end)

            task.spawn(function()
                while ProAntiAllEnabled do
                    task.wait(0.3)
                    pcall(function()
                        local char = getChar()
                        if char then
                            DestroyExternalConnections(char)
                        end
                    end)
                end
            end)

            local function ultraLock()
                if not ProAntiAllEnabled then return end
                local hrp  = getHRP()
                local hum  = getHum()
                local char = getChar()
                if not hrp or not char then return end
                pcall(function()
                    hrp.Anchored = false
                    EnsureBodyPosition(hrp)
                    EnsureBodyGyro(hrp)
                    for _ = 1, 10 do
                        hrp.CFrame = SAFE_POSITION
                        hrp.AssemblyLinearVelocity  = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end
                    for _, child in pairs(hrp:GetChildren()) do
                        if isForceType(child) and not isOurObject(child) then
                            child:Destroy()
                        end
                    end
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part ~= hrp then
                            part.AssemblyLinearVelocity  = Vector3.zero
                            part.AssemblyAngularVelocity = Vector3.zero
                            for _, child in pairs(part:GetChildren()) do
                                if isForceType(child) and not isOurObject(child) then
                                    child:Destroy()
                                end
                            end
                        end
                    end
                    for _, v in pairs(char:GetDescendants()) do
                        if isConstraintType(v) then
                            local p0, p1 = nil, nil
                            pcall(function() p0 = v.Part0 end)
                            pcall(function() p1 = v.Part1 end)
                            if p0 and p1 then
                                if not p0:IsDescendantOf(char)
                                or not p1:IsDescendantOf(char) then
                                    v:Destroy()
                                end
                            end
                        end
                    end
                    if hum then
                        if hum.SeatPart then
                            if not hum.SeatPart:IsDescendantOf(char) then
                                hum.Jump = true
                                hum.Sit = false
                                pcall(function()
                                    for _, w in pairs(hum.SeatPart:GetChildren()) do
                                        if w:IsA("Weld") or w:IsA("WeldConstraint") then
                                            local wp0, wp1 = nil, nil
                                            pcall(function() wp0 = w.Part0 end)
                                            pcall(function() wp1 = w.Part1 end)
                                            if (wp0 and wp0:IsDescendantOf(char))
                                            or (wp1 and wp1:IsDescendantOf(char)) then
                                                w:Destroy()
                                            end
                                        end
                                    end
                                end)
                            end
                        end
                        hum.PlatformStand = false
                        hum.Sit = false
                        hum.Health = hum.MaxHealth
                    end
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("Fire") or v:IsA("Smoke")
                        or v:IsA("Sparkles") then
                            v:Destroy()
                        end
                    end
                    if hum then
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if animator then
                            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                local an = ""
                                pcall(function()
                                    an = track.Animation
                                        and track.Animation.Name or ""
                                end)
                                if not isAnimSafe(an) then
                                    pcall(function() track:Stop(0) end)
                                end
                            end
                        end
                    end
                    hrp.CFrame = SAFE_POSITION
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.Anchored = false
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
                    Title = "👑 Pro Anti All v3 FIXED",
                    Content = "✅ РАБОТАЕТ!\n✅ BodyPosition/BodyGyro\n✅ Другие ВИДЯТ тебя!",
                    Duration = 5, Image = 4483362458
                })
            end)

        else
            for _, conn in pairs(ProAntiAllConnections) do
                pcall(function() conn:Disconnect() end)
            end
            ProAntiAllConnections = {}
            if ProAnimBlockerConn then
                pcall(function() ProAnimBlockerConn:Disconnect() end)
                ProAnimBlockerConn = nil
            end
            pcall(function()
                local hrp = getHRP()
                if hrp then
                    hrp.Anchored = false
                    local bp = hrp:FindFirstChild(OUR_BP_NAME)
                    if bp then bp:Destroy() end
                    local bg = hrp:FindFirstChild(OUR_BG_NAME)
                    if bg then bg:Destroy() end
                end
            end)
            pcall(function()
                Rayfield:Notify({
                    Title = "👑 Pro Anti All v3",
                    Content = "Выключен.",
                    Duration = 3, Image = 4483362458
                })
            end)
        end
    end,
})

-- ═══════ ЗАГРУЖЕНО ═══════
pcall(function()
    Rayfield:Notify({
        Title = "💀 DMM HUB v3 FIXED+INVIS",
        Content = "✅ ВСЁ ЗАГРУЖЕНО!\n👻 Невидимость для себя ДОБАВЛЕНА!\n👑 Pro Anti All v3 ИСПРАВЛЕН!",
        Duration = 5, Image = 0,
    })
end)

print("═══════════════════════════════════════")
print("  ✅ DMM HUB v3 — FIXED+INVIS!")
print("  👻 Локальная невидимость добавлена")
print("  👑 Pro Anti All v3 работает")
print("═══════════════════════════════════════")
