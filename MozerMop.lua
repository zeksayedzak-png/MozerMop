-- Mozer Mob v3.0 (Multi-Selection & Anti-Movement)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local SavedLocation = nil
local SelectedMobList = {} -- قائمة الوحوش المختارة
local CurrentlyHoveredMob = nil -- الوحش الذي يتم لمسه حالياً
local SelectionMode = false
local BringingEnabled = false

-- Create Highlight Effect (الهالة الحمراء)
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(255, 0, 0)
Highlight.FillTransparency = 0.5
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.OutlineTransparency = 0
Highlight.Parent = nil

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MozerMob_V3"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", MainFrame)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Sidebar)

local Layout = Instance.new("UIListLayout", Sidebar)
Layout.Padding = UDim.new(0, 5)

-- Pages Container
local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 130, 0, 10)
Pages.Size = UDim2.new(1, -140, 1, -20)
Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", Pages)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Text = name
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
        Page.Visible = true
    end)
    return Page
end

local PageMob = CreatePage("Mob Selection")
local PageTransfer = CreatePage("Transfer Control")

-- --- [MOB PAGE UI] ---
local MobListLabel = Instance.new("TextLabel", PageMob)
MobListLabel.Size = UDim2.new(1, 0, 0, 30)
MobListLabel.Text = "Selected: 0 mobs"
MobListLabel.TextColor3 = Color3.new(1,1,1)
MobListLabel.BackgroundTransparency = 1

local DetectBtn = Instance.new("TextButton", PageMob)
DetectBtn.Size = UDim2.new(1, 0, 0, 40)
DetectBtn.Position = UDim2.new(0,0,0,40)
DetectBtn.Text = "Start Detection: OFF"
DetectBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
DetectBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", DetectBtn)

local AddBtn = Instance.new("TextButton", PageMob)
AddBtn.Size = UDim2.new(1, 0, 0, 40)
AddBtn.Position = UDim2.new(0,0,0,90)
AddBtn.Text = "Select (Add to List)"
AddBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
AddBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AddBtn)

local ClearBtn = Instance.new("TextButton", PageMob)
ClearBtn.Size = UDim2.new(1, 0, 0, 30)
ClearBtn.Position = UDim2.new(0,0,0,140)
ClearBtn.Text = "Clear List"
ClearBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ClearBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", ClearBtn)

-- --- [TRANSFER PAGE UI] ---
local SetPosBtn = Instance.new("TextButton", PageTransfer)
SetPosBtn.Size = UDim2.new(1, 0, 0, 50)
SetPosBtn.Text = "Save Current Location"
SetPosBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SetPosBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", SetPosBtn)

local BringToggle = Instance.new("TextButton", PageTransfer)
BringToggle.Size = UDim2.new(1, 0, 0, 70)
BringToggle.Position = UDim2.new(0,0,0,60)
BringToggle.Text = "BRING MOBS: OFF"
BringToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
BringToggle.Font = Enum.Font.GothamBold
BringToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", BringToggle)

-- --- [LOGIC] ---

-- 1. Detection Mode
DetectBtn.MouseButton1Click:Connect(function()
    SelectionMode = not SelectionMode
    DetectBtn.Text = SelectionMode and "Detection: ON (Tap Mob)" or "Detection: OFF"
    DetectBtn.BackgroundColor3 = SelectionMode and Color3.fromRGB(30, 150, 30) or Color3.fromRGB(100, 30, 30)
    if not SelectionMode then Highlight.Parent = nil end
end)

-- 2. Mouse/Touch Detection (Anti-Click UI Passthrough)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end -- يمنع الاختيار إذا ضغطت على زر
    if SelectionMode and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChildOfClass("Humanoid") then
                CurrentlyHoveredMob = model
                Highlight.Parent = model -- تفعيل الهالة الحمراء
            end
        end
    end
end)

-- 3. Add to List
AddBtn.MouseButton1Click:Connect(function()
    if CurrentlyHoveredMob then
        local name = CurrentlyHoveredMob.Name
        if not table.find(SelectedMobList, name) then
            table.insert(SelectedMobList, name)
            MobListLabel.Text = "Selected: " .. #SelectedMobList .. " mobs"
            print("Added: " .. name)
        end
    end
end)

-- 4. Clear List
ClearBtn.MouseButton1Click:Connect(function()
    SelectedMobList = {}
    MobListLabel.Text = "Selected: 0 mobs"
    Highlight.Parent = nil
    CurrentlyHoveredMob = nil
end)

-- 5. Save Location
SetPosBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SavedLocation = LocalPlayer.Character.HumanoidRootPart.CFrame
        SetPosBtn.Text = "Location Saved! ✔️"
        task.wait(1)
        SetPosBtn.Text = "Save Current Location"
    end
end)

-- 6. Bring & Freeze Loop
BringToggle.MouseButton1Click:Connect(function()
    BringingEnabled = not BringingEnabled
    BringToggle.Text = BringingEnabled and "BRING MOBS: ON" or "BRING MOBS: OFF"
    BringToggle.BackgroundColor3 = BringingEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(150, 0, 0)
end)

RunService.Heartbeat:Connect(function()
    if BringingEnabled and SavedLocation and #SelectedMobList > 0 then
        for _, obj in pairs(workspace:GetChildren()) do
            if table.find(SelectedMobList, obj.Name) and obj:IsA("Model") then
                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("UpperTorso")
                if hrp then
                    -- نقل فوري
                    hrp.CFrame = SavedLocation
                    -- منع الحركة (تجميد)
                    hrp.Velocity = Vector3.new(0,0,0)
                    hrp.RotVelocity = Vector3.new(0,0,0)
                    -- منع الجاذبية من إسقاطهم
                    for _, part in pairs(obj:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end
        end
    end
end)

-- Make Draggable
local function MakeDraggable(f)
    local d, s, sp
    f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true s = i.Position sp = f.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
    f.InputEnded:Connect(function(i) d = false end)
end
MakeDraggable(MainFrame)

PageMob.Visible = true
print("Mozer Mob V3 Loaded!")
