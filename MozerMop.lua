-- Mozer Mob v4.0 (Smart Path Detection & Delta Optimized)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local SavedLocation = nil
local SelectedPaths = {} -- تخزين المسارات (Folders) التي تحتوي على الموبات
local SelectedMobNames = {} -- أسماء الموبات المحددة
local DetectionActive = false
local BringingActive = false
local TempTarget = nil

-- Highlight for Selection
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(255, 0, 0)
Highlight.FillTransparency = 0.4
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

-- UI Creation
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MozerMob_V4"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 460, 0, 320)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Pages Container
local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 130, 0, 10)
Pages.Size = UDim2.new(1, -140, 1, -20)
Pages.BackgroundTransparency = 1

local PageObjects = {}
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", Pages)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    PageObjects[name] = Page
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.Text = name
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.TextColor3 = Color3.new(1,1,1)
    TabBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(PageObjects) do p.Visible = false end
        Page.Visible = true
    end)
    return Page
end

local PageTER = CreatePage("TER")
local PageMob = CreatePage("Mob")
local PageTMop = CreatePage("TMop")

-- [1] TER PAGE (Position Setup)
local SetPosBtn = Instance.new("TextButton", PageTER)
SetPosBtn.Size = UDim2.new(1, 0, 0, 50)
SetPosBtn.Text = "STEP 1: Save Location"
SetPosBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 80)
SetPosBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SetPosBtn)

SetPosBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SavedLocation = LocalPlayer.Character.HumanoidRootPart.CFrame
        SetPosBtn.Text = "Location Saved! ✔️"
        task.delay(1, function() SetPosBtn.Text = "STEP 1: Save Location" end)
    end
end)

-- [2] MOB PAGE (Path Detection Logic)
local InfoLabel = Instance.new("TextLabel", PageMob)
InfoLabel.Size = UDim2.new(1, 0, 0, 40)
InfoLabel.Text = "Select a Mob to Auto-Detect Path"
InfoLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextWrapped = true

local DetectBtn = Instance.new("TextButton", PageMob)
DetectBtn.Size = UDim2.new(1, 0, 0, 45)
DetectBtn.Position = UDim2.new(0, 0, 0, 50)
DetectBtn.Text = "Detection: OFF"
DetectBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
DetectBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", DetectBtn)

local AddMobBtn = Instance.new("TextButton", PageMob)
AddMobBtn.Size = UDim2.new(1, 0, 0, 45)
AddMobBtn.Position = UDim2.new(0, 0, 0, 105)
AddMobBtn.Text = "SELECT & SAVE PATH"
AddMobBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
AddMobBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AddMobBtn)

DetectBtn.MouseButton1Click:Connect(function()
    DetectionActive = not DetectionActive
    DetectBtn.Text = DetectionActive and "Detection: ON (Touch Mob)" or "Detection: OFF"
    DetectBtn.BackgroundColor3 = DetectionActive and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(80, 40, 40)
    if not DetectionActive then Highlight.Parent = nil end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not DetectionActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChildOfClass("Humanoid") then
                TempTarget = model
                Highlight.Parent = model
                InfoLabel.Text = "Target: " .. model.Name .. "\nPath: " .. model.Parent.Name
            end
        end
    end
end)

AddMobBtn.MouseButton1Click:Connect(function()
    if TempTarget then
        -- حفظ اسم الموب وحفظ "المجلد" الذي يحتوي عليه
        if not table.find(SelectedMobNames, TempTarget.Name) then
            table.insert(SelectedMobNames, TempTarget.Name)
        end
        if not table.find(SelectedPaths, TempTarget.Parent) then
            table.insert(SelectedPaths, TempTarget.Parent)
        end
        InfoLabel.Text = "Path Added Successfully! (" .. #SelectedPaths .. " Paths)"
        Highlight.Parent = nil
        TempTarget = nil
    end
end)

-- [3] TMop PAGE (Bringing & Freezing)
local BringBtn = Instance.new("TextButton", PageTMop)
BringBtn.Size = UDim2.new(1, 0, 0, 80)
BringBtn.Text = "START BRINGING: OFF"
BringBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
BringBtn.TextColor3 = Color3.new(1,1,1)
BringBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", BringBtn)

BringBtn.MouseButton1Click:Connect(function()
    if not SavedLocation then
        BringBtn.Text = "SAVE LOCATION FIRST!"
        task.wait(1)
        BringBtn.Text = "START BRINGING: OFF"
        return
    end
    BringingActive = not BringingActive
    BringBtn.Text = BringingActive and "BRINGING: ON" or "BRINGING: OFF"
    BringBtn.BackgroundColor3 = BringingActive and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(120, 0, 0)
end)

-- Main Loop (The Brain)
RunService.Heartbeat:Connect(function()
    if BringingActive and SavedLocation then
        -- البحث داخل المسارات التي تم حفظها تلقائياً
        for _, parent in pairs(SelectedPaths) do
            for _, mob in pairs(parent:GetChildren()) do
                if mob:IsA("Model") and table.find(SelectedMobNames, mob.Name) then
                    local hrp = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("UpperTorso")
                    if hrp then
                        -- النقل مع الحفاظ على زاوية الوجه
                        hrp.CFrame = SavedLocation
                        -- التجميد التام
                        hrp.Velocity = Vector3.new(0,0,0)
                        hrp.RotVelocity = Vector3.new(0,0,0)
                        for _, p in pairs(mob:GetChildren()) do
                            if p:IsA("BasePart") then p.Velocity = Vector3.new(0,0,0) end
                        end
                    end
                end
            end
        end
    end
end)

-- Dragging Functionality (Move UI)
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(MainFrame)
PageTER.Visible = true
print("Mozer Mob V4 Loaded - Path Detection Active")
