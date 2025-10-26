local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- cleanup if re-executed
if game.CoreGui:FindFirstChild("NameDisplayGui") then
	game.CoreGui.NameDisplayGui:Destroy()
end

-- gui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NameDisplayGui"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 110)
Frame.Position = UDim2.new(0.5, -110, 0.5, -55)
Frame.BackgroundColor3 = Color3.fromRGB(40, 50, 70) -- dark blue tint
Frame.BorderSizePixel = 1
Frame.Parent = ScreenGui

-- title bar with label
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 16)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
TitleBar.BorderSizePixel = 1
TitleBar.Parent = Frame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "user2display"
TitleText.TextColor3 = Color3.fromRGB(200, 210, 230)
TitleText.TextSize = 11
TitleText.Font = Enum.Font.SourceSansBold
TitleText.Parent = TitleBar

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, 0, 0, 24)
InputBox.Position = UDim2.new(0, 0, 0, 18)
InputBox.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
InputBox.TextColor3 = Color3.fromRGB(230, 230, 240)
InputBox.TextSize = 11
InputBox.PlaceholderText = "type username..."
InputBox.ClearTextOnFocus = false
InputBox.Parent = Frame

local ResultLabel = Instance.new("TextLabel")
ResultLabel.Size = UDim2.new(1, 0, 0, 24)
ResultLabel.Position = UDim2.new(0, 0, 0, 44)
ResultLabel.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
ResultLabel.TextColor3 = Color3.fromRGB(220, 225, 240)
ResultLabel.TextSize = 11
ResultLabel.Text = ""
ResultLabel.Parent = Frame

local SwitchButton = Instance.new("TextButton")
SwitchButton.Size = UDim2.new(1, 0, 0, 24)
SwitchButton.Position = UDim2.new(0, 0, 0, 70)
SwitchButton.BackgroundColor3 = Color3.fromRGB(60, 70, 100)
SwitchButton.TextColor3 = Color3.fromRGB(240, 240, 255)
SwitchButton.TextSize = 10
SwitchButton.Text = "switch to display → username"
SwitchButton.Parent = Frame

-- dragging setup
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
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

-- logic + focus
local mode = "username_to_display"
local textFocused = false

InputBox.Focused:Connect(function() textFocused = true end)
InputBox.FocusLost:Connect(function() textFocused = false end)

local function updateLabel()
	local inputText = InputBox.Text:lower()
	local result = "no match found"

	for _, player in ipairs(Players:GetPlayers()) do
		if mode == "username_to_display" then
			if player.Name:lower():find(inputText) then
				result = "display name: " .. player.DisplayName
				break
			end
		else
			if player.DisplayName:lower():find(inputText) then
				result = "username: " .. player.Name
				break
			end
		end
	end

	ResultLabel.Text = result
end

InputBox:GetPropertyChangedSignal("Text"):Connect(updateLabel)

SwitchButton.MouseButton1Click:Connect(function()
	if mode == "username_to_display" then
		mode = "display_to_username"
		InputBox.PlaceholderText = "type display name..."
		SwitchButton.Text = "switch to username → display"
	else
		mode = "username_to_display"
		InputBox.PlaceholderText = "type username..."
		SwitchButton.Text = "switch to display → username"
	end
	updateLabel()
end)

-- toggle + delete
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift and not textFocused then
		ScreenGui.Enabled = not ScreenGui.Enabled
	elseif input.KeyCode == Enum.KeyCode.Delete then
		ScreenGui:Destroy()
	end
end)

RunService.RenderStepped:Connect(updateLabel)
