-- Mozer Mob v2.1 (Optimized for Mobile/Delta)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local SavedLocation = nil
local SelectedMobName = ""
local BringingMobs = false
local SelectionEnabled = false -- وضع الاختيار (OFF افتراضياً)

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MozerMob_v2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- [1] Welcome Screen
local function ShowWelcome()
    local WelcomeGui = Instance.new("ScreenGui", game.CoreGui)
    local MozerLabel = Instance.new("TextLabel", WelcomeGui)
    MozerLabel.Size = UDim2.new(1, 0, 0.1, 0)
    MozerLabel.Position = UDim2.new(0, 0, 0.38, 0)
    MozerLabel.BackgroundTransparency = 1
    MozerLabel.Text = "Mozer Mob"
    MozerLabel.TextSize = 80
    MozerLabel.Font = Enum.Font.FredokaOne
    task.spawn(function()
        while WelcomeGui.Parent do
            MozerLabel.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            task.wait()
        end
    end)
    task.wait(2)
    WelcomeGui:Destroy()
end

-- [2] Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Sidebar & Content
local LeftSidebar = Instance.new("Frame", MainFrame)
LeftSidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LeftSidebar.Size = UDim2.new(0, 155, 1, 0)
Instance.new("UICorner", LeftSidebar).CornerRadius = UDim.new(0, 12)

local RightContent = Instance.new("Frame", MainFrame)
RightContent.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
RightContent.Position = UDim2.new(0, 165, 0, 50)
RightContent.Size = UDim2.new(1, -175, 1, -60)
Instance.new("UICorner", RightContent).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel", LeftSidebar)
Title.Text = "Mozer Mob"
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Position = UDim2.new(0, 15, 0, 10)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- User Profile
local UserProfile = Instance.new("Frame", LeftSidebar)
UserProfile.Size = UDim2.new(1, -12, 0, 50)
UserProfile.Position = UDim2.new(0, 6, 1, -60)
UserProfile.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", UserProfile)

local UserName = Instance.new("TextLabel", UserProfile)
UserName.Text = LocalPlayer.DisplayName
UserName.Size = UDim2.new(1, -50, 0, 15)
UserName.Position = UDim2.new(0, 48, 0.3, -2)
UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 11
UserName.BackgroundTransparency = 1

-- Tabs
local TabContainer = Instance.new("Frame", LeftSidebar)
TabContainer.Position = UDim2.new(0, 10, 0, 65)
TabContainer.Size = UDim2.new(1, -20, 0.55, 0)
TabContainer.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", TabContainer)
Layout.Padding = UDim.new(0, 6)

local Pages = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", RightContent)
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Pages[name] = Page
    
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
    end)
    return Page
end

-- Create Pages
local TER_Page = CreatePage("TER")
local Mob_Page = CreatePage("Mob")
local TMop_Page = CreatePage("TMop")

-- --- [TER Page Logic] ---
local TerLabel = Instance.new("TextLabel", TER_Page)
TerLabel.Size = UDim2.new(1, 0, 0, 40)
TerLabel.Text = "Location: Not Set"
TerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TerLabel.BackgroundTransparency = 1

local SelectTerBtn = Instance.new("TextButton", TER_Page)
SelectTerBtn.Size = UDim2.new(0.9, 0, 0, 40)
SelectTerBtn.Position = UDim2.new(0.05, 0, 0, 50)
SelectTerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SelectTerBtn.Text = "Select Current Pos"
SelectTerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", SelectTerBtn)

SelectTerBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SavedLocation = LocalPlayer.Character.HumanoidRootPart.CFrame
        local pos = SavedLocation.Position
        TerLabel.Text = string.format("X: %.0f | Y: %.0f | Z: %.0f", pos.X, pos.Y, pos.Z)
    end
end)

-- --- [Mob Page Logic] ---
local MobStatus = Instance.new("TextLabel", Mob_Page)
MobStatus.Size = UDim2.new(1, 0, 0, 40)
MobStatus.Text = "Current Mob: None"
MobStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
MobStatus.BackgroundTransparency = 1

