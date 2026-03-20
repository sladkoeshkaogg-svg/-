-- ╔════════════════════════════════════════════════════════════════╗
-- ║              💀 DMM HUB — Custom UI | FTAP                    ║
-- ║           Dark-White Theme | Mobile + PC Friendly             ║
-- ╚════════════════════════════════════════════════════════════════╝

-- =====================
-- SERVICES
-- =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local IsMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)

-- =====================
-- DESTROY OLD GUI
-- =====================
if CoreGui:FindFirstChild("DMM_HUB") then
    CoreGui:FindFirstChild("DMM_HUB"):Destroy()
end

-- =====================
-- THEME
-- =====================
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(14, 14, 18),
    TopBar = Color3.fromRGB(22, 22, 28),
    Card = Color3.fromRGB(28, 28, 35),
    CardHover = Color3.fromRGB(35, 35, 44),
    Accent = Color3.fromRGB(255, 255, 255),
    AccentDim = Color3.fromRGB(180, 180, 180),
    TextPrimary = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(150, 150, 160),
    ToggleOn = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(60, 60, 70),
    SliderFill = Color3.fromRGB(255, 255, 255),
    SliderBg = Color3.fromRGB(40, 40, 50),
    Border = Color3.fromRGB(45, 45, 55),
    Shadow = Color3.fromRGB(0, 0, 0),
    Danger = Color3.fromRGB(255, 70, 70),
    Success = Color3.fromRGB(70, 255, 130),
    TabActive = Color3.fromRGB(255, 255, 255),
    TabInactive = Color3.fromRGB(90, 90, 100),
    Font = Enum.Font.GothamBold,
    FontLight = Enum.Font.Gotham,
}

-- =====================
-- TWEEN HELPER
-- =====================
local function Tween(obj, props, dur, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- =====================
-- SCREENGU
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DMM_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- =====================
-- MAIN FRAME
-- =====================
local WinWidth = IsMobile and 360 or 580
local WinHeight = IsMobile and 420 or 440
local SidebarWidth = IsMobile and 48 or 150

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, WinWidth, 0, WinHeight)
MainFrame.Position = UDim2.new(0.5, -WinWidth/2, 0.5, -WinHeight/2)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

-- =====================
-- DRAG SYSTEM (PC + MOBILE)
-- =====================
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

-- Нижний фикс для топбара (чтобы не было скругления снизу)
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 12)
TopFix.Position = UDim2.new(0, 0, 1, -12)
TopFix.BackgroundColor3 = Theme.TopBar
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "💀 DMM HUB"
TitleLabel.TextColor3 = Theme.TextPrimary
TitleLabel.TextSize = 16
TitleLabel.Font = Theme.Font
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -36, 0, 3)
CloseBtn.BackgroundColor3 = Theme.Card
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Danger
CloseBtn.TextSize = 16
CloseBtn.Font = Theme.Font
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 8)
CloseBtnCorner.Parent = CloseBtn

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -72, 0, 3)
MinBtn.BackgroundColor3 = Theme.Card
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.AccentDim
MinBtn.TextSize = 16
MinBtn.Font = Theme.Font
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 8)
MinBtnCorner.Parent = MinBtn

-- Drag
local Dragging, DragStart, StartPos

local function DragInput(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - DragStart
        local newPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        Tween(MainFrame, {Position = newPos}, 0.08)
    end
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if Dragging then DragInput(input) end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging then DragInput(input) end
end)

-- Close / Minimize
local Minimized = false
local OrigSize = MainFrame.Size

CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Size = UDim2.new(0, WinWidth, 0, 0)}, 0.3)
    task.wait(0.3)
    ScreenGui:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        Tween(MainFrame, {Size = UDim2.new(0, WinWidth, 0, 38)}, 0.3)
        MinBtn.Text = "+"
    else
        Tween(MainFrame, {Size = UDim2.new(0, WinWidth, 0, WinHeight)}, 0.3)
        MinBtn.Text = "—"
    end
end)

-- =====================
-- SIDEBAR
-- =====================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = Theme.Border
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Size = UDim2.new(1, 0, 1, -8)
SideScroll.Position = UDim2.new(0, 0, 0, 4)
SideScroll.BackgroundTransparency = 1
SideScroll.ScrollBarThickness = 0
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SideScroll.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 4)
SideLayout.Parent = SideScroll

local SidePad = Instance.new("UIPadding")
SidePad.PaddingLeft = UDim.new(0, 6)
SidePad.PaddingRight = UDim.new(0, 6)
SidePad.PaddingTop = UDim.new(0, 6)
SidePad.Parent = SideScroll

-- =====================
-- CONTENT AREA
-- =====================
local ContentArea = Instance.new("Frame")
ContentArea.Name = "Content"
ContentArea.Size = UDim2.new(1, -SidebarWidth, 1, -38)
ContentArea.Position = UDim2.new(0, SidebarWidth, 0, 38)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- =====================
-- TAB SYSTEM
-- =====================
local Tabs = {}
local ActiveTab = nil
local TabContents = {}

