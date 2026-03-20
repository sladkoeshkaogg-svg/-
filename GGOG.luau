-- ╔════════════════════════════════════════════════════════════════╗
-- ║           💀 DMM HUB — Fling Things and People 💀            ║
-- ║              Built on Rayfield | Full Feature                 ║
-- ╚════════════════════════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ═══════ СЕРВИСЫ ═══════
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SG = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")

-- ═══════ SETTINGS ═══════
local S = {
    -- Blobman
    BlobLoopGrabAll = false,
    BlobLoopGrabPlayer = false,
    BlobFree = false,
    BlobFreeze = false,
    SpeedGrab = false,
    -- Grabs
    PoisonGrab = false,
    RadioactiveGrab = false,
    DeathGrab = false,
    BurnGrab = false,
    VoidGrab = false,
    MasslessGrab = false,
    NoclipGrab = false,
    KillGrab = false,
    FreezeGrab = false,
    -- Kicks
    InstantKickBlob = false,
    AutoKickAllBlob = false,
    LoopKickBlob = false,
    -- Kills
    LoopKill = false,
    LoopKillAll = false,
    LoopKillPlayer = false,
    -- Auras
    PoisonAura = false,
    DeathAura = false,
    RadioactiveAura = false,
    BurnAura = false,
    FlingAura = false,
    AttractionAura = false,
    VoidAura = false,
    FollowAura = false,
    KickAura = false,
    -- Combat
    SuperStrength = false,
    StrengthVal = 500,
    SilentAim = false,
    AutoAttacker = false,
    PositionDamage = false,
    -- Antis
    AntiGrab = false,
    AntiExplosion = false,
    AntiKick = false,
    AntiVoid = false,
    AntiBurn = false,
    AntiLag = false,
    AntiBlobman = false,
    GucciAnti = false,
    -- Player
    InfJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    GodMode = false,
    -- Misc
    LagServer = false,
    DestroyServer = false,
    BurnAll = false,
    BringServer = false,
    SpamSounds = false,
    FeObjectTornado = false,
    FeObjectAura = false,
    FeObjectFloat = false,
    LoopRagdoll = false,
    LoopFire = false,
    -- Ranges
    AuraRange = 40,
    FlingPower = 9999,
}

local SelectedPlayer = nil
local SelectedPlayerName = "None"

-- ═══════ CHARACTER UPDATE ═══════
LP.CharacterAdded:Connect(function(c)
    Char = c
    Hum = c:WaitForChild("Humanoid")
    HRP = c:WaitForChild("HumanoidRootPart")
end)

-- ═══════ УТИЛИТЫ ═══════
local function plrList()
    local l = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(l, p.Name) end
    end
    return l
end

local function getPlr(name)
    return Players:FindFirstChild(name)
end

local function alive(p)
    return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0
end

local function dist(p)
    if alive(p) and HRP then
        return (HRP.Position - p.Character.HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function closest(range)
    local best, bestD = nil, range or math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local d = dist(p)
            if d < bestD then best, bestD = p, d end
        end
    end
    return best
end

-- ═══════ BLOBMAN UTILS ═══════
local function getBlobman()
    -- В FTAP blobman это Model с Seat и руками
    for _, m in pairs(WS:GetChildren()) do
        if m:IsA("Model") and (m.Name:lower():find("blob") or m.Name == "BlobMan" or m.Name == "Blobman") then
            return m
        end
    end
    -- Также ищем в глубину
    for _, m in pairs(WS:GetDescendants()) do
        if m:IsA("Model") and (m.Name == "BlobMan" or m.Name == "Blobman") then
            return m
        end
    end
    return nil
end

local function getBlobSeat(blob)
    if blob then
        return blob:FindFirstChildWhichIsA("Seat") or blob:FindFirstChildWhichIsA("VehicleSeat") or blob:FindFirstChild("Seat")
    end
    return nil
end

local function getBlobHands(blob)
    local hands = {}
    if blob then
        for _, p in pairs(blob:GetDescendants()) do
            if p:IsA("BasePart") and (p.Name:lower():find("hand") or p.Name:lower():find("grab") or p.Name:lower():find("palm")) then
                table.insert(hands, p)
            end
        end
        -- Если не нашли по имени, берём все Part кроме Seat
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

-- Сесть на блобмен
local function sitOnBlob(blob)
    local seat = getBlobSeat(blob)
    if seat and HRP then
        HRP.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.1)
        if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
            seat:Sit(Hum)
        end
    end
end

-- Grab player через blob
local function blobGrabPlayer(blob, target)
    pcall(function()
        if not alive(target) or not blob then return end
        local hands = getBlobHands(blob)
        for _, hand in pairs(hands) do
            if hand then
                -- Телепортируем руку блобмена к цели
                hand.CFrame = target.Character.HumanoidRootPart.CFrame
                -- firetouchinterest
                pcall(function()
                    firetouchinterest(hand, target.Character.HumanoidRootPart, 0)
                    task.wait(0.05)
                    firetouchinterest(hand, target.Character.HumanoidRootPart, 1)
                end)
            end
        end
    end)
end

-- Kick через blob: хватаем и бросаем вниз/вверх
local function blobKickPlayer(blob, target)
    pcall(function()
        if not alive(target) or not blob then return end
        local hands = getBlobHands(blob)
        for _, hand in pairs(hands) do
            hand.CFrame = target.Character.HumanoidRootPart.CFrame
            pcall(function()
                firetouchinterest(hand, target.Character.HumanoidRootPart, 0)
            end)
        end
        task.wait(0.1)
        -- Fling: даём velocity
        if alive(target) then
            local hrp = target.Character.HumanoidRootPart
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, S.FlingPower, 0)
            bv.Parent = hrp
            Debris:AddItem(bv, 0.5)
        end
        task.wait(0.15)
        for _, hand in pairs(hands) do
            pcall(function()
                firetouchinterest(hand, target.Character.HumanoidRootPart, 1)
            end)
        end
    end)
