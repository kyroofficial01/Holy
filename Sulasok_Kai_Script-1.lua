--// Roblox Luau / Executor GUI
--// Supported PlaceId: 107778070777162
--// Fixed Circle Icon & Floating Toggle Button

repeat task.wait() until game:IsLoaded()

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local CONFIG_FILE = "Sulasok_Config.json"

local DefaultConfig = {
    Theme = "Sulasok",
    Accent = "#5CE1E6",
    Accent2 = "#FF5CA8",

    Background = "#0A0F1A",
    Transparency = 0,

    CornerRadius = 16,

    Width = 520,   
    Height = 360,  
}

local Config = table.clone(DefaultConfig)

--==================================================
-- EXECUTOR FILE CONFIG
--==================================================

local function loadConfig()
    if not (readfile and isfile) then
        return
    end
    if not isfile(CONFIG_FILE) then
        return
    end

    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)

    if success and type(result) == "table" then
        for key, value in pairs(DefaultConfig) do
            if result[key] ~= nil then
                Config[key] = result[key]
            end
        end
    end
end

local function saveConfig()
    if not (writefile and HttpService) then
        return
    end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
end

loadConfig()

--==================================================
-- COLOR
--==================================================

local function hexToColor3(hex)
    hex = tostring(hex or "#FFFFFF"):gsub("#", "")
    if #hex ~= 6 then
        return Color3.fromRGB(255, 255, 255)
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then
        return Color3.fromRGB(255, 255, 255)
    end
    return Color3.fromRGB(r, g, b)
end

local AccentColor = hexToColor3(Config.Accent)
local Accent2Color = hexToColor3(Config.Accent2)

local function newGradient(parent, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, AccentColor),
        ColorSequenceKeypoint.new(1, Accent2Color),
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local ThemePresets = {
    {Name = "Sulasok", Accent = "#5CE1E6", Accent2 = "#FF5CA8"},
    {Name = "Ocean", Accent = "#00D4FF", Accent2 = "#0077FF"},
    {Name = "Purple Dream", Accent = "#C77DFF", Accent2 = "#7B2CBF"},
    {Name = "Emerald", Accent = "#00F5A0", Accent2 = "#00D9F5"},
    {Name = "Sunset", Accent = "#FF6B6B", Accent2 = "#FFA500"},
    {Name = "Midnight", Accent = "#A0AEC0", Accent2 = "#4A5568"},
}

--==================================================
-- SUPPORTED GAME
--==================================================

local SupportedPlaceId = 107778070777162

local function isSupportedGame()
    return game.PlaceId == SupportedPlaceId
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaiHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

pcall(function()
    local existing = ScreenGui.Parent:FindFirstChild("KaiHub")
    if existing and existing ~= ScreenGui then
        existing:Destroy()
    end
end)

--==================================================
-- LOADING SCREEN
--==================================================

local Loading = Instance.new("Frame")
Loading.Size = UDim2.fromScale(1, 1)
Loading.BackgroundColor3 = Color3.fromRGB(7, 10, 17)
Loading.BorderSizePixel = 0
Loading.Parent = ScreenGui

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingTitle.Position = UDim2.fromScale(0.5, 0.42)
LoadingTitle.Size = UDim2.fromOffset(400, 60)
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.Text = "KAI HUB"
LoadingTitle.TextSize = 36
LoadingTitle.TextColor3 = AccentColor
LoadingTitle.Parent = Loading
newGradient(LoadingTitle, 0)

local LoadingSub = Instance.new("TextLabel")
LoadingSub.BackgroundTransparency = 1
LoadingSub.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingSub.Position = UDim2.fromScale(0.5, 0.51)
LoadingSub.Size = UDim2.fromOffset(400, 26)
LoadingSub.Font = Enum.Font.Gotham
LoadingSub.Text = "Initializing..."
LoadingSub.TextSize = 14
LoadingSub.TextColor3 = Color3.fromRGB(170, 175, 185)
LoadingSub.Parent = Loading

local LoadingBarBack = Instance.new("Frame")
LoadingBarBack.AnchorPoint = Vector2.new(0.5, 0.5)
LoadingBarBack.Position = UDim2.fromScale(0.5, 0.58)
LoadingBarBack.Size = UDim2.fromOffset(280, 5)
LoadingBarBack.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
LoadingBarBack.BorderSizePixel = 0
LoadingBarBack.Parent = Loading

local LoadingBarCorner = Instance.new("UICorner")
LoadingBarCorner.CornerRadius = UDim.new(1, 0)
LoadingBarCorner.Parent = LoadingBarBack

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.fromScale(0, 1)
LoadingBar.BackgroundColor3 = AccentColor
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingBarBack

local LoadingBarCorner2 = Instance.new("UICorner")
LoadingBarCorner2.CornerRadius = UDim.new(1, 0)
LoadingBarCorner2.Parent = LoadingBar

TweenService:Create(
    LoadingBar,
    TweenInfo.new(1.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Size = UDim2.fromScale(1, 1)}
):Play()

