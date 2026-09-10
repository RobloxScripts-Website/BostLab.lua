-- BoostLab Loader
-- Loads the embedded BoostLab LocalScript.
-- Generated from the supplied source file.

local source = [==[
-- ============================================================
-- BoostLab - Game Tools
-- LocalScript - place in StarterPlayerScripts or StarterGui
-- Available to every player who joins
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==== CONFIG ====
local ENEMY_FOLDER_NAME = "Enemies" -- NPC folder for aim assist targeting

-- ============================================================
-- INTRO ANIMATION - BoostLab, fullscreen purple waves
-- ============================================================
local function playIntro()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BoostLabIntro"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.Position = UDim2.new(0, 0, 0, 0)
	background.BackgroundColor3 = Color3.fromRGB(8, 0, 16)
	background.BorderSizePixel = 0
	background.ZIndex = 1
	background.Parent = screenGui

	local waveColors = {
		Color3.fromRGB(120, 0, 200),
		Color3.fromRGB(80, 0, 160),
		Color3.fromRGB(170, 50, 230),
		Color3.fromRGB(60, 0, 120),
	}

	for i, color in ipairs(waveColors) do
		local wave = Instance.new("Frame")
		wave.Size = UDim2.new(2, 0, 0.7, 0)
		wave.Position = UDim2.new(-0.5, 0, 0.35 + (i * 0.06), 0)
		wave.BackgroundColor3 = color
		wave.BackgroundTransparency = 0.45
		wave.BorderSizePixel = 0
		wave.ZIndex = i + 1
		wave.Parent = background

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = wave

		task.spawn(function()
			while wave.Parent do
				local tweenA = TweenService:Create(wave, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = UDim2.new(-0.15, 0, wave.Position.Y.Scale, 0),
				})
				tweenA:Play()
				tweenA.Completed:Wait()

				local tweenB = TweenService:Create(wave, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = UDim2.new(-0.65, 0, wave.Position.Y.Scale, 0),
				})
				tweenB:Play()
				tweenB.Completed:Wait()
			end
		end)
	end

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.8, 0, 0.22, 0)
	title.Position = UDim2.new(0.1, 0, 0.39, 0)
	title.BackgroundTransparency = 1
	title.Text = "BoostLab"
	title.TextColor3 = Color3.fromRGB(235, 210, 255)
	title.TextStrokeTransparency = 0.4
	title.TextStrokeColor3 = Color3.fromRGB(90, 0, 150)
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.ZIndex = 20
	title.TextTransparency = 1
	title.Parent = background

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(0.6, 0, 0.06, 0)
	subtitle.Position = UDim2.new(0.2, 0, 0.6, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "loading tools..."
	subtitle.TextColor3 = Color3.fromRGB(200, 170, 230)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextScaled = true
	subtitle.ZIndex = 20
	subtitle.TextTransparency = 1
	subtitle.Parent = background

	TweenService:Create(title, TweenInfo.new(1), { TextTransparency = 0 }):Play()
	TweenService:Create(subtitle, TweenInfo.new(1.4), { TextTransparency = 0.3 }):Play()

	-- Fade out after a short display time - Rayfield is triggered to load
	-- partway through so the window appears while the waves are still animating.
	task.delay(1.4, function()
		TweenService:Create(background, TweenInfo.new(1.2), { BackgroundTransparency = 0.55 }):Play()
		TweenService:Create(title, TweenInfo.new(1.2), { TextTransparency = 0.4 }):Play()
		TweenService:Create(subtitle, TweenInfo.new(1.2), { TextTransparency = 1 }):Play()
	end)

	task.delay(3.2, function()
		local fade = TweenService:Create(background, TweenInfo.new(0.8), { BackgroundTransparency = 1 })
		TweenService:Create(title, TweenInfo.new(0.8), { TextTransparency = 1 }):Play()
		fade:Play()
		fade.Completed:Wait()
		screenGui:Destroy()
	end)
end

playIntro()

-- Give the intro a moment to start animating before Rayfield's own
-- loading screen appears on top of it (so BoostLab is visible underneath).
task.wait(1.4)

-- ============================================================
-- RAYFIELD SETUP
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "BoostLab",
	LoadingTitle = "BoostLab",
	LoadingSubtitle = "Game Tools",
	ConfigurationSaving = { Enabled = true, FolderName = "BoostLab", FileName = "Settings" },
})

