-- ╔══════════════════════════════════════════════════════════╗
-- ║         DMM HUB — DELTA FIX + ENHANCED PRO ANTI ALL    ║
-- ║  Fly | God Mode | Speed | Anti-Grab (WORKING)           ║
-- ║  Anti Detected | Anti All 6.9 | Auto Reset              ║
-- ║  👑 Pro Anti All v2 — ULTRA IMMOVABLE + ANIM DEFENSE    ║
-- ║  🎨 Dark-White Theme                                     ║
-- ╚══════════════════════════════════════════════════════════╝

-- ═══════ БЕЗОПАСНАЯ ЗАГРУЗКА RAYFIELD ═══════
local Rayfield
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success or not Rayfield then
    local success2, err2 = pcall(function()
        Rayfield = loadstring(game:HttpGet(
            'https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'
        ))()
    end)
    if not success2 or not Rayfield then
        local success3, err3 = pcall(function()
            Rayfield = loadstring(game:HttpGet(
                'https://raw.githubusercontent.com/shlexware/Rayfield/main/source'
            ))()
        end)
        if not success3 or not Rayfield then
            warn("❌ Rayfield не загрузился: "..tostring(err))
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "❌ DMM HUB",
                    Text = "Rayfield не загрузился! Проверь интернет.",
                    Duration = 10
                })
            end)
            return
        end
    end
end
print("✅ Rayfield загружен!")

-- ═══════ СЕРВИСЫ ═══════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")

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

-- ═══════ НОВЫЕ ПЕРЕМЕННЫЕ ДЛЯ PRO ANTI ALL v2 ═══════
local ProAnimBlockerConnection  = nil
local ProAnimCycleThread        = nil
local ProSeatBreakerThread      = nil
local ProStateForceThread       = nil
local ProNetworkSpoofThread     = nil
local ProLastCharSetup          = nil

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
                if hum.SeatPart and not hum.SeatPart:IsDescendantOf(getChar()) then
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
            local lowerName = string.lower(animName)
            local safeAnimations = {
                "idle","walk","run","jump","fall","climb",
                "sit","swim","tool","wave","point","dance",
                "cheer","laugh","tilt","movedirection"
            }
            local isSafe = false
            for _, safeName in ipairs(safeAnimations) do
                if string.find(lowerName, safeName) then isSafe = true; break end
            end
            local grabKeywords = {
                "grab","hold","carry","punch","stun","ragdoll","knock","sleep",
                "drag","pull","throw","slam","choke","bind","tie","capture",
                "arrest","cuff","kill","eat","swallow","consume","caught",
                "trapped","picked","lifted","fling","toss","crush"
            }
            local isGrab = false
            for _, keyword in ipairs(grabKeywords) do
                if string.find(lowerName, keyword) then isGrab = true; break end
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
            if not hum.SeatPart:IsDescendantOf(char) then hum.Jump = true end
            if hum.SeatPart.Parent and hum.SeatPart.Parent.Name:lower():find("blob") then
                hum.Jump = true
            end
        end
        if hum then hum.PlatformStand = false end
        if not Flying and not IsTeleporting then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyForce")
                or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity")
                or v:IsA("BodyPosition") or child:IsA("BodyGyro")
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
        if horizontalSpeed > 18 and timeSinceInput > 0.1 then detected = true end
        if fullSpeed > 50 and timeSinceInput > 0.08 then detected = true end
        if detected then
            AntiDetectedCooldown = true
            local ok = TeleportBack(7)
            if ok then
                pcall(function()
                    Rayfield:Notify({
                        Title = "🛡️ Anti Detected",
                        Content = "⚡ Возврат на 7 сек!",
                        Duration = 3, Image = 4483362458
                    })
                end)
            end
            task.defer(function() task.wait(0.5); AntiDetectedCooldown = false end)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- 👑 PRO ANTI ALL v2 — ФУНКЦИИ ЗАЩИТЫ ОТ BLOBMAN GRAB
