-- ╔══════════════════════════════════════════════════════════╗
-- ║              DMM HUB — Fling Things and People          ║
-- ║           + ⭐ Legend OP (Anti-Grab & Anti-Detected)     ║
-- ║                Built on Rayfield Interface               ║
-- ╚══════════════════════════════════════════════════════════╝

-- ╔══════════════════════════════════════════╗
-- ║             VIDEO INTRO                  ║
-- ╚══════════════════════════════════════════╝

local INTRO_VIDEO_ID = "rbxassetid://5608327882"
local INTRO_DURATION = 5

local Players_intro = game:GetService("Players")
local TweenService_intro = game:GetService("TweenService")
local LP_intro = Players_intro.LocalPlayer
local PG_intro = LP_intro:WaitForChild("PlayerGui")

local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "DMM_Intro"
IntroGui.ResetOnSpawn = false
IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
IntroGui.DisplayOrder = 999
IntroGui.Parent = PG_intro

local Background = Instance.new("Frame")
Background.Name = "BG"
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BorderSizePixel = 0
Background.ZIndex = 100
Background.Parent = IntroGui

local VideoFrame = Instance.new("VideoFrame")
VideoFrame.Name = "IntroVideo"
VideoFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
VideoFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
VideoFrame.AnchorPoint = Vector2.new(0, 0)
VideoFrame.BackgroundTransparency = 1
VideoFrame.ZIndex = 101
VideoFrame.Looped = false
VideoFrame.Volume = 1
VideoFrame.Video = INTRO_VIDEO_ID
VideoFrame.Parent = Background

local SkipLabel = Instance.new("TextLabel")
SkipLabel.Name = "Skip"
SkipLabel.Size = UDim2.new(0.3, 0, 0.05, 0)
SkipLabel.Position = UDim2.new(0.35, 0, 0.92, 0)
SkipLabel.BackgroundTransparency = 1
SkipLabel.Text = "Нажми чтобы пропустить..."
SkipLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SkipLabel.TextScaled = true
SkipLabel.Font = Enum.Font.Gotham
SkipLabel.ZIndex = 102
SkipLabel.Parent = Background

local SkipButton = Instance.new("TextButton")
SkipButton.Name = "SkipBtn"
SkipButton.Size = UDim2.new(1, 0, 1, 0)
SkipButton.BackgroundTransparency = 1
SkipButton.Text = ""
SkipButton.ZIndex = 103
SkipButton.Parent = Background

local introDone = false

local function EndIntro()
    if introDone then return end
    introDone = true
    local fadeOut = TweenService_intro:Create(Background, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
    local videoFade = TweenService_intro:Create(VideoFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Volume = 0})
    fadeOut:Play()
    videoFade:Play()
    pcall(function() VideoFrame:Pause() end)
    fadeOut.Completed:Wait()
    IntroGui:Destroy()
end

SkipButton.MouseButton1Click:Connect(EndIntro)
pcall(function() VideoFrame:Play() end)
VideoFrame.Ended:Connect(EndIntro)
task.delay(INTRO_DURATION, function()
    if not introDone then EndIntro() end
end)
repeat task.wait(0.1) until introDone
task.wait(0.3)

-- ╔══════════════════════════════════════════╗
-- ║          HUB НАЧИНАЕТСЯ                  ║
-- ╚══════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ═══════ СЕРВИСЫ ═══════
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local UserInputService   = game:GetService("UserInputService")
local VirtualInputManager= game:GetService("VirtualInputManager")
local TweenService       = game:GetService("TweenService")
local Debris             = game:GetService("Debris")
local Lighting           = game:GetService("Lighting")

local LocalPlayer      = Players.LocalPlayer
local Character        = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Mouse            = LocalPlayer:GetMouse()

-- ═══════ ПЕРЕМЕННЫЕ ═══════
local Settings = {
    InstantKick = false, LoopKick = false, KickAll = false,
    BlobmanGrab = false, BlobmanLoopGrab = false, BlobmanFree = false, GrabAll = false,
    KillGrab = false, VoidGrab = false, PoisonGrab = false,
    RadioactiveGrab = false, FreezeGrab = false,
    FlingAura = false, VoidAura = false, PoisonAura = false,
    FollowAura = false, KillAura = false,
    SuperThrow = false, SuperStrength = false, SilentAim = false,
    AntiGrab = false, AntiExplosion = false, AntiKick = false,
    PositionDamage = false, InfJump = false, Noclip = false,
    SpeedHack = false, AutoClaimCash = false,
    LoopKillAll = false, LoopKillPlayer = false, GodMode = false,
}

local SelectedPlayer = nil
local WalkSpeedVal   = 16
local JumpPowerVal   = 50
local AuraRange      = 30
local FlingPower     = 500
local ThrowPower     = 300

local HS = {
    BlobLoopGrabAll = false, BlobLoopGrabPlayer = false, BlobFreeze = false,
    SpeedGrab = false, PoisonGrab = false, RadioactiveGrab = false,
    DeathGrab = false, BurnGrab = false, VoidGrab = false,
    MasslessGrab = false, NoclipGrab = false, KillGrab = false, FreezeGrab = false,
    LoopKickBlob = false, AutoKickAllBlob = false,
    LoopKill = false, LoopKillAll = false, LoopRagdoll = false, LoopFire = false,
    PoisonAura = false, DeathAura = false, RadioactiveAura = false,
    BurnAura = false, FlingAura = false, AttractionAura = false,
    VoidAura = false, FollowAura = false, KickAura = false,
    SuperStrength = false, StrengthVal = 500, SilentAim = false,
    AutoAttacker = false, PositionDamage = false,
    AntiGrab = false, AntiExplosion = false, AntiKick = false,
    AntiVoid = false, AntiBurn = false, AntiLag = false,
    AntiBlobman = false, GucciAnti = false,
    InfJump = false, Noclip = false,
    Fly = false, FlySpeed = 50, GodMode = false,
    DestroyServer = false, LagServer = false, BurnAll = false,
    BringServer = false, SpamSounds = false,
    FeObjectTornado = false, FeObjectAura = false, FeObjectFloat = false,
    AuraRange = 40, FlingPower = 9999,
    LoopVoid = false, LoopTP = false, AutoCash = false, ClickTP = false,
}

local HSelPlayer     = nil
local HSelPlayerName = "None"

-- ═══════ LEGEND OP — ПЕРЕМЕННЫЕ ═══════
local Flying               = false
local IsTeleporting        = false
local LastInputTime        = tick()
local PositionHistory      = {}
local AntiGrabEnabled      = false
local AntiDetectedEnabled  = false
local AntiDetectedCooldown = false
local AntiAllHacksEnabled     = false
local AntiAllHacksConnections = {}  -- ★ ТАБЛИЦА для всех соединений
local LoopResetEnabled        = false  -- ★ НОВАЯ ПЕРЕМЕННАЯ
local SAFE_POSITION           = CFrame.new(322.31, 9.52, 489.68)

local MovementKeys = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true, [Enum.KeyCode.LeftShift] = true,
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if MovementKeys[input.KeyCode] then LastInputTime = tick() end
    end
end)

-- ═══════ ЗАПИСЬ ИСТОРИИ ПОЗИЦИЙ ═══════
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
        Time = tick(), CFrame = hrp.CFrame, Velocity = hrp.AssemblyLinearVelocity
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

local function TeleportBack(seconds)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return false end
    local safeData = GetPositionSecondsAgo(seconds)
    if safeData then
        IsTeleporting = true
        HumanoidRootPart.CFrame = safeData.CFrame
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        pcall(function()
            local animator = Humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end
        end)
        task.defer(function() task.wait(0.4); IsTeleporting = false end)
        return true
    end
    return false
end

-- ═══════ ANTI-GRAB ТРЕКЕР ═══════
local function SetupAntiGrabAnimTracker(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = hum:WaitForChild("Animator", 5) end
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

-- ═══════ ANTI-DETECTED HEARTBEAT ═══════
RunService.Heartbeat:Connect(function()
    if not AntiDetectedEnabled then return end
    if Flying or IsTeleporting or AntiDetectedCooldown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
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

-- ═══════ ОБНОВЛЕНИЕ ПЕРСОНАЖА ═══════
LocalPlayer.CharacterAdded:Connect(function(char)
    Character        = char
    Humanoid         = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    task.wait(0.3)
    SetupAntiGrabAnimTracker(char)
end)
if LocalPlayer.Character then
    SetupAntiGrabAnimTracker(LocalPlayer.Character)
end

-- ═══════ УТИЛИТЫ ═══════
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local function getClosestPlayer(range)
    local closest, dist = nil, range or math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then closest = p; dist = d end
        end
    end
    return closest
end

local function getBlobman()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "BlobMan" or obj.Name == "Blobman" then return obj end
    end
    return nil
end

local function getAllBlobmen()
    local blobs = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "BlobMan" or obj.Name == "Blobman" then table.insert(blobs, obj) end
    end
    return blobs
end

local function getGrabbableRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("grab") or v.Name:lower():find("pickup") or v.Name:lower():find("interact")) then return v end
    end
    return nil
end

local function getDamageRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("damage") or v.Name:lower():find("attack") or v.Name:lower():find("kill")) then return v end
    end
    return nil
end

local function getCashRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("cash") or v.Name:lower():find("coin") or v.Name:lower():find("claim") or v.Name:lower():find("money")) then return v end
    end
    return nil
end

local function applyVelocity(part, direction, power)
    if part then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = direction * power
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = part
        Debris:AddItem(bv, 0.3)
    end
end

local function flingPlayer(target)
    pcall(function()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local tHRP = target.Character.HumanoidRootPart
            local direction = (tHRP.Position - HumanoidRootPart.Position).Unit
            HumanoidRootPart.CFrame = tHRP.CFrame + direction * 2
            applyVelocity(tHRP, Vector3.new(math.random(-1,1), 1, math.random(-1,1)), FlingPower)
        end
    end)
end

local function voidPlayer(target)
    pcall(function()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
        end
    end)
end

