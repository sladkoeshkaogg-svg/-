-- ╔══════════════════════════════════════════════════════════╗
-- ║              DMM HUB — Fling Things and People          ║
-- ║                Built on Rayfield Interface               ║
-- ╚══════════════════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ═══════ СЕРВИСЫ ═══════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ═══════ ПЕРЕМЕННЫЕ ═══════
local Settings = {
    -- Kicks
    InstantKick = false,
    LoopKick = false,
    KickAll = false,
    -- Blobmen
    BlobmanGrab = false,
    BlobmanLoopGrab = false,
    BlobmanFree = false,
    GrabAll = false,
    -- Grabs
    KillGrab = false,
    VoidGrab = false,
    PoisonGrab = false,
    RadioactiveGrab = false,
    FreezeGrab = false,
    -- Auras
    FlingAura = false,
    VoidAura = false,
    PoisonAura = false,
    FollowAura = false,
    KillAura = false,
    -- Combat
    SuperThrow = false,
    SuperStrength = false,
    SilentAim = false,
    AntiGrab = false,
    AntiExplosion = false,
    AntiKick = false,
    PositionDamage = false,
    -- Player
    InfJump = false,
    Noclip = false,
    SpeedHack = false,
    -- Misc
    AutoClaimCash = false,
    LoopKillAll = false,
    LoopKillPlayer = false,
}

local SelectedPlayer = nil
local WalkSpeedVal = 16
local JumpPowerVal = 50
local AuraRange = 30
local FlingPower = 500
local ThrowPower = 300

-- ═══════ ОБНОВЛЕНИЕ ПЕРСОНАЖА ═══════
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- ═══════ УТИЛИТЫ ═══════
local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

local function getClosestPlayer(range)
    local closest, dist = nil, range or math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                closest = p
                dist = d
            end
        end
    end
    return closest
end

local function getBlobman()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "BlobMan" or obj.Name == "Blobman" then
            return obj
        end
    end
    return nil
end

local function getAllBlobmen()
    local blobs = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "BlobMan" or obj.Name == "Blobman" then
            table.insert(blobs, obj)
        end
    end
    return blobs
end

local function getGrabbableRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("grab") or v.Name:lower():find("pickup") or v.Name:lower():find("interact")) then
            return v
        end
    end
    return nil
end

local function getKickRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("kick") or v.Name:lower():find("fling") or v.Name:lower():find("throw") or v.Name:lower():find("hit")) then
            return v
        end
    end
    return nil
end

local function getDamageRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("damage") or v.Name:lower():find("attack") or v.Name:lower():find("kill")) then
            return v
        end
    end
    return nil
end

local function getCashRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("cash") or v.Name:lower():find("coin") or v.Name:lower():find("claim") or v.Name:lower():find("money")) then
            return v
        end
    end
    return nil
end

local function applyVelocity(part, direction, power)
    if part then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = direction * power
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = part
        game:GetService("Debris"):AddItem(bv, 0.3)
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

-- ═══════════════════════════════════════
-- ОКНО
-- ═══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "💀 DMM HUB — FTAP",
    Icon = 0,
    LoadingTitle = "DMM HUB",
    LoadingSubtitle = "Fling Things and People",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DMM_HUB",
        FileName = "FTAP_Config"
    },
    KeySystem = false,
})

-- ═══════════════════════════════════════════════════
-- TAB: 🦠 BLOBMEN
-- ═══════════════════════════════════════════════════
local BlobTab = Window:CreateTab("🦠 Blobmen", 0)

local BlobSection = BlobTab:CreateSection("Blobman Controls")

