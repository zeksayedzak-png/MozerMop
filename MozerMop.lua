-- Mozer Inspector Pro (Multi-Page Path Finder)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Global Variables
local CurrentMode = "None" -- UI, Part, Button
local LastPaths = {UI = "", Part = "", Button = ""}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MozerInspectorPro"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.Position = UDim2.new(0.5, -175, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame)

-- Sidebar for Navigation
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 80, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Sidebar)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Pages Container
local Pages = Instance.new("Frame", MainFrame)
Pages.Position = UDim2.new(0, 90, 0, 10)
Pages.Size = UDim2.new(1, -100, 1, -20)
Pages.BackgroundTransparency = 1

-- Helper Function: Get Path
local function GetPath(obj)
    if not obj then return "" end
    local path = obj.Name
    local parent = obj.Parent
    while parent and parent ~= game do
        local name = parent.Name
        if name:find(" ") or name:sub(1,1):match("%d") or name:find("[^%w]") then
            path = '["' .. name .. '"].' .. path
        else
            path = parent.Name .. "." .. path
        end
        parent = parent.Parent
    end
    return "game." .. path
end

-- Function to Create Pages
local function CreateInspectorPage(modeName, color)
    local Page = Instance.new("Frame", Pages)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false

    local Title = Instance.new("TextLabel", Page)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = modeName .. " Inspector"
    Title.TextColor3 = color
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1

    local Toggle = Instance.new("TextButton", Page)
    Toggle.Size = UDim2.new(1, 0, 0, 40)
    Toggle.Position = UDim2.new(0, 0, 0, 40)
    Toggle.Text = "Mode: OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Toggle)

    local Display = Instance.new("TextBox", Page)
    Display.Size = UDim2.new(1, 0, 0, 60)
    Display.Position = UDim2.new(0, 0, 0, 90)
    Display.Text = "Click something to see path..."
    Display.TextWrapped = true
    Display.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Display.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Display.ClearTextOnFocus = false
    Display.TextEditable = false
    Instance.new("UICorner", Display)

    local Copy = Instance.new("TextButton", Page)
    Copy.Size = UDim2.new(1, 0, 0, 30)
    Copy.Position = UDim2.new(0, 0, 0, 160)
    Copy.Text = "Copy " .. modeName .. " Path"
    Copy.BackgroundColor3 = color
    Copy.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Copy)

    -- Tab Button
    local Tab = Instance.new("TextButton", Sidebar)
    Tab.Size = UDim2.new(0.9, 0, 0, 40)
    Tab.Text = modeName
    Tab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Tab.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Tab)

    -- Logic for this page
    Tab.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)

    Toggle.MouseButton1Click:Connect(function()
        if CurrentMode == modeName then
            CurrentMode = "None"
            Toggle.Text = "Mode: OFF"
            Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        else
            CurrentMode = modeName
            for _, p in pairs(Pages:GetChildren()) do 
                local t = p:FindFirstChild("TextButton")
                if t then t.Text = "Mode: OFF" t.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
            end
            Toggle.Text = "Mode: ON"
            Toggle.BackgroundColor3 = color
        end
    end)

    Copy.MouseButton1Click:Connect(function()
        if LastPaths[modeName] ~= "" then
            setclipboard(LastPaths[modeName])
            Copy.Text = "Copied!"
            task.wait(1)
            Copy.Text = "Copy " .. modeName .. " Path"
        end
    end)

    return {Page = Page, Display = Display}
end

-- Create the 3 Specialized Pages
local UIPage = CreateInspectorPage("UI", Color3.fromRGB(0, 120, 255))
local PartPage = CreateInspectorPage("Part", Color3.fromRGB(0, 200, 100))
local ButtonPage = CreateInspectorPage("Button", Color3.fromRGB(200, 50, 50))

-- Global Detection Logic
UserInputService.InputBegan:Connect(function(input, processed)
    if CurrentMode == "None" or processed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local target = nil
        local pos = input.Position

        if CurrentMode == "UI" then
            local guis = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
            for _, g in pairs(guis) do
                if not g:IsDescendantOf(MainFrame) then target = g break end
            end
            if target then 
                LastPaths.UI = GetPath(target)
                UIPage.Display.Text = LastPaths.UI
            end

        elseif CurrentMode == "Part" then
            target = Mouse.Target
            if target then
                LastPaths.Part = GetPath(target)
                PartPage.Display.Text = LastPaths.Part
            end

        elseif CurrentMode == "Button" then
            -- ابحث أولاً عن أزرار الواجهة
            local guis = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
            for _, g in pairs(guis) do
                if (g:IsA("TextButton") or g:IsA("ImageButton")) and not g:IsDescendantOf(MainFrame) then
                    target = g break
                end
            end
            -- إذا لم يجد، ابحث عن أزرار في العالم (ClickDetector)
            if not target then
                local worldTarget = Mouse.Target
                if worldTarget and (worldTarget:FindFirstChildOfClass("ClickDetector") or worldTarget:IsA("TextButton")) then
                    target = worldTarget
                end
            end
            
            if target then
                LastPaths.Button = GetPath(target)
                ButtonPage.Display.Text = LastPaths.Button
            end
        end
    end
end)

-- Draggable UI
local function MakeDraggable(f)
    local d, s, sp
    f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true s = i.Position sp = f.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
    f.InputEnded:Connect(function(i) d = false end)
end
MakeDraggable(MainFrame)

-- Start default page
UIPage.Page.Visible = true