task.wait(1.8)

TweenService:Create(Loading, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
for _, obj in ipairs(Loading:GetDescendants()) do
    if obj:IsA("TextLabel") then
        TweenService:Create(obj, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
    elseif obj:IsA("Frame") and obj ~= Loading then
        TweenService:Create(obj, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
    end
end

task.wait(0.45)
Loading:Destroy()

--==================================================
-- MAIN GUI
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.52)
Main.Size = UDim2.fromOffset(Config.Width, Config.Height)
Main.BackgroundColor3 = hexToColor3(Config.Background)
Main.BackgroundTransparency = Config.Transparency
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, Config.CornerRadius)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Transparency = 0.08
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = Main
newGradient(MainStroke, 35)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 10)
Title.Size = UDim2.fromOffset(180, 22)
Title.Font = Enum.Font.GothamBold
Title.Text = "KAI HUB"
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.Parent = TopBar
newGradient(Title, 0)

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(19, 29)
Subtitle.Size = UDim2.fromOffset(180, 15)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Kai's Script Hub"
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextColor3 = Color3.fromRGB(145, 150, 160)
Subtitle.Parent = TopBar

--==================================================
-- MINIMIZE / CLOSE
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.AnchorPoint = Vector2.new(1, 0.5)
Minimize.Position = UDim2.new(1, -48, 0.5, 0)
Minimize.Size = UDim2.fromOffset(28, 28)
Minimize.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
Minimize.BackgroundTransparency = 0.15
Minimize.Text = "–"
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 18
Minimize.TextColor3 = Color3.fromRGB(210, 214, 222)
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(1, 0)
MinimizeCorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.AnchorPoint = Vector2.new(1, 0.5)
Close.Position = UDim2.new(1, -12, 0.5, 0)
Close.Size = UDim2.fromOffset(28, 28)
Close.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
Close.BackgroundTransparency = 0.15
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.TextColor3 = Color3.fromRGB(230, 230, 235)
Close.AutoButtonColor = false
Close.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = Close

local function addHoverScale(btn)
    local originalSize = btn.Size
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back), {
            Size = UDim2.fromOffset(originalSize.X.Offset + 3, originalSize.Y.Offset + 3)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            Size = originalSize
        }):Play()
    end)
end

addHoverScale(Minimize)
addHoverScale(Close)

--==================================================
-- LEFT NAVIGATION
--==================================================

local Navigation = Instance.new("Frame")
Navigation.Position = UDim2.fromOffset(12, 58)
Navigation.Size = UDim2.new(0, 128, 1, -70)
Navigation.BackgroundTransparency = 1
Navigation.Parent = Main

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 6)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Parent = Navigation

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(148, 58)
Content.Size = UDim2.new(1, -160, 1, -70)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}

local function createPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.fromScale(1, 1)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = AccentColor
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 2)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 4)
    Padding.Parent = Page

    Pages[name] = Page
    return Page
end

--==================================================
-- NAV BUTTON
--==================================================

local CurrentPage
local NavButtons = {}

local function createNavButton(text, icon, pageName, order)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(22, 27, 40)
    Button.BackgroundTransparency = 0.2
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.LayoutOrder = order
    Button.Parent = Navigation

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local Icon = Instance.new("TextLabel")
    Icon.Position = UDim2.fromOffset(12, 0)
    Icon.Size = UDim2.fromOffset(18, 36)
    Icon.BackgroundTransparency = 1
    Icon.Text = icon
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 13
    Icon.TextXAlignment = Enum.TextXAlignment.Left
    Icon.TextColor3 = Color3.fromRGB(165, 170, 180)
    Icon.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.fromOffset(34, 0)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(165, 170, 180)
    Label.Parent = Button

    local gradient

    local function setSelected(selected)
        if selected then
            Button.BackgroundTransparency = 0
            Button.BackgroundColor3 = AccentColor
            if not gradient then
                gradient = newGradient(Button, 25)
            end
            Icon.TextColor3 = Color3.fromRGB(10, 14, 20)
            Label.TextColor3 = Color3.fromRGB(10, 14, 20)
            Label.Font = Enum.Font.GothamBold
        else
            if gradient then
                gradient:Destroy()
                gradient = nil
            end
            Button.BackgroundTransparency = 0.2
            Button.BackgroundColor3 = Color3.fromRGB(22, 27, 40)
            Icon.TextColor3 = Color3.fromRGB(165, 170, 180)
            Label.TextColor3 = Color3.fromRGB(165, 170, 180)
            Label.Font = Enum.Font.GothamMedium
        end
    end

    NavButtons[Button] = setSelected

    Button.MouseEnter:Connect(function()
        if CurrentPage ~= pageName then
            TweenService:Create(Button, TweenInfo.new(0.12),
                {BackgroundColor3 = Color3.fromRGB(30, 36, 52)}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.12), {TextColor3 = AccentColor}):Play()
        end
    end)

    Button.MouseLeave:Connect(function()
        if CurrentPage ~= pageName then
            Button.BackgroundColor3 = Color3.fromRGB(22, 27, 40)
            Icon.TextColor3 = Color3.fromRGB(165, 170, 180)
        end
    end)

    Button.MouseButton1Click:Connect(function()
        for _, page in pairs(Pages) do
            page.Visible = false
        end
        for _, fn in pairs(NavButtons) do
            fn(false)
        end
        setSelected(true)
        Pages[pageName].Visible = true
        CurrentPage = pageName
    end)

    return Button