local function h_alive(p)
    return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
       and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function h_dist(p)
    if h_alive(p) and HumanoidRootPart then
        return (HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function h_closest(range)
    local best, bestD = nil, range or math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local d = h_dist(p)
            if d < bestD then best, bestD = p, d end
        end
    end
    return best
end

local function h_getBlobSeat(blob)
    if blob then
        return blob:FindFirstChildWhichIsA("Seat") or blob:FindFirstChildWhichIsA("VehicleSeat") or blob:FindFirstChild("Seat")
    end
    return nil
end

local function h_getBlobHands(blob)
    local hands = {}
    if blob then
        for _, p in pairs(blob:GetDescendants()) do
            if p:IsA("BasePart") and (p.Name:lower():find("hand") or p.Name:lower():find("grab") or p.Name:lower():find("palm")) then
                table.insert(hands, p)
            end
        end
        if #hands == 0 then
            for _, p in pairs(blob:GetDescendants()) do
                if p:IsA("BasePart") and not p:IsA("Seat") and not p:IsA("VehicleSeat") then
                    table.insert(hands, p)
                end
            end
        end
    end
    return hands
end

local function h_sitOnBlob(blob)
    local seat = h_getBlobSeat(blob)
    if seat and HumanoidRootPart then
        HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
        if seat:IsA("Seat") or seat:IsA("VehicleSeat") then seat:Sit(Humanoid) end
    end
end

local function h_blobGrabPlayer(blob, target)
    pcall(function()
        if not h_alive(target) or not blob then return end
        local hands = h_getBlobHands(blob)
        for _, hand in pairs(hands) do
            if hand then
                hand.CFrame = target.Character.HumanoidRootPart.CFrame
                pcall(function()
                    firetouchinterest(hand, target.Character.HumanoidRootPart, 0)
                    task.wait(0.05)
                    firetouchinterest(hand, target.Character.HumanoidRootPart, 1)
                end)
            end
        end
    end)
end

local function h_blobKickPlayer(blob, target)
    pcall(function()
        if not h_alive(target) or not blob then return end
        local hands = h_getBlobHands(blob)
        for _, hand in pairs(hands) do
            hand.CFrame = target.Character.HumanoidRootPart.CFrame
            pcall(function() firetouchinterest(hand, target.Character.HumanoidRootPart, 0) end)
        end
        task.wait(0.1)
        if h_alive(target) then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9,1e9,1e9)
            bv.Velocity = Vector3.new(0, HS.FlingPower, 0)
            bv.Parent = target.Character.HumanoidRootPart
            Debris:AddItem(bv, 0.5)
        end
        task.wait(0.15)
        for _, hand in pairs(hands) do
            pcall(function() firetouchinterest(hand, target.Character.HumanoidRootPart, 1) end)
        end
    end)
end

local function h_flingPlayer(target)
    pcall(function()
        if not h_alive(target) then return end
        local tHRP = target.Character.HumanoidRootPart
        local oldCF = HumanoidRootPart.CFrame
        HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, -1)
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, HS.FlingPower, 0)
        bav.MaxTorque = Vector3.new(1e9,1e9,1e9)
        bav.Parent = HumanoidRootPart
        Debris:AddItem(bav, 0.3)
        task.wait(0.3)
        HumanoidRootPart.CFrame = oldCF
    end)
end

local function h_voidPlayer(target)
    pcall(function()
        if h_alive(target) then target.Character.HumanoidRootPart.CFrame = CFrame.new(9e9,9e9,9e9) end
    end)
end

local function h_applyGrabEffect(target, effectType)
    pcall(function()
        if not h_alive(target) then return end
        local hrp = target.Character.HumanoidRootPart
        if effectType == "Poison" then
            local p = Instance.new("Part"); p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(3,3,3)
            p.Color=Color3.fromRGB(0,255,0); p.Material=Enum.Material.Neon; p.Transparency=0.4
            p.Anchored=true; p.CanCollide=false; p.CFrame=hrp.CFrame; p.Parent=Workspace; Debris:AddItem(p,0.5)
            local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            bv.Velocity=Vector3.new(0,-50,0); bv.Parent=hrp; Debris:AddItem(bv,0.2)
        elseif effectType == "Radioactive" then
            local p = Instance.new("Part"); p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(4,4,4)
            p.Color=Color3.fromRGB(255,255,0); p.Material=Enum.Material.Neon; p.Transparency=0.3
            p.Anchored=true; p.CanCollide=false; p.CFrame=hrp.CFrame; p.Parent=Workspace; Debris:AddItem(p,0.5)
        elseif effectType == "Death" then hrp.CFrame = CFrame.new(0,-500,0)
        elseif effectType == "Burn" then
            local fire=Instance.new("Fire"); fire.Size=10; fire.Heat=25; fire.Parent=hrp; Debris:AddItem(fire,3)
        elseif effectType == "Void" then hrp.CFrame = CFrame.new(9e9,9e9,9e9)
        elseif effectType == "Massless" then
            for _, part in pairs(target.Character:GetDescendants()) do if part:IsA("BasePart") then part.Massless=true end end
        elseif effectType == "Noclip" then
            for _, part in pairs(target.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
        elseif effectType == "Kill" then hrp.CFrame = CFrame.new(0,-500,0)
        elseif effectType == "Freeze" then
            hrp.Anchored = true
            task.delay(5, function() pcall(function() hrp.Anchored = false end) end)
        end
    end)
end

-- ═══════════════════════════════════════
-- ★★★ ТЁМНО-БЕЛАЯ ТЕМА ★★★
-- ═══════════════════════════════════════
local DarkWhiteTheme = {
    TextFont = "Default",
    TextColor = Color3.fromRGB(230, 230, 235),

    Background = Color3.fromRGB(18, 18, 22),
    Topbar = Color3.fromRGB(28, 28, 33),
    Shadow = Color3.fromRGB(8, 8, 12),

    NotificationBackground = Color3.fromRGB(22, 22, 27),
    NotificationActionsBackground = Color3.fromRGB(200, 200, 210),

    TabBackground = Color3.fromRGB(35, 35, 40),
    TabStroke = Color3.fromRGB(55, 55, 60),
    TabBackgroundSelected = Color3.fromRGB(215, 215, 225),
    TabTextColor = Color3.fromRGB(195, 195, 200),
    SelectedTabTextColor = Color3.fromRGB(18, 18, 22),

    ElementBackground = Color3.fromRGB(28, 28, 33),
    ElementBackgroundHover = Color3.fromRGB(38, 38, 43),
    SecondaryElementBackground = Color3.fromRGB(22, 22, 27),
    ElementStroke = Color3.fromRGB(50, 50, 58),
    SecondaryElementStroke = Color3.fromRGB(40, 40, 48),

    SliderBackground = Color3.fromRGB(35, 35, 40),
    SliderProgress = Color3.fromRGB(210, 210, 220),
    SliderStroke = Color3.fromRGB(48, 48, 55),

    ToggleBackground = Color3.fromRGB(30, 30, 35),
    ToggleEnabled = Color3.fromRGB(220, 220, 230),
    ToggleDisabled = Color3.fromRGB(70, 70, 78),
    ToggleEnabledStroke = Color3.fromRGB(230, 230, 240),
    ToggleDisabledStroke = Color3.fromRGB(85, 85, 92),
    ToggleEnabledOuterStroke = Color3.fromRGB(110, 110, 118),
    ToggleDisabledOuterStroke = Color3.fromRGB(60, 60, 68),

    InputBackground = Color3.fromRGB(25, 25, 30),
    InputStroke = Color3.fromRGB(48, 48, 55),
    PlaceholderColor = Color3.fromRGB(160, 160, 168),
}

-- ═══════════════════════════════════════
-- ОКНО  ★ С ТЁМНО-БЕЛОЙ ТЕМОЙ ★
-- ═══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "💀 DMM HUB — FTAP",
    Icon = 0,
    LoadingTitle = "DMM HUB",
    LoadingSubtitle = "Fling Things and People",
    Theme = DarkWhiteTheme,          -- ★ ТЁМНО-БЕЛАЯ ТЕМА
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true, FolderName = "DMM_HUB", FileName = "FTAP_Config"
    },
    KeySystem = false,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              ⭐ LEGEND OP TAB                            ║
-- ╚══════════════════════════════════════════════════════════╝
local LegendTab = Window:CreateTab("⭐ Legend OP", 4483362458)

LegendTab:CreateSection("💛 Anti-Grab [BETA] 🔴OP")

LegendTab:CreateParagraph({
    Title = "⭐ Anti-Grab Info",
    Content = "Отслеживает подозрительные анимации (grab, hold, carry...)\nОткат на 3 секунды назад при захвате."
})

LegendTab:CreateToggle({
    Name = "Anti-Grab [BETA] 🔴OP",
    CurrentValue = false, Flag = "LegendAntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then
            PositionHistory = {}
            Rayfield:Notify({Title="⭐ Legend OP", Content="Anti-Grab АКТИВИРОВАН!", Duration=3, Image=4483362458})
        else
            Rayfield:Notify({Title="⭐ Legend OP", Content="Anti-Grab выключен.", Duration=2, Image=4483362458})
        end
    end,
})

LegendTab:CreateSection("💛 Anti Detected [BETA Hacker]")

LegendTab:CreateParagraph({
    Title = "⭐ Anti Detected Info",
    Content = "Отслеживает принудительное перемещение.\nОткат на 7 сек назад. Защита от Fling, Kick, Velocity."
})

