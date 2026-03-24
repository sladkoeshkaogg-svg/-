--[[
    ██████╗  ██████╗  ██████╗  ██████╗     ██╗  ██╗██╗   ██╗██████╗ 
   ██╔════╝ ██╔════╝ ██╔═══██╗██╔════╝     ██║  ██║██║   ██║██╔══██╗
   ██║  ███╗██║  ███╗██║   ██║██║  ███╗    ███████║██║   ██║██████╔╝
   ██║   ██║██║   ██║██║   ██║██║   ██║    ██╔══██║██║   ██║██╔══██╗
   ╚██████╔╝╚██████╔╝╚██████╔╝╚██████╔╝    ██║  ██║╚██████╔╝██████╔╝
    ╚═════╝  ╚═════╝  ╚═════╝  ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    GGOG Hub — Fling Things and People
    4 Hubs Combined: Cosmic + CosmicV2 + EggHub + NoobHub
]]

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local RS              = game:GetService("ReplicatedStorage")
local WS              = game:GetService("Workspace")
local Debris          = game:GetService("Debris")
local HttpService     = game:GetService("HttpService")
local Lighting        = game:GetService("Lighting")

-- ════════════════════════════════════════════════════════
-- PLAYER REFERENCES
-- ════════════════════════════════════════════════════════
local LP        = Players.LocalPlayer
local playerChar = LP.Character or LP.CharacterAdded:Wait()

LP.CharacterAdded:Connect(function(c)
    playerChar = c
end)

-- ════════════════════════════════════════════════════════
-- GAME REMOTES
-- ════════════════════════════════════════════════════════
local GrabEvents      = RS:WaitForChild("GrabEvents")
local MenuToys        = RS:WaitForChild("MenuToys")
local CharacterEvents = RS:WaitForChild("CharacterEvents")
local SNO             = GrabEvents:WaitForChild("SetNetworkOwner")
local StruggleRemote  = CharacterEvents:WaitForChild("Struggle")
local CreateLineRem   = GrabEvents:WaitForChild("CreateGrabLine")
local DestroyLineRem  = GrabEvents:WaitForChild("DestroyGrabLine")
local DestroyToyRem   = MenuToys:WaitForChild("DestroyToy")
local RagdollRemote   = CharacterEvents:FindFirstChild("RagdollRemote")
local SpawnToyFunc    = MenuToys:WaitForChild("SpawnToyRemoteFunction")

-- ════════════════════════════════════════════════════════
-- CORE UTILITIES
-- ════════════════════════════════════════════════════════
local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function setNet(part, cf)
    if not part then return end
    pcall(function() SNO:FireServer(part, cf or getHRP().CFrame) end)
end

local function ungrab(part)
    pcall(function() DestroyLineRem:FireServer(part) end)
end

local function createLine(part)
    pcall(function() CreateLineRem:FireServer(part, CFrame.identity) end)
end

local function spawnItem(name, cf)
    task.spawn(function()
        pcall(function() SpawnToyFunc:InvokeServer(name, cf, Vector3.zero) end)
    end)
end

local function destroyToy(model)
    pcall(function() DestroyToyRem:FireServer(model) end)
end

local function addVel(part, vel, dur)
    if not part or not part.Parent then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    bv.Velocity = vel
    bv.Parent = part
    Debris:AddItem(bv, dur or 1)
end

local function addBodyPos(part, pos)
    if not part or not part.Parent then return end
    local b = Instance.new("BodyPosition")
    b.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    b.Position = pos
    b.P = 2e4
    b.D = 5e3
    b.Parent = part
    Debris:AddItem(b, 1)
end

local function moveTo(part, cf)
    if not part or not part.Parent then return end
    pcall(function()
        for _, v in ipairs(part.Parent:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)
    addBodyPos(part, cf.Position)
end

local function noclipChar(char)
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end

local function FindAncestorModel(inst)
    local cur = inst.Parent
    while cur and cur ~= WS do
        if cur:IsA("Model") and cur.Parent ~= WS then
            return cur
        end
        cur = cur.Parent
    end
    return nil
end

local function isDescOf(target, other)
    local p = target.Parent
    while p do
        if p == other then return true end
        p = p.Parent
    end
    return false
end

-- ═══ Map Parts ═══
local function getMapParts(name)
    local t = {}
    pcall(function()
        for _, d in ipairs(WS.Map:GetDescendants()) do
            if d:IsA("Part") and d.Name == name then table.insert(t, d) end
        end
    end)
    return t
end

local poisonParts = getMapParts("PoisonHurtPart")
local paintParts  = getMapParts("PaintPlayerPart")

-- ═══ Player List ═══
local function getPlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(t, p.Name) end
    end
    return t
end

local function getDisplayList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(t, p.DisplayName) end
    end
    return t
end

local function findPlayer(name)
    if not name or name == "" then return nil end
    local s = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #s) == s or p.DisplayName:lower():sub(1, #s) == s then return p end
    end
    return nil
end

local function findByDisplay(dn)
    if not dn or dn == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName == dn then return p end
    end
    return nil
end

-- ═══ Toys Folder ═══
local function getToyFolder()
    return WS:FindFirstChild(LP.Name .. "SpawnedInToys")
end

-- ═══ Blobman ═══
local function getBlobman()
    local f = getToyFolder()
    return f and f:FindFirstChild("CreatureBlobman")
end

local function getMountedBlob()
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h and h.SeatPart and h.SeatPart.Parent and h.SeatPart.Parent.Name == "CreatureBlobman" then
            return h.SeatPart.Parent
        end
    end
    return nil
end

local blobAlter = 1
local function blobGrabAlt(player, blob)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    pcall(function()
        local hrp = player.Character.HumanoidRootPart
        if blobAlter == 1 then
            blob:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(
                blob:FindFirstChild("LeftDetector"), hrp,
                blob:FindFirstChild("LeftDetector"):FindFirstChild("LeftWeld"))
            blobAlter = 2
        else
            blob:WaitForChild("BlobmanSeatAndOwnerScript"):WaitForChild("CreatureGrab"):FireServer(
                blob:FindFirstChild("RightDetector"), hrp,
                blob:FindFirstChild("RightDetector"):FindFirstChild("RightWeld"))
            blobAlter = 1
        end
    end)
end

local function blobGrabSide(blob, target, side)
    if not blob or not target then return end
    pcall(function()
        blob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
            blob:FindFirstChild(side .. "Detector"), target,
            blob:FindFirstChild(side .. "Detector"):FindFirstChild(side .. "Weld"))
    end)
end

local function blobKickSide(blob, target, side)
    if not blob or not target then return end
    blobGrabSide(blob, getHRP(), side)
    task.wait(0.1)
    setNet(target)
    task.wait()
    target.CFrame = target.CFrame + Vector3.new(0, 16, 0)
    task.wait(0.1)
    ungrab(target)
    blobGrabSide(blob, target, side)
end

local function blobBring(blob, target, side)
    local pos = getHRP().CFrame
    getHRP().CFrame = target.CFrame
    task.wait(0.25)
    blobGrabSide(blob, target, side)
    task.wait(0.25)
    getHRP().CFrame = pos
end

local function blobVoid(blob, target, side)
    local pos = getHRP().CFrame
    blobGrabSide(blob, getHRP(), side)
    task.wait()
    blobBring(blob, target, side)
    task.wait()
    getHRP().CFrame = CFrame.new(1e32, -16, 1e32)
    task.wait(1)
    pcall(function() getHum().Sit = false end)
    task.wait(0.1)
    getHRP().CFrame = pos
    task.wait()
    destroyToy(blob)
end

local function blobSlide(blob, target, side)
    local pos = getHRP().CFrame
    blobGrabSide(blob, getHRP(), side)
    task.wait()
    blobBring(blob, target, side)
    task.wait()
    getHRP().CFrame = pos
    task.wait(0.5)
    destroyToy(blob)
end

local function blobLock(blob, target, side)
    local pos = getHRP().CFrame
    blobBring(blob, target, side)
    task.wait()
    getHRP().CFrame = pos
end

-- ═══ Snipe System (Hub 3) ═══
local function snipeFunc(root, func)
    if not root or not root.Parent then return end
    local hrp = getHRP()
    if not hrp then return end
    local pos = hrp.CFrame
    task.spawn(function()
        pcall(function()
            noclipChar(LP.Character)
            hrp.CFrame = CFrame.new(root.Position.X, root.Position.Y - 6, root.Position.Z)
            task.wait(0.1)
            WS.CurrentCamera.CFrame = CFrame.lookAt(WS.CurrentCamera.CFrame.Position, root.Position)
            for _ = 1, 4 do setNet(root, hrp.CFrame); task.wait(0.05) end
            task.wait(0.1)
            func()
            task.wait(0.1)
            hrp.CFrame = pos
            addVel(hrp, Vector3.zero, 0.1)
        end)
    end)
end

-- ═══ Hub 2 Attack System ═══
local function h2_noclipModel(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end

local function h2_launchPart(hrp, hum)
    h2_noclipModel(hum.Parent)
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 1e9, 0)
    hum.Jump = true
    hum.Sit = false
    task.delay(3, function() if bv.Parent then bv:Destroy() end end)
end

local function h2_processTarget(target, settings, doKill)
    if not settings.E then return end
    local char = target.Character
    if not char then return end
    local thrp = char:FindFirstChild("HumanoidRootPart")
    local thum = char:FindFirstChildOfClass("Humanoid")
    local thead = char:FindFirstChild("Head")
    if not thrp or not thum or not thead or thum.Health <= 0 then return end
    
    local myChar = LP.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    
    pcall(function()
        settings.S = myChar:GetPivot()
        myChar:PivotTo(CFrame.new(thrp.Position + settings.Off))
        h2_noclipModel(char)
        SNO:FireServer(thrp, thrp.CFrame)
        task.wait()
        if settings.S then
            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            if myHRP and (myHRP.Position - settings.S.Position).Magnitude > settings.D then
                myChar:PivotTo(settings.S)
            end
        end
        task.wait(0.1)
        DestroyLineRem:FireServer(thrp)
        task.wait(0.1)
        if thead:FindFirstChild("PartOwner") and thead.PartOwner.Value == LP.Name then
            h2_launchPart(thrp, thum)
            if doKill then
                task.wait(0.1)
                thum.Health = 0
            end
        end
    end)
    task.wait(settings.Del)
end

-- ═══ Arson (Fire on part) ═══
local function arsonPart(part)
    pcall(function()
        local tf = getToyFolder()
        if not tf then return end
        if not tf:FindFirstChild("Campfire") then
            spawnItem("Campfire", CFrame.new(-73, -6, -266))
            task.wait(0.5)
        end
        local cf = tf:FindFirstChild("Campfire")
        if not cf then return end
        local fp = cf:FindFirstChild("FirePlayerPart")
        if fp then
            fp.Size = Vector3.new(7, 7, 7)
            fp.Position = part.Position
            task.wait(0.3)
            fp.Position = Vector3.new(0, -50, 0)
        end
    end)
end

-- ═══ Coroutine Manager ═══
local function safeClose(co)
    if co and coroutine.status(co) ~= "dead" then pcall(coroutine.close, co) end
    return nil
end

local function safeDisconnect(conn)
    if conn then pcall(function() conn:Disconnect() end) end
    return nil
end

-- ════════════════════════════════════════════════════════
-- RAYFIELD
-- ════════════════════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "GGOG Hub",
    Icon = 0,
    LoadingTitle = "GGOG Hub",
    LoadingSubtitle = "4 Hubs Combined | Fling Things & People",
    Theme = "Amethyst",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GGOGHub",
        FileName = "GGOGConfig"
    },
    KeySystem = false
})

-- ╔═══════════════════════════════════════════════════════════╗
-- ║              TAB 1 — COSMIC HUB (Hub 1)                  ║
-- ╚═══════════════════════════════════════════════════════════╝
local Tab1 = Window:CreateTab("Cosmic Hub", 4483362458)

local H1 = {
    strength = 400, strengthConn = nil,
    poisonCo = nil, ufoCo = nil, fireCo = nil, noclipCo = nil,
    kickGrabConns = {}, kickAnchorCo = nil,
    fireAllCo = nil, ragdollAllCo = nil,
    crouchSpeed = 50, crouchJump = 50,
    crouchSpeedCo = nil, crouchJumpCo = nil,
    anchoredParts = {}, anchoredConns = {},
    compiledGroups = {}, compileConns = {}, renderConns = {},
    compileCo = nil, recoverCo = nil,
    anchorGrabCo = nil,
    antiStruggle = nil, antiKick = nil, antiExplosion = nil, charAddedConn = nil,
    selfDefendCo = nil,
    blobmanCo = nil, blobDelay = 0.005,
    coinAmount = "",
    decoyConns = {}, followMode = true,
    decoyOffset = 15, stopDistance = 5,
    circleRadius = 10
}