end

--==================================================
-- PAGES
--==================================================

local InformationPage = createPage("Information")
local KeyPage = createPage("ScriptsKey")
local NoKeyPage = createPage("ScriptsNoKey")
local HopPage = createPage("Hop")
local SettingsPage = createPage("Settings")

local navInfo = createNavButton("Information", "⌂", "Information", 1)
createNavButton("Scripts • Key", "🔑", "ScriptsKey", 2)
createNavButton("Scripts • No Key", "⚡", "ScriptsNoKey", 3)
createNavButton("Hop Script", "💎", "Hop", 4)
createNavButton("Settings", "⚙", "Settings", 5)

--==================================================
-- UI HELPERS
--==================================================

local function createSectionTitle(parent, text, order)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 26)
    Holder.BackgroundTransparency = 1
    Holder.LayoutOrder = order or 1
    Holder.Parent = parent

    local Bar = Instance.new("Frame")
    Bar.Position = UDim2.fromOffset(1, 3)
    Bar.Size = UDim2.fromOffset(3, 20)
    Bar.BorderSizePixel = 0
    Bar.Parent = Holder
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar
    newGradient(Bar, 90)

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.fromOffset(12, 0)
    Label.Size = UDim2.new(1, -14, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(245, 245, 250)
    Label.Parent = Holder
    newGradient(Label, 0)

    return Holder
end

local function createInfoRow(parent, icon, text, order, textColor)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -4, 0, 20)
    Holder.BackgroundTransparency = 1
    Holder.LayoutOrder = order or 1
    Holder.Parent = parent

    local Icon = Instance.new("TextLabel")
    Icon.Position = UDim2.fromOffset(2, 0)
    Icon.Size = UDim2.fromOffset(16, 20)
    Icon.BackgroundTransparency = 1
    Icon.Text = icon
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 11
    Icon.TextXAlignment = Enum.TextXAlignment.Left
    Icon.TextColor3 = Color3.fromRGB(140, 148, 165)
    Icon.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.fromOffset(22, 0)
    Label.Size = UDim2.new(1, -24, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = textColor or Color3.fromRGB(175, 180, 195)
    Label.Parent = Holder

    return Label
end

local function createCard(parent, height, order)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -4, 0, height)
    Card.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
    Card.BackgroundTransparency = 0.06
    Card.BorderSizePixel = 0
    Card.LayoutOrder = order or 1
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 12)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.5
    CardStroke.Color = Color3.fromRGB(55, 65, 90)
    CardStroke.Parent = Card

    return Card
end

--==================================================
-- INFORMATION PAGE
--==================================================

createSectionTitle(InformationPage, "Welcome to Kai Hub", 1)

local SubWelcome = Instance.new("TextLabel")
SubWelcome.Size = UDim2.new(1, -4, 0, 16)
SubWelcome.BackgroundTransparency = 1
SubWelcome.Text = "Your ultimate Roblox script hub."
SubWelcome.Font = Enum.Font.Gotham
SubWelcome.TextSize = 11
SubWelcome.TextXAlignment = Enum.TextXAlignment.Left
SubWelcome.TextColor3 = Color3.fromRGB(145, 150, 165)
SubWelcome.LayoutOrder = 2
SubWelcome.Parent = InformationPage

local ProfileCard = createCard(InformationPage, 88, 3)

local ProfileImage = Instance.new("ImageLabel")
ProfileImage.Position = UDim2.fromOffset(10, 10)
ProfileImage.Size = UDim2.fromOffset(66, 66)
ProfileImage.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
ProfileImage.BorderSizePixel = 0
ProfileImage.Parent = ProfileCard

local ProfileImageCorner = Instance.new("UICorner")
ProfileImageCorner.CornerRadius = UDim.new(1, 0)
ProfileImageCorner.Parent = ProfileImage

local AvatarRing = Instance.new("UIStroke")
AvatarRing.Thickness = 2
AvatarRing.Transparency = 0.1
AvatarRing.Parent = ProfileImage
newGradient(AvatarRing, 40)

local ProfileName = Instance.new("TextLabel")
ProfileName.Position = UDim2.fromOffset(88, 14)
ProfileName.Size = UDim2.new(0.42, -10, 0, 20)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = LocalPlayer.Name
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextSize = 15
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.TextColor3 = Color3.fromRGB(245, 245, 250)
ProfileName.Parent = ProfileCard

