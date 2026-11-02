
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

local originalCollisions = {}
local highlights = {}
local lockedTarget = nil

local flyVelocity = nil
local flyGyro = nil
local flyConnection = nil
local noclipConnection = nil

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
    main, "WalkSpeed (16-10000)", UDim2.fromOffset(220, 30),
    UDim2.fromOffset(20, 165)
)

local speedButton = makeButton(
    main, "Loop Speed: OFF", UDim2.fromOffset(220, 32),
    UDim2.fromOffset(20, 200)
)

local jumpBox = makeBox(
    main, "JumpPower (0-10000)", UDim2.fromOffset(220, 30),
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
    menu2, "Fly Speed (30-10000)", UDim2.fromOffset(220, 30),
    UDim2.fromOffset(20, 145)
)
flySpeedBox.Text = "30"

local flyHelp = Instance.new("TextLabel")
flyHelp.Size = UDim2.fromOffset(220, 75)
flyHelp.Position = UDim2.fromOffset(20, 190)
flyHelp.BackgroundTransparency = 1
flyHelp.TextColor3 = Color3.fromRGB(220, 220, 220)
flyHelp.TextWrapped = true
flyHelp.TextScaled = true
flyHelp.Font = Enum.Font.Gotham
flyHelp.Text = "Look in the direction you want to fly, then use your movement controls."
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
    flySpeed = math.clamp(requestedSpeed or 30, 30, 10000)
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
        if not flyEnabled then return end

        if not root.Parent or not humanoid.Parent then
            stopFlying()
            return
        end

        local inputSpeed = tonumber(flySpeedBox.Text)
        if inputSpeed then
            flySpeed = math.clamp(inputSpeed, 30, 10000)
        end

        camera = workspace.CurrentCamera
        if not camera then return end

        local cameraCF = camera.CFrame
        local lookDirection = cameraCF.LookVector
        local rightDirection = cameraCF.RightVector

        local flatForward = Vector3.new(
            lookDirection.X, 0, lookDirection.Z
        )

        if flatForward.Magnitude < 0.001 then
            local rootLook = root.CFrame.LookVector
            flatForward = Vector3.new(rootLook.X, 0, rootLook.Z)
        end

        if flatForward.Magnitude > 0.001 then
            flatForward = flatForward.Unit
        else
            flatForward = Vector3.new(0, 0, -1)
        end

        local flatRight = Vector3.new(
            rightDirection.X, 0, rightDirection.Z
        )

        if flatRight.Magnitude > 0.001 then
            flatRight = flatRight.Unit
        else
            flatRight = Vector3.new(1, 0, 0)
        end

        local forwardAmount = 0
        local rightAmount = 0

        if UserInputService.TouchEnabled then
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0.05 then
                forwardAmount = moveDirection:Dot(flatForward)
                rightAmount = moveDirection:Dot(flatRight)
            end
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                forwardAmount += 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                forwardAmount -= 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                rightAmount += 1
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                rightAmount -= 1
            end
        end

        local velocityDirection =
            (lookDirection * forwardAmount) +
            (rightDirection * rightAmount)

        if velocityDirection.Magnitude > 1 then
            velocityDirection = velocityDirection.Unit
        end

        flyVelocity.Velocity = velocityDirection * flySpeed

        flyGyro.CFrame = CFrame.lookAt(
            root.Position,
            root.Position + lookDirection
        )
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
        speedBox.Text = tostring(math.clamp(value, 16, 10000))
    end
end)

jumpBox.FocusLost:Connect(function()
    local value = tonumber(jumpBox.Text)
    if value then
        jumpBox.Text = tostring(math.clamp(value, 0, 10000))
    end
end)

flySpeedBox.FocusLost:Connect(function()
    local value = tonumber(flySpeedBox.Text)
    if value then
        flySpeed = math.clamp(value, 30, 10000)
        flySpeedBox.Text = tostring(flySpeed)
    else
        flySpeedBox.Text = tostring(flySpeed)
    end
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
            speed = math.clamp(value, 16, 10000)
            humanoid.WalkSpeed = speed
        end
    end

    if loopJumpPower then
        local value = tonumber(jumpBox.Text)
        if value then
            jumpPower = math.clamp(value, 0, 10000)
            humanoid.UseJumpPower = true
            humanoid.JumpPower = jumpPower
        end
    end
end)

-- CLIENT-SIDED NOCLIP
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

    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    if not enabled then
        restoreCollisions()
        return
    end

    noclipConnection = RunService.Stepped:Connect(function()
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
end

noclipButton.MouseButton1Click:Connect(function()
    setNoclip(not noclip)
end)

-- ENEMY CHECK
local function isEnemy(otherPlayer)
    if otherPlayer == player then return false end

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