-- Blobman Grab
BlobTab:CreateToggle({
    Name = "Blobman Grab",
    CurrentValue = false,
    Flag = "BlobGrab",
    Callback = function(Value)
        Settings.BlobmanGrab = Value
        if Value then
            task.spawn(function()
                while Settings.BlobmanGrab do
                    task.wait(0.1)
                    pcall(function()
                        local blob = getBlobman()
                        if blob then
                            local remote = getGrabbableRemote()
                            if remote then
                                remote:FireServer(blob)
                            end
                            -- Альтернатива через firetouchinterest
                            if blob:FindFirstChild("Handle") or blob:IsA("BasePart") then
                                local part = blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
                                if part and HumanoidRootPart then
                                    firetouchinterest(HumanoidRootPart, part, 0)
                                    task.wait(0.05)
                                    firetouchinterest(HumanoidRootPart, part, 1)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

-- Blobman Loop Grab All Players
BlobTab:CreateToggle({
    Name = "Blobman Loop Grab All",
    CurrentValue = false,
    Flag = "BlobLoopGrabAll",
    Callback = function(Value)
        Settings.BlobmanLoopGrab = Value
        task.spawn(function()
            while Settings.BlobmanLoopGrab do
                task.wait(0.15)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        local blobPart = blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
                        if blobPart then
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    blobPart.CFrame = p.Character.HumanoidRootPart.CFrame
                                    task.wait(0.05)
                                    firetouchinterest(blobPart, p.Character.HumanoidRootPart, 0)
                                    task.wait(0.05)
                                    firetouchinterest(blobPart, p.Character.HumanoidRootPart, 1)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

-- Blobman Free (Spawn Free Blobman)
BlobTab:CreateButton({
    Name = "Blobman Free (Spawn)",
    Callback = function()
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:lower():find("spawn") or remote.Name:lower():find("buy") or remote.Name:lower():find("summon")) then
                    remote:FireServer("BlobMan")
                    remote:FireServer("Blobman")
                end
            end
        end)
        Rayfield:Notify({Title = "DMM HUB", Content = "Attempted to spawn Blobman!", Duration = 3})
    end,
})

-- Blobman TP to Player
local blobTpDropdown
BlobTab:CreateDropdown({
    Name = "Blobman TP to Player",
    Options = getPlayerList(),
    CurrentOption = {},
    MultiOption = false,
    Flag = "BlobTP",
    Callback = function(Option)
        pcall(function()
            local target = Players:FindFirstChild(Option)
            local blob = getBlobman()
            if target and target.Character and blob then
                local blobPart = blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
                if blobPart and target.Character:FindFirstChild("HumanoidRootPart") then
                    blobPart.CFrame = target.Character.HumanoidRootPart.CFrame
                end
            end
        end)
    end,
})

-- Blobman Multiple Grab
BlobTab:CreateButton({
    Name = "Multiple Blobman Grab",
    Callback = function()
        pcall(function()
            local blobs = getAllBlobmen()
            for _, blob in pairs(blobs) do
                local part = blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
                if part then
                    firetouchinterest(HumanoidRootPart, part, 0)
                    task.wait(0.05)
                    firetouchinterest(HumanoidRootPart, part, 1)
                end
            end
        end)
        Rayfield:Notify({Title = "DMM HUB", Content = "Grabbed all Blobmen!", Duration = 3})
    end,
})

local BlobGrabSection = BlobTab:CreateSection("Grab Mods (With Blobman)")

-- Kill Grab
BlobTab:CreateToggle({
    Name = "Kill Grab",
    CurrentValue = false,
    Flag = "KillGrab",
    Callback = function(Value)
        Settings.KillGrab = Value
        task.spawn(function()
            while Settings.KillGrab do
                task.wait(0.1)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character then
                        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                        local hum = target.Character:FindFirstChild("Humanoid")
                        if hrp then
                            HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -2)
                            applyVelocity(hrp, Vector3.new(0, -1000, 0), 9999)
                        end
                    end
                end)
            end
        end)
    end,
})

-- Void Grab
BlobTab:CreateToggle({
    Name = "Void Grab",
    CurrentValue = false,
    Flag = "VoidGrab",
    Callback = function(Value)
        Settings.VoidGrab = Value
        task.spawn(function()
            while Settings.VoidGrab do
                task.wait(0.2)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target then
                        voidPlayer(target)
                    end
                end)
            end
        end)
    end,
})

-- Poison Grab
BlobTab:CreateToggle({
    Name = "Poison Grab",
    CurrentValue = false,
    Flag = "PoisonGrab",
    Callback = function(Value)
        Settings.PoisonGrab = Value
        task.spawn(function()
            while Settings.PoisonGrab do
                task.wait(0.3)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local damageRemote = getDamageRemote()
                        if damageRemote then
                            damageRemote:FireServer(target.Character.HumanoidRootPart, "Poison")
                        end
                        -- visual effect
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(1, 1, 1)
                        part.Color = Color3.fromRGB(0, 255, 0)
                        part.Material = Enum.Material.Neon
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 0.5
                        part.CFrame = target.Character.HumanoidRootPart.CFrame
                        part.Shape = Enum.PartType.Ball
                        part.Parent = Workspace
                        game:GetService("Debris"):AddItem(part, 0.5)
                    end
                end)
            end
        end)
    end,
})

-- Radioactive Grab
BlobTab:CreateToggle({
    Name = "Radioactive Grab",
    CurrentValue = false,
    Flag = "RadioGrab",
    Callback = function(Value)
        Settings.RadioactiveGrab = Value
        task.spawn(function()
            while Settings.RadioactiveGrab do
                task.wait(0.2)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local damageRemote = getDamageRemote()
                        if damageRemote then
                            damageRemote:FireServer(target.Character.HumanoidRootPart, "Radioactive")
                        end
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(2, 2, 2)
                        part.Color = Color3.fromRGB(255, 255, 0)
                        part.Material = Enum.Material.Neon
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 0.4
                        part.CFrame = target.Character.HumanoidRootPart.CFrame
                        part.Shape = Enum.PartType.Ball
                        part.Parent = Workspace
                        game:GetService("Debris"):AddItem(part, 0.5)
                    end
                end)
            end
        end)
    end,
})