local DisplayName = Instance.new("TextLabel")
DisplayName.Position = UDim2.fromOffset(88, 34)
DisplayName.Size = UDim2.new(0.42, -10, 0, 15)
DisplayName.BackgroundTransparency = 1
DisplayName.Text = "@" .. LocalPlayer.DisplayName
DisplayName.Font = Enum.Font.Gotham
DisplayName.TextSize = 11
DisplayName.TextXAlignment = Enum.TextXAlignment.Left
DisplayName.TextColor3 = AccentColor
DisplayName.Parent = ProfileCard

local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Position = UDim2.fromOffset(88, 52)
UserIdLabel.Size = UDim2.new(0.55, -10, 0, 14)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "User ID: " .. tostring(LocalPlayer.UserId)
UserIdLabel.Font = Enum.Font.Gotham
UserIdLabel.TextSize = 9
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left
UserIdLabel.TextColor3 = Color3.fromRGB(120, 126, 140)
UserIdLabel.Parent = ProfileCard

task.spawn(function()
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if success and image then
        ProfileImage.Image = image
    end
end)

local PlaceBox = Instance.new("Frame")
PlaceBox.AnchorPoint = Vector2.new(1, 0.5)
PlaceBox.Position = UDim2.new(1, -10, 0.5, 0)
PlaceBox.Size = UDim2.fromOffset(128, 48)
PlaceBox.BackgroundColor3 = Color3.fromRGB(24, 30, 46)
PlaceBox.BackgroundTransparency = 0.12
PlaceBox.BorderSizePixel = 0
PlaceBox.Parent = ProfileCard

local PlaceBoxCorner = Instance.new("UICorner")
PlaceBoxCorner.CornerRadius = UDim.new(0, 11)
PlaceBoxCorner.Parent = PlaceBox

local PlaceIcon = Instance.new("TextLabel")
PlaceIcon.Position = UDim2.fromOffset(10, 0)
PlaceIcon.Size = UDim2.fromOffset(22, 48)
PlaceIcon.BackgroundTransparency = 1
PlaceIcon.Text = "▣"
PlaceIcon.Font = Enum.Font.GothamBold
PlaceIcon.TextSize = 18
PlaceIcon.TextColor3 = Color3.fromRGB(225, 228, 235)
PlaceIcon.Parent = PlaceBox

local PlaceTitle = Instance.new("TextLabel")
PlaceTitle.Position = UDim2.fromOffset(36, 8)
PlaceTitle.Size = UDim2.new(1, -42, 0, 14)
PlaceTitle.BackgroundTransparency = 1
PlaceTitle.Text = "Place ID"
PlaceTitle.Font = Enum.Font.Gotham
PlaceTitle.TextSize = 10
PlaceTitle.TextXAlignment = Enum.TextXAlignment.Left
PlaceTitle.TextColor3 = Color3.fromRGB(145, 150, 165)
PlaceTitle.Parent = PlaceBox

local PlaceIdText = Instance.new("TextLabel")
PlaceIdText.Position = UDim2.fromOffset(36, 24)
PlaceIdText.Size = UDim2.new(1, -42, 0, 16)
PlaceIdText.BackgroundTransparency = 1
PlaceIdText.Text = tostring(game.PlaceId)
PlaceIdText.Font = Enum.Font.GothamBold
PlaceIdText.TextSize = 11
PlaceIdText.TextXAlignment = Enum.TextXAlignment.Left
PlaceIdText.TextColor3 = AccentColor
PlaceIdText.Parent = PlaceBox

local InfoCard = createCard(InformationPage, 118, 4)

local InfoHeaderIcon = Instance.new("TextLabel")
InfoHeaderIcon.Position = UDim2.fromOffset(12, 10)
InfoHeaderIcon.Size = UDim2.fromOffset(16, 18)
InfoHeaderIcon.BackgroundTransparency = 1
InfoHeaderIcon.Text = "ⓘ"
InfoHeaderIcon.Font = Enum.Font.GothamBold
InfoHeaderIcon.TextSize = 13
InfoHeaderIcon.TextColor3 = AccentColor
InfoHeaderIcon.Parent = InfoCard

local InfoHeader = Instance.new("TextLabel")
InfoHeader.Position = UDim2.fromOffset(32, 8)
InfoHeader.Size = UDim2.new(1, -40, 0, 22)
InfoHeader.BackgroundTransparency = 1
InfoHeader.Text = "Script Information"
InfoHeader.Font = Enum.Font.GothamBold
InfoHeader.TextSize = 13
InfoHeader.TextXAlignment = Enum.TextXAlignment.Left
InfoHeader.TextColor3 = Color3.fromRGB(245, 245, 250)
InfoHeader.Parent = InfoCard

createInfoRow(InfoCard, "♟", "Developer: Kai", 1).Parent = InfoCard

local SupportedRow = createInfoRow(
    InfoCard,
    "🛡",
    "Supported Place: " .. tostring(SupportedPlaceId),
    2
)
SupportedRow.TextColor3 = Color3.fromRGB(90, 235, 170)