-- ═══ COMBAT — STRENGTH ═══
Tab1:CreateSection("Combat — Strength")

Tab1:CreateSlider({
    Name = "Strength Power", Range = {100, 10000}, Increment = 50,
    CurrentValue = 400, Flag = "H1Str",
    Callback = function(v) H1.strength = v end
})

Tab1:CreateToggle({
    Name = "Strength (Right Click Throw)",
    CurrentValue = false, Flag = "H1StrToggle",
    Callback = function(on)
        if on then
            H1.strengthConn = WS.ChildAdded:Connect(function(model)
                if model.Name ~= "GrabParts" then return end
                local gp = model:FindFirstChild("GrabPart")
                if not gp then return end
                local wc = gp:FindFirstChild("WeldConstraint")
                if not wc or not wc.Part1 then return end
                local part = wc.Part1
                local vel = Instance.new("BodyVelocity", part)
                model:GetPropertyChangedSignal("Parent"):Connect(function()
                    if not model.Parent then
                        if UIS:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                            vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            vel.Velocity = WS.CurrentCamera.CFrame.LookVector * H1.strength
                            Debris:AddItem(vel, 1)
                        else
                            vel:Destroy()
                        end
                    end
                end)
            end)
        else
            H1.strengthConn = safeDisconnect(H1.strengthConn)
        end
    end
})

-- ═══ GRAB EFFECTS ═══
Tab1:CreateSection("Grab Effects")

local function h1GrabHandler(tbl)
    while true do
        pcall(function()
            local child = WS:FindFirstChild("GrabParts")
            if child then
                local gp = child:FindFirstChild("GrabPart")
                if gp and gp:FindFirstChild("WeldConstraint") and gp.WeldConstraint.Part1 then
                    local head = gp.WeldConstraint.Part1.Parent:FindFirstChild("Head")
                    if head then
                        while WS:FindFirstChild("GrabParts") do
                            for _, p in pairs(tbl) do
                                p.Size = Vector3.new(2, 2, 2)
                                p.Transparency = 1
                                p.Position = head.Position
                            end
                            task.wait()
                            for _, p in pairs(tbl) do
                                p.Position = Vector3.new(0, -200, 0)
                            end
                        end
                        for _, p in pairs(tbl) do
                            p.Position = Vector3.new(0, -200, 0)
                        end
                    end
                end
            end
        end)
        task.wait()
    end
end

Tab1:CreateToggle({
    Name = "Poison Grab", CurrentValue = false, Flag = "H1PoisonG",
    Callback = function(on)
        H1.poisonCo = safeClose(H1.poisonCo)
        if on then
            H1.poisonCo = coroutine.create(function() h1GrabHandler(poisonParts) end)
            coroutine.resume(H1.poisonCo)
        else
            for _, p in pairs(poisonParts) do p.Position = Vector3.new(0, -200, 0) end
        end
    end
})

Tab1:CreateToggle({
    Name = "Radioactive Grab", CurrentValue = false, Flag = "H1RadioG",
    Callback = function(on)
        H1.ufoCo = safeClose(H1.ufoCo)
        if on then
            H1.ufoCo = coroutine.create(function() h1GrabHandler(paintParts) end)
            coroutine.resume(H1.ufoCo)
        else
            for _, p in pairs(paintParts) do p.Position = Vector3.new(0, -200, 0) end
        end
    end
})

Tab1:CreateToggle({
    Name = "Fire Grab", CurrentValue = false, Flag = "H1FireG",
    Callback = function(on)
        H1.fireCo = safeClose(H1.fireCo)
        if on then
            H1.fireCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local child = WS:FindFirstChild("GrabParts")
                        if child then
                            local gp = child:FindFirstChild("GrabPart")
                            if gp and gp:FindFirstChild("WeldConstraint") and gp.WeldConstraint.Part1 then
                                local head = gp.WeldConstraint.Part1.Parent:FindFirstChild("Head")
                                if head then arsonPart(head) end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.fireCo)
        end
    end
})

Tab1:CreateToggle({
    Name = "Noclip Grab", CurrentValue = false, Flag = "H1NoclipG",
    Callback = function(on)
        H1.noclipCo = safeClose(H1.noclipCo)
        if on then
            H1.noclipCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local child = WS:FindFirstChild("GrabParts")
                        if child then
                            local gp = child:FindFirstChild("GrabPart")
                            if gp and gp:FindFirstChild("WeldConstraint") and gp.WeldConstraint.Part1 then
                                local char = gp.WeldConstraint.Part1.Parent
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    while WS:FindFirstChild("GrabParts") do
                                        noclipChar(char)
                                        task.wait()
                                    end
                                end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.noclipCo)
        end
    end
})

Tab1:CreateToggle({
    Name = "Kick Grab", CurrentValue = false, Flag = "H1KickG",
    Callback = function(on)
        if on then
            for _, player in pairs(Players:GetPlayers()) do
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local fpp = player.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                        if fpp then
                            fpp.Size = Vector3.new(4.5, 5.5, 4.5)
                            fpp.CollisionGroup = "1"
                            fpp.CanQuery = true
                        end
                    end
                end)
            end
            local c1 = Players.PlayerAdded:Connect(function(pl)
                local c2 = pl.CharacterAdded:Connect(function(char)
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    local fpp = hrp:WaitForChild("FirePlayerPart")
                    fpp.Size = Vector3.new(4.5, 5, 4.5)
                    fpp.CollisionGroup = "1"
                    fpp.CanQuery = true
                end)
                table.insert(H1.kickGrabConns, c2)
            end)
            table.insert(H1.kickGrabConns, c1)
        else
            for _, c in pairs(H1.kickGrabConns) do safeDisconnect(c) end
            H1.kickGrabConns = {}
            for _, player in pairs(Players:GetPlayers()) do
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local fpp = player.Character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                        if fpp then
                            fpp.Size = Vector3.new(2.5, 5.5, 2.5)
                            fpp.CollisionGroup = "Default"
                            fpp.CanQuery = false
                        end
                    end
                end)
            end
        end
    end
})

Tab1:CreateToggle({
    Name = "Kick Grab Anchor", CurrentValue = false, Flag = "H1KickAnchor",
    Callback = function(on)
        H1.kickAnchorCo = safeClose(H1.kickAnchorCo)
        if on then
            H1.kickAnchorCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local gp = WS:FindFirstChild("GrabParts")
                        if not gp then return end
                        local grab = gp:FindFirstChild("GrabPart")
                        if not grab then return end
                        local wc = grab:FindFirstChild("WeldConstraint")
                        if not wc or not wc.Part1 then return end
                        local pp = wc.Part1
                        if pp.Name ~= "FirePlayerPart" then return end
                        for _, c in ipairs(pp:GetChildren()) do
                            if c:IsA("BodyPosition") or c:IsA("BodyGyro") then c:Destroy() end
                        end
                        while WS:FindFirstChild("GrabParts") do task.wait() end
                        local bp = Instance.new("BodyPosition")
                        bp.P = 15000; bp.D = 200
                        bp.MaxForce = Vector3.new(5e6, 5e6, 5e6)
                        bp.Position = pp.Position; bp.Parent = pp
                        local bg = Instance.new("BodyGyro")
                        bg.P = 15000; bg.D = 200
                        bg.MaxTorque = Vector3.new(5e6, 5e6, 5e6)
                        bg.CFrame = pp.CFrame; bg.Parent = pp
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.kickAnchorCo)
        end
    end
})

-- ═══ ALL PLAYERS ATTACK ═══
Tab1:CreateSection("All Players Attack")

Tab1:CreateToggle({
    Name = "Fire All", CurrentValue = false, Flag = "H1FireAll",
    Callback = function(on)
        H1.fireAllCo = safeClose(H1.fireAllCo)
        if on then
            H1.fireAllCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local tf = getToyFolder()
                        if not tf then return end
                        if tf:FindFirstChild("Campfire") then destroyToy(tf.Campfire); task.wait(0.5) end
                        local head = playerChar and playerChar:FindFirstChild("Head")
                        if not head then return end
                        spawnItem("Campfire", head.CFrame)
                        task.wait(0.5)
                        local cf = tf:FindFirstChild("Campfire")
                        if not cf then return end
                        local fp
                        for _, p in pairs(cf:GetChildren()) do
                            if p.Name == "FirePlayerPart" then p.Size = Vector3.new(10, 10, 10); fp = p; break end
                        end
                        if not fp then return end
                        setNet(fp, fp.CFrame)
                        local bp = Instance.new("BodyPosition")
                        bp.P = 20000
                        bp.Position = head.Position + Vector3.new(0, 600, 0)
                        bp.Parent = cf:FindFirstChild("Main") or cf.PrimaryPart
                        while true do
                            for _, pl in pairs(Players:GetChildren()) do
                                pcall(function()
                                    bp.Position = head.Position + Vector3.new(0, 600, 0)
                                    if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and pl.Character ~= playerChar then
                                        fp.Position = pl.Character.HumanoidRootPart.Position
                                        task.wait()
                                    end
                                end)
                            end
                            task.wait()
                        end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.fireAllCo)
        end
    end
})

Tab1:CreateToggle({
    Name = "Ragdoll All (Banana)", CurrentValue = false, Flag = "H1RagAll",
    Callback = function(on)
        H1.ragdollAllCo = safeClose(H1.ragdollAllCo)
        if on then
            H1.ragdollAllCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local tf = getToyFolder()
                        if not tf then return end
                        if not tf:FindFirstChild("FoodBanana") then
                            spawnItem("FoodBanana", CFrame.new(-73, -6, -266))
                            task.wait(0.5)
                        end
                        local banana = tf:FindFirstChild("FoodBanana")
                        if not banana then return end
                        local peel
                        for _, p in pairs(banana:GetChildren()) do
                            if p.Name == "BananaPeel" and p:FindFirstChild("TouchInterest") then
                                p.Size = Vector3.new(10, 10, 10); p.Transparency = 1; peel = p; break
                            end
                        end
                        if not peel then return end
                        local bp = Instance.new("BodyPosition"); bp.P = 20000
                        bp.Parent = banana:FindFirstChild("Main") or banana.PrimaryPart
                        local head = playerChar and playerChar:FindFirstChild("Head")
                        while true do
                            for _, pl in pairs(Players:GetChildren()) do
                                pcall(function()
                                    if pl.Character and pl.Character ~= playerChar and pl.Character:FindFirstChild("HumanoidRootPart") then
                                        peel.Position = pl.Character.HumanoidRootPart.Position
                                        if head then bp.Position = head.Position + Vector3.new(0, 600, 0) end
                                        task.wait()
                                    end
                                end)
                            end
                            task.wait()
                        end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.ragdollAllCo)
        end
    end
})

-- ═══ LOCAL PLAYER ═══
Tab1:CreateSection("Local Player")

Tab1:CreateToggle({
    Name = "Crouch Speed", CurrentValue = false, Flag = "H1CSpeed",
    Callback = function(on)
        H1.crouchSpeedCo = safeClose(H1.crouchSpeedCo)
        if on then
            H1.crouchSpeedCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local h = getHum()
                        if h and h.WalkSpeed == 5 then h.WalkSpeed = H1.crouchSpeed end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.crouchSpeedCo)
        else
            pcall(function() local h = getHum(); if h then h.WalkSpeed = 16 end end)
        end
    end
})

Tab1:CreateSlider({
    Name = "Crouch Speed Value", Range = {6, 1000}, Increment = 1,
    CurrentValue = 50, Flag = "H1CSpeedV",
    Callback = function(v) H1.crouchSpeed = v end
})

Tab1:CreateToggle({
    Name = "Crouch Jump Power", CurrentValue = false, Flag = "H1CJump",
    Callback = function(on)
        H1.crouchJumpCo = safeClose(H1.crouchJumpCo)
        if on then
            H1.crouchJumpCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local h = getHum()
                        if h and h.JumpPower == 12 then h.JumpPower = H1.crouchJump end
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.crouchJumpCo)
        else
            pcall(function() local h = getHum(); if h then h.JumpPower = 24 end end)
        end
    end
})

Tab1:CreateSlider({
    Name = "Crouch Jump Value", Range = {6, 1000}, Increment = 1,
    CurrentValue = 50, Flag = "H1CJumpV",
    Callback = function(v) H1.crouchJump = v end
})

