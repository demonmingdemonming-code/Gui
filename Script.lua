-- PRISON LIFE ULTIMATE GUI
-- LocalScript: StarterPlayer > StarterPlayerScripts
-- Intended for your own Roblox experience.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- SETTINGS
local KEY = "xino7"
local speed = 16
local jumpPower = 50
local loopSpeed = false
local loopJumpPower = false
local noclip = false
local espEnabled = false
local targetLock = false

local flyEnabled = false
local flySpeed = 30
local flyUp = false
local flyDown = false

local originalCollisions = {}
local highlights = {}
local lockedTarget = nil

local flyVelocity = nil
local flyGyro = nil
local flyConnection = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PrisonLifeUltimateGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeButton(parent, text, size, position)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    return button
end

local function makeBox(parent, placeholder, size, position)
    local box = Instance.new("TextBox")
    box.Size = size
    box.Position = position
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.ClearTextOnFocus = false
    box.TextScaled = true
    box.Font = Enum.Font.Gotham
    box.Parent = parent
    return box
end

-- KEY GATE
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.fromOffset(250, 130)
keyFrame.Position = UDim2.new(0.5, -125, 0.5, -65)
keyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
keyFrame.Parent = gui

local keyBox = makeBox(
    keyFrame,
    "Enter key",
    UDim2.fromOffset(210, 35),
    UDim2.fromOffset(20, 20)
)

local keyButton = makeButton(
    keyFrame,
    "UNLOCK",
    UDim2.fromOffset(210, 35),
    UDim2.fromOffset(20, 70)
)

-- MAIN MENU
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(260, 390)
main.Position = UDim2.new(0, 30, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true
main.Visible = false
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -32, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
title.Text = "PRISON LIFE ULTIMATE GUI"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

local closeButton = makeButton(
    main, "X", UDim2.fromOffset(32, 35), UDim2.new(1, -32, 0, 0)
)

local menuSwitch = makeButton(
    main, "MENU2", UDim2.fromOffset(65, 30), UDim2.new(0, -67, 0, 42)
)

local espButton = makeButton(
    main, "ESP: OFF", UDim2.fromOffset(220, 32), UDim2.fromOffset(20, 45)
)

local targetButton = makeButton(
    main, "Target Lock: OFF", UDim2.fromOffset(220, 32), UDim2.fromOffset(20, 83)
)

local noclipButton = makeButton(
    main, "Noclip: OFF", UDim2.fromOffset(220, 32), UDim2.fromOffset(20, 121)
)

local speedBox = makeBox(
    main, "WalkSpeed (16-200)", UDim2.fromOffset(220, 30),
    UDim2.fromOffset(20, 165)
)

local speedButton = makeButton(
    main, "Loop Speed: OFF", UDim2.fromOffset(220, 32),
    UDim2.fromOffset(20, 200)
)

local jumpBox = makeBox(
    main, "JumpPower (0-200)", UDim2.fromOffset(220, 30),
    UDim2.fromOffset(20, 238)
)

local jumpButton = makeButton(
    main, "Loop JumpPower: OFF", UDim2.fromOffset(220, 32),
    UDim2.fromOffset(20, 273)
)

-- MENU2
local menu2 = Instance.new("Frame")
menu2.Size = UDim2.fromOffset(260, 390)
menu2.Position = main.Position
menu2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menu2.Active = true
menu2.Draggable = true
menu2.Visible = false
menu2.Parent = gui

local menu2Title = Instance.new("TextLabel")
menu2Title.Size = UDim2.new(1, -32, 0, 35)
menu2Title.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
menu2Title.Text = "MENU2 - MOVEMENT"
menu2Title.TextColor3 = Color3.new(1, 1, 1)
menu2Title.TextScaled = true
menu2Title.Font = Enum.Font.GothamBold
menu2Title.Parent = menu2

local menu2Close = makeButton(
    menu2, "X", UDim2.fromOffset(32, 35), UDim2.new(1, -32, 0, 0)
)

local backButton = makeButton(
    menu2, "BACK TO MENU", UDim2.fromOffset(220, 32),
    UDim2.fromOffset(20, 50)
)

local flyButton = makeButton(
    menu2, "Fly: OFF", UDim2.fromOffset(220, 35),
    UDim2.fromOffset(20, 100)
)

local flySpeedBox = makeBox(
    menu2, "Fly Speed (30-200)", UDim2.fromOffset(220, 30),
    UDim2.fromOffset(20, 145)
)
flySpeedBox.Text = "30"

local upButton = makeButton(
    menu2, "HOLD UP", UDim2.fromOffset(105, 40),
    UDim2.fromOffset(20, 190)
)

local downButton = makeButton(
    menu2, "HOLD DOWN", UDim2.fromOffset(105, 40),
    UDim2.fromOffset(135, 190)
)

local flyHelp = Instance.new("TextLabel")
flyHelp.Size = UDim2.fromOffset(220, 75)
flyHelp.Position = UDim2.fromOffset(20, 240)
flyHelp.BackgroundTransparency = 1
flyHelp.TextColor3 = Color3.fromRGB(220, 220, 220)
flyHelp.TextWrapped = true
flyHelp.TextScaled = true
flyHelp.Font = Enum.Font.Gotham
flyHelp.Text = "Move with your movement controls. Space = up; Ctrl = down. On mobile, use the UP/DOWN buttons."
flyHelp.Parent = menu2

-- REOPEN BUTTON
local reopenButton = makeButton(
    gui, "OPEN GUI", UDim2.fromOffset(110, 35), UDim2.fromOffset(10, 10)
)
reopenButton.Visible = false

-- MENU SWITCHING
menuSwitch.MouseButton1Click:Connect(function()
    menu2.Position = main.Position
    main.Visible = false
    menu2.Visible = true
end)

backButton.MouseButton1Click:Connect(function()
    menu2.Visible = false
    main.Visible = true
end)

-- CHARACTER HELPERS
local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- FLY CLEANUP
local function stopFlying()
    flyEnabled = false
    flyButton.Text = "Fly: OFF"
    flyUp = false
    flyDown = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end

    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end

    local humanoid = getHumanoid()
    if humanoid then
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
    end
end

-- FLY START
local function startFlying()
    local humanoid = getHumanoid()
    local root = getRoot()

    if not humanoid or not root then
        flyButton.Text = "Fly: NO CHARACTER"
        return
    end

    local requestedSpeed = tonumber(flySpeedBox.Text)
    flySpeed = math.clamp(requestedSpeed or 30, 30, 200)
    flySpeedBox.Text = tostring(flySpeed)

    flyEnabled = true
    flyButton.Text = "Fly: ON"
    humanoid.AutoRotate = false
    humanoid.PlatformStand = false

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Name = "LocalFlyVelocity"
    flyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
    flyVelocity.P = 25000
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.Name = "LocalFlyGyro"
    flyGyro.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
    flyGyro.P = 15000
    flyGyro.CFrame = root.CFrame
    flyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled then
            return
        end

        if not root.Parent or not humanoid.Parent then
            stopFlying()
            return
        end

        local inputSpeed = tonumber(flySpeedBox.Text)
        if inputSpeed then
            flySpeed = math.clamp(inputSpeed, 30, 200)
        end

        local direction = humanoid.MoveDirection
        local vertical = 0

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or flyUp then
            vertical += 1
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or flyDown then
            vertical -= 1
        end

        -- Use camera-relative keyboard movement on desktop.
        if not UserInputService.TouchEnabled then
            local cameraCF = camera.CFrame
            local forward = Vector3.new(cameraCF.LookVector.X, 0, cameraCF.LookVector.Z)
            local right = Vector3.new(cameraCF.RightVector.X, 0, cameraCF.RightVector.Z)

            if forward.Magnitude > 0 then forward = forward.Unit end
            if right.Magnitude > 0 then right = right.Unit end

            direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += right end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= right end
        end

        local velocity = direction + Vector3.new(0, vertical, 0)
        if velocity.Magnitude > 1 then
            velocity = velocity.Unit
        end

        flyVelocity.Velocity = velocity * flySpeed

        local look = camera.CFrame.LookVector
        flyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + look)
    end)