local StatusRow = createInfoRow(InfoCard, "★", "", 3)
if isSupportedGame() then
    StatusRow.Text = "Status:  ✓ Supported"
    StatusRow.TextColor3 = Color3.fromRGB(90, 235, 170)
else
    StatusRow.Text = "Status:  ⚠ Unsupported"
    StatusRow.TextColor3 = Color3.fromRGB(255, 190, 90)
end

for _, row in ipairs(InfoCard:GetChildren()) do
    if row:IsA("Frame") then
        row.Position = UDim2.fromOffset(0, 34 + (row.LayoutOrder - 1) * 24)
    end
end

local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(1, -4, 0, 40)
DiscordButton.BackgroundColor3 = AccentColor
DiscordButton.BorderSizePixel = 0
DiscordButton.Text = ""
DiscordButton.AutoButtonColor = false
DiscordButton.LayoutOrder = 5
DiscordButton.Parent = InformationPage

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 11)
DiscordCorner.Parent = DiscordButton
newGradient(DiscordButton, 25)

local DiscordIcon = Instance.new("TextLabel")
DiscordIcon.AnchorPoint = Vector2.new(0.5, 0.5)
DiscordIcon.Position = UDim2.new(0.5, -48, 0.5, 0)
DiscordIcon.Size = UDim2.fromOffset(18, 18)
DiscordIcon.BackgroundTransparency = 1
DiscordIcon.Text = "✧"
DiscordIcon.Font = Enum.Font.GothamBold
DiscordIcon.TextSize = 14
DiscordIcon.TextColor3 = Color3.fromRGB(12, 16, 24)
DiscordIcon.Parent = DiscordButton

local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.AnchorPoint = Vector2.new(0.5, 0.5)
DiscordLabel.Position = UDim2.new(0.5, 12, 0.5, 0)
DiscordLabel.Size = UDim2.fromOffset(100, 18)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.Text = "Copy Discord"
DiscordLabel.Font = Enum.Font.GothamBold
DiscordLabel.TextSize = 12
DiscordLabel.TextColor3 = Color3.fromRGB(12, 16, 24)
DiscordLabel.Parent = DiscordButton

DiscordButton.MouseEnter:Connect(function()
    TweenService:Create(DiscordButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play()
end)
DiscordButton.MouseLeave:Connect(function()
    TweenService:Create(DiscordButton, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
end)

DiscordButton.MouseButton1Click:Connect(function()
    local DiscordInvite = "YOUR_DISCORD_INVITE"
    if setclipboard then
        pcall(function()
            setclipboard(DiscordInvite)
        end)
    end
    DiscordLabel.Text = "Copied ✓"
    task.delay(1.4, function()
        DiscordLabel.Text = "Copy Discord"
    end)
end)

--==================================================
-- SCRIPT LOADER
--==================================================

local function executeScript(url)
    if not url or url == "" then
        return
    end
    local success, errorMessage = pcall(function()
        local source = game:HttpGet(url)
        local func = loadstring(source)
        if func then
            func()
        end
    end)
    if not success then
        warn("[Kai Hub] Script error:", errorMessage)
    end
end

local function addScriptButton(parent, name, url, status)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -4, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(22, 27, 40)
    Button.BackgroundTransparency = 0.05
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Thickness = 1
    ButtonStroke.Transparency = 0.55
    ButtonStroke.Color = Color3.fromRGB(50, 58, 78)
    ButtonStroke.Parent = Button

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Position = UDim2.fromOffset(12, 5)
    NameLabel.Size = UDim2.new(1, -110, 0, 16)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name
    NameLabel.Font = Enum.Font.GothamMedium
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextColor3 = Color3.fromRGB(235, 237, 242)
    NameLabel.Parent = Button

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Position = UDim2.fromOffset(12, 22)
    StatusLabel.Size = UDim2.new(1, -110, 0, 13)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = status or "Script"
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 9
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextColor3 = AccentColor
    StatusLabel.Parent = Button

    local Arrow = Instance.new("TextLabel")
    Arrow.AnchorPoint = Vector2.new(1, 0.5)
    Arrow.Position = UDim2.new(1, -12, 0.5, 0)
    Arrow.Size = UDim2.fromOffset(16, 16)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "›"
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 18
    Arrow.TextColor3 = Color3.fromRGB(120, 125, 135)
    Arrow.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.12),
            {BackgroundColor3 = Color3.fromRGB(30, 36, 52)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.12), {TextColor3 = AccentColor}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.12),
            {BackgroundColor3 = Color3.fromRGB(22, 27, 40)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.12),
            {TextColor3 = Color3.fromRGB(120, 125, 135)}):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        executeScript(url)
    end)

    return Button
end

--==================================================
-- SCRIPT LISTS
--==================================================

