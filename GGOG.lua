

```lua
-- ╔══════════════════════════════════════════════════════════╗
-- ║         DMM HUB — Extracted Features                     ║
-- ║  Fly | God Mode | Speed | Anti-Grab (WORKING)           ║
-- ║  Anti Detected | Anti All 6.9 | Auto Reset              ║
-- ║  👑 Pro Version Anti All — IMMOVABLE                     ║
-- ╚══════════════════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
    local c = getChar(); if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local c = getChar(); if not c then return nil end
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
    [Enum.KeyCode.W]=true, [Enum.KeyCode.A]=true,
    [Enum.KeyCode.S]=true, [Enum.KeyCode.D]=true,
    [Enum.KeyCode.Space]=true, [Enum.KeyCode.LeftShift]=true,
}
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if MovementKeys[input.KeyCode] then LastInputTime = tick() end
    end
end)

-- ═══════ ЗАПИСЬ ИСТОРИИ ПОЗИЦИЙ ═══════
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    if not AntiGrabEnabled and not AntiDetectedEnabled then PositionHistory = {}; return end
    if Flying or IsTeleporting then return end
    local hrp = getHRP(); if not hrp then return end
    pcall(function()
        table.insert(PositionHistory, 1, {Time=tick(), CFrame=hrp.CFrame, Velocity=hrp.AssemblyLinearVelocity})
        local now = tick()
        for i = #PositionHistory, 1, -1 do
            if now - PositionHistory[i].Time > 8.5 then table.remove(PositionHistory, i) end
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
    if not closest and #PositionHistory > 0 then closest = PositionHistory[#PositionHistory] end
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
                if child:IsA("BodyVelocity") or child:IsA("BodyForce") or child:IsA("BodyThrust")
                or child:IsA("BodyAngularVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro")
                or child:IsA("LinearVelocity") or child:IsA("VectorForce") then child:Destroy() end
            end
        end)
        pcall(function()
            local char = getChar()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if (v:IsA("Weld") or v:IsA("WeldConstraint")) and v.Part0 and v.Part1 then
                        if not v.Part0:IsDescendantOf(char) or not v.Part1:IsDescendantOf(char) then v:Destroy() end
                    end
                end
            end
        end)
        pcall(function()
            local hum = getHum()
            if hum then
                hum.PlatformStand = false
                if hum.SeatPart and not hum.SeatPart:IsDescendantOf(getChar()) then hum.Jump = true end
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
                end
            end
        end)
        task.defer(function() task.wait(0.4); IsTeleporting = false end)
        return true
    end
    return false
end

-- ═══════ ANTI-GRAB: ТРЕКЕР АНИМАЦИЙ + АВТО-РЕФРЕШ ═══════
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
                track.Priority == Enum.AnimationPriority.Action  or
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

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    _lastTrackedChar = char
    SetupAntiGrabAnimTracker(char)
end)
if getChar() then
    _lastTrackedChar = getChar()
    SetupAntiGrabAnimTracker(getChar())
end

-- ═══════ ANTI-GRAB: HEARTBEAT (Weld+Force+Seat+Ragdoll) ═══════
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    if not AntiGrabEnabled then return end
    pcall(function()
        local char = getChar()
        local hum  = getHum()
        local hrp  = getHRP()
        if not char or not hrp then return end

        -- Разрыв внешних Weld (ВСЕГДА)
        for _, v in pairs(char:GetDescendants()) do
            if (v:IsA("Weld") or v:IsA("WeldConstraint")) and v.Part0 and v.Part1 then
                if not v.Part0:IsDescendantOf(char) or not v.Part1:IsDescendantOf(char) then
                    v:Destroy()
                end
            end
        end

        -- Выход из чужих сидений (ВСЕГДА)
        if hum and hum.SeatPart then
            if not hum.SeatPart:IsDescendantOf(char) then hum.Jump = true end
            if hum.SeatPart.Parent and hum.SeatPart.Parent.Name:lower():find("blob") then hum.Jump = true end
        end

        -- Анти-ragdoll (ВСЕГДА)
        if hum then hum.PlatformStand = false end

        -- Удаление сил + скорости (ТОЛЬКО не в полёте)
        if not Flying and not IsTeleporting then
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust")
                or v:IsA("BodyAngularVelocity") or v:IsA("BodyPosition") or v:IsA("BodyGyro")
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

-- ═══════ ANTI DETECTED HEARTBEAT (точная копия) ═══════
RunService.Heartbeat:Connect(function()
    if not _alive then return end
    if not AntiDetectedEnabled then return end
    if Flying or IsTeleporting or AntiDetectedCooldown then return end
    local hrp = getHRP(); if not hrp then return end
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
            local success = TeleportBack(7)
            if success then
                Rayfield:Notify({
                    Title = "🛡️ Anti Detected [BETA]",
                    Content = "⚡ Принудительное перемещение!\nВозврат на 7 секунд назад.",
                    Duration = 3, Image = 4483362458
                })
            end
            task.defer(function() task.wait(0.5); AntiDetectedCooldown = false end)
        end
    end)
end)

-- ═══════════════════════════════════════
-- ОКНО RAYFIELD
-- ═══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "💀 DMM HUB — Features",
    Icon = 0,
    LoadingTitle = "DMM HUB",
    LoadingSubtitle = "Loading Features...",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {Enabled=true, FolderName="DMM_HUB", FileName="Feat_Config"},
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
            local hrp = getHRP(); if not hrp then return end
            flyBV = Instance.new("BodyVelocity")
            flyBV.Name = "_DMM_FlyBV"
            flyBV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.Name = "_DMM_FlyBG"
            flyBG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
            flyBG.P = 9e4
            flyBG.Parent = hrp
            task.spawn(function()
                while Flying do RunService.Heartbeat:Wait()
                    pcall(function()
                        local cam = Workspace.CurrentCamera
                        local hum = getHum()
                        if hum and hum.MoveDirection.Magnitude > 0 then
                            flyBV.Velocity = cam.CFrame.LookVector * FlySpeed
                        else flyBV.Velocity = Vector3.zero end
                        flyBG.CFrame = cam.CFrame
                    end)
                end
            end)
        else
            pcall(function() flyBV:Destroy() end)
            pcall(function() flyBG:Destroy() end)
        end
    end,
})

Tab:CreateSlider({
    Name="Fly Speed", Range={10,500}, Increment=5, Suffix="spd",
    CurrentValue=50, Flag="FlySpd",
    Callback=function(V) FlySpeed=V end
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
                pcall(function() local hum=getHum(); if hum then hum.Health=hum.MaxHealth end end)
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
    Name="Walk Speed", Range={16,500}, Increment=1, Suffix="spd",
    CurrentValue=16, Flag="WalkSpeed",
    Callback=function(V)
        pcall(function() local hum=getHum(); if hum then hum.WalkSpeed=V end end)
    end
})

Tab:CreateToggle({
    Name = "⚡ Speed Hack (CFrame)",
    CurrentValue = false, Flag = "SpeedHack",
    Callback = function(V)
        SpeedHackEnabled = V
        if V then task.spawn(function()
            while SpeedHackEnabled do RunService.Heartbeat:Wait()
                pcall(function()
                    local hum=getHum(); local hrp=getHRP()
                    if hum and hrp and hum.MoveDirection.Magnitude>0 then
                        hrp.CFrame = hrp.CFrame + hum.MoveDirection*2
                    end
                end)
            end
        end) end
    end,
})

-- ╔═══════════════════════════════════════╗
-- ║   🛡️ ANTI-GRAB [WORKING] 🔴OP       ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("🛡️ Anti-Grab [WORKING]")

Tab:CreateParagraph({
    Title = "⭐ Anti-Grab Info",
    Content = "• Трекер grab-анимаций + откат 3 сек\n• Разрыв внешних Weld/WeldConstraint\n• Удаление BodyVelocity/Force и др.\n• Выход из чужих сидений + Blobman\n• Отмена скорости >300\n• Анти-ragdoll (PlatformStand)"
})

Tab:CreateToggle({
    Name = "🛡️ Anti-Grab [WORKING] 🔴OP",
    CurrentValue = false, Flag = "AntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then
            PositionHistory = {}
            Rayfield:Notify({Title="⭐ Anti-Grab", Content="АКТИВИРОВАН!\nПолная защита от захватов.", Duration=3, Image=4483362458})
        else
            Rayfield:Notify({Title="⭐ Anti-Grab", Content="Выключен.", Duration=2, Image=4483362458})
        end
    end,
})

-- ╔═══════════════════════════════════════╗
-- ║   🛡️ ANTI DETECTED [BETA] (копия)    ║
-- ╚═══════════════════════════════════════╝
Tab:CreateSection("🛡️ Anti Detected [BETA Hacker]")

Tab:CreateParagraph({
    Title = "⭐ Anti Detected Info",
    Content = "Отслеживает принудительное перемещение.\nОткат на 7 сек назад. Защита от Fling, Kick, Velocity."
})

Tab:CreateToggle({
    Name = "Anti Detected [BETA Hacker]",
    CurrentValue = false, Flag = "AntiDetected",
    Callback = function(Value)
        AntiDetectedEnabled = Value
        if Value then
            PositionHistory = {}
            Rayfield:Notify({Title="⭐ Legend OP", Content="Anti Detected АКТИВИРОВАН!", Duration=3, Image=4483362458})
        else
            Rayfield:Notify({Title="⭐ Legend OP", Content="Anti Detected выключен.", Duration=2, Image=4483362458})
        end
    end,
})

-- ╔═══════════════════════════════════════════════════╗
-- ║   💛 ANTI ALL HACKS v6.9 (точная копия, без      ║
-- ║      изменений, скопировано как есть)              ║
-- ╚═══════════════════════════════════════════════════╝
Tab:CreateSection("💛 Anti All Hacks v6.9")

Tab:CreateParagraph({
    Title = "⭐ Anti All Hacks v6.9 Info",
    Content = "10x ТП КАЖДЫЙ КАДР на безопасную позицию.\nX:322.31 Y:9.52 Z:489.68\n3 потока: RenderStepped + Heartbeat + Stepped"
})

Tab:CreateToggle({
    Name = "Anti All Hacks v6.9 ⚡ULTRA 10x",
    CurrentValue = false, Flag = "AntiAllHacks",
    Callback = function(Value)
        AntiAllHacksEnabled = Value
        if Value then
            for _, conn in pairs(AntiAllHacksConnections) do pcall(function() conn:Disconnect() end) end
            AntiAllHacksConnections = {}
            local function forceTP()
                if not AntiAllHacksEnabled then return end
                local hrp = getHRP()
                if not hrp then return end
                for _i = 1, 10 do
                    hrp.CFrame = SAFE_POSITION
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                for _, child in pairs(hrp:GetChildren()) do
                    if child:IsA("BodyVelocity") or child:IsA("BodyForce") or child:IsA("BodyThrust")
                    or child:IsA("BodyAngularVelocity") or child:IsA("BodyPosition") or child:IsA("BodyGyro")
                    or child:IsA("LinearVelocity") or child:IsA("VectorForce") then child:Destroy() end
                end
            end
            table.insert(AntiAllHacksConnections, RunService.RenderStepped:Connect(forceTP))
            table.insert(AntiAllHacksConnections, RunService.Heartbeat:Connect(forceTP))
            table.insert(AntiAllHacksConnections, RunService.Stepped:Connect(function() forceTP() end))
            Rayfield:Notify({Title="⭐ Legend OP", Content="Anti All Hacks v6.9 ⚡ULTRA\n10x ТП × 3 потока!", Duration=4, Image=4483362458})
        else
            for _, conn in pairs(AntiAllHacksConnections) do pcall(function() conn:Disconnect() end) end
            AntiAllHacksConnections = {}
            Rayfield:Notify({Title="⭐ Legend OP", Content="Anti All Hacks v6.9 выключен.", Duration=2, Image=4483362458})
        end
    end,
})

-- ╔═══════════════════════════════════════════════════╗
-- ║   💛 LOOP RESET ⚡ (точная копия)                 ║
-- ╚═══════════════════════════════════════════════════╝
Tab:CreateSection("💛 Loop Reset ⚡")

Tab:CreateParagraph({
    Title = "⭐ Loop Reset Info",
    Content = "Ультра-быстрый ресет персонажа.\nМгновенная смерть → респавн → снова."
})

Tab:CreateToggle({
    Name = "🔄 Loop Reset ⚡ULTRA FAST",
    CurrentValue = false, Flag = "LoopReset",
    Callback = function(Value)
        LoopResetEnabled = Value
        if Value then
            Rayfield:Notify({Title="⭐ Legend OP", Content="Loop Reset АКТИВИРОВАН!", Duration=3, Image=4483362458})
            task.spawn(function()
                while LoopResetEnabled do
                    pcall(function()
                        local hum = getHum()
                        if hum and hum.Health > 0 then hum.Health = 0 end
                    end)
                    if LoopResetEnabled then
                        local waited = 0
                        repeat
                            task.wait(0.05); waited = waited + 0.05
                            local hum = getHum()
                        until (hum and hum.Health > 0) or waited > 10 or not LoopResetEnabled
                        task.wait(0.05)
                    end
                end
            end)
        else
            Rayfield:Notify({Title="⭐ Legend OP", Content="Loop Reset выключен.", Duration=2, Image=4483362458})
        end
    end,
})

-- ╔═══════════════════════════════════════════════════════════╗
-- ║   👑 PRO VERSION ANTI ALL — IMMOVABLE                     ║
-- ║   1000x TP × 3 потока | Anchor Lock | Force Kill         ║
-- ║   Weld Break | Seat Eject | Anti-Ragdoll | Anim Block    ║
-- ║   God Mode | Massless | Anti-Effects | Velocity Zero     ║
-- ╚═══════════════════════════════════════════════════════════╝
Tab:CreateSection("👑 Pro Version Anti All")

Tab:CreateParagraph({
    Title = "👑 Pro Anti All",
    Content = "1000x TP/кадр × 3 потока\nAnchor+CFrame Lock намертво\nForce Kill+Weld Break\nSeat Eject+Anti-Ragdoll\nAnim Block+God Mode\nMassless+Anti-Effects\nX:322.31 Y:9.52 Z:489.68"
})

Tab:CreateToggle({
    Name = "👑 Pro Anti All ⚡IMMOVABLE",
    CurrentValue = false, Flag = "ProAntiAll",
    Callback = function(Value)
        ProAntiAllEnabled = Value
        if Value then
            for _, conn in pairs(ProAntiAllConnections) do pcall(function() conn:Disconnect() end) end
            ProAntiAllConnections = {}

            local function ultraLock()
                if not ProAntiAllEnabled then return end
                local hrp  = getHRP()
                local hum  = getHum()
                local char = getChar()
                if not hrp or not char then return end

                -- ══ 1000x TP + Zero Velocity ══
                for _i = 1, 1000 do
                    hrp.CFrame = SAFE_POSITION
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end

                -- ══ ANCHOR LOCK (как AnchorPart, намертво) ══
                hrp.Anchored = true
                hrp.CFrame   = SAFE_POSITION

                -- ══ Удаление ВСЕХ сил с HRP ══
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

                -- ══ Удаление сил + Massless + Zero Velocity со ВСЕХ частей ══
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

                -- ══ Разрыв ВСЕХ внешних Weld/Constraint ══
                for _, v in pairs(char:GetDescendants()) do
                    if (v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("RigidConstraint")
                    or v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint")
                    or v:IsA("RopeConstraint") or v:IsA("SpringConstraint")
                    or v:IsA("RodConstraint")) and v.Part0 and v.Part1 then
                        if not v.Part0:IsDescendantOf(char) or not v.Part1:IsDescendantOf(char) then
                            v:Destroy()
                        end
                    end
                end

                -- ══ Выход из чужих сидений ══
                if hum and hum.SeatPart and not hum.SeatPart:IsDescendantOf(char) then
                    hum.Jump = true
                end

                -- ══ Anti-Ragdoll + God Mode ══
                if hum then
                    hum.PlatformStand = false
                    hum.Health = hum.MaxHealth
                end

                -- ══ Anti-Effects (Fire/Smoke/Sparkles) ══
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        v:Destroy()
                    end
                end

                -- ══ Стоп grab-анимаций ══
                pcall(function()
                    if hum then
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if animator then
                            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                local an = ""
                                pcall(function() an = track.Animation and track.Animation.Name or "" end)
                                local ln = string.lower(an)
                                local safe = false
                                for _, s in ipairs({"idle","walk","run","jump","fall","climb","sit","swim"}) do
                                    if string.find(ln, s) then safe = true; break end
                                end
                                if not safe then track:Stop(0) end
                            end
                        end
                    end
                end)

                -- ══ ФИНАЛЬНЫЙ ЛОК (после всего) ══
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.CFrame   = SAFE_POSITION
                hrp.Anchored = true
            end

            table.insert(ProAntiAllConnections, RunService.RenderStepped:Connect(ultraLock))
            table.insert(ProAntiAllConnections, RunService.Heartbeat:Connect(ultraLock))
            table.insert(ProAntiAllConnections, RunService.Stepped:Connect(function() ultraLock() end))

            Rayfield:Notify({
                Title = "👑 Pro Anti All",
                Content = "⚡ IMMOVABLE!\n1000x TP × 3 потока\nAnchor-Lock + Full Protection!",
                Duration = 5, Image = 4483362458
            })
        else
            for _, conn in pairs(ProAntiAllConnections) do pcall(function() conn:Disconnect() end) end
            ProAntiAllConnections = {}
            pcall(function()
                local hrp = getHRP()
                if hrp then hrp.Anchored = false end
                local char = getChar()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.Massless = false end
                    end
                end
            end)
            Rayfield:Notify({Title="👑 Pro Anti All", Content="Выключен. Anchor снят.", Duration=2, Image=4483362458})
        end
    end,
})

-- ═══════════════════════════════════════
-- LOADED
-- ═══════════════════════════════════════
Rayfield:Notify({
    Title = "Totem hub anti all hacks v4.2 Pro⭐",
    Content = "✈️Fly 🛡️GodMode 🏃Speed\n🛡️AntiGrab 🛡️AntiDetected\n💛AntiAll6.9 🔄AutoReset\n👑Pro Anti All\nВСЁ ЗАГРУЖЕНО!",
    Duration = 5, Image = 0,
})

print("═══════════════════════════════════════")
print("  DMM HUB — Features Loaded!")
print("  Fly | God Mode | Speed")
print("  Anti-Grab (WORKING) | Anti Detected")
print("  Anti All 6.9 | Auto Reset")
print("  👑 Pro Version Anti All (IMMOVABLE)")
print("═══════════════════════════════════════")
```
