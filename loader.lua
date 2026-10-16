-- Vortex Loader | Premium UI
-- Remote scripts run with the executor's privileges. Only use scripts you trust and have reviewed.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local CONFIG = {
    title = "Vortex Loader",
    subtitle = " LIBRARY SCRIPT",
    version = "v2.0",
    toggleKey = Enum.KeyCode.RightShift,
    scripts = {
        {
            name = "Vortex Hub",
            cmd = "loadstring(game:HttpGet('https://raw.githubusercontent.com/djvort735-ux/Private-Script/main/old.lua'))()",
            desc = "Main",
            tag = "FREE",
        },
        {
            name = "Loot To Forge",
            cmd = "loadstring(game:HttpGet('https://raw.githubusercontent.com/djvort735-ux/Private-Script/main/Loot_To_Forge.lua'))()",
            desc = "Loot utility",
            tag = "FREE",
        },
}

local THEME = {
    bg = Color3.fromRGB(10, 11, 17),
    bgTop = Color3.fromRGB(15, 17, 27),
    panel = Color3.fromRGB(15, 17, 26),
    card = Color3.fromRGB(20, 23, 35),
    cardHover = Color3.fromRGB(27, 31, 47),
    stroke = Color3.fromRGB(36, 41, 60),
    text = Color3.fromRGB(244, 245, 252),
    subtext = Color3.fromRGB(150, 158, 182),
    muted = Color3.fromRGB(96, 104, 130),
    accentA = Color3.fromRGB(96, 120, 255),
    accentB = Color3.fromRGB(154, 96, 255),
    accentC = Color3.fromRGB(86, 200, 255),
    ok = Color3.fromRGB(96, 214, 160),
    err = Color3.fromRGB(244, 108, 124),
}

local W, H, HEADER = 760, 470, 66

-- helpers ---------------------------------------------------------------

local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties) do
        object[key] = value
    end
    if parent then
        object.Parent = parent
    end
    return object
end

local function corner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(parent, firstColor, secondColor, rotation, transparency)
    return make("UIGradient", {
        Color = ColorSequence.new(firstColor, secondColor),
        Rotation = rotation or 0,
        Transparency = transparency or NumberSequence.new(0),
    }, parent)
end

local function tween(object, properties, duration, style, direction)
    TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.16,
            style or Enum.EasingStyle.Quart,
            direction or Enum.EasingDirection.Out
        ),
        properties
    ):Play()
end

local function label(parent, properties)
    local props = {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = THEME.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "",
    }
    for key, value in pairs(properties) do
        props[key] = value
    end
    return make("TextLabel", props, parent)
end

local function extractUrl(value)
    return value:match("https?://[^'\"%)%s]+")
end

local function runScript(entry, setStatus)
    if entry.available == false then
        setStatus("This script is coming soon", "idle")
        return false
    end

    local url = extractUrl(entry.cmd or entry.url or "")
    if not url then
        setStatus("No valid URL for " .. entry.name, "err")
        return false
    end

    setStatus("Fetching " .. entry.name .. "...", "idle")
    local fetchOk, source = pcall(game.HttpGet, game, url)
    if not fetchOk or type(source) ~= "string" or #source == 0 then
        setStatus("Couldn't fetch " .. entry.name, "err")
        return false
    end

    local compileOk, callback, compileError = pcall(loadstring, source)
    if not compileOk or type(callback) ~= "function" then
        setStatus("Compile error: " .. tostring(compileError or callback), "err")
        return false
    end

    local runOk, runtimeError = pcall(callback)
    if runOk then
        setStatus("Launched " .. entry.name, "ok")
        return true
    end

    setStatus("Runtime error: " .. tostring(runtimeError), "err")
    return false
end

-- setup -----------------------------------------------------------------

local player = Players.LocalPlayer
if not player then
    return
end

local guiParent
if typeof(gethui) == "function" then
    local getHuiOk, result = pcall(gethui)
    if getHuiOk and result then
        guiParent = result
    end
end
if not guiParent then
    guiParent = game:GetService("CoreGui")
end

local existing = guiParent:FindFirstChild("VortexLoaderGui")
if existing then
    existing:Destroy()