local function CreateTab(name, icon, order)
    -- Sidebar button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name
    TabBtn.Size = UDim2.new(1, 0, 0, IsMobile and 38 or 36)
    TabBtn.BackgroundColor3 = Theme.Sidebar
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.LayoutOrder = order or 0
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = SideScroll

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 8)
    TabBtnCorner.Parent = TabBtn

    -- Indicator bar (left side)
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0, 0)
    Indicator.Position = UDim2.new(0, -3, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Parent = TabBtn

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 2)
    IndCorner.Parent = Indicator

    local IconLabel
    if IsMobile then
        -- Mobile: icon only
        IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(1, 0, 1, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = icon or "?"
        IconLabel.TextColor3 = Theme.TabInactive
        IconLabel.TextSize = 18
        IconLabel.Font = Theme.Font
        IconLabel.Parent = TabBtn
    else
        -- PC: icon + name
        IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(0, 24, 1, 0)
        IconLabel.Position = UDim2.new(0, 10, 0, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = icon or "?"
        IconLabel.TextColor3 = Theme.TabInactive
        IconLabel.TextSize = 16
        IconLabel.Font = Theme.Font
        IconLabel.Parent = TabBtn

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Name = "TabName"
        NameLabel.Size = UDim2.new(1, -44, 1, 0)
        NameLabel.Position = UDim2.new(0, 38, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = name
        NameLabel.TextColor3 = Theme.TabInactive
        NameLabel.TextSize = 13
        NameLabel.Font = Theme.Font
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = TabBtn
    end

    -- Content scroll
    local Content = Instance.new("ScrollingFrame")
    Content.Name = name .. "_Content"
    Content.Size = UDim2.new(1, -8, 1, -8)
    Content.Position = UDim2.new(0, 4, 0, 4)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Theme.AccentDim
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.Visible = false
    Content.Parent = ContentArea

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 6)
    ContentLayout.Parent = Content

    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingLeft = UDim.new(0, 8)
    ContentPad.PaddingRight = UDim.new(0, 8)
    ContentPad.PaddingTop = UDim.new(0, 6)
    ContentPad.PaddingBottom = UDim.new(0, 6)
    ContentPad.Parent = Content

    local tabData = {
        Button = TabBtn,
        Content = Content,
        Indicator = Indicator,
        IconLabel = IconLabel,
        Name = name,
        Elements = {},
        LayoutOrder = 0,
    }

    table.insert(Tabs, tabData)
    TabContents[name] = tabData

    -- Switch tab
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            Tween(t.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
            t.IconLabel.TextColor3 = Theme.TabInactive
            if t.Button:FindFirstChild("TabName") then
                t.Button.TabName.TextColor3 = Theme.TabInactive
            end
            Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
        end
        tabData.Content.Visible = true
        Tween(tabData.Indicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.2)
        tabData.IconLabel.TextColor3 = Theme.TabActive
        if tabData.Button:FindFirstChild("TabName") then
            tabData.Button.TabName.TextColor3 = Theme.TabActive
        end
        Tween(tabData.Button, {BackgroundTransparency = 0.9}, 0.2)
        ActiveTab = tabData
    end)

    -- Hover
    TabBtn.MouseEnter:Connect(function()
        if ActiveTab ~= tabData then
            Tween(TabBtn, {BackgroundTransparency = 0.92}, 0.15)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if ActiveTab ~= tabData then
            Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
        end
    end)

    return tabData
end

-- =====================
-- ELEMENT CREATORS
-- =====================
local ElementOrder = 0

local function NextOrder()
    ElementOrder = ElementOrder + 1
    return ElementOrder
end

-- SECTION
local function CreateSection(tab, text)
    local ord = NextOrder()
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(1, 0, 0, 26)
    Section.BackgroundTransparency = 1
    Section.LayoutOrder = ord
    Section.Parent = tab.Content

    local Line1 = Instance.new("Frame")
    Line1.Size = UDim2.new(0.2, 0, 0, 1)
    Line1.Position = UDim2.new(0, 0, 0.5, 0)
    Line1.BackgroundColor3 = Theme.Border
    Line1.BorderSizePixel = 0
    Line1.Parent = Section

    local SText = Instance.new("TextLabel")
    SText.Size = UDim2.new(0.6, 0, 1, 0)
    SText.Position = UDim2.new(0.2, 0, 0, 0)
    SText.BackgroundTransparency = 1
    SText.Text = text
    SText.TextColor3 = Theme.TextSecondary
    SText.TextSize = 12
    SText.Font = Theme.Font
    SText.Parent = Section

    local Line2 = Instance.new("Frame")
    Line2.Size = UDim2.new(0.2, 0, 0, 1)
    Line2.Position = UDim2.new(0.8, 0, 0.5, 0)
    Line2.BackgroundColor3 = Theme.Border
    Line2.BorderSizePixel = 0
    Line2.Parent = Section
end

-- TOGGLE
local function CreateToggle(tab, name, default, callback)
    local ord = NextOrder()
    local Value = default or false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
    ToggleFrame.BackgroundColor3 = Theme.Card
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.LayoutOrder = ord
    ToggleFrame.Parent = tab.Content

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 8)
    TCorner.Parent = ToggleFrame

    local TName = Instance.new("TextLabel")
    TName.Size = UDim2.new(1, -60, 1, 0)
    TName.Position = UDim2.new(0, 12, 0, 0)
    TName.BackgroundTransparency = 1
    TName.Text = name
    TName.TextColor3 = Theme.TextPrimary
    TName.TextSize = 13
    TName.Font = Theme.FontLight
    TName.TextXAlignment = Enum.TextXAlignment.Left
    TName.TextTruncate = Enum.TextTruncate.AtEnd
    TName.Parent = ToggleFrame

    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 40, 0, 22)
    ToggleBg.Position = UDim2.new(1, -50, 0.5, -11)
    ToggleBg.BackgroundColor3 = Value and Theme.ToggleOn or Theme.ToggleOff
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Parent = ToggleFrame

    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(1, 0)
    TBCorner.Parent = ToggleBg

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Circle.BackgroundColor3 = Value and Theme.Background or Theme.AccentDim
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBg

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = Circle

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.Parent = ToggleFrame

    ToggleBtn.MouseButton1Click:Connect(function()
        Value = not Value
        Tween(ToggleBg, {BackgroundColor3 = Value and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
        Tween(Circle, {
            Position = Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = Value and Theme.Background or Theme.AccentDim
        }, 0.2)
        pcall(callback, Value)
    end)

    -- Hover
    ToggleBtn.MouseEnter:Connect(function()
        Tween(ToggleFrame, {BackgroundColor3 = Theme.CardHover}, 0.15)
    end)
    ToggleBtn.MouseLeave:Connect(function()
        Tween(ToggleFrame, {BackgroundColor3 = Theme.Card}, 0.15)
    end)

    return {
        Set = function(v)
            Value = v
            Tween(ToggleBg, {BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
            Tween(Circle, {
                Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = v and Theme.Background or Theme.AccentDim
            }, 0.2)
        end,
        Get = function() return Value end,
    }
end

-- BUTTON
local function CreateButton(tab, name, callback)
    local ord = NextOrder()

    local BtnFrame = Instance.new("Frame")
    BtnFrame.Size = UDim2.new(1, 0, 0, 36)
    BtnFrame.BackgroundColor3 = Theme.Card
    BtnFrame.BorderSizePixel = 0
    BtnFrame.LayoutOrder = ord
    BtnFrame.Parent = tab.Content

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = BtnFrame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = name
    Btn.TextColor3 = Theme.TextPrimary
    Btn.TextSize = 13
    Btn.Font = Theme.FontLight
    Btn.Parent = BtnFrame

    Btn.MouseButton1Click:Connect(function()
        -- Flash effect
        Tween(BtnFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
        Tween(Btn, {TextColor3 = Theme.Background}, 0.1)
        task.wait(0.1)
        Tween(BtnFrame, {BackgroundColor3 = Theme.Card}, 0.2)
        Tween(Btn, {TextColor3 = Theme.TextPrimary}, 0.2)
        pcall(callback)
    end)

    Btn.MouseEnter:Connect(function()
        Tween(BtnFrame, {BackgroundColor3 = Theme.CardHover}, 0.15)
    end)
    Btn.MouseLeave:Connect(function()
        Tween(BtnFrame, {BackgroundColor3 = Theme.Card}, 0.15)
    end)
end

-- SLIDER
local function CreateSlider(tab, name, min, max, default, suffix, callback)
    local ord = NextOrder()
    local Value = default or min

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 52)
    SliderFrame.BackgroundColor3 = Theme.Card
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = ord
    SliderFrame.Parent = tab.Content

    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 8)
    SCorner.Parent = SliderFrame

    local SName = Instance.new("TextLabel")
    SName.Size = UDim2.new(0.6, 0, 0, 22)
    SName.Position = UDim2.new(0, 12, 0, 4)
    SName.BackgroundTransparency = 1
    SName.Text = name
    SName.TextColor3 = Theme.TextPrimary
    SName.TextSize = 12
    SName.Font = Theme.FontLight
    SName.TextXAlignment = Enum.TextXAlignment.Left
    SName.Parent = SliderFrame

    local SVal = Instance.new("TextLabel")
    SVal.Size = UDim2.new(0.4, -12, 0, 22)
    SVal.Position = UDim2.new(0.6, 0, 0, 4)
    SVal.BackgroundTransparency = 1
    SVal.Text = tostring(Value) .. (suffix or "")
    SVal.TextColor3 = Theme.AccentDim
    SVal.TextSize = 12
    SVal.Font = Theme.Font
    SVal.TextXAlignment = Enum.TextXAlignment.Right
    SVal.Parent = SliderFrame

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -24, 0, 6)
    SliderBg.Position = UDim2.new(0, 12, 0, 34)
    SliderBg.BackgroundColor3 = Theme.SliderBg
    SliderBg.BorderSizePixel = 0
    SliderBg.Parent = SliderFrame

    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(1, 0)
    SBCorner.Parent = SliderBg

    local pct = (Value - min) / (max - min)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(pct, 0, 1, 0)
    SliderFill.BackgroundColor3 = Theme.SliderFill
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBg

    local SFCorner = Instance.new("UICorner")
    SFCorner.CornerRadius = UDim.new(1, 0)
    SFCorner.Parent = SliderFill

    -- Knob
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new(pct, -7, 0.5, -7)
    Knob.BackgroundColor3 = Theme.Accent
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 2
    Knob.Parent = SliderBg

    local KCorner = Instance.new("UICorner")
    KCorner.CornerRadius = UDim.new(1, 0)
    KCorner.Parent = Knob

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(1, 0, 0, 24)
    SliderBtn.Position = UDim2.new(0, 0, 0, 28)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text = ""
    SliderBtn.Parent = SliderFrame

    local sliding = false

    local function UpdateSlider(inputPos)
        local absPos = SliderBg.AbsolutePosition.X
        local absSize = SliderBg.AbsoluteSize.X
        local rel = math.clamp((inputPos.X - absPos) / absSize, 0, 1)
        Value = math.floor(min + (max - min) * rel)
        SVal.Text = tostring(Value) .. (suffix or "")
        SliderFill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -7, 0.5, -7)
        pcall(callback, Value)
    end

    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSlider(input.Position)
        end
    end)

    SliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input.Position)
        end
    end)