-- Freeze Grab
BlobTab:CreateToggle({
    Name = "Freeze Grab",
    CurrentValue = false,
    Flag = "FreezeGrab",
    Callback = function(Value)
        Settings.FreezeGrab = Value
        task.spawn(function()
            while Settings.FreezeGrab do
                task.wait(0.3)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        target.Character.HumanoidRootPart.Anchored = true
                        task.delay(3, function()
                            pcall(function()
                                target.Character.HumanoidRootPart.Anchored = false
                            end)
                        end)
                    end
                end)
            end
        end)
    end,
})

-- Grab Range
BlobTab:CreateSlider({
    Name = "Grab / Aura Range",
    Range = {10, 200},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "AuraRange",
    Callback = function(Value)
        AuraRange = Value
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: ⚡ KICKS
-- ═══════════════════════════════════════════════════
local KickTab = Window:CreateTab("⚡ Kicks", 0)

local KickSection = KickTab:CreateSection("Kick Players")

-- Select Player for Kick
KickTab:CreateDropdown({
    Name = "Select Player",
    Options = getPlayerList(),
    CurrentOption = {},
    MultiOption = false,
    Flag = "KickTarget",
    Callback = function(Option)
        SelectedPlayer = Players:FindFirstChild(Option)
    end,
})

-- Instant Kick (Blobman Kick)
KickTab:CreateButton({
    Name = "⚡ Instant Kick (Blobman)",
    Callback = function()
        pcall(function()
            if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local blob = getBlobman()
                if blob then
                    local blobPart = blob:IsA("BasePart") and blob or blob:FindFirstChildWhichIsA("BasePart")
                    if blobPart then
                        -- TP blobman to target and fling them off the map
                        for i = 1, 20 do
                            blobPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame
                            applyVelocity(SelectedPlayer.Character.HumanoidRootPart, Vector3.new(0, 5000, 0), 9999)
                            task.wait(0.05)
                        end
                    end
                else
                    -- Fling kick без blobman
                    for i = 1, 30 do
                        HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1)
                        Humanoid.WalkSpeed = 500
                        applyVelocity(SelectedPlayer.Character.HumanoidRootPart, (SelectedPlayer.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Unit * 3000 + Vector3.new(0, 2000, 0), 1)
                        task.wait(0.05)
                    end
                    Humanoid.WalkSpeed = WalkSpeedVal
                end
                Rayfield:Notify({Title = "DMM HUB", Content = "Kicked " .. SelectedPlayer.Name .. "!", Duration = 3})
            else
                Rayfield:Notify({Title = "DMM HUB", Content = "Select a player first!", Duration = 3})
            end
        end)
    end,
})

-- Loop Kick
KickTab:CreateToggle({
    Name = "🔄 Loop Kick Selected",
    CurrentValue = false,
    Flag = "LoopKick",
    Callback = function(Value)
        Settings.LoopKick = Value
        task.spawn(function()
            while Settings.LoopKick do
                task.wait(0.5)
                pcall(function()
                    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        flingPlayer(SelectedPlayer)
                        applyVelocity(SelectedPlayer.Character.HumanoidRootPart, Vector3.new(math.random(-1,1), 5, math.random(-1,1)), 3000)
                    end
                end)
            end
        end)
    end,
})

-- Kick ALL
KickTab:CreateButton({
    Name = "💥 Kick ALL Players",
    Callback = function()
        task.spawn(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        flingPlayer(p)
                        applyVelocity(p.Character.HumanoidRootPart, Vector3.new(math.random(-1,1), 5, math.random(-1,1)), 3000)
                    end)
                    task.wait(0.2)
                end
            end
        end)
        Rayfield:Notify({Title = "DMM HUB", Content = "Kicked all players!", Duration = 3})
    end,
})

-- Loop Kill
KickTab:CreateToggle({
    Name = "🔄 Loop Kill Selected",
    CurrentValue = false,
    Flag = "LoopKillPlayer",
    Callback = function(Value)
        Settings.LoopKillPlayer = Value
        task.spawn(function()
            while Settings.LoopKillPlayer do
                task.wait(0.3)
                pcall(function()
                    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        SelectedPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
                    end
                end)
            end
        end)
    end,
})

-- Loop Kill All
KickTab:CreateToggle({
    Name = "💀 Loop Kill ALL",
    CurrentValue = false,
    Flag = "LoopKillAll",
    Callback = function(Value)
        Settings.LoopKillAll = Value
        task.spawn(function()
            while Settings.LoopKillAll do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            p.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
                        end
                    end)
                end
            end
        end)
    end,
})

