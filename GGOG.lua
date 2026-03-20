-- ╔══════════════════════════════════════════════════════════╗
-- ║              DMM HUB — Fling Things and People          ║
-- ║                Built on Rayfield Interface               ║
-- ╚══════════════════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ═══════ SERVICES ═══════
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local UserInputService   = game:GetService("UserInputService")
local VirtualInputManager= game:GetService("VirtualInputManager")
local TweenService       = game:GetService("TweenService")
local Debris             = game:GetService("Debris")

local LocalPlayer     = Players.LocalPlayer
local Character       = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid        = Character:WaitForChild("Humanoid")
local HumanoidRootPart= Character:WaitForChild("HumanoidRootPart")

-- ═══════ SETTINGS ═══════
local Settings = {
    InstantKick       = false,
    LoopKick          = false,
    KickAll           = false,
    BlobmanGrab       = false,
    BlobmanLoopGrab   = false,
    BlobmanFree       = false,
    GrabAll           = false,
    KillGrab          = false,
    VoidGrab          = false,
    PoisonGrab        = false,
    RadioactiveGrab   = false,
    FreezeGrab        = false,
    FlingAura         = false,
    VoidAura          = false,
    PoisonAura        = false,
    FollowAura        = false,
    KillAura          = false,
    SuperThrow        = false,
    SuperStrength     = false,
    SilentAim         = false,
    AntiGrab          = false,
    AntiExplosion     = false,
    AntiKick          = false,
    PositionDamage    = false,
    InfJump           = false,
    Noclip            = false,
    SpeedHack         = false,
    AutoClaimCash     = false,
    LoopKillAll       = false,
    LoopKillPlayer    = false,
}

local SelectedPlayer = nil
local WalkSpeedVal   = 16
local JumpPowerVal   = 50
local AuraRange      = 30
local FlingPower     = 500
local ThrowPower     = 300

-- ═══════ HOME TAB SETTINGS ═══════
local HS = {
    BlobLoopGrabAll      = false,
    BlobLoopGrabPlayer   = false,
    BlobFreeze           = false,
    SpeedGrab            = false,
    PoisonGrab           = false,
    RadioactiveGrab      = false,
    DeathGrab            = false,
    BurnGrab             = false,
    VoidGrab             = false,
    MasslessGrab         = false,
    NoclipGrab           = false,
    KillGrab             = false,
    FreezeGrab           = false,
    LoopKickBlob         = false,
    AutoKickAllBlob      = false,
    LoopKill             = false,
    LoopKillAll          = false,
    LoopRagdoll          = false,
    LoopFire             = false,
    PoisonAura           = false,
    DeathAura            = false,
    RadioactiveAura      = false,
    BurnAura             = false,
    FlingAura            = false,
    AttractionAura       = false,
    VoidAura             = false,
    FollowAura           = false,
    KickAura             = false,
    SuperStrength        = false,
    StrengthVal          = 500,
    SilentAim            = false,
    AutoAttacker         = false,
    PositionDamage       = false,
    AntiGrab             = false,
    AntiExplosion        = false,
    AntiKick             = false,
    AntiVoid             = false,
    AntiBurn             = false,
    AntiLag              = false,
    AntiBlobman          = false,
    GucciAnti            = false,
    InfJump              = false,
    Noclip               = false,
    Fly                  = false,
    FlySpeed             = 50,
    GodMode              = false,
    DestroyServer        = false,
    LagServer            = false,
    BurnAll              = false,
    BringServer          = false,
    SpamSounds           = false,
    FeObjectTornado      = false,
    FeObjectAura         = false,
    FeObjectFloat        = false,
    AuraRange            = 40,
    FlingPower           = 9999,
}

local HSelPlayer     = nil
local HSelPlayerName = "None"

-- ═══════ ANTI-DETECTED STATE ═══════
-- FIX #4: Define all variables the Anti-Detected system needs
local AntiDetectedEnabled = false
local AntiDetectedCooldown = false
local AntiGrabEnabled     = false
local Flying              = false
local IsTeleporting       = false
local LastInputTime       = tick()
local PositionHistory     = {}   -- {tick(), CFrame}
local POS_HISTORY_WINDOW  = 10   -- seconds to keep

-- Track input so we know when the player is actually moving
UserInputService.InputBegan:Connect(function() LastInputTime = tick() end)
UserInputService.InputEnded:Connect(function() LastInputTime = tick() end)

-- Record position history every 0.25s
task.spawn(function()
    while true do
        task.wait(0.25)
        pcall(function()
            if HumanoidRootPart and HumanoidRootPart.Parent then
                table.insert(PositionHistory, {tick(), HumanoidRootPart.CFrame})
                -- prune old entries
                while #PositionHistory > 0
                      and (tick() - PositionHistory[1][1]) > POS_HISTORY_WINDOW do
                    table.remove(PositionHistory, 1)
                end
            end
        end)
    end
end)

-- FIX #4: Define TeleportBack so Anti-Detected can call it
local function TeleportBack(seconds)
    local target = tick() - seconds
    for i = #PositionHistory, 1, -1 do
        if PositionHistory[i][1] <= target then
            HumanoidRootPart.CFrame = PositionHistory[i][2]
            return true
        end
    end
    if #PositionHistory > 0 then
        HumanoidRootPart.CFrame = PositionHistory[1][2]
        return true
    end
    return false
end

-- FIX #1: Define SetupAntiGrabAnimTracker (stub — expand if you need anim detection)
local function SetupAntiGrabAnimTracker(char)
    -- watches for "grab" animations and cancels them
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        animator.AnimationPlayed:Connect(function(track)
            if AntiGrabEnabled then
                local name = track.Animation and track.Animation.Name or ""
                if name:lower():find("grab") or name:lower():find("hold") then
                    track:Stop()
                end
            end
        end)
    end)
end

-- ═══════ CHARACTER RELOAD ═══════
LocalPlayer.CharacterAdded:Connect(function(char)
    Character       = char
    Humanoid        = char:WaitForChild("Humanoid")
    HumanoidRootPart= char:WaitForChild("HumanoidRootPart")
    task.wait(0.3)
    SetupAntiGrabAnimTracker(char)
end)

if LocalPlayer.Character then
    SetupAntiGrabAnimTracker(LocalPlayer.Character)
end

-- ═══════ UTILITIES ═══════
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
        if p ~= LocalPlayer and p.Character
           and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (HumanoidRootPart.Position
                     - p.Character.HumanoidRootPart.Position).Magnitude
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
        if obj.Name == "BlobMan" or obj.Name == "Blobman" then
            table.insert(blobs, obj)
        end
    end
    return blobs
end

local function getGrabbableRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("grab")
           or v.Name:lower():find("pickup")
           or v.Name:lower():find("interact")) then return v end
    end
    return nil
end

local function getKickRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("kick")
           or v.Name:lower():find("fling")
           or v.Name:lower():find("throw")
           or v.Name:lower():find("hit")) then return v end
    end
    return nil
end

local function getDamageRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("damage")
           or v.Name:lower():find("attack")
           or v.Name:lower():find("kill")) then return v end
    end
    return nil
end

local function getCashRemote()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("cash")
           or v.Name:lower():find("coin")
           or v.Name:lower():find("claim")
           or v.Name:lower():find("money")) then return v end
    end
    return nil
end

local function applyVelocity(part, direction, power)
    if part then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity   = direction * power
        bv.MaxForce   = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent     = part
        Debris:AddItem(bv, 0.3)
    end
end

local function flingPlayer(target)
    pcall(function()
        if target and target.Character
           and target.Character:FindFirstChild("HumanoidRootPart") then
            local tHRP      = target.Character.HumanoidRootPart
            local direction  = (tHRP.Position - HumanoidRootPart.Position).Unit
            HumanoidRootPart.CFrame = tHRP.CFrame + direction * 2
            applyVelocity(tHRP,
                Vector3.new(math.random(-1,1), 1, math.random(-1,1)), FlingPower)
        end
    end)
end

local function voidPlayer(target)
    pcall(function()
        if target and target.Character
           and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0)
        end
    end)
end

-- ═══════ HOME-TAB HELPERS ═══════
local function h_alive(p)
    return p and p.Character
       and p.Character:FindFirstChild("HumanoidRootPart")
       and p.Character:FindFirstChild("Humanoid")
       and p.Character.Humanoid.Health > 0
end

local function h_dist(p)
    if h_alive(p) and HumanoidRootPart then
        return (HumanoidRootPart.Position
              - p.Character.HumanoidRootPart.Position).Magnitude
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
        return blob:FindFirstChildWhichIsA("Seat")
            or blob:FindFirstChildWhichIsA("VehicleSeat")
            or blob:FindFirstChild("Seat")
    end
    return nil
end

local function h_getBlobHands(blob)
    local hands = {}
    if blob then
        for _, p in pairs(blob:GetDescendants()) do
            if p:IsA("BasePart") and (p.Name:lower():find("hand")
               or p.Name:lower():find("grab")
               or p.Name:lower():find("palm")) then
                table.insert(hands, p)
            end
        end
        if #hands == 0 then
            for _, p in pairs(blob:GetDescendants()) do
                if p:IsA("BasePart") and not p:IsA("Seat")
                   and not p:IsA("VehicleSeat") then
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
        if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
            seat:Sit(Humanoid)
        end
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
            pcall(function()
                firetouchinterest(hand, target.Character.HumanoidRootPart, 0)
            end)
        end
        task.wait(0.1)
        if h_alive(target) then
            local hrp = target.Character.HumanoidRootPart
            local bv  = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, HS.FlingPower, 0)
            bv.Parent   = hrp
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

