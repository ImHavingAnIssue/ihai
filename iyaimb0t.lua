local teamCheck = false
local fov = 150


local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1.5
FOVring.Radius = fov
FOVring.Transparency = 1
FOVring.Color = Color3.fromRGB(255, 128, 128)

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local Header = Instance.new("Frame", Frame)
local HeaderLabel = Instance.new("TextLabel", Header)
local ToggleButton = Instance.new("TextButton", Frame)
local TeamCheckButton = Instance.new("TextButton", Frame)  -- Team Check Button
local IYButton = Instance.new("TextButton", Frame)
local FOVSliderFrame = Instance.new("Frame", Frame)
local FOVSliderBar = Instance.new("Frame", FOVSliderFrame)

ScreenGui.Name = "aimb0tGUI"
Frame.Size = UDim2.new(0, 150, 0, 200)  -- Increased size of the UI
Frame.Position = UDim2.new(0, 20, 0, 20)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.BorderSizePixel = 0

Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BorderSizePixel = 0

HeaderLabel.Size = UDim2.new(1, 0, 1, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "hex iy+aimb0t"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.TextSize = 14

ToggleButton.Size = UDim2.new(0, 130, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleButton.Text = "aimb0t · off"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)

TeamCheckButton.Size = UDim2.new(0, 130, 0, 30)  -- Team Check Button Setup
TeamCheckButton.Position = UDim2.new(0, 10, 0, 80)
TeamCheckButton.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
TeamCheckButton.Text = "team check · off"
TeamCheckButton.TextColor3 = Color3.new(1, 1, 1)

IYButton.Size = UDim2.new(0, 130, 0, 30)
IYButton.Position = UDim2.new(0, 10, 0, 120)
IYButton.BackgroundColor3 = Color3.fromRGB(120, 100, 180)
IYButton.Text = "infinite yield"
IYButton.TextColor3 = Color3.new(1, 1, 1)

FOVSliderFrame.Size = UDim2.new(0, 130, 0, 20)
FOVSliderFrame.Position = UDim2.new(0, 10, 0, 160)
FOVSliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

FOVSliderBar.Size = UDim2.new(fov / 300, 0, 1, 0)
FOVSliderBar.BackgroundColor3 = Color3.fromRGB(255, 128, 128)
FOVSliderBar.Parent = FOVSliderFrame

local aimb0tEnabled = false
local guiVisible = true

-- Dragging Functionality
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
    FOVring.Visible = aimb0tEnabled
end

local function updateFOV(percentage)
    fov = math.clamp(math.floor(percentage * 300), 50, 300) -- FOV range: 50 to 300
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

-- Toggle GUI visibility with RightShift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        ScreenGui.Enabled = guiVisible
    end
end)

-- aimb0t Logic
local function getClosest(cframe)
    local closestTarget = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (player.Team ~= LocalPlayer.Team or not teamCheck) then
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local headPosition = character.Head.Position
                local screenPoint, onScreen = Camera:WorldToViewportPoint(headPosition)
                if onScreen then
                    local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - FOVring.Position).Magnitude
                    if screenDistance < closestDistance and screenDistance < fov then
                        closestDistance = screenDistance
                        closestTarget = player
                    end
                end
            end
        end
    end

    return closestTarget
end

local loop
loop = RunService.RenderStepped:Connect(function()
    FOVring.Position = Camera.ViewportSize / 2

    if aimb0tEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closestTarget = getClosest(Camera.CFrame)
        if closestTarget and closestTarget.Character and closestTarget.Character:FindFirstChild("Head") then
            local targetPosition = closestTarget.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        end
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.Delete) then
        loop:Disconnect()
        FOVring:Remove()
        ScreenGui:Destroy()
    end
end)