end

flyButton.MouseButton1Click:Connect(function()
    if flyEnabled then
        stopFlying()
    else
        startFlying()
    end
end)

-- SPEED BOX VALIDATION
speedBox.FocusLost:Connect(function()
    local value = tonumber(speedBox.Text)
    if value then
        speedBox.Text = tostring(math.clamp(value, 16, 200))
    end
end)

jumpBox.FocusLost:Connect(function()
    local value = tonumber(jumpBox.Text)
    if value then
        jumpBox.Text = tostring(math.clamp(value, 0, 200))
    end
end)

flySpeedBox.FocusLost:Connect(function()
    local value = tonumber(flySpeedBox.Text)
    if value then
        flySpeed = math.clamp(value, 30, 200)
        flySpeedBox.Text = tostring(flySpeed)
    else
        flySpeedBox.Text = tostring(flySpeed)
    end
end)

-- MOBILE HOLD BUTTONS
upButton.MouseButton1Down:Connect(function()
    flyUp = true
end)
upButton.MouseButton1Up:Connect(function()
    flyUp = false
end)
upButton.MouseLeave:Connect(function()
    flyUp = false
end)

downButton.MouseButton1Down:Connect(function()
    flyDown = true
end)
downButton.MouseButton1Up:Connect(function()
    flyDown = false
end)
downButton.MouseLeave:Connect(function()
    flyDown = false
end)

-- LOOP SPEED / JUMP
speedButton.MouseButton1Click:Connect(function()
    loopSpeed = not loopSpeed
    speedButton.Text = "Loop Speed: " .. (loopSpeed and "ON" or "OFF")
end)