LegendTab:CreateToggle({
    Name = "Anti Detected [BETA Hacker]",
    CurrentValue = false, Flag = "LegendAntiDetected",
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

LegendTab:CreateSection("💛 Anti All Hacks v6.9")

LegendTab:CreateParagraph({
    Title = "⭐ Anti All Hacks v6.9 Info",
    Content = "10x ТП КАЖДЫЙ КАДР на безопасную позицию.\nX:322.31 Y:9.52 Z:489.68\n3 потока: RenderStepped + Heartbeat + Stepped\nМАКСИМАЛЬНАЯ скорость телепорта."
})

-- ★★★ ОБНОВЛЁННЫЙ Anti All Hacks — 10x ТП × 3 RunService потока ★★★
LegendTab:CreateToggle({
    Name = "Anti All Hacks v6.9 ⚡ULTRA 10x",
    CurrentValue = false, Flag = "LegendAntiAllHacks",
    Callback = function(Value)
        AntiAllHacksEnabled = Value
        if Value then
            -- Очистка старых соединений
            for _, conn in pairs(AntiAllHacksConnections) do
                pcall(function() conn:Disconnect() end)
            end
            AntiAllHacksConnections = {}

            -- ★ Общая функция — 10 ТП за вызов
            local function forceTP()
                if not AntiAllHacksEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _i = 1, 10 do
                    hrp.CFrame = SAFE_POSITION
                    hrp.AssemblyLinearVelocity  = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                -- Убиваем любые навязанные силы
                for _, child in pairs(hrp:GetChildren()) do
                    if child:IsA("BodyVelocity") or child:IsA("BodyForce")
                    or child:IsA("BodyThrust") or child:IsA("BodyAngularVelocity")
                    or child:IsA("BodyPosition") or child:IsA("BodyGyro")
                    or child:IsA("LinearVelocity") or child:IsA("VectorForce") then
                        child:Destroy()
                    end
                end
            end

            -- ★ Поток 1 — RenderStepped (перед рендером, самый быстрый)
            table.insert(AntiAllHacksConnections,
                RunService.RenderStepped:Connect(forceTP)
            )

            -- ★ Поток 2 — Heartbeat (после физики)
            table.insert(AntiAllHacksConnections,
                RunService.Heartbeat:Connect(forceTP)
            )

            -- ★ Поток 3 — Stepped (перед физикой)
            table.insert(AntiAllHacksConnections,
                RunService.Stepped:Connect(function() forceTP() end)
            )

            Rayfield:Notify({
                Title = "⭐ Legend OP",
                Content = "Anti All Hacks v6.9 ⚡ULTRA\n10x ТП × 3 потока = 30 ТП/кадр!\n→ X:322 Y:9.5 Z:489",
                Duration = 4, Image = 4483362458
            })
        else
            for _, conn in pairs(AntiAllHacksConnections) do
                pcall(function() conn:Disconnect() end)
            end
            AntiAllHacksConnections = {}
            Rayfield:Notify({
                Title = "⭐ Legend OP",
                Content = "Anti All Hacks v6.9 выключен.",
                Duration = 2, Image = 4483362458
            })
        end
    end,
})

-- ★★★ НОВЫЙ: LOOP RESET ★★★
LegendTab:CreateSection("💛 Loop Reset ⚡")

LegendTab:CreateParagraph({
    Title = "⭐ Loop Reset Info",
    Content = "Ультра-быстрый ресет персонажа.\nМгновенная смерть каждый цикл.\nПерсонаж респавнится и снова умирает."
})

LegendTab:CreateToggle({
    Name = "🔄 Loop Reset ⚡ULTRA FAST",
    CurrentValue = false, Flag = "LegendLoopReset",
    Callback = function(Value)
        LoopResetEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "⭐ Legend OP",
                Content = "Loop Reset АКТИВИРОВАН!\n⚡ Ультра-быстрый ресет.",
                Duration = 3, Image = 4483362458
            })
            task.spawn(function()
                while LoopResetEnabled do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                hum.Health = 0
                            end
                        end
                    end)
                    -- Ждём респавна
                    if LoopResetEnabled then
                        local newChar = LocalPlayer.Character
                        if newChar then
                            local newHum = newChar:FindFirstChildOfClass("Humanoid")
                            if newHum and newHum.Health <= 0 then
                                -- Ждём пока персонаж жив (респавн)
                                local waited = 0
                                repeat
                                    task.wait(0.05)
                                    waited = waited + 0.05
                                    newChar = LocalPlayer.Character
                                    newHum = newChar and newChar:FindFirstChildOfClass("Humanoid")
                                until (newHum and newHum.Health > 0) or waited > 10 or not LoopResetEnabled
                            end
                        end
                        task.wait(0.05) -- минимальная задержка
                    end
                end
            end)
        else
            Rayfield:Notify({
                Title = "⭐ Legend OP",
                Content = "Loop Reset выключен.",
                Duration = 2, Image = 4483362458
            })
        end
    end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║                    TAB: 🏠 HOME                          ║
-- ╚══════════════════════════════════════════════════════════╝
local HomeTab = Window:CreateTab("🏠 Home", 0)

HomeTab:CreateSection("🦠 Blobman Controls")

HomeTab:CreateButton({
    Name = "🟢 Sit On Blobman",
    Callback = function()
        local blob = getBlobman()
        if blob then h_sitOnBlob(blob); Rayfield:Notify({Title="DMM",Content="Mounted Blobman!",Duration=2})
        else Rayfield:Notify({Title="DMM",Content="No Blobman found!",Duration=2}) end
    end,
})

HomeTab:CreateButton({
    Name = "🆓 Blobman Free (Spawn)",
    Callback = function()
        pcall(function()
            for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                if r:IsA("RemoteEvent") then
                    pcall(function() r:FireServer("BlobMan") end)
                    pcall(function() r:FireServer("Blobman") end)
                    pcall(function() r:FireServer("Buy", "BlobMan") end)
                    pcall(function() r:FireServer("buy", "Blobman") end)
                    pcall(function() r:FireServer("Purchase", "BlobMan") end)
                end
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Attempted spawn Blobman!",Duration=2})
    end,
})

HomeTab:CreateToggle({
    Name = "❄️ Freeze Blobman", CurrentValue = false, Flag = "H_BlobFreeze",
    Callback = function(V)
        HS.BlobFreeze = V
        task.spawn(function()
            while HS.BlobFreeze do task.wait(0.1)
                pcall(function()
                    local blob = getBlobman()
                    if blob then for _, p in pairs(blob:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = true end end end
                end)
            end
            pcall(function()
                local blob = getBlobman()
                if blob then for _, p in pairs(blob:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = false end end end
            end)
        end)
    end,
})

HomeTab:CreateSection("🦠 Blobman Loop Grab")

HomeTab:CreateToggle({
    Name = "🔄 Loop Grab ALL Players", CurrentValue = false, Flag = "H_BlobGrabAll",
    Callback = function(V)
        HS.BlobLoopGrabAll = V
        task.spawn(function()
            while HS.BlobLoopGrabAll do task.wait(0.15)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and h_alive(p) then h_blobGrabPlayer(blob, p) end
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateDropdown({
    Name = "Select Player (Blob Grab)", Options = getPlayerList(), CurrentOption = {},
    MultiOption = false, Flag = "H_BlobGrabTarget",
    Callback = function(Opt) HSelPlayerName = Opt; HSelPlayer = Players:FindFirstChild(Opt) end,
})

HomeTab:CreateToggle({
    Name = "🔄 Loop Grab Selected Player", CurrentValue = false, Flag = "H_BlobGrabSel",
    Callback = function(V)
        HS.BlobLoopGrabPlayer = V
        task.spawn(function()
            while HS.BlobLoopGrabPlayer do task.wait(0.15)
                pcall(function() local blob = getBlobman(); if blob and h_alive(HSelPlayer) then h_blobGrabPlayer(blob, HSelPlayer) end end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "⚡ Speed Grab Player", CurrentValue = false, Flag = "H_SpeedGrab",
    Callback = function(V)
        HS.SpeedGrab = V
        task.spawn(function()
            while HS.SpeedGrab do task.wait(0.05)
                pcall(function() local blob = getBlobman(); if blob and h_alive(HSelPlayer) then h_blobGrabPlayer(blob, HSelPlayer) end end)
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "🤏 Multiple Grab (All Blobmen)",
    Callback = function()
        pcall(function()
            for _, m in pairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and (m.Name == "BlobMan" or m.Name == "Blobman") then
                    for _, h in pairs(h_getBlobHands(m)) do
                        firetouchinterest(HumanoidRootPart, h, 0); task.wait(0.02); firetouchinterest(HumanoidRootPart, h, 1)
                    end
                end
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Grabbed all Blobmen!",Duration=2})
    end,
})

HomeTab:CreateSection("💎 Grab Mods")

for _, gt in pairs({"Poison","Radioactive","Death","Burn","Void","Massless","Noclip","Kill","Freeze"}) do
    HomeTab:CreateToggle({
        Name = "💎 " .. gt .. " Grab", CurrentValue = false, Flag = "H_" .. gt .. "Grab",
        Callback = function(V)
            HS[gt .. "Grab"] = V
            task.spawn(function()
                while HS[gt .. "Grab"] do task.wait(0.3)
                    pcall(function() local target = h_closest(HS.AuraRange); if target then h_applyGrabEffect(target, gt) end end)
                end
            end)
        end,
    })
end

HomeTab:CreateSlider({Name="Grab / Aura Range", Range={10,300}, Increment=5, Suffix="studs", CurrentValue=40, Flag="H_AuraRange", Callback=function(V) HS.AuraRange=V end})

HomeTab:CreateSection("⚡ Kicks & Kills")

HomeTab:CreateDropdown({Name="Select Player (Kick)", Options=getPlayerList(), CurrentOption={}, MultiOption=false, Flag="H_KickTarget",
    Callback=function(Opt) HSelPlayer=Players:FindFirstChild(Opt); HSelPlayerName=Opt end})

HomeTab:CreateButton({Name="⚡ Instant Kick (Blobman)", Callback=function()
    pcall(function()
        local blob = getBlobman()
        if blob and h_alive(HSelPlayer) then
            for i=1,30 do h_blobKickPlayer(blob, HSelPlayer); task.wait(0.05) end
            Rayfield:Notify({Title="DMM",Content="Kicked "..HSelPlayerName.."!",Duration=2})
        else Rayfield:Notify({Title="DMM",Content="Need Blobman + Target!",Duration=2}) end
    end)
end})

HomeTab:CreateToggle({Name="🔄 Loop Kick (Blobman)", CurrentValue=false, Flag="H_LoopKickBlob",
    Callback=function(V) HS.LoopKickBlob=V; task.spawn(function() while HS.LoopKickBlob do task.wait(0.2)
        pcall(function() local blob=getBlobman(); if blob and h_alive(HSelPlayer) then h_blobKickPlayer(blob, HSelPlayer) end end) end end) end})

HomeTab:CreateButton({Name="💥 Kick ALL (Blobman)", Callback=function()
    task.spawn(function() local blob=getBlobman(); if blob then
        for _, p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and h_alive(p) then for i=1,15 do h_blobKickPlayer(blob, p); task.wait(0.05) end end end
        Rayfield:Notify({Title="DMM",Content="Kicked ALL!",Duration=2}) end end) end})

HomeTab:CreateToggle({Name="🔄 Auto Kick ALL", CurrentValue=false, Flag="H_AutoKickAll",
    Callback=function(V) HS.AutoKickAllBlob=V; task.spawn(function() while HS.AutoKickAllBlob do task.wait(0.3)
        pcall(function() local blob=getBlobman(); if blob then for _, p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer and h_alive(p) then h_blobKickPlayer(blob, p) end end end end) end end) end})

HomeTab:CreateToggle({Name="💀 Loop Kill Selected", CurrentValue=false, Flag="H_LoopKill",
    Callback=function(V) HS.LoopKill=V; task.spawn(function() while HS.LoopKill do task.wait(0.3)
        pcall(function() if h_alive(HSelPlayer) then HSelPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(0,-500,0) end end) end end) end})

HomeTab:CreateToggle({Name="☠️ Loop Kill ALL", CurrentValue=false, Flag="H_LoopKillAll",
    Callback=function(V) HS.LoopKillAll=V; task.spawn(function() while HS.LoopKillAll do task.wait(0.3)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and h_alive(p) then p.Character.HumanoidRootPart.CFrame=CFrame.new(0,-500,0) end end) end end end) end})

HomeTab:CreateToggle({Name="🔄 Loop Ragdoll Selected", CurrentValue=false, Flag="H_LoopRagdoll",
    Callback=function(V) HS.LoopRagdoll=V; task.spawn(function() while HS.LoopRagdoll do task.wait(0.5)
        pcall(function() if h_alive(HSelPlayer) then local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            bv.Velocity=Vector3.new(math.random(-200,200),100,math.random(-200,200)); bv.Parent=HSelPlayer.Character.HumanoidRootPart; Debris:AddItem(bv,0.3) end end) end end) end})

HomeTab:CreateToggle({Name="🔥 Loop Fire Selected", CurrentValue=false, Flag="H_LoopFire",
    Callback=function(V) HS.LoopFire=V; task.spawn(function() while HS.LoopFire do task.wait(1)
        pcall(function() if h_alive(HSelPlayer) then h_applyGrabEffect(HSelPlayer, "Burn") end end) end end) end})

HomeTab:CreateButton({Name="🌊 Send to Void", Callback=function()
    if h_alive(HSelPlayer) then h_voidPlayer(HSelPlayer); Rayfield:Notify({Title="DMM",Content="Voided "..HSelPlayerName,Duration=2}) end end})

HomeTab:CreateToggle({Name="🌊 Loop Void", CurrentValue=false, Flag="H_LoopVoid",
    Callback=function(V) HS.LoopVoid=V; task.spawn(function() while HS.LoopVoid do task.wait(0.5)
        pcall(function() if h_alive(HSelPlayer) then h_voidPlayer(HSelPlayer) end end) end end) end})

HomeTab:CreateButton({Name="🔗 Bring Selected", Callback=function()
    pcall(function() if h_alive(HSelPlayer) then HSelPlayer.Character.HumanoidRootPart.CFrame=HumanoidRootPart.CFrame*CFrame.new(0,0,-5)
        Rayfield:Notify({Title="DMM",Content="Brought "..HSelPlayerName,Duration=2}) end end) end})

HomeTab:CreateButton({Name="🔒 Lock Selected", Callback=function()
    pcall(function() if h_alive(HSelPlayer) then HSelPlayer.Character.HumanoidRootPart.Anchored=true
        Rayfield:Notify({Title="DMM",Content="Locked "..HSelPlayerName,Duration=2}) end end) end})

HomeTab:CreateSlider({Name="Fling / Kick Power", Range={100,99999}, Increment=500, Suffix="force", CurrentValue=9999, Flag="H_FlingPow", Callback=function(V) HS.FlingPower=V end})

HomeTab:CreateSection("⚔️ Combat")

HomeTab:CreateToggle({Name="💪 Super Strength", CurrentValue=false, Flag="H_SuperStr", Callback=function(V) HS.SuperStrength=V end})
HomeTab:CreateSlider({Name="Custom Strength", Range={0,10000}, Increment=50, Suffix="str", CurrentValue=500, Flag="H_StrVal", Callback=function(V) HS.StrengthVal=V end})
HomeTab:CreateToggle({Name="🎯 Silent Aim", CurrentValue=false, Flag="H_SilentAim", Callback=function(V) HS.SilentAim=V; Settings.SilentAim=V end})

HomeTab:CreateToggle({Name="⚔️ Auto Attacker", CurrentValue=false, Flag="H_AutoAtk",
    Callback=function(V) HS.AutoAttacker=V; task.spawn(function() while HS.AutoAttacker do task.wait(0.2)
        pcall(function() local t=h_closest(HS.AuraRange); if t and h_alive(t) then h_flingPlayer(t) end end) end end) end})

HomeTab:CreateToggle({Name="📍 Position Damage", CurrentValue=false, Flag="H_PosDmg",
    Callback=function(V) HS.PositionDamage=V; task.spawn(function() while HS.PositionDamage do task.wait(0.2)
        pcall(function() local t=h_closest(HS.AuraRange); if t and h_alive(t) then t.Character.HumanoidRootPart.CFrame=CFrame.new(0,-300,0) end end) end end) end})

HomeTab:CreateSection("🌀 Auras")

for _, aura in pairs({
    {name="☠️ Poison Aura", key="PoisonAura", effect="Poison"},
    {name="💀 Death Aura", key="DeathAura", effect="Death"},
    {name="☢️ Radioactive Aura", key="RadioactiveAura", effect="Radioactive"},
    {name="🔥 Burn Aura", key="BurnAura", effect="Burn"},
    {name="🌊 Void Aura", key="VoidAura", effect="Void"},
    {name="🧲 Attraction Aura", key="AttractionAura", effect=nil},
    {name="💨 Fling Aura", key="FlingAura", effect=nil},
    {name="👣 Follow Aura", key="FollowAura", effect=nil},
    {name="👢 Kick Aura", key="KickAura", effect=nil},
}) do
    HomeTab:CreateToggle({
        Name = aura.name, CurrentValue = false, Flag = "H_" .. aura.key,
        Callback = function(V)
            HS[aura.key] = V
            task.spawn(function()
                while HS[aura.key] do task.wait(0.3)
                    for _, p in pairs(Players:GetPlayers()) do pcall(function()
                        if p~=LocalPlayer and h_alive(p) and h_dist(p)<=HS.AuraRange then
                            if aura.effect then h_applyGrabEffect(p, aura.effect)
                            elseif aura.key=="FlingAura" then h_flingPlayer(p)
                            elseif aura.key=="AttractionAura" then p.Character.HumanoidRootPart.CFrame=HumanoidRootPart.CFrame*CFrame.new(0,0,-3)
                            elseif aura.key=="FollowAura" then if h_alive(HSelPlayer) then HumanoidRootPart.CFrame=HSelPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3) end
                            elseif aura.key=="KickAura" then local blob=getBlobman(); if blob then h_blobKickPlayer(blob, p) end end
                        end
                    end) end
                end
            end)
        end,
    })
end

HomeTab:CreateSlider({Name="Fling Aura Strength", Range={100,99999}, Increment=500, Suffix="power", CurrentValue=9999, Flag="H_FlingAuraStr", Callback=function(V) HS.FlingPower=V end})

HomeTab:CreateSection("🛡️ Defense / Antis")

HomeTab:CreateToggle({Name="🛡️ Anti Grab", CurrentValue=false, Flag="H_AntiGrab",
    Callback=function(V) HS.AntiGrab=V; task.spawn(function() while HS.AntiGrab do task.wait(0.05)
        pcall(function() for _, v in pairs(Character:GetDescendants()) do
            if (v:IsA("Weld") or v:IsA("WeldConstraint")) and v.Part0 and v.Part1 then
                if not v.Part0:IsDescendantOf(Character) or not v.Part1:IsDescendantOf(Character) then v:Destroy() end end end
            if Humanoid.SeatPart and not Humanoid.SeatPart:IsDescendantOf(Character) then Humanoid.Jump=true end end) end end) end})

HomeTab:CreateToggle({Name="🛡️ Gucci Anti", CurrentValue=false, Flag="H_GucciAnti",
    Callback=function(V) HS.GucciAnti=V; task.spawn(function() while HS.GucciAnti do task.wait(0.02)
        pcall(function() for _, v in pairs(Character:GetDescendants()) do
            if (v:IsA("Weld") or v:IsA("WeldConstraint")) and v.Part0 and v.Part1 and (not v.Part0:IsDescendantOf(Character) or not v.Part1:IsDescendantOf(Character)) then v:Destroy() end
            if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") then if v.Parent and v.Parent:IsDescendantOf(Character) then v:Destroy() end end end
            if HumanoidRootPart.Velocity.Magnitude>300 then HumanoidRootPart.Velocity=Vector3.zero; HumanoidRootPart.RotVelocity=Vector3.zero end
            if Humanoid.SeatPart and not Humanoid.SeatPart:IsDescendantOf(Character) then Humanoid.Jump=true end end) end end) end})

HomeTab:CreateToggle({Name="🛡️ Anti Blobman", CurrentValue=false, Flag="H_AntiBlobman",
    Callback=function(V) HS.AntiBlobman=V; task.spawn(function() while HS.AntiBlobman do task.wait(0.05)
        pcall(function()
            if Humanoid.SeatPart and Humanoid.SeatPart.Parent and Humanoid.SeatPart.Parent.Name:lower():find("blob") then Humanoid.Jump=true end
            for _, v in pairs(Character:GetDescendants()) do if (v:IsA("Weld") or v:IsA("WeldConstraint")) and v.Part0 and v.Part1 then
                local other = v.Part0:IsDescendantOf(Character) and v.Part1 or v.Part0
                if other and other.Parent and (other.Parent.Name:lower():find("blob") or other.Name:lower():find("hand")) then v:Destroy() end end end end) end end) end})

HomeTab:CreateToggle({Name="🛡️ Anti Explosion", CurrentValue=false, Flag="H_AntiExpl", Callback=function(V) HS.AntiExplosion=V end})

HomeTab:CreateToggle({Name="🛡️ Anti Kick", CurrentValue=false, Flag="H_AntiKick",
    Callback=function(V) HS.AntiKick=V; task.spawn(function() while HS.AntiKick do task.wait(0.03)
        pcall(function() if HumanoidRootPart.Velocity.Magnitude>200 then HumanoidRootPart.Velocity=Vector3.zero; HumanoidRootPart.RotVelocity=Vector3.zero end
            for _, v in pairs(HumanoidRootPart:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") then v:Destroy() end end end) end end) end})

HomeTab:CreateToggle({Name="🛡️ Anti Void", CurrentValue=false, Flag="H_AntiVoid",
    Callback=function(V) HS.AntiVoid=V; task.spawn(function() while HS.AntiVoid do task.wait(0.1)
        pcall(function() if HumanoidRootPart.Position.Y<-100 then HumanoidRootPart.CFrame=CFrame.new(0,50,0) end end) end end) end})

HomeTab:CreateToggle({Name="🛡️ Anti Burn", CurrentValue=false, Flag="H_AntiBurn",
    Callback=function(V) HS.AntiBurn=V; task.spawn(function() while HS.AntiBurn do task.wait(0.5)
        pcall(function() for _, v in pairs(Character:GetDescendants()) do if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v:Destroy() end end end) end end) end})

HomeTab:CreateToggle({Name="🛡️ Anti Lag", CurrentValue=false, Flag="H_AntiLag",
    Callback=function(V) HS.AntiLag=V; if V then pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false end
            if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then v:Destroy() end end
        Lighting.GlobalShadows=false; Lighting.FogEnd=99999; settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end) end end})

HomeTab:CreateSection("🏃 Player")

HomeTab:CreateSlider({Name="Walk Speed", Range={16,500}, Increment=1, Suffix="speed", CurrentValue=16, Flag="H_WS", Callback=function(V) pcall(function() Humanoid.WalkSpeed=V end) end})
HomeTab:CreateSlider({Name="Jump Power", Range={50,500}, Increment=1, Suffix="power", CurrentValue=50, Flag="H_JP", Callback=function(V) pcall(function() Humanoid.UseJumpPower=true; Humanoid.JumpPower=V end) end})
HomeTab:CreateToggle({Name="♾️ Infinite Jump", CurrentValue=false, Flag="H_InfJump", Callback=function(V) HS.InfJump=V end})
HomeTab:CreateToggle({Name="👻 Noclip", CurrentValue=false, Flag="H_Noclip", Callback=function(V) HS.Noclip=V end})

HomeTab:CreateToggle({Name="🛡️ God Mode", CurrentValue=false, Flag="H_GodMode",
    Callback=function(V) HS.GodMode=V; task.spawn(function() while HS.GodMode do task.wait(0.1)
        pcall(function() Humanoid.Health=Humanoid.MaxHealth end) end end) end})

local h_flyBV, h_flyBG
HomeTab:CreateToggle({Name="✈️ Fly", CurrentValue=false, Flag="H_Fly",
    Callback=function(V) HS.Fly=V; Flying=V; if V then
        h_flyBV=Instance.new("BodyVelocity"); h_flyBV.MaxForce=Vector3.new(1e9,1e9,1e9); h_flyBV.Velocity=Vector3.zero; h_flyBV.Parent=HumanoidRootPart
        h_flyBG=Instance.new("BodyGyro"); h_flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); h_flyBG.P=9e4; h_flyBG.Parent=HumanoidRootPart
        task.spawn(function() while HS.Fly do RunService.Heartbeat:Wait()
            pcall(function() local cam=Workspace.CurrentCamera
                if Humanoid.MoveDirection.Magnitude>0 then h_flyBV.Velocity=cam.CFrame.LookVector*HS.FlySpeed else h_flyBV.Velocity=Vector3.zero end
                h_flyBG.CFrame=cam.CFrame end) end end)
    else pcall(function() h_flyBV:Destroy() end); pcall(function() h_flyBG:Destroy() end) end end})

HomeTab:CreateSlider({Name="Fly Speed", Range={10,500}, Increment=5, Suffix="speed", CurrentValue=50, Flag="H_FlySpd", Callback=function(V) HS.FlySpeed=V end})

HomeTab:CreateSection("👁 Visuals")

HomeTab:CreateToggle({Name="👁 ESP Players", CurrentValue=false, Flag="H_ESP",
    Callback=function(V)
        if V then
            local function h_addESP(player)
                if player==LocalPlayer then return end
                local function onChar(char)
                    local head=char:WaitForChild("Head",5); if not head then return end
                    local bb=Instance.new("BillboardGui"); bb.Name="HDMM_ESP"; bb.Adornee=head; bb.Size=UDim2.new(0,120,0,50)
                    bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=head
                    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0.5,0); nl.BackgroundTransparency=1
                    nl.TextColor3=Color3.fromRGB(255,50,50); nl.TextStrokeTransparency=0.5; nl.Text=player.Name; nl.TextScaled=true; nl.Font=Enum.Font.GothamBold; nl.Parent=bb
                    local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0.5,0); dl.Position=UDim2.new(0,0,0.5,0); dl.BackgroundTransparency=1
                    dl.TextColor3=Color3.new(1,1,1); dl.TextStrokeTransparency=0.5; dl.TextScaled=true; dl.Font=Enum.Font.Gotham; dl.Parent=bb
                    local hl=Instance.new("Highlight"); hl.Name="HDMM_HL"; hl.FillColor=Color3.fromRGB(255,0,0); hl.FillTransparency=0.7; hl.OutlineColor=Color3.fromRGB(255,255,0); hl.Parent=char
                    task.spawn(function() while char.Parent and head.Parent do pcall(function()
                        dl.Text="["..math.floor((HumanoidRootPart.Position-head.Position).Magnitude).."m]" end); task.wait(0.5) end end)
                end
                if player.Character then onChar(player.Character) end
                player.CharacterAdded:Connect(onChar)
            end
            for _, p in pairs(Players:GetPlayers()) do h_addESP(p) end
            Players.PlayerAdded:Connect(h_addESP)
        else
            for _, p in pairs(Players:GetPlayers()) do if p.Character then
                for _, v in pairs(p.Character:GetDescendants()) do if v.Name=="HDMM_ESP" or v.Name=="HDMM_HL" then v:Destroy() end end end end
        end
    end})

HomeTab:CreateToggle({Name="💡 Fullbright", CurrentValue=false, Flag="H_FB",
    Callback=function(V) if V then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=1e6; Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(178,178,178)
    else Lighting.Brightness=1; Lighting.ClockTime=14; Lighting.FogEnd=1e4; Lighting.GlobalShadows=true; Lighting.Ambient=Color3.fromRGB(0,0,0) end end})

HomeTab:CreateButton({Name="✨ TetraCube Wings", Callback=function()
    pcall(function() for i=-1,1,2 do local w=Instance.new("Part"); w.Name="HDMM_Wing"; w.Size=Vector3.new(0.2,4,3); w.Color=Color3.fromRGB(100,0,255)
        w.Material=Enum.Material.Neon; w.Transparency=0.3; w.CanCollide=false; w.Massless=true; w.Parent=Character
        local weld=Instance.new("Weld"); weld.Part0=HumanoidRootPart; weld.Part1=w; weld.C0=CFrame.new(i*1.5,0.5,0.8)*CFrame.Angles(0,0,math.rad(-30*i)); weld.Parent=w end end)
    Rayfield:Notify({Title="DMM",Content="Wings added!",Duration=2}) end})

HomeTab:CreateSection("🌀 Teleport")

HomeTab:CreateDropdown({Name="TP to Player", Options=getPlayerList(), CurrentOption={}, MultiOption=false, Flag="H_TpPlr",
    Callback=function(Opt) pcall(function() local t=Players:FindFirstChild(Opt); if h_alive(t) then IsTeleporting=true
        HumanoidRootPart.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0); Rayfield:Notify({Title="DMM",Content="TP'd to "..Opt,Duration=2})
        task.defer(function() task.wait(0.5); IsTeleporting=false end) end end) end})

HomeTab:CreateToggle({Name="🔄 Loop TP to Selected", CurrentValue=false, Flag="H_LoopTP",
    Callback=function(V) HS.LoopTP=V; task.spawn(function() while HS.LoopTP do RunService.Heartbeat:Wait()
        pcall(function() if h_alive(HSelPlayer) then HumanoidRootPart.CFrame=HSelPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3) end end) end end) end})

HomeTab:CreateButton({Name="🏠 TP to Spawn", Callback=function() pcall(function() IsTeleporting=true
    local sp=Workspace:FindFirstChildWhichIsA("SpawnLocation",true); if sp then HumanoidRootPart.CFrame=sp.CFrame+Vector3.new(0,5,0) else HumanoidRootPart.CFrame=CFrame.new(0,50,0) end
    task.defer(function() task.wait(0.5); IsTeleporting=false end) end) end})

HomeTab:CreateButton({Name="🎲 TP to Random", Callback=function() pcall(function()
    local list={}; for _, p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and h_alive(p) then table.insert(list,p) end end
    if #list>0 then IsTeleporting=true; local r=list[math.random(#list)]; HumanoidRootPart.CFrame=r.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
        Rayfield:Notify({Title="DMM",Content="TP'd to "..r.Name,Duration=2}); task.defer(function() task.wait(0.5); IsTeleporting=false end) end end) end})

HomeTab:CreateSection("💥 Server Attacks")

HomeTab:CreateToggle({Name="💥 Destroy Server", CurrentValue=false, Flag="H_DestroyServer",
    Callback=function(V) HS.DestroyServer=V; task.spawn(function() while HS.DestroyServer do task.wait(0.1)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and h_alive(p) then h_flingPlayer(p)
            local blob=getBlobman(); if blob then h_blobKickPlayer(blob, p) end end end) end end end) end})

HomeTab:CreateToggle({Name="📡 Lag Server", CurrentValue=false, Flag="H_LagSrv",
    Callback=function(V) HS.LagServer=V; task.spawn(function() while HS.LagServer do task.wait(0.01)
        pcall(function() for _, r in pairs(ReplicatedStorage:GetDescendants()) do if r:IsA("RemoteEvent") then for i=1,5 do r:FireServer(string.rep("lag",500)) end end end end) end end) end})

HomeTab:CreateToggle({Name="🔥 Burn ALL", CurrentValue=false, Flag="H_BurnAll",
    Callback=function(V) HS.BurnAll=V; task.spawn(function() while HS.BurnAll do task.wait(1)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and h_alive(p) then h_applyGrabEffect(p,"Burn") end end) end end end) end})

HomeTab:CreateToggle({Name="🔗 Bring Server", CurrentValue=false, Flag="H_BringAll",
    Callback=function(V) HS.BringServer=V; task.spawn(function() while HS.BringServer do task.wait(0.3)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and h_alive(p) then
            p.Character.HumanoidRootPart.CFrame=HumanoidRootPart.CFrame*CFrame.new(math.random(-5,5),0,math.random(-5,5)) end end) end end end) end})

HomeTab:CreateSection("🎮 FE Objects")

HomeTab:CreateToggle({Name="🌪️ FE Tornado", CurrentValue=false, Flag="H_FeTornado",
    Callback=function(V) HS.FeObjectTornado=V; task.spawn(function() local angle=0; while HS.FeObjectTornado do RunService.Heartbeat:Wait(); angle=angle+5
        pcall(function() for _, obj in pairs(Workspace:GetChildren()) do if obj:IsA("BasePart") and not obj.Anchored and obj~=HumanoidRootPart and not obj:IsDescendantOf(Character) then
            obj.CFrame=CFrame.new(HumanoidRootPart.Position.X+math.cos(math.rad(angle))*20, HumanoidRootPart.Position.Y+(angle%360)/36, HumanoidRootPart.Position.Z+math.sin(math.rad(angle))*20) end end end) end end) end})

HomeTab:CreateToggle({Name="🌐 FE Aura", CurrentValue=false, Flag="H_FeAura",
    Callback=function(V) HS.FeObjectAura=V; task.spawn(function() local a=0; while HS.FeObjectAura do RunService.Heartbeat:Wait(); a=a+3
        pcall(function() local i=0; for _, obj in pairs(Workspace:GetChildren()) do if obj:IsA("BasePart") and not obj.Anchored and obj~=HumanoidRootPart and not obj:IsDescendantOf(Character) then
            i=i+1; local ang=math.rad(a+i*30); obj.CFrame=HumanoidRootPart.CFrame*CFrame.new(math.cos(ang)*10,2,math.sin(ang)*10) end end end) end end) end})

HomeTab:CreateToggle({Name="☁️ FE Float", CurrentValue=false, Flag="H_FeFloat",
    Callback=function(V) HS.FeObjectFloat=V; task.spawn(function() while HS.FeObjectFloat do task.wait(0.1)
        pcall(function() for _, obj in pairs(Workspace:GetChildren()) do if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(Character) then
            local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(0,1e5,0); bv.Velocity=Vector3.new(0,30,0); bv.Parent=obj; Debris:AddItem(bv,0.5) end end end) end end) end})

HomeTab:CreateToggle({Name="🔊 Spam Sounds", CurrentValue=false, Flag="H_SpamSnd",
    Callback=function(V) HS.SpamSounds=V; task.spawn(function() while HS.SpamSounds do task.wait(0.1)
        pcall(function() for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("Sound") then obj:Play() end end end) end end) end})

HomeTab:CreateSection("⚙️ Utility")

HomeTab:CreateToggle({Name="💰 Auto Claim Cash", CurrentValue=false, Flag="H_AutoCash",
    Callback=function(V) HS.AutoCash=V; task.spawn(function() while HS.AutoCash do task.wait(0.5)
        pcall(function() for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("ProximityPrompt") then fireproximityprompt(obj) end end
            for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("cash")) then
                firetouchinterest(HumanoidRootPart,obj,0); task.wait(0.02); firetouchinterest(HumanoidRootPart,obj,1) end end end) end end) end})

HomeTab:CreateToggle({Name="🚫 Anti AFK", CurrentValue=true, Flag="H_AntiAFK",
    Callback=function(V) if V then LocalPlayer.Idled:Connect(function()
        VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.W,false,game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.W,false,game) end) end end})

HomeTab:CreateToggle({Name="🖱️ Click Teleport", CurrentValue=false, Flag="H_ClickTP", Callback=function(V) HS.ClickTP=V end})
do local mouse=LocalPlayer:GetMouse(); mouse.Button1Down:Connect(function()
    if HS.ClickTP and mouse.Hit then IsTeleporting=true; HumanoidRootPart.CFrame=mouse.Hit+Vector3.new(0,3,0)
        task.defer(function() task.wait(0.5); IsTeleporting=false end) end end) end

HomeTab:CreateButton({Name="🔄 Rejoin Server", Callback=function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end})

HomeTab:CreateButton({Name="🌐 Server Hop", Callback=function() pcall(function()
    local data=game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in pairs(data.data) do if s.playing<s.maxPlayers and s.id~=game.JobId then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer); break end end end) end})

HomeTab:CreateButton({Name="📋 Copy Game Link", Callback=function()
    pcall(function() setclipboard("https://www.roblox.com/games/"..game.PlaceId) end)
    Rayfield:Notify({Title="DMM",Content="Link copied!",Duration=2}) end})

HomeTab:CreateButton({Name="❌ Destroy DMM HUB", Callback=function()
    Flying=false; AntiGrabEnabled=false; AntiDetectedEnabled=false; AntiAllHacksEnabled=false; LoopResetEnabled=false
    for _, conn in pairs(AntiAllHacksConnections) do pcall(function() conn:Disconnect() end) end; Rayfield:Destroy() end})

-- ═══════════════════════════════════════════════════
-- TAB: 🦠 BLOBMEN
-- ═══════════════════════════════════════════════════
local BlobTab = Window:CreateTab("🦠 Blobmen", 0)
BlobTab:CreateSection("Blobman Controls")

BlobTab:CreateToggle({Name="Blobman Grab", CurrentValue=false, Flag="BlobGrab",
    Callback=function(V) Settings.BlobmanGrab=V; if V then task.spawn(function() while Settings.BlobmanGrab do task.wait(0.1)
        pcall(function() local blob=getBlobman(); if blob then local r=getGrabbableRemote(); if r then r:FireServer(blob) end
            local part=blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
            if part and HumanoidRootPart then firetouchinterest(HumanoidRootPart,part,0); task.wait(0.05); firetouchinterest(HumanoidRootPart,part,1) end end end) end end) end end})

BlobTab:CreateToggle({Name="Loop Grab All", CurrentValue=false, Flag="BlobLoopGrabAll",
    Callback=function(V) Settings.BlobmanLoopGrab=V; task.spawn(function() while Settings.BlobmanLoopGrab do task.wait(0.15)
        pcall(function() local blob=getBlobman(); if blob then local bp=blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
            if bp then for _, p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                bp.CFrame=p.Character.HumanoidRootPart.CFrame; task.wait(0.05)
                firetouchinterest(bp,p.Character.HumanoidRootPart,0); task.wait(0.05); firetouchinterest(bp,p.Character.HumanoidRootPart,1) end end end end end) end end) end})

BlobTab:CreateButton({Name="Blobman Free", Callback=function() pcall(function()
    for _, r in pairs(ReplicatedStorage:GetDescendants()) do if r:IsA("RemoteEvent") and (r.Name:lower():find("spawn") or r.Name:lower():find("buy") or r.Name:lower():find("summon")) then
        r:FireServer("BlobMan"); r:FireServer("Blobman") end end end); Rayfield:Notify({Title="DMM",Content="Attempted spawn!",Duration=3}) end})

BlobTab:CreateDropdown({Name="Blob TP to Player", Options=getPlayerList(), CurrentOption={}, MultiOption=false, Flag="BlobTP",
    Callback=function(Opt) pcall(function() local t=Players:FindFirstChild(Opt); local blob=getBlobman()
        if t and t.Character and blob then local bp=blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
            if bp and t.Character:FindFirstChild("HumanoidRootPart") then bp.CFrame=t.Character.HumanoidRootPart.CFrame end end end) end})

BlobTab:CreateButton({Name="Multiple Blob Grab", Callback=function() pcall(function()
    for _, b in pairs(getAllBlobmen()) do local part=b:IsA("BasePart") and b or b:FindFirstChildWhichIsA("BasePart")
        if part then firetouchinterest(HumanoidRootPart,part,0); task.wait(0.05); firetouchinterest(HumanoidRootPart,part,1) end end end)
    Rayfield:Notify({Title="DMM",Content="Grabbed all!",Duration=3}) end})

BlobTab:CreateSection("Grab Mods")

BlobTab:CreateToggle({Name="Kill Grab", CurrentValue=false, Flag="KillGrab",
    Callback=function(V) Settings.KillGrab=V; task.spawn(function() while Settings.KillGrab do task.wait(0.1)
        pcall(function() local t=getClosestPlayer(AuraRange); if t and t.Character then local hrp=t.Character:FindFirstChild("HumanoidRootPart")
            if hrp then HumanoidRootPart.CFrame=hrp.CFrame*CFrame.new(0,0,-2); applyVelocity(hrp,Vector3.new(0,-1000,0),9999) end end end) end end) end})

BlobTab:CreateToggle({Name="Void Grab", CurrentValue=false, Flag="VoidGrab",
    Callback=function(V) Settings.VoidGrab=V; task.spawn(function() while Settings.VoidGrab do task.wait(0.2)
        pcall(function() local t=getClosestPlayer(AuraRange); if t then voidPlayer(t) end end) end end) end})

BlobTab:CreateToggle({Name="Poison Grab", CurrentValue=false, Flag="PoisonGrab",
    Callback=function(V) Settings.PoisonGrab=V; task.spawn(function() while Settings.PoisonGrab do task.wait(0.3)
        pcall(function() local t=getClosestPlayer(AuraRange); if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local r=getDamageRemote(); if r then r:FireServer(t.Character.HumanoidRootPart,"Poison") end
            local p=Instance.new("Part"); p.Size=Vector3.new(1,1,1); p.Color=Color3.fromRGB(0,255,0); p.Material=Enum.Material.Neon; p.Anchored=true; p.CanCollide=false
            p.Transparency=0.5; p.CFrame=t.Character.HumanoidRootPart.CFrame; p.Shape=Enum.PartType.Ball; p.Parent=Workspace; Debris:AddItem(p,0.5) end end) end end) end})

BlobTab:CreateToggle({Name="Radioactive Grab", CurrentValue=false, Flag="RadioGrab",
    Callback=function(V) Settings.RadioactiveGrab=V; task.spawn(function() while Settings.RadioactiveGrab do task.wait(0.2)
        pcall(function() local t=getClosestPlayer(AuraRange); if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local r=getDamageRemote(); if r then r:FireServer(t.Character.HumanoidRootPart,"Radioactive") end
            local p=Instance.new("Part"); p.Size=Vector3.new(2,2,2); p.Color=Color3.fromRGB(255,255,0); p.Material=Enum.Material.Neon; p.Anchored=true; p.CanCollide=false
            p.Transparency=0.4; p.CFrame=t.Character.HumanoidRootPart.CFrame; p.Shape=Enum.PartType.Ball; p.Parent=Workspace; Debris:AddItem(p,0.5) end end) end end) end})

BlobTab:CreateToggle({Name="Freeze Grab", CurrentValue=false, Flag="FreezeGrab",
    Callback=function(V) Settings.FreezeGrab=V; task.spawn(function() while Settings.FreezeGrab do task.wait(0.3)
        pcall(function() local t=getClosestPlayer(AuraRange); if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            t.Character.HumanoidRootPart.Anchored=true; task.delay(3, function() pcall(function() t.Character.HumanoidRootPart.Anchored=false end) end) end end) end end) end})

BlobTab:CreateSlider({Name="Grab Range", Range={10,200}, Increment=5, Suffix="studs", CurrentValue=30, Flag="AuraRange", Callback=function(V) AuraRange=V end})

-- ═══════════════════════════════════════════════════
-- TAB: ⚡ KICKS
-- ═══════════════════════════════════════════════════
local KickTab = Window:CreateTab("⚡ Kicks", 0)
KickTab:CreateSection("Kick Players")

KickTab:CreateDropdown({Name="Select Player", Options=getPlayerList(), CurrentOption={}, MultiOption=false, Flag="KickTarget",
    Callback=function(Opt) SelectedPlayer=Players:FindFirstChild(Opt) end})

KickTab:CreateButton({Name="⚡ Instant Kick", Callback=function() pcall(function()
    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local blob=getBlobman(); if blob then local bp=blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
            if bp then for i=1,20 do bp.CFrame=SelectedPlayer.Character.HumanoidRootPart.CFrame; applyVelocity(SelectedPlayer.Character.HumanoidRootPart,Vector3.new(0,5000,0),9999); task.wait(0.05) end end
        else for i=1,30 do HumanoidRootPart.CFrame=SelectedPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-1); Humanoid.WalkSpeed=500
            applyVelocity(SelectedPlayer.Character.HumanoidRootPart,(SelectedPlayer.Character.HumanoidRootPart.Position-HumanoidRootPart.Position).Unit*3000+Vector3.new(0,2000,0),1); task.wait(0.05) end
            Humanoid.WalkSpeed=WalkSpeedVal end
        Rayfield:Notify({Title="DMM",Content="Kicked "..SelectedPlayer.Name.."!",Duration=3})
    else Rayfield:Notify({Title="DMM",Content="Select player first!",Duration=3}) end end) end})

KickTab:CreateToggle({Name="🔄 Loop Kick", CurrentValue=false, Flag="LoopKick",
    Callback=function(V) Settings.LoopKick=V; task.spawn(function() while Settings.LoopKick do task.wait(0.5)
        pcall(function() if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            flingPlayer(SelectedPlayer); applyVelocity(SelectedPlayer.Character.HumanoidRootPart,Vector3.new(math.random(-1,1),5,math.random(-1,1)),3000) end end) end end) end})

KickTab:CreateButton({Name="💥 Kick ALL", Callback=function() task.spawn(function()
    for _, p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function() flingPlayer(p); applyVelocity(p.Character.HumanoidRootPart,Vector3.new(math.random(-1,1),5,math.random(-1,1)),3000) end); task.wait(0.2) end end end)
    Rayfield:Notify({Title="DMM",Content="Kicked all!",Duration=3}) end})

