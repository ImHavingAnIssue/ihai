-- Simple Reset GUI | Made by @L3KKX

local UIS = game:GetService("UserInputService")
local PS = game:GetService("Players")
local SG = game:GetService("StarterGui")
local LP = PS.LocalPlayer
local brand = "Made by @L3KKX"

-- DISABLE ROBLOX DEFAULT RESET (THIS IS THE FIX)
pcall(function()
	SG:SetCore("ResetButtonCallback", false)
end)

local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "SimpleResetGUI"

local function corner(o, r)
	local c = Instance.new("UICorner", o)
	c.CornerRadius = UDim.new(0, r)
end

local cfg = "SimpleReset_L3KKX_Config.txt"

local themes = {
	["Neon Purple"] = Color3.fromRGB(140, 0, 255),
	["Neo Blue"] = Color3.fromRGB(0, 170, 255),
	["Matrix Green"] = Color3.fromRGB(0, 200, 0),
	["Carbon Black"] = Color3.fromRGB(20, 20, 20),
	["Red Inferno"] = Color3.fromRGB(200, 0, 0)
}

local theme = "Carbon Black"
local resetKey = Enum.KeyCode.R
local toggleKey = Enum.KeyCode.RightControl

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 310, 0, 190)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = themes[theme]
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.new(0, 0, 0)
corner(frame, 12)

-- Dragging
local drag, dragPos, framePos = false
frame.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		dragPos = i.Position
		framePos = frame.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				drag = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(i)
	if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragPos
		frame.Position = UDim2.new(
			framePos.X.Scale,
			framePos.X.Offset + d.X,
			framePos.Y.Scale,
			framePos.Y.Offset + d.Y
		)
	end
end)

local font = Enum.Font.GothamBold

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Simple Reset"
title.Font = font
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1

local setBtn = Instance.new("TextButton", frame)
setBtn.Size = UDim2.new(0, 24, 0, 24)
setBtn.Position = UDim2.new(1, -28, 0, 4)
setBtn.Text = "⚙"
setBtn.Font = font
setBtn.TextScaled = true
setBtn.TextColor3 = Color3.new(1, 1, 1)
setBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
corner(setBtn, 8)

local wm = Instance.new("TextLabel", frame)
wm.Size = UDim2.new(1, 0, 0, 20)
wm.Position = UDim2.new(0, 0, 0, 170)
wm.Text = brand
wm.Font = font
wm.TextScaled = true
wm.TextColor3 = Color3.new(1, 1, 1)
wm.BackgroundTransparency = 1

local keyTxt = Instance.new("TextLabel", frame)
keyTxt.Size = UDim2.new(1, 0, 0, 26)
keyTxt.Position = UDim2.new(0, 0, 0, 40)
keyTxt.Text = "Reset Key: R"
keyTxt.Font = font
keyTxt.TextScaled = true
keyTxt.TextColor3 = Color3.new(1, 1, 1)
keyTxt.BackgroundTransparency = 1

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0, 50, 0, 50)
box.Position = UDim2.new(0.5, -25, 0, 80)
box.PlaceholderText = "Key"
box.Text = ""
box.TextColor3 = Color3.new(1, 1, 1)
box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
box.Font = font
box.TextScaled = true
corner(box, 10)

local toggleTxt = Instance.new("TextLabel", frame)
toggleTxt.Size = UDim2.new(1, 0, 0, 18)
toggleTxt.Position = UDim2.new(0, 0, 0, 140)
toggleTxt.Text = "Toggle GUI: RightControl"
toggleTxt.Font = Enum.Font.Gotham
toggleTxt.TextScaled = true
toggleTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleTxt.BackgroundTransparency = 1

local sp = {
	ALT = Enum.KeyCode.LeftAlt,
	RIGHTALT = Enum.KeyCode.RightAlt,
	CTRL = Enum.KeyCode.LeftControl,
	RIGHTCTRL = Enum.KeyCode.RightControl,
	SHIFT = Enum.KeyCode.LeftShift,
	RIGHTSHIFT = Enum.KeyCode.RightShift
}

UIS.InputBegan:Connect(function(i, g)
	if g then return end

	if i.KeyCode == resetKey and LP.Character then
		LP.Character:BreakJoints()
	end

	if i.KeyCode == toggleKey then
		gui.Enabled = not gui.Enabled
	end
end)

box:GetPropertyChangedSignal("Text"):Connect(function()
	local t = box.Text:upper()
	if #t > 1 and not sp[t] then
		box.Text = t:sub(1, 1)
		t = box.Text
	end

	if sp[t] then
		resetKey = sp[t]
		keyTxt.Text = "Reset Key: " .. t
	elseif #t == 1 and Enum.KeyCode[t] then
		resetKey = Enum.KeyCode[t]
		keyTxt.Text = "Reset Key: " .. t
	end
end)
