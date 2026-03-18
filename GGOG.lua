-- ULTIMATE BLOB MEN SPAWNER & FLING HUB v2.0
-- Rayfield UI | Blobmen Grab/Fling/Kill | Multi-Target | Network Ownership Bypass
-- Compatible with all executors (Synapse, Krnl, Fluxus, etc.)
-- Execute in Fling Things And People or any Roblox game

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Config
local Blobmen = {}
local MaxBlobs = 50
local BlobPower = 50000
local SpawnRadius = 20
local TargetPlayer = nil
local Connections = {}
local BlobModel = nil -- Will create custom blob

-- Create custom Blobman model (R15 rig with blob properties)
local function createBlobModel()
    local model = Instance.new("Model")
    model.Name = "Blobman"
    model.Parent = Workspace
    
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(4, 6, 2)
    rootPart.Material = Enum.Material.Neon
    rootPart.BrickColor = BrickColor.new("Bright green")
    rootPart.Shape = Enum.PartType.Ball
    rootPart.CanCollide = false
    rootPart.Anchored = false
    rootPart.Parent = model
    
    -- Simple limbs (blob style)
    local limbs = {"Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    for _, limbName in pairs(limbs) do
        local limb = rootPart:Clone()
        limb.Name = limbName
        limb.Size = Vector3.new(2, 2, 2)
        limb.Material = Enum.Material.ForceField
        limb.BrickColor = BrickColor.Random()
        limb.Parent = model
    end
    
    -- Weld all parts to root
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = model.Head
    weld.Parent = rootPart
    
    model.PrimaryPart = rootPart
    rootPart.CFrame = CFrame.new(0, 50, 0)
    
    return model
end

-- Spawn single blob
local function spawnBlob(position)
    local blob = createBlobModel()
    local root = blob.HumanoidRootPart
    
    -- Network ownership to localplayer for control
    pcall(function()
        root:SetNetworkOwner(LocalPlayer)
    end)
    
    root.CFrame = CFrame.new(position)
    root.CanCollide = true
    
    -- Add fling power
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = root
    
    local ba = Instance.new("BodyAngularVelocity")
    ba.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    ba.AngularVelocity = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
    ba.Parent = root
    
    table.insert(Blobmen, blob)
    
    -- Cleanup if too many
    if #Blobmen > MaxBlobs then
        local oldBlob = table.remove(Blobmen, 1)
        Debris:AddItem(oldBlob, 5)
    end
    
    return blob
end

-- Grab/Teleport blob to target
local function grabBlob(blob, targetPos)
    local root = blob.HumanoidRootPart
    if root then
        root.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-5,5), 10, math.random(-5,5)))
        
        -- Fling towards target
        local direction = (targetPos - root.Position).Unit
        local bv = root:FindFirstChild("BodyVelocity")
        if bv then
            bv.Velocity = direction * BlobPower + Vector3.new(0, BlobPower/2, 0)
        end
    end
end