end

-- Void player
local function voidPlayer(target)
    pcall(function()
        if alive(target) then
            target.Character.HumanoidRootPart.CFrame = CFrame.new(9e9, 9e9, 9e9)
        end
    end)
end

-- Fling player (fling своим телом)
local function flingPlayer(target)
    pcall(function()
        if not alive(target) then return end
        local tHRP = target.Character.HumanoidRootPart
        -- Способ через velocity spin
        local oldCF = HRP.CFrame
        HRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -1)
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, S.FlingPower, 0)
        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bav.Parent = HRP
        Debris:AddItem(bav, 0.3)
        task.wait(0.3)
        HRP.CFrame = oldCF
    end)
end

-- ═══════ GRAB EFFECT UTILS ═══════
local function applyGrabEffect(target, effectType)
    pcall(function()
        if not alive(target) then return end
        local hrp = target.Character.HumanoidRootPart
        
        if effectType == "Poison" then
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Ball
            p.Size = Vector3.new(3,3,3)
            p.Color = Color3.fromRGB(0, 255, 0)
            p.Material = Enum.Material.Neon
            p.Transparency = 0.4
            p.Anchored = true
            p.CanCollide = false
            p.CFrame = hrp.CFrame
            p.Parent = WS
            Debris:AddItem(p, 0.5)
            -- Damage via network
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.new(0, -50, 0)
            bv.Parent = hrp
            Debris:AddItem(bv, 0.2)

        elseif effectType == "Radioactive" then
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Ball
            p.Size = Vector3.new(4,4,4)
            p.Color = Color3.fromRGB(255, 255, 0)
            p.Material = Enum.Material.Neon
            p.Transparency = 0.3
            p.Anchored = true
            p.CanCollide = false
            p.CFrame = hrp.CFrame
            p.Parent = WS
            Debris:AddItem(p, 0.5)

        elseif effectType == "Death" then
            hrp.CFrame = CFrame.new(0, -500, 0)

        elseif effectType == "Burn" then
            local fire = Instance.new("Fire")
            fire.Size = 10
            fire.Heat = 25
            fire.Parent = hrp
            Debris:AddItem(fire, 3)

        elseif effectType == "Void" then
            hrp.CFrame = CFrame.new(9e9, 9e9, 9e9)

        elseif effectType == "Massless" then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = true
                end
            end

        elseif effectType == "Noclip" then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

        elseif effectType == "Kill" then
            hrp.CFrame = CFrame.new(0, -500, 0)

        elseif effectType == "Freeze" then
            hrp.Anchored = true
            task.delay(5, function()
                pcall(function() hrp.Anchored = false end)
            end)
        end
    end)
end

-- ═══════════════════════════════════════
-- ОКНО
-- ═══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "💀 DMM HUB | FTAP",
    Icon = 0,
    LoadingTitle = "DMM HUB",
    LoadingSubtitle = "by DMM | Fling Things and People",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DMM_HUB",
        FileName = "FTAP"
    },
    KeySystem = false,
})

-- ╔══════════════════════════╗
-- ║   TAB: 🦠 BLOBMEN       ║
-- ╚══════════════════════════╝
local BlobTab = Window:CreateTab("🦠 Blobmen", 0)

BlobTab:CreateSection("Blobman Main")

BlobTab:CreateButton({
    Name = "🟢 Sit On Blobman",
    Callback = function()
        local blob = getBlobman()
        if blob then
            sitOnBlob(blob)
            Rayfield:Notify({Title="DMM",Content="Mounted Blobman!",Duration=2})
        else
            Rayfield:Notify({Title="DMM",Content="No Blobman found!",Duration=2})
        end
    end,
})

BlobTab:CreateButton({
    Name = "🆓 Blobman Free (Spawn)",
    Callback = function()
        pcall(function()
            for _, r in pairs(Rep:GetDescendants()) do
                if r:IsA("RemoteEvent") then
                    pcall(function() r:FireServer("BlobMan") end)
                    pcall(function() r:FireServer("Blobman") end)
                    pcall(function() r:FireServer("Buy", "BlobMan") end)
                    pcall(function() r:FireServer("buy", "Blobman") end)
                    pcall(function() r:FireServer("Purchase", "BlobMan") end)
                end
            end
            -- Пробуем через Shop remote
            for _, r in pairs(Rep:GetDescendants()) do
                if r:IsA("RemoteFunction") then
                    pcall(function() r:InvokeServer("BlobMan") end)
                    pcall(function() r:InvokeServer("Buy", "Blobman") end)
                end
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Attempted spawn Blobman!",Duration=2})
    end,
})

BlobTab:CreateToggle({
    Name = "❄️ Freeze Blobman",
    CurrentValue = false,
    Flag = "BlobFreeze",
    Callback = function(V)
        S.BlobFreeze = V
        task.spawn(function()
            while S.BlobFreeze do
                task.wait(0.1)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        for _, p in pairs(blob:GetDescendants()) do
                            if p:IsA("BasePart") then p.Anchored = true end
                        end
                    end
                end)
            end
            -- Unfreeze
            pcall(function()
                local blob = getBlobman()
                if blob then
                    for _, p in pairs(blob:GetDescendants()) do
                        if p:IsA("BasePart") then p.Anchored = false end
                    end
                end
            end)
        end)
    end,
})