local ToggleSelectionBtn = Instance.new("TextButton", Mob_Page)
ToggleSelectionBtn.Size = UDim2.new(0.9, 0, 0, 50)
ToggleSelectionBtn.Position = UDim2.new(0.05, 0, 0, 50)
ToggleSelectionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleSelectionBtn.Text = "Selection Mode: OFF"
ToggleSelectionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ToggleSelectionBtn)

local ResearchBtn = Instance.new("TextButton", Mob_Page)
ResearchBtn.Size = UDim2.new(0.9, 0, 0, 40)
ResearchBtn.Position = UDim2.new(0.05, 0, 0, 110)
ResearchBtn.Text = "Research (Reset All)"
ResearchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ResearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ResearchBtn)

-- تفعيل وضع الاختيار
ToggleSelectionBtn.MouseButton1Click:Connect(function()
    SelectionEnabled = not SelectionEnabled
    if SelectionEnabled then
        ToggleSelectionBtn.Text = "Selection Mode: ON (Tap a Mob)"
        ToggleSelectionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ToggleSelectionBtn.Text = "Selection Mode: OFF"
        ToggleSelectionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- وظيفة لمس الموب
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- "gameProcessed" تضمن أنك لا تضغط على أزرار الواجهة
    if not gameProcessed and SelectionEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model then
                SelectedMobName = model.Name
                MobStatus.Text = "Current Mob: " .. SelectedMobName
                -- إيقاف الوضع تلقائياً بعد الاختيار
                SelectionEnabled = false
                ToggleSelectionBtn.Text = "Selection Mode: OFF"
                ToggleSelectionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            end
        end
    end
end)

ResearchBtn.MouseButton1Click:Connect(function()
    SelectedMobName = ""
    MobStatus.Text = "Current Mob: None"
end)

-- --- [TMop Page Logic] ---
local BringToggle = Instance.new("TextButton", TMop_Page)
BringToggle.Size = UDim2.new(0.9, 0, 0, 60)
BringToggle.Position = UDim2.new(0.05, 0, 0, 20)
BringToggle.Text = "BRING MOBS: OFF"
BringToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
BringToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BringToggle.Font = Enum.Font.GothamBold
Instance.new("UICorner", BringToggle)

BringToggle.MouseButton1Click:Connect(function()
    BringingMobs = not BringingMobs
    BringToggle.Text = BringingMobs and "BRING MOBS: ON" or "BRING MOBS: OFF"
    BringToggle.BackgroundColor3 = BringingMobs and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- [Main Loop] (Teleport & Freeze)
RunService.Heartbeat:Connect(function()
    if BringingMobs and SavedLocation and SelectedMobName ~= "" then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == SelectedMobName then
                local hrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("UpperTorso")
                if hrp then
                    hrp.CFrame = SavedLocation
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.RotVelocity = Vector3.new(0,0,0)
                end
            end
        end
    end
end)

-- [Navigation & Draggable]
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0,35,0,35); CloseBtn.Position = UDim2.new(1,-40,0,5); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.TextSize = 20

local MinimizedBtn = Instance.new("TextButton", ScreenGui)
MinimizedBtn.Size = UDim2.new(0,55,0,55); MinimizedBtn.Position = UDim2.new(0.05,0,0.4,0); MinimizedBtn.Text = "M"; MinimizedBtn.Visible = false; MinimizedBtn.BackgroundColor3 = Color3.fromRGB(15,15,15)
Instance.new("UICorner", MinimizedBtn)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinimizedBtn.Visible = true end)
MinimizedBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; MinimizedBtn.Visible = false end)

local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input) dragging = false end)
end

MakeDraggable(MainFrame)
MakeDraggable(MinimizedBtn)

ShowWelcome()
MainFrame.Visible = true
Pages["TER"].Visible = true