KickTab:CreateToggle({Name="🔄 Loop Kill Selected", CurrentValue=false, Flag="LoopKillPlayer",
    Callback=function(V) Settings.LoopKillPlayer=V; task.spawn(function() while Settings.LoopKillPlayer do task.wait(0.3)
        pcall(function() if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            SelectedPlayer.Character.HumanoidRootPart.CFrame=CFrame.new(0,-500,0) end end) end end) end})

KickTab:CreateToggle({Name="💀 Loop Kill ALL", CurrentValue=false, Flag="LoopKillAll",
    Callback=function(V) Settings.LoopKillAll=V; task.spawn(function() while Settings.LoopKillAll do task.wait(0.3)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame=CFrame.new(0,-500,0) end end) end end end) end})

KickTab:CreateSection("Settings")
KickTab:CreateSlider({Name="Fling Power", Range={100,10000}, Increment=100, Suffix="force", CurrentValue=500, Flag="FlingPower", Callback=function(V) FlingPower=V end})

-- ═══════════════════════════════════════════════════
-- TAB: ⚔️ COMBAT
-- ═══════════════════════════════════════════════════
local CombatTab = Window:CreateTab("⚔️ Combat", 0)
CombatTab:CreateSection("Offensive")

CombatTab:CreateToggle({Name="Super Throw", CurrentValue=false, Flag="SuperThrow", Callback=function(V) Settings.SuperThrow=V end})
CombatTab:CreateSlider({Name="Throw Power", Range={100,5000}, Increment=50, Suffix="force", CurrentValue=300, Flag="ThrowPower", Callback=function(V) ThrowPower=V end})
CombatTab:CreateToggle({Name="Super Strength", CurrentValue=false, Flag="SuperStrength", Callback=function(V) Settings.SuperStrength=V end})
CombatTab:CreateToggle({Name="Silent Aim", CurrentValue=false, Flag="SilentAim", Callback=function(V) Settings.SilentAim=V end})