local KickPowerSection = KickTab:CreateSection("Kick Settings")

KickTab:CreateSlider({
    Name = "Fling Power",
    Range = {100, 10000},
    Increment = 100,
    Suffix = "force",
    CurrentValue = 500,
    Flag = "FlingPower",
    Callback = function(Value)
        FlingPower = Value
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: ⚔️ COMBAT
-- ═══════════════════════════════════════════════════
local CombatTab = Window:CreateTab("⚔️ Combat", 0)

local CombatSection = CombatTab:CreateSection("Offensive")

-- Super Throw
CombatTab:CreateToggle({
    Name = "Super Throw",
    CurrentValue = false,
    Flag = "SuperThrow",
    Callback = function(Value)
        Settings.SuperThrow = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Throw Power",
    Range = {100, 5000},
    Increment = 50,
    Suffix = "force",
    CurrentValue = 300,
    Flag = "ThrowPower",
    Callback = function(Value)
        ThrowPower = Value
    end,
})

-- Super Strength
CombatTab:CreateToggle({
    Name = "Super Strength",
    CurrentValue = false,
    Flag = "SuperStrength",
    Callback = function(Value)
        Settings.SuperStrength = Value
        -- Модифицируем все BodyMovers при подбирании
    end,
})

-- Silent Aim
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(Value)
        Settings.SilentAim = Value
    end,
})

-- Position Damage
CombatTab:CreateToggle({
    Name = "Position Damage",
    CurrentValue = false,
    Flag = "PosDamage",
    Callback = function(Value)
        Settings.PositionDamage = Value
        task.spawn(function()
            while Settings.PositionDamage do
                task.wait(0.2)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local remote = getDamageRemote()
                        if remote then
                            remote:FireServer(target, target.Character.HumanoidRootPart.Position)
                        end
                    end
                end)
            end
        end)
    end,
})

local AuraSection = CombatTab:CreateSection("Auras")

-- Fling Aura
CombatTab:CreateToggle({
    Name = "Fling Aura",
    CurrentValue = false,
    Flag = "FlingAura",
    Callback = function(Value)
        Settings.FlingAura = Value
        task.spawn(function()
            while Settings.FlingAura do
                task.wait(0.2)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then
                                flingPlayer(p)
                            end
                        end
                    end)
                end
            end
        end)
    end,
})

-- Void Aura
CombatTab:CreateToggle({
    Name = "Void Aura",
    CurrentValue = false,
    Flag = "VoidAura",
    Callback = function(Value)
        Settings.VoidAura = Value
        task.spawn(function()
            while Settings.VoidAura do
                task.wait(0.5)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then
                                voidPlayer(p)
                            end
                        end
                    end)
                end
            end
        end)
    end,
})