local KeyScripts = {
    {Name = "Ajjans", Url = "https://api.luarmor.net/files/v4/loaders/359e97f8618e9008afe5f496184ebb7c.lua", Status = "Need Key"},
    {Name = "Clover", Url = "https://cloverhub.app/clover.lua", Status = "Need Key"},
    {Name = "Fyy", Url = "https://FyyCommunity.my.id", Status = "Need Key"},
    {Name = "BigFoot", Url = "https://raw.githubusercontent.com/hanniii1/Loader/refs/heads/main/BFLoader.lua", Status = "Need Key"},
    {Name = "Zeroin Hub", Url = "https://zeroinhub.com/api/script", Status = "Need Key (OP)"},
    {Name = "Speed Hub", Url = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", Status = "Need Key"},
    {Name = "Nasi Rendang", Url = "https://raw.githubusercontent.com/JualNasiRendang/loader/refs/heads/main/main.lua", Status = "Need Key"},
    {Name = "Synerox Hub", Url = "https://synex.lat/loaders/stealegg.lua", Status = "Need Key"},
    {Name = "Omg Hub", Url = "https://raw.githubusercontent.com/Omgshit/Scripts/main/MainLoader.lua", Status = "Need Key"},
    {Name = "Solix Hub", Url = "https://raw.githubusercontent.com/bao8jl/solixhub/main/loader", Status = "Need Key"},
}

local NoKeyScripts = {
    {Name = "Chili", Url = "https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua", Status = "No Key"},
    {Name = "Diablo Hub", Url = "https://pastebin.com/raw/f1nDPF4C", Status = "Under Maintenance"},
    {Name = "Limbo Hub", Url = "https://limbohub.my.id/loader.lua", Status = "No Key"},
    {Name = "Lennon", Url = "https://api.luarmor.net/files/v4/loaders/4595fe31a5f7a8b4f4dd7071f3119ef7.lua", Status = "No Key"},
    {Name = "Miranda", Url = "https://raw.githubusercontent.com/miirandahub/loader/refs/heads/main/mirandaafk.lua", Status = "No Key"},
    {Name = "Sena Hub", Url = "https://senahub.xyz/raw/loader", Status = "No Key"},
    {Name = "Lkz", Url = "https://api.luarmor.net/files/v4/loaders/65bf3459d87ba3ac46350e154b640929.lua", Status = "No Key"},
    {Name = "FoxName", Url = "https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/Fn-stealanegg.lua", Status = "No Key"},
    {Name = "Decode", Url = "https://raw.githubusercontent.com/ItzYumi/Decode/refs/heads/main/DE%3ACODE.lua", Status = "No Key"},
    {Name = "Bks", Url = "https://api.luarmor.net/files/v4/loaders/9ee4edde227ac85f50872bf9e4226508.lua", Status = "No Key"},
    {Name = "Night Hub", Url = "https://raw.githubusercontent.com/WhiteX1208/Scripts/refs/heads/main/StealEggOnly.luau", Status = "No Key"},
    {Name = "VoidShell", Url = "https://raw.githubusercontent.com/VoidShell-null/VoidShell-Hub/refs/heads/main/Scripts/StealAnEgg.luau", Status = "No Key"},
    {Name = "Oxide Hub", Url = "https://raw.githubusercontent.com/xulfo/Oxide-Loader/main/Main.lua", Status = "No Key"},
    {Name = "Blyxo Hub", Url = "https://flowauth.net/v1/loaders/69d3463240384f3a73fbe32c178093a2.lua", Status = "No Key"},
    {Name = "Vincitore", Url = "https://raw.githubusercontent.com/idk953072-crypto/Steal-an-Egg/refs/heads/main/vincitore", Status = "No Key"},
    {Name = "Glint Hub", Url = "https://flowauth.net/v1/loaders/6824c37a4078d7d311677732e231edaa.lua", Status = "No Key"},
    {Name = "Vanta-B", Url = "https://raw.githubusercontent.com/tranduykhanh08428-web/VantablackHub/refs/heads/main/Stealanegg.lua.txt", Status = "No Key"},
    {Name = "Hoshi Hub", Url = "https://hoshihub.site/loader.lua", Status = "No Key"},
    {Name = "Shader Hub", Url = "https://raw.githubusercontent.com/robloxscripts2026/simple-shader/refs/heads/main/lua", Status = "No Key"},
    {Name = "Cyrus Hub", Url = "https://raw.githubusercontent.com/CyrusOffc/scriptcyrus/refs/heads/main/loader", Status = "No Key"},
    {Name = "Lennon V3", Url = "https://raw.githubusercontent.com/lennonxscripts/lennonhubv3/refs/heads/main/stealanegg.lua", Status = "No Key"},
    {Name = "Yukudo Hub", Url = "https://raw.githubusercontent.com/betdoyvaka/stealanegg/main/Loader.lua", Status = "No Key"},
    {Name = "Pulse Hub", Url = "https://raw.githubusercontent.com/PulseZax/Loader/refs/heads/main/.lua", Status = "No Key"},
}

for _, data in ipairs(KeyScripts) do
    addScriptButton(KeyPage, data.Name, data.Url, data.Status)
end

for _, data in ipairs(NoKeyScripts) do
    addScriptButton(NoKeyPage, data.Name, data.Url, data.Status)
end

--==================================================
-- HOP PAGE
--==================================================

local function hopServer()
    local servers = {}
    local cursor = ""

    repeat
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
            ))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            cursor = result.nextPageCursor or ""
        else
            cursor = ""
        end
    until cursor == "" or #servers > 0

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    else
        warn("[Kai Hub] No available servers to hop to.")
    end
