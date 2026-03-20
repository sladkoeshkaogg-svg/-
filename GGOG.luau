-- ╔════════════════════════════════════════════════════════════════╗
-- ║                    💀 DMM HUB | FTAP                          ║
-- ╚════════════════════════════════════════════════════════════════╝

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "💀 | DMM HUB",
    LoadingTitle = "DMM HUB",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DMMHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

-- =====================
-- SERVICES
-- =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- =====================
-- UTILS
-- =====================
local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHRP()
    local char = GetChar()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local char = GetChar()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- =====================
-- SHARED VARIABLES
-- =====================
local Flying = false
local IsTeleporting = false
local LastInputTime = tick()
local PositionHistory = {}
local AntiGrabEnabled = false
local AntiDetectedEnabled = false

local MovementKeys = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true,
    [Enum.KeyCode.LeftShift] = true,
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if MovementKeys[input.KeyCode] then
            LastInputTime = tick()
        end
    end
end)

-- =====================
-- POSITION HISTORY
-- =====================
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
        Time = tick(),
        CFrame = hrp.CFrame
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

local function TeleportBack(seconds)
    local hrp = GetHRP()
    if not hrp then return false end
    local safeData = GetPositionSecondsAgo(seconds)
    if safeData then
        IsTeleporting = true
        hrp.CFrame = safeData.CFrame
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        local hum = GetHum()
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end
        end
        task.defer(function()
            task.wait(0.4)
            IsTeleporting = false
        end)
        return true
    end
    return false
end

-- ======================================================
-- TAB: HOME (ПЕРВАЯ ВКЛАДКА)
-- ======================================================
local HomeTab = Window:CreateTab("Home", 4483362458)

HomeTab:CreateSection("💀 Welcome to DMM HUB")

HomeTab:CreateParagraph({
    Title = "💀 DMM HUB v1.0",
    Content = "Game: Fling Things and People\n\nFly = WASD + Space/Shift\nLag Speed = Toggle + LMB clicks\nAnti Grab = TP back when grabbed\nAnti Detected = Auto return\n\nEnjoy! 💀"
})

HomeTab:CreateLabel("Game: Fling Things and People")
HomeTab:CreateLabel("Players Online: " .. #Players:GetPlayers())

HomeTab:CreateSection("Quick Actions")

HomeTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

HomeTab:CreateButton({
    Name = "🌐 Server Hop",
    Callback = function()
        pcall(function()
            local Http = game:GetService("HttpService")
            local data = Http:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            ))
            for _, server in pairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end,
})

HomeTab:CreateButton({
    Name = "📋 Copy Game Link",
    Callback = function()
        pcall(function()
            setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
        end)
        Rayfield:Notify({Title = "DMM HUB", Content = "Link copied!", Duration = 2})
    end,
})

HomeTab:CreateSection("Anti AFK")

local AntiAFKEnabled = false
HomeTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        AntiAFKEnabled = Value
    end,
})

LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
    end
end)

-- ======================================================
-- TAB: PLAYER
-- ======================================================
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- =====================
-- КЛАССИЧЕСКИЙ FLY (BodyVelocity + BodyGyro)
-- =====================
PlayerTab:CreateSection("Fly")

local FlySpeed = 100
local FlyConnection = nil
local FlyBV = nil
local FlyBG = nil

local function StartFly()
    local char = GetChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")

    if hrp:FindFirstChild("FlyBV") then hrp:FindFirstChild("FlyBV"):Destroy() end
    if hrp:FindFirstChild("FlyBG") then hrp:FindFirstChild("FlyBG"):Destroy() end

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "FlyBV"
    FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyBV.Velocity = Vector3.new(0, 0, 0)
    FlyBV.Parent = hrp

    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "FlyBG"
    FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyBG.P = 9e4
    FlyBG.D = 500
    FlyBG.CFrame = hrp.CFrame
    FlyBG.Parent = hrp

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying then return end

        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        local currentHRP = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHRP then return end

        local camera = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            FlyBV.Velocity = moveDir.Unit * FlySpeed
        else
            FlyBV.Velocity = Vector3.new(0, 0, 0)
        end

        FlyBG.CFrame = camera.CFrame
    end)