BlobTab:CreateSection("Blobman Loop Grab")

BlobTab:CreateToggle({
    Name = "🔄 Loop Grab ALL Players",
    CurrentValue = false,
    Flag = "BlobGrabAll",
    Callback = function(V)
        S.BlobLoopGrabAll = V
        task.spawn(function()
            while S.BlobLoopGrabAll do
                task.wait(0.15)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LP and alive(p) then
                                blobGrabPlayer(blob, p)
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

BlobTab:CreateDropdown({
    Name = "Select Player (Blob Grab)",
    Options = plrList(),
    CurrentOption = {},
    MultiOption = false,
    Flag = "BlobGrabTarget",
    Callback = function(Opt)
        SelectedPlayerName = Opt
        SelectedPlayer = getPlr(Opt)
    end,
})

BlobTab:CreateToggle({
    Name = "🔄 Loop Grab Selected Player",
    CurrentValue = false,
    Flag = "BlobGrabSel",
    Callback = function(V)
        S.BlobLoopGrabPlayer = V
        task.spawn(function()
            while S.BlobLoopGrabPlayer do
                task.wait(0.15)
                pcall(function()
                    local blob = getBlobman()
                    if blob and alive(SelectedPlayer) then
                        blobGrabPlayer(blob, SelectedPlayer)
                    end
                end)
            end
        end)
    end,
})

BlobTab:CreateToggle({
    Name = "⚡ Speed Grab Player",
    CurrentValue = false,
    Flag = "SpeedGrab",
    Callback = function(V)
        S.SpeedGrab = V
        task.spawn(function()
            while S.SpeedGrab do
                task.wait(0.05)
                pcall(function()
                    local blob = getBlobman()
                    if blob and alive(SelectedPlayer) then
                        blobGrabPlayer(blob, SelectedPlayer)
                    end
                end)
            end
        end)
    end,
})

BlobTab:CreateButton({
    Name = "🤏 Multiple Grab (Grab All Blobmen)",
    Callback = function()
        pcall(function()
            for _, m in pairs(WS:GetDescendants()) do
                if m:IsA("Model") and (m.Name == "BlobMan" or m.Name == "Blobman") then
                    local hands = getBlobHands(m)
                    for _, h in pairs(hands) do
                        firetouchinterest(HRP, h, 0)
                        task.wait(0.02)
                        firetouchinterest(HRP, h, 1)
                    end
                end
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Grabbed all Blobmen!",Duration=2})
    end,
})

BlobTab:CreateSection("Grab Mods")

local grabTypes = {"Poison", "Radioactive", "Death", "Burn", "Void", "Massless", "Noclip", "Kill", "Freeze"}

for _, gt in pairs(grabTypes) do
    BlobTab:CreateToggle({
        Name = "💎 " .. gt .. " Grab",
        CurrentValue = false,
        Flag = gt .. "Grab",
        Callback = function(V)
            S[gt .. "Grab"] = V
            task.spawn(function()
                while S[gt .. "Grab"] do
                    task.wait(0.3)
                    pcall(function()
                        local target = closest(S.AuraRange)
                        if target then
                            applyGrabEffect(target, gt)
                        end
                    end)
                end
            end)
        end,
    })
end

BlobTab:CreateSlider({
    Name = "Grab / Aura Range",
    Range = {10, 300},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 40,
    Flag = "AuraRange",
    Callback = function(V) S.AuraRange = V end,
})

-- ╔══════════════════════════╗
-- ║   TAB: ⚡ KICKS          ║
-- ╚══════════════════════════╝
local KickTab = Window:CreateTab("⚡ Kicks", 0)

KickTab:CreateSection("Select Target")

KickTab:CreateDropdown({
    Name = "Select Player",
    Options = plrList(),
    CurrentOption = {},
    MultiOption = false,
    Flag = "KickTarget",
    Callback = function(Opt)
        SelectedPlayer = getPlr(Opt)
        SelectedPlayerName = Opt
    end,
})

KickTab:CreateSection("Instant Kick")

KickTab:CreateButton({
    Name = "⚡ Instant Kick (Blobman)",
    Callback = function()
        pcall(function()
            local blob = getBlobman()
            if blob and alive(SelectedPlayer) then
                for i = 1, 30 do
                    blobKickPlayer(blob, SelectedPlayer)
                    task.wait(0.05)
                end
                Rayfield:Notify({Title="DMM",Content="Kicked "..SelectedPlayerName.."!",Duration=2})
            else
                Rayfield:Notify({Title="DMM",Content="Need Blobman + Target!",Duration=2})
            end
        end)
    end,
})

KickTab:CreateToggle({
    Name = "🔄 Loop Kick (Blobman)",
    CurrentValue = false,
    Flag = "LoopKickBlob",
    Callback = function(V)
        S.LoopKickBlob = V
        task.spawn(function()
            while S.LoopKickBlob do
                task.wait(0.2)
                pcall(function()
                    local blob = getBlobman()
                    if blob and alive(SelectedPlayer) then
                        blobKickPlayer(blob, SelectedPlayer)
                    end
                end)
            end
        end)
    end,
})

KickTab:CreateButton({
    Name = "💥 Kick ALL (Blobman)",
    Callback = function()
        task.spawn(function()
            local blob = getBlobman()
            if blob then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and alive(p) then
                        for i = 1, 15 do
                            blobKickPlayer(blob, p)
                            task.wait(0.05)
                        end
                    end
                end
                Rayfield:Notify({Title="DMM",Content="Kicked ALL!",Duration=2})
            end
        end)
    end,
})

KickTab:CreateToggle({
    Name = "🔄 Auto Kick ALL Off Blob",
    CurrentValue = false,
    Flag = "AutoKickAll",
    Callback = function(V)
        S.AutoKickAllBlob = V
        task.spawn(function()
            while S.AutoKickAllBlob do
                task.wait(0.3)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LP and alive(p) then
                                blobKickPlayer(blob, p)
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

KickTab:CreateSection("Kill Methods")

KickTab:CreateToggle({
    Name = "💀 Loop Kill Selected",
    CurrentValue = false,
    Flag = "LoopKill",
    Callback = function(V)
        S.LoopKill = V
        task.spawn(function()
            while S.LoopKill do
                task.wait(0.3)
                pcall(function()
                    if alive(SelectedPlayer) then
                        SelectedPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
                    end
                end)
            end
        end)
    end,
})

KickTab:CreateToggle({
    Name = "☠️ Loop Kill ALL",
    CurrentValue = false,
    Flag = "LoopKillAll",
    Callback = function(V)
        S.LoopKillAll = V
        task.spawn(function()
            while S.LoopKillAll do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LP and alive(p) then
                            p.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
                        end
                    end)
                end
            end
        end)
    end,
})

KickTab:CreateToggle({
    Name = "🔄 Loop Ragdoll Selected",
    CurrentValue = false,
    Flag = "LoopRagdoll",
    Callback = function(V)
        S.LoopRagdoll = V
        task.spawn(function()
            while S.LoopRagdoll do
                task.wait(0.5)
                pcall(function()
                    if alive(SelectedPlayer) then
                        local hrp = SelectedPlayer.Character.HumanoidRootPart
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bv.Velocity = Vector3.new(math.random(-200,200), 100, math.random(-200,200))
                        bv.Parent = hrp
                        Debris:AddItem(bv, 0.3)
                    end
                end)
            end
        end)
    end,
})

KickTab:CreateToggle({
    Name = "🔥 Loop Fire Selected",
    CurrentValue = false,
    Flag = "LoopFire",
    Callback = function(V)
        S.LoopFire = V
        task.spawn(function()
            while S.LoopFire do
                task.wait(1)
                pcall(function()
                    if alive(SelectedPlayer) then
                        applyGrabEffect(SelectedPlayer, "Burn")
                    end
                end)
            end
        end)
    end,
})

KickTab:CreateButton({
    Name = "🌊 Send to Void (Selected)",
    Callback = function()
        if alive(SelectedPlayer) then
            voidPlayer(SelectedPlayer)
            Rayfield:Notify({Title="DMM",Content="Voided "..SelectedPlayerName,Duration=2})
        end
    end,
})

KickTab:CreateToggle({
    Name = "🌊 Loop Send to Void",
    CurrentValue = false,
    Flag = "LoopVoid",
    Callback = function(V)
        local loopVoid = V
        task.spawn(function()
            while loopVoid do
                task.wait(0.5)
                pcall(function()
                    if alive(SelectedPlayer) then voidPlayer(SelectedPlayer) end
                end)
            end
        end)
    end,
})

KickTab:CreateButton({
    Name = "🔗 Bring Selected Player",
    Callback = function()
        pcall(function()
            if alive(SelectedPlayer) then
                SelectedPlayer.Character.HumanoidRootPart.CFrame = HRP.CFrame * CFrame.new(0, 0, -5)
                Rayfield:Notify({Title="DMM",Content="Brought "..SelectedPlayerName,Duration=2})
            end
        end)
    end,
})

KickTab:CreateButton({
    Name = "🔒 Lock Selected Player",
    Callback = function()
        pcall(function()
            if alive(SelectedPlayer) then
                SelectedPlayer.Character.HumanoidRootPart.Anchored = true
                Rayfield:Notify({Title="DMM",Content="Locked "..SelectedPlayerName,Duration=2})
            end
        end)
    end,
})

KickTab:CreateSlider({
    Name = "Fling / Kick Power",
    Range = {100, 99999},
    Increment = 500,
    Suffix = "force",
    CurrentValue = 9999,
    Flag = "FlingPow",
    Callback = function(V) S.FlingPower = V end,
})

-- ╔══════════════════════════╗
-- ║   TAB: ⚔️ COMBAT        ║
-- ╚══════════════════════════╝
local CombatTab = Window:CreateTab("⚔️ Combat", 0)

CombatTab:CreateSection("Strength & Aim")

CombatTab:CreateToggle({
    Name = "💪 Super Strength",
    CurrentValue = false,
    Flag = "SuperStr",
    Callback = function(V)
        S.SuperStrength = V
    end,
})

CombatTab:CreateSlider({
    Name = "Custom Strength",
    Range = {0, 10000},
    Increment = 50,
    Suffix = "str",
    CurrentValue = 500,
    Flag = "StrVal",
    Callback = function(V) S.StrengthVal = V end,
})

-- Super Strength через DescendantAdded
WS.DescendantAdded:Connect(function(obj)
    if S.SuperStrength then
        if obj:IsA("BodyPosition") then
            obj.MaxForce = Vector3.new(S.StrengthVal * 1000, S.StrengthVal * 1000, S.StrengthVal * 1000)
        elseif obj:IsA("BodyVelocity") then
            obj.MaxForce = Vector3.new(S.StrengthVal * 1000, S.StrengthVal * 1000, S.StrengthVal * 1000)
        end
    end
end)

CombatTab:CreateToggle({
    Name = "🎯 Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(V) S.SilentAim = V end,
})

CombatTab:CreateToggle({
    Name = "⚔️ Auto Attacker",
    CurrentValue = false,
    Flag = "AutoAtk",
    Callback = function(V)
        S.AutoAttacker = V
        task.spawn(function()
            while S.AutoAttacker do
                task.wait(0.2)
                pcall(function()
                    local target = closest(S.AuraRange)
                    if target and alive(target) then
                        flingPlayer(target)
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "📍 Position Damage",
    CurrentValue = false,
    Flag = "PosDmg",
    Callback = function(V)
        S.PositionDamage = V
        task.spawn(function()
            while S.PositionDamage do
                task.wait(0.2)
                pcall(function()
                    local target = closest(S.AuraRange)
                    if target and alive(target) then
                        target.Character.HumanoidRootPart.CFrame = CFrame.new(0, -300, 0)
                        task.wait(0.1)
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateSection("Auras")

local auraTypes = {
    {name = "☠️ Poison Aura", key = "PoisonAura", effect = "Poison"},
    {name = "💀 Death Aura", key = "DeathAura", effect = "Death"},
    {name = "☢️ Radioactive Aura", key = "RadioactiveAura", effect = "Radioactive"},
    {name = "🔥 Burn Aura", key = "BurnAura", effect = "Burn"},
    {name = "🌊 Void Aura", key = "VoidAura", effect = "Void"},
    {name = "🧲 Attraction Aura", key = "AttractionAura", effect = nil},
    {name = "💨 Fling Aura", key = "FlingAura", effect = nil},
    {name = "👣 Follow Aura", key = "FollowAura", effect = nil},
    {name = "👢 Kick Aura (Blob)", key = "KickAura", effect = nil},
}

for _, aura in pairs(auraTypes) do
    CombatTab:CreateToggle({
        Name = aura.name,
        CurrentValue = false,
        Flag = aura.key,
        Callback = function(V)
            S[aura.key] = V
            task.spawn(function()
                while S[aura.key] do
                    task.wait(0.3)
                    for _, p in pairs(Players:GetPlayers()) do
                        pcall(function()
                            if p ~= LP and alive(p) and dist(p) <= S.AuraRange then
                                if aura.effect then
                                    applyGrabEffect(p, aura.effect)
                                elseif aura.key == "FlingAura" then
                                    flingPlayer(p)
                                elseif aura.key == "AttractionAura" then
                                    p.Character.HumanoidRootPart.CFrame = HRP.CFrame * CFrame.new(0, 0, -3)
                                elseif aura.key == "FollowAura" then
                                    if alive(SelectedPlayer) then
                                        HRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                                    end
                                elseif aura.key == "KickAura" then
                                    local blob = getBlobman()
                                    if blob then blobKickPlayer(blob, p) end
                                end
                            end
                        end)
                    end
                end
            end)
        end,
    })
end

CombatTab:CreateSlider({
    Name = "Custom Fling Aura Strength",
    Range = {100, 99999},
    Increment = 500,
    Suffix = "power",
    CurrentValue = 9999,
    Flag = "FlingAuraStr",
    Callback = function(V) S.FlingPower = V end,
})

CombatTab:CreateSection("Defense / Antis")

CombatTab:CreateToggle({
    Name = "🛡️ Anti Grab",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(V)
        S.AntiGrab = V
        task.spawn(function()
            while S.AntiGrab do
                task.wait(0.05)
                pcall(function()
                    for _, v in pairs(Char:GetDescendants()) do
                        if (v:IsA("Weld") or v:IsA("WeldConstraint")) then
                            local p0, p1 = v.Part0, v.Part1
                            if p0 and p1 then
                                if not p0:IsDescendantOf(Char) or not p1:IsDescendantOf(Char) then
                                    v:Destroy()
                                end
                            end
                        end
                    end
                    -- Destroy seat welds (anti blobman grab)
                    if Hum.SeatPart and not Hum.SeatPart:IsDescendantOf(Char) then
                        Hum.Jump = true
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "🛡️ Gucci Anti (Advanced)",
    CurrentValue = false,
    Flag = "GucciAnti",
    Callback = function(V)
        S.GucciAnti = V
        task.spawn(function()
            while S.GucciAnti do
                task.wait(0.02)
                pcall(function()
                    -- Remove all external welds + forces
                    for _, v in pairs(Char:GetDescendants()) do
                        if v:IsA("Weld") or v:IsA("WeldConstraint") then
                            local p0, p1 = v.Part0, v.Part1
                            if p0 and p1 and (not p0:IsDescendantOf(Char) or not p1:IsDescendantOf(Char)) then
                                v:Destroy()
                            end
                        end
                        if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") then
                            if v.Parent and v.Parent:IsDescendantOf(Char) then
                                v:Destroy()
                            end
                        end
                    end
                    -- Kill velocity
                    if HRP.Velocity.Magnitude > 300 then
                        HRP.Velocity = Vector3.zero
                        HRP.RotVelocity = Vector3.zero
                    end
                    -- Unseat if grabbed
                    if Hum.SeatPart and not Hum.SeatPart:IsDescendantOf(Char) then
                        Hum.Jump = true
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "🛡️ Anti Blobman",
    CurrentValue = false,
    Flag = "AntiBlobman",
    Callback = function(V)
        S.AntiBlobman = V
        task.spawn(function()
            while S.AntiBlobman do
                task.wait(0.05)
                pcall(function()
                    if Hum.SeatPart then
                        local seat = Hum.SeatPart
                        if seat.Parent and (seat.Parent.Name:lower():find("blob")) then
                            Hum.Jump = true
                        end
                    end
                    for _, v in pairs(Char:GetDescendants()) do
                        if (v:IsA("Weld") or v:IsA("WeldConstraint")) then
                            if v.Part0 and v.Part1 then
                                local other = v.Part0:IsDescendantOf(Char) and v.Part1 or v.Part0
                                if other and other.Parent and (other.Parent.Name:lower():find("blob") or other.Name:lower():find("hand")) then
                                    v:Destroy()
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "🛡️ Anti Explosion",
    CurrentValue = false,
    Flag = "AntiExpl",
    Callback = function(V)
        S.AntiExplosion = V
    end,
})

WS.DescendantAdded:Connect(function(obj)
    if S.AntiExplosion and obj:IsA("Explosion") then
        obj.BlastPressure = 0
        obj.BlastRadius = 0
        obj.DestroyJointRadiusPercent = 0
    end
end)

CombatTab:CreateToggle({
    Name = "🛡️ Anti Kick (Velocity Block)",
    CurrentValue = false,
    Flag = "AntiKick",
    Callback = function(V)
        S.AntiKick = V
        task.spawn(function()
            while S.AntiKick do
                task.wait(0.03)
                pcall(function()
                    if HRP.Velocity.Magnitude > 200 then
                        HRP.Velocity = Vector3.zero
                        HRP.RotVelocity = Vector3.zero
                    end
                    for _, v in pairs(HRP:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") then
                            v:Destroy()
                        end
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "🛡️ Anti Void",
    CurrentValue = false,
    Flag = "AntiVoid",
    Callback = function(V)
        S.AntiVoid = V
        task.spawn(function()
            while S.AntiVoid do
                task.wait(0.1)
                pcall(function()
                    if HRP.Position.Y < -100 then
                        HRP.CFrame = CFrame.new(0, 50, 0)
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "🛡️ Anti Burn",
    CurrentValue = false,
    Flag = "AntiBurn",
    Callback = function(V)
        S.AntiBurn = V
        task.spawn(function()
            while S.AntiBurn do
                task.wait(0.5)
                pcall(function()
                    for _, v in pairs(Char:GetDescendants()) do
                        if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                            v:Destroy()
                        end
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "🛡️ Anti Lag",
    CurrentValue = false,
    Flag = "AntiLag",
    Callback = function(V)
        S.AntiLag = V
        if V then
            pcall(function()
                for _, v in pairs(WS:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                    if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        v:Destroy()
                    end
                end
                game:GetService("Lighting").GlobalShadows = false
                game:GetService("Lighting").FogEnd = 99999
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
        end
    end,
})

-- ╔══════════════════════════╗
-- ║   TAB: 🏃 PLAYER        ║
-- ╚══════════════════════════╝
local PlayerTab = Window:CreateTab("🏃 Player", 0)

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WS",
    Callback = function(V) pcall(function() Hum.WalkSpeed = V end) end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JP",
    Callback = function(V)
        pcall(function()
            Hum.UseJumpPower = true
            Hum.JumpPower = V
        end)
    end,
})

PlayerTab:CreateToggle({
    Name = "♾️ Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(V) S.InfJump = V end,
})

UIS.JumpRequest:Connect(function()
    if S.InfJump and Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "👻 Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(V) S.Noclip = V end,
})

RS.Stepped:Connect(function()
    if S.Noclip and Char then
        for _, p in pairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "🛡️ God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(V)
        S.GodMode = V
        task.spawn(function()
            while S.GodMode do
                task.wait(0.1)
                pcall(function() Hum.Health = Hum.MaxHealth end)
            end
        end)
    end,
})

-- Fly
local flyBV, flyBG
PlayerTab:CreateToggle({
    Name = "✈️ Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(V)
        S.Fly = V
        if V then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = HRP
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
            flyBG.P = 9e4
            flyBG.Parent = HRP
            task.spawn(function()
                while S.Fly do
                    RS.Heartbeat:Wait()
                    pcall(function()
                        local cam = WS.CurrentCamera
                        if Hum.MoveDirection.Magnitude > 0 then
                            flyBV.Velocity = cam.CFrame.LookVector * S.FlySpeed
                        else
                            flyBV.Velocity = Vector3.zero
                        end
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

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 50,
    Flag = "FlySpd",
    Callback = function(V) S.FlySpeed = V end,
})

-- ╔══════════════════════════╗
-- ║   TAB: 👁 VISUALS       ║
-- ╚══════════════════════════╝
local VisTab = Window:CreateTab("👁 Visuals", 0)

VisTab:CreateToggle({
    Name = "👁 ESP Players",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(V)
        if V then
            local function addESP(player)
                if player == LP then return end
                local function onChar(char)
                    local head = char:WaitForChild("Head", 5)
                    if not head then return end
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "DMM_ESP"; bb.Adornee = head
                    bb.Size = UDim2.new(0,120,0,50)
                    bb.StudsOffset = Vector3.new(0,3,0)
                    bb.AlwaysOnTop = true; bb.Parent = head
                    local nl = Instance.new("TextLabel")
                    nl.Size = UDim2.new(1,0,0.5,0)
                    nl.BackgroundTransparency = 1
                    nl.TextColor3 = Color3.fromRGB(255,50,50)
                    nl.TextStrokeTransparency = 0.5
                    nl.Text = player.Name
                    nl.TextScaled = true
                    nl.Font = Enum.Font.GothamBold
                    nl.Parent = bb
                    local dl = Instance.new("TextLabel")
                    dl.Size = UDim2.new(1,0,0.5,0)
                    dl.Position = UDim2.new(0,0,0.5,0)
                    dl.BackgroundTransparency = 1
                    dl.TextColor3 = Color3.new(1,1,1)
                    dl.TextStrokeTransparency = 0.5
                    dl.TextScaled = true
                    dl.Font = Enum.Font.Gotham
                    dl.Parent = bb
                    local hl = Instance.new("Highlight")
                    hl.Name = "DMM_HL"
                    hl.FillColor = Color3.fromRGB(255,0,0)
                    hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.fromRGB(255,255,0)
                    hl.Parent = char
                    task.spawn(function()
                        while char.Parent and head.Parent do
                            pcall(function()
                                dl.Text = "["..math.floor((HRP.Position - head.Position).Magnitude).."m]"
                            end)
                            task.wait(0.5)
                        end
                    end)
                end
                if player.Character then onChar(player.Character) end
                player.CharacterAdded:Connect(onChar)
            end
            for _, p in pairs(Players:GetPlayers()) do addESP(p) end
            Players.PlayerAdded:Connect(addESP)
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    for _, v in pairs(p.Character:GetDescendants()) do
                        if v.Name == "DMM_ESP" or v.Name == "DMM_HL" then v:Destroy() end
                    end
                end
            end
        end
    end,
})

VisTab:CreateToggle({
    Name = "💡 Fullbright",
    CurrentValue = false,
    Flag = "FB",
    Callback = function(V)
        local L = game:GetService("Lighting")
        if V then
            L.Brightness = 2; L.ClockTime = 14; L.FogEnd = 1e6
            L.GlobalShadows = false; L.Ambient = Color3.fromRGB(178,178,178)
        else
            L.Brightness = 1; L.ClockTime = 14; L.FogEnd = 1e4
            L.GlobalShadows = true; L.Ambient = Color3.fromRGB(0,0,0)
        end
    end,
})

VisTab:CreateButton({
    Name = "✨ TetraCube Wings",
    Callback = function()
        pcall(function()
            for i = -1, 1, 2 do
                local w = Instance.new("Part")
                w.Name = "DMM_Wing"
                w.Size = Vector3.new(0.2, 4, 3)
                w.Color = Color3.fromRGB(100, 0, 255)
                w.Material = Enum.Material.Neon
                w.Transparency = 0.3
                w.CanCollide = false
                w.Massless = true
                w.Parent = Char
                local weld = Instance.new("Weld")
                weld.Part0 = HRP; weld.Part1 = w
                weld.C0 = CFrame.new(i * 1.5, 0.5, 0.8) * CFrame.Angles(0, 0, math.rad(-30 * i))
                weld.Parent = w
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Wings added!",Duration=2})
    end,
})

-- ╔══════════════════════════╗
-- ║   TAB: 🌀 TELEPORT      ║
-- ╚══════════════════════════╝
local TpTab = Window:CreateTab("🌀 Teleport", 0)

TpTab:CreateDropdown({
    Name = "TP to Player",
    Options = plrList(),
    CurrentOption = {},
    MultiOption = false,
    Flag = "TpPlr",
    Callback = function(Opt)
        pcall(function()
            local t = getPlr(Opt)
            if alive(t) then
                HRP.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                Rayfield:Notify({Title="DMM",Content="TP'd to "..Opt,Duration=2})
            end
        end)
    end,
})

TpTab:CreateToggle({
    Name = "🔄 Loop TP to Selected",
    CurrentValue = false,
    Flag = "LoopTP",
    Callback = function(V)
        local loopTp = V
        task.spawn(function()
            while loopTp do
                RS.Heartbeat:Wait()
                pcall(function()
                    if alive(SelectedPlayer) then
                        HRP.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
                    end
                end)
            end
        end)
    end,
})

TpTab:CreateButton({
    Name = "🏠 TP to Spawn",
    Callback = function()
        pcall(function()
            local sp = WS:FindFirstChildWhichIsA("SpawnLocation", true)
            if sp then HRP.CFrame = sp.CFrame + Vector3.new(0,5,0)
            else HRP.CFrame = CFrame.new(0,50,0) end
        end)
    end,
})

TpTab:CreateButton({
    Name = "🎲 TP to Random Player",
    Callback = function()
        pcall(function()
            local list = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and alive(p) then table.insert(list, p) end
            end
            if #list > 0 then
                local r = list[math.random(#list)]
                HRP.CFrame = r.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                Rayfield:Notify({Title="DMM",Content="TP'd to "..r.Name,Duration=2})
            end
        end)
    end,
})

-- ╔══════════════════════════╗
-- ║   TAB: ⚙ MISC           ║
-- ╚══════════════════════════╝
local MiscTab = Window:CreateTab("⚙ Misc", 0)

MiscTab:CreateSection("Server Attacks")

MiscTab:CreateToggle({
    Name = "💥 Destroy Server (Loop Fling All)",
    CurrentValue = false,
    Flag = "DestroyServer",
    Callback = function(V)
        S.DestroyServer = V
        task.spawn(function()
            while S.DestroyServer do
                task.wait(0.1)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LP and alive(p) then
                            flingPlayer(p)
                            local blob = getBlobman()
                            if blob then blobKickPlayer(blob, p) end
                        end
                    end)
                end
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "📡 Lag Server",
    CurrentValue = false,
    Flag = "LagSrv",
    Callback = function(V)
        S.LagServer = V
        task.spawn(function()
            while S.LagServer do
                task.wait(0.01)
                pcall(function()
                    for _, r in pairs(Rep:GetDescendants()) do
                        if r:IsA("RemoteEvent") then
                            for i = 1, 5 do
                                r:FireServer(string.rep("lag", 500))
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "🔥 Burn ALL Players",
    CurrentValue = false,
    Flag = "BurnAll",
    Callback = function(V)
        S.BurnAll = V
        task.spawn(function()
            while S.BurnAll do
                task.wait(1)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LP and alive(p) then
                            applyGrabEffect(p, "Burn")
                        end
                    end)
                end
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "🔗 Bring Server (All to You)",
    CurrentValue = false,
    Flag = "BringAll",
    Callback = function(V)
        S.BringServer = V
        task.spawn(function()
            while S.BringServer do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LP and alive(p) then
                            p.Character.HumanoidRootPart.CFrame = HRP.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end)
                end
            end
        end)
    end,
})

MiscTab:CreateSection("FE Objects")

MiscTab:CreateToggle({
    Name = "🌪️ FE Object Tornado",
    CurrentValue = false,
    Flag = "FeTornado",
    Callback = function(V)
        S.FeObjectTornado = V
        task.spawn(function()
            local angle = 0
            while S.FeObjectTornado do
                RS.Heartbeat:Wait()
                angle = angle + 5
                pcall(function()
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored and obj ~= HRP and not obj:IsDescendantOf(Char) then
                            local radius = 20
                            local x = HRP.Position.X + math.cos(math.rad(angle)) * radius
                            local z = HRP.Position.Z + math.sin(math.rad(angle)) * radius
                            local y = HRP.Position.Y + (angle % 360) / 36
                            obj.CFrame = CFrame.new(x, y, z)
                        end
                    end
                end)
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "🌐 FE Object Aura",
    CurrentValue = false,
    Flag = "FeAura",
    Callback = function(V)
        S.FeObjectAura = V
        task.spawn(function()
            local a = 0
            while S.FeObjectAura do
                RS.Heartbeat:Wait()
                a = a + 3
                pcall(function()
                    local i = 0
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored and obj ~= HRP and not obj:IsDescendantOf(Char) then
                            i = i + 1
                            local ang = math.rad(a + i * 30)
                            obj.CFrame = HRP.CFrame * CFrame.new(math.cos(ang)*10, 2, math.sin(ang)*10)
                        end
                    end
                end)
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "☁️ FE Object Float",
    CurrentValue = false,
    Flag = "FeFloat",
    Callback = function(V)
        S.FeObjectFloat = V
        task.spawn(function()
            while S.FeObjectFloat do
                task.wait(0.1)
                pcall(function()
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(Char) then
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(0,1e5,0)
                            bv.Velocity = Vector3.new(0, 30, 0)
                            bv.Parent = obj
                            Debris:AddItem(bv, 0.5)
                        end
                    end
                end)
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "🔊 Spam Sounds",
    CurrentValue = false,
    Flag = "SpamSnd",
    Callback = function(V)
        S.SpamSounds = V
        task.spawn(function()
            while S.SpamSounds do
                task.wait(0.1)
                pcall(function()
                    for _, obj in pairs(WS:GetDescendants()) do
                        if obj:IsA("Sound") then
                            obj:Play()
                        end
                    end
                end)
            end
        end)
    end,
})

MiscTab:CreateSection("Utility")

MiscTab:CreateToggle({
    Name = "💰 Auto Claim Cash",
    CurrentValue = false,
    Flag = "AutoCash",
    Callback = function(V)
        local autoCash = V
        task.spawn(function()
            while autoCash do
                task.wait(0.5)
                pcall(function()
                    for _, obj in pairs(WS:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            fireproximityprompt(obj)
                        end
                    end
                    -- Touch coins
                    for _, obj in pairs(WS:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("cash")) then
                            firetouchinterest(HRP, obj, 0)
                            task.wait(0.02)
                            firetouchinterest(HRP, obj, 1)
                        end
                    end
                end)
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "🚫 Anti AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(V)
        if V then
            LP.Idled:Connect(function()
                VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        end
    end,
})

MiscTab:CreateToggle({
    Name = "🖱️ Click Teleport",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(V)
        local clickTp = V
        local mouse = LP:GetMouse()
        mouse.Button1Down:Connect(function()
            if clickTp and mouse.Hit then
                HRP.CFrame = mouse.Hit + Vector3.new(0,3,0)
            end
        end)
    end,
})

MiscTab:CreateSection("Server")

MiscTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end,
})

MiscTab:CreateButton({
    Name = "🌐 Server Hop",
    Callback = function()
        pcall(function()
            local data = game.HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            )
            for _, s in pairs(data.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    break
                end
            end
        end)
    end,
})

MiscTab:CreateButton({
    Name = "📋 Copy Game Link",
    Callback = function()
        pcall(function()
            setclipboard("https://www.roblox.com/games/"..game.PlaceId)
        end)
        Rayfield:Notify({Title="DMM",Content="Link copied!",Duration=2})
    end,
})

MiscTab:CreateButton({
    Name = "❌ Destroy DMM HUB",
    Callback = function() Rayfield:Destroy() end,
})

-- ═══════════════════════════════════════
-- HOOKS (Silent Aim & Super Throw)
-- ═══════════════════════════════════════
pcall(function()
    local oldNC
    oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" and self:IsA("RemoteEvent") then
            -- Silent Aim
            if S.SilentAim then
                local target = closest(S.AuraRange)
                if target and alive(target) then
                    for i, v in pairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = target.Character.HumanoidRootPart.Position
                        end
                        if typeof(v) == "CFrame" then
                            args[i] = target.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end
        
        return oldNC(self, unpack(args))
    end))
end)

-- ═══════════════════════════════════════
-- DONE
-- ═══════════════════════════════════════
Rayfield:Notify({
    Title = "💀 DMM HUB",
    Content = "Loaded! All features ready 🎉",
    Duration = 5,
})

print("═══════════════════════════════════")
print("   💀 DMM HUB — Fully Loaded!")
print("   Game: Fling Things and People")
print("═══════════════════════════════════")