end

createSectionTitle(HopPage, "Server Hop", 1)

local HopLabel = Instance.new("TextLabel")
HopLabel.Size = UDim2.new(1, -4, 0, 18)
HopLabel.BackgroundTransparency = 1
HopLabel.Text = "Teleport to a random server in this place."
HopLabel.Font = Enum.Font.Gotham
HopLabel.TextSize = 11
HopLabel.TextXAlignment = Enum.TextXAlignment.Left
HopLabel.TextColor3 = Color3.fromRGB(145, 150, 165)
HopLabel.LayoutOrder = 2
HopLabel.Parent = HopPage

local HopButton = Instance.new("TextButton")
HopButton.Size = UDim2.new(1, -4, 0, 40)
HopButton.BackgroundColor3 = AccentColor
HopButton.BorderSizePixel = 0
HopButton.Text = "Hop Server"
HopButton.Font = Enum.Font.GothamBold
HopButton.TextSize = 12
HopButton.TextColor3 = Color3.fromRGB(12, 16, 24)
HopButton.AutoButtonColor = false
HopButton.LayoutOrder = 3
HopButton.Parent = HopPage

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 11)
HopCorner.Parent = HopButton
newGradient(HopButton, 25)

HopButton.MouseEnter:Connect(function()
    TweenService:Create(HopButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play()
end)
HopButton.MouseLeave:Connect(function()
    TweenService:Create(HopButton, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
end)

HopButton.MouseButton1Click:Connect(function()
    HopButton.Text = "Hopping..."
    hopServer()
end)

createSectionTitle(HopPage, "Advanced Hop", 4)
addScriptButton(HopPage, "ServerHop (Find Server)", "https://raw.githubusercontent.com/GlazeScripts/Private-Server-Finder/refs/heads/main/Glazehub.lua", "Find Server")

--==================================================
-- SETTINGS PAGE
--==================================================

createSectionTitle(SettingsPage, "Quick Themes", 1)

local ThemeHint = Instance.new("TextLabel")
ThemeHint.Size = UDim2.new(1, -4, 0, 15)
ThemeHint.BackgroundTransparency = 1
ThemeHint.Text = "Click a preset — colors update & save. Re-execute for full refresh."
ThemeHint.Font = Enum.Font.Gotham
ThemeHint.TextSize = 10
ThemeHint.TextXAlignment = Enum.TextXAlignment.Left
ThemeHint.TextColor3 = Color3.fromRGB(145, 150, 165)
ThemeHint.LayoutOrder = 2
ThemeHint.Parent = SettingsPage

local ThemeContainer = Instance.new("Frame")
ThemeContainer.Size = UDim2.new(1, -4, 0, 100)
ThemeContainer.BackgroundTransparency = 1
ThemeContainer.LayoutOrder = 3
ThemeContainer.Parent = SettingsPage

local ThemeLayout = Instance.new("UIGridLayout")
ThemeLayout.CellSize = UDim2.fromOffset(118, 30)
ThemeLayout.CellPadding = UDim2.fromOffset(6, 6)
ThemeLayout.SortOrder = Enum.SortOrder.LayoutOrder
ThemeLayout.Parent = ThemeContainer

for i, preset in ipairs(ThemePresets) do
    local ThemeBtn = Instance.new("TextButton")
    ThemeBtn.Size = UDim2.fromOffset(118, 30)
    ThemeBtn.BackgroundColor3 = Color3.fromRGB(22, 27, 40)
    ThemeBtn.BorderSizePixel = 0
    ThemeBtn.Text = preset.Name
    ThemeBtn.Font = Enum.Font.GothamMedium
    ThemeBtn.TextSize = 11
    ThemeBtn.TextColor3 = Color3.fromRGB(230, 233, 240)
    ThemeBtn.AutoButtonColor = false
    ThemeBtn.LayoutOrder = i
    ThemeBtn.Parent = ThemeContainer

    local ThemeCorner = Instance.new("UICorner")
    ThemeCorner.CornerRadius = UDim.new(0, 8)
    ThemeCorner.Parent = ThemeBtn

    local ThemeStroke = Instance.new("UIStroke")
    ThemeStroke.Thickness = 1.3
    ThemeStroke.Transparency = 0.35
    ThemeStroke.Color = hexToColor3(preset.Accent)
    ThemeStroke.Parent = ThemeBtn

    ThemeBtn.MouseEnter:Connect(function()
        TweenService:Create(ThemeBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(32, 38, 55)
        }):Play()
    end)
    ThemeBtn.MouseLeave:Connect(function()
        TweenService:Create(ThemeBtn, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(22, 27, 40)
        }):Play()
    end)

    ThemeBtn.MouseButton1Click:Connect(function()
        Config.Accent = preset.Accent
        Config.Accent2 = preset.Accent2
        Config.Theme = preset.Name
        AccentColor = hexToColor3(preset.Accent)
        Accent2Color = hexToColor3(preset.Accent2)
        saveConfig()

        ThemeBtn.Text = "Applied ✓"
        task.delay(1.1, function()
            if ThemeBtn and ThemeBtn.Parent then
                ThemeBtn.Text = preset.Name
            end
        end)
    end)