-- Poison Aura
CombatTab:CreateToggle({
    Name = "Poison Aura",
    CurrentValue = false,
    Flag = "PoisonAura",
    Callback = function(Value)
        Settings.PoisonAura = Value
        task.spawn(function()
            while Settings.PoisonAura do
                task.wait(0.5)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then
                                local remote = getDamageRemote()
                                if remote then
                                    remote:FireServer(p.Character.HumanoidRootPart, "Poison")
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end,
})

-- Follow Aura
CombatTab:CreateToggle({
    Name = "Follow Aura",
    CurrentValue = false,
    Flag = "FollowAura",
    Callback = function(Value)
        Settings.FollowAura = Value
        task.spawn(function()
            while Settings.FollowAura do
                RunService.Heartbeat:Wait()
                pcall(function()
                    if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        HumanoidRootPart.CFrame = SelectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    end
                end)
            end
        end)
    end,
})

-- Kill Aura
CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        Settings.KillAura = Value
        task.spawn(function()
            while Settings.KillAura do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then
                                p.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
                            end
                        end
                    end)
                end
            end
        end)
    end,
})

local DefSection = CombatTab:CreateSection("Defensive")

-- Anti Grab
CombatTab:CreateToggle({
    Name = "Anti Grab",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        Settings.AntiGrab = Value
        task.spawn(function()
            while Settings.AntiGrab do
                task.wait(0.1)
                pcall(function()
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("Weld") or v:IsA("WeldConstraint") then
                            local p0 = v:IsA("Weld") and v.Part0 or v.Part0
                            local p1 = v:IsA("Weld") and v.Part1 or v.Part1
                            if p0 and p1 then
                                local isExternal = (not p0:IsDescendantOf(Character) or not p1:IsDescendantOf(Character))
                                if isExternal then
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

-- Anti Explosion
CombatTab:CreateToggle({
    Name = "Anti Explosion",
    CurrentValue = false,
    Flag = "AntiExplosion",
    Callback = function(Value)
        Settings.AntiExplosion = Value
        if Value then
            Workspace.DescendantAdded:Connect(function(obj)
                if Settings.AntiExplosion and obj:IsA("Explosion") then
                    obj.BlastPressure = 0
                    obj.BlastRadius = 0
                    obj.DestroyJointRadiusPercent = 0
                end
            end)
        end
    end,
})

-- Anti Kick (не позволяет себя кикнуть)
CombatTab:CreateToggle({
    Name = "Anti Kick",
    CurrentValue = false,
    Flag = "AntiKick",
    Callback = function(Value)
        Settings.AntiKick = Value
        task.spawn(function()
            while Settings.AntiKick do
                task.wait(0.05)
                pcall(function()
                    if HumanoidRootPart.Velocity.Magnitude > 200 then
                        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                    end
                    for _, v in pairs(HumanoidRootPart:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("BodyThrust") then
                            v:Destroy()
                        end
                    end
                end)
            end
        end)
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: 🏃 PLAYER
-- ═══════════════════════════════════════════════════
local PlayerTab = Window:CreateTab("🏃 Player", 0)

-- Walk Speed
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        WalkSpeedVal = Value
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end,
})

-- Jump Power
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        JumpPowerVal = Value
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Value
        end
    end,
})

-- Infinite Jump
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        Settings.InfJump = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        Settings.Noclip = Value
    end,
})

RunService.Stepped:Connect(function()
    if Settings.Noclip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- CFrame Speed Hack
PlayerTab:CreateToggle({
    Name = "Speed Hack (CFrame)",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        Settings.SpeedHack = Value
        task.spawn(function()
            while Settings.SpeedHack do
                RunService.Heartbeat:Wait()
                pcall(function()
                    if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
                        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Humanoid.MoveDirection * 2
                    end
                end)
            end
        end)
    end,
})

-- Invincibility
PlayerTab:CreateToggle({
    Name = "Invincibility (God Mode)",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        if Value then
            pcall(function()
                -- Бесконечное здоровье
                task.spawn(function()
                    while Value do
                        pcall(function()
                            if Humanoid then
                                Humanoid.Health = Humanoid.MaxHealth
                            end
                        end)
                        task.wait(0.1)
                    end
                end)
            end)
        end
    end,
})

-- Fly
local flying = false
local flySpeed = 50
local flyBV, flyBG

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        flying = Value
        if Value then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = HumanoidRootPart

            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            flyBG.P = 9e4
            flyBG.Parent = HumanoidRootPart

            task.spawn(function()
                while flying do
                    RunService.Heartbeat:Wait()
                    pcall(function()
                        local cam = Workspace.CurrentCamera
                        local moveDir = Humanoid.MoveDirection
                        if moveDir.Magnitude > 0 then
                            flyBV.Velocity = cam.CFrame.LookVector * flySpeed
                        else
                            flyBV.Velocity = Vector3.new(0, 0, 0)
                        end
                        flyBG.CFrame = cam.CFrame
                    end)
                end
            end)
        else
            if flyBV then flyBV:Destroy() end
            if flyBG then flyBG:Destroy() end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: 👁 VISUALS
-- ═══════════════════════════════════════════════════
local VisualsTab = Window:CreateTab("👁 Visuals", 0)

-- ESP
VisualsTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        if Value then
            local function addESP(player)
                if player == LocalPlayer then return end
                local function onChar(char)
                    if not Value then return end
                    local head = char:WaitForChild("Head", 5)
                    if not head then return end

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "DMM_ESP"
                    bb.Adornee = head
                    bb.Size = UDim2.new(0, 120, 0, 50)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = head

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.Text = player.Name
                    nameLabel.TextScaled = true
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.Parent = bb

                    local distLabel = Instance.new("TextLabel")
                    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distLabel.BackgroundTransparency = 1
                    distLabel.TextColor3 = Color3.new(1, 1, 1)
                    distLabel.TextStrokeTransparency = 0.5
                    distLabel.TextScaled = true
                    distLabel.Font = Enum.Font.Gotham
                    distLabel.Parent = bb

                    local hl = Instance.new("Highlight")
                    hl.Name = "DMM_HL"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                    hl.Parent = char

                    task.spawn(function()
                        while char and char.Parent and head and head.Parent do
                            pcall(function()
                                local d = math.floor((HumanoidRootPart.Position - head.Position).Magnitude)
                                distLabel.Text = "[" .. d .. "m]"
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
                        if v.Name == "DMM_ESP" or v.Name == "DMM_HL" then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end,
})

-- Fullbright
VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        local L = game:GetService("Lighting")
        if Value then
            L.Brightness = 2
            L.ClockTime = 14
            L.FogEnd = 100000
            L.GlobalShadows = false
            L.Ambient = Color3.fromRGB(178, 178, 178)
        else
            L.Brightness = 1
            L.ClockTime = 14
            L.FogEnd = 10000
            L.GlobalShadows = true
            L.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end,
})

