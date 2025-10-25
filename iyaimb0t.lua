-- integrated aimb0t + hitbox expander (client-side / studio/dev testing)
local teamCheck = false 
local fov = 150
local hideCircleWithGUI = true

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- try to create a real Drawing circle if available (exploit environments)
local FOVring
if typeof(Drawing) == "table" and Drawing.New then
    -- some exploit environments use Drawing.new (lowercase/new variations exist)
    local success, circle = pcall(function()
        return Drawing.new and Drawing.new("Circle") or Drawing.New("Circle")
    end)
    if success and circle then
        FOVring = circle
        FOVring.Visible = false
        FOVring.Thickness = 1.5
        FOVring.Radius = fov
        FOVring.Transparency = 1
        FOVring.Color = Color3.fromRGB(255, 128, 128)
        FOVring.Position = Vector2.new(0,0)
    else
        FOVring = { Position = Vector2.new(0,0), Radius = fov, Visible = false }
        warn("Drawing API not available: using fallback FOV object.")
    end
else
    -- fallback table (won't draw anything, but keeps logic running)
    FOVring = { Position = Vector2.new(0,0), Radius = fov, Visible = false }
    warn("Drawing API not available: using fallback FOV object.")
end

-- GUI Setup (original behavior: parent to CoreGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "aimb0tGUI"
-- try to parent to CoreGui (as in non-studio exploit environment). fallback to PlayerGui if CoreGui restricted.
if pcall(function() game:GetService("CoreGui").Name end) then
    pcall(function() ScreenGui.Parent = game.CoreGui end)
end
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

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

-- style color for primary buttons (matches aimb0t button)
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

-- hide circle / gui button (now same style as aimb0t button)
local ShiftToggle = Instance.new("TextButton", SettingsTab)
ShiftToggle.Size = UDim2.new(1, -10, 0, 30)
ShiftToggle.Position = UDim2.new(0, 5, 0, 30)
ShiftToggle.Text = "hide circle w/ gui · on"
ShiftToggle.BackgroundColor3 = primaryButtonColor
ShiftToggle.TextColor3 = Color3.new(1, 1, 1)

-- HITBOX EXPANDER UI - no separate title; status dot in the button text like others
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

local hitboxSize = 50 -- default size
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

-- Toggles
local aimb0tEnabled = false
local guiVisible = true

-- Hitbox logic state
local hitboxEnabled = false
local originalSizes = {} -- store original sizes per player (HumanoidRootPart.Size) to restore later

-- Dragging
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

-- Logic
local function toggleaimb0t()
    aimb0tEnabled = not aimb0tEnabled
    ToggleButton.Text = "aimb0t · " .. (aimb0tEnabled and "on" or "off")
    FOVring.Visible = aimb0tEnabled and guiVisible and not (hideCircleWithGUI and not guiVisible)
end

local function updateFOV(percentage)
    fov = math.clamp(math.floor(percentage * 300), 50, 300)
    FOVring.Radius = fov
    if FOVSliderBar and FOVSliderBar.Size then
        FOVSliderBar.Size = UDim2.new(fov / 300, 0, 1, 0)
    end
end

ToggleButton.MouseButton1Click:Connect(toggleaimb0t)

-- FOV slider interaction
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
    -- note: this uses HttpGet + loadstring typical in exploit envs; may error in normal RBX environments
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
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

-- Toggle GUI visibility with RightShift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        -- ScreenGui may not support 'Enabled' in some contexts; do a pcall to be safe
        pcall(function() ScreenGui.Enabled = guiVisible end)
        if hideCircleWithGUI then
            FOVring.Visible = aimb0tEnabled and guiVisible
        end
    end
end)

-- Hitbox UI interactions
HitboxToggle.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    HitboxToggle.Text = "hitbox expander · " .. (hitboxEnabled and "on" or "off")

    if not hitboxEnabled then
        -- restore original sizes if we have them
        for player, originalSize in pairs(originalSizes) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = player.Character.HumanoidRootPart
                    hrp.Size = originalSize
                    hrp.Transparency = 0
                    hrp.CanCollide = true
                    hrp.BrickColor = BrickColor.new("Medium stone grey")
                    hrp.Material = Enum.Material.SmoothPlastic
                end)
            end
        end
        originalSizes = {}
    end