jumpButton.MouseButton1Click:Connect(function()
    loopJumpPower = not loopJumpPower
    jumpButton.Text = "Loop JumpPower: " .. (loopJumpPower and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    local humanoid = getHumanoid()
    if not humanoid then return end

    if loopSpeed then
        local value = tonumber(speedBox.Text)
        if value then
            speed = math.clamp(value, 16, 200)
            humanoid.WalkSpeed = speed
        end
    end

    if loopJumpPower then
        local value = tonumber(jumpBox.Text)
        if value then
            jumpPower = math.clamp(value, 0, 200)
            humanoid.UseJumpPower = true
            humanoid.JumpPower = jumpPower
        end
    end
end)

-- NOCLIP
local function restoreCollisions()
    for part, oldValue in pairs(originalCollisions) do
        if part and part.Parent then
            part.CanCollide = oldValue
        end
    end
    table.clear(originalCollisions)
end

local function setNoclip(enabled)
    noclip = enabled
    noclipButton.Text = "Noclip: " .. (enabled and "ON" or "OFF")

    if not enabled then
        restoreCollisions()
    end
end

-- Apply locally every physics step. In a multiplayer experience, server-side
-- collision rules may also be needed for fully authoritative noclip.
RunService.Stepped:Connect(function()
    if not noclip then return end

    local character = getCharacter()
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if originalCollisions[part] == nil then
                originalCollisions[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end)

noclipButton.MouseButton1Click:Connect(function()
    setNoclip(not noclip)
end)

-- ENEMY CHECK
local function isEnemy(otherPlayer)
    if otherPlayer == player then
        return false
    end

    if player.Team and otherPlayer.Team then
        return player.Team ~= otherPlayer.Team
    end

    return true
end

-- ESP
local function updateESP(otherPlayer)
    if otherPlayer == player then return end

    local character = otherPlayer.Character
    if not character then return end

    if espEnabled then
        if not highlights[otherPlayer]
            or highlights[otherPlayer].Parent ~= character then

            if highlights[otherPlayer] then
                highlights[otherPlayer]:Destroy()
            end

            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = character
            highlights[otherPlayer] = highlight
        end
    elseif highlights[otherPlayer] then
        highlights[otherPlayer]:Destroy()
        highlights[otherPlayer] = nil
    end
end

local function refreshESP()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        updateESP(otherPlayer)
    end
end

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    refreshESP()
end)

local function setupPlayer(otherPlayer)
    if otherPlayer == player then return end

    otherPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        updateESP(otherPlayer)
    end)
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do
    setupPlayer(otherPlayer)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(otherPlayer)
    if highlights[otherPlayer] then
        highlights[otherPlayer]:Destroy()
        highlights[otherPlayer] = nil
    end
end)

-- FIND ENEMY NEAREST TO CROSSHAIR
local function getTargetAtCrosshair()
    local bestTarget = nil
    local bestDistance = 180
    local center = camera.ViewportSize / 2

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if isEnemy(otherPlayer) then
            local character = otherPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if root and humanoid and humanoid.Health > 0 then
                local screenPosition, onScreen =
                    camera:WorldToViewportPoint(root.Position)

                if onScreen and screenPosition.Z > 0 then
                    local distance = (
                        Vector2.new(screenPosition.X, screenPosition.Y) - center
                    ).Magnitude

                    if distance < bestDistance then
                        bestDistance = distance
                        bestTarget = otherPlayer
                    end
                end
            end
        end
    end

    return bestTarget
end

-- TARGET LOCK
targetButton.MouseButton1Click:Connect(function()
    targetLock = not targetLock
    lockedTarget = nil
    targetButton.Text = "Target Lock: " .. (targetLock and "ON" or "OFF")
end)

RunService:BindToRenderStep(
    "PrisonLifeTargetCamera",
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if not targetLock then return end

        camera = workspace.CurrentCamera or camera
        if not camera then return end

        if not lockedTarget
            or not lockedTarget.Character
            or not lockedTarget.Character:FindFirstChild("HumanoidRootPart")
            or not isEnemy(lockedTarget) then
            lockedTarget = getTargetAtCrosshair()
        end

        if not lockedTarget then return end

        local character = lockedTarget.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if root and humanoid and humanoid.Health > 0 then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, root.Position)
        else
            lockedTarget = nil
        end
    end
)

-- CLOSE / REOPEN
local function closeGUI()
    main.Visible = false
    menu2.Visible = false
    reopenButton.Visible = true
end

closeButton.MouseButton1Click:Connect(closeGUI)
menu2Close.MouseButton1Click:Connect(closeGUI)

reopenButton.MouseButton1Click:Connect(function()
    reopenButton.Visible = false
    main.Visible = true
end)

-- RESPAWN SUPPORT
player.CharacterAdded:Connect(function(character)
    stopFlying()
    restoreCollisions()

    character:WaitForChild("Humanoid")

    if espEnabled then
        task.wait(0.5)
        refreshESP()
    end
end)

-- KEY CHECK
keyButton.MouseButton1Click:Connect(function()
    if keyBox.Text == KEY then
        keyFrame.Visible = false
        main.Visible = true
    else
        keyBox.Text = ""
        keyBox.PlaceholderText = "Incorrect key"
    end
end)