end

local function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("FlyBV")
            local bg = hrp:FindFirstChild("FlyBG")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    FlyBV = nil
    FlyBG = nil
end

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Flying = Value
        if Value then
            StartFly()
        else
            StopFly()
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 10,
    Suffix = " studs/s",
    CurrentValue = 100,
    Flag = "FlySpeed",
    Callback = function(Value)
        FlySpeed = Value
    end,
})

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Flying then
        StopFly()
        task.wait(0.3)
        StartFly()
    end
end)

-- =====================
-- LAG SPEED
-- =====================
PlayerTab:CreateSection("Lag Speed ⚡")

local LagSpeedEnabled = false
local LagSpeedValue = 100

task.spawn(function()
    while task.wait() do
        if LagSpeedEnabled then
            local clicksThisFrame = math.min(LagSpeedValue, 1000)

            for i = 1, clicksThisFrame do
                pcall(function()
                    mouse1click()
                end)

                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end)
            end

            local delay = 1 / (LagSpeedValue / clicksThisFrame)
            if delay < 0.001 then
                task.wait()
            else
                task.wait(delay)
            end
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Lag Speed ⚡",
    CurrentValue = false,
    Flag = "LagSpeed",
    Callback = function(Value)
        LagSpeedEnabled = Value
    end,
})

PlayerTab:CreateSlider({
    Name = "Clicks Per Second",
    Range = {1, 100000},
    Increment = 1,
    Suffix = " CPS",
    CurrentValue = 100,
    Flag = "LagSpeedCPS",
    Callback = function(Value)
        LagSpeedValue = Value
    end,
})

-- =====================
-- AUTO RESET
-- =====================
PlayerTab:CreateSection("Auto Reset")

local AutoResetEnabled = false
local AutoResetDelay = 1

task.spawn(function()
    while task.wait(0.1) do
        if AutoResetEnabled then
            local hum = GetHum()
            if hum then
                hum.Health = 0
            end
            task.wait(AutoResetDelay)
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Auto Reset",
    CurrentValue = false,
    Flag = "AutoReset",
    Callback = function(Value)
        AutoResetEnabled = Value
    end,
})

PlayerTab:CreateSlider({
    Name = "Reset Delay",
    Range = {0, 10},
    Increment = 1,
    Suffix = " sec",
    CurrentValue = 1,
    Flag = "AutoResetDelay",
    Callback = function(Value)
        AutoResetDelay = Value
    end,
})

-- =====================
-- ANTI-GRAB [BETA] OP
-- =====================
PlayerTab:CreateSection("Anti-Grab [BETA] 🔴OP")

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
        if tick() - LastInputTime > 0.15 then
            local animName = ""
            pcall(function()
                animName = track.Animation and track.Animation.Name or ""
            end)
            local lowerName = string.lower(animName)
            local safeAnims = {
                "idle","walk","run","jump","fall","climb",
                "sit","swim","tool","wave","point","dance",
                "cheer","laugh","tilt","movedirection"
            }
            local isSafe = false
            for _, s in ipairs(safeAnims) do
                if string.find(lowerName, s) then isSafe = true break end
            end
            local grabWords = {
                "grab","hold","carry","punch","stun","ragdoll",
                "knock","sleep","drag","pull","throw","slam",
                "choke","bind","tie","capture","arrest","cuff",
                "kill","eat","swallow","consume","caught",
                "trapped","picked","lifted","fling","toss","crush"
            }
            local isGrab = false
            for _, g in ipairs(grabWords) do
                if string.find(lowerName, g) then isGrab = true break end
            end
            local suspPriority = (
                track.Priority == Enum.AnimationPriority.Action or
                track.Priority == Enum.AnimationPriority.Action2 or
                track.Priority == Enum.AnimationPriority.Action3 or
                track.Priority == Enum.AnimationPriority.Action4
            )
            if isGrab or (suspPriority and not isSafe) then
                track:Stop(0)
                TeleportBack(3)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    SetupAntiGrabAnimTracker(char)
end)
if LocalPlayer.Character then
    SetupAntiGrabAnimTracker(LocalPlayer.Character)
end