end

local screen = make("ScreenGui", {
    Name = "VortexLoaderGui",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 20,
}, nil)

if not pcall(function()
    screen.Parent = guiParent
end) then
    screen.Parent = player:WaitForChild("PlayerGui")
end

local connections = {}
local function track(connection)
    connections[#connections + 1] = connection
    return connection
end

local function disconnectAll()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
end

-- root + glow -----------------------------------------------------------

local root = make("Frame", {
    Name = "Root",
    Size = UDim2.fromOffset(W, H),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0.5, -H / 2),
    BackgroundTransparency = 1,
}, screen)
local rootScale = make("UIScale", { Scale = 0.92 }, root)

make("ImageLabel", {
    Name = "Glow",
    Size = UDim2.new(1, 80, 1, 80),
    Position = UDim2.fromOffset(-40, -40),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = THEME.accentB,
    ImageTransparency = 0.84,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
}, root)
make("ImageLabel", {
    Name = "Shadow",
    Size = UDim2.new(1, 36, 1, 36),
    Position = UDim2.fromOffset(-18, -14),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.35,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
}, root)

local main = make("Frame", {
    Name = "MainWindow",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, root)
corner(main, 16)
gradient(main, THEME.bgTop, THEME.bg, 90)

-- animated gradient border
local borderStroke = stroke(main, Color3.new(1, 1, 1), 1.5, 0.1)
local borderGradient = make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, THEME.accentA),
        ColorSequenceKeypoint.new(0.3, THEME.accentB),
        ColorSequenceKeypoint.new(0.55, THEME.stroke),
        ColorSequenceKeypoint.new(0.8, THEME.accentC),
        ColorSequenceKeypoint.new(1, THEME.accentA),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 0.05),
    }),
}, borderStroke)

local spin = 0
track(RunService.Heartbeat:Connect(function(dt)
    if not screen.Parent then
        disconnectAll()
        return
    end
    spin = (spin + dt * 45) % 360
    borderGradient.Rotation = spin
end))

-- aurora glow behind header
local aurora = make("Frame", {
    Name = "Aurora",
    Size = UDim2.new(1, 0, 0, 150),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, main)
corner(aurora, 16)
gradient(aurora, THEME.accentA, THEME.accentB, 70, NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.82),
    NumberSequenceKeypoint.new(0.55, 0.94),
    NumberSequenceKeypoint.new(1, 1),
}))

-- header ----------------------------------------------------------------

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, HEADER),
    BackgroundTransparency = 1,
}, main)

local logo = make("Frame", {
    Size = UDim2.fromOffset(40, 40),
    Position = UDim2.fromOffset(20, 13),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, header)
corner(logo, 12)
gradient(logo, THEME.accentA, THEME.accentB, 40)
stroke(logo, Color3.new(1, 1, 1), 1, 0.8)
label(logo, {
    Size = UDim2.fromScale(1, 1),
    Text = "V",
    Font = Enum.Font.GothamBlack,
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Center,
})

label(header, {
    Size = UDim2.fromOffset(300, 22),
    Position = UDim2.fromOffset(72, 13),
    Text = CONFIG.title,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
})
label(header, {
    Size = UDim2.fromOffset(300, 14),
    Position = UDim2.fromOffset(73, 37),
    Text = CONFIG.subtitle,
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextColor3 = THEME.accentC,
})

local sessionPill = make("Frame", {
    Size = UDim2.fromOffset(134, 26),
    Position = UDim2.new(1, -232, 0, 20),
    BackgroundColor3 = THEME.card,
    BorderSizePixel = 0,
}, header)
corner(sessionPill, 99)
stroke(sessionPill, THEME.stroke, 1, 0.1)
local sessionDot = make("Frame", {
    Size = UDim2.fromOffset(7, 7),
    Position = UDim2.fromOffset(12, 9),
    BackgroundColor3 = THEME.ok,
    BorderSizePixel = 0,
}, sessionPill)
corner(sessionDot, 4)
label(sessionPill, {
    Size = UDim2.new(1, -30, 1, 0),
    Position = UDim2.fromOffset(26, 0),
    Text = "CLIENT SESSION",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = THEME.subtext,
})

task.spawn(function()
    while screen.Parent do
        tween(sessionDot, { BackgroundTransparency = 0.7 }, 0.9, Enum.EasingStyle.Sine)
        task.wait(0.9)
        tween(sessionDot, { BackgroundTransparency = 0 }, 0.9, Enum.EasingStyle.Sine)
        task.wait(0.9)
    end
end)

local function headerButton(text, xOffset, hoverColor)
    local button = make("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, xOffset, 0, 18),
        BackgroundColor3 = THEME.card,
        Text = text,
        TextColor3 = THEME.subtext,
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, header)
    corner(button, 9)
    stroke(button, THEME.stroke, 1, 0.1)
    button.MouseEnter:Connect(function()
        tween(button, { BackgroundColor3 = hoverColor, TextColor3 = Color3.new(1, 1, 1) })
    end)
    button.MouseLeave:Connect(function()
        tween(button, { BackgroundColor3 = THEME.card, TextColor3 = THEME.subtext })
    end)
    return button
end

local minimizeButton = headerButton("–", -82, THEME.cardHover)
local closeButton = headerButton("×", -46, THEME.err)

local divider = make("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.fromOffset(0, HEADER - 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, main)
gradient(divider, THEME.accentA, THEME.accentB, 0, NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.2),
    NumberSequenceKeypoint.new(1, 1),
}))