CombatTab:CreateToggle({Name="Position Damage", CurrentValue=false, Flag="PosDamage",
    Callback=function(V) Settings.PositionDamage=V; task.spawn(function() while Settings.PositionDamage do task.wait(0.2)
        pcall(function() local t=getClosestPlayer(AuraRange); if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local r=getDamageRemote(); if r then r:FireServer(t, t.Character.HumanoidRootPart.Position) end end end) end end) end})

CombatTab:CreateSection("Auras")

CombatTab:CreateToggle({Name="Fling Aura", CurrentValue=false, Flag="C_FlingAura",
    Callback=function(V) Settings.FlingAura=V; task.spawn(function() while Settings.FlingAura do task.wait(0.2)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude<=AuraRange then flingPlayer(p) end end end) end end end) end})

CombatTab:CreateToggle({Name="Void Aura", CurrentValue=false, Flag="C_VoidAura",
    Callback=function(V) Settings.VoidAura=V; task.spawn(function() while Settings.VoidAura do task.wait(0.5)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude<=AuraRange then voidPlayer(p) end end end) end end end) end})

CombatTab:CreateToggle({Name="Follow Aura", CurrentValue=false, Flag="C_FollowAura",
    Callback=function(V) Settings.FollowAura=V; task.spawn(function() while Settings.FollowAura do RunService.Heartbeat:Wait()
        pcall(function() if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            HumanoidRootPart.CFrame=SelectedPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3) end end) end end) end})

