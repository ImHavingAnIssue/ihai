-- integrated aimb0t + hitbox expander (client-side / studio/dev testing)
local teamCheck = false 
local fov = 150
local hideCircleWithGUI = true

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- FOV ring placeholder for studio (Drawing not available)
local FOVring = {}
FOVring.Position = Vector2.new(0,0)
FOVring.Radius = fov
FOVring.Visible = false
FOVring.Color = Color3.fromRGB(255,128,128)
FOVring.Thickness = 1.5

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "aimb0tGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 150, 0, 260)
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.BorderSizePixel = 0

local Header = Instance.new("Frame", Frame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BorderSizePixel = 0

local HeaderLabel = Instance.new("TextLabel", Header)
HeaderLabel.Size = UDim2.new(1, 0, 1, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "wuiuo's aimb0t"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.TextSize = 14

local primaryButtonColor = Color3.fromRGB(100, 100, 100)

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0, 130, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.BackgroundColor3 = primaryButtonColor
ToggleButton.Text = "aimb0t · off"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

local TeamCheckButton = Instance.new("TextButton", Frame)
TeamCheckButton.Size = UDim2.new(0, 130, 0, 30)
TeamCheckButton.Position = UDim2.new(0, 10, 0, 80)
TeamCheckButton.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
TeamCheckButton.Text = "team check · off"
TeamCheckButton.TextColor3 = Color3.new(1, 1, 1)

local IYButton = Instance.new("TextButton", Frame)
IYButton.Size = UDim2.new(0, 130, 0, 30)
IYButton.Position = UDim2.new(0, 10, 0, 120)
IYButton.BackgroundColor3 = Color3.fromRGB(120, 100, 180)
IYButton.Text = "infinite yield"
IYButton.TextColor3 = Color3.new(1, 1, 1)

local SettingsButton = Instance.new("TextButton", Frame)
SettingsButton.Size = UDim2.new(0, 130, 0, 30)
SettingsButton.Position = UDim2.new(0, 10, 0, 160)
SettingsButton.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
SettingsButton.Text = "settings"
SettingsButton.TextColor3 = Color3.new(1, 1, 1)

local FOVSliderFrame = Instance.new("Frame", Frame)
FOVSliderFrame.Size = UDim2.new(0, 130, 0, 20)
FOVSliderFrame.Position = UDim2.new(0, 10, 0, 200)
FOVSliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

local FOVSliderBar = Instance.new("Frame", FOVSliderFrame)
FOVSliderBar.Size = UDim2.new(fov / 300, 0, 1, 0)
FOVSliderBar.BackgroundColor3 = Color3.fromRGB(255, 128, 128)

-- Settings Tab
local SettingsTab = Instance.new("Frame", ScreenGui)
SettingsTab.Size = UDim2.new(0, 220, 0, 170)
SettingsTab.Position = UDim2.new(0, 180, 0, 20)
SettingsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsTab.Visible = false

local SettingsClose = Instance.new("TextButton", SettingsTab)
SettingsClose.Size = UDim2.new(0, 20, 0, 20)
SettingsClose.Position = UDim2.new(1, -25, 0, 5)
SettingsClose.Text = "X"
SettingsClose.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
SettingsClose.TextColor3 = Color3.new(1, 1, 1)

local ShiftToggle = Instance.new("TextButton", SettingsTab)
ShiftToggle.Size = UDim2.new(1, -10, 0, 30)
ShiftToggle.Position = UDim2.new(0, 5, 0, 30)
ShiftToggle.Text = "hide circle w/ gui · on"
ShiftToggle.BackgroundColor3 = primaryButtonColor
ShiftToggle.TextColor3 = Color3.new(1, 1, 1)

local HitboxToggle = Instance.new("TextButton", SettingsTab)
HitboxToggle.Size = UDim2.new(1, -10, 0, 30)
HitboxToggle.Position = UDim2.new(0, 5, 0, 70)
HitboxToggle.BackgroundColor3 = primaryButtonColor
HitboxToggle.Text = "hitbox expander · off"
HitboxToggle.TextColor3 = Color3.new(1,1,1)

local HitboxSliderFrame = Instance.new("Frame", SettingsTab)
HitboxSliderFrame.Size = UDim2.new(1, -20, 0, 12)
HitboxSliderFrame.Position = UDim2.new(0, 10, 0, 110)
HitboxSliderFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)

local hitboxSize = 50
local HitboxSliderBar = Instance.new("Frame", HitboxSliderFrame)
HitboxSliderBar.Size = UDim2.new(math.clamp(hitboxSize / 300, 0, 1), 0, 1, 0)
HitboxSliderBar.BackgroundColor3 = Color3.fromRGB(120,120,255)

local HitboxValueLabel = Instance.new("TextLabel", SettingsTab)
HitboxValueLabel.Size = UDim2.new(1, -10, 0, 20)
HitboxValueLabel.Position = UDim2.new(0, 5, 0, 130)
HitboxValueLabel.BackgroundTransparency = 1
HitboxValueLabel.Text = "size · " .. tostring(hitboxSize) .. " (default = 50)" -- fixed missing quote
HitboxValueLabel.TextColor3 = Color3.new(1,1,1)
HitboxValueLabel.TextXAlignment = Enum.TextXAlignment.Left

-- toggles
local aimb0tEnabled = false
local guiVisible = true
local hitboxEnabled = false
local originalSizes = {}

-- dragging
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function toggleaimb0t()
    aimb0tEnabled = not aimb0tEnabled
    ToggleButton.Text = "aimb0t · " .. (aimb0tEnabled and "on" or "off")
    FOVring.Visible = aimb0tEnabled and guiVisible and not (hideCircleWithGUI and not guiVisible)
end

local function updateFOV(percentage)
    fov = math.clamp(math.floor(percentage * 300), 50, 300)
    FOVring.Radius = fov
    FOVSliderBar.Size = UDim2.new(fov / 300, 0, 1, 0)
end

ToggleButton.MouseButton1Click:Connect(toggleaimb0t)

FOVSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local relativeX = math.clamp((mousePos.X - FOVSliderFrame.AbsolutePosition.X) / FOVSliderFrame.AbsoluteSize.X, 0, 1)
            updateFOV(relativeX)
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                connection:Disconnect()
            end
        end)
    end
end)

IYButton.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    IYButton:Destroy()
end)

TeamCheckButton.MouseButton1Click:Connect(function()
    teamCheck = not teamCheck
    TeamCheckButton.Text = "team check · " .. (teamCheck and "on" or "off")
end)

SettingsButton.MouseButton1Click:Connect(function()
    SettingsTab.Visible = not SettingsTab.Visible
end)

SettingsClose.MouseButton1Click:Connect(function()
    SettingsTab.Visible = false
end)

ShiftToggle.MouseButton1Click:Connect(function()
    hideCircleWithGUI = not hideCircleWithGUI
    ShiftToggle.Text = "hide circle w/ gui · " .. (hideCircleWithGUI and "on" or "off")
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        ScreenGui.Enabled = guiVisible
        if hideCircleWithGUI then
            FOVring.Visible = aimb0tEnabled and guiVisible
        end
    end
end)