end

--==================================================
-- FLOATING CIRCLE TOGGLE BUTTON (FIXED / NOT DRAGGABLE)
--==================================================

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "SulasokToggle"
ToggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
ToggleBtn.Size = UDim2.fromOffset(50, 50) -- Fixed Circle Floating Icon
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 32)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0) -- Circle
ToggleCorner.Parent = ToggleBtn

local ToggleAspect = Instance.new("UIAspectRatioConstraint")
ToggleAspect.AspectRatio = 1
ToggleAspect.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Transparency = 0.1
ToggleStroke.Parent = ToggleBtn
newGradient(ToggleStroke, 45)

local ToggleEmoji = Instance.new("TextLabel")
ToggleEmoji.Size = UDim2.fromScale(1, 1)
ToggleEmoji.BackgroundTransparency = 1
ToggleEmoji.Text = "🥴"
ToggleEmoji.Font = Enum.Font.GothamBold
ToggleEmoji.TextSize = 24
ToggleEmoji.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleEmoji.Parent = ToggleBtn

--==================================================
-- FOOTER
--==================================================

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, -4, 0, 36)
Footer.BackgroundTransparency = 1
Footer.LayoutOrder = 99
Footer.Parent = Navigation

local FooterIcon = Instance.new("TextLabel")
FooterIcon.Position = UDim2.fromOffset(8, 4)
FooterIcon.Size = UDim2.fromOffset(20, 26)
FooterIcon.BackgroundTransparency = 1
FooterIcon.Text = "♟"
FooterIcon.Font = Enum.Font.GothamBold
FooterIcon.TextSize = 15
FooterIcon.TextColor3 = AccentColor
FooterIcon.Parent = Footer
newGradient(FooterIcon, 25)

local FooterTitle = Instance.new("TextLabel")
FooterTitle.Position = UDim2.fromOffset(32, 3)
FooterTitle.Size = UDim2.new(1, -36, 0, 14)
FooterTitle.BackgroundTransparency = 1
FooterTitle.Text = "Developer: Kai"
FooterTitle.Font = Enum.Font.GothamMedium
FooterTitle.TextSize = 10
FooterTitle.TextXAlignment = Enum.TextXAlignment.Left
FooterTitle.TextColor3 = Color3.fromRGB(200, 205, 215)
FooterTitle.Parent = Footer

local FooterSub = Instance.new("TextLabel")
FooterSub.Position = UDim2.fromOffset(32, 17)
FooterSub.Size = UDim2.new(1, -36, 0, 13)
FooterSub.BackgroundTransparency = 1
FooterSub.Text = "Better Scripts, Better Fun."
FooterSub.Font = Enum.Font.Gotham
FooterSub.TextSize = 9
FooterSub.TextXAlignment = Enum.TextXAlignment.Left
FooterSub.TextColor3 = Color3.fromRGB(120, 126, 140)
FooterSub.Parent = Footer

--==================================================
-- WINDOW CONTROLS & DRAGGING
--==================================================

local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        TweenService:Create(
            Main,
            TweenInfo.new(0.07),
            {Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )}
        ):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local minimized = false

local function toggleGui()
    minimized = not minimized
    if minimized then
        Main.Visible = false
        ToggleBtn.Visible = true
    else
        Main.Visible = true
        ToggleBtn.Visible = false
    end
end

Minimize.MouseButton1Click:Connect(toggleGui)
ToggleBtn.MouseButton1Click:Connect(toggleGui)

Close.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.22), {
        Size = UDim2.fromOffset(Config.Width, 0),
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.22), {Transparency = 1}):Play()
    task.delay(0.25, function()
        ScreenGui:Destroy()
    end)
end)

--==================================================
-- TOGGLE KEYBIND (RightShift)
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleGui()
    end
end)

--==================================================
-- SHOW GUI
--==================================================

Main.Visible = true
Main.Size = UDim2.fromOffset(Config.Width, 0)
Main.BackgroundTransparency = 1
MainStroke.Transparency = 1

TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(Config.Width, Config.Height),
    BackgroundTransparency = Config.Transparency,
}):Play()
TweenService:Create(MainStroke, TweenInfo.new(0.35), {Transparency = 0.08}):Play()

Pages.Information.Visible = true
CurrentPage = "Information"
NavButtons[navInfo](true)