CombatTab:CreateToggle({Name="Kill Aura", CurrentValue=false, Flag="C_KillAura",
    Callback=function(V) Settings.KillAura=V; task.spawn(function() while Settings.KillAura do task.wait(0.3)
        for _, p in pairs(Players:GetPlayers()) do pcall(function() if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (HumanoidRootPart.Position-p.Character.HumanoidRootPart.Position).Magnitude<=AuraRange then p.Character.HumanoidRootPart.CFrame=CFrame.new(0,-500,0) end end end) end end end) end})

CombatTab:CreateSection("Defensive")

CombatTab:CreateToggle({Name="Anti Grab", CurrentValue=false, Flag="C_AntiGrab",
    Callback=function(V) Settings.AntiGrab=V; task.spawn(function() while Settings.AntiGrab do task.wait(0.1)
        pcall(function() for _, v in pairs(Character:GetDescendants()) do if (v:IsA("Weld") or v:IsA("WeldConstraint")) and v.Part0 and v.Part1 then
            if not v.Part0:IsDescendantOf(Character) or not v.Part1:IsDescendantOf(Character) then v:Destroy() end end end end) end end) end})

CombatTab:CreateToggle({Name="Anti Explosion", CurrentValue=false, Flag="C_AntiExplosion", Callback=function(V) Settings.AntiExplosion=V end})