-- drag
local dragging = false
local dragStart
local startPosition
track(header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = root.Position
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end))

-- body ------------------------------------------------------------------

local body = make("Frame", {
    Name = "Body",
    Size = UDim2.new(1, 0, 1, -HEADER),
    Position = UDim2.fromOffset(0, HEADER),
    BackgroundTransparency = 1,
}, main)

-- sidebar
local sidebar = make("Frame", {
    Name = "ProfileSidebar",
    Size = UDim2.new(0, 196, 1, -26),
    Position = UDim2.fromOffset(14, 12),
    BackgroundColor3 = THEME.panel,
    BorderSizePixel = 0,
}, body)
corner(sidebar, 14)
stroke(sidebar, THEME.stroke, 1, 0.15)

local ring = make("Frame", {
    Size = UDim2.fromOffset(82, 82),
    Position = UDim2.new(0.5, -41, 0, 16),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, sidebar)
corner(ring, 24)
gradient(ring, THEME.accentA, THEME.accentB, 45)

local avatar = make("ImageLabel", {
    Size = UDim2.new(1, -6, 1, -6),
    Position = UDim2.fromOffset(3, 3),
    BackgroundColor3 = THEME.card,
    BorderSizePixel = 0,
    ScaleType = Enum.ScaleType.Crop,
    Image = string.format("rbxthumb://type=AvatarBust&id=%d&w=420&h=420", player.UserId),
}, ring)
corner(avatar, 21)

local onlineDot = make("Frame", {
    Size = UDim2.fromOffset(14, 14),
    Position = UDim2.new(1, -10, 1, -10),
    BackgroundColor3 = THEME.ok,
    BorderSizePixel = 0,
    ZIndex = 3,
}, ring)
corner(onlineDot, 7)
stroke(onlineDot, THEME.panel, 2, 0)

label(sidebar, {
    Size = UDim2.new(1, -20, 0, 22),
    Position = UDim2.fromOffset(10, 106),
    Text = player.DisplayName,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextTruncate = Enum.TextTruncate.AtEnd,
    TextXAlignment = Enum.TextXAlignment.Center,
})
label(sidebar, {
    Size = UDim2.new(1, -20, 0, 16),
    Position = UDim2.fromOffset(10, 128),
    Text = "@" .. player.Name,
    TextSize = 11,
    TextColor3 = THEME.subtext,
    TextTruncate = Enum.TextTruncate.AtEnd,
    TextXAlignment = Enum.TextXAlignment.Center,
})

local function infoRow(index, labelText, value)
    local row = make("Frame", {
        Size = UDim2.new(1, -24, 0, 26),
        Position = UDim2.fromOffset(12, 158 + (index - 1) * 30),
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
    }, sidebar)
    corner(row, 8)
    stroke(row, THEME.stroke, 1, 0.6)
    label(row, {
        Size = UDim2.new(0.46, -3, 1, 0),
        Position = UDim2.fromOffset(9, 0),
        Text = labelText,
        TextSize = 10,
        TextColor3 = THEME.muted,
    })
    return label(row, {
        Size = UDim2.new(0.54, -12, 1, 0),
        Position = UDim2.new(0.46, 0, 0, 0),
        Text = value,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local createdAt = os.date("%d.%m.%Y", os.time() - player.AccountAge * 86400)
infoRow(1, "Joined", createdAt)
infoRow(2, "Account age", string.format("%d days", player.AccountAge))
infoRow(3, "User ID", tostring(player.UserId))
infoRow(4, "Membership", player.MembershipType.Name)
infoRow(5, "Locale", (player.LocaleId ~= "" and player.LocaleId) or "N/A")
local gameValue = infoRow(6, "Experience", "Loading...")

label(sidebar, {
    Size = UDim2.new(1, -20, 0, 14),
    Position = UDim2.new(0, 10, 1, -22),
    Text = CONFIG.toggleKey.Name .. " — hide / show",
    TextSize = 9,
    TextColor3 = THEME.muted,
    TextXAlignment = Enum.TextXAlignment.Center,
})

task.spawn(function()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    gameValue.Text = (success and info and info.Name) or "Unknown"
end)

-- content heading
local availableCount = 0
for _, entry in ipairs(CONFIG.scripts) do
    if entry.available ~= false then
        availableCount += 1
    end
end

label(body, {
    Size = UDim2.new(1, -450, 0, 24),
    Position = UDim2.fromOffset(226, 12),
    Text = "Script library",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
})
label(body, {
    Size = UDim2.new(1, -450, 0, 16),
    Position = UDim2.fromOffset(227, 36),
    Text = string.format("%d available  ·  select a module to start", availableCount),
    TextSize = 11,
    TextColor3 = THEME.subtext,
})

-- search
local searchBox = make("Frame", {
    Size = UDim2.fromOffset(190, 32),
    Position = UDim2.new(1, -204, 0, 16),
    BackgroundColor3 = THEME.panel,
    BorderSizePixel = 0,
}, body)
corner(searchBox, 10)
local searchStroke = stroke(searchBox, THEME.stroke, 1, 0.1)
label(searchBox, {
    Size = UDim2.fromOffset(24, 32),
    Position = UDim2.fromOffset(8, 0),
    Text = "⌕",
    TextSize = 16,
    TextColor3 = THEME.muted,
    TextXAlignment = Enum.TextXAlignment.Center,
})
local searchInput = make("TextBox", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.fromOffset(32, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Search scripts...",
    PlaceholderColor3 = THEME.muted,
    TextColor3 = THEME.text,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
}, searchBox)
searchInput.Focused:Connect(function()
    tween(searchStroke, { Color = THEME.accentA, Transparency = 0 })
end)
searchInput.FocusLost:Connect(function()
    tween(searchStroke, { Color = THEME.stroke, Transparency = 0.1 })
end)

-- status bar
local statusBar = make("Frame", {
    Size = UDim2.new(1, -240, 0, 28),
    Position = UDim2.new(0, 226, 1, -40),
    BackgroundColor3 = THEME.panel,
    BorderSizePixel = 0,
}, body)
corner(statusBar, 9)
stroke(statusBar, THEME.stroke, 1, 0.3)
local statusDot = make("Frame", {
    Size = UDim2.fromOffset(7, 7),
    Position = UDim2.fromOffset(12, 10),
    BackgroundColor3 = THEME.muted,
    BorderSizePixel = 0,
}, statusBar)
corner(statusDot, 4)
local status = label(statusBar, {
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.fromOffset(28, 0),
    Text = "Ready",
    TextSize = 11,
    TextColor3 = THEME.subtext,
    TextTruncate = Enum.TextTruncate.AtEnd,
})
label(statusBar, {
    Size = UDim2.fromOffset(50, 28),
    Position = UDim2.new(1, -58, 0, 0),
    Text = "KickVortex",
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextColor3 = THEME.muted,
    TextXAlignment = Enum.TextXAlignment.Right,
})

local function setStatus(message, kind)
    status.Text = message
    local color = THEME.subtext
    local dotColor = THEME.muted
    if kind == "ok" then
        color, dotColor = THEME.ok, THEME.ok
    elseif kind == "err" then
        color, dotColor = THEME.err, THEME.err
    end
    tween(status, { TextColor3 = color }, 0.2)
    tween(statusDot, { BackgroundColor3 = dotColor }, 0.2)
end

-- close logic
local closing = false
local function closeUI()
    if closing then
        return
    end
    closing = true
    tween(rootScale, { Scale = 0.9 }, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    task.wait(0.18)
    disconnectAll()
    screen:Destroy()
end

closeButton.MouseButton1Click:Connect(closeUI)

local collapsed = false
minimizeButton.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    minimizeButton.Text = collapsed and "+" or "–"
    body.Visible = not collapsed
    tween(root, { Size = collapsed and UDim2.fromOffset(W, HEADER) or UDim2.fromOffset(W, H) }, 0.28)
end)

track(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if input.KeyCode == CONFIG.toggleKey then
        root.Visible = not root.Visible
    end
end))

-- script cards ----------------------------------------------------------

local scriptList = make("ScrollingFrame", {
    Name = "ScriptList",
    Size = UDim2.new(1, -240, 1, -112),
    Position = UDim2.fromOffset(226, 60),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = THEME.accentA,
    ScrollBarImageTransparency = 0.4,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
}, body)
make("UIPadding", {
    PaddingTop = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 6),
    PaddingBottom = UDim.new(0, 4),
}, scriptList)
make("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, scriptList)

local emptyLabel = label(scriptList, {
    Size = UDim2.new(1, 0, 0, 48),
    Text = "No scripts found",
    TextSize = 12,
    TextColor3 = THEME.subtext,
    TextXAlignment = Enum.TextXAlignment.Center,
    Visible = #CONFIG.scripts == 0,
    LayoutOrder = 999,
})

local cards = {}

for index, entry in ipairs(CONFIG.scripts) do
    local isAvailable = entry.available ~= false

    local card = make("Frame", {
        Name = "ScriptCard" .. index,
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = THEME.card,
        BorderSizePixel = 0,
        LayoutOrder = index,
        ClipsDescendants = true,
    }, scriptList)
    corner(card, 13)
    local cardStroke = stroke(card, THEME.stroke, 1, 0.1)

    local icon = make("Frame", {
        Size = UDim2.fromOffset(44, 44),
        Position = UDim2.fromOffset(14, 18),
        BackgroundColor3 = isAvailable and Color3.new(1, 1, 1) or THEME.panel,
        BorderSizePixel = 0,
    }, card)
    corner(icon, 12)
    if isAvailable then
        gradient(icon, THEME.accentA, THEME.accentB, 45)
    else
        stroke(icon, THEME.stroke, 1, 0.2)
    end
    label(icon, {
        Size = UDim2.fromScale(1, 1),
        Text = isAvailable and string.upper(string.sub(entry.name, 1, 1)) or "+",
        Font = Enum.Font.GothamBold,
        TextSize = 19,
        TextColor3 = isAvailable and Color3.new(1, 1, 1) or THEME.muted,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    label(card, {
        Size = UDim2.new(1, -210, 0, 20),
        Position = UDim2.fromOffset(72, 12),
        Text = entry.name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = isAvailable and THEME.text or THEME.subtext,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    label(card, {
        Size = UDim2.new(1, -210, 0, 16),
        Position = UDim2.fromOffset(72, 32),
        Text = entry.desc or "",
        TextSize = 11,
        TextColor3 = THEME.subtext,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local tag = make("Frame", {
        Size = UDim2.fromOffset(40, 16),
        Position = UDim2.fromOffset(72, 54),
        BackgroundColor3 = isAvailable and THEME.ok or THEME.muted,
        BackgroundTransparency = 0.86,
        BorderSizePixel = 0,
    }, card)
    corner(tag, 99)
    label(tag, {
        Size = UDim2.fromScale(1, 1),
        Text = entry.tag or "",
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = isAvailable and THEME.ok or THEME.muted,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local progress = make("Frame", {
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 4,
    }, card)
    gradient(progress, THEME.accentA, THEME.accentC, 0)

    local runButton = make("TextButton", {
        Size = UDim2.fromOffset(96, 36),
        Position = UDim2.new(1, -112, 0.5, -18),
        BackgroundColor3 = isAvailable and Color3.new(1, 1, 1) or THEME.panel,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Active = isAvailable,
        Selectable = isAvailable,
        ZIndex = 5,
    }, card)
    corner(runButton, 10)
    local buttonScale = make("UIScale", { Scale = 1 }, runButton)

    local runLabel = label(runButton, {
        Name = "ButtonCaption",
        Size = UDim2.fromScale(1, 1),
        Text = isAvailable and "RUN" or "SOON",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = isAvailable and Color3.new(1, 1, 1) or THEME.muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextStrokeColor3 = Color3.fromRGB(30, 24, 61),
        TextStrokeTransparency = isAvailable and 0.45 or 1,
        ZIndex = 6,
    })

    local buttonStroke
    if isAvailable then
        gradient(runButton, THEME.accentA, THEME.accentB, 0)
        buttonStroke = stroke(runButton, THEME.accentC, 1, 0.7)
    else
        stroke(runButton, THEME.stroke, 1, 0.3)
    end

    card.MouseEnter:Connect(function()
        tween(card, { BackgroundColor3 = THEME.cardHover })
        tween(cardStroke, {
            Color = isAvailable and THEME.accentA or THEME.stroke,
            Transparency = isAvailable and 0 or 0.1,
        })
    end)
    card.MouseLeave:Connect(function()
        tween(card, { BackgroundColor3 = THEME.card })
        tween(cardStroke, { Color = THEME.stroke, Transparency = 0.1 })
    end)

    if isAvailable then
        runButton.MouseEnter:Connect(function()
            tween(buttonStroke, { Transparency = 0.1 })
            tween(buttonScale, { Scale = 1.04 }, 0.12)
        end)
        runButton.MouseLeave:Connect(function()
            tween(buttonStroke, { Transparency = 0.7 })
            tween(buttonScale, { Scale = 1 }, 0.12)
        end)
        runButton.MouseButton1Down:Connect(function()
            tween(buttonScale, { Scale = 0.95 }, 0.08)
        end)
        runButton.MouseButton1Up:Connect(function()
            tween(buttonScale, { Scale = 1.04 }, 0.1)
        end)

        local busy = false
        runButton.MouseButton1Click:Connect(function()
            if busy then
                return
            end
            busy = true
            runLabel.Text = "LOADING"
            runLabel.TextSize = 11
            progress.Size = UDim2.new(0, 0, 0, 2)
            tween(progress, { Size = UDim2.new(0.85, 0, 0, 2) }, 1.4)

            task.spawn(function()
                local success = runScript(entry, setStatus)
                if success then
                    tween(progress, { Size = UDim2.new(1, 0, 0, 2) }, 0.15)
                    runLabel.Text = "DONE"
                    runLabel.TextSize = 13
                    task.wait(0.6)
                    closeUI()
                    return
                end
                tween(cardStroke, { Color = THEME.err, Transparency = 0 }, 0.15)
                progress.Size = UDim2.new(0, 0, 0, 2)
                runLabel.Text = "RUN"
                runLabel.TextSize = 13
                task.wait(0.9)
                tween(cardStroke, { Color = THEME.stroke, Transparency = 0.1 }, 0.3)
                busy = false
            end)
        end)
    else
        runButton.MouseButton1Click:Connect(function()
            setStatus("This script is coming soon", "idle")
        end)
    end

    cards[#cards + 1] = { frame = card, name = string.lower(entry.name) }
end

-- search filter
searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(searchInput.Text)
    local visible = 0
    for _, item in ipairs(cards) do
        local match = query == "" or string.find(item.name, query, 1, true) ~= nil
        item.frame.Visible = match
        if match then
            visible += 1
        end
    end
    emptyLabel.Visible = visible == 0
end)

-- intro
tween(rootScale, { Scale = 1 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