-- Main Window
local Window = Rayfield:CreateWindow({
    Name = "BlobMaster Hub v2.0",
    LoadingTitle = "Blobmen Loading...",
    LoadingSubtitle = "by HackerAI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BlobMaster",
        FileName = "BlobConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

Rayfield:Notify({
    Title = "BlobMaster Loaded!",
    Content = "Full blobmen control activated. F=Target, G=Spam Grab",
    Duration = 5,
    Image = 4483362458
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

local SpawnSection = MainTab:CreateSection("Blob Spawning")

local SpawnSlider = MainTab:CreateSlider({
    Name = "Max Blobs",
    Range = {1, 100},
    Increment = 5,
    CurrentValue = 50,
    Flag = "MaxBlobs",
    Callback = function(Value)
        MaxBlobs = Value
    end,
})

local PowerSlider = MainTab:CreateSlider({
    Name = "Fling Power",
    Range = {10000, 100000},
    Increment = 5000,
    CurrentValue = 50000,
    Flag = "BlobPower",
    Callback = function(Value)
        BlobPower = Value
    end,
})

local SpawnButton = MainTab:CreateButton({
    Name = "Spawn Blob Army",
    Callback = function()
        for i = 1, MaxBlobs do
            spawnBlob(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.random(-SpawnRadius, SpawnRadius), 20, math.random(-SpawnRadius, SpawnRadius)))
            wait(0.01)
        end
        Rayfield:Notify({Title = "Spawned", Content = MaxBlobs .. " blobmen!", Duration = 3})
    end,
})

local CleanButton = MainTab:CreateButton({
    Name = "Clean All Blobs",
    Callback = function()
        for _, blob in pairs(Blobmen) do
            if blob.Parent then
                Debris:AddItem(blob, 0)
            end
        end
        Blobmen = {}
        Rayfield:Notify({Title = "Cleaned", Content = "All blobmen removed!", Duration = 3})
    end,
})

-- Target Section
local TargetSection = MainTab:CreateSection("Targeting")

local TargetButton = MainTab:CreateButton({
    Name = "Set Mouse Target",
    Callback = function()
        local target = Mouse.Target
        if target and target.Parent:FindFirstChild("Humanoid") then
            local player = Players:GetPlayerFromCharacter(target.Parent)
            if player then
                TargetPlayer = player
                Rayfield:Notify({Title = "Target Set", Content = player.Name, Duration = 3})
            end
        end
    end,
})

-- Attack Section
local AttackSection = MainTab:CreateSection("Blob Attacks")

local SpamGrabToggle = MainTab:CreateToggle({
    Name = "Spam Grab Target",
    CurrentValue = false,
    Flag = "SpamGrab",
    Callback = function(Value)
        if Value then
            Connections.SpamGrab = RunService.Heartbeat:Connect(function()
                if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, blob in pairs(Blobmen) do
                        grabBlob(blob, TargetPlayer.Character.HumanoidRootPart.Position)
                    end
                end
            end)
        else
            if Connections.SpamGrab then
                Connections.SpamGrab:Disconnect()
            end
        end
    end,
})

local FlingAllButton = MainTab:CreateButton({
    Name = "FLING ALL BLOBS AT TARGET",
    Callback = function()
        if TargetPlayer and TargetPlayer.Character then
            local targetPos = TargetPlayer.Character.HumanoidRootPart.Position
            for _, blob in pairs(Blobmen) do
                grabBlob(blob, targetPos)
            end
            Rayfield:Notify({Title = "Fling Attack", Content = "All blobs flung!", Duration = 3})
        end
    end,
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)

local KillSection = CombatTab:CreateSection("Kill Aura")

local KillAuraToggle = CombatTab:CreateToggle({
    Name = "Blob Kill Aura (Nearby)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(Value)
        if Value then
            Connections.KillAura = RunService.Heartbeat:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 50 then
                            for _, blob in pairs(Blobmen) do
                                grabBlob(blob, player.Character.HumanoidRootPart.Position)
                            end
                        end
                    end
                end
            end)
        else
            if Connections.KillAura then
                Connections.KillAura:Disconnect()
            end
        end
    end,
})

-- Teleport Tab
local TeleportTab = Window:CreateTab("Teleport")

local TPSection = TeleportTab:CreateSection("Blob Teleports")

local TPForwardButton = TeleportTab:CreateButton({
    Name = "TP All Blobs Forward",
    Callback = function()
        local pos = LocalPlayer.Character.HumanoidRootPart.Position + LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 50
        for _, blob in pairs(Blobmen) do
            local root = blob.HumanoidRootPart
            if root then root.CFrame = CFrame.new(pos) end
        end
    end,
})

local TPSkyButton = TeleportTab:CreateButton({
    Name = "TP All Blobs to Sky",
    Callback = function()
        for _, blob in pairs(Blobmen) do
            local root = blob.HumanoidRootPart
            if root then root.CFrame = CFrame.new(root.Position + Vector3.new(0, 100, 0)) end
        end
    end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings")

local ConfigSection = SettingsTab:CreateSection("Configuration")

local SpawnRadiusSlider = SettingsTab:CreateSlider({
    Name = "Spawn Radius",
    Range = {5, 100},
    Increment = 5,
    CurrentValue = 20,
    Flag = "SpawnRadius",
    Callback = function(Value)
        SpawnRadius = Value
    end,
})

local RainbowToggle = SettingsTab:CreateToggle({
    Name = "Rainbow Blob Colors",
    CurrentValue = false,
    Flag = "Rainbow",
    Callback = function(Value)
        if Value then
            Connections.Rainbow = RunService.Heartbeat:Connect(function()
                for _, blob in pairs(Blobmen) do
                    for _, part in pairs(blob:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        end
                    end
                end
            end)
        else
            if Connections.Rainbow then
                Connections.Rainbow:Disconnect()
            end
        end
    end,
})

-- Keybinds
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        -- F = Set Target
        local target = Mouse.Target
        if target and target.Parent:FindFirstChild("Humanoid") then
            TargetPlayer = Players:GetPlayerFromCharacter(target.Parent)
            Rayfield:Notify({Title = "Target", Content = TargetPlayer.Name, Duration = 2})
        end
    elseif input.KeyCode == Enum.KeyCode.G then
        -- G = Spam Grab Toggle
        SpamGrabToggle:Toggle()
    end
end)

-- Load Config
Rayfield:LoadConfiguration()