-- ═══════════════════════════════════════════════════════════

-- Список ВСЕХ grab/hostile анимаций (расширенный)
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

-- Безопасные анимации (НЕ останавливать)
local SAFE_ANIM_KEYWORDS = {
    "idle", "walk", "run", "jump", "fall", "climb",
    "sit", "swim", "tool", "wave", "point", "dance",
    "cheer", "laugh", "tilt", "movedirection", "land"
}

local function isAnimSafe(animName)
    local ln = string.lower(animName or "")
    if ln == "" then return false end
    for _, s in ipairs(SAFE_ANIM_KEYWORDS) do
        if string.find(ln, s) then return true end
    end
    return false
end

local function isAnimGrab(animName)
    local ln = string.lower(animName or "")
    for _, kw in ipairs(GRAB_ANIM_KEYWORDS) do
        if string.find(ln, kw) then return true end
    end
    return false
end

-- ══════════════════════════════════════════════════════
-- 🔒 [PRO] Функция 1: Реалтайм блокер AnimationPlayed
-- Ловит КАЖДУЮ анимацию в момент запуска и убивает
-- ══════════════════════════════════════════════════════
local function SetupProAnimBlocker(char)
    if not char then return end
    -- Отключаем старый коннект
    if ProAnimBlockerConnection then
        pcall(function() ProAnimBlockerConnection:Disconnect() end)
        ProAnimBlockerConnection = nil
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then hum = char:WaitForChild("Humanoid", 5) end
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = hum:WaitForChild("Animator", 3) end
    if not animator then return end

    ProAnimBlockerConnection = animator.AnimationPlayed:Connect(function(track)
        if not ProAntiAllEnabled then return end

        local animName = ""
        pcall(function()
            animName = track.Animation and track.Animation.Name or ""
        end)

        local animId = ""
        pcall(function()
            animId = track.Animation and track.Animation.AnimationId or ""
        end)

        local safe = isAnimSafe(animName)
        local grab = isAnimGrab(animName)

        -- Подозрительный приоритет (Action и выше)
        local suspiciousPriority = (
            track.Priority == Enum.AnimationPriority.Action
            or track.Priority == Enum.AnimationPriority.Action2
            or track.Priority == Enum.AnimationPriority.Action3
            or track.Priority == Enum.AnimationPriority.Action4
        )

        -- 🔴 УБИВАЕМ: если это граб, или подозрительная + не безопасная
        if grab or (suspiciousPriority and not safe) or (not safe and animName == "") then
            -- Мгновенный стоп
            track:Stop(0)

            -- Дополнительно: стоп через кадр (на случай если переиграют)
            task.defer(function()
                pcall(function() track:Stop(0) end)
            end)
            task.delay(0.05, function()
                pcall(function() track:Stop(0) end)
            end)
            task.delay(0.1, function()
                pcall(function() track:Stop(0) end)
            end)

            -- Принудительный ТП обратно
            pcall(function()
                local hrp = getHRP()
                if hrp then
                    hrp.CFrame = SAFE_POSITION
                    hrp.Anchored = true
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end
    end)
end

-- ══════════════════════════════════════════════════════
-- 🔒 [PRO] Функция 2: Полное уничтожение ВСЕХ связей
-- Расширенный список: Weld, Constraint, Attachment и тд
-- ══════════════════════════════════════════════════════
local function DestroyAllExternalConnections(char)
    if not char then return end

    -- Все типы связей которые могут использоваться для граба
    local connectionTypes = {
        "Weld", "WeldConstraint", "RigidConstraint",
        "BallSocketConstraint", "HingeConstraint",
        "RopeConstraint", "SpringConstraint", "RodConstraint",
        "CylindricalConstraint", "PrismaticConstraint",
        "UniversalConstraint", "NoCollisionConstraint"
    }

    for _, v in pairs(char:GetDescendants()) do
        -- Уничтожаем связи с внешними объектами
        local isConnection = false
        for _, typeName in ipairs(connectionTypes) do
            if v:IsA(typeName) then isConnection = true; break end
        end

        if isConnection then
            local p0, p1 = nil, nil
            pcall(function() p0 = v.Part0 end)
            pcall(function() p1 = v.Part1 end)

            if p0 and p1 then
                if not p0:IsDescendantOf(char) or not p1:IsDescendantOf(char) then
                    pcall(function() v:Destroy() end)
                end
            end

            -- Также проверяем Attachment0/Attachment1 для Constraint
            local a0, a1 = nil, nil
            pcall(function() a0 = v.Attachment0 end)
            pcall(function() a1 = v.Attachment1 end)

            if a0 and a1 then
                local a0Parent = a0.Parent
                local a1Parent = a1.Parent
                if a0Parent and a1Parent then
                    if not a0Parent:IsDescendantOf(char)
                    or not a1Parent:IsDescendantOf(char) then
                        pcall(function() v:Destroy() end)
                    end
                end
            end
        end
    end

    -- Уничтожаем внешние Weld/Constraint которые ССЫЛАЮТСЯ на наши части
    -- (находятся вне нашего персонажа но привязаны к нам)
    pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsDescendantOf(char) then continue end

            local isConn = v:IsA("Weld") or v:IsA("WeldConstraint")
                or v:IsA("RigidConstraint") or v:IsA("BallSocketConstraint")

            if isConn then
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

-- ══════════════════════════════════════════════════════
-- 🔒 [PRO] Функция 3: Убийство ВСЕХ сил со ВСЕХ частей
-- ══════════════════════════════════════════════════════
local function DestroyAllForces(char)
    if not char then return end
    local forceTypes = {
        "BodyVelocity", "BodyForce", "BodyThrust",
        "BodyAngularVelocity", "BodyPosition", "BodyGyro",
        "LinearVelocity", "VectorForce", "AlignPosition",
        "AlignOrientation", "LineForce", "Torque"
    }
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
            part.Massless = true
            for _, child in pairs(part:GetChildren()) do
                for _, ft in ipairs(forceTypes) do
                    if child:IsA(ft) then
                        pcall(function() child:Destroy() end)
                        break
                    end
                end
            end
        end
    end
end

-- ═══════════════════════════════════════
-- 🎨 ТЁМНО-БЕЛАЯ ТЕМА
-- ═══════════════════════════════════════
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
-- ОКНО RAYFIELD
-- ═══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "💀 DMM HUB — Pro Features v2",
    Icon = 0,
    LoadingTitle = "💀 DMM HUB",
    LoadingSubtitle = "Loading Pro Features...",
    Theme = DarkWhiteTheme,
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DMM_HUB",
        FileName = "ProFeat_Config"
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
    CurrentValue = false, Flag = "Fly",
    Callback = function(V)
        Flying = V
        if V then
            local hrp = getHRP()
            if not hrp then Flying = false; return end
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
    Name = "Fly Speed", Range = {10, 500}, Increment = 5,
    Suffix = " spd", CurrentValue = 50, Flag = "FlySpd",
    Callback = function(V) FlySpeed = V end,
})

