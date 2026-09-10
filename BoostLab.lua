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
-- INTRO ANIMATION - BoostLab polished startup
-- ============================================================
local function playIntro()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("BoostLabIntro")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "BoostLabIntro"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 99999
	gui.Parent = playerGui

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundColor3 = Color3.fromRGB(4, 2, 9)
	root.BorderSizePixel = 0
	root.Parent = gui

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 2, 12)),
		ColorSequenceKeypoint.new(0.48, Color3.fromRGB(31, 7, 54)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 2, 10)),
	})
	bgGradient.Rotation = 35
	bgGradient.Parent = root

	local glow = Instance.new("Frame")
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.Position = UDim2.fromScale(0.5, 0.43)
	glow.Size = UDim2.fromScale(0.18, 0.18)
	glow.BackgroundColor3 = Color3.fromRGB(170, 55, 255)
	glow.BackgroundTransparency = 0.74
	glow.BorderSizePixel = 0
	glow.Parent = root
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(1, 0)
	glowCorner.Parent = glow
	local glowScale = Instance.new("UIScale")
	glowScale.Scale = 0.7
	glowScale.Parent = glow

	local rings = {}
	for i = 1, 3 do
		local ring = Instance.new("Frame")
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromScale(0.5, 0.43)
		ring.Size = UDim2.fromScale(0.17 + i * 0.045, 0.17 + i * 0.045)
		ring.BackgroundTransparency = 1
		ring.BorderSizePixel = 0
		ring.Parent = root

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(176, 65, 245)
		stroke.Transparency = 0.55 + i * 0.1
		stroke.Thickness = 1.5
		stroke.Parent = ring

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = ring
		rings[i] = ring
	end

	local logo = Instance.new("TextLabel")
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.fromScale(0.5, 0.43)
	logo.Size = UDim2.fromScale(0.62, 0.14)
	logo.BackgroundTransparency = 1
	logo.Text = "BOOSTLAB"
	logo.Font = Enum.Font.GothamBlack
	logo.TextScaled = true
	logo.TextColor3 = Color3.fromRGB(250, 241, 255)
	logo.TextStrokeColor3 = Color3.fromRGB(154, 45, 235)
	logo.TextStrokeTransparency = 0.25
	logo.TextTransparency = 1
	logo.Parent = root

	local sub = Instance.new("TextLabel")
	sub.AnchorPoint = Vector2.new(0.5, 0.5)
	sub.Position = UDim2.fromScale(0.5, 0.535)
	sub.Size = UDim2.fromScale(0.55, 0.045)
	sub.BackgroundTransparency = 1
	sub.Text = "INITIALIZING  •  GAME TOOLS"
	sub.Font = Enum.Font.GothamMedium
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromRGB(205, 177, 225)
	sub.TextTransparency = 1
	sub.Parent = root

	local status = Instance.new("TextLabel")
	status.AnchorPoint = Vector2.new(0.5, 0.5)
	status.Position = UDim2.fromScale(0.5, 0.59)
	status.Size = UDim2.fromScale(0.5, 0.035)
	status.BackgroundTransparency = 1
	status.Text = "Loading modules..."
	status.Font = Enum.Font.Gotham
	status.TextScaled = true
	status.TextColor3 = Color3.fromRGB(167, 133, 190)
	status.TextTransparency = 1
	status.Parent = root

	local track = Instance.new("Frame")
	track.AnchorPoint = Vector2.new(0.5, 0.5)
	track.Position = UDim2.fromScale(0.5, 0.67)
	track.Size = UDim2.fromScale(0.34, 0.009)
	track.BackgroundColor3 = Color3.fromRGB(45, 25, 58)
	track.BackgroundTransparency = 0.2
	track.BorderSizePixel = 0
	track.Parent = root
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(196, 76, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local percent = Instance.new("TextLabel")
	percent.AnchorPoint = Vector2.new(0.5, 0.5)
	percent.Position = UDim2.fromScale(0.5, 0.705)
	percent.Size = UDim2.fromScale(0.12, 0.03)
	percent.BackgroundTransparency = 1
	percent.Text = "0%"
	percent.Font = Enum.Font.GothamBold
	percent.TextScaled = true
	percent.TextColor3 = Color3.fromRGB(210, 180, 235)
	percent.TextTransparency = 1
	percent.Parent = root

	local statuses = {
		"Loading modules...",
		"Preparing visuals...",
		"Preparing movement...",
		"Preparing controls...",
		"BoostLab ready."
	}

	TweenService:Create(glowScale, TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1.35}):Play()
	TweenService:Create(logo, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	local _introPulse = task.spawn(function()
		while logo.Parent do
			TweenService:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextStrokeTransparency = 0.05, TextTransparency = 0.02}):Play()
			task.wait(0.9)
			TweenService:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextStrokeTransparency = 0.45, TextTransparency = 0.08}):Play()
			task.wait(0.9)
		end
	end)
	task.delay(0.18, function()
		TweenService:Create(sub, TweenInfo.new(0.55), {TextTransparency = 0.15}):Play()
	end)
	task.delay(0.3, function()
		TweenService:Create(status, TweenInfo.new(0.45), {TextTransparency = 0.2}):Play()
		TweenService:Create(percent, TweenInfo.new(0.45), {TextTransparency = 0.1}):Play()
	end)

	for i, ring in ipairs(rings) do
		task.spawn(function()
			local direction = (i % 2 == 0) and 1 or -1
			while ring.Parent do
				TweenService:Create(ring, TweenInfo.new(2.2 + i * 0.35, Enum.EasingStyle.Linear), {
					Rotation = ring.Rotation + 360 * direction
				}):Play()
				task.wait(2.2 + i * 0.35)
			end
		end)
	end

	local duration = 2.8
	local start = os.clock()
	while true do
		local alpha = math.clamp((os.clock() - start) / duration, 0, 1)
		local eased = 1 - (1 - alpha)^3
		fill.Size = UDim2.new(eased, 0, 1, 0)
		percent.Text = string.format("%d%%", math.floor(eased * 100 + 0.5))
		status.Text = statuses[math.clamp(math.floor(alpha * #statuses) + 1, 1, #statuses)]
		if alpha >= 1 then break end
		RunService.RenderStepped:Wait()
	end

	task.wait(0.18)
	TweenService:Create(root, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
	TweenService:Create(logo, TweenInfo.new(0.45), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	TweenService:Create(sub, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
	TweenService:Create(status, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
	TweenService:Create(percent, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
	TweenService:Create(track, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	TweenService:Create(glow, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	task.wait(0.65)
	gui:Destroy()
end

playIntro()

-- ============================================================
-- RAYFIELD SETUP
-- ============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "BoostLab",
	LoadingTitle = "BoostLab",
	LoadingSubtitle = "Clean • Fast • Simple",
	ConfigurationSaving = { Enabled = true, FolderName = "BoostLab", FileName = "Settings" },
})

local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
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
-- VISUALS TAB
-- ============================================================
VisualsTab:CreateParagraph({
	Title = "Visuals",
	Content = "ESP tools for players and targets. Use the controls below to keep the overlay clean.",
})
VisualsTab:CreateSection("ESP")

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

local function hasLineOfSight(part)
	local character = LocalPlayer.Character
	local origin = Camera.CFrame.Position
	local direction = part.Position - origin

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = character and {character} or {}
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, params)
	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(part.Parent)
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

VisualsTab:CreateToggle({
	Name = "Enable ESP",
	CurrentValue = false,
	Flag = "ESPToggle",
	Callback = function(value)
		espEnabled = value
		refreshAllESP()
		Rayfield:Notify({ Title = "ESP " .. (value and "Enabled" or "Disabled"), Content = "", Duration = 2 })
	end,
})

VisualsTab:CreateToggle({
	Name = "Show Boxes",
	CurrentValue = true,
	Flag = "ESPBoxesToggle",
	Callback = function(value)
		boxesEnabled = value
	end,
})

VisualsTab:CreateToggle({
	Name = "Show Snaplines",
	CurrentValue = true,
	Flag = "ESPSnaplinesToggle",
	Callback = function(value)
		snaplinesEnabled = value
	end,
})

VisualsTab:CreateToggle({
	Name = "Show Names",
	CurrentValue = true,
	Flag = "ESPNamesToggle",
	Callback = function(value)
		namesEnabled = value
	end,
})

VisualsTab:CreateSlider({
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

VisualsTab:CreateColorPicker({
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
-- COMBAT TAB
-- ============================================================
CombatTab:CreateParagraph({
	Title = "Combat",
	Content = "Aim-assist controls with adjustable target part, strength and FOV.",
})
CombatTab:CreateSection("Aim Assist")

local MAX_ASSIST_RANGE = 180 -- larger detection radius around crosshair
local MAX_DISTANCE = 1500

local assistEnabled = false -- feature toggle
local assistHolding = false -- true only while right mouse button is held
local assistStrength = 0.85 -- strong, smooth camera assistance
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
local MAX_STRENGTH_CAP = 1.0
local currentAssistTarget = nil -- stable target selection

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

	if not assistEnabled or not assistHolding or assistStrength <= 0 then
		currentAssistTarget = nil
		return
	end

	local mousePos = UserInputService:GetMouseLocation()
	local targets = getTargets()

	local closestPart, closestScreenDist = nil, math.huge

	for _, part in ipairs(targets) do
		local screenPos, onScreen, depth = worldToScreen(part.Position)
		if onScreen and depth > 0 and depth < MAX_DISTANCE then
			local screenDist = (screenPos - mousePos).Magnitude
			if screenDist < MAX_ASSIST_RANGE and hasLineOfSight(part) then
				-- Prefer targets close to the crosshair, with a small distance penalty.
				local score = screenDist + (depth / 6000)
				if score < closestScreenDist then
					closestScreenDist = score
					closestPart = part
				end
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
		local pullAmount = math.clamp(cappedStrength * (0.35 + falloff * 0.65), 0.05, 0.55)

		local camPos = Camera.CFrame.Position
		local targetCFrame = CFrame.new(camPos, closestPart.Position)
		local newCFrame = Camera.CFrame:Lerp(targetCFrame, pullAmount)
		Camera.CFrame = newCFrame
	end
end)

CombatTab:CreateParagraph({
	Title = "Improved Targeting",
	Content = "Smooth target selection, visibility check and stable target retention. Hold right-click while Aim Assist is enabled.",
})

CombatTab:CreateToggle({
	Name = "Enable Aim Assist",
	CurrentValue = false,
	Flag = "AimAssistToggle",
	Callback = function(value)
		assistEnabled = value
		if not value then currentAssistTarget = nil end
		Rayfield:Notify({ Title = "Aim Assist " .. (value and "Enabled" or "Disabled"), Content = "Hold right-click for a light aim nudge", Duration = 2 })
	end,
})

CombatTab:CreateDropdown({
	Name = "Target Part",
	Options = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" },
	CurrentOption = { "Head" },
	MultipleOptions = false,
	Flag = "AimAssistTargetPart",
	Callback = function(option)
		assistTargetPart = option[1]
	end,
})

CombatTab:CreateSlider({
	Name = "Assist Strength",
	Range = { 0, 100 },
	Increment = 5,
	Suffix = "%",
	CurrentValue = 85,
	Flag = "AimAssistStrength",
	Callback = function(value)
		assistStrength = value / 100
	end,
})

CombatTab:CreateToggle({
	Name = "Show FOV Circle",
	CurrentValue = true,
	Flag = "FOVCircleToggle",
	Callback = function(value)
		fovCircleEnabled = value
	end,
})

CombatTab:CreateColorPicker({
	Name = "FOV Circle Color",
	Color = Color3.fromRGB(170, 60, 230),
	Flag = "FOVCircleColor",
	Callback = function(value)
		fovCircle.Color = value
	end,
})

CombatTab:CreateSlider({
	Name = "Detection Radius (FOV)",
	Range = { 25, 180 },
	Increment = 5,
	Suffix = "px",
	CurrentValue = 180,
	Flag = "AimAssistRadius",
	Callback = function(value)
		MAX_ASSIST_RANGE = value
	end,
})

-- ============================================================
-- MOVEMENT TAB
-- ============================================================
MovementTab:CreateParagraph({
	Title = "Movement",
	Content = "Fly, noclip, speed, jump and camera controls in one place.",
})
MovementTab:CreateSection("Flight")

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

MovementTab:CreateToggle({
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

MovementTab:CreateSlider({
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

-- ============================================================
-- PLAYER TOOLS
-- ============================================================
MovementTab:CreateSection("Player Tools")

UserInputService.JumpRequest:Connect(function()
	if infiniteJumpEnabled then
		local humanoid = getHumanoid()
		if humanoid and humanoid.Health > 0 then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

MovementTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "InfiniteJumpToggle",
	Callback = function(value)
		infiniteJumpEnabled = value
	end,
})
MovementTab:CreateToggle({
	Name = "No Fall Damage",
	CurrentValue = false,
	Flag = "NoFallDamageToggle",
	Callback = function(value)
		local char = LocalPlayer.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if value then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			else
				humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
			end
		end
	end,
})


-- ============================================================
-- NOCLIP
-- ============================================================
local noclipEnabled = false
local noclipConnection
local noclipDescendantConnection

local function setCharacterCollision(enabled)
	local char = LocalPlayer.Character
	if not char then return end

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = enabled
		end
	end
end

local function startNoclip()
	if noclipConnection then noclipConnection:Disconnect() end
	if noclipDescendantConnection then noclipDescendantConnection:Disconnect() end

	local char = LocalPlayer.Character
	if char then
		noclipDescendantConnection = char.DescendantAdded:Connect(function(obj)
			if noclipEnabled and obj:IsA("BasePart") then
				obj.CanCollide = false
			end
		end)
	end

	noclipConnection = RunService.Stepped:Connect(function()
		if not noclipEnabled then return end
		local currentChar = LocalPlayer.Character
		if not currentChar then return end

		for _, part in ipairs(currentChar:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)

	setCharacterCollision(false)
end

local function stopNoclip()
	if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
	if noclipDescendantConnection then noclipDescendantConnection:Disconnect(); noclipDescendantConnection = nil end
	setCharacterCollision(true)
end

LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart", 5)
	task.wait(0.15)
	if noclipEnabled then startNoclip() end
end)

MovementTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Flag = "NoclipToggle",
	Callback = function(value)
		noclipEnabled = value
		if value then startNoclip() else stopNoclip() end
		Rayfield:Notify({
			Title = "Noclip " .. (value and "Enabled" or "Disabled"),
			Content = value and "Character collision disabled" or "Normal collision restored",
			Duration = 2
		})
	end,
})

-- ==== Walk Speed / Jump Power ====
MovementTab:CreateSection("Player Movement")

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

MovementTab:CreateSlider({
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

MovementTab:CreateSlider({
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
-- CAMERA
-- ============================================================
MovementTab:CreateSection("Camera")

MovementTab:CreateSlider({
	Name = "Field of View",
	Range = { 40, 120 },
	Increment = 5,
	Suffix = "°",
	CurrentValue = 70,
	Flag = "FOVSlider",
	Callback = function(value)
		local camera = workspace.CurrentCamera
		if camera then camera.FieldOfView = value end
	end,
})

-- ============================================================
-- QUALITY OF LIFE
-- ============================================================
MiscTab:CreateSection("Quality of Life")

local antiAfkConnection

local function startAntiAfk()
	if antiAfkConnection then antiAfkConnection:Disconnect() end
	antiAfkConnection = LocalPlayer.Idled:Connect(function()
		local VirtualUser = game:GetService("VirtualUser")
		VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(0.1)
		VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end)
end

MiscTab:CreateToggle({
	Name = "Anti-AFK",
	CurrentValue = true,
	Flag = "AntiAFKToggle",
	Callback = function(value)
		if value then
			startAntiAfk()
		elseif antiAfkConnection then
			antiAfkConnection:Disconnect()
			antiAfkConnection = nil
		end
	end,
})

local savedLighting = {}

local function setFullbright(enabled)
	local Lighting = game:GetService("Lighting")
	if enabled then
		savedLighting.Brightness = Lighting.Brightness
		savedLighting.ClockTime = Lighting.ClockTime
		savedLighting.FogEnd = Lighting.FogEnd
		savedLighting.GlobalShadows = Lighting.GlobalShadows
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
	else
		if savedLighting.Brightness then Lighting.Brightness = savedLighting.Brightness end
		if savedLighting.ClockTime then Lighting.ClockTime = savedLighting.ClockTime end
		if savedLighting.FogEnd then Lighting.FogEnd = savedLighting.FogEnd end
		if savedLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = savedLighting.GlobalShadows end
	end
end

MiscTab:CreateToggle({
	Name = "Fullbright",
	CurrentValue = false,
	Flag = "FullbrightToggle",
	Callback = function(value)
		setFullbright(value)
	end,
})

startAntiAfk()

-- ============================================================
-- MISC TAB
-- ============================================================
MiscTab:CreateSection("Community")

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