end)

-- slider for hitbox size (click and drag)
HitboxSliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local relativeX = math.clamp((mousePos.X - HitboxSliderFrame.AbsolutePosition.X) / HitboxSliderFrame.AbsoluteSize.X, 0, 1)
            hitboxSize = math.clamp(math.floor(relativeX * 300), 10, 300)
            HitboxSliderBar.Size = UDim2.new(hitboxSize / 300, 0, 1, 0)
            HitboxValueLabel.Text = "size · " .. tostring(hitboxSize) .. " (default = 50)"
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                conn:Disconnect()
            end
        end)
    end
end)

-- Aimbot targeting
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
                    local screenPos2 = Vector2.new(screenPoint.X, screenPoint.Y)
                    local ringPos = FOVring.Position or (Camera.ViewportSize / 2)
                    local screenDistance = (screenPos2 - ringPos).Magnitude
                    if screenDistance < closestDistance and screenDistance < (FOVring.Radius or fov) then
                        closestDistance = screenDistance
                        closestTarget = player
                    end
                end
            end
        end
    end

    return closestTarget
end

-- Helper to apply hitbox visuals/sizing
local function applyHitboxToPlayer(player, size)
    if not player or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function()
        if not originalSizes[player] then
            originalSizes[player] = hrp.Size
        end

        hrp.Size = Vector3.new(size, size, size)
        hrp.Transparency = 0.7
        hrp.BrickColor = BrickColor.new("Really blue")
        hrp.Material = Enum.Material.Neon
        hrp.CanCollide = false
    end)
end

-- Loop
local loop
loop = RunService.RenderStepped:Connect(function()
    -- update FOVring position for drawing calculations
    local viewportCenter = Camera.ViewportSize / 2
    if FOVring and FOVring.Position ~= nil then
        -- if it's a Drawing circle, its Position expects Vector2
        pcall(function() FOVring.Position = viewportCenter end)
    end

    -- draw the circle if using Drawing
    if typeof(FOVring) == "table" and FOVring.Radius and FOVring.Visible and (getmetatable(FOVring) ~= nil) then
        -- if this is a real Drawing object, ensure properties are up-to-date
        pcall(function()
            FOVring.Radius = fov
            FOVring.Position = viewportCenter
            -- color/visibility already handled elsewhere
        end)
    end

    -- aimbot aim (right mouse button to aim)
    if aimb0tEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closestTarget = getClosest(Camera.CFrame)
        if closestTarget and closestTarget.Character and closestTarget.Character:FindFirstChild("Head") then
            local targetPosition = closestTarget.Character.Head.Position
            -- attempt to set camera to look at target (works in most exploit clients)
            pcall(function()
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
            end)
        end
    end

    -- hitbox expander behavior (client-side)
    if hitboxEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and (player.Team ~= LocalPlayer.Team or not teamCheck) then
                applyHitboxToPlayer(player, hitboxSize)
            end
        end
    end

    -- visibility of FOV ring
    if not (ScreenGui and ScreenGui.Enabled) and hideCircleWithGUI then
        if type(FOVring.Visible) ~= "nil" then
            pcall(function() FOVring.Visible = false end)
        end
    elseif aimb0tEnabled and (ScreenGui and ScreenGui.Enabled) then
        pcall(function() FOVring.Visible = true end)
    end

    -- cleanup / destroy on Delete key
    if UserInputService:IsKeyDown(Enum.KeyCode.Delete) then
        if loop then loop:Disconnect() end
        pcall(function()
            if type(FOVring.Remove) == "function" then
                FOVring:Remove()
            elseif type(FOVring) == "table" then
                -- nothing to remove for fallback
            end
        end)

        -- restore sizes on exit if we modified them
        for player, originalSize in pairs(originalSizes) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = player.Character.HumanoidRootPart
                    hrp.Size = originalSize
                    hrp.Transparency = 0
                    hrp.CanCollide = true
                    hrp.BrickColor = BrickColor.new("Medium stone grey")
                    hrp.Material = Enum.Material.SmoothPlastic
                end)
            end
        end

        pcall(function() ScreenGui:Destroy() end)
    end
end)