end

-- DROPDOWN
local function CreateDropdown(tab, name, options, callback)
    local ord = NextOrder()
    local Selected = nil
    local Open = false

    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, 0, 0, 36)
    DropFrame.BackgroundColor3 = Theme.Card
    DropFrame.BorderSizePixel = 0
    DropFrame.ClipsDescendants = true
    DropFrame.LayoutOrder = ord
    DropFrame.Parent = tab.Content

    local DCorner = Instance.new("UICorner")
    DCorner.CornerRadius = UDim.new(0, 8)
    DCorner.Parent = DropFrame

    local DName = Instance.new("TextLabel")
    DName.Size = UDim2.new(0.5, 0, 0, 36)
    DName.Position = UDim2.new(0, 12, 0, 0)
    DName.BackgroundTransparency = 1
    DName.Text = name
    DName.TextColor3 = Theme.TextPrimary
    DName.TextSize = 12
    DName.Font = Theme.FontLight
    DName.TextXAlignment = Enum.TextXAlignment.Left
    DName.Parent = DropFrame

    local DSelected = Instance.new("TextLabel")
    DSelected.Size = UDim2.new(0.5, -12, 0, 36)
    DSelected.Position = UDim2.new(0.5, 0, 0, 0)
    DSelected.BackgroundTransparency = 1
    DSelected.Text = "Select... ▼"
    DSelected.TextColor3 = Theme.AccentDim
    DSelected.TextSize = 12
    DSelected.Font = Theme.Font
    DSelected.TextXAlignment = Enum.TextXAlignment.Right
    DSelected.Parent = DropFrame

    local DBtn = Instance.new("TextButton")
    DBtn.Size = UDim2.new(1, 0, 0, 36)
    DBtn.BackgroundTransparency = 1
    DBtn.Text = ""
    DBtn.Parent = DropFrame

    local OptionFrames = {}

    local function BuildOptions(opts)
        for _, f in pairs(OptionFrames) do f:Destroy() end
        OptionFrames = {}
        for i, opt in ipairs(opts) do
            local OBtn = Instance.new("TextButton")
            OBtn.Size = UDim2.new(1, -16, 0, 28)
            OBtn.Position = UDim2.new(0, 8, 0, 36 + (i-1) * 30)
            OBtn.BackgroundColor3 = Theme.CardHover
            OBtn.Text = tostring(opt)
            OBtn.TextColor3 = Theme.TextPrimary
            OBtn.TextSize = 12
            OBtn.Font = Theme.FontLight
            OBtn.BorderSizePixel = 0
            OBtn.Parent = DropFrame

            local OCorner = Instance.new("UICorner")
            OCorner.CornerRadius = UDim.new(0, 6)
            OCorner.Parent = OBtn

            table.insert(OptionFrames, OBtn)

            OBtn.MouseButton1Click:Connect(function()
                Selected = opt
                DSelected.Text = tostring(opt) .. " ▼"
                Open = false
                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                pcall(callback, opt)
            end)
        end
    end

    BuildOptions(options)

    DBtn.MouseButton1Click:Connect(function()
        Open = not Open
        if Open then
            local h = 36 + #options * 30 + 6
            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, math.min(h, 200))}, 0.2)
        else
            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
        end
    end)

    return {
        Refresh = function(newOpts)
            options = newOpts
            BuildOptions(newOpts)
            if Open then
                local h = 36 + #newOpts * 30 + 6
                DropFrame.Size = UDim2.new(1, 0, 0, math.min(h, 200))
            end
        end,
        Get = function() return Selected end,
    }