local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimAssistTab = Window:CreateTab("Aim Assist", 4483362458)
local FlyTab = Window:CreateTab("Fly", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- ============================================================
-- SHARED HELPERS
-- ============================================================
local TEAM_CHECK_ENABLED = true

local function isSameTeam(player)
	if not TEAM_CHECK_ENABLED then return false end
	if not LocalPlayer.Team or not player.Team then return false end
	return LocalPlayer.Team == player.Team
end

-- ============================================================
-- ESP TAB (boxes + snaplines, adjustable size + color, no highlight)
-- ============================================================
local espEnabled = false
local boxesEnabled = true
local snaplinesEnabled = true
local namesEnabled = true
local espColor = Color3.fromRGB(170, 60, 230)
local espSizeMultiplier = 1 -- adjustable scale for boxes/text

local espObjects = {} -- [player] = { billboard, boxDrawing, snapline }

local function destroyESPFor(player)
	local obj = espObjects[player]
	if not obj then return end
	if obj.billboard then obj.billboard:Destroy() end
	if obj.boxDrawing then obj.boxDrawing:Remove() end
	if obj.snapline then obj.snapline:Remove() end
	espObjects[player] = nil
end

local function createESPFor(player)
	if espObjects[player] then return end
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local obj = {}

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 150, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = espColor
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.Text = player.Name
	label.Parent = billboard
	obj.billboard = billboard

	local boxDrawing = Drawing.new("Square")
	boxDrawing.Thickness = 2
	boxDrawing.Color = espColor
	boxDrawing.Filled = false
	boxDrawing.Visible = false
	obj.boxDrawing = boxDrawing

	local snapline = Drawing.new("Line")
	snapline.Thickness = 1.5
	snapline.Color = espColor
	snapline.Visible = false
	obj.snapline = snapline

	espObjects[player] = obj
end

local function refreshAllESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if espEnabled then
				createESPFor(plr)
			else
				destroyESPFor(plr)
			end
		end
	end
end

local TEAMMATE_COLOR = Color3.fromRGB(60, 220, 100)

local function colorForPlayer(plr)
	if isSameTeam(plr) then
		return TEAMMATE_COLOR
	end
	return espColor
end

RunService.RenderStepped:Connect(function()
	if not espEnabled then return end

	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for plr, obj in pairs(espObjects) do
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local displayColor = colorForPlayer(plr)

		if hrp and obj.billboard and obj.billboard.Parent then
			local label = obj.billboard:FindFirstChildOfClass("TextLabel")
			if label then
				label.Visible = namesEnabled
				label.TextColor3 = displayColor
				if namesEnabled and myHrp then
					local dist = (hrp.Position - myHrp.Position).Magnitude
					local teamTag = isSameTeam(plr) and " [TEAM]" or ""
					label.Text = string.format("%s%s [%dm]", plr.Name, teamTag, math.floor(dist))
					label.TextSize = 16 * espSizeMultiplier
				end
			end

			local ok, cf, size = pcall(function()
				return char:GetBoundingBox()
			end)

			if ok and boxesEnabled then
				local screenPos, onScreen = Camera:WorldToViewportPoint(cf.Position)
				if onScreen then
					local scale = math.clamp((1000 / math.max(screenPos.Z, 1)) * espSizeMultiplier, 15, 500)
					obj.boxDrawing.Size = Vector2.new(scale * (size.X / size.Y), scale)
					obj.boxDrawing.Position = Vector2.new(screenPos.X - obj.boxDrawing.Size.X / 2, screenPos.Y - obj.boxDrawing.Size.Y / 2)
					obj.boxDrawing.Thickness = math.clamp(2 * espSizeMultiplier, 1, 6)
					obj.boxDrawing.Color = displayColor
					obj.boxDrawing.Visible = true
				else
					obj.boxDrawing.Visible = false
				end
			else
				obj.boxDrawing.Visible = false
			end

			if snaplinesEnabled then
				local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				if onScreen then
					local viewportSize = Camera.ViewportSize
					obj.snapline.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
					obj.snapline.To = Vector2.new(screenPos.X, screenPos.Y)
					obj.snapline.Thickness = math.clamp(1.5 * espSizeMultiplier, 1, 4)
					obj.snapline.Color = displayColor
					obj.snapline.Visible = true
				else
					obj.snapline.Visible = false
				end
			else
				obj.snapline.Visible = false
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		if espEnabled then createESPFor(plr) end
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	destroyESPFor(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		plr.CharacterAdded:Connect(function()
			task.wait(0.5)
			if espEnabled then createESPFor(plr) end
		end)
	end
end

ESPTab:CreateToggle({
	Name = "Enable ESP",
	CurrentValue = false,
	Flag = "ESPToggle",
	Callback = function(value)
		espEnabled = value
		refreshAllESP()
		Rayfield:Notify({ Title = "ESP " .. (value and "Enabled" or "Disabled"), Content = "", Duration = 2 })
	end,
})

ESPTab:CreateToggle({
	Name = "Show Boxes",
	CurrentValue = true,
	Flag = "ESPBoxesToggle",
	Callback = function(value)
		boxesEnabled = value
	end,
})

ESPTab:CreateToggle({
	Name = "Show Snaplines",
	CurrentValue = true,
	Flag = "ESPSnaplinesToggle",
	Callback = function(value)
		snaplinesEnabled = value
	end,
})

ESPTab:CreateToggle({
	Name = "Show Names",
	CurrentValue = true,
	Flag = "ESPNamesToggle",
	Callback = function(value)
		namesEnabled = value
	end,
})

ESPTab:CreateSlider({
	Name = "ESP Size",
	Range = { 25, 300 },
	Increment = 5,
	Suffix = "%",
	CurrentValue = 100,
	Flag = "ESPSizeSlider",
	Callback = function(value)
		espSizeMultiplier = value / 100
	end,
})

ESPTab:CreateColorPicker({
	Name = "ESP Color",
	Color = espColor,
	Flag = "ESPColorPicker",
	Callback = function(value)
		espColor = value
		for _, obj in pairs(espObjects) do
			if obj.boxDrawing then obj.boxDrawing.Color = value end
			if obj.snapline then obj.snapline.Color = value end
			local label = obj.billboard and obj.billboard:FindFirstChildOfClass("TextLabel")
			if label then label.TextColor3 = value end
		end
	end,
})

-- ============================================================
-- AIM ASSIST TAB (camera snaps toward NPC heads - "Enemies" folder ONLY, not players)
-- ============================================================
local MAX_ASSIST_RANGE = 25 -- pixel radius around crosshair to pick up a target
local MAX_DISTANCE = 600

local assistEnabled = false -- feature toggle
local assistHolding = false -- true only while right mouse button is held
local assistStrength = 0.3 -- 0-1, kept low by default - this is a LIGHT magnetism assist, not a snap/lock
local assistTargetPart = "Head" -- which body part to pull toward
local fovCircleEnabled = true

-- FOV circle - visualizes the detection radius on screen
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(170, 60, 230)
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.Transparency = 0.8
fovCircle.Visible = false

-- Light aim assist targets OTHER PLAYERS (arena PvP), not just NPCs.
-- It nudges the camera a small amount toward the nearest target near the
-- crosshair - it does not lock on or auto-track, so players still have to
-- aim and track manually. Strength is capped below to keep it a genuine
-- assist rather than an aimbot.
local MAX_STRENGTH_CAP = 0.7 -- hard ceiling - still an assist, not a hard lock
local currentAssistTarget = nil -- for hysteresis, so target doesn't flicker between near-equal candidates

local function getTargets()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and not isSameTeam(plr) then
			local part = plr.Character:FindFirstChild(assistTargetPart)
				or plr.Character:FindFirstChild("Head")
				or plr.Character:FindFirstChild("HumanoidRootPart")
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if part and hum and hum.Health > 0 then
				table.insert(list, part)
			end
		end
	end

	-- Also include NPCs in the Enemies folder if present, for PvE modes
	local folder = workspace:FindFirstChild(ENEMY_FOLDER_NAME)
	if folder then
		for _, model in ipairs(folder:GetChildren()) do
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local part = model:FindFirstChild(assistTargetPart)
					or model:FindFirstChild("Head")
					or model:FindFirstChild("HumanoidRootPart")
					or model.PrimaryPart
				if part then
					table.insert(list, part)
				end
			end
		end
	end

	return list
end

local function worldToScreen(pos)
	local screenPoint, onScreen = Camera:WorldToViewportPoint(pos)
	return Vector2.new(screenPoint.X, screenPoint.Y), onScreen, screenPoint.Z
end

-- Right mouse button held = assist active this frame
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		assistHolding = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		assistHolding = false
	end
end)

RunService.RenderStepped:Connect(function()
	-- Update FOV circle regardless of whether assist is actively pulling,
	-- so the player can always see their current detection radius.
	if fovCircleEnabled and assistEnabled then
		fovCircle.Position = UserInputService:GetMouseLocation()
		fovCircle.Radius = MAX_ASSIST_RANGE
		fovCircle.Visible = true
	else
		fovCircle.Visible = false
	end

	if not assistEnabled or not assistHolding or assistStrength <= 0 then return end

	local mousePos = UserInputService:GetMouseLocation()
	local targets = getTargets()

	local closestPart, closestScreenDist = nil, math.huge

	for _, part in ipairs(targets) do
		local screenPos, onScreen, depth = worldToScreen(part.Position)
		if onScreen and depth > 0 and depth < MAX_DISTANCE then
			local screenDist = (screenPos - mousePos).Magnitude
			if screenDist < MAX_ASSIST_RANGE and screenDist < closestScreenDist then
				closestScreenDist = screenDist
				closestPart = part
			end
		end
	end

	-- Hysteresis: if the currently-assisted target is still valid and roughly
	-- as close as the new candidate, keep it - this stops the assist jittering
	-- between two nearby targets. It does NOT keep aiming at a target that
	-- has gone off-screen or out of range; it only smooths selection among
	-- currently visible, in-range candidates.
	if currentAssistTarget and currentAssistTarget.Parent then
		local screenPos, onScreen, depth = worldToScreen(currentAssistTarget.Position)
		if onScreen and depth > 0 and depth < MAX_DISTANCE then
			local currentScreenDist = (screenPos - mousePos).Magnitude
			if currentScreenDist < MAX_ASSIST_RANGE and currentScreenDist <= closestScreenDist + 6 then
				closestPart = currentAssistTarget
				closestScreenDist = currentScreenDist
			end
		end
	end

	currentAssistTarget = closestPart

	if closestPart then
		-- Small, capped nudge toward the target - proportional to how close
		-- the crosshair already is. This helps stabilize aim without
		-- removing the need to track the target yourself.
		local cappedStrength = math.min(assistStrength, MAX_STRENGTH_CAP)
		local falloff = 1 - (closestScreenDist / MAX_ASSIST_RANGE)
		local pullAmount = cappedStrength * falloff * 0.55 -- more responsive, still gradual not instant

		local camPos = Camera.CFrame.Position
		local targetCFrame = CFrame.new(camPos, closestPart.Position)
		local newCFrame = Camera.CFrame:Lerp(targetCFrame, pullAmount)
		Camera.CFrame = newCFrame
	end
end)

AimAssistTab:CreateToggle({
	Name = "Enable Aim Assist",
	CurrentValue = false,
	Flag = "AimAssistToggle",
	Callback = function(value)
		assistEnabled = value
		Rayfield:Notify({ Title = "Aim Assist " .. (value and "Enabled" or "Disabled"), Content = "Hold right-click for a light aim nudge", Duration = 2 })
	end,
})

AimAssistTab:CreateDropdown({
	Name = "Target Part",
	Options = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" },
	CurrentOption = { "Head" },
	MultipleOptions = false,
	Flag = "AimAssistTargetPart",
	Callback = function(option)
		assistTargetPart = option[1]
	end,
})

AimAssistTab:CreateSlider({
	Name = "Assist Strength",
	Range = { 0, 100 },
	Increment = 5,
	Suffix = "%",
	CurrentValue = 50,
	Flag = "AimAssistStrength",
	Callback = function(value)
		assistStrength = value / 100
	end,
})

AimAssistTab:CreateToggle({
	Name = "Show FOV Circle",
	CurrentValue = true,
	Flag = "FOVCircleToggle",
	Callback = function(value)
		fovCircleEnabled = value
	end,
})

AimAssistTab:CreateColorPicker({
	Name = "FOV Circle Color",
	Color = Color3.fromRGB(170, 60, 230),
	Flag = "FOVCircleColor",
	Callback = function(value)
		fovCircle.Color = value
	end,
})

AimAssistTab:CreateSlider({
	Name = "Detection Radius (FOV)",
	Range = { 5, 150 },
	Increment = 5,
	Suffix = "px",
	CurrentValue = 25,
	Flag = "AimAssistRadius",
	Callback = function(value)
		MAX_ASSIST_RANGE = value
	end,
})

-- ============================================================
-- FLY TAB
-- ============================================================
local flying = false
local flySpeed = 50
local bodyVelocity, bodyGyro
local flyConnection

local function getHRP()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function startFly()
	local hrp = getHRP()
	if not hrp or flying then return end
	flying = true

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = hrp

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 3000
	bodyGyro.Parent = hrp

	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = true
	end

	flyConnection = RunService.RenderStepped:Connect(function()
		local hrpNow = getHRP()
		if not hrpNow or not bodyVelocity then return end

		local camera = workspace.CurrentCamera
		local moveVector = Vector3.new(0, 0, 0)

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveVector += camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveVector -= camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveVector -= camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveVector += camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveVector += Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			moveVector += Vector3.new(0, -1, 0)
		end

		if moveVector.Magnitude > 0 then
			moveVector = moveVector.Unit * flySpeed
		end

		bodyVelocity.Velocity = moveVector
		bodyGyro.CFrame = camera.CFrame
	end)
end

local function stopFly()
	flying = false
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end

	local char = LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	flying = false
	bodyVelocity = nil
	bodyGyro = nil
end)

FlyTab:CreateToggle({
	Name = "Enable Fly",
	CurrentValue = false,
	Flag = "FlyToggle",
	Callback = function(value)
		if value then
			startFly()
		else
			stopFly()
		end
		Rayfield:Notify({ Title = "Fly " .. (value and "Enabled" or "Disabled"), Content = "", Duration = 2 })
	end,
})

FlyTab:CreateSlider({
	Name = "Fly Speed",
	Range = { 10, 200 },
	Increment = 10,
	Suffix = " studs/s",
	CurrentValue = 50,
	Flag = "FlySpeedSlider",
	Callback = function(value)
		flySpeed = value
	end,
})

-- ==== Walk Speed / Jump Power ====
local function applyToHumanoid(applyFn)
	local char = LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		applyFn(humanoid)
	end
end

local currentWalkSpeed = 16
local currentJumpPower = 50

LocalPlayer.CharacterAdded:Connect(function(char)
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.WalkSpeed = currentWalkSpeed
	humanoid.JumpPower = currentJumpPower
end)

FlyTab:CreateSlider({
	Name = "Walk Speed",
	Range = { 16, 150 },
	Increment = 2,
	Suffix = " studs/s",
	CurrentValue = 16,
	Flag = "WalkSpeedSlider",
	Callback = function(value)
		currentWalkSpeed = value
		applyToHumanoid(function(h) h.WalkSpeed = value end)
	end,
})

FlyTab:CreateSlider({
	Name = "Jump Power",
	Range = { 50, 300 },
	Increment = 10,
	Suffix = "",
	CurrentValue = 50,
	Flag = "JumpPowerSlider",
	Callback = function(value)
		currentJumpPower = value
		applyToHumanoid(function(h) h.JumpPower = value end)
	end,
})

-- ============================================================
-- MISC TAB (community links)
-- ============================================================
MiscTab:CreateToggle({
	Name = "Team Check (hide/exclude teammates)",
	CurrentValue = true,
	Flag = "TeamCheckToggle",
	Callback = function(value)
		TEAM_CHECK_ENABLED = value
		refreshAllESP()
		Rayfield:Notify({ Title = "Team Check " .. (value and "Enabled" or "Disabled"), Content = "", Duration = 2 })
	end,
})

MiscTab:CreateParagraph({
	Title = "BoostLab Community",
	Content = "Join our Discord for updates, support and to suggest features. Subscribe on YouTube for showcases and tutorials.",
})

MiscTab:CreateButton({
	Name = "Copy Discord Link",
	Callback = function()
		setclipboard("https://discord.gg/RfVsQcyUZp")
		Rayfield:Notify({ Title = "Copied!", Content = "Discord link copied to clipboard", Duration = 3 })
	end,
})

MiscTab:CreateButton({
	Name = "Copy YouTube Link",
	Callback = function()
		setclipboard("https://www.youtube.com/@BoostLab-dll")
		Rayfield:Notify({ Title = "Copied!", Content = "YouTube link copied to clipboard", Duration = 3 })
	end,
})
]==]

local chunk, err = loadstring(source)
if not chunk then
    error("BoostLab Loader failed to compile: " .. tostring(err))
end

return chunk()