-- ═══ OBJECT GRAB ═══
Tab1:CreateSection("Object Grab")

local function h1CreateBodyMovers(part, pos, rot)
    local bp = Instance.new("BodyPosition")
    bp.P = 15000; bp.D = 200; bp.MaxForce = Vector3.new(5e6, 5e6, 5e6)
    bp.Position = pos; bp.Parent = part
    local bg = Instance.new("BodyGyro")
    bg.P = 15000; bg.D = 200; bg.MaxTorque = Vector3.new(5e6, 5e6, 5e6)
    bg.CFrame = rot; bg.Parent = part
end

local function h1CreateHL(parent)
    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.Occluded
    hl.FillTransparency = 1; hl.Name = "Highlight"
    hl.OutlineColor = Color3.new(0, 0, 1)
    hl.OutlineTransparency = 0.5; hl.Parent = parent
    return hl
end

Tab1:CreateToggle({
    Name = "Anchor Grab (Object)", CurrentValue = false, Flag = "H1AnchorObj",
    Callback = function(on)
        H1.anchorGrabCo = safeClose(H1.anchorGrabCo)
        if on then
            H1.anchorGrabCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local gp = WS:FindFirstChild("GrabParts")
                        if not gp then return end
                        local grab = gp:FindFirstChild("GrabPart")
                        if not grab then return end
                        local wc = grab:FindFirstChild("WeldConstraint")
                        if not wc or not wc.Part1 then return end
                        local pp = wc.Part1.Name == "SoundPart" and wc.Part1 or (wc.Part1.Parent and wc.Part1.Parent:FindFirstChild("SoundPart")) or wc.Part1
                        if not pp or pp.Anchored then return end
                        if isDescOf(pp, WS.Map) then return end
                        for _, player in pairs(Players:GetChildren()) do
                            if isDescOf(pp, player.Character) then return end
                        end
                        local alreadyAnchored = false
                        for _, v in pairs(H1.anchoredParts) do
                            if v == pp then alreadyAnchored = true; break end
                        end
                        if not alreadyAnchored then
                            local target = FindAncestorModel(pp) or pp
                            h1CreateHL(target)
                            table.insert(H1.anchoredParts, pp)
                        end
                        if FindAncestorModel(pp) then
                            for _, c in ipairs(FindAncestorModel(pp):GetDescendants()) do
                                if c:IsA("BodyPosition") or c:IsA("BodyGyro") then c:Destroy() end
                            end
                        else
                            for _, c in ipairs(pp:GetChildren()) do
                                if c:IsA("BodyPosition") or c:IsA("BodyGyro") then c:Destroy() end
                            end
                        end
                        while WS:FindFirstChild("GrabParts") do task.wait() end
                        h1CreateBodyMovers(pp, pp.Position, pp.CFrame)
                    end)
                    task.wait()
                end
            end)
            coroutine.resume(H1.anchorGrabCo)
        end
    end
})

Tab1:CreateButton({
    Name = "Unanchor All Parts",
    Callback = function()
        for _, part in ipairs(H1.anchoredParts) do
            pcall(function()
                if part:FindFirstChild("BodyPosition") then part.BodyPosition:Destroy() end
                if part:FindFirstChild("BodyGyro") then part.BodyGyro:Destroy() end
                local hl = part:FindFirstChild("Highlight") or (part.Parent and part.Parent:FindFirstChild("Highlight"))
                if hl then hl:Destroy() end
            end)
        end
        for _, c in ipairs(H1.anchoredConns) do safeDisconnect(c) end
        H1.anchoredParts = {}; H1.anchoredConns = {}
    end
})

Tab1:CreateButton({
    Name = "Compile Anchored Parts",
    Callback = function()
        if #H1.anchoredParts == 0 then
            Rayfield:Notify({Title = "Error", Content = "No anchored parts!", Duration = 3})
            return
        end
        Rayfield:Notify({Title = "Success", Content = "Compiled " .. #H1.anchoredParts .. " parts", Duration = 3})
        local primary = H1.anchoredParts[1]
        if not primary then return end
        local hl = primary:FindFirstChild("Highlight") or (primary.Parent and primary.Parent:FindFirstChild("Highlight"))
        if hl then hl.OutlineColor = Color3.new(0, 1, 0) end
        local group = {}
        for _, part in ipairs(H1.anchoredParts) do
            if part ~= primary then
                table.insert(group, {part = part, offset = primary.CFrame:ToObjectSpace(part.CFrame)})
            end
        end
        table.insert(H1.compiledGroups, {primaryPart = primary, group = group})
        local function updateGroup()
            for _, gd in ipairs(H1.compiledGroups) do
                if gd.primaryPart == primary then
                    for _, data in ipairs(gd.group) do
                        local bp = data.part:FindFirstChild("BodyPosition")
                        local bg = data.part:FindFirstChild("BodyGyro")
                        if bp then bp.Position = (primary.CFrame * data.offset).Position end
                        if bg then bg.CFrame = primary.CFrame * data.offset end
                    end
                end
            end
        end
        local c1 = primary:GetPropertyChangedSignal("CFrame"):Connect(updateGroup)
        local c2 = RunService.Heartbeat:Connect(updateGroup)
        table.insert(H1.compileConns, c1)
        table.insert(H1.renderConns, c2)
    end
})

Tab1:CreateButton({
    Name = "Disassemble All",
    Callback = function()
        for _, gd in ipairs(H1.compiledGroups) do
            for _, data in ipairs(gd.group) do
                pcall(function()
                    if data.part:FindFirstChild("BodyPosition") then data.part.BodyPosition:Destroy() end
                    if data.part:FindFirstChild("BodyGyro") then data.part.BodyGyro:Destroy() end
                end)
            end
            pcall(function()
                local hl = gd.primaryPart:FindFirstChild("Highlight") or gd.primaryPart.Parent:FindFirstChild("Highlight")
                if hl then hl:Destroy() end
            end)
        end
        for _, c in ipairs(H1.compileConns) do safeDisconnect(c) end
        for _, c in ipairs(H1.renderConns) do safeDisconnect(c) end
        H1.compiledGroups = {}; H1.compileConns = {}; H1.renderConns = {}
        -- Also clean anchored
        for _, part in ipairs(H1.anchoredParts) do
            pcall(function()
                if part:FindFirstChild("BodyPosition") then part.BodyPosition:Destroy() end
                if part:FindFirstChild("BodyGyro") then part.BodyGyro:Destroy() end
                local hl = part:FindFirstChild("Highlight") or (part.Parent and part.Parent:FindFirstChild("Highlight"))
                if hl then hl:Destroy() end
            end)
        end
        H1.anchoredParts = {}
    end
})

Tab1:CreateToggle({
    Name = "Auto Recover Dropped Parts", CurrentValue = false, Flag = "H1AutoRecover",
    Callback = function(on)
        H1.recoverCo = safeClose(H1.recoverCo)
        if on then
            H1.recoverCo = coroutine.create(function()
                while true do
                    pcall(function()
                        local hrp = getHRP()
                        if hrp then
                            for _, part in pairs(H1.anchoredParts) do
                                if part and (part.Position - hrp.Position).Magnitude <= 30 then
                                    local hl = part:FindFirstChild("Highlight") or (part.Parent and part.Parent:FindFirstChild("Highlight"))
                                    if hl and hl.OutlineColor == Color3.new(1, 0, 0) then
                                        setNet(part, part.CFrame)
                                        task.wait(0.1)
                                        if part:FindFirstChild("PartOwner") and part.PartOwner.Value == LP.Name then
                                            hl.OutlineColor = Color3.new(0, 0, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.02)
                end
            end)
            coroutine.resume(H1.recoverCo)
        end
    end
})

Tab1:CreateButton({
    Name = "Unanchor Primary Part",
    Callback = function()
        local pp = H1.anchoredParts[1]
        if not pp then return end
        pcall(function()
            if pp:FindFirstChild("BodyPosition") then pp.BodyPosition:Destroy() end
            if pp:FindFirstChild("BodyGyro") then pp.BodyGyro:Destroy() end
            local hl = (pp.Parent and pp.Parent:FindFirstChild("Highlight")) or pp:FindFirstChild("Highlight")
            if hl then hl:Destroy() end
        end)
    end
})

-- ═══ DEFENSE ═══
Tab1:CreateSection("Defense")

Tab1:CreateToggle({
    Name = "Anti Grab (Struggle + Anchor)", CurrentValue = false, Flag = "H1AntiGrab",
    Callback = function(on)
        H1.antiStruggle = safeDisconnect(H1.antiStruggle)
        if on then
            H1.antiStruggle = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local c = LP.Character
                    if c and c:FindFirstChild("Head") and c.Head:FindFirstChild("PartOwner") then
                        StruggleRemote:FireServer()
                        pcall(function() RS.GameCorrectionEvents.StopAllVelocity:FireServer() end)
                        for _, p in pairs(c:GetChildren()) do if p:IsA("BasePart") then p.Anchored = true end end
                        while LP.IsHeld.Value do task.wait() end
                        for _, p in pairs(c:GetChildren()) do if p:IsA("BasePart") then p.Anchored = false end end
                    end
                end)
            end)
        end
    end
})

Tab1:CreateToggle({
    Name = "Anti Kick Grab", CurrentValue = false, Flag = "H1AntiKick",
    Callback = function(on)
        H1.antiKick = safeDisconnect(H1.antiKick)
        if on then
            H1.antiKick = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local c = LP.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        local fpp = c.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                        if fpp then
                            local po = fpp:FindFirstChild("PartOwner")
                            if po and po.Value ~= LP.Name then
                                if RagdollRemote then RagdollRemote:FireServer(c.HumanoidRootPart, 0) end
                                task.wait(0.1)
                                StruggleRemote:FireServer()
                            end
                        end
                    end
                end)
            end)
        end
    end
})

Tab1:CreateToggle({
    Name = "Anti Explosion", CurrentValue = false, Flag = "H1AntiExp",
    Callback = function(on)
        H1.antiExplosion = safeDisconnect(H1.antiExplosion)
        H1.charAddedConn = safeDisconnect(H1.charAddedConn)
        if on then
            local function setup(c)
                pcall(function()
                    local rag = c:WaitForChild("Humanoid"):FindFirstChild("Ragdolled")
                    if rag then
                        H1.antiExplosion = rag:GetPropertyChangedSignal("Value"):Connect(function()
                            for _, p in ipairs(c:GetChildren()) do
                                if p:IsA("BasePart") then p.Anchored = rag.Value end
                            end
                        end)
                    end
                end)
            end
            if LP.Character then setup(LP.Character) end
            H1.charAddedConn = LP.CharacterAdded:Connect(function(c)
                H1.antiExplosion = safeDisconnect(H1.antiExplosion)
                setup(c)
            end)
        end
    end
})