-- TetraCube Wings (Visual)
VisualsTab:CreateButton({
    Name = "✨ TetraCube Wings",
    Callback = function()
        pcall(function()
            local wing1 = Instance.new("Part")
            wing1.Name = "DMM_Wing1"
            wing1.Size = Vector3.new(0.2, 4, 3)
            wing1.Color = Color3.fromRGB(100, 0, 255)
            wing1.Material = Enum.Material.Neon
            wing1.Transparency = 0.3
            wing1.CanCollide = false
            wing1.Massless = true
            wing1.Parent = Character

            local weld1 = Instance.new("Weld")
            weld1.Part0 = HumanoidRootPart
            weld1.Part1 = wing1
            weld1.C0 = CFrame.new(-1.5, 0.5, 0.8) * CFrame.Angles(0, 0, math.rad(-30))
            weld1.Parent = wing1

            local wing2 = wing1:Clone()
            wing2.Name = "DMM_Wing2"
            wing2.Parent = Character

            local weld2 = Instance.new("Weld")
            weld2.Part0 = HumanoidRootPart
            weld2.Part1 = wing2
            weld2.C0 = CFrame.new(1.5, 0.5, 0.8) * CFrame.Angles(0, 0, math.rad(30))
            weld2.Parent = wing2
        end)
        Rayfield:Notify({Title = "DMM HUB", Content = "Wings added!", Duration = 3})
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: 🌀 TELEPORT
-- ═══════════════════════════════════════════════════
local TeleportTab = Window:CreateTab("🌀 Teleport", 0)

TeleportTab:CreateDropdown({
    Name = "Teleport to Player",
    Options = getPlayerList(),
    CurrentOption = {},
    MultiOption = false,
    Flag = "TpPlayer",
    Callback = function(Option)
        pcall(function()
            local target = Players:FindFirstChild(Option)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                Rayfield:Notify({Title = "DMM HUB", Content = "TP'd to " .. Option, Duration = 2})
            end
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Spawn",
    Callback = function()
        pcall(function()
            local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
            if spawn then
                HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
            else
                HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
            end
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Random Player",
    Callback = function()
        pcall(function()
            local plrs = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(plrs, p)
                end
            end
            if #plrs > 0 then
                local rand = plrs[math.random(1, #plrs)]
                HumanoidRootPart.CFrame = rand.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                Rayfield:Notify({Title = "DMM HUB", Content = "TP'd to " .. rand.Name, Duration = 2})
            end
        end)
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: ⚙️ MISC
-- ═══════════════════════════════════════════════════
local MiscTab = Window:CreateTab("⚙ Misc", 0)

-- Anti AFK
MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(Value)
        if Value then
            LocalPlayer.Idled:Connect(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        end
    end,
})

-- Auto Claim Cash
MiscTab:CreateToggle({
    Name = "Auto Claim Cash / Coins",
    CurrentValue = false,
    Flag = "AutoCash",
    Callback = function(Value)
        Settings.AutoClaimCash = Value
        task.spawn(function()
            while Settings.AutoClaimCash do
                task.wait(1)
                pcall(function()
                    -- Метод 1: ProximityPrompts
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            fireproximityprompt(obj)
                        end
                    end
                    -- Метод 2: Remotes
                    local cashRemote = getCashRemote()
                    if cashRemote then
                        cashRemote:FireServer()
                    end
                    -- Метод 3: Touch coins
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("cash") or obj.Name:lower():find("money")) then
                            firetouchinterest(HumanoidRootPart, obj, 0)
                            task.wait(0.05)
                            firetouchinterest(HumanoidRootPart, obj, 1)
                        end
                    end
                end)
            end
        end)
    end,
})

-- Click TP (нажми и телепортируйся)
local clickTpEnabled = false
MiscTab:CreateToggle({
    Name = "Click Teleport",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value)
        clickTpEnabled = Value
    end,
})

local Mouse = LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    if clickTpEnabled and Mouse.Hit then
        HumanoidRootPart.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
    end
end)

-- Rejoin
MiscTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

-- Server Hop
MiscTab:CreateButton({
    Name = "🌐 Server Hop",
    Callback = function()
        pcall(function()
            local servers = game.HttpService:JSONDecode(
                game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
            )
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end,
})

-- Copy Game Link
MiscTab:CreateButton({
    Name = "📋 Copy Game Link",
    Callback = function()
        setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
        Rayfield:Notify({Title = "DMM HUB", Content = "Link copied!", Duration = 2})
    end,
})

-- Destroy Hub
MiscTab:CreateButton({
    Name = "❌ Destroy DMM HUB",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- ═══════════════════════════════════════════════════
-- GLOBAL HOOKS (SuperThrow & SilentAim)
-- ═══════════════════════════════════════════════════

-- SuperThrow hook: усиливает все выбрасывания
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Super Throw: если бросаем объект, увеличиваем силу
    if Settings.SuperThrow and method == "FireServer" and self:IsA("RemoteEvent") then
        if self.Name:lower():find("throw") or self.Name:lower():find("fling") or self.Name:lower():find("launch") then
            for i, v in pairs(args) do
                if typeof(v) == "Vector3" then
                    args[i] = v.Unit * ThrowPower
                end
                if typeof(v) == "number" and v > 1 then
                    args[i] = v * (ThrowPower / 100)
                end
            end
            return oldNamecall(self, unpack(args))
        end
    end

    -- Silent Aim: перенаправляет на ближайшего игрока
    if Settings.SilentAim and method == "FireServer" and self:IsA("RemoteEvent") then
        if self.Name:lower():find("aim") or self.Name:lower():find("shoot") or self.Name:lower():find("hit") then
            local target = getClosestPlayer(AuraRange)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                for i, v in pairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = target.Character.HumanoidRootPart.Position
                    end
                    if typeof(v) == "CFrame" then
                        args[i] = target.Character.HumanoidRootPart.CFrame
                    end
                end
            end
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end))

-- Super Strength: усиливаем хватку
if Settings.SuperStrength then
    Workspace.DescendantAdded:Connect(function(obj)
        if Settings.SuperStrength then
            if obj:IsA("BodyPosition") then
                obj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            elseif obj:IsA("BodyVelocity") then
                obj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════
-- ЗАГРУЗКА
-- ═══════════════════════════════════════════════════
Rayfield:Notify({
    Title = "💀 DMM HUB",
    Content = "Loaded! Fling Things and People 🎉",
    Duration = 5,
    Image = 0,
})

print("═══════════════════════════════")
print("  DMM HUB — Loaded Successfully")
print("  Game: Fling Things and People")
print("═════���═════════════════════════")