end

-- LABEL
local function CreateLabel(tab, text)
    local ord = NextOrder()
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 0, 20)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Theme.TextSecondary
    L.TextSize = 11
    L.Font = Theme.FontLight
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.LayoutOrder = ord
    L.Parent = tab.Content
    return L
end

-- PARAGRAPH
local function CreateParagraph(tab, title, content)
    local ord = NextOrder()
    local PFrame = Instance.new("Frame")
    PFrame.Size = UDim2.new(1, 0, 0, 70)
    PFrame.BackgroundColor3 = Theme.Card
    PFrame.BorderSizePixel = 0
    PFrame.LayoutOrder = ord
    PFrame.Parent = tab.Content

    local PCorner = Instance.new("UICorner")
    PCorner.CornerRadius = UDim.new(0, 8)
    PCorner.Parent = PFrame

    local PTitle = Instance.new("TextLabel")
    PTitle.Size = UDim2.new(1, -16, 0, 22)
    PTitle.Position = UDim2.new(0, 8, 0, 4)
    PTitle.BackgroundTransparency = 1
    PTitle.Text = title
    PTitle.TextColor3 = Theme.Accent
    PTitle.TextSize = 13
    PTitle.Font = Theme.Font
    PTitle.TextXAlignment = Enum.TextXAlignment.Left
    PTitle.Parent = PFrame

    local PContent = Instance.new("TextLabel")
    PContent.Size = UDim2.new(1, -16, 1, -28)
    PContent.Position = UDim2.new(0, 8, 0, 26)
    PContent.BackgroundTransparency = 1
    PContent.Text = content
    PContent.TextColor3 = Theme.TextSecondary
    PContent.TextSize = 11
    PContent.Font = Theme.FontLight
    PContent.TextXAlignment = Enum.TextXAlignment.Left
    PContent.TextYAlignment = Enum.TextYAlignment.Top
    PContent.TextWrapped = true
    PContent.Parent = PFrame