CombatTab:CreateToggle({Name="Anti Kick", CurrentValue=false, Flag="C_AntiKick",
    Callback=function(V) Settings.AntiKick=V; task.spawn(function() while Settings.AntiKick do task.wait(0.05)
        pcall(function() if HumanoidRootPart.Velocity.Magnitude>200 then HumanoidRootPart.Velocity=Vector3.zero; HumanoidRootPart.RotVelocity=Vector3.zero end
            for _, v in pairs(HumanoidRootPart:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") then v:Destroy() end end end) end end) end})

-- ═══════════════════════════════════════════════════
-- TAB: 🏃 PLAYER
-- ═══════════════════════════════════════════════════
local PlayerTab = Window:CreateTab("🏃 Player", 0)

PlayerTab:CreateSlider({Name="Walk Speed", Range={16,500}, Increment=1, Suffix="Speed", CurrentValue=16, Flag="WalkSpeed",
    Callback=function(V) WalkSpeedVal=V; if Humanoid then Humanoid.WalkSpeed=V end end})

PlayerTab:CreateSlider({Name="Jump Power", Range={50,500}, Increment=1, Suffix="Power", CurrentValue=50, Flag="JumpPower",
    Callback=function(V) JumpPowerVal=V; if Humanoid then Humanoid.UseJumpPower=true; Humanoid.JumpPower=V end end})

PlayerTab:CreateToggle({Name="Infinite Jump", CurrentValue=false, Flag="P_InfJump", Callback=function(V) Settings.InfJump=V end})
UserInputService.JumpRequest:Connect(function() if Settings.InfJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

PlayerTab:CreateToggle({Name="Noclip", CurrentValue=false, Flag="P_Noclip", Callback=function(V) Settings.Noclip=V end})
RunService.Stepped:Connect(function() if Settings.Noclip and Character then for _, part in pairs(Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end end)

PlayerTab:CreateToggle({Name="Speed Hack", CurrentValue=false, Flag="SpeedHack",
    Callback=function(V) Settings.SpeedHack=V; task.spawn(function() while Settings.SpeedHack do RunService.Heartbeat:Wait()
        pcall(function() if Humanoid and Humanoid.MoveDirection.Magnitude>0 then HumanoidRootPart.CFrame=HumanoidRootPart.CFrame+Humanoid.MoveDirection*2 end end) end end) end})

PlayerTab:CreateToggle({Name="God Mode", CurrentValue=false, Flag="P_GodMode",
    Callback=function(V) Settings.GodMode=V; if V then task.spawn(function() while Settings.GodMode do pcall(function() Humanoid.Health=Humanoid.MaxHealth end); task.wait(0.1) end end) end end})

local p_flyBV, p_flyBG
PlayerTab:CreateToggle({Name="Fly", CurrentValue=false, Flag="P_Fly",
    Callback=function(V) Flying=V; if V then
        p_flyBV=Instance.new("BodyVelocity"); p_flyBV.MaxForce=Vector3.new(math.huge,math.huge,math.huge); p_flyBV.Velocity=Vector3.zero; p_flyBV.Parent=HumanoidRootPart
        p_flyBG=Instance.new("BodyGyro"); p_flyBG.MaxTorque=Vector3.new(math.huge,math.huge,math.huge); p_flyBG.P=9e4; p_flyBG.Parent=HumanoidRootPart
        task.spawn(function() while Flying do RunService.Heartbeat:Wait()
            pcall(function() local cam=Workspace.CurrentCamera; if Humanoid.MoveDirection.Magnitude>0 then p_flyBV.Velocity=cam.CFrame.LookVector*50 else p_flyBV.Velocity=Vector3.zero end; p_flyBG.CFrame=cam.CFrame end) end end)
    else pcall(function() p_flyBV:Destroy() end); pcall(function() p_flyBG:Destroy() end) end end})

-- ═══════════════════════════════════════════════════
-- TAB: 👁 VISUALS
-- ═══════════════════════════════════════════════════
local VisualsTab = Window:CreateTab("👁 Visuals", 0)

VisualsTab:CreateToggle({Name="ESP Players", CurrentValue=false, Flag="ESP",
    Callback=function(V)
        if V then
            local function addESP(player)
                if player==LocalPlayer then return end
                local function onChar(char)
                    local head=char:WaitForChild("Head",5); if not head then return end
                    local bb=Instance.new("BillboardGui"); bb.Name="DMM_ESP"; bb.Adornee=head; bb.Size=UDim2.new(0,120,0,50)
                    bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Parent=head
                    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,0.5,0); nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(255,50,50)
                    nl.TextStrokeTransparency=0.5; nl.Text=player.Name; nl.TextScaled=true; nl.Font=Enum.Font.GothamBold; nl.Parent=bb
                    local dl=Instance.new("TextLabel"); dl.Size=UDim2.new(1,0,0.5,0); dl.Position=UDim2.new(0,0,0.5,0); dl.BackgroundTransparency=1
                    dl.TextColor3=Color3.new(1,1,1); dl.TextStrokeTransparency=0.5; dl.TextScaled=true; dl.Font=Enum.Font.Gotham; dl.Parent=bb
                    local hl=Instance.new("Highlight"); hl.Name="DMM_HL"; hl.FillColor=Color3.fromRGB(255,0,0); hl.FillTransparency=0.7; hl.OutlineColor=Color3.fromRGB(255,255,0); hl.Parent=char
                    task.spawn(function() while char and char.Parent and head and head.Parent do pcall(function()
                        dl.Text="["..math.floor((HumanoidRootPart.Position-head.Position).Magnitude).."m]" end); task.wait(0.5) end end)
                end
                if player.Character then onChar(player.Character) end; player.CharacterAdded:Connect(onChar)
            end
            for _, p in pairs(Players:GetPlayers()) do addESP(p) end; Players.PlayerAdded:Connect(addESP)
        else for _, p in pairs(Players:GetPlayers()) do if p.Character then for _, v in pairs(p.Character:GetDescendants()) do
            if v.Name=="DMM_ESP" or v.Name=="DMM_HL" then v:Destroy() end end end end end end})

VisualsTab:CreateToggle({Name="Fullbright", CurrentValue=false, Flag="Fullbright",
    Callback=function(V) if V then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(178,178,178)
    else Lighting.Brightness=1; Lighting.ClockTime=14; Lighting.FogEnd=10000; Lighting.GlobalShadows=true; Lighting.Ambient=Color3.fromRGB(0,0,0) end end})

VisualsTab:CreateButton({Name="✨ Wings", Callback=function() pcall(function()
    local w1=Instance.new("Part"); w1.Name="DMM_Wing"; w1.Size=Vector3.new(0.2,4,3); w1.Color=Color3.fromRGB(100,0,255); w1.Material=Enum.Material.Neon
    w1.Transparency=0.3; w1.CanCollide=false; w1.Massless=true; w1.Parent=Character
    local wd1=Instance.new("Weld"); wd1.Part0=HumanoidRootPart; wd1.Part1=w1; wd1.C0=CFrame.new(-1.5,0.5,0.8)*CFrame.Angles(0,0,math.rad(-30)); wd1.Parent=w1
    local w2=w1:Clone(); w2.Parent=Character; local wd2=Instance.new("Weld"); wd2.Part0=HumanoidRootPart; wd2.Part1=w2; wd2.C0=CFrame.new(1.5,0.5,0.8)*CFrame.Angles(0,0,math.rad(30)); wd2.Parent=w2 end)
    Rayfield:Notify({Title="DMM",Content="Wings added!",Duration=3}) end})

-- ═══════════════════════════════════════════════════
-- TAB: 🌀 TELEPORT
-- ═══════════════════════════════════════════════════
local TeleportTab = Window:CreateTab("🌀 Teleport", 0)

TeleportTab:CreateDropdown({Name="TP to Player", Options=getPlayerList(), CurrentOption={}, MultiOption=false, Flag="TpPlayer",
    Callback=function(Opt) pcall(function() local t=Players:FindFirstChild(Opt); if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
        IsTeleporting=true; HumanoidRootPart.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
        Rayfield:Notify({Title="DMM",Content="TP'd to "..Opt,Duration=2}); task.defer(function() task.wait(0.5); IsTeleporting=false end) end end) end})

TeleportTab:CreateButton({Name="TP to Spawn", Callback=function() pcall(function() IsTeleporting=true
    local sp=Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildWhichIsA("SpawnLocation",true)
    if sp then HumanoidRootPart.CFrame=sp.CFrame+Vector3.new(0,5,0) else HumanoidRootPart.CFrame=CFrame.new(0,50,0) end
    task.defer(function() task.wait(0.5); IsTeleporting=false end) end) end})

TeleportTab:CreateButton({Name="TP Random", Callback=function() pcall(function() local plrs={}
    for _, p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(plrs,p) end end
    if #plrs>0 then IsTeleporting=true; local r=plrs[math.random(1,#plrs)]; HumanoidRootPart.CFrame=r.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
        Rayfield:Notify({Title="DMM",Content="TP'd to "..r.Name,Duration=2}); task.defer(function() task.wait(0.5); IsTeleporting=false end) end end) end})

-- ═══════════════════════════════════════════════════
-- TAB: ⚙️ MISC
-- ═══════════════════════════════════════════════════
local MiscTab = Window:CreateTab("⚙ Misc", 0)

MiscTab:CreateToggle({Name="Anti AFK", CurrentValue=true, Flag="AntiAFK",
    Callback=function(V) if V then LocalPlayer.Idled:Connect(function()
        VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.W,false,game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.W,false,game) end) end end})

MiscTab:CreateToggle({Name="Auto Cash", CurrentValue=false, Flag="AutoCash",
    Callback=function(V) Settings.AutoClaimCash=V; task.spawn(function() while Settings.AutoClaimCash do task.wait(1)
        pcall(function() for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("ProximityPrompt") then fireproximityprompt(obj) end end
            local cr=getCashRemote(); if cr then cr:FireServer() end
            for _, obj in pairs(Workspace:GetDescendants()) do if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("cash") or obj.Name:lower():find("money")) then
                firetouchinterest(HumanoidRootPart,obj,0); task.wait(0.05); firetouchinterest(HumanoidRootPart,obj,1) end end end) end end) end})

local clickTpEnabled = false
MiscTab:CreateToggle({Name="Click TP", CurrentValue=false, Flag="ClickTP", Callback=function(V) clickTpEnabled=V end})
Mouse.Button1Down:Connect(function() if clickTpEnabled and Mouse.Hit then IsTeleporting=true; HumanoidRootPart.CFrame=Mouse.Hit+Vector3.new(0,3,0)
    task.defer(function() task.wait(0.5); IsTeleporting=false end) end end)

MiscTab:CreateButton({Name="🔄 Rejoin", Callback=function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,LocalPlayer) end})

MiscTab:CreateButton({Name="🌐 Server Hop", Callback=function() pcall(function()
    local data=game.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in pairs(data.data) do if s.playing<s.maxPlayers and s.id~=game.JobId then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,s.id,LocalPlayer); break end end end) end})

MiscTab:CreateButton({Name="📋 Copy Link", Callback=function() setclipboard("https://www.roblox.com/games/"..game.PlaceId)
    Rayfield:Notify({Title="DMM",Content="Copied!",Duration=2}) end})

MiscTab:CreateButton({Name="❌ Destroy HUB", Callback=function() Flying=false; AntiGrabEnabled=false; AntiDetectedEnabled=false
    AntiAllHacksEnabled=false; LoopResetEnabled=false
    for _, conn in pairs(AntiAllHacksConnections) do pcall(function() conn:Disconnect() end) end; Rayfield:Destroy() end})

-- ═══════════════════════════════════════════════════
-- GLOBAL HOOKS
-- ═══════════════════════════════════════════════════

Workspace.DescendantAdded:Connect(function(obj)
    if HS.SuperStrength or Settings.SuperStrength then
        if obj:IsA("BodyPosition") or obj:IsA("BodyVelocity") then
            local f=(HS.StrengthVal or 500)*1000; obj.MaxForce=Vector3.new(f,f,f) end end end)

Workspace.DescendantAdded:Connect(function(obj)
    if (HS.AntiExplosion or Settings.AntiExplosion) and obj:IsA("Explosion") then
        obj.BlastPressure=0; obj.BlastRadius=0; obj.DestroyJointRadiusPercent=0 end end)

UserInputService.JumpRequest:Connect(function()
    if HS.InfJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

RunService.Stepped:Connect(function()
    if HS.Noclip and Character then for _, p in pairs(Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Settings.SuperThrow and method=="FireServer" and self:IsA("RemoteEvent") then
        if self.Name:lower():find("throw") or self.Name:lower():find("fling") or self.Name:lower():find("launch") then
            for i, v in pairs(args) do
                if typeof(v)=="Vector3" then args[i]=v.Unit*ThrowPower end
                if typeof(v)=="number" and v>1 then args[i]=v*(ThrowPower/100) end end
            return oldNamecall(self, unpack(args)) end end
    if (Settings.SilentAim or HS.SilentAim) and method=="FireServer" and self:IsA("RemoteEvent") then
        if self.Name:lower():find("aim") or self.Name:lower():find("shoot") or self.Name:lower():find("hit") then
            local target=getClosestPlayer(AuraRange)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                for i, v in pairs(args) do
                    if typeof(v)=="Vector3" then args[i]=target.Character.HumanoidRootPart.Position end
                    if typeof(v)=="CFrame" then args[i]=target.Character.HumanoidRootPart.CFrame end end end
            return oldNamecall(self, unpack(args)) end end
    return oldNamecall(self, ...)
end))

-- ═══════════════════════════════════════════════════
-- LOADED
-- ═══════════════════════════════════════════════════
Rayfield:Notify({
    Title = "💀 DMM HUB + ⭐ Legend OP",
    Content = "Loaded! Dark-White Theme 🎨\nAnti All Hacks 10x⚡ + Loop Reset 🔄",
    Duration = 5, Image = 0,
})

print("═══════════════════════════════════════")
print("  DMM HUB + ⭐ Legend OP — Loaded!")
print("  Anti-Grab + Anti-Detected")
print("  Anti All Hacks v6.9 — 10x TP × 3 потока")
print("  Loop Reset ⚡ULTRA FAST")
print("  Dark-White Theme 🎨")
print("  All tabs — 0 errors")
print("═══════════════════════════════════════")