-- ╔═══════════════════════════╗
-- ║      🛡️ GOD MODE          ║
-- ╚═══════════════════════════╝
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

-- ╔═══════════════════════════╗
-- ║       🏃 SPEED            ║
-- ╚═══════════════════════════╝
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

-- ╔═══════════════════════════════════════╗
-- ║   🛡️ ANTI-GRAB [WORKING]             ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("🛡️ Anti-Grab [WORKING]")

Tab:CreateParagraph({
    Title = "⭐ Anti-Grab Info",
    Content = "Трекер grab-анимаций + откат 3 сек\nРазрыв Weld + удаление сил\nВыход из сидений + анти-ragdoll"
})

Tab:CreateToggle({
    Name = "🛡️ Anti-Grab [WORKING] 🔴OP",
    CurrentValue = false, Flag = "AntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then
            PositionHistory = {}
            pcall(function() Rayfield:Notify({
                Title = "⭐ Anti-Grab", Content = "АКТИВИРОВАН!",
                Duration = 3, Image = 4483362458
            }) end)
        else
            pcall(function() Rayfield:Notify({
                Title = "⭐ Anti-Grab", Content = "Выключен.",
                Duration = 2, Image = 4483362458
            }) end)
        end
    end,
})

-- ╔═══════════════════════════════════════╗
-- ║   🛡️ ANTI DETECTED [BETA]            ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("🛡️ Anti Detected [BETA]")