PlayerTab:CreateToggle({
    Name = "Anti-Grab [BETA] 🔴OP",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        AntiGrabEnabled = Value
        if Value then PositionHistory = {} end
    end,
})

-- =====================
-- ANTI DETECTED [BETA Hacker]
-- =====================
PlayerTab:CreateSection("Anti Detected [BETA Hacker]")

local AntiDetectedCooldown = false

RunService.Heartbeat:Connect(function()
    if not AntiDetectedEnabled then return end
    if Flying or IsTeleporting or AntiDetectedCooldown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local timeSinceInput = tick() - LastInputTime
    local vel = hrp.AssemblyLinearVelocity
    local hSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
    local fSpeed = vel.Magnitude
    local detected = false
    if hSpeed > 18 and timeSinceInput > 0.1 then detected = true end
    if fSpeed > 50 and timeSinceInput > 0.08 then detected = true end
    if detected then
        AntiDetectedCooldown = true
        local success = TeleportBack(7)
        if success then
            Rayfield:Notify({
                Title = "🛡️ Anti Kick+Hacker [BETA Ultra OP]",
                Content = "⚡ Принудительное перемещение!\nВозврат на 7 секунд назад.",
                Duration = 3,
                Image = 4483362458
            })
        end
        task.defer(function()
            task.wait(0.5)
            AntiDetectedCooldown = false
        end)
    end
end)

PlayerTab:CreateToggle({
    Name = "Anti Detected [BETA Hacker]",
    CurrentValue = false,
    Flag = "AntiDetected",
    Callback = function(Value)
        AntiDetectedEnabled = Value
        if Value then
            PositionHistory = {}
            Rayfield:Notify({
                Title = "🛡️ Anti Detected",
                Content = "Активировано!",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- =====================
-- MOVEMENT
-- =====================
PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local hum = GetHum()
        if hum then hum.WalkSpeed = Value end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    Suffix = " power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        local hum = GetHum()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end
    end,
})

local InfJump = false
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        InfJump = Value
    end,
})

UserInputService.JumpRequest:Connect(function()
    if InfJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local NoclipEnabled = false
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        NoclipEnabled = Value
    end,
})

RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

PlayerTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.FogEnd = 1000000
        else
            Lighting.Brightness = 2
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            Lighting.FogEnd = 5000
        end
    end,
})

PlayerTab:CreateButton({
    Name = "God Mode (Max HP)",
    Callback = function()
        local hum = GetHum()
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local hum = GetHum()
        if hum then hum.Health = 0 end
    end,
})

-- ======================================================
-- TAB: ESP
-- ======================================================
local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateSection("Wallhack")

local ESP_ENABLED = false
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

local function ApplyESPToPlayer(player)
    if player == LocalPlayer then return end
    local function DoESP(character)
        if not character then return end
        local old = character:FindFirstChild("ESP_Highlight")
        if old then old:Destroy() end
        if ESP_ENABLED then
            local h = Instance.new("Highlight")
            h.Name = "ESP_Highlight"
            h.FillColor = ESP_COLOR
            h.OutlineColor = Color3.new(1, 1, 1)
            h.FillTransparency = 0.5
            h.Parent = character
            local head = character:FindFirstChild("Head")
            if head and not head:FindFirstChild("ESP_Name") then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ESP_Name"
                bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0, 200, 0, 50)
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.Parent = head
                local txt = Instance.new("TextLabel")
                txt.Name = "NameLabel"
                txt.Size = UDim2.new(1, 0, 0.5, 0)
                txt.BackgroundTransparency = 1
                txt.Text = player.Name
                txt.TextColor3 = ESP_COLOR
                txt.TextStrokeTransparency = 0
                txt.TextScaled = true
                txt.Font = Enum.Font.GothamBold
                txt.Parent = bb
                local dist = Instance.new("TextLabel")
                dist.Name = "DistLabel"
                dist.Size = UDim2.new(1, 0, 0.5, 0)
                dist.Position = UDim2.new(0, 0, 0.5, 0)
                dist.BackgroundTransparency = 1
                dist.Text = "0m"
                dist.TextColor3 = Color3.new(1, 1, 1)
                dist.TextStrokeTransparency = 0
                dist.TextScaled = true
                dist.Font = Enum.Font.Gotham
                dist.Parent = bb
            end
        end
    end
    if player.Character then DoESP(player.Character) end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if ESP_ENABLED then DoESP(char) end
    end)