end

-- NOTIFICATION
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 260, 1, 0)
NotifHolder.Position = UDim2.new(1, -270, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local NLayout = Instance.new("UIListLayout")
NLayout.SortOrder = Enum.SortOrder.LayoutOrder
NLayout.Padding = UDim.new(0, 6)
NLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NLayout.Parent = NotifHolder

local NPad = Instance.new("UIPadding")
NPad.PaddingBottom = UDim.new(0, 10)
NPad.PaddingRight = UDim.new(0, 10)
NPad.Parent = NotifHolder

local function Notify(title, content, dur)
    local NF = Instance.new("Frame")
    NF.Size = UDim2.new(1, 0, 0, 55)
    NF.BackgroundColor3 = Theme.TopBar
    NF.BorderSizePixel = 0
    NF.Parent = NotifHolder

    local NC = Instance.new("UICorner")
    NC.CornerRadius = UDim.new(0, 8)
    NC.Parent = NF

    local NS = Instance.new("UIStroke")
    NS.Color = Theme.Border
    NS.Thickness = 1
    NS.Parent = NF

    local NT = Instance.new("TextLabel")
    NT.Size = UDim2.new(1, -12, 0, 22)
    NT.Position = UDim2.new(0, 6, 0, 4)
    NT.BackgroundTransparency = 1
    NT.Text = title or ""
    NT.TextColor3 = Theme.Accent
    NT.TextSize = 12
    NT.Font = Theme.Font
    NT.TextXAlignment = Enum.TextXAlignment.Left
    NT.Parent = NF

    local NCC = Instance.new("TextLabel")
    NCC.Size = UDim2.new(1, -12, 0, 22)
    NCC.Position = UDim2.new(0, 6, 0, 26)
    NCC.BackgroundTransparency = 1
    NCC.Text = content or ""
    NCC.TextColor3 = Theme.TextSecondary
    NCC.TextSize = 11
    NCC.Font = Theme.FontLight
    NCC.TextXAlignment = Enum.TextXAlignment.Left
    NCC.Parent = NF

    -- Slide in
    NF.Position = UDim2.new(1, 0, 0, 0)
    Tween(NF, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)

    task.delay(dur or 3, function()
        Tween(NF, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        NF:Destroy()
    end)
end

-- ======================================================
-- SHARED GAME VARIABLES
-- ======================================================
local FlyingEnabled = false
local IsTeleporting = false
local LastInputTime = tick()
local PositionHistory = {}
local AntiGrabEnabled = false
local AntiDetectedEnabled = false
local NoclipEnabled = false
local InfJumpEnabled = false
local LagSpeedEnabled = false
local LagSpeedValue = 100
local AutoResetEnabled = false
local AutoResetDelay = 1
local FlySpeed = 100
local FlyConnection, FlyBV, FlyBG

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

-- POSITION HISTORY
RunService.Heartbeat:Connect(function()
    if not AntiGrabEnabled and not AntiDetectedEnabled then
        PositionHistory = {}
        return
    end
    if FlyingEnabled or IsTeleporting then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    table.insert(PositionHistory, 1, {Time = tick(), CFrame = hrp.CFrame})
    local now = tick()
    for i = #PositionHistory, 1, -1 do
        if now - PositionHistory[i].Time > 8.5 then
            table.remove(PositionHistory, i)
        end
    end
end)

local function GetPositionSecondsAgo(seconds)
    local targetTime = tick() - seconds
    local clos, closDiff = nil, math.huge
    for _, data in ipairs(PositionHistory) do
        local diff = math.abs(data.Time - targetTime)
        if diff < closDiff then closDiff = diff; clos = data end
    end
    if not clos and #PositionHistory > 0 then clos = PositionHistory[#PositionHistory] end
    return clos
end

local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function GetHRP()
    local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = GetChar(); return c and c:FindFirstChildOfClass("Humanoid")
end

local function TeleportBack(seconds)
    local hrp = GetHRP()
    if not hrp then return false end
    local safeData = GetPositionSecondsAgo(seconds)
    if safeData then
        IsTeleporting = true
        hrp.CFrame = safeData.CFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        local hum = GetHum()
        if hum then
            local anim = hum:FindFirstChildOfClass("Animator")
            if anim then
                for _, t in pairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
            end
        end
        task.defer(function() task.wait(0.4); IsTeleporting = false end)
        return true
    end
    return false
end

-- ======================================================
-- TABS
-- ======================================================
local HomeTab = CreateTab("Home", "🏠", 1)
local PlayerTab = CreateTab("Player", "🏃", 2)
local ESPTab = CreateTab("ESP", "👁", 3)
local TPTab = CreateTab("Teleport", "🌀", 4)
local SettingsTab = CreateTab("Settings", "⚙", 5)

-- Activate Home by default
Tabs[1].Button.MouseButton1Click:Fire()

-- ======================================================
-- HOME TAB
-- ======================================================
CreateParagraph(HomeTab, "💀 DMM HUB v1.0", "Game: Fling Things and People\nCustom UI | Mobile + PC\nEnjoy!")
CreateLabel(HomeTab, "Players: " .. #Players:GetPlayers())

CreateSection(HomeTab, "Quick Actions")

CreateButton(HomeTab, "🔄 Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(HomeTab, "🌐 Server Hop", function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local data = Http:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)

CreateButton(HomeTab, "📋 Copy Game Link", function()
    pcall(function() setclipboard("https://www.roblox.com/games/" .. game.PlaceId) end)
    Notify("DMM HUB", "Link copied!", 2)
end)

CreateSection(HomeTab, "Anti AFK")

CreateToggle(HomeTab, "Anti AFK", false, function(v)
    -- handled by Idled
end)

LocalPlayer.Idled:Connect(function()
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
end)

-- ======================================================
-- PLAYER TAB
-- ======================================================

-- FLY
CreateSection(PlayerTab, "Fly")

local function StartFly()
    local char = GetChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
    if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "FlyBV"
    FlyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = hrp
    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "FlyBG"
    FlyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlyBG.P = 9e4; FlyBG.D = 500
    FlyBG.CFrame = hrp.CFrame
    FlyBG.Parent = hrp
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyingEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        FlyBV.Velocity = dir.Magnitude > 0 and dir.Unit * FlySpeed or Vector3.zero
        FlyBG.CFrame = cam.CFrame
    end)
end

local function StopFly()
    if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChild("HumanoidRootPart")
        if h then
            if h:FindFirstChild("FlyBV") then h.FlyBV:Destroy() end
            if h:FindFirstChild("FlyBG") then h.FlyBG:Destroy() end
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
    FlyBV = nil; FlyBG = nil
end

CreateToggle(PlayerTab, "Fly", false, function(v)
    FlyingEnabled = v
    if v then StartFly() else StopFly() end
end)

CreateSlider(PlayerTab, "Fly Speed", 10, 500, 100, " studs/s", function(v)
    FlySpeed = v
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if FlyingEnabled then StopFly(); task.wait(0.3); StartFly() end
end)

-- LAG SPEED
CreateSection(PlayerTab, "Lag Speed ⚡")

task.spawn(function()
    while task.wait() do
        if LagSpeedEnabled then
            local clicks = math.min(LagSpeedValue, 1000)
            for i = 1, clicks do
                pcall(mouse1click)
                pcall(function()
                    local c = LocalPlayer.Character
                    if c then
                        local tool = c:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end)
            end
            local d = 1 / (LagSpeedValue / clicks)
            if d < 0.001 then task.wait() else task.wait(d) end
        end
    end
end)

CreateToggle(PlayerTab, "Lag Speed ⚡", false, function(v) LagSpeedEnabled = v end)
CreateSlider(PlayerTab, "Clicks Per Second", 1, 100000, 100, " CPS", function(v) LagSpeedValue = v end)

-- AUTO RESET
CreateSection(PlayerTab, "Auto Reset")

task.spawn(function()
    while task.wait(0.1) do
        if AutoResetEnabled then
            local hum = GetHum()
            if hum then hum.Health = 0 end
            task.wait(AutoResetDelay)
        end
    end
end)

CreateToggle(PlayerTab, "Auto Reset", false, function(v) AutoResetEnabled = v end)
CreateSlider(PlayerTab, "Reset Delay", 0, 10, 1, " sec", function(v) AutoResetDelay = v end)

-- ANTI GRAB
CreateSection(PlayerTab, "Anti-Grab [BETA] 🔴OP")

local function SetupAntiGrabAnimTracker(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = hum:WaitForChild("Animator", 5) end
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not AntiGrabEnabled then return end
        if FlyingEnabled or IsTeleporting then return end
        if tick() - LastInputTime > 0.15 then
            local animName = ""
            pcall(function() animName = track.Animation and track.Animation.Name or "" end)
            local ln = string.lower(animName)
            local safeA = {"idle","walk","run","jump","fall","climb","sit","swim","tool","wave","point","dance","cheer","laugh","tilt","movedirection"}
            local isSafe = false
            for _, s in ipairs(safeA) do if string.find(ln, s) then isSafe = true; break end end
            local grabW = {"grab","hold","carry","punch","stun","ragdoll","knock","sleep","drag","pull","throw","slam","choke","bind","tie","capture","arrest","cuff","kill","eat","swallow","consume","caught","trapped","picked","lifted","fling","toss","crush"}
            local isGrab = false
            for _, g in ipairs(grabW) do if string.find(ln, g) then isGrab = true; break end end
            local susp = (track.Priority == Enum.AnimationPriority.Action or track.Priority == Enum.AnimationPriority.Action2 or track.Priority == Enum.AnimationPriority.Action3 or track.Priority == Enum.AnimationPriority.Action4)
            if isGrab or (susp and not isSafe) then
                track:Stop(0)
                TeleportBack(3)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.3); SetupAntiGrabAnimTracker(c) end)
if LocalPlayer.Character then SetupAntiGrabAnimTracker(LocalPlayer.Character) end

CreateToggle(PlayerTab, "Anti-Grab [BETA] 🔴OP", false, function(v)
    AntiGrabEnabled = v
    if v then PositionHistory = {} end
end)

-- ANTI DETECTED
CreateSection(PlayerTab, "Anti Detected [BETA]")

local AntiDetectedCooldown = false

RunService.Heartbeat:Connect(function()
    if not AntiDetectedEnabled then return end
    if FlyingEnabled or IsTeleporting or AntiDetectedCooldown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local tsi = tick() - LastInputTime
    local vel = hrp.AssemblyLinearVelocity
    local hSpd = Vector3.new(vel.X, 0, vel.Z).Magnitude
    local fSpd = vel.Magnitude
    local det = false
    if hSpd > 18 and tsi > 0.1 then det = true end
    if fSpd > 50 and tsi > 0.08 then det = true end
    if det then
        AntiDetectedCooldown = true
        local ok = TeleportBack(7)
        if ok then Notify("🛡️ Anti Detected", "Forced TP detected! Returned 7s back.", 3) end
        task.defer(function() task.wait(0.5); AntiDetectedCooldown = false end)
    end
end)

CreateToggle(PlayerTab, "Anti Detected [BETA]", false, function(v)
    AntiDetectedEnabled = v
    if v then
        PositionHistory = {}
        Notify("🛡️ Anti Detected", "Activated!", 2)
    end
end)

-- MOVEMENT
CreateSection(PlayerTab, "Movement")

CreateSlider(PlayerTab, "WalkSpeed", 16, 500, 16, " studs", function(v)
    local hum = GetHum(); if hum then hum.WalkSpeed = v end
end)

CreateSlider(PlayerTab, "JumpPower", 50, 500, 50, " power", function(v)
    local hum = GetHum()
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end)

CreateToggle(PlayerTab, "Infinite Jump", false, function(v) InfJumpEnabled = v end)

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

CreateToggle(PlayerTab, "Noclip", false, function(v) NoclipEnabled = v end)

RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local c = LocalPlayer.Character
        if c then
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

CreateToggle(PlayerTab, "Full Bright", false, function(v)
    if v then
        Lighting.Brightness = 10; Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Ambient = Color3.new(1,1,1); Lighting.FogEnd = 1e6
    else
        Lighting.Brightness = 2; Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.Ambient = Color3.fromRGB(128,128,128); Lighting.FogEnd = 5000
    end
end)

CreateButton(PlayerTab, "God Mode (Max HP)", function()
    local hum = GetHum()
    if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
end)

CreateButton(PlayerTab, "Reset Character", function()
    local hum = GetHum(); if hum then hum.Health = 0 end
end)

-- ======================================================
-- ESP TAB
-- ======================================================
CreateSection(ESPTab, "Wallhack")

local ESP_ON = false
local ESP_COL = Color3.fromRGB(255, 255, 255)

local function ApplyESP(player)
    if player == LocalPlayer then return end
    local function DoESP(char)
        if not char then return end
        local old = char:FindFirstChild("DMM_HL"); if old then old:Destroy() end
        if ESP_ON then
            local hl = Instance.new("Highlight")
            hl.Name = "DMM_HL"
            hl.FillColor = ESP_COL
            hl.OutlineColor = Color3.new(1,1,1)
            hl.FillTransparency = 0.5
            hl.Parent = char
            local head = char:FindFirstChild("Head")
            if head and not head:FindFirstChild("DMM_ESP") then
                local bb = Instance.new("BillboardGui")
                bb.Name = "DMM_ESP"; bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0,200,0,50)
                bb.StudsOffset = Vector3.new(0,2.5,0)
                bb.Parent = head
                local nl = Instance.new("TextLabel")
                nl.Name = "N"; nl.Size = UDim2.new(1,0,0.5,0)
                nl.BackgroundTransparency = 1; nl.Text = player.Name
                nl.TextColor3 = ESP_COL; nl.TextStrokeTransparency = 0
                nl.TextScaled = true; nl.Font = Enum.Font.GothamBold
                nl.Parent = bb
                local dl = Instance.new("TextLabel")
                dl.Name = "D"; dl.Size = UDim2.new(1,0,0.5,0)
                dl.Position = UDim2.new(0,0,0.5,0)
                dl.BackgroundTransparency = 1; dl.Text = "0m"
                dl.TextColor3 = Color3.new(1,1,1)
                dl.TextStrokeTransparency = 0; dl.TextScaled = true
                dl.Font = Enum.Font.Gotham; dl.Parent = bb
            end
        end
    end
    if player.Character then DoESP(player.Character) end
    player.CharacterAdded:Connect(function(c) task.wait(0.5); if ESP_ON then DoESP(c) end end)
end

RunService.RenderStepped:Connect(function()
    if not ESP_ON then return end
    local myH = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myH then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local bb = head:FindFirstChild("DMM_ESP")
                if bb then
                    local dl = bb:FindFirstChild("D")
                    if dl then
                        local tH = p.Character:FindFirstChild("HumanoidRootPart")
                        if tH then dl.Text = "["..math.floor((myH.Position - tH.Position).Magnitude).."m]" end
                    end
                end
            end
        end
    end
end)

CreateToggle(ESPTab, "Player ESP", false, function(v)
    ESP_ON = v
    for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
    if not v then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("DMM_HL"); if h then h:Destroy() end
                local head = p.Character:FindFirstChild("Head")
                if head then local bb = head:FindFirstChild("DMM_ESP"); if bb then bb:Destroy() end end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(p) if ESP_ON then ApplyESP(p) end end)

-- ======================================================
-- TELEPORT TAB
-- ======================================================
CreateSection(TPTab, "Teleport System")

local ClickTPEnabled = false
CreateToggle(TPTab, "Click TP (Ctrl + Click)", false, function(v) ClickTPEnabled = v end)

Mouse.Button1Down:Connect(function()
    if ClickTPEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        IsTeleporting = true
        local hrp = GetHRP()
        if hrp and Mouse.Hit then hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end
        task.defer(function() task.wait(0.5); IsTeleporting = false end)
    end
end)

CreateSection(TPTab, "Teleport to Player")

local SelTPP = nil
local plist = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(plist, p.Name) end
end

local TPDrop = CreateDropdown(TPTab, "Select Player", plist, function(opt)
    SelTPP = opt
end)

local function RefreshPL()
    local n = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(n, p.Name) end
    end
    pcall(function() TPDrop.Refresh(n) end)
end
Players.PlayerAdded:Connect(RefreshPL)
Players.PlayerRemoving:Connect(RefreshPL)

CreateButton(TPTab, "Teleport to Player", function()
    if SelTPP then
        IsTeleporting = true
        local t = Players:FindFirstChild(SelTPP)
        if t and t.Character then
            local tH = t.Character:FindFirstChild("HumanoidRootPart")
            local myH = GetHRP()
            if tH and myH then myH.CFrame = tH.CFrame + Vector3.new(3,0,0) end
        end
        task.defer(function() task.wait(0.5); IsTeleporting = false end)
    end
end)

CreateButton(TPTab, "TP to Spawn", function()
    local hrp = GetHRP()
    if hrp then
        local sp = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if sp then hrp.CFrame = sp.CFrame + Vector3.new(0,5,0)
        else hrp.CFrame = CFrame.new(0,50,0) end
    end
end)

CreateButton(TPTab, "TP to Random Player", function()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p)
        end
    end
    if #list > 0 then
        local r = list[math.random(#list)]
        local hrp = GetHRP()
        if hrp then hrp.CFrame = r.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end
        Notify("DMM HUB", "TP'd to " .. r.Name, 2)
    end
end)

CreateButton(TPTab, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- ======================================================
-- SETTINGS TAB
-- ======================================================
CreateSection(SettingsTab, "Hub Settings")

CreateButton(SettingsTab, "❌ Destroy GUI", function()
    FlyingEnabled = false; StopFly()
    AntiGrabEnabled = false; AntiDetectedEnabled = false
    LagSpeedEnabled = false; AutoResetEnabled = false
    Tween(MainFrame, {Size = UDim2.new(0, WinWidth, 0, 0)}, 0.3)
    task.wait(0.3)
    ScreenGui:Destroy()
end)

CreateParagraph(SettingsTab, "💀 DMM HUB v1.0", "Custom UI | Dark-White Theme\nMobile + PC Friendly\nAll features from original script")

CreateLabel(SettingsTab, "Version 1.0 | DMM HUB")

-- ======================================================
-- MOBILE TOGGLE BUTTON
-- ======================================================
if IsMobile then
    local MobileBtn = Instance.new("TextButton")
    MobileBtn.Size = UDim2.new(0, 45, 0, 45)
    MobileBtn.Position = UDim2.new(0, 10, 0.5, -22)
    MobileBtn.BackgroundColor3 = Theme.TopBar
    MobileBtn.Text = "💀"
    MobileBtn.TextSize = 20
    MobileBtn.Font = Theme.Font
    MobileBtn.BorderSizePixel = 0
    MobileBtn.Parent = ScreenGui
    MobileBtn.Active = true
    MobileBtn.Draggable = true

    local MBCorner = Instance.new("UICorner")
    MBCorner.CornerRadius = UDim.new(1, 0)
    MBCorner.Parent = MobileBtn

    local MBStroke = Instance.new("UIStroke")
    MBStroke.Color = Theme.Border
    MBStroke.Thickness = 1.5
    MBStroke.Parent = MobileBtn

    local guiVisible = true
    MobileBtn.MouseButton1Click:Connect(function()
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end)
end

-- ======================================================
-- DONE
-- ======================================================
Notify("💀 DMM HUB", "Loaded! Enjoy 🎉", 5)

print("═══════════════════════════════")
print("  💀 DMM HUB — Loaded!")
print("  Custom UI | Dark-White Theme")
print("═══════════════════════════════")