Tab:CreateToggle({
    Name = "Anti Detected [BETA]",
    CurrentValue = false, Flag = "AntiDetected",
    Callback = function(Value)
        AntiDetectedEnabled = Value
        if Value then
            PositionHistory = {}
            pcall(function() Rayfield:Notify({
                Title = "⭐ Anti Detected", Content = "АКТИВИРОВАН!",
                Duration = 3, Image = 4483362458
            }) end)
        end
    end,
})

-- ╔═══════════════════════════════════════╗
-- ║   💛 ANTI ALL HACKS v6.9             ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("💛 Anti All Hacks v6.9")

Tab:CreateToggle({
    Name = "Anti All Hacks v6.9 ⚡ULTRA 10x",
    CurrentValue = false, Flag = "AntiAllHacks",
    Callback = function(Value)
        AntiAllHacksEnabled = Value
        if Value then
            for _, c in pairs(AntiAllHacksConnections) do pcall(function() c:Disconnect() end) end
            AntiAllHacksConnections = {}
            local function forceTP()
                if not AntiAllHacksEnabled then return end
                local hrp = getHRP(); if not hrp then return end
                pcall(function()
                    for _ = 1, 10 do
                        hrp.CFrame = SAFE_POSITION
                        hrp.AssemblyLinearVelocity = Vector3.zero
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
            table.insert(AntiAllHacksConnections, RunService.RenderStepped:Connect(forceTP))
            table.insert(AntiAllHacksConnections, RunService.Heartbeat:Connect(forceTP))
            table.insert(AntiAllHacksConnections, RunService.Stepped:Connect(function() forceTP() end))
            pcall(function() Rayfield:Notify({
                Title = "⭐ Anti All v6.9", Content = "⚡10x × 3 потока!",
                Duration = 4, Image = 4483362458
            }) end)
        else
            for _, c in pairs(AntiAllHacksConnections) do pcall(function() c:Disconnect() end) end
            AntiAllHacksConnections = {}
        end
    end,
})

-- ╔═══════════════════════════════════════╗
-- ║   💛 LOOP RESET                       ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("💛 Loop Reset ⚡")

Tab:CreateToggle({
    Name = "🔄 Loop Reset ⚡ULTRA FAST",
    CurrentValue = false, Flag = "LoopReset",
    Callback = function(Value)
        LoopResetEnabled = Value
        if Value then
            task.spawn(function()
                while LoopResetEnabled do
                    pcall(function()
                        local hum = getHum()
                        if hum and hum.Health > 0 then hum.Health = 0 end
                    end)
                    if LoopResetEnabled then
                        local w = 0
                        repeat task.wait(0.05); w = w + 0.05
                        until (getHum() and getHum().Health > 0) or w > 10 or not LoopResetEnabled
                        task.wait(0.05)
                    end
                end
            end)
        end
    end,
})

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║   👑 PRO VERSION ANTI ALL v2 — ULTRA IMMOVABLE              ║
-- ║                                                               ║
-- ║   🆕 НОВОЕ:                                                   ║
-- ║   🔒 Реалтайм блокер ВСЕХ grab-анимаций                      ║
-- ║   🔄 Цикл анимаций каждые 0.3с (ломает граб Blobman)        ║
-- ║   🪑 Быстрый Sit→Jump цикл (ломает захват сидения)          ║
-- ║   🔧 Принудительный HumanoidState (блок состояния граба)     ║
-- ║   👻 Сетевой CFrame спуф (для других видно что ты на месте) ║
-- ║   💀 Уничтожение ВНЕШНИХ связей из Workspace                 ║
-- ║   🛡️ Блок Fire/Smoke/Sparkles/Trail эффектов                ║
-- ║                                                               ║
-- ║   + ВСЁ СТАРОЕ:                                               ║
-- ║   1000x TP | Anchor Lock | Force Kill | Weld Break           ║
-- ║   Seat Eject | Anti-Ragdoll | God Mode | Massless            ║
-- ╚═══════════════════════════════════════════════════════════════╝
Tab:CreateSection("👑 Pro Anti All v2 — ULTRA")

Tab:CreateParagraph({
    Title = "👑 Pro Anti All v2 — ЧТО НОВОГО",
    Content = "🔒 Реалтайм блокер ВСЕХ grab-анимаций\n"
        .. "🔄 Цикл анимаций 0.3с (ломает Blobman граб)\n"
        .. "🪑 Быстрый Sit→Jump (ломает захват сидения)\n"
        .. "🔧 Принудительный HumanoidState\n"
        .. "👻 Для других видно что ты НА МЕСТЕ\n"
        .. "💀 Уничтожение связей из Workspace\n"
        .. "🛡️ Блок эффектов Fire/Smoke/Trail\n"
        .. "━━━━━━━━━━━━━━━━━━━\n"
        .. "1000x TP × 3 потока | Anchor Lock\n"
        .. "God Mode | Massless | Anti-Ragdoll\n"
        .. "X:322.31 Y:9.52 Z:489.68"
})

Tab:CreateToggle({
    Name = "👑 Pro Anti All v2 ⚡IMMOVABLE",
    CurrentValue = false, Flag = "ProAntiAll",
    Callback = function(Value)
        ProAntiAllEnabled = Value

        if Value then
            -- ═══ Отключаем старые коннекты ═══
            for _, conn in pairs(ProAntiAllConnections) do
                pcall(function() conn:Disconnect() end)
            end
            ProAntiAllConnections = {}
            if ProAnimBlockerConnection then
                pcall(function() ProAnimBlockerConnection:Disconnect() end)
                ProAnimBlockerConnection = nil
            end

            -- ══════════════════════════════════════════
            -- 🔒 ПОТОК 1: Реалтайм блокер анимаций
            -- Подключается к AnimationPlayed и убивает
            -- grab-анимации В МОМЕНТ ЗАПУСКА
            -- ══════════════════════════════════════════
            pcall(function()
                local char = getChar()
                if char then SetupProAnimBlocker(char) end
            end)

            -- Авто-переподключение при респавне
            local charAddedConn
            charAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if not ProAntiAllEnabled then
                    pcall(function() charAddedConn:Disconnect() end)
                    return
                end
                task.wait(0.3)
                SetupProAnimBlocker(newChar)
                ProLastCharSetup = newChar
            end)
            table.insert(ProAntiAllConnections, charAddedConn)

            -- ══════════════════════════════════════════════
            -- 🔄 ПОТОК 2: Цикл анимаций каждые 0.3 сек
            -- Останавливает ВСЕ подозрительные анимации
            -- + Принудительный HumanoidState
            -- + Sit/Jump цикл для ломки граба
            -- ══════════════════════════════════════════════
            ProAnimCycleThread = task.spawn(function()
                while ProAntiAllEnabled do
                    task.wait(0.3)
                    pcall(function()
                        local hum = getHum()
                        local hrp = getHRP()
                        local char = getChar()
                        if not hum or not hrp or not char then return end

                        -- 🔧 Принудительный HumanoidState
                        -- Сбрасываем граб-состояния
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        end)
                        task.wait(0.02)
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                        end)

                        -- 🔄 Стоп ВСЕХ подозрительных анимаций
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if animator then
                            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                local an = ""
                                pcall(function()
                                    an = track.Animation and track.Animation.Name or ""
                                end)
                                if not isAnimSafe(an) then
                                    track:Stop(0)
                                end
                            end
                        end

                        -- 🪑 Sit → Jump цикл (ломает граб Blobman)
                        -- Кратковременно снимаем anchor для jump
                        pcall(function()
                            hrp.Anchored = false
                            hum.Sit = false
                            hum.PlatformStand = false
                            hum.Jump = true
                        end)
                        task.wait(0.02)
                        -- Сразу обратно anchor + TP
                        pcall(function()
                            hrp.CFrame = SAFE_POSITION
                            hrp.Anchored = true
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end)

                        -- 🔒 Проверяем и переподключаем AnimBlocker
                        if char ~= ProLastCharSetup then
                            ProLastCharSetup = char
                            SetupProAnimBlocker(char)
                        end
                    end)
                end
            end)

            -- ══════════════════════════════════════════════════
            -- 👻 ПОТОК 3: Сетевой спуф + доп. защита (0.5 сек)
            -- Уничтожает ВНЕШНИЕ связи из Workspace
            -- Другие видят тебя на SAFE_POSITION
            -- ══════════════════════════════════════════════════
            ProNetworkSpoofThread = task.spawn(function()
                while ProAntiAllEnabled do
                    task.wait(0.5)
                    pcall(function()
                        local char = getChar()
                        local hrp = getHRP()
                        local hum = getHum()
                        if not char or not hrp then return end

                        -- 💀 Уничтожаем ВНЕШНИЕ связи из Workspace
                        -- (связи которые ДРУГИЕ игроки создали к нам)
                        DestroyAllExternalConnections(char)

                        -- 👻 Для сети: Кратко unanchor → set CFrame → anchor
                        -- Это заставляет сервер обновить позицию
                        hrp.Anchored = false
                        hrp.CFrame = SAFE_POSITION
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        task.wait(0.02)
                        hrp.CFrame = SAFE_POSITION
                        hrp.Anchored = true

                        -- Выход из ЛЮБОГО сидения
                        if hum then
                            if hum.SeatPart then
                                hum.Jump = true
                                hum.Sit = false
                                -- Ломаем SeatWeld напрямую
                                pcall(function()
                                    if hum.SeatPart then
                                        for _, w in pairs(hum.SeatPart:GetChildren()) do
                                            if w:IsA("Weld") or w:IsA("WeldConstraint") then
                                                local p0 = w.Part0
                                                local p1 = w.Part1
                                                if (p0 and p0:IsDescendantOf(char))
                                                or (p1 and p1:IsDescendantOf(char)) then
                                                    w:Destroy()
                                                end
                                            end
                                        end
                                    end
                                end)
                            end
                        end
                    end)
                end
            end)

            -- ════════════════════════════════════════════════════════
            -- ⚡ ОСНОВНОЙ ПОТОК: ultraLock (RenderStepped + Heartbeat
            --    + Stepped) — 1000x TP + полная защита КАЖДЫЙ КАДР
            -- ════════════════════════════════════════════════════════
            local function ultraLock()
                if not ProAntiAllEnabled then return end
                local hrp  = getHRP()
                local hum  = getHum()
                local char = getChar()
                if not hrp or not char then return end

                pcall(function()
                    -- ══ 1000x TP + Zero Velocity ══
                    for _ = 1, 1000 do
                        hrp.CFrame = SAFE_POSITION
                        hrp.AssemblyLinearVelocity  = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end

                    -- ══ ANCHOR LOCK ══
                    hrp.Anchored = true
                    hrp.CFrame   = SAFE_POSITION

                    -- ══ Удаление ВСЕХ сил с HRP ══
                    DestroyAllForces(char)

                    -- ══ Разрыв ВСЕХ внешних связей ══
                    for _, v in pairs(char:GetDescendants()) do
                        if (v:IsA("Weld") or v:IsA("WeldConstraint")
                        or v:IsA("RigidConstraint")
                        or v:IsA("BallSocketConstraint")
                        or v:IsA("HingeConstraint")
                        or v:IsA("RopeConstraint")
                        or v:IsA("SpringConstraint")
                        or v:IsA("RodConstraint"))
                        and v.Part0 and v.Part1 then
                            if not v.Part0:IsDescendantOf(char)
                            or not v.Part1:IsDescendantOf(char) then
                                v:Destroy()
                            end
                        end
                    end

                    -- ══ Выход из чужих сидений ══
                    if hum and hum.SeatPart
                    and not hum.SeatPart:IsDescendantOf(char) then
                        hum.Jump = true
                        hum.Sit = false
                    end

                    -- ══ Anti-Ragdoll + God Mode ══
                    if hum then
                        hum.PlatformStand = false
                        hum.Health = hum.MaxHealth
                    end

                    -- ══ Anti-Effects ══
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("Fire") or v:IsA("Smoke")
                        or v:IsA("Sparkles") or v:IsA("Trail")
                        or v:IsA("ParticleEmitter") then
                            -- Не удаляем стандартные Trail от аксессуаров
                            if v:IsA("Trail") then
                                if v.Parent and not v.Parent:IsA("Accessory") then
                                    v:Destroy()
                                end
                            else
                                v:Destroy()
                            end
                        end
                    end

                    -- ══ Стоп ВСЕХ подозрительных анимаций (КАЖДЫЙ КАДР) ══
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
                                    track:Stop(0)
                                end
                            end
                        end
                    end

                    -- ══ ФИНАЛЬНЫЙ ЛОК ══
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    hrp.CFrame   = SAFE_POSITION
                    hrp.Anchored = true
                end)
            end

            -- Подключаем к 3 потокам
            table.insert(ProAntiAllConnections,
                RunService.RenderStepped:Connect(ultraLock))
            table.insert(ProAntiAllConnections,
                RunService.Heartbeat:Connect(ultraLock))
            table.insert(ProAntiAllConnections,
                RunService.Stepped:Connect(function() ultraLock() end))

            pcall(function()
                Rayfield:Notify({
                    Title = "👑 Pro Anti All v2",
                    Content = "⚡ ULTRA IMMOVABLE!\n"
                        .. "🔒 Реалтайм блокер анимаций\n"
                        .. "🔄 Цикл 0.3с + Sit/Jump\n"
                        .. "👻 Сетевой спуф позиции\n"
                        .. "1000x TP × 3 потока!",
                    Duration = 6, Image = 4483362458
                })
            end)

        else
            -- ═══ ВЫКЛЮЧЕНИЕ ═══
            for _, conn in pairs(ProAntiAllConnections) do
                pcall(function() conn:Disconnect() end)
            end
            ProAntiAllConnections = {}

            if ProAnimBlockerConnection then
                pcall(function() ProAnimBlockerConnection:Disconnect() end)
                ProAnimBlockerConnection = nil
            end

            -- Снимаем anchor и massless
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
                    Title = "👑 Pro Anti All v2",
                    Content = "Выключен. Anchor снят.\nВсе потоки остановлены.",
                    Duration = 3, Image = 4483362458
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
        Title = "💀 DMM HUB v2 — Delta",
        Content = "✅ ВСЁ ЗАГРУЖЕНО!\n"
            .. "👑 Pro Anti All v2 — ULTRA\n"
            .. "🎨 Dark-White Theme",
        Duration = 5, Image = 0,
    })
end)

print("═══════════════════════════════════════")
print("  ✅ DMM HUB v2 — Loaded!")
print("  👑 Pro Anti All v2 — ULTRA IMMOVABLE")
print("  🔒 Realtime Anim Blocker")
print("  🔄 Anim Cycle 0.3s")
print("  🪑 Sit/Jump Grab Breaker")
print("  👻 Network CFrame Spoof")
print("  💀 External Weld Destroyer")
print("═══════════════════════════════════════")