end

RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then return end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local bb = head:FindFirstChild("ESP_Name")
                if bb then
                    local dl = bb:FindFirstChild("DistLabel")
                    if dl then
                        local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if tHRP then
                            dl.Text = "["..math.floor((myHRP.Position - tHRP.Position).Magnitude).."m]"
                        end
                    end
                end
            end
        end
    end
end)

ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESP_ENABLED = Value
        for _, p in pairs(Players:GetPlayers()) do ApplyESPToPlayer(p) end
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local h = p.Character:FindFirstChild("ESP_Highlight")
                    if h then h:Destroy() end
                    local head = p.Character:FindFirstChild("Head")
                    if head then
                        local bb = head:FindFirstChild("ESP_Name")
                        if bb then bb:Destroy() end
                    end
                end
            end
        end
    end,
})

Players.PlayerAdded:Connect(function(p)
    if ESP_ENABLED then ApplyESPToPlayer(p) end
end)

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        ESP_COLOR = Value
        if ESP_ENABLED then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local h = p.Character:FindFirstChild("ESP_Highlight")
                    if h then h.FillColor = Value end
                end
            end
        end
    end,
})

-- ======================================================
-- TAB: TELEPORT
-- ======================================================
local TPTab = Window:CreateTab("Teleport", 4483362458)
TPTab:CreateSection("Teleport System")

local ClickTP = false
TPTab:CreateToggle({
    Name = "Click TP (Ctrl + Click)",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value) ClickTP = Value end,
})

Mouse.Button1Down:Connect(function()
    if ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        IsTeleporting = true
        local hrp = GetHRP()
        if hrp and Mouse.Hit then
            hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
        task.defer(function() task.wait(0.5) IsTeleporting = false end)
    end
end)

TPTab:CreateSection("Teleport to Player")

local SelectedTPPlayer = nil
local PList = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(PList, p.Name) end
end

local TPDrop = TPTab:CreateDropdown({
    Name = "Select Player",
    Options = PList,
    CurrentOption = "",
    Flag = "TPSelect",
    Callback = function(Option) SelectedTPPlayer = Option end,
})

local function RefreshPList()
    local n = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(n, p.Name) end
    end
    pcall(function() TPDrop:Refresh(n, true) end)
end
Players.PlayerAdded:Connect(RefreshPList)
Players.PlayerRemoving:Connect(RefreshPList)

TPTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if SelectedTPPlayer then
            IsTeleporting = true
            local t = Players:FindFirstChild(SelectedTPPlayer)
            if t and t.Character then
                local tHRP = t.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = GetHRP()
                if tHRP and myHRP then
                    myHRP.CFrame = tHRP.CFrame + Vector3.new(3, 0, 0)
                end
            end
            task.defer(function() task.wait(0.5) IsTeleporting = false end)
        end
    end,
})

TPTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- ======================================================
-- TAB: SETTINGS
-- ======================================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Hub Settings")

SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Flying = false
        StopFly()
        AntiGrabEnabled = false
        AntiDetectedEnabled = false
        LagSpeedEnabled = false
        AutoResetEnabled = false
        Rayfield:Destroy()
    end,
})

SettingsTab:CreateParagraph({
    Title = "💀 DMM HUB v1.0",
    Content = "Fly = WASD + Space/Shift (BodyVelocity)\nLag Speed = Toggle + LMB = clicks\nAuto Reset = Auto reset character\nAnti Grab = TP back when grabbed\nAnti Detected = Return on forced movement"
})

SettingsTab:CreateLabel("Version 1.0 | DMM HUB")

-- ======================================================
-- LOADED NOTIFICATION
-- ======================================================
Rayfield:Notify({
    Title = "💀 DMM HUB",
    Content = "Successfully loaded! Enjoy 🎉",
    Duration = 5,
    Image = 4483362458
})

print("═══════════════════════════════")
print("  💀 DMM HUB — Loaded!")
print("  Fling Things and People")
print("═══════════════════════════════")