local function h_flingPlayer(target)
    pcall(function()
        if not h_alive(target) then return end
        local tHRP  = target.Character.HumanoidRootPart
        local oldCF = HumanoidRootPart.CFrame
        HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, -1)
        local bav = Instance.new("BodyAngularVelocity")
        bav.AngularVelocity = Vector3.new(0, HS.FlingPower, 0)
        bav.MaxTorque       = Vector3.new(1e9, 1e9, 1e9)
        bav.Parent          = HumanoidRootPart
        Debris:AddItem(bav, 0.3)
        task.wait(0.3)
        HumanoidRootPart.CFrame = oldCF
    end)
end

local function h_voidPlayer(target)
    pcall(function()
        if h_alive(target) then
            target.Character.HumanoidRootPart.CFrame = CFrame.new(9e9, 9e9, 9e9)
        end
    end)
end

local function h_applyGrabEffect(target, effectType)
    pcall(function()
        if not h_alive(target) then return end
        local hrp = target.Character.HumanoidRootPart

        if effectType == "Poison" then
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Ball; p.Size = Vector3.new(3,3,3)
            p.Color = Color3.fromRGB(0,255,0); p.Material = Enum.Material.Neon
            p.Transparency = 0.4; p.Anchored = true; p.CanCollide = false
            p.CFrame = hrp.CFrame; p.Parent = Workspace
            Debris:AddItem(p, 0.5)
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.new(0,-50,0)
            bv.Parent   = hrp; Debris:AddItem(bv, 0.2)

        elseif effectType == "Radioactive" then
            local p = Instance.new("Part")
            p.Shape = Enum.PartType.Ball; p.Size = Vector3.new(4,4,4)
            p.Color = Color3.fromRGB(255,255,0); p.Material = Enum.Material.Neon
            p.Transparency = 0.3; p.Anchored = true; p.CanCollide = false
            p.CFrame = hrp.CFrame; p.Parent = Workspace
            Debris:AddItem(p, 0.5)

        elseif effectType == "Death" then
            hrp.CFrame = CFrame.new(0, -500, 0)

        elseif effectType == "Burn" then
            local fire  = Instance.new("Fire")
            fire.Size   = 10; fire.Heat = 25
            fire.Parent = hrp; Debris:AddItem(fire, 3)

        elseif effectType == "Void" then
            hrp.CFrame = CFrame.new(9e9, 9e9, 9e9)

        elseif effectType == "Massless" then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.Massless = true end
            end

        elseif effectType == "Noclip" then
            for _, part in pairs(target.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
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
-- WINDOW
-- ═══════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name                  = "💀 DMM HUB — FTAP",
    Icon                  = 0,
    LoadingTitle          = "DMM HUB",
    LoadingSubtitle       = "Fling Things and People",
    Theme                 = "Default",
    DisableRayfieldPrompts= true,
    DisableBuildWarnings  = true,
    ConfigurationSaving   = {
        Enabled    = true,
        FolderName = "DMM_HUB",
        FileName   = "FTAP_Config"
    },
    KeySystem = false,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║                    TAB: 🏠 HOME                          ║
-- ╚══════════════════════════════════════════════════════════╝
local HomeTab = Window:CreateTab("🏠 Home", 0)

-- ══════════════ BLOBMAN CONTROLS ══════════════
HomeTab:CreateSection("🦠 Blobman Controls")

HomeTab:CreateButton({
    Name = "🟢 Sit On Blobman",
    Callback = function()
        local blob = getBlobman()
        if blob then
            h_sitOnBlob(blob)
            Rayfield:Notify({Title="DMM",Content="Mounted Blobman!",Duration=2})
        else
            Rayfield:Notify({Title="DMM",Content="No Blobman found!",Duration=2})
        end
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
            for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                if r:IsA("RemoteFunction") then
                    pcall(function() r:InvokeServer("BlobMan") end)
                    pcall(function() r:InvokeServer("Buy", "Blobman") end)
                end
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Attempted spawn Blobman!",Duration=2})
    end,
})

HomeTab:CreateToggle({
    Name = "❄️ Freeze Blobman",
    CurrentValue = false,
    Flag = "H_BlobFreeze",
    Callback = function(V)
        HS.BlobFreeze = V
        task.spawn(function()
            while HS.BlobFreeze do
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

-- ══════════════ BLOBMAN GRAB ══════════════
HomeTab:CreateSection("🦠 Blobman Loop Grab")

HomeTab:CreateToggle({
    Name = "🔄 Loop Grab ALL Players",
    CurrentValue = false,
    Flag = "H_BlobGrabAll",
    Callback = function(V)
        HS.BlobLoopGrabAll = V
        task.spawn(function()
            while HS.BlobLoopGrabAll do
                task.wait(0.15)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and h_alive(p) then
                                h_blobGrabPlayer(blob, p)
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateDropdown({
    Name = "Select Player (Blob Grab)",
    Options = getPlayerList(),
    CurrentOption = {},
    MultiOption = false,
    Flag = "H_BlobGrabTarget",
    Callback = function(Opt)
        HSelPlayerName = Opt
        HSelPlayer = Players:FindFirstChild(Opt)
    end,
})

HomeTab:CreateToggle({
    Name = "🔄 Loop Grab Selected Player",
    CurrentValue = false,
    Flag = "H_BlobGrabSel",
    Callback = function(V)
        HS.BlobLoopGrabPlayer = V
        task.spawn(function()
            while HS.BlobLoopGrabPlayer do
                task.wait(0.15)
                pcall(function()
                    local blob = getBlobman()
                    if blob and h_alive(HSelPlayer) then
                        h_blobGrabPlayer(blob, HSelPlayer)
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "⚡ Speed Grab Player",
    CurrentValue = false,
    Flag = "H_SpeedGrab",
    Callback = function(V)
        HS.SpeedGrab = V
        task.spawn(function()
            while HS.SpeedGrab do
                task.wait(0.05)
                pcall(function()
                    local blob = getBlobman()
                    if blob and h_alive(HSelPlayer) then
                        h_blobGrabPlayer(blob, HSelPlayer)
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "🤏 Multiple Grab (Grab All Blobmen)",
    Callback = function()
        pcall(function()
            for _, m in pairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and (m.Name == "BlobMan" or m.Name == "Blobman") then
                    local hands = h_getBlobHands(m)
                    for _, h in pairs(hands) do
                        firetouchinterest(HumanoidRootPart, h, 0)
                        task.wait(0.02)
                        firetouchinterest(HumanoidRootPart, h, 1)
                    end
                end
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Grabbed all Blobmen!",Duration=2})
    end,
})

-- ══════════════ GRAB MODS ══════════════
HomeTab:CreateSection("💎 Grab Mods")

local h_grabTypes = {
    "Poison","Radioactive","Death","Burn","Void","Massless","Noclip","Kill","Freeze"
}

for _, gt in pairs(h_grabTypes) do
    HomeTab:CreateToggle({
        Name = "💎 " .. gt .. " Grab",
        CurrentValue = false,
        Flag = "H_" .. gt .. "Grab",
        Callback = function(V)
            HS[gt .. "Grab"] = V
            task.spawn(function()
                while HS[gt .. "Grab"] do
                    task.wait(0.3)
                    pcall(function()
                        local target = h_closest(HS.AuraRange)
                        if target then h_applyGrabEffect(target, gt) end
                    end)
                end
            end)
        end,
    })
end

HomeTab:CreateSlider({
    Name = "Grab / Aura Range",
    Range = {10, 300}, Increment = 5, Suffix = "studs",
    CurrentValue = 40, Flag = "H_AuraRange",
    Callback = function(V) HS.AuraRange = V end,
})

-- ══════════════ KICKS & KILLS ══════════════
HomeTab:CreateSection("⚡ Kicks & Kills")

HomeTab:CreateDropdown({
    Name = "Select Player (Kick)",
    Options = getPlayerList(),
    CurrentOption = {}, MultiOption = false, Flag = "H_KickTarget",
    Callback = function(Opt)
        HSelPlayer     = Players:FindFirstChild(Opt)
        HSelPlayerName = Opt
    end,
})

HomeTab:CreateButton({
    Name = "⚡ Instant Kick (Blobman)",
    Callback = function()
        pcall(function()
            local blob = getBlobman()
            if blob and h_alive(HSelPlayer) then
                for i = 1, 30 do
                    h_blobKickPlayer(blob, HSelPlayer)
                    task.wait(0.05)
                end
                Rayfield:Notify({Title="DMM",Content="Kicked "..HSelPlayerName.."!",Duration=2})
            else
                Rayfield:Notify({Title="DMM",Content="Need Blobman + Target!",Duration=2})
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🔄 Loop Kick (Blobman)",
    CurrentValue = false, Flag = "H_LoopKickBlob",
    Callback = function(V)
        HS.LoopKickBlob = V
        task.spawn(function()
            while HS.LoopKickBlob do
                task.wait(0.2)
                pcall(function()
                    local blob = getBlobman()
                    if blob and h_alive(HSelPlayer) then
                        h_blobKickPlayer(blob, HSelPlayer)
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "💥 Kick ALL (Blobman)",
    Callback = function()
        task.spawn(function()
            local blob = getBlobman()
            if blob then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and h_alive(p) then
                        for i = 1, 15 do
                            h_blobKickPlayer(blob, p)
                            task.wait(0.05)
                        end
                    end
                end
                Rayfield:Notify({Title="DMM",Content="Kicked ALL!",Duration=2})
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🔄 Auto Kick ALL Off Blob",
    CurrentValue = false, Flag = "H_AutoKickAll",
    Callback = function(V)
        HS.AutoKickAllBlob = V
        task.spawn(function()
            while HS.AutoKickAllBlob do
                task.wait(0.3)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and h_alive(p) then
                                h_blobKickPlayer(blob, p)
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "💀 Loop Kill Selected",
    CurrentValue = false, Flag = "H_LoopKill",
    Callback = function(V)
        HS.LoopKill = V
        task.spawn(function()
            while HS.LoopKill do
                task.wait(0.3)
                pcall(function()
                    if h_alive(HSelPlayer) then
                        HSelPlayer.Character.HumanoidRootPart.CFrame =
                            CFrame.new(0, -500, 0)
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "☠️ Loop Kill ALL",
    CurrentValue = false, Flag = "H_LoopKillAll",
    Callback = function(V)
        HS.LoopKillAll = V
        task.spawn(function()
            while HS.LoopKillAll do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and h_alive(p) then
                            p.Character.HumanoidRootPart.CFrame =
                                CFrame.new(0, -500, 0)
                        end
                    end)
                end
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🔄 Loop Ragdoll Selected",
    CurrentValue = false, Flag = "H_LoopRagdoll",
    Callback = function(V)
        HS.LoopRagdoll = V
        task.spawn(function()
            while HS.LoopRagdoll do
                task.wait(0.5)
                pcall(function()
                    if h_alive(HSelPlayer) then
                        local hrp = HSelPlayer.Character.HumanoidRootPart
                        local bv  = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                        bv.Velocity = Vector3.new(
                            math.random(-200,200), 100, math.random(-200,200))
                        bv.Parent = hrp; Debris:AddItem(bv, 0.3)
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🔥 Loop Fire Selected",
    CurrentValue = false, Flag = "H_LoopFire",
    Callback = function(V)
        HS.LoopFire = V
        task.spawn(function()
            while HS.LoopFire do
                task.wait(1)
                pcall(function()
                    if h_alive(HSelPlayer) then
                        h_applyGrabEffect(HSelPlayer, "Burn")
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "🌊 Send to Void (Selected)",
    Callback = function()
        if h_alive(HSelPlayer) then
            h_voidPlayer(HSelPlayer)
            Rayfield:Notify({Title="DMM",Content="Voided "..HSelPlayerName,Duration=2})
        end
    end,
})

-- FIX #5: Loop void used a local that captured the value at call-time.
--         Now reads from HS table so toggling off actually stops it.
HomeTab:CreateToggle({
    Name = "🌊 Loop Send to Void",
    CurrentValue = false, Flag = "H_LoopVoid",
    Callback = function(V)
        HS.LoopVoid = V                         -- ← store in HS
        task.spawn(function()
            while HS.LoopVoid do                 -- ← read from HS
                task.wait(0.5)
                pcall(function()
                    if h_alive(HSelPlayer) then h_voidPlayer(HSelPlayer) end
                end)
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "🔗 Bring Selected Player",
    Callback = function()
        pcall(function()
            if h_alive(HSelPlayer) then
                HSelPlayer.Character.HumanoidRootPart.CFrame =
                    HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                Rayfield:Notify({Title="DMM",Content="Brought "..HSelPlayerName,Duration=2})
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "🔒 Lock Selected Player",
    Callback = function()
        pcall(function()
            if h_alive(HSelPlayer) then
                HSelPlayer.Character.HumanoidRootPart.Anchored = true
                Rayfield:Notify({Title="DMM",Content="Locked "..HSelPlayerName,Duration=2})
            end
        end)
    end,
})

HomeTab:CreateSlider({
    Name = "Fling / Kick Power",
    Range = {100, 99999}, Increment = 500, Suffix = "force",
    CurrentValue = 9999, Flag = "H_FlingPow",
    Callback = function(V) HS.FlingPower = V end,
})

-- ══════════════ COMBAT ══════════════
HomeTab:CreateSection("⚔️ Combat")

HomeTab:CreateToggle({
    Name = "💪 Super Strength",
    CurrentValue = false, Flag = "H_SuperStr",
    Callback = function(V) HS.SuperStrength = V end,
})

HomeTab:CreateSlider({
    Name = "Custom Strength",
    Range = {0, 10000}, Increment = 50, Suffix = "str",
    CurrentValue = 500, Flag = "H_StrVal",
    Callback = function(V) HS.StrengthVal = V end,
})

HomeTab:CreateToggle({
    Name = "🎯 Silent Aim",
    CurrentValue = false, Flag = "H_SilentAim",
    Callback = function(V) HS.SilentAim = V; Settings.SilentAim = V end,
})

HomeTab:CreateToggle({
    Name = "⚔️ Auto Attacker",
    CurrentValue = false, Flag = "H_AutoAtk",
    Callback = function(V)
        HS.AutoAttacker = V
        task.spawn(function()
            while HS.AutoAttacker do
                task.wait(0.2)
                pcall(function()
                    local target = h_closest(HS.AuraRange)
                    if target and h_alive(target) then h_flingPlayer(target) end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "📍 Position Damage",
    CurrentValue = false, Flag = "H_PosDmg",
    Callback = function(V)
        HS.PositionDamage = V
        task.spawn(function()
            while HS.PositionDamage do
                task.wait(0.2)
                pcall(function()
                    local target = h_closest(HS.AuraRange)
                    if target and h_alive(target) then
                        target.Character.HumanoidRootPart.CFrame =
                            CFrame.new(0, -300, 0)
                        task.wait(0.1)
                    end
                end)
            end
        end)
    end,
})

-- ══════════════ AURAS ══════════════
HomeTab:CreateSection("🌀 Auras")

local h_auraTypes = {
    {name="☠️ Poison Aura",       key="PoisonAura",      effect="Poison"},
    {name="💀 Death Aura",        key="DeathAura",       effect="Death"},
    {name="☢️ Radioactive Aura",  key="RadioactiveAura", effect="Radioactive"},
    {name="🔥 Burn Aura",         key="BurnAura",        effect="Burn"},
    {name="🌊 Void Aura",         key="VoidAura",        effect="Void"},
    {name="🧲 Attraction Aura",   key="AttractionAura",  effect=nil},
    {name="💨 Fling Aura",        key="FlingAura",       effect=nil},
    {name="👣 Follow Aura",       key="FollowAura",      effect=nil},
    {name="👢 Kick Aura (Blob)",  key="KickAura",        effect=nil},
}

for _, aura in pairs(h_auraTypes) do
    HomeTab:CreateToggle({
        Name = aura.name,
        CurrentValue = false, Flag = "H_" .. aura.key,
        Callback = function(V)
            HS[aura.key] = V
            task.spawn(function()
                while HS[aura.key] do
                    task.wait(0.3)
                    for _, p in pairs(Players:GetPlayers()) do
                        pcall(function()
                            if p ~= LocalPlayer and h_alive(p)
                               and h_dist(p) <= HS.AuraRange then
                                if aura.effect then
                                    h_applyGrabEffect(p, aura.effect)
                                elseif aura.key == "FlingAura" then
                                    h_flingPlayer(p)
                                elseif aura.key == "AttractionAura" then
                                    p.Character.HumanoidRootPart.CFrame =
                                        HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
                                elseif aura.key == "FollowAura" then
                                    if h_alive(HSelPlayer) then
                                        HumanoidRootPart.CFrame =
                                            HSelPlayer.Character.HumanoidRootPart.CFrame
                                            * CFrame.new(0,0,-3)
                                    end
                                elseif aura.key == "KickAura" then
                                    local blob = getBlobman()
                                    if blob then h_blobKickPlayer(blob, p) end
                                end
                            end
                        end)
                    end
                end
            end)
        end,
    })
end

HomeTab:CreateSlider({
    Name = "Custom Fling Aura Strength",
    Range = {100, 99999}, Increment = 500, Suffix = "power",
    CurrentValue = 9999, Flag = "H_FlingAuraStr",
    Callback = function(V) HS.FlingPower = V end,
})

-- ══════════════ DEFENSE / ANTIS ══════════════
HomeTab:CreateSection("🛡️ Defense / Antis")

HomeTab:CreateToggle({
    Name = "🛡️ Anti Grab",
    CurrentValue = false, Flag = "H_AntiGrab",
    Callback = function(V)
        HS.AntiGrab = V
        task.spawn(function()
            while HS.AntiGrab do
                task.wait(0.05)
                pcall(function()
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("Weld") or v:IsA("WeldConstraint") then
                            local p0, p1 = v.Part0, v.Part1
                            if p0 and p1 then
                                if not p0:IsDescendantOf(Character)
                                   or not p1:IsDescendantOf(Character) then
                                    v:Destroy()
                                end
                            end
                        end
                    end
                    if Humanoid.SeatPart
                       and not Humanoid.SeatPart:IsDescendantOf(Character) then
                        Humanoid.Jump = true
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🛡️ Gucci Anti (Advanced)",
    CurrentValue = false, Flag = "H_GucciAnti",
    Callback = function(V)
        HS.GucciAnti = V
        task.spawn(function()
            while HS.GucciAnti do
                task.wait(0.02)
                pcall(function()
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("Weld") or v:IsA("WeldConstraint") then
                            local p0, p1 = v.Part0, v.Part1
                            if p0 and p1
                               and (not p0:IsDescendantOf(Character)
                                    or not p1:IsDescendantOf(Character)) then
                                v:Destroy()
                            end
                        end
                        if v:IsA("BodyVelocity") or v:IsA("BodyForce")
                           or v:IsA("BodyThrust")
                           or v:IsA("BodyAngularVelocity") then
                            if v.Parent and v.Parent:IsDescendantOf(Character) then
                                v:Destroy()
                            end
                        end
                    end
                    if HumanoidRootPart.Velocity.Magnitude > 300 then
                        HumanoidRootPart.Velocity    = Vector3.zero
                        HumanoidRootPart.RotVelocity = Vector3.zero
                    end
                    if Humanoid.SeatPart
                       and not Humanoid.SeatPart:IsDescendantOf(Character) then
                        Humanoid.Jump = true
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🛡️ Anti Blobman",
    CurrentValue = false, Flag = "H_AntiBlobman",
    Callback = function(V)
        HS.AntiBlobman = V
        task.spawn(function()
            while HS.AntiBlobman do
                task.wait(0.05)
                pcall(function()
                    if Humanoid.SeatPart then
                        local seat = Humanoid.SeatPart
                        if seat.Parent
                           and seat.Parent.Name:lower():find("blob") then
                            Humanoid.Jump = true
                        end
                    end
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("Weld") or v:IsA("WeldConstraint") then
                            if v.Part0 and v.Part1 then
                                local other = v.Part0:IsDescendantOf(Character)
                                    and v.Part1 or v.Part0
                                if other and other.Parent
                                   and (other.Parent.Name:lower():find("blob")
                                        or other.Name:lower():find("hand")) then
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

HomeTab:CreateToggle({
    Name = "🛡️ Anti Explosion",
    CurrentValue = false, Flag = "H_AntiExpl",
    Callback = function(V) HS.AntiExplosion = V end,
})

HomeTab:CreateToggle({
    Name = "🛡️ Anti Kick (Velocity Block)",
    CurrentValue = false, Flag = "H_AntiKick",
    Callback = function(V)
        HS.AntiKick = V
        task.spawn(function()
            while HS.AntiKick do
                task.wait(0.03)
                pcall(function()
                    if HumanoidRootPart.Velocity.Magnitude > 200 then
                        HumanoidRootPart.Velocity    = Vector3.zero
                        HumanoidRootPart.RotVelocity = Vector3.zero
                    end
                    for _, v in pairs(HumanoidRootPart:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyForce")
                           or v:IsA("BodyThrust")
                           or v:IsA("BodyAngularVelocity") then
                            v:Destroy()
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🛡️ Anti Void",
    CurrentValue = false, Flag = "H_AntiVoid",
    Callback = function(V)
        HS.AntiVoid = V
        task.spawn(function()
            while HS.AntiVoid do
                task.wait(0.1)
                pcall(function()
                    if HumanoidRootPart.Position.Y < -100 then
                        HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🛡️ Anti Burn",
    CurrentValue = false, Flag = "H_AntiBurn",
    Callback = function(V)
        HS.AntiBurn = V
        task.spawn(function()
            while HS.AntiBurn do
                task.wait(0.5)
                pcall(function()
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("Fire") or v:IsA("Smoke")
                           or v:IsA("Sparkles") then
                            v:Destroy()
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🛡️ Anti Lag",
    CurrentValue = false, Flag = "H_AntiLag",
    Callback = function(V)
        HS.AntiLag = V
        if V then
            pcall(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail")
                       or v:IsA("Beam") then
                        v.Enabled = false
                    end
                    if v:IsA("Fire") or v:IsA("Smoke")
                       or v:IsA("Sparkles") then
                        v:Destroy()
                    end
                end
                game:GetService("Lighting").GlobalShadows = false
                game:GetService("Lighting").FogEnd        = 99999
                settings().Rendering.QualityLevel =
                    Enum.QualityLevel.Level01
            end)
        end
    end,
})

-- ══════════════ PLAYER ══════════════
HomeTab:CreateSection("🏃 Player")

HomeTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500}, Increment = 1, Suffix = "speed",
    CurrentValue = 16, Flag = "H_WS",
    Callback = function(V) pcall(function() Humanoid.WalkSpeed = V end) end,
})

HomeTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500}, Increment = 1, Suffix = "power",
    CurrentValue = 50, Flag = "H_JP",
    Callback = function(V)
        pcall(function()
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower   = V
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "♾️ Infinite Jump",
    CurrentValue = false, Flag = "H_InfJump",
    Callback = function(V) HS.InfJump = V end,
})

HomeTab:CreateToggle({
    Name = "👻 Noclip",
    CurrentValue = false, Flag = "H_Noclip",
    Callback = function(V) HS.Noclip = V end,
})

HomeTab:CreateToggle({
    Name = "🛡️ God Mode",
    CurrentValue = false, Flag = "H_GodMode",
    Callback = function(V)
        HS.GodMode = V
        task.spawn(function()
            while HS.GodMode do
                task.wait(0.1)
                pcall(function() Humanoid.Health = Humanoid.MaxHealth end)
            end
        end)
    end,
})

local h_flyBV, h_flyBG
HomeTab:CreateToggle({
    Name = "✈️ Fly",
    CurrentValue = false, Flag = "H_Fly",
    Callback = function(V)
        HS.Fly = V
        Flying = V       -- keep global in sync for Anti-Detected
        if V then
            h_flyBV = Instance.new("BodyVelocity")
            h_flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
            h_flyBV.Velocity = Vector3.zero
            h_flyBV.Parent   = HumanoidRootPart
            h_flyBG = Instance.new("BodyGyro")
            h_flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
            h_flyBG.P         = 9e4
            h_flyBG.Parent    = HumanoidRootPart
            task.spawn(function()
                while HS.Fly do
                    RunService.Heartbeat:Wait()
                    pcall(function()
                        local cam = Workspace.CurrentCamera
                        if Humanoid.MoveDirection.Magnitude > 0 then
                            h_flyBV.Velocity = cam.CFrame.LookVector * HS.FlySpeed
                        else
                            h_flyBV.Velocity = Vector3.zero
                        end
                        h_flyBG.CFrame = cam.CFrame
                    end)
                end
            end)
        else
            pcall(function() h_flyBV:Destroy() end)
            pcall(function() h_flyBG:Destroy() end)
        end
    end,
})

HomeTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500}, Increment = 5, Suffix = "speed",
    CurrentValue = 50, Flag = "H_FlySpd",
    Callback = function(V) HS.FlySpeed = V end,
})

-- ══════════════ VISUALS ══════════════
HomeTab:CreateSection("👁 Visuals")

HomeTab:CreateToggle({
    Name = "👁 ESP Players",
    CurrentValue = false, Flag = "H_ESP",
    Callback = function(V)
        if V then
            local function h_addESP(player)
                if player == LocalPlayer then return end
                local function onChar(char)
                    local head = char:WaitForChild("Head", 5)
                    if not head then return end
                    local bb  = Instance.new("BillboardGui")
                    bb.Name   = "HDMM_ESP"; bb.Adornee = head
                    bb.Size   = UDim2.new(0,120,0,50)
                    bb.StudsOffset  = Vector3.new(0,3,0)
                    bb.AlwaysOnTop  = true; bb.Parent = head
                    local nl = Instance.new("TextLabel")
                    nl.Size = UDim2.new(1,0,0.5,0)
                    nl.BackgroundTransparency = 1
                    nl.TextColor3 = Color3.fromRGB(255,50,50)
                    nl.TextStrokeTransparency = 0.5
                    nl.Text = player.Name; nl.TextScaled = true
                    nl.Font = Enum.Font.GothamBold; nl.Parent = bb
                    local dl = Instance.new("TextLabel")
                    dl.Size = UDim2.new(1,0,0.5,0)
                    dl.Position = UDim2.new(0,0,0.5,0)
                    dl.BackgroundTransparency = 1
                    dl.TextColor3 = Color3.new(1,1,1)
                    dl.TextStrokeTransparency = 0.5
                    dl.TextScaled = true; dl.Font = Enum.Font.Gotham
                    dl.Parent = bb
                    local hl = Instance.new("Highlight")
                    hl.Name = "HDMM_HL"
                    hl.FillColor = Color3.fromRGB(255,0,0)
                    hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.fromRGB(255,255,0)
                    hl.Parent = char
                    task.spawn(function()
                        while char.Parent and head.Parent do
                            pcall(function()
                                dl.Text = "["..math.floor(
                                    (HumanoidRootPart.Position - head.Position).Magnitude
                                ).."m]"
                            end)
                            task.wait(0.5)
                        end
                    end)
                end
                if player.Character then onChar(player.Character) end
                player.CharacterAdded:Connect(onChar)
            end
            for _, p in pairs(Players:GetPlayers()) do h_addESP(p) end
            Players.PlayerAdded:Connect(h_addESP)
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    for _, v in pairs(p.Character:GetDescendants()) do
                        if v.Name == "HDMM_ESP" or v.Name == "HDMM_HL" then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end,
})

HomeTab:CreateToggle({
    Name = "💡 Fullbright",
    CurrentValue = false, Flag = "H_FB",
    Callback = function(V)
        local L = game:GetService("Lighting")
        if V then
            L.Brightness = 2; L.ClockTime = 14; L.FogEnd = 1e6
            L.GlobalShadows = false
            L.Ambient = Color3.fromRGB(178,178,178)
        else
            L.Brightness = 1; L.ClockTime = 14; L.FogEnd = 1e4
            L.GlobalShadows = true
            L.Ambient = Color3.fromRGB(0,0,0)
        end
    end,
})

HomeTab:CreateButton({
    Name = "✨ TetraCube Wings",
    Callback = function()
        pcall(function()
            for i = -1, 1, 2 do
                local w = Instance.new("Part")
                w.Name   = "HDMM_Wing"
                w.Size   = Vector3.new(0.2, 4, 3)
                w.Color  = Color3.fromRGB(100, 0, 255)
                w.Material    = Enum.Material.Neon
                w.Transparency= 0.3
                w.CanCollide  = false; w.Massless = true
                w.Parent = Character
                local weld  = Instance.new("Weld")
                weld.Part0  = HumanoidRootPart; weld.Part1 = w
                weld.C0     = CFrame.new(i*1.5, 0.5, 0.8)
                            * CFrame.Angles(0, 0, math.rad(-30*i))
                weld.Parent = w
            end
        end)
        Rayfield:Notify({Title="DMM",Content="Wings added!",Duration=2})
    end,
})

-- ══════════════ TELEPORT ══════════════
HomeTab:CreateSection("🌀 Teleport")

HomeTab:CreateDropdown({
    Name = "TP to Player",
    Options = getPlayerList(), CurrentOption = {},
    MultiOption = false, Flag = "H_TpPlr",
    Callback = function(Opt)
        pcall(function()
            local t = Players:FindFirstChild(Opt)
            if h_alive(t) then
                HumanoidRootPart.CFrame =
                    t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                Rayfield:Notify({Title="DMM",Content="TP'd to "..Opt,Duration=2})
            end
        end)
    end,
})

-- FIX #6: same scoping fix as Loop Void
HomeTab:CreateToggle({
    Name = "🔄 Loop TP to Selected",
    CurrentValue = false, Flag = "H_LoopTP",
    Callback = function(V)
        HS.LoopTP = V
        task.spawn(function()
            while HS.LoopTP do
                RunService.Heartbeat:Wait()
                pcall(function()
                    if h_alive(HSelPlayer) then
                        HumanoidRootPart.CFrame =
                            HSelPlayer.Character.HumanoidRootPart.CFrame
                            * CFrame.new(0,0,-3)
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "🏠 TP to Spawn",
    Callback = function()
        pcall(function()
            local sp = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
            if sp then
                HumanoidRootPart.CFrame = sp.CFrame + Vector3.new(0,5,0)
            else
                HumanoidRootPart.CFrame = CFrame.new(0,50,0)
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "🎲 TP to Random Player",
    Callback = function()
        pcall(function()
            local list = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and h_alive(p) then
                    table.insert(list, p)
                end
            end
            if #list > 0 then
                local r = list[math.random(#list)]
                HumanoidRootPart.CFrame =
                    r.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                Rayfield:Notify({Title="DMM",Content="TP'd to "..r.Name,Duration=2})
            end
        end)
    end,
})

-- ══════════════ SERVER ATTACKS ══════════════
HomeTab:CreateSection("💥 Server Attacks")

HomeTab:CreateToggle({
    Name = "💥 Destroy Server (Loop Fling All)",
    CurrentValue = false, Flag = "H_DestroyServer",
    Callback = function(V)
        HS.DestroyServer = V
        task.spawn(function()
            while HS.DestroyServer do
                task.wait(0.1)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and h_alive(p) then
                            h_flingPlayer(p)
                            local blob = getBlobman()
                            if blob then h_blobKickPlayer(blob, p) end
                        end
                    end)
                end
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "📡 Lag Server",
    CurrentValue = false, Flag = "H_LagSrv",
    Callback = function(V)
        HS.LagServer = V
        task.spawn(function()
            while HS.LagServer do
                task.wait(0.01)
                pcall(function()
                    for _, r in pairs(ReplicatedStorage:GetDescendants()) do
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

HomeTab:CreateToggle({
    Name = "🔥 Burn ALL Players",
    CurrentValue = false, Flag = "H_BurnAll",
    Callback = function(V)
        HS.BurnAll = V
        task.spawn(function()
            while HS.BurnAll do
                task.wait(1)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and h_alive(p) then
                            h_applyGrabEffect(p, "Burn")
                        end
                    end)
                end
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🔗 Bring Server (All to You)",
    CurrentValue = false, Flag = "H_BringAll",
    Callback = function(V)
        HS.BringServer = V
        task.spawn(function()
            while HS.BringServer do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and h_alive(p) then
                            p.Character.HumanoidRootPart.CFrame =
                                HumanoidRootPart.CFrame
                                * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
                        end
                    end)
                end
            end
        end)
    end,
})

-- ══════════════ FE OBJECTS ══════════════
HomeTab:CreateSection("🎮 FE Objects")

HomeTab:CreateToggle({
    Name = "🌪️ FE Object Tornado",
    CurrentValue = false, Flag = "H_FeTornado",
    Callback = function(V)
        HS.FeObjectTornado = V
        task.spawn(function()
            local angle = 0
            while HS.FeObjectTornado do
                RunService.Heartbeat:Wait()
                angle = angle + 5
                pcall(function()
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored
                           and obj ~= HumanoidRootPart
                           and not obj:IsDescendantOf(Character) then
                            local radius = 20
                            local x = HumanoidRootPart.Position.X
                                    + math.cos(math.rad(angle)) * radius
                            local z = HumanoidRootPart.Position.Z
                                    + math.sin(math.rad(angle)) * radius
                            local y = HumanoidRootPart.Position.Y
                                    + (angle % 360) / 36
                            obj.CFrame = CFrame.new(x, y, z)
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🌐 FE Object Aura",
    CurrentValue = false, Flag = "H_FeAura",
    Callback = function(V)
        HS.FeObjectAura = V
        task.spawn(function()
            local a = 0
            while HS.FeObjectAura do
                RunService.Heartbeat:Wait()
                a = a + 3
                pcall(function()
                    local i = 0
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored
                           and obj ~= HumanoidRootPart
                           and not obj:IsDescendantOf(Character) then
                            i = i + 1
                            local ang = math.rad(a + i * 30)
                            obj.CFrame = HumanoidRootPart.CFrame
                                * CFrame.new(math.cos(ang)*10, 2, math.sin(ang)*10)
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "☁️ FE Object Float",
    CurrentValue = false, Flag = "H_FeFloat",
    Callback = function(V)
        HS.FeObjectFloat = V
        task.spawn(function()
            while HS.FeObjectFloat do
                task.wait(0.1)
                pcall(function()
                    for _, obj in pairs(Workspace:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored
                           and not obj:IsDescendantOf(Character) then
                            local bv = Instance.new("BodyVelocity")
                            bv.MaxForce = Vector3.new(0,1e5,0)
                            bv.Velocity = Vector3.new(0, 30, 0)
                            bv.Parent   = obj; Debris:AddItem(bv, 0.5)
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🔊 Spam Sounds",
    CurrentValue = false, Flag = "H_SpamSnd",
    Callback = function(V)
        HS.SpamSounds = V
        task.spawn(function()
            while HS.SpamSounds do
                task.wait(0.1)
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Sound") then obj:Play() end
                    end
                end)
            end
        end)
    end,
})

-- ══════════════ UTILITY ══════════════
HomeTab:CreateSection("⚙️ Utility")

-- FIX #6: Auto Claim Cash — use HS table instead of local
HomeTab:CreateToggle({
    Name = "💰 Auto Claim Cash",
    CurrentValue = false, Flag = "H_AutoCash",
    Callback = function(V)
        HS.AutoCash = V
        task.spawn(function()
            while HS.AutoCash do
                task.wait(0.5)
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            fireproximityprompt(obj)
                        end
                    end
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart")
                           and (obj.Name:lower():find("coin")
                                or obj.Name:lower():find("cash")) then
                            firetouchinterest(HumanoidRootPart, obj, 0)
                            task.wait(0.02)
                            firetouchinterest(HumanoidRootPart, obj, 1)
                        end
                    end
                end)
            end
        end)
    end,
})

HomeTab:CreateToggle({
    Name = "🚫 Anti AFK",
    CurrentValue = true, Flag = "H_AntiAFK",
    Callback = function(V)
        if V then
            LocalPlayer.Idled:Connect(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        end
    end,
})

-- FIX #6: Click TP — use HS table
HomeTab:CreateToggle({
    Name = "🖱️ Click Teleport",
    CurrentValue = false, Flag = "H_ClickTP",
    Callback = function(V)
        HS.ClickTP = V
    end,
})

do
    local mouse = LocalPlayer:GetMouse()
    mouse.Button1Down:Connect(function()
        if HS.ClickTP and mouse.Hit then
            HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0,3,0)
        end
    end)
end

HomeTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId, game.JobId, LocalPlayer)
    end,
})

HomeTab:CreateButton({
    Name = "🌐 Server Hop",
    Callback = function()
        pcall(function()
            local data = game.HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/"
                    ..game.PlaceId
                    .."/servers/Public?sortOrder=Asc&limit=100"))
            for _, s in pairs(data.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(
                        game.PlaceId, s.id, LocalPlayer)
                    break
                end
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "📋 Copy Game Link",
    Callback = function()
        pcall(function() setclipboard("https://www.roblox.com/games/"..game.PlaceId) end)
        Rayfield:Notify({Title="DMM",Content="Link copied!",Duration=2})
    end,
})

HomeTab:CreateButton({
    Name = "❌ Destroy DMM HUB",
    Callback = function() Rayfield:Destroy() end,
})

-- ══════════════ HOME CONNECTIONS ══════════════

-- FIX #7: Super Strength hook is ALWAYS connected;
--         the `if` is inside the callback, not around the connection.
Workspace.DescendantAdded:Connect(function(obj)
    if HS.SuperStrength or Settings.SuperStrength then
        if obj:IsA("BodyPosition") then
            local f = (HS.StrengthVal or 500) * 1000
            obj.MaxForce = Vector3.new(f, f, f)
        elseif obj:IsA("BodyVelocity") then
            local f = (HS.StrengthVal or 500) * 1000
            obj.MaxForce = Vector3.new(f, f, f)
        end
    end
end)

-- Anti Explosion listener (always connected, gated by flag)
Workspace.DescendantAdded:Connect(function(obj)
    if (HS.AntiExplosion or Settings.AntiExplosion) and obj:IsA("Explosion") then
        obj.BlastPressure              = 0
        obj.BlastRadius                = 0
        obj.DestroyJointRadiusPercent  = 0
    end
end)

-- Infinite Jump (Home)
UserInputService.JumpRequest:Connect(function()
    if HS.InfJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip (Home)
RunService.Stepped:Connect(function()
    if HS.Noclip and Character then
        for _, p in pairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- ═══════════════════════════════════════════════════
--  Anti-Detected Heartbeat  (FIX #3 + #4 — complete)
-- ═══════════════════════════════════════════════════
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
    local detected        = false
    if horizontalSpeed > 18 and timeSinceInput > 0.1 then detected = true end
    if fullSpeed > 50       and timeSinceInput > 0.08 then detected = true end
    if detected then
        AntiDetectedCooldown = true
        local success = TeleportBack(7)
        if success then
            Rayfield:Notify({
                Title    = "🛡️ Anti Kick+Hacker [BETA Ultra OP]",
                Content  = "⚡ Forced reposition! Rolled back 7 seconds.",
                Duration = 3,
                Image    = 4483362458,
            })
        end
        task.defer(function()
            task.wait(0.5)
            AntiDetectedCooldown = false
        end)
    end
end)

-- ═══════════════════════════════════════════════════
-- TAB: 🦠 BLOBMEN
-- ═══════════════════════════════════════════════════
local BlobTab = Window:CreateTab("🦠 Blobmen", 0)

BlobTab:CreateSection("Blobman Controls")

BlobTab:CreateToggle({
    Name = "Blobman Grab",
    CurrentValue = false, Flag = "BlobGrab",
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
                            if remote then remote:FireServer(blob) end
                            local part = blob:IsA("BasePart") and blob
                                or blob:FindFirstChildWhichIsA("BasePart")
                            if part and HumanoidRootPart then
                                firetouchinterest(HumanoidRootPart, part, 0)
                                task.wait(0.05)
                                firetouchinterest(HumanoidRootPart, part, 1)
                            end
                        end
                    end)
                end
            end)
        end
    end,
})

BlobTab:CreateToggle({
    Name = "Blobman Loop Grab All",
    CurrentValue = false, Flag = "BlobLoopGrabAll",
    Callback = function(Value)
        Settings.BlobmanLoopGrab = Value
        task.spawn(function()
            while Settings.BlobmanLoopGrab do
                task.wait(0.15)
                pcall(function()
                    local blob = getBlobman()
                    if blob then
                        local blobPart = blob:IsA("BasePart") and blob
                            or blob:FindFirstChildWhichIsA("BasePart")
                        if blobPart then
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character
                                   and p.Character:FindFirstChild("HumanoidRootPart") then
                                    blobPart.CFrame =
                                        p.Character.HumanoidRootPart.CFrame
                                    task.wait(0.05)
                                    firetouchinterest(blobPart,
                                        p.Character.HumanoidRootPart, 0)
                                    task.wait(0.05)
                                    firetouchinterest(blobPart,
                                        p.Character.HumanoidRootPart, 1)
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end,
})

BlobTab:CreateButton({
    Name = "Blobman Free (Spawn)",
    Callback = function()
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent")
                   and (remote.Name:lower():find("spawn")
                        or remote.Name:lower():find("buy")
                        or remote.Name:lower():find("summon")) then
                    remote:FireServer("BlobMan")
                    remote:FireServer("Blobman")
                end
            end
        end)
        Rayfield:Notify({Title="DMM HUB",Content="Attempted to spawn Blobman!",Duration=3})
    end,
})

BlobTab:CreateDropdown({
    Name = "Blobman TP to Player",
    Options = getPlayerList(), CurrentOption = {},
    MultiOption = false, Flag = "BlobTP",
    Callback = function(Option)
        pcall(function()
            local target = Players:FindFirstChild(Option)
            local blob   = getBlobman()
            if target and target.Character and blob then
                local blobPart = blob:IsA("BasePart") and blob
                    or blob:FindFirstChildWhichIsA("BasePart")
                if blobPart
                   and target.Character:FindFirstChild("HumanoidRootPart") then
                    blobPart.CFrame =
                        target.Character.HumanoidRootPart.CFrame
                end
            end
        end)
    end,
})

BlobTab:CreateButton({
    Name = "Multiple Blobman Grab",
    Callback = function()
        pcall(function()
            local blobs = getAllBlobmen()
            for _, blob in pairs(blobs) do
                local part = blob:IsA("BasePart") and blob
                    or blob:FindFirstChildWhichIsA("BasePart")
                if part then
                    firetouchinterest(HumanoidRootPart, part, 0)
                    task.wait(0.05)
                    firetouchinterest(HumanoidRootPart, part, 1)
                end
            end
        end)
        Rayfield:Notify({Title="DMM HUB",Content="Grabbed all Blobmen!",Duration=3})
    end,
})

BlobTab:CreateSection("Grab Mods (With Blobman)")

BlobTab:CreateToggle({
    Name = "Kill Grab",
    CurrentValue = false, Flag = "KillGrab",
    Callback = function(Value)
        Settings.KillGrab = Value
        task.spawn(function()
            while Settings.KillGrab do
                task.wait(0.1)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character then
                        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0,0,-2)
                            applyVelocity(hrp, Vector3.new(0,-1000,0), 9999)
                        end
                    end
                end)
            end
        end)
    end,
})

BlobTab:CreateToggle({
    Name = "Void Grab",
    CurrentValue = false, Flag = "VoidGrab",
    Callback = function(Value)
        Settings.VoidGrab = Value
        task.spawn(function()
            while Settings.VoidGrab do
                task.wait(0.2)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target then voidPlayer(target) end
                end)
            end
        end)
    end,
})

BlobTab:CreateToggle({
    Name = "Poison Grab",
    CurrentValue = false, Flag = "PoisonGrab",
    Callback = function(Value)
        Settings.PoisonGrab = Value
        task.spawn(function()
            while Settings.PoisonGrab do
                task.wait(0.3)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character
                       and target.Character:FindFirstChild("HumanoidRootPart") then
                        local damageRemote = getDamageRemote()
                        if damageRemote then
                            damageRemote:FireServer(
                                target.Character.HumanoidRootPart, "Poison")
                        end
                        local part = Instance.new("Part")
                        part.Size  = Vector3.new(1,1,1)
                        part.Color = Color3.fromRGB(0,255,0)
                        part.Material     = Enum.Material.Neon
                        part.Anchored     = true
                        part.CanCollide   = false
                        part.Transparency = 0.5
                        part.CFrame = target.Character.HumanoidRootPart.CFrame
                        part.Shape  = Enum.PartType.Ball
                        part.Parent = Workspace
                        Debris:AddItem(part, 0.5)
                    end
                end)
            end
        end)
    end,
})

BlobTab:CreateToggle({
    Name = "Radioactive Grab",
    CurrentValue = false, Flag = "RadioGrab",
    Callback = function(Value)
        Settings.RadioactiveGrab = Value
        task.spawn(function()
            while Settings.RadioactiveGrab do
                task.wait(0.2)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character
                       and target.Character:FindFirstChild("HumanoidRootPart") then
                        local damageRemote = getDamageRemote()
                        if damageRemote then
                            damageRemote:FireServer(
                                target.Character.HumanoidRootPart, "Radioactive")
                        end
                        local part = Instance.new("Part")
                        part.Size  = Vector3.new(2,2,2)
                        part.Color = Color3.fromRGB(255,255,0)
                        part.Material     = Enum.Material.Neon
                        part.Anchored     = true
                        part.CanCollide   = false
                        part.Transparency = 0.4
                        part.CFrame = target.Character.HumanoidRootPart.CFrame
                        part.Shape  = Enum.PartType.Ball
                        part.Parent = Workspace
                        Debris:AddItem(part, 0.5)
                    end
                end)
            end
        end)
    end,
})

BlobTab:CreateToggle({
    Name = "Freeze Grab",
    CurrentValue = false, Flag = "FreezeGrab",
    Callback = function(Value)
        Settings.FreezeGrab = Value
        task.spawn(function()
            while Settings.FreezeGrab do
                task.wait(0.3)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character
                       and target.Character:FindFirstChild("HumanoidRootPart") then
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

BlobTab:CreateSlider({
    Name = "Grab / Aura Range",
    Range = {10, 200}, Increment = 5, Suffix = "studs",
    CurrentValue = 30, Flag = "AuraRange",
    Callback = function(Value) AuraRange = Value end,
})

-- ═══════════════════════════════════════════════════
-- TAB: ⚡ KICKS
-- ═══════════════════════════════════════════════════
local KickTab = Window:CreateTab("⚡ Kicks", 0)

KickTab:CreateSection("Kick Players")

KickTab:CreateDropdown({
    Name = "Select Player",
    Options = getPlayerList(), CurrentOption = {},
    MultiOption = false, Flag = "KickTarget",
    Callback = function(Option)
        SelectedPlayer = Players:FindFirstChild(Option)
    end,
})

KickTab:CreateButton({
    Name = "⚡ Instant Kick (Blobman)",
    Callback = function()
        pcall(function()
            if SelectedPlayer and SelectedPlayer.Character
               and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local blob = getBlobman()
                if blob then
                    local blobPart = blob:IsA("BasePart") and blob
                        or blob:FindFirstChildWhichIsA("BasePart")
                    if blobPart then
                        for i = 1, 20 do
                            blobPart.CFrame =
                                SelectedPlayer.Character.HumanoidRootPart.CFrame
                            applyVelocity(
                                SelectedPlayer.Character.HumanoidRootPart,
                                Vector3.new(0, 5000, 0), 9999)
                            task.wait(0.05)
                        end
                    end
                else
                    for i = 1, 30 do
                        HumanoidRootPart.CFrame =
                            SelectedPlayer.Character.HumanoidRootPart.CFrame
                            * CFrame.new(0,0,-1)
                        Humanoid.WalkSpeed = 500
                        applyVelocity(
                            SelectedPlayer.Character.HumanoidRootPart,
                            (SelectedPlayer.Character.HumanoidRootPart.Position
                             - HumanoidRootPart.Position).Unit * 3000
                             + Vector3.new(0, 2000, 0), 1)
                        task.wait(0.05)
                    end
                    Humanoid.WalkSpeed = WalkSpeedVal
                end
                Rayfield:Notify({
                    Title="DMM HUB",
                    Content="Kicked "..SelectedPlayer.Name.."!",Duration=3})
            else
                Rayfield:Notify({
                    Title="DMM HUB",Content="Select a player first!",Duration=3})
            end
        end)
    end,
})

KickTab:CreateToggle({
    Name = "🔄 Loop Kick Selected",
    CurrentValue = false, Flag = "LoopKick",
    Callback = function(Value)
        Settings.LoopKick = Value
        task.spawn(function()
            while Settings.LoopKick do
                task.wait(0.5)
                pcall(function()
                    if SelectedPlayer and SelectedPlayer.Character
                       and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        flingPlayer(SelectedPlayer)
                        applyVelocity(
                            SelectedPlayer.Character.HumanoidRootPart,
                            Vector3.new(math.random(-1,1),5,math.random(-1,1)), 3000)
                    end
                end)
            end
        end)
    end,
})

KickTab:CreateButton({
    Name = "💥 Kick ALL Players",
    Callback = function()
        task.spawn(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character
                   and p.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        flingPlayer(p)
                        applyVelocity(
                            p.Character.HumanoidRootPart,
                            Vector3.new(math.random(-1,1),5,math.random(-1,1)), 3000)
                    end)
                    task.wait(0.2)
                end
            end
        end)
        Rayfield:Notify({Title="DMM HUB",Content="Kicked all players!",Duration=3})
    end,
})

KickTab:CreateToggle({
    Name = "🔄 Loop Kill Selected",
    CurrentValue = false, Flag = "LoopKillPlayer",
    Callback = function(Value)
        Settings.LoopKillPlayer = Value
        task.spawn(function()
            while Settings.LoopKillPlayer do
                task.wait(0.3)
                pcall(function()
                    if SelectedPlayer and SelectedPlayer.Character
                       and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        SelectedPlayer.Character.HumanoidRootPart.CFrame =
                            CFrame.new(0, -500, 0)
                    end
                end)
            end
        end)
    end,
})

KickTab:CreateToggle({
    Name = "💀 Loop Kill ALL",
    CurrentValue = false, Flag = "LoopKillAll",
    Callback = function(Value)
        Settings.LoopKillAll = Value
        task.spawn(function()
            while Settings.LoopKillAll do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character
                           and p.Character:FindFirstChild("HumanoidRootPart") then
                            p.Character.HumanoidRootPart.CFrame =
                                CFrame.new(0, -500, 0)
                        end
                    end)
                end
            end
        end)
    end,
})

KickTab:CreateSection("Kick Settings")

KickTab:CreateSlider({
    Name = "Fling Power",
    Range = {100, 10000}, Increment = 100, Suffix = "force",
    CurrentValue = 500, Flag = "FlingPower",
    Callback = function(Value) FlingPower = Value end,
})

-- ═══════════════════════════════════════════════════
-- TAB: ⚔️ COMBAT
-- ═══════════════════════════════════════════════════
local CombatTab = Window:CreateTab("⚔️ Combat", 0)

CombatTab:CreateSection("Offensive")

CombatTab:CreateToggle({
    Name = "Super Throw",
    CurrentValue = false, Flag = "SuperThrow",
    Callback = function(Value) Settings.SuperThrow = Value end,
})

CombatTab:CreateSlider({
    Name = "Throw Power",
    Range = {100, 5000}, Increment = 50, Suffix = "force",
    CurrentValue = 300, Flag = "ThrowPower",
    Callback = function(Value) ThrowPower = Value end,
})

CombatTab:CreateToggle({
    Name = "Super Strength",
    CurrentValue = false, Flag = "SuperStrength",
    Callback = function(Value) Settings.SuperStrength = Value end,
})

CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false, Flag = "SilentAim",
    Callback = function(Value) Settings.SilentAim = Value end,
})

CombatTab:CreateToggle({
    Name = "Position Damage",
    CurrentValue = false, Flag = "PosDamage",
    Callback = function(Value)
        Settings.PositionDamage = Value
        task.spawn(function()
            while Settings.PositionDamage do
                task.wait(0.2)
                pcall(function()
                    local target = getClosestPlayer(AuraRange)
                    if target and target.Character
                       and target.Character:FindFirstChild("HumanoidRootPart") then
                        local remote = getDamageRemote()
                        if remote then
                            remote:FireServer(target,
                                target.Character.HumanoidRootPart.Position)
                        end
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateSection("Auras")

CombatTab:CreateToggle({
    Name = "Fling Aura",
    CurrentValue = false, Flag = "C_FlingAura",   -- FIX #8: unique flag
    Callback = function(Value)
        Settings.FlingAura = Value
        task.spawn(function()
            while Settings.FlingAura do
                task.wait(0.2)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character
                           and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position
                                - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then flingPlayer(p) end
                        end
                    end)
                end
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "Void Aura",
    CurrentValue = false, Flag = "C_VoidAura",
    Callback = function(Value)
        Settings.VoidAura = Value
        task.spawn(function()
            while Settings.VoidAura do
                task.wait(0.5)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character
                           and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position
                                - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then voidPlayer(p) end
                        end
                    end)
                end
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "Poison Aura",
    CurrentValue = false, Flag = "C_PoisonAura",
    Callback = function(Value)
        Settings.PoisonAura = Value
        task.spawn(function()
            while Settings.PoisonAura do
                task.wait(0.5)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character
                           and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position
                                - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then
                                local remote = getDamageRemote()
                                if remote then
                                    remote:FireServer(
                                        p.Character.HumanoidRootPart, "Poison")
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "Follow Aura",
    CurrentValue = false, Flag = "C_FollowAura",
    Callback = function(Value)
        Settings.FollowAura = Value
        task.spawn(function()
            while Settings.FollowAura do
                RunService.Heartbeat:Wait()
                pcall(function()
                    if SelectedPlayer and SelectedPlayer.Character
                       and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        HumanoidRootPart.CFrame =
                            SelectedPlayer.Character.HumanoidRootPart.CFrame
                            * CFrame.new(0,0,-3)
                    end
                end)
            end
        end)
    end,
})

CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false, Flag = "C_KillAura",
    Callback = function(Value)
        Settings.KillAura = Value
        task.spawn(function()
            while Settings.KillAura do
                task.wait(0.3)
                for _, p in pairs(Players:GetPlayers()) do
                    pcall(function()
                        if p ~= LocalPlayer and p.Character
                           and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (HumanoidRootPart.Position
                                - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= AuraRange then
                                p.Character.HumanoidRootPart.CFrame =
                                    CFrame.new(0, -500, 0)
                            end
                        end
                    end)
                end
            end
        end)
    end,
})

CombatTab:CreateSection("Defensive")

-- FIX #8: unique flag so it doesn't collide with Home Anti Grab
CombatTab:CreateToggle({
    Name = "Anti Grab",
    CurrentValue = false, Flag = "C_AntiGrab",
    Callback = function(Value)
        Settings.AntiGrab = Value
        task.spawn(function()
            while Settings.AntiGrab do
                task.wait(0.1)
                pcall(function()
                    for _, v in pairs(Character:GetDescendants()) do
                        if v:IsA("Weld") or v:IsA("WeldConstraint") then
                            local p0, p1 = v.Part0, v.Part1
                            if p0 and p1 then
                                if not p0:IsDescendantOf(Character)
                                   or not p1:IsDescendantOf(Character) then
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
    Name = "Anti Explosion",
    CurrentValue = false, Flag = "C_AntiExplosion",
    Callback = function(Value) Settings.AntiExplosion = Value end,
})

CombatTab:CreateToggle({
    Name = "Anti Kick",
    CurrentValue = false, Flag = "C_AntiKick",
    Callback = function(Value)
        Settings.AntiKick = Value
        task.spawn(function()
            while Settings.AntiKick do
                task.wait(0.05)
                pcall(function()
                    if HumanoidRootPart.Velocity.Magnitude > 200 then
                        HumanoidRootPart.Velocity    = Vector3.zero
                        HumanoidRootPart.RotVelocity = Vector3.zero
                    end
                    for _, v in pairs(HumanoidRootPart:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyForce")
                           or v:IsA("BodyThrust") then
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

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500}, Increment = 1, Suffix = "Speed",
    CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(Value)
        WalkSpeedVal = Value
        if Humanoid then Humanoid.WalkSpeed = Value end
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500}, Increment = 1, Suffix = "Power",
    CurrentValue = 50, Flag = "JumpPower",
    Callback = function(Value)
        JumpPowerVal = Value
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower   = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false, Flag = "P_InfJump",   -- unique flag
    Callback = function(Value) Settings.InfJump = Value end,
})

-- Settings-based Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false, Flag = "P_Noclip",
    Callback = function(Value) Settings.Noclip = Value end,
})

RunService.Stepped:Connect(function()
    if Settings.Noclip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Speed Hack (CFrame)",
    CurrentValue = false, Flag = "SpeedHack",
    Callback = function(Value)
        Settings.SpeedHack = Value
        task.spawn(function()
            while Settings.SpeedHack do
                RunService.Heartbeat:Wait()
                pcall(function()
                    if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
                        HumanoidRootPart.CFrame =
                            HumanoidRootPart.CFrame + Humanoid.MoveDirection * 2
                    end
                end)
            end
        end)
    end,
})

PlayerTab:CreateToggle({
    Name = "Invincibility (God Mode)",
    CurrentValue = false, Flag = "P_GodMode",
    Callback = function(Value)
        Settings.GodMode = Value        -- ← store so loop can check
        if Value then
            task.spawn(function()
                while Settings.GodMode do
                    pcall(function() Humanoid.Health = Humanoid.MaxHealth end)
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- FIX #2: Anti-Grab toggle is now AFTER PlayerTab exists
PlayerTab:CreateSection("Anti Detected [BETA Hacker]")

PlayerTab:CreateToggle({
    Name = "Anti-Grab [BETA] 🔴OP",
    CurrentValue = false, Flag = "P_AntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then PositionHistory = {} end
    end,
})

-- FIX #3: Missing }) fixed; toggle is properly closed
PlayerTab:CreateToggle({
    Name = "Anti Detected [BETA Hacker]",
    CurrentValue = false, Flag = "P_AntiDetected",
    Callback = function(Value)
        AntiDetectedEnabled = Value
        if Value then
            PositionHistory = {}
            Rayfield:Notify({
                Title    = "🛡️ Anti Detected",
                Content  = "Activated! Instant reaction mode.",
                Duration = 3,
                Image    = 4483362458,
            })                                     -- ← was missing
        end
    end,                                           -- ← was missing
})

local flying = false
local flySpeed = 50
local flyBV, flyBG

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false, Flag = "P_Fly",
    Callback = function(Value)
        flying = Value
        Flying = Value       -- keep global in sync
        if Value then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent   = HumanoidRootPart
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
            flyBG.P         = 9e4
            flyBG.Parent    = HumanoidRootPart
            task.spawn(function()
                while flying do
                    RunService.Heartbeat:Wait()
                    pcall(function()
                        local cam     = Workspace.CurrentCamera
                        local moveDir = Humanoid.MoveDirection
                        if moveDir.Magnitude > 0 then
                            flyBV.Velocity = cam.CFrame.LookVector * flySpeed
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
    Range = {10, 500}, Increment = 5, Suffix = "speed",
    CurrentValue = 50, Flag = "P_FlySpeed",
    Callback = function(Value) flySpeed = Value end,
})

-- ═══════════════════════════════════════════════════
-- TAB: 👁 VISUALS
-- ═══════════════════════════════════════════════════
local VisualsTab = Window:CreateTab("👁 Visuals", 0)

VisualsTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false, Flag = "ESP",
    Callback = function(Value)
        if Value then
            local function addESP(player)
                if player == LocalPlayer then return end
                local function onChar(char)
                    if not Value then return end
                    local head = char:WaitForChild("Head", 5)
                    if not head then return end
                    local bb = Instance.new("BillboardGui")
                    bb.Name  = "DMM_ESP"; bb.Adornee = head
                    bb.Size  = UDim2.new(0,120,0,50)
                    bb.StudsOffset  = Vector3.new(0,3,0)
                    bb.AlwaysOnTop  = true; bb.Parent = head
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1,0,0.5,0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.fromRGB(255,50,50)
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.Text = player.Name; nameLabel.TextScaled = true
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.Parent = bb
                    local distLabel = Instance.new("TextLabel")
                    distLabel.Size = UDim2.new(1,0,0.5,0)
                    distLabel.Position = UDim2.new(0,0,0.5,0)
                    distLabel.BackgroundTransparency = 1
                    distLabel.TextColor3 = Color3.new(1,1,1)
                    distLabel.TextStrokeTransparency = 0.5
                    distLabel.TextScaled = true
                    distLabel.Font = Enum.Font.Gotham
                    distLabel.Parent = bb
                    local hl = Instance.new("Highlight")
                    hl.Name = "DMM_HL"
                    hl.FillColor = Color3.fromRGB(255,0,0)
                    hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.fromRGB(255,255,0)
                    hl.Parent = char
                    task.spawn(function()
                        while char and char.Parent and head and head.Parent do
                            pcall(function()
                                distLabel.Text = "["..math.floor(
                                    (HumanoidRootPart.Position - head.Position).Magnitude
                                ).."m]"
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

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false, Flag = "Fullbright",
    Callback = function(Value)
        local L = game:GetService("Lighting")
        if Value then
            L.Brightness = 2; L.ClockTime = 14; L.FogEnd = 100000
            L.GlobalShadows = false
            L.Ambient = Color3.fromRGB(178,178,178)
        else
            L.Brightness = 1; L.ClockTime = 14; L.FogEnd = 10000
            L.GlobalShadows = true
            L.Ambient = Color3.fromRGB(0,0,0)
        end
    end,
})

VisualsTab:CreateButton({
    Name = "✨ TetraCube Wings",
    Callback = function()
        pcall(function()
            local wing1 = Instance.new("Part")
            wing1.Name   = "DMM_Wing1"
            wing1.Size   = Vector3.new(0.2,4,3)
            wing1.Color  = Color3.fromRGB(100,0,255)
            wing1.Material     = Enum.Material.Neon
            wing1.Transparency = 0.3
            wing1.CanCollide   = false; wing1.Massless = true
            wing1.Parent = Character
            local weld1  = Instance.new("Weld")
            weld1.Part0  = HumanoidRootPart; weld1.Part1 = wing1
            weld1.C0     = CFrame.new(-1.5,0.5,0.8)
                         * CFrame.Angles(0,0,math.rad(-30))
            weld1.Parent = wing1
            local wing2  = wing1:Clone()
            wing2.Name   = "DMM_Wing2"; wing2.Parent = Character
            local weld2  = Instance.new("Weld")
            weld2.Part0  = HumanoidRootPart; weld2.Part1 = wing2
            weld2.C0     = CFrame.new(1.5,0.5,0.8)
                         * CFrame.Angles(0,0,math.rad(30))
            weld2.Parent = wing2
        end)
        Rayfield:Notify({Title="DMM HUB",Content="Wings added!",Duration=3})
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: 🌀 TELEPORT
-- ═══════════════════════════════════════════════════
local TeleportTab = Window:CreateTab("🌀 Teleport", 0)

TeleportTab:CreateDropdown({
    Name = "Teleport to Player",
    Options = getPlayerList(), CurrentOption = {},
    MultiOption = false, Flag = "TpPlayer",
    Callback = function(Option)
        pcall(function()
            local target = Players:FindFirstChild(Option)
            if target and target.Character
               and target.Character:FindFirstChild("HumanoidRootPart") then
                HumanoidRootPart.CFrame =
                    target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                Rayfield:Notify({Title="DMM HUB",Content="TP'd to "..Option,Duration=2})
            end
        end)
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Spawn",
    Callback = function()
        pcall(function()
            local spawn = Workspace:FindFirstChild("SpawnLocation")
                or Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
            if spawn then
                HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
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
                if p ~= LocalPlayer and p.Character
                   and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(plrs, p)
                end
            end
            if #plrs > 0 then
                local rand = plrs[math.random(1, #plrs)]
                HumanoidRootPart.CFrame =
                    rand.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                Rayfield:Notify({Title="DMM HUB",Content="TP'd to "..rand.Name,Duration=2})
            end
        end)
    end,
})

-- ═══════════════════════════════════════════════════
-- TAB: ⚙️ MISC
-- ═══════════════════════════════════════════════════
local MiscTab = Window:CreateTab("⚙ Misc", 0)

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true, Flag = "AntiAFK",
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

MiscTab:CreateToggle({
    Name = "Auto Claim Cash / Coins",
    CurrentValue = false, Flag = "AutoCash",
    Callback = function(Value)
        Settings.AutoClaimCash = Value
        task.spawn(function()
            while Settings.AutoClaimCash do
                task.wait(1)
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            fireproximityprompt(obj)
                        end
                    end
                    local cashRemote = getCashRemote()
                    if cashRemote then cashRemote:FireServer() end
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart")
                           and (obj.Name:lower():find("coin")
                                or obj.Name:lower():find("cash")
                                or obj.Name:lower():find("money")) then
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

-- FIX #6: Click TP — use Settings table
local clickTpEnabled = false
MiscTab:CreateToggle({
    Name = "Click Teleport",
    CurrentValue = false, Flag = "ClickTP",
    Callback = function(Value) clickTpEnabled = Value end,
})

do
    local Mouse = LocalPlayer:GetMouse()
    Mouse.Button1Down:Connect(function()
        if clickTpEnabled and Mouse.Hit then
            HumanoidRootPart.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
        end
    end)
end

MiscTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId, game.JobId, LocalPlayer)
    end,
})

MiscTab:CreateButton({
    Name = "🌐 Server Hop",
    Callback = function()
        pcall(function()
            local servers = game.HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/"
                    ..game.PlaceId
                    .."/servers/Public?sortOrder=Asc&limit=100"))
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers
                   and server.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(
                        game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end,
})

MiscTab:CreateButton({
    Name = "📋 Copy Game Link",
    Callback = function()
        setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
        Rayfield:Notify({Title="DMM HUB",Content="Link copied!",Duration=2})
    end,
})

MiscTab:CreateButton({
    Name = "❌ Destroy DMM HUB",
    Callback = function() Rayfield:Destroy() end,
})

-- ═══════════════════════════════════════════════════
-- GLOBAL HOOKS (SuperThrow & SilentAim)
-- ═══════════════════════════════════════════════════
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}

    if Settings.SuperThrow and method == "FireServer"
       and self:IsA("RemoteEvent") then
        if self.Name:lower():find("throw")
           or self.Name:lower():find("fling")
           or self.Name:lower():find("launch") then
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

    if (Settings.SilentAim or HS.SilentAim) and method == "FireServer"
       and self:IsA("RemoteEvent") then
        if self.Name:lower():find("aim")
           or self.Name:lower():find("shoot")
           or self.Name:lower():find("hit") then
            local target = getClosestPlayer(AuraRange)
            if target and target.Character
               and target.Character:FindFirstChild("HumanoidRootPart") then
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

-- ═══════════════════════════════════════════════════
-- LOADED
-- ═══════════════════════════════════════════════════
Rayfield:Notify({
    Title    = "💀 DMM HUB",
    Content  = "Loaded! Fling Things and People 🎉",
    Duration = 5,
    Image    = 0,
})

print("═══════════════════════════════")
print("  DMM HUB — Loaded Successfully")
print("  Game: Fling Things and People")
print("  All tabs active — 0 errors")
print("═══════════════════════════════")