Tab1:CreateToggle({
    Name = "Self Defense / Air Suspend", CurrentValue = false, Flag = "H1SelfDef",
    Callback = function(on)
        H1.selfDefendCo = safeClose(H1.selfDefendCo)
        if on then
            H1.selfDefendCo = coroutine.create(function()
                while task.wait(0.02) do
                    pcall(function()
                        local c = LP.Character
                        if c and c:FindFirstChild("Head") then
                            local po = c.Head:FindFirstChild("PartOwner")
                            if po then
                                local atk = Players:FindFirstChild(po.Value)
                                if atk and atk.Character then
                                    StruggleRemote:FireServer()
                                    pcall(function()
                                        setNet(atk.Character.Head, atk.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                                    end)
                                    task.wait(0.1)
                                    local t = atk.Character:FindFirstChild("Torso")
                                    if t then
                                        local v = t:FindFirstChild("l") or Instance.new("BodyVelocity")
                                        v.Name = "l"; v.Parent = t
                                        v.Velocity = Vector3.new(0, 5000, 0)
                                        v.MaxForce = Vector3.new(0, math.huge, 0)
                                        Debris:AddItem(v, 100)
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
            coroutine.resume(H1.selfDefendCo)
        end
    end
})

-- ═══ BLOBMAN ═══
Tab1:CreateSection("Blobman")

Tab1:CreateToggle({
    Name = "Blobman Destroy Server", CurrentValue = false, Flag = "H1BlobDes",
    Callback = function(on)
        H1.blobmanCo = safeClose(H1.blobmanCo)
        if on then
            H1.blobmanCo = coroutine.create(function()
                local blob
                for _, v in pairs(WS:GetDescendants()) do
                    if v.Name == "CreatureBlobman" and v:FindFirstChild("VehicleSeat") and v.VehicleSeat:FindFirstChild("SeatWeld") then
                        pcall(function()
                            if v.VehicleSeat.SeatWeld.Part1:IsDescendantOf(LP.Character) then blob = v end
                        end)
                    end
                    if blob then break end
                end
                if not blob then
                    Rayfield:Notify({Title = "Error", Content = "Mount a blobman first!", Duration = 3})
                    return
                end
                while true do
                    for _, v in pairs(Players:GetChildren()) do
                        if blob and v ~= LP then
                            pcall(function() blobGrabAlt(v, blob) end)
                            task.wait(H1.blobDelay)
                        end
                    end
                    task.wait(0.02)
                end
            end)
            coroutine.resume(H1.blobmanCo)
        end
    end
})

Tab1:CreateSlider({
    Name = "Blobman Speed", Range = {0.005, 1}, Increment = 0.005,
    CurrentValue = 0.005, Flag = "H1BlobSpd",
    Callback = function(v) H1.blobDelay = v end
})

-- ═══ FUN ═══
Tab1:CreateSection("Fun / Troll")

Tab1:CreateInput({
    Name = "Coin Amount (Visual)", PlaceholderText = "Number",
    RemoveTextAfterFocusLost = false, Flag = "H1CoinIn",
    Callback = function(t) H1.coinAmount = t end
})

Tab1:CreateButton({
    Name = "Set Coins (Visual Only)",
    Callback = function()
        pcall(function() LP.PlayerGui.MenuGui.TopRight.CoinsFrame.CoinsDisplay.Coins.Text = tostring(tonumber(H1.coinAmount) or 0) end)
    end
})

Tab1:CreateSlider({
    Name = "Decoy Offset", Range = {1, 30}, Increment = 1,
    CurrentValue = 15, Flag = "H1DecoyOff",
    Callback = function(v) H1.decoyOffset = v end
})

Tab1:CreateInput({
    Name = "Circle Radius (Surround)", PlaceholderText = "10",
    RemoveTextAfterFocusLost = false, Flag = "H1CircleR",
    Callback = function(v) H1.circleRadius = tonumber(v) or 10 end
})

Tab1:CreateButton({
    Name = "Decoy Follow",
    Callback = function()
        local decoys = {}
        for _, d in pairs(WS:GetDescendants()) do
            if d:IsA("Model") and d.Name == "YouDecoy" then table.insert(decoys, d) end
        end
        local num = #decoys
        local mid = math.ceil(num / 2)
        
        local function getNearestPlayer()
            local nearest, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (playerChar.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = p end
                end
            end
            return nearest
        end

        for i, decoy in pairs(decoys) do
            local torso = decoy:FindFirstChild("Torso")
            if torso then
                local bp = Instance.new("BodyPosition"); bp.Parent = torso
                bp.MaxForce = Vector3.new(40000, 40000, 40000); bp.D = 100; bp.P = 100
                local bg = Instance.new("BodyGyro"); bg.Parent = torso
                bg.MaxTorque = Vector3.new(40000, 40000, 40000); bg.D = 100; bg.P = 20000
                setNet(torso, playerChar.Head.CFrame)
                
                local conn = RunService.Heartbeat:Connect(function()
                    pcall(function()
                        if not torso or not torso.Parent then return end
                        local targetPos
                        if H1.followMode then
                            if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                                local offset = (i - mid) * H1.decoyOffset
                                local fwd = playerChar.HumanoidRootPart.CFrame.LookVector
                                local right = playerChar.HumanoidRootPart.CFrame.RightVector
                                targetPos = playerChar.HumanoidRootPart.Position - fwd * H1.decoyOffset + right * offset
                            end
                        else
                            local np = getNearestPlayer()
                            if np and np.Character and np.Character:FindFirstChild("HumanoidRootPart") then
                                local angle = math.rad((i - 1) * (360 / num))
                                targetPos = np.Character.HumanoidRootPart.Position + Vector3.new(math.cos(angle) * H1.circleRadius, 0, math.sin(angle) * H1.circleRadius)
                                bg.CFrame = CFrame.new(torso.Position, np.Character.HumanoidRootPart.Position)
                            end
                        end
                        if targetPos then
                            if (targetPos - torso.Position).Magnitude > H1.stopDistance then
                                bp.Position = targetPos
                                if H1.followMode then bg.CFrame = CFrame.new(torso.Position, targetPos) end
                            else
                                bp.Position = torso.Position
                            end
                        end
                    end)
                end)
                table.insert(H1.decoyConns, conn)
            end
        end
        Rayfield:Notify({Title = "Decoys", Content = "Got " .. num .. " units", Duration = 3})
    end
})

Tab1:CreateButton({
    Name = "Toggle Follow/Surround Mode",
    Callback = function()
        H1.followMode = not H1.followMode
        Rayfield:Notify({Title = "Mode", Content = H1.followMode and "Follow Mode" or "Surround Mode", Duration = 2})
    end
})

Tab1:CreateButton({
    Name = "Disconnect Decoys",
    Callback = function()
        for _, c in ipairs(H1.decoyConns) do safeDisconnect(c) end
        H1.decoyConns = {}
    end
})

-- ╔═══════════════════════════════════════════════════════════╗
-- ║              TAB 2 — COSMIC V2 (Hub 2)                    ║
-- ╚═══════════════════════════════════════════════════════════╝
local Tab2 = Window:CreateTab("Cosmic V2", 4483362458)

local H2 = {
    -- Movement
    walkspeed = false, speedMul = 1,
    infJump = false, jumpPow = 100,
    noclip = false,
    -- Anti
    antiGrab = false, antiExplode = false, antiFire = false, antiBlobman = false, antiLag = false,
    -- Attack
    attackPlayers = {}, selectedPlayer = nil,
    loopKickOn = false, loopKillOn = false, kickAllOn = false, killAllOn = false,
    kickSettings = {E = false, S = nil, D = 2, Off = Vector3.new(5, -18.5, 0), H = 10000, Del = 0.5},
    killSettings = {E = false, S = nil, D = 2, Off = Vector3.new(5, -18.5, 0), H = 10000, Del = 0.5},
    killGrab = false,
    strengthOn = false, strengthPow = 800,
    -- Snowball
    sbTarget = nil, sbRagdoll = false, sbAutoSpawn = false,
    -- Blobman
    blobTargets = {}, blobTargetOn = false, blobDelay = 0.1,
    blobGodLoop = false, blobHover = false,
    -- Auras
    launchAura = false, telekAura = false, deathAura = false, auraRadius = 25,
    -- TP
    tpTarget = nil, loopTP = false,
    -- Misc
    lagOn = false, lagIntensity = 5,
    bringAllOn = false, bringWLFriends = false,
    -- Connections
    strengthConn = nil, deathConn = nil, launchCo = nil, telekCo = nil,
    loopKickConn = nil, loopKillConn = nil, kickAllConn = nil, killAllConn = nil,
    blobTargetCo = nil, blobGodCo = nil, blobHoverCo = nil,
    bringAllState = {A = false, Conn = nil, Pos = nil, Cam = nil, Q = {}, R = 15, WL = false},
}

-- ═══ MOVEMENT ═══
Tab2:CreateSection("Movement")

Tab2:CreateToggle({
    Name = "Walkspeed (CFrame)", CurrentValue = false, Flag = "H2Walk",
    Callback = function(v) H2.walkspeed = v end
})

Tab2:CreateSlider({
    Name = "Speed Multiplier", Range = {1, 5}, Increment = 0.1,
    CurrentValue = 1, Flag = "H2SpeedM",
    Callback = function(v) H2.speedMul = v end
})

Tab2:CreateToggle({
    Name = "Infinite Jump", CurrentValue = false, Flag = "H2InfJ",
    Callback = function(v) H2.infJump = v end
})

Tab2:CreateSlider({
    Name = "Jump Power", Range = {16, 500}, Increment = 1,
    CurrentValue = 100, Flag = "H2JumpP",
    Callback = function(v) H2.jumpPow = v end
})

Tab2:CreateToggle({
    Name = "Noclip", CurrentValue = false, Flag = "H2Noclip",
    Callback = function(v) H2.noclip = v end
})

-- ═══ ANTI SYSTEMS ═══
Tab2:CreateSection("Anti Systems")

Tab2:CreateButton({
    Name = "Anti Ragdoll/Snowball (Spam Fire)",
    Callback = function()
        if RagdollRemote then
            task.spawn(function()
                for _, v in pairs(Players:GetPlayers()) do
                    if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        for _ = 1, 150 do RagdollRemote:FireServer(v.Character.HumanoidRootPart, 9999999); task.wait() end
                    end
                end
            end)
        end
    end
})

Tab2:CreateButton({
    Name = "Destroy Void",
    Callback = function() WS.FallenPartsDestroyHeight = -1e95 end
})

Tab2:CreateToggle({Name = "Anti Grab", CurrentValue = false, Flag = "H2AntiG", Callback = function(v) H2.antiGrab = v end})
Tab2:CreateToggle({Name = "Anti Explode", CurrentValue = false, Flag = "H2AntiE", Callback = function(v) H2.antiExplode = v end})
Tab2:CreateToggle({Name = "Anti Fire", CurrentValue = false, Flag = "H2AntiF", Callback = function(v) H2.antiFire = v end})
Tab2:CreateToggle({Name = "Anti Blobman", CurrentValue = false, Flag = "H2AntiB", Callback = function(v) H2.antiBlobman = v end})

Tab2:CreateToggle({
    Name = "Anti Lag", CurrentValue = false, Flag = "H2AntiLag",
    Callback = function(v)
        H2.antiLag = v
        pcall(function()
            local scr = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("CharacterAndBeamMove")
            if scr then scr.Disabled = v end
        end)
    end
})

-- ═══ ATTACK — LOOP ═══
Tab2:CreateSection("Attack — Loop Kill/Kick")

local h2SelectDD = Tab2:CreateDropdown({
    Name = "Select Player", Options = getPlayerList(),
    CurrentOption = {}, MultipleOptions = false, Flag = "H2Select",
    Callback = function(opt) H2.selectedPlayer = Players:FindFirstChild(type(opt) == "table" and opt[1] or opt) end
})

local h2LoopDD = Tab2:CreateDropdown({
    Name = "Players in Loop", Options = {},
    CurrentOption = {}, MultipleOptions = false, Flag = "H2Loop",
    Callback = function(opt) H2.selectedPlayer = Players:FindFirstChild(type(opt) == "table" and opt[1] or opt) end
})

Tab2:CreateButton({
    Name = "Add Player to Loop",
    Callback = function()
        if H2.selectedPlayer and not H2.attackPlayers[H2.selectedPlayer.Name] then
            H2.attackPlayers[H2.selectedPlayer.Name] = true
            local list = {}
            for n, _ in pairs(H2.attackPlayers) do table.insert(list, n) end
            pcall(function() h2LoopDD:Set(list) end)
        end
    end
})

Tab2:CreateButton({
    Name = "Remove Player from Loop",
    Callback = function()
        if H2.selectedPlayer and H2.attackPlayers[H2.selectedPlayer.Name] then
            H2.attackPlayers[H2.selectedPlayer.Name] = nil
            local list = {}
            for n, _ in pairs(H2.attackPlayers) do table.insert(list, n) end
            pcall(function() h2LoopDD:Set(list) end)
        end
    end
})

Tab2:CreateToggle({
    Name = "Loop Kick (Selected)", CurrentValue = false, Flag = "H2LoopKick",
    Callback = function(on)
        H2.kickSettings.E = on
        H2.loopKickConn = safeDisconnect(H2.loopKickConn)
        if on then
            H2.loopKickConn = RunService.Heartbeat:Connect(function()
                if not H2.kickSettings.E then return end
                for name, _ in pairs(H2.attackPlayers) do
                    local p = Players:FindFirstChild(name)
                    if p then h2_processTarget(p, H2.kickSettings, false) end
                end
            end)
        end
    end
})

Tab2:CreateToggle({
    Name = "Loop Kill (Selected)", CurrentValue = false, Flag = "H2LoopKill",
    Callback = function(on)
        H2.killSettings.E = on
        H2.loopKillConn = safeDisconnect(H2.loopKillConn)
        if on then
            H2.loopKillConn = RunService.Heartbeat:Connect(function()
                if not H2.killSettings.E then return end
                for name, _ in pairs(H2.attackPlayers) do
                    local p = Players:FindFirstChild(name)
                    if p then h2_processTarget(p, H2.killSettings, true) end
                end
            end)
        end
    end
})

Tab2:CreateToggle({
    Name = "Kick All", CurrentValue = false, Flag = "H2KickAll",
    Callback = function(on)
        H2.kickAllConn = safeDisconnect(H2.kickAllConn)
        if on then
            H2.kickSettings.E = true
            H2.kickAllConn = RunService.Heartbeat:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP then h2_processTarget(p, H2.kickSettings, false) end
                end
            end)
        else
            H2.kickSettings.E = false
        end
    end
})

Tab2:CreateToggle({
    Name = "Kill All", CurrentValue = false, Flag = "H2KillAll",
    Callback = function(on)
        H2.killAllConn = safeDisconnect(H2.killAllConn)
        if on then
            H2.killSettings.E = true
            H2.killAllConn = RunService.Heartbeat:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP then h2_processTarget(p, H2.killSettings, true) end
                end
            end)
        else
            H2.killSettings.E = false
        end
    end
})

-- ═══ GRABS ═══
Tab2:CreateSection("Grabs")

Tab2:CreateToggle({Name = "Kill Grab", CurrentValue = false, Flag = "H2KillG", Callback = function(v) H2.killGrab = v end})

Tab2:CreateToggle({
    Name = "Strength", CurrentValue = false, Flag = "H2StrT",
    Callback = function(on)
        H2.strengthOn = on
        H2.strengthConn = safeDisconnect(H2.strengthConn)
        if on then
            H2.strengthConn = WS.ChildAdded:Connect(function(model)
                if model.Name ~= "GrabParts" then return end
                local gp = model:FindFirstChild("GrabPart")
                if not gp or not gp:FindFirstChild("WeldConstraint") or not gp.WeldConstraint.Part1 then return end
                local part = gp.WeldConstraint.Part1
                local bv = Instance.new("BodyVelocity", part)
                bv.MaxForce = Vector3.zero
                local throwBtn
                -- Find throw button
                local function doThrow()
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = WS.CurrentCamera.CFrame.LookVector * H2.strengthPow
                end
                pcall(function()
                    for _, d in pairs(LP.PlayerGui.ContextActionGui:GetDescendants()) do
                        if d:IsA("ImageLabel") and d.Image == "http://www.roblox.com/asset/?id=9603678090" then
                            throwBtn = d.Parent; break
                        end
                    end
                end)
                if throwBtn then
                    throwBtn.MouseButton1Up:Connect(doThrow)
                    throwBtn.MouseButton1Down:Connect(doThrow)
                end
                model:GetPropertyChangedSignal("Parent"):Connect(function()
                    if not model.Parent then Debris:AddItem(bv, 1) end
                end)
            end)
        end
    end
})

Tab2:CreateSlider({
    Name = "Launch Strength", Range = {10, 3000}, Increment = 50,
    CurrentValue = 800, Flag = "H2StrP",
    Callback = function(v) H2.strengthPow = v end
})

-- ═══ SNOWBALL ═══
Tab2:CreateSection("Snowball Ragdoll")

local h2SbDD = Tab2:CreateDropdown({
    Name = "Snowball Target", Options = getPlayerList(),
    CurrentOption = {}, MultipleOptions = false, Flag = "H2SbTgt",
    Callback = function(opt) H2.sbTarget = type(opt) == "table" and opt[1] or opt end
})

Tab2:CreateToggle({
    Name = "Snowball Ragdoll", CurrentValue = false, Flag = "H2SbRag",
    Callback = function(on)
        H2.sbRagdoll = on
        if on then
            task.spawn(function()
                while H2.sbRagdoll do
                    pcall(function()
                        local tf = getToyFolder()
                        if tf and H2.sbTarget then
                            local t = Players:FindFirstChild(H2.sbTarget)
                            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                                for _, m in ipairs(tf:GetChildren()) do
                                    if m:IsA("Model") and m.Name == "BallSnowball" then
                                        for _, p in ipairs(m:GetDescendants()) do
                                            if p:IsA("BasePart") then p.Position = t.Character.HumanoidRootPart.Position end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tab2:CreateToggle({
    Name = "Auto Spawn Snowballs", CurrentValue = false, Flag = "H2SbSpawn",
    Callback = function(on)
        H2.sbAutoSpawn = on
        if on then
            task.spawn(function()
                while H2.sbAutoSpawn do
                    pcall(function()
                        local hrp = getHRP()
                        if hrp then spawnItem("BallSnowball", CFrame.new(hrp.Position + Vector3.new(0, 2, 0))) end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- ═══ BLOBMAN TARGET ═══
Tab2:CreateSection("Blobman Target")

local h2BlobDD = Tab2:CreateDropdown({
    Name = "Select Player", Options = getPlayerList(),
    CurrentOption = {}, MultipleOptions = false, Flag = "H2BlobSel",
    Callback = function(opt)
        local name = type(opt) == "table" and opt[1] or opt
        H2.blobSelectedPlayer = Players:FindFirstChild(name)
    end
})

Tab2:CreateButton({
    Name = "Add to Blob Target List",
    Callback = function()
        if H2.blobSelectedPlayer then
            H2.blobTargets[H2.blobSelectedPlayer.UserId] = H2.blobSelectedPlayer.Name
            Rayfield:Notify({Title = "Added", Content = H2.blobSelectedPlayer.Name, Duration = 2})
        end
    end
})

Tab2:CreateButton({
    Name = "Remove from Blob Target List",
    Callback = function()
        if H2.blobSelectedPlayer then
            H2.blobTargets[H2.blobSelectedPlayer.UserId] = nil
            Rayfield:Notify({Title = "Removed", Content = H2.blobSelectedPlayer.Name, Duration = 2})
        end
    end
})

Tab2:CreateToggle({
    Name = "Blobman Target (Grab Loop)", CurrentValue = false, Flag = "H2BlobTarget",
    Callback = function(on)
        H2.blobTargetOn = on
        H2.blobTargetCo = safeClose(H2.blobTargetCo)
        if on then
            H2.blobTargetCo = coroutine.create(function()
                while H2.blobTargetOn do
                    local blob = getMountedBlob()
                    if not blob then
                        Rayfield:Notify({Title = "Error", Content = "Mount a blobman!", Duration = 3})
                        H2.blobTargetOn = false
                        return
                    end
                    for uid, _ in pairs(H2.blobTargets) do
                        local p = Players:GetPlayerByUserId(uid)
                        if p then blobGrabAlt(p, blob); task.wait(H2.blobDelay) end
                    end
                    task.wait(0.02)
                end
            end)
            coroutine.resume(H2.blobTargetCo)
        end
    end
})

Tab2:CreateToggle({
    Name = "God Loop Target (Fast Grab/Drop)", CurrentValue = false, Flag = "H2GodLoop",
    Callback = function(on)
        H2.blobGodLoop = on
        H2.blobGodCo = safeClose(H2.blobGodCo)
        if on then
            H2.blobGodCo = coroutine.create(function()
                local blob = getMountedBlob()
                if not blob then
                    Rayfield:Notify({Title = "Error", Content = "Mount a blobman!", Duration = 3})
                    return
                end
                while H2.blobGodLoop do
                    for uid, _ in pairs(H2.blobTargets) do
                        local p = Players:GetPlayerByUserId(uid)
                        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            pcall(function()
                                local hrp = p.Character.HumanoidRootPart
                                local ld = blob:FindFirstChild("LeftDetector")
                                local rd = blob:FindFirstChild("RightDetector")
                                local script = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
                                if script then
                                    local grab = script:FindFirstChild("CreatureGrab")
                                    local drop = script:FindFirstChild("CreatureDrop")
                                    if grab and drop then
                                        if ld then
                                            local w = ld:FindFirstChild("RigidConstraint") or ld:FindFirstChild("LeftWeld")
                                            if w then
                                                grab:FireServer(ld, hrp, w)
                                                drop:FireServer(w, hrp)
                                            end
                                        end
                                        if rd then
                                            local w = rd:FindFirstChild("RightWeld") or rd:FindFirstChild("RigidConstraint")
                                            if w then
                                                grab:FireServer(rd, hrp, w)
                                                drop:FireServer(w, hrp)
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                    task.wait(0.01)
                end
            end)
            coroutine.resume(H2.blobGodCo)
        end
    end
})

Tab2:CreateToggle({
    Name = "Hover Above Target", CurrentValue = false, Flag = "H2Hover",
    Callback = function(on)
        H2.blobHover = on
        H2.blobHoverCo = safeClose(H2.blobHoverCo)
        if on then
            H2.blobHoverCo = coroutine.create(function()
                while H2.blobHover do
                    pcall(function()
                        local blob = getMountedBlob()
                        local target = H2.blobSelectedPlayer
                        if blob and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                            local tPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 25, 0)
                            if blob.PrimaryPart then
                                local bp = Instance.new("BodyPosition")
                                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bp.P = 100000; bp.Position = tPos; bp.Parent = blob.PrimaryPart
                                local myHRP = getHRP()
                                if myHRP then myHRP.CFrame = CFrame.new(tPos) end
                                pcall(function() blob:SetPrimaryPartCFrame(CFrame.new(tPos)) end)
                                task.wait(0.1)
                                if bp.Parent then bp:Destroy() end
                            end
                        end
                    end)
                    task.wait(0.06)
                end
            end)
            coroutine.resume(H2.blobHoverCo)
        end
    end
})

Tab2:CreateSlider({
    Name = "Blobman Delay", Range = {0.01, 1}, Increment = 0.01,
    CurrentValue = 0.1, Flag = "H2BlobDel",
    Callback = function(v) H2.blobDelay = v end
})

-- ═══ AURAS ═══
Tab2:CreateSection("Auras")

Tab2:CreateSlider({
    Name = "Aura Radius", Range = {10, 100}, Increment = 5,
    CurrentValue = 25, Flag = "H2AuraR",
    Callback = function(v) H2.auraRadius = v end
})

Tab2:CreateToggle({Name = "Launch Aura", CurrentValue = false, Flag = "H2LaunchA", Callback = function(v) H2.launchAura = v end})
Tab2:CreateToggle({Name = "Telekinesis Aura", CurrentValue = false, Flag = "H2TelekA", Callback = function(v) H2.telekAura = v end})

Tab2:CreateToggle({
    Name = "Death Aura", CurrentValue = false, Flag = "H2DeathA",
    Callback = function(on)
        H2.deathAura = on
        H2.deathConn = safeDisconnect(H2.deathConn)
        if on then
            H2.deathConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character then
                            local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                            local head = p.Character:FindFirstChild("Head")
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if tHRP and head and hum and hum.Health > 0 and (tHRP.Position - hrp.Position).Magnitude <= H2.auraRadius then
                                SNO:FireServer(tHRP, tHRP.CFrame)
                                task.wait(0.1)
                                DestroyLineRem:FireServer(tHRP)
                                if head:FindFirstChild("PartOwner") and head.PartOwner.Value == LP.Name then
                                    for _, pt in pairs(hum.Parent:GetChildren()) do
                                        if pt:IsA("BasePart") then pt.CFrame = CFrame.new(-1e9, 1e9, -1e9) end
                                    end
                                    local bv = Instance.new("BodyVelocity")
                                    bv.Velocity = Vector3.new(0, -9999999, 0)
                                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                    bv.Parent = tHRP
                                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                                    Debris:AddItem(bv, 2)
                                end
                            end
                        end
                    end
                end)
            end)
        end
    end
})

-- ═══ TELEPORT ═══
Tab2:CreateSection("Teleport")

local h2TpDD = Tab2:CreateDropdown({
    Name = "Teleport Target", Options = getPlayerList(),
    CurrentOption = {}, MultipleOptions = false, Flag = "H2TpDrop",
    Callback = function(opt) H2.tpTarget = type(opt) == "table" and opt[1] or opt end
})

Tab2:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if H2.tpTarget then
            local t = Players:FindFirstChild(H2.tpTarget)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = getHRP()
                if hrp then hrp.CFrame = t.Character.HumanoidRootPart.CFrame end
            end
        end
    end
})

Tab2:CreateToggle({
    Name = "Loop Teleport", CurrentValue = false, Flag = "H2LoopTP",
    Callback = function(v) H2.loopTP = v end
})

-- ═══ SERVER MISC ═══
Tab2:CreateSection("Server Misc")

Tab2:CreateToggle({Name = "Lag Server", CurrentValue = false, Flag = "H2Lag", Callback = function(v) H2.lagOn = v end})
Tab2:CreateSlider({Name = "Lag Intensity", Range = {1, 500}, Increment = 1, CurrentValue = 5, Flag = "H2LagI", Callback = function(v) H2.lagIntensity = v end})

Tab2:CreateButton({
    Name = "Destroy All Gucci (Blobmen)",
    Callback = function()
        for _, v in pairs(WS:GetDescendants()) do
            pcall(function()
                if v.Name == "CreatureBlobman" then
                    v.VehicleSeat:Sit(LP.Character.Humanoid)
                    task.wait(0.05)
                    LP.Character.Humanoid.Jump = true
                end
            end)
        end
    end
})

-- ╔═══════════════════════════════════════════════════════════╗
-- ║              TAB 3 — EGG HUB (Hub 3)                     ║
-- ╚═══════════════════════════════════════════════════════════╝
local Tab3 = Window:CreateTab("Egg Hub", 4483362458)

local H3 = {
    KickGrab = false, KillGrab = false, VoidGrab = false, AnchorGrab = false,
    SuperStr = false, StrPow = 250,
    AntiGrab = false, AntiVoid = false, AntiExplode = false, AntiRagdoll = false, AntiGucci = false,
    KillAura = false, VoidAura = false, RagdollAura = false, FireAura = false,
    AnchorAura = false, NoclipAura = false, AuraR = 32,
    BlobTarget = "", BlobSide = "Left",
    BlobGrabAura = false, BlobKickAura = false, BlobLoopKick = false,
    TargetPlayer = nil,
    LoopKill = false, LoopVoid = false, LoopPoison = false,
    LoopRagdoll = false, LoopDeath = false, LoopBring = false, LoopPull = false,
    SpeedVal = 16, JumpVal = 50, SpeedOn = false, JumpOn = false, Noclip = false,
    ChaosLine = false, CameraZoom = false,
    AuraT = 0, DefT = 0, LoopT = 0, ChaosT = 0
}

-- ═══ GRAB CONTROLS ═══
Tab3:CreateSection("Grab Controls")
Tab3:CreateToggle({Name = "Kick Grab", CurrentValue = false, Flag = "H3KickG", Callback = function(v) H3.KickGrab = v end})
Tab3:CreateToggle({Name = "Kill Grab", CurrentValue = false, Flag = "H3KillG", Callback = function(v) H3.KillGrab = v end})
Tab3:CreateToggle({Name = "Void Grab", CurrentValue = false, Flag = "H3VoidG", Callback = function(v) H3.VoidGrab = v end})
Tab3:CreateToggle({Name = "Anchor Grab", CurrentValue = false, Flag = "H3AnchorG", Callback = function(v) H3.AnchorGrab = v end})

Tab3:CreateSection("Super Strength")
Tab3:CreateSlider({Name = "Throw Power", Range = {0, 10000}, Increment = 10, CurrentValue = 250, Flag = "H3StrP", Callback = function(v) H3.StrPow = v end})
Tab3:CreateToggle({Name = "Super Strength", CurrentValue = false, Flag = "H3SuperStr", Callback = function(v) H3.SuperStr = v end})

-- ═══ DEFENSE ═══
Tab3:CreateSection("Defense")
Tab3:CreateToggle({Name = "Anti-Grab", CurrentValue = false, Flag = "H3AntiG", Callback = function(v) H3.AntiGrab = v end})
Tab3:CreateToggle({Name = "Anti-Void", CurrentValue = false, Flag = "H3AntiV", Callback = function(v) H3.AntiVoid = v end})
Tab3:CreateToggle({Name = "Anti-Explode", CurrentValue = false, Flag = "H3AntiE", Callback = function(v) H3.AntiExplode = v end})
Tab3:CreateToggle({Name = "Anti-Ragdoll", CurrentValue = false, Flag = "H3AntiR", Callback = function(v) H3.AntiRagdoll = v end})
Tab3:CreateToggle({Name = "Anti-Gucci", CurrentValue = false, Flag = "H3AntiGuc", Callback = function(v) H3.AntiGucci = v end})

-- ═══ AURAS ═══
Tab3:CreateSection("Auras")
Tab3:CreateSlider({Name = "Aura Radius", Range = {10, 100}, Increment = 1, CurrentValue = 32, Flag = "H3AuraR", Callback = function(v) H3.AuraR = v end})
Tab3:CreateToggle({Name = "Kill Aura", CurrentValue = false, Flag = "H3KillA", Callback = function(v) H3.KillAura = v end})
Tab3:CreateToggle({Name = "Void Aura", CurrentValue = false, Flag = "H3VoidA", Callback = function(v) H3.VoidAura = v end})
Tab3:CreateToggle({Name = "Ragdoll Aura", CurrentValue = false, Flag = "H3RagA", Callback = function(v) H3.RagdollAura = v end})
Tab3:CreateToggle({Name = "Fire Aura", CurrentValue = false, Flag = "H3FireA", Callback = function(v) H3.FireAura = v end})
Tab3:CreateToggle({Name = "Anchor Aura", CurrentValue = false, Flag = "H3AnchorA", Callback = function(v) H3.AnchorAura = v end})
Tab3:CreateToggle({Name = "Noclip Aura", CurrentValue = false, Flag = "H3NoclipA", Callback = function(v) H3.NoclipAura = v end})

-- ═══ BLOBMAN ═══
Tab3:CreateSection("Blobman")
Tab3:CreateButton({Name = "Spawn Blobman", Callback = function() local h = getHRP(); if h then spawnItem("CreatureBlobman", h.CFrame) end end})
Tab3:CreateInput({Name = "Target Player", PlaceholderText = "Name...", RemoveTextAfterFocusLost = false, Flag = "H3BlobT", Callback = function(v) H3.BlobTarget = v end})
Tab3:CreateDropdown({Name = "Arm Side", Options = {"Left", "Right"}, CurrentOption = {"Left"}, Flag = "H3BlobS", Callback = function(v) H3.BlobSide = type(v) == "table" and v[1] or v end})

Tab3:CreateSection("Single Blob Actions")
Tab3:CreateButton({Name = "Blob Grab", Callback = function()
    local t = findPlayer(H3.BlobTarget)
    if t and t.Character then local b = getBlobman(); if b then blobGrabSide(b, t.Character:FindFirstChild("HumanoidRootPart"), H3.BlobSide) end end
end})

Tab3:CreateButton({Name = "Blob Bring", Callback = function()
    local t = findPlayer(H3.BlobTarget)
    if t and t.Character then local b = getBlobman(); if b then blobBring(b, t.Character:FindFirstChild("HumanoidRootPart"), H3.BlobSide) end end
end})

Tab3:CreateButton({Name = "Blob Kick", Callback = function()
    local t = findPlayer(H3.BlobTarget)
    if t and t.Character then local b = getBlobman(); if b then blobKickSide(b, t.Character:FindFirstChild("HumanoidRootPart"), H3.BlobSide) end end
end})

Tab3:CreateButton({Name = "Blob Void", Callback = function()
    local t = findPlayer(H3.BlobTarget)
    if t and t.Character then local b = getBlobman(); if b then blobVoid(b, t.Character:FindFirstChild("HumanoidRootPart"), H3.BlobSide) end end
end})

Tab3:CreateButton({Name = "Blob Slide", Callback = function()
    local t = findPlayer(H3.BlobTarget)
    if t and t.Character then local b = getBlobman(); if b then blobSlide(b, t.Character:FindFirstChild("HumanoidRootPart"), H3.BlobSide) end end
end})

Tab3:CreateButton({Name = "Blob Lock", Callback = function()
    local t = findPlayer(H3.BlobTarget)
    if t and t.Character then local b = getBlobman(); if b then blobLock(b, t.Character:FindFirstChild("HumanoidRootPart"), H3.BlobSide) end end
end})

Tab3:CreateSection("All Players Blob")
Tab3:CreateButton({Name = "Grab All (Blob)", Callback = function()
    local b = getBlobman(); if not b then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then task.wait(0.2); blobGrabSide(b, r, H3.BlobSide) end
        end
    end
end})

Tab3:CreateButton({Name = "Kick All (Blob)", Callback = function()
    local b = getBlobman(); if not b then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then task.wait(0.25); blobKickSide(b, r, H3.BlobSide) end
        end
    end
end})

Tab3:CreateSection("Blob Auras")
Tab3:CreateToggle({Name = "Blob Grab Aura", CurrentValue = false, Flag = "H3BGAura", Callback = function(v) H3.BlobGrabAura = v end})
Tab3:CreateToggle({Name = "Blob Kick Aura", CurrentValue = false, Flag = "H3BKAura", Callback = function(v) H3.BlobKickAura = v end})
Tab3:CreateToggle({Name = "Blob Loop Kick", CurrentValue = false, Flag = "H3BLoopK", Callback = function(v) H3.BlobLoopKick = v end})

-- ═══ TARGET KILL ═══
Tab3:CreateSection("Target Kill")

local h3TargetDD = Tab3:CreateDropdown({
    Name = "Target Player", Options = getPlayerList(),
    CurrentOption = {}, MultipleOptions = false, Flag = "H3TargetDD",
    Callback = function(opt) H3.TargetPlayer = Players:FindFirstChild(type(opt) == "table" and opt[1] or opt) end
})

Tab3:CreateButton({Name = "🔄 Refresh Players", Callback = function()
    local list = getPlayerList()
    pcall(function() h3TargetDD:Set(list) end)
end})

Tab3:CreateToggle({Name = "Loop Kill", CurrentValue = false, Flag = "H3LKill", Callback = function(v) H3.LoopKill = v end})
Tab3:CreateToggle({Name = "Loop Void", CurrentValue = false, Flag = "H3LVoid", Callback = function(v) H3.LoopVoid = v end})
Tab3:CreateToggle({Name = "Loop Poison", CurrentValue = false, Flag = "H3LPoison", Callback = function(v) H3.LoopPoison = v end})
Tab3:CreateToggle({Name = "Loop Ragdoll", CurrentValue = false, Flag = "H3LRag", Callback = function(v) H3.LoopRagdoll = v end})
Tab3:CreateToggle({Name = "Loop Death", CurrentValue = false, Flag = "H3LDeath", Callback = function(v) H3.LoopDeath = v end})
Tab3:CreateToggle({Name = "Loop Bring", CurrentValue = false, Flag = "H3LBring", Callback = function(v) H3.LoopBring = v end})
Tab3:CreateToggle({Name = "Loop Pull", CurrentValue = false, Flag = "H3LPull", Callback = function(v) H3.LoopPull = v end})

-- ═══ CAMERA ═══
Tab3:CreateSection("Camera")
Tab3:CreateToggle({Name = "50000 Stud Zoom", CurrentValue = false, Flag = "H3Zoom", Callback = function(v) LP.CameraMaxZoomDistance = v and 50000 or 128 end})

-- ═══ PLAYER ═══
Tab3:CreateSection("Player")
Tab3:CreateSlider({Name = "Speed", Range = {16, 1000}, Increment = 1, CurrentValue = 16, Flag = "H3Speed", Callback = function(v) H3.SpeedVal = v end})
Tab3:CreateToggle({Name = "Speed Boost", CurrentValue = false, Flag = "H3SpeedOn", Callback = function(v) H3.SpeedOn = v end})
Tab3:CreateSlider({Name = "Jump Power", Range = {50, 500}, Increment = 1, CurrentValue = 50, Flag = "H3Jump", Callback = function(v) H3.JumpVal = v end})
Tab3:CreateToggle({Name = "Jump Boost", CurrentValue = false, Flag = "H3JumpOn", Callback = function(v) H3.JumpOn = v end})
Tab3:CreateToggle({Name = "Noclip", CurrentValue = false, Flag = "H3Noclip", Callback = function(v) H3.Noclip = v end})

-- ═══ GRAB LINE ═══
Tab3:CreateSection("Grab Line")
Tab3:CreateToggle({Name = "Chaos Line (Lag)", CurrentValue = false, Flag = "H3Chaos", Callback = function(v) H3.ChaosLine = v end})
Tab3:CreateButton({Name = "Reconnect All Lines", Callback = function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then createLine(r) end
        end
    end
end})

-- ╔═══════════════════════════════════════════════════════════╗
-- ║              TAB 4 — NOOB HUB (Hub 4)                    ║
-- ╚═══════════════════════════════════════════════════════════╝
local Tab4 = Window:CreateTab("Noob Hub", 4483362458)

local H4 = {
    AutoFling = false, FlingPow = 100, FlingRad = 20,
    KillAura = false, KillAuraR = 10,
    SpinBot = false, SpinSpeed = 10,
    SpeedOn = false, WalkSpd = 16,
    JumpOn = false, JumpPow = 50, InfJump = false,
    FlyOn = false, FlySpd = 50,
    NoClip = false,
    GodMode = false, AntiRag = false,
    BringAll = false, Freeze = false,
    Invis = false,
    ESP = false,
    AutoResp = false,
    ChatSpam = false, ChatMsg = "GGOG Hub!",
    tpTarget = nil
}

-- ═══ FLING ═══
Tab4:CreateSection("Fling")
Tab4:CreateToggle({Name = "Auto Fling Nearby", CurrentValue = false, Flag = "H4AutoF", Callback = function(v) H4.AutoFling = v end})
Tab4:CreateSlider({Name = "Fling Power", Range = {10, 99999}, Increment = 10, CurrentValue = 100, Flag = "H4FPow", Callback = function(v) H4.FlingPow = v end})
Tab4:CreateSlider({Name = "Fling Radius", Range = {5, 100}, Increment = 5, CurrentValue = 20, Flag = "H4FRad", Callback = function(v) H4.FlingRad = v end})

Tab4:CreateButton({Name = "Fling All Players", Callback = function()
    local hrp = getHRP(); if not hrp then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local t = p.Character:FindFirstChild("HumanoidRootPart")
            if t then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = (t.Position - hrp.Position).Unit * H4.FlingPow
                bv.Parent = t; Debris:AddItem(bv, 0.5)
            end
        end
    end
end})

Tab4:CreateToggle({Name = "Kill Aura (Fling)", CurrentValue = false, Flag = "H4KillA", Callback = function(v) H4.KillAura = v end})
Tab4:CreateSlider({Name = "Kill Aura Radius", Range = {5, 50}, Increment = 5, CurrentValue = 10, Flag = "H4KAR", Callback = function(v) H4.KillAuraR = v end})
Tab4:CreateToggle({Name = "SpinBot", CurrentValue = false, Flag = "H4Spin", Callback = function(v) H4.SpinBot = v end})
Tab4:CreateSlider({Name = "Spin Speed", Range = {1, 50}, Increment = 1, CurrentValue = 10, Flag = "H4SpinS", Callback = function(v) H4.SpinSpeed = v end})

-- ═══ MOVEMENT ═══
Tab4:CreateSection("Movement")
Tab4:CreateToggle({Name = "Speed Boost", CurrentValue = false, Flag = "H4Speed", Callback = function(v) H4.SpeedOn = v; if not v then pcall(function() getHum().WalkSpeed = 16 end) end end})
Tab4:CreateSlider({Name = "Walk Speed", Range = {16, 500}, Increment = 5, CurrentValue = 16, Flag = "H4WS", Callback = function(v) H4.WalkSpd = v end})
Tab4:CreateToggle({Name = "Jump Boost", CurrentValue = false, Flag = "H4JBoost", Callback = function(v) H4.JumpOn = v; if not v then pcall(function() getHum().JumpPower = 50 end) end end})
Tab4:CreateSlider({Name = "Jump Power", Range = {50, 500}, Increment = 10, CurrentValue = 50, Flag = "H4JP", Callback = function(v) H4.JumpPow = v end})
Tab4:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Flag = "H4InfJ", Callback = function(v) H4.InfJump = v end})
Tab4:CreateToggle({Name = "Fly Mode", CurrentValue = false, Flag = "H4Fly", Callback = function(v) H4.FlyOn = v end})
Tab4:CreateSlider({Name = "Fly Speed", Range = {10, 300}, Increment = 5, CurrentValue = 50, Flag = "H4FlyS", Callback = function(v) H4.FlySpd = v end})
Tab4:CreateToggle({Name = "NoClip", CurrentValue = false, Flag = "H4NC", Callback = function(v) H4.NoClip = v end})

-- ═══ COMBAT ═══
Tab4:CreateSection("Combat")
Tab4:CreateToggle({Name = "God Mode", CurrentValue = false, Flag = "H4God", Callback = function(v)
    H4.GodMode = v
    pcall(function() local h = getHum(); if v then h.MaxHealth = math.huge; h.Health = math.huge else h.MaxHealth = 100; h.Health = 100 end end)
end})
Tab4:CreateToggle({Name = "Anti-Ragdoll", CurrentValue = false, Flag = "H4AntiR", Callback = function(v) H4.AntiRag = v end})
Tab4:CreateToggle({Name = "Bring All", CurrentValue = false, Flag = "H4Bring", Callback = function(v) H4.BringAll = v end})
Tab4:CreateToggle({Name = "Freeze Players", CurrentValue = false, Flag = "H4Freeze", Callback = function(v) H4.Freeze = v end})
Tab4:CreateToggle({Name = "Invisibility", CurrentValue = false, Flag = "H4Invis", Callback = function(v)
    H4.Invis = v
    pcall(function()
        for _, p in pairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = v and 1 or 0 end
            if v and p:IsA("Accessory") then p:Destroy() end
        end
    end)
end})

-- ═══ TELEPORT ═══
Tab4:CreateSection("Teleport")

local h4TpDD = Tab4:CreateDropdown({
    Name = "Select Player", Options = getPlayerList(),
    CurrentOption = {}, MultipleOptions = false, Flag = "H4TpDrop",
    Callback = function(opt) H4.tpTarget = type(opt) == "table" and opt[1] or opt end
})

Tab4:CreateButton({Name = "Teleport to Player", Callback = function()
    if H4.tpTarget then
        local t = Players:FindFirstChild(H4.tpTarget)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local h = getHRP(); if h then h.CFrame = t.Character.HumanoidRootPart.CFrame end
        end
    end
end})

Tab4:CreateButton({Name = "Teleport Random", Callback = function()
    local all = Players:GetPlayers()
    local r = all[math.random(1, #all)]
    if r ~= LP and r.Character then
        local h = getHRP(); local t = r.Character:FindFirstChild("HumanoidRootPart")
        if h and t then h.CFrame = t.CFrame end
    end
end})

-- ═══ VISUALS ═══
Tab4:CreateSection("Visuals")
Tab4:CreateToggle({Name = "Player ESP", CurrentValue = false, Flag = "H4ESP", Callback = function(v) H4.ESP = v end})
Tab4:CreateButton({Name = "Fullbright", Callback = function()
    Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end})

-- ═══ MISC ═══
Tab4:CreateSection("Misc")
Tab4:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Flag = "H4AFK", Callback = function(v)
    if v then LP.Idled:Connect(function()
        pcall(function() local VU = game:GetService("VirtualUser"); VU:CaptureController(); VU:ClickButton2(Vector2.new()) end)
    end) end
end})
Tab4:CreateToggle({Name = "Auto Respawn", CurrentValue = false, Flag = "H4Resp", Callback = function(v) H4.AutoResp = v end})
Tab4:CreateToggle({Name = "Chat Spam", CurrentValue = false, Flag = "H4Chat", Callback = function(v) H4.ChatSpam = v end})
Tab4:CreateInput({Name = "Chat Message", PlaceholderText = "Message...", RemoveTextAfterFocusLost = false, Flag = "H4Msg", Callback = function(v) H4.ChatMsg = v end})
Tab4:CreateButton({Name = "Remove Accessories", Callback = function()
    pcall(function() for _, a in pairs(LP.Character:GetChildren()) do if a:IsA("Accessory") then a:Destroy() end end end)
end})
Tab4:CreateButton({Name = "Reset Character", Callback = function() pcall(function() LP.Character:BreakJoints() end) end})
Tab4:CreateButton({Name = "Destroy GUI", Callback = function() Rayfield:Destroy() end})

-- ╔═══════════════════════════════════════════════════════════╗
-- ║         CONSOLIDATED MAIN LOOPS (NO CONFLICTS)            ║
-- ╚═══════════════════════════════════════════════════════════╝

-- ═══ ONE Stepped (Physics) ═══
RunService.Stepped:Connect(function()
    pcall(function()
        if H2.walkspeed then
            local hrp = getHRP(); local hum = getHum()
            if hrp and hum then
                hrp.CFrame = hrp.CFrame + hum.MoveDirection * (16 * H2.speedMul / 10)
            end
        end
        if H2.noclip then noclipChar(LP.Character) end
    end)
end)

-- ═══ ONE JumpRequest ═══
UIS.JumpRequest:Connect(function()
    if H2.infJump then
        pcall(function()
            local h = getHum()
            if h then
                h:ChangeState(Enum.HumanoidStateType.Freefall)
                task.wait()
                h:ChangeState(Enum.HumanoidStateType.Jumping)
                if h.UseJumpPower == false then
                    h.JumpHeight = math.clamp(H2.jumpPow / 10, 7.2, 50)
                else
                    h.JumpPower = H2.jumpPow
                end
            end
        end)
    end
    if H4.InfJump then
        pcall(function() getHum():ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- ═══ ONE GrabParts Handler ═══
WS.ChildAdded:Connect(function(model)
    if model.Name ~= "GrabParts" or not model:IsA("Model") then return end
    
    local gp = model:FindFirstChild("GrabPart")
    if not gp then return end
    local wc = gp:FindFirstChild("WeldConstraint")
    if not wc or not wc.Part1 then return end
    local target = wc.Part1
    
    -- Hub 2: Kill Grab
    if H2.killGrab then
        pcall(function()
            if target.Parent and target.Parent ~= LP.Character then
                local h = target.Parent:FindFirstChildOfClass("Humanoid")
                if h then h.Health = 0 end
            end
        end)
    end
    
    -- Hub 3: Super Strength
    if H3.SuperStr then
        model:GetPropertyChangedSignal("Parent"):Connect(function()
            if not model.Parent and target and target.Parent then
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
                bv.Velocity = WS.CurrentCamera.CFrame.LookVector * H3.StrPow
                bv.Parent = target
                Debris:AddItem(bv, 0.1)
            end
        end)
    end
    
    -- Hub 3: Grab Effects
    task.spawn(function()
        task.wait(0.1)
        if H3.VoidGrab then setNet(target); addVel(target, Vector3.new(0, 10000, 0)) end
        if H3.KillGrab then setNet(target); moveTo(target, CFrame.new(4096, -75, 4096)); addVel(target, Vector3.new(0, -1000, 0)) end
        if H3.KickGrab then
            local pl = Players:GetPlayerFromCharacter(target.Parent)
            if pl then setNet(target); moveTo(target, CFrame.new(25e25, 25e25, 25e25)); task.wait(0.5); ungrab(target) end
        end
        if H3.AnchorGrab then
            setNet(target); local pos = target.CFrame
            for _ = 1, 2 do
                setNet(target)
                local bp = Instance.new("BodyPosition"); bp.Position = pos.Position; bp.MaxForce = Vector3.new(1e8, 1e8, 1e8); bp.Parent = target
                local bg = Instance.new("BodyGyro"); bg.CFrame = pos; bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8); bg.Parent = target
                task.wait(0.5)
            end
        end
    end)
end)

-- ═══ ONE Heartbeat (Main Loop) ═══
RunService.Heartbeat:Connect(function(dt)
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end
    
    -- ═══ Hub 2: Anti Systems ═══
    if H2.antiGrab then
        pcall(function()
            if LP:FindFirstChild("IsHeld") and LP.IsHeld.Value then
                hrp.Anchored = true
                while LP.IsHeld.Value and H2.antiGrab do StruggleRemote:FireServer(LP); task.wait(0.001) end
                hrp.Anchored = false
            end
        end)
    end
    
    if H2.antiExplode then
        pcall(function()
            local rArm = LP.Character:FindFirstChild("Right Arm")
            if rArm and rArm:FindFirstChild("RagdollLimbPart") and rArm.RagdollLimbPart.CanCollide then
                hrp.Anchored = true
                while rArm:FindFirstChild("RagdollLimbPart") and rArm.RagdollLimbPart.CanCollide do task.wait(0.001) end
                hrp.Anchored = false
            end
        end)
    end
    
    if H2.antiFire then
        pcall(function()
            if hrp:FindFirstChild("FireLight") or hrp:FindFirstChild("FireParticleEmitter") then
                local ep = WS.Map.Hole.PoisonBigHole.ExtinguishPart
                ep.CFrame = CFrame.new(hrp.Position)
            end
        end)
    end
    
    if H2.antiBlobman then
        pcall(function()
            for _, d in pairs(WS:GetDescendants()) do
                if d:IsA("BasePart") and (d.Name == "LeftDetector" or d.Name == "RightDetector") then
                    if (hrp.Position - d.Position).Magnitude > 10 then d:Destroy() end
                end
            end
        end)
    end
    
    -- ═══ Hub 2: Auras ═══
    if H2.launchAura then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local torso = p.Character:FindFirstChild("Torso")
                if torso and (torso.Position - hrp.Position).Magnitude <= H2.auraRadius then
                    pcall(function()
                        setNet(torso, p.Character.HumanoidRootPart.FirePlayerPart.CFrame)
                        task.wait(0.1)
                        local v = torso:FindFirstChild("l") or Instance.new("BodyVelocity", torso)
                        v.Name = "l"; v.Velocity = Vector3.new(0, 2e11, 0); v.MaxForce = Vector3.new(0, math.huge, 0)
                        Debris:AddItem(v, 100)
                    end)
                end
            end
        end
    end
    
    if H2.telekAura then
        local cam = WS.CurrentCamera
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local torso = p.Character:FindFirstChild("Torso")
                if torso and (torso.Position - hrp.Position).Magnitude <= H2.auraRadius then
                    pcall(function()
                        setNet(torso, hrp.CFrame)
                        noclipChar(p.Character)
                        local bp = torso:FindFirstChild("HellAuraPos") or Instance.new("BodyPosition")
                        bp.Name = "HellAuraPos"; bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bp.D = 500; bp.P = 50000; bp.Parent = torso
                        bp.Position = hrp.Position + cam.CFrame.LookVector * 15 + Vector3.new(0, 5, 0)
                    end)
                end
            end
        end
    end
    
    -- ═══ Hub 2: Loop TP ═══
    if H2.loopTP and H2.tpTarget then
        pcall(function()
            local t = Players:FindFirstChild(H2.tpTarget)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = t.Character.HumanoidRootPart.CFrame
            end
        end)
    end
    
    -- ═══ Hub 2: Lag ═══
    if H2.lagOn then
        pcall(function()
            for _ = 1, H2.lagIntensity do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Torso") then
                        CreateLineRem:FireServer(p.Character.Torso, p.Character.Torso.CFrame)
                    end
                end
            end
        end)
    end
    
    -- ═══ Hub 3: Timers ═══
    H3.AuraT = H3.AuraT + dt
    H3.DefT = H3.DefT + dt
    H3.LoopT = H3.LoopT + dt
    H3.ChaosT = H3.ChaosT + dt
    
    -- Hub 3: Defense
    if H3.DefT >= 0.1 then
        if H3.AntiGrab then pcall(function() StruggleRemote:FireServer(LP); RS.GameCorrectionEvents.StopAllVelocity:FireServer() end) end
        if H3.AntiVoid and hrp.Position.Y < -87.5 then hrp.CFrame = CFrame.new(0, 10, 0) end
        if H3.AntiRagdoll and hum:GetState() == Enum.HumanoidStateType.Ragdoll then hum:ChangeState(Enum.HumanoidStateType.Running) end
        H3.DefT = 0
    end
    
    -- Hub 3: Auras
    if H3.AuraT >= 0.5 then
        if H3.KillAura or H3.VoidAura or H3.RagdollAura or H3.NoclipAura or H3.FireAura or H3.AnchorAura then
            pcall(function()
                for _, part in ipairs(WS:GetPartBoundsInRadius(hrp.Position, H3.AuraR)) do
                    if part.Name == "HumanoidRootPart" and not part:IsDescendantOf(LP.Character) then
                        setNet(part)
                        if H3.KillAura then moveTo(part, CFrame.new(4096, -75, 4096)); addVel(part, Vector3.new(0, -1000, 0)) end
                        if H3.VoidAura then addVel(part, Vector3.new(0, 10000, 0)) end
                        if H3.RagdollAura then addVel(part, Vector3.new(0, -256, 0)) end
                        if H3.NoclipAura then part.CanCollide = false end
                        if H3.FireAura then arsonPart(part) end
                        if H3.AnchorAura then
                            local bp = Instance.new("BodyPosition"); bp.Position = part.Position
                            bp.MaxForce = Vector3.new(1e8, 1e8, 1e8); bp.Parent = part; Debris:AddItem(bp, 5)
                        end
                    end
                end
            end)
        end
        if H3.BlobGrabAura or H3.BlobKickAura then
            pcall(function()
                local blob = getBlobman()
                if blob then
                    for _, part in ipairs(WS:GetPartBoundsInRadius(hrp.Position, H3.AuraR)) do
                        if part.Name == "HumanoidRootPart" and not part:IsDescendantOf(LP.Character) then
                            if H3.BlobGrabAura then blobGrabSide(blob, part, H3.BlobSide) end
                            if H3.BlobKickAura then blobKickSide(blob, part, H3.BlobSide) end
                        end
                    end
                end
            end)
        end
        H3.AuraT = 0
    end
    
    -- Hub 3: Player
    if H3.SpeedOn then hum.WalkSpeed = H3.SpeedVal end
    if H3.JumpOn then hum.JumpPower = H3.JumpVal end
    if H3.Noclip then noclipChar(LP.Character) end
    
    -- Hub 3: Target Kill Loops
    if H3.LoopT >= 1.5 then
        if H3.TargetPlayer and H3.TargetPlayer.Character then
            local tp = H3.TargetPlayer
            local r = tp.Character:FindFirstChild("HumanoidRootPart")
            if r then
                if H3.LoopKill then task.spawn(function() snipeFunc(r, function() moveTo(r, CFrame.new(4096, -75, 4096)); addVel(r, Vector3.new(0, -1000, 0)) end) end) end
                if H3.LoopVoid then task.spawn(function() snipeFunc(r, function() addVel(r, Vector3.new(0, 10000, 0)) end) end) end
                if H3.LoopPoison then task.spawn(function() snipeFunc(r, function() moveTo(r, CFrame.new(58, -70, 271)) end) end) end
                if H3.LoopRagdoll then task.spawn(function() snipeFunc(r, function() addVel(r, Vector3.new(0, -64, 0), 0.1) end) end) end
                if H3.LoopDeath then task.spawn(function() snipeFunc(r, function()
                    local h = tp.Character:FindFirstChildOfClass("Humanoid")
                    if h then h:ChangeState(Enum.HumanoidStateType.Dead) end
                    task.wait(0.5); ungrab(r)
                end) end) end
                if H3.LoopBring then task.spawn(function()
                    local pos = hrp.CFrame
                    snipeFunc(r, function() r.CFrame = pos; task.wait(0.5); ungrab(r) end)
                end) end
                if H3.LoopPull then task.spawn(function() snipeFunc(r, function()
                    local bp = Instance.new("BodyPosition"); bp.Name = "PullBP"
                    bp.MaxForce = Vector3.new(1e8, 1e8, 1e8); bp.P = 1e6; bp.D = 1e5; bp.Parent = r
                    task.spawn(function()
                        local start = tick()
                        while bp and bp.Parent and tick() - start < 2 do
                            pcall(function() bp.Position = getHRP().Position; setNet(r) end)
                            task.wait(0.05)
                        end
                    end)
                    task.delay(2, function()
                        if r and r.Parent then
                            local b = r:FindFirstChild("PullBP"); if b then b:Destroy() end
                            ungrab(r)
                        end
                    end)
                end) end) end
            end
        end
        H3.LoopT = 0
    end
    
    -- Hub 3: Chaos Line
    if H3.ChaosLine and H3.ChaosT >= 0.01 then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then createLine(r) end
            end
        end
        H3.ChaosT = 0
    end
    
    -- ═══ Hub 4 ═══
    if H4.SpeedOn then hum.WalkSpeed = H4.WalkSpd end
    if H4.JumpOn then hum.JumpPower = H4.JumpPow end
    if H4.NoClip then noclipChar(LP.Character) end
    if H4.AntiRag and hum:GetState() == Enum.HumanoidStateType.Ragdoll then hum:ChangeState(Enum.HumanoidStateType.Running) end
    
    -- Fly
    if H4.FlyOn then
        local bv = hrp:FindFirstChild("GGOGFly") or Instance.new("BodyVelocity")
        bv.Name = "GGOGFly"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Parent = hrp
        local cam = WS.CurrentCamera; local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * H4.FlySpd or Vector3.zero
    else
        local f = hrp:FindFirstChild("GGOGFly"); if f then f:Destroy() end
    end
    
    -- Auto Fling
    if H4.AutoFling then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local t = p.Character:FindFirstChild("HumanoidRootPart")
                if t and (t.Position - hrp.Position).Magnitude <= H4.FlingRad then
                    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = (t.Position - hrp.Position).Unit * H4.FlingPow; bv.Parent = t; Debris:AddItem(bv, 0.1)
                end
            end
        end
    end
    
    -- Kill Aura Fling
    if H4.KillAura then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local t = p.Character:FindFirstChild("HumanoidRootPart")
                if t and (t.Position - hrp.Position).Magnitude <= H4.KillAuraR then
                    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(0, H4.FlingPow * 2, 0); bv.Parent = t; Debris:AddItem(bv, 0.1)
                end
            end
        end
    end
    
    -- Bring All
    if H4.BringAll then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local t = p.Character:FindFirstChild("HumanoidRootPart")
                if t then t.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 3 end
            end
        end
    end
    
    -- Freeze
    if H4.Freeze then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local t = p.Character:FindFirstChild("HumanoidRootPart")
                if t then t.Anchored = true end
            end
        end
    end
    
    -- SpinBot
    if H4.SpinBot then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(H4.SpinSpeed), 0) end
end)

-- ═══ ESP Loop (Hub 4) ═══
task.spawn(function()
    while true do
        pcall(function()
            if H4.ESP then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and not p.Character:FindFirstChild("GGOGESP") then
                        local esp = Instance.new("BillboardGui"); esp.Name = "GGOGESP"; esp.AlwaysOnTop = true
                        esp.Size = UDim2.new(0, 100, 0, 50); esp.StudsOffset = Vector3.new(0, 3, 0); esp.Parent = p.Character
                        local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 1, 0)
                        f.BackgroundColor3 = Color3.fromRGB(255, 0, 0); f.BackgroundTransparency = 0.5; f.BorderSizePixel = 2; f.Parent = esp
                        local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
                        l.Text = p.Name; l.TextColor3 = Color3.fromRGB(255, 255, 255); l.TextScaled = true; l.Parent = f
                    end
                end
            else
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("GGOGESP") then p.Character.GGOGESP:Destroy() end
                end
            end
        end)
        task.wait(1)
    end
end)

-- ═══ Chat Spam (Hub 4) ═══
task.spawn(function()
    while true do
        if H4.ChatSpam then
            pcall(function() RS.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(H4.ChatMsg, "All") end)
        end
        task.wait(3)
    end
end)

-- ═══ Player List Refresh ═══
local allDropdowns = {h2SelectDD, h2TpDD, h2SbDD, h2BlobDD, h4TpDD}

local function refreshDropdowns()
    task.wait(0.5)
    local list = getPlayerList()
    for _, dd in pairs(allDropdowns) do
        pcall(function() dd:Set(list) end)
    end
    pcall(function() h3TargetDD:Set(list) end)
end

Players.PlayerAdded:Connect(refreshDropdowns)
Players.PlayerRemoving:Connect(function(p)
    if H3.TargetPlayer == p then H3.TargetPlayer = nil end
    refreshDropdowns()
end)

-- ═══ Character Added ═══
LP.CharacterAdded:Connect(function(c)
    playerChar = c
    refreshDropdowns()
    -- Hub 4: Auto Respawn reconnect
    pcall(function()
        c:WaitForChild("Humanoid").Died:Connect(function()
            if H4.AutoResp then task.wait(1); pcall(function() LP:LoadCharacter() end) end
        end)
    end)
end)

-- ═══ Initial Humanoid Died ═══
pcall(function()
    getHum().Died:Connect(function()
        if H4.AutoResp then task.wait(1); pcall(function() LP:LoadCharacter() end) end
    end)
end)

-- ════════════════════════════════════════════════════════════
-- LOADED
-- ════════════════════════════════════════════════════════════
Rayfield:Notify({
    Title = "GGOG Hub Loaded!",
    Content = "4 Hubs: Cosmic | CosmicV2 | Egg | Noob\nAll features active!",
    Duration = 5
})

print("═══════════════════════════════════")
print("  GGOG Hub — Full Load Complete!")
print("  Tab 1: Cosmic Hub (All Features)")
print("  Tab 2: Cosmic V2 (All Features)")
print("  Tab 3: Egg Hub (All Features)")
print("  Tab 4: Noob Hub (All Features)")
print("═══════════════════════════════════")
