
--==================================================
-- PRISON LIFE ULTIMATE GUI
-- LocalScript: StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local KEY = "xino7"

-- SETTINGS
local speed = 30
local jumpPower = 50
local flySpeed = 50

local espEnabled = false
local targetLockEnabled = false
local noclipEnabled = false
local flyEnabled = false
local loopSpeed = false
local loopJump = false
local killAuraEnabled = false

local combatRemote = ReplicatedStorage:WaitForChild("XinoKillAura", 10)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "XinoPrisonLifeGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeFrame(name, size, position)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(25, 15, 15)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    return frame
end

local function makeButton(parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 32)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

local function makeBox(parent, placeholder, position)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -12, 0, 30)
    box.Position = position
    box.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderColor3 = Color3.fromRGB(190, 190, 190)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = parent
    return box
end

local function makeTitle(parent, text)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(130, 15, 15)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = parent
    return title
end

local menu = makeFrame("MENU", UDim2.fromOffset(220, 390), UDim2.new(0, 20, 0.25, 0))
local menu2 = makeFrame("MENU2", UDim2.fromOffset(220, 300), UDim2.new(0, 250, 0.25, 0))
local menu3 = makeFrame("MENU3", UDim2.fromOffset(220, 220), UDim2.new(0, 480, 0.25, 0))

makeTitle(menu, "XINO'S ULTIMATE GUI")
makeTitle(menu2, "MOVEMENT")
makeTitle(menu3, "COMBAT")

-- Dragging
local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(menu, menu:FindFirstChildOfClass("TextLabel"))
makeDraggable(menu2, menu2:FindFirstChildOfClass("TextLabel"))
makeDraggable(menu3, menu3:FindFirstChildOfClass("TextLabel"))

local function isEnemy(other)
    if other == player then return false end
    if not other.Character then return false end

    if player.Team and other.Team then
        return player.Team ~= other.Team
    end

    return true
end

-- ESP
local highlights = {}

local function updateESP()
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and isEnemy(other) then
            if espEnabled then
                local highlight = highlights[other]
                if not highlight or highlight.Parent ~= other.Character then
                    if highlight then highlight:Destroy() end
                    highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = other.Character
                    highlights[other] = highlight
                end
            elseif highlights[other] then
                highlights[other]:Destroy()
                highlights[other] = nil
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(other)
    if highlights[other] then
        highlights[other]:Destroy()
        highlights[other] = nil
    end
end)

-- MAIN MENU
local y = 42

makeButton(menu, "ESP: OFF", UDim2.fromOffset(6, y), function(button)
    espEnabled = not espEnabled
    button.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    if not espEnabled then
        for _, h in pairs(highlights) do h:Destroy() end
        table.clear(highlights)
    end
end).Name = "ESPButton"
y = y + 38

makeButton(menu, "Target Lock: OFF", UDim2.fromOffset(6, y), function(button)
    targetLockEnabled = not targetLockEnabled
    button.Text = "Target Lock: " .. (targetLockEnabled and "ON" or "OFF")
end)
y = y + 38

makeButton(menu, "Noclip: OFF", UDim2.fromOffset(6, y), function(button)
    noclipEnabled = not noclipEnabled
    button.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
end)
y = y + 38

local speedBox = makeBox(menu, "WalkSpeed (max 10000)", UDim2.fromOffset(6, y))
y = y + 34

makeButton(menu, "Set WalkSpeed", UDim2.fromOffset(6, y), function()
    local n = tonumber(speedBox.Text)
    if n then speed = math.clamp(n, 16, 10000) end
end)
y = y + 36

makeButton(menu, "Loop Speed: OFF", UDim2.fromOffset(6, y), function(button)
    loopSpeed = not loopSpeed
    button.Text = "Loop Speed: " .. (loopSpeed and "ON" or "OFF")
end)
y = y + 38

local jumpBox = makeBox(menu, "JumpPower (max 10000)", UDim2.fromOffset(6, y))
y = y + 34

makeButton(menu, "Set JumpPower", UDim2.fromOffset(6, y), function()
    local n = tonumber(jumpBox.Text)
    if n then jumpPower = math.clamp(n, 0, 10000) end
end)
y = y + 36

makeButton(menu, "Loop Jump: OFF", UDim2.fromOffset(6, y), function(button)
    loopJump = not loopJump
    button.Text = "Loop Jump: " .. (loopJump and "ON" or "OFF")
end)
y = y + 38

makeButton(menu, "MENU 2", UDim2.fromOffset(6, y), function()
    menu2.Visible = not menu2.Visible
end)

-- MENU 2: FLY
local flyButton = makeButton(menu2, "Fly: OFF", UDim2.fromOffset(6, 45), function()
    flyEnabled = not flyEnabled
    flyButton.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
end)

local flyBox = makeBox(menu2, "Fly speed (max 10000)", UDim2.fromOffset(6, 85))
makeButton(menu2, "Set Fly Speed", UDim2.fromOffset(6, 120), function()
    local n = tonumber(flyBox.Text)
    if n then flySpeed = math.clamp(n, 1, 10000) end
end)

makeButton(menu2, "MENU 3", UDim2.fromOffset(6, 158), function()
    menu3.Visible = not menu3.Visible
end)

makeButton(menu2, "CLOSE MENUS", UDim2.fromOffset(6, 196), function()
    menu.Visible = false
    menu2.Visible = false
    menu3.Visible = false
end)

-- MENU 3: COMBAT
local auraButton = makeButton(menu3, "Kill Aura: OFF", UDim2.fromOffset(6, 45), function()
    killAuraEnabled = not killAuraEnabled
    auraButton.Text = "Kill Aura: " .. (killAuraEnabled and "ON" or "OFF")
end)

local selectedTarget = nil

local function getPlayersList()
    local list = {}
    for _, other in ipairs(Players:GetPlayers()) do
        if isEnemy(other) and other.Character
        and other.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, other)
        end
    end
    return list
end

local function selectNextTarget()
    local list = getPlayersList()
    if #list == 0 then
        selectedTarget = nil
        return
    end

    local index = 0
    for i, other in ipairs(list) do
        if other == selectedTarget then index = i break end
    end

    index = (index % #list) + 1
    selectedTarget = list[index]
end

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1, -12, 0, 28)
targetLabel.Position = UDim2.fromOffset(6, 84)
targetLabel.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
targetLabel.TextColor3 = Color3.new(1, 1, 1)
targetLabel.Text = "Target: none"
targetLabel.Parent = menu3

makeButton(menu3, "Select Next Player", UDim2.fromOffset(6, 116), function()
    selectNextTarget()
    targetLabel.Text = "Target: " .. (selectedTarget and selectedTarget.Name or "none")
end)

makeButton(menu3, "Teleport To Player", UDim2.fromOffset(6, 154), function()
    if not selectedTarget or not selectedTarget.Character then return end

    local myChar = player.Character
    local theirRoot = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if myRoot and theirRoot then
        myRoot.CFrame = theirRoot.CFrame * CFrame.new(0, 0, 3)
    end
end)

-- TARGET LOCK
local function getNearestEnemy()
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local nearest, nearestDistance = nil, math.huge

    for _, other in ipairs(Players:GetPlayers()) do
        if isEnemy(other) and other.Character then
            local root = other.Character:FindFirstChild("HumanoidRootPart")
            local hum = other.Character:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearest = other
                    nearestDistance = distance
                end
            end
        end
    end

    return nearest
end

-- FLY MOVEMENT
local bodyVelocity
local bodyGyro

local function stopFly()
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

local function updateFly()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if not flyEnabled or not root or not hum then
        stopFly()
        return
    end

    if not bodyVelocity then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Parent = root

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.P = 10000
        bodyGyro.Parent = root
    end

    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector

    local flatForward = Vector3.new(look.X, 0, look.Z)
    if flatForward.Magnitude < 0.001 then
        flatForward = Vector3.new(0, 0, -1)
    else
        flatForward = flatForward.Unit
    end

    local flatRight = Vector3.new(right.X, 0, right.Z)
    if flatRight.Magnitude < 0.001 then
        flatRight = Vector3.new(1, 0, 0)
    else
        flatRight = flatRight.Unit
    end

    local direction = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += look end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= look end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += flatRight end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= flatRight end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end

    if UserInputService.TouchEnabled then
        local move = hum.MoveDirection
        direction += flatForward * move:Dot(flatForward)
        direction += flatRight * move:Dot(flatRight)
    end

    if direction.Magnitude > 0 then
        direction = direction.Unit * flySpeed
    end

    bodyVelocity.Velocity = direction
    bodyGyro.CFrame = camera.CFrame
end

-- MAIN UPDATE
local auraTimer = 0

RunService.Heartbeat:Connect(function(dt)
    updateESP()

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        if loopSpeed then hum.WalkSpeed = speed end
        if loopJump then hum.JumpPower = jumpPower end
    end

    if noclipEnabled and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    updateFly()

    if targetLockEnabled then
        local target = getNearestEnemy()
        local targetRoot = target and target.Character
            and target.Character:FindFirstChild("HumanoidRootPart")

        if targetRoot then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetRoot.Position)
        end
    end

    auraTimer += dt
    if killAuraEnabled and auraTimer >= 0.5 then
        auraTimer = 0

        if combatRemote and root then
            local target = getNearestEnemy()
            local targetRoot = target and target.Character
                and target.Character:FindFirstChild("HumanoidRootPart")

            if targetRoot and (targetRoot.Position - root.Position).Magnitude <= 50 then
                combatRemote:FireServer(target)
            end
        end
    end
end)

-- RESPAWN CLEANUP
player.CharacterAdded:Connect(function()
    stopFly()
end)

-- CLOSE / REOPEN
local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(65, 30)
reopen.Position = UDim2.new(0, 10, 0.5, 0)
reopen.BackgroundColor3 = Color3.fromRGB(130, 15, 15)
reopen.TextColor3 = Color3.new(1, 1, 1)
reopen.Text = "xino"
reopen.Parent = gui

reopen.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

-- KEY GATE
local keyFrame = makeFrame("KEY", UDim2.fromOffset(220, 120), UDim2.new(0.5, -110, 0.5, -60))
keyFrame.Visible = true
makeTitle(keyFrame, "ENTER KEY")

local keyBox = makeBox(keyFrame, "Enter key", UDim2.fromOffset(6, 42))
makeButton(keyFrame, "UNLOCK", UDim2.fromOffset(6, 78), function()
    if keyBox.Text == KEY then
        keyFrame.Visible = false
        menu.Visible = true
    else
        keyBox.Text = ""
        keyBox.PlaceholderText = "Wrong key!"
    end
end)
