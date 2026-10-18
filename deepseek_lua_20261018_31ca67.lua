-- [[ NOVAX HUB V19 - MACOS LIGHTNING PUNK ]]
-- Tác giả: Nhism
-- Cập nhật: Giao diện Sáng (Light), Viền Neon Rainbow, Khắc phục lỗi không bấm được.

if not getgenv then getgenv = function() return _G end end
if not getgenv().NhismLoadCount then getgenv().NhismLoadCount = 0 end
getgenv().NhismLoadCount = getgenv().NhismLoadCount + 1

if getgenv().NhismLoadCount >= 15 then
    game:GetService("Players").LocalPlayer:Kick("[NovaX Hub] Anti-Cheat: Executor Spam Detected.")
    return
end

if not game:IsLoaded() then game.Loaded:Wait() end

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting")
}

local Player = Services.Players.LocalPlayer
local IsMobile = Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled
local ScreenGuiName = "NovaX_LightningPunk_V19"
local JsonFileName = "NovaX_Config_V19.json"

-- [ CẤU HÌNH TỪ BÊN NGOÀI ]
local Config = {
    Key = getgenv().Key or "",
    ID = getgenv().id or "Unknown_ID",
    Script_Mode = getgenv().Script_Mode or "Main"
}

local AllowedIDs = { ["153601438942"] = true, ["129198757199"] = true }
local FreeKeys = {"NHISM-FREE-111", "NHISM-FREE-222"}
local PremiumKeys = {"NHISM-PREMIUM-999", "NHISM-PREMIUM-888"}

-- [ HÀM CHẠY SCRIPT CHÍNH ]
local function ExecuteGameScript(isPremium)
    local ScriptURLs = {
        Main = "https://raw.githubusercontent.com/yourname/yourrepo/main/main.lua",
        Kaitun = "https://raw.githubusercontent.com/yourname/yourrepo/main/kaitun.lua",
        Aimbot = "https://raw.githubusercontent.com/pichunii/NovaXClient/refs/heads/main/Aimbot.lua",
        Fixlag = "https://raw.githubusercontent.com/pichunii/NovaXClient/refs/heads/main/Fixlag.luau"
    }
    
    local TargetURL = ScriptURLs[Config.Script_Mode] or ScriptURLs["Main"]

    if TargetURL ~= "" and TargetURL:find("http") then
        local success, err = pcall(function()
            if type(loadstring) == "function" then
                loadstring(game:HttpGet(TargetURL))()
            else
                warn("[NovaX Hub] Executor does not support loadstring.")
            end
        end)
        if not success then warn("[NovaX Hub] Script load error: " .. tostring(err)) end
    end
end

-- [ KIỂM TRA CONFIG TỰ ĐỘNG ]
if Config.Key ~= "" then
    local isValid = false
    for _, k in ipairs(FreeKeys) do if Config.Key == k then isValid = true break end end
    if not isValid then for _, k in ipairs(PremiumKeys) do if Config.Key == k then isValid = true break end end end

    if isValid then
        if AllowedIDs[Config.ID] or Config.ID == "Unknown_ID" then
            ExecuteGameScript(Config.Key:find("PREM") ~= nil)
            return
        else
            Player:Kick("[NovaX Hub] Invalid Config ID.")
            return
        end
    else
        Player:Kick("[NovaX Hub] Invalid Config Key.")
        return
    end
end

-- [ HÀM HỖ TRỢ FILE JSON AN TOÀN ]
local function SafeReadFile(fileName)
    if isfile and readfile then
        local success, result = pcall(function()
            if isfile(fileName) then return readfile(fileName) end
        end)
        if success and result then return result end
    end
    return nil
end

local function SafeWriteFile(fileName, content)
    if writefile then pcall(function() writefile(fileName, content) end) end
end

local SavedKey = ""
local fileData = SafeReadFile(JsonFileName)
if fileData then
    local success, result = pcall(function() return Services.HttpService:JSONDecode(fileData) end)
    if success and result and result.Key then SavedKey = result.Key end
end

-- [ XÁC ĐỊNH PARENT CHO UI ]
local ParentGui = Services.CoreGui
if gethui then
    local success, hui = pcall(gethui)
    if success and hui then ParentGui = hui end
elseif Player:FindFirstChild("PlayerGui") then
    ParentGui = Player.PlayerGui
end

if ParentGui:FindFirstChild(ScreenGuiName) then
    ParentGui:FindFirstChild(ScreenGuiName):Destroy()
end

-- [ KHỞI TẠO UI CHÍNH ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true 
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = ParentGui

-- HÀM TẠO HIỆU ỨNG MACOS LIGHTNING PUNK
local function ApplyPunkStyle(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = element
    
    -- Viền Rainbow phát sáng
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = element
    
    local rainbowGradient = Instance.new("UIGradient")
    rainbowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),   -- Hồng
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(128, 0, 255)), -- Tím
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 128, 255)),  -- Xanh dương
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 255, 128)), -- Xanh lá
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 0))     -- Vàng
    }
    rainbowGradient.Parent = stroke
end

-- HÀM TẠO HIỆU ỨNG HOVER VÀ CLICK
local function AddButtonEffects(btn, defaultColor, hoverColor)
    btn.MouseEnter:Connect(function()
        if not IsMobile then
            Services.TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor or defaultColor, BackgroundTransparency = 0.05}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not IsMobile then
            Services.TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor, BackgroundTransparency = 0.2}):Play()
        end
    end)
    btn.MouseButton1Down:Connect(function()
        Services.TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(btn.Size.X.Scale * 0.95, btn.Size.X.Offset, btn.Size.Y.Scale * 0.95, btn.Size.Y.Offset)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        Services.TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = btn.Size}):Play()
    end)
end

-- ==========================================
-- [ 1. DYNAMIC ISLAND (TỐI GIỮ NGUYÊN BẢN) ]
-- ==========================================
local DynamicIsland = Instance.new("TextButton")
DynamicIsland.Name = "DynamicIsland"
DynamicIsland.Size = UDim2.new(0, 130, 0, 35)
DynamicIsland.AnchorPoint = Vector2.new(0.5, 0)
DynamicIsland.Position = UDim2.new(0.5, 0, 0, 10)
DynamicIsland.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DynamicIsland.BackgroundTransparency = 0.05
DynamicIsland.BorderSizePixel = 0
DynamicIsland.AutoButtonColor = false
DynamicIsland.Text = ""
DynamicIsland.ZIndex = 1000
DynamicIsland.Parent = ScreenGui

local DICorner = Instance.new("UICorner")
DICorner.CornerRadius = UDim.new(1, 0)
DICorner.Parent = DynamicIsland

local DIStroke = Instance.new("UIStroke")
DIStroke.Color = Color3.fromRGB(80, 80, 80)
DIStroke.Thickness = 1
DIStroke.Parent = DynamicIsland

local DIText = Instance.new("TextLabel")
DIText.Size = UDim2.new(1, -20, 1, 0)
DIText.Position = UDim2.new(0, 10, 0, 0)
DIText.BackgroundTransparency = 1
DIText.Text = "00:00 | Main"
DIText.TextColor3 = Color3.fromRGB(0, 255, 128)
DIText.Font = Enum.Font.GothamMedium
DIText.TextSize = 13
DIText.TextXAlignment = Enum.TextXAlignment.Center
DIText.Parent = DynamicIsland

local DIExpanded = false
local DI_Tween = nil
DynamicIsland.MouseButton1Click:Connect(function()
    DIExpanded = not DIExpanded
    if DI_Tween then DI_Tween:Cancel() end
    if DIExpanded then
        DI_Tween = Services.TweenService:Create(DynamicIsland, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 220, 0, 65)})
        DI_Tween:Play()
        Services.TweenService:Create(DICorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(0, 20)}):Play()
        DIText.Text = "Session Active\nClick to close"
    else
        DI_Tween = Services.TweenService:Create(DynamicIsland, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 130, 0, 35)})
        DI_Tween:Play()
        Services.TweenService:Create(DICorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(1, 0)}):Play()
        DIText.Text = "00:00 | Main"
    end
end)

local StartTime = tick()
task.spawn(function()
    while ScreenGui.Parent do
        if not DIExpanded then
            local elapsed = math.floor(tick() - StartTime)
            local mins = string.format("%02d", math.floor(elapsed / 60))
            local secs = string.format("%02d", elapsed % 60)
            DIText.Text = string.format("%s:%s | %s", mins, secs, Config.Script_Mode)
        end
        task.wait(1)
    end
end)

-- ==========================================
-- [ 2. MAIN WINDOW (MACOS LIGHT) ]
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(250, 250, 255) -- Nền sáng
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
ApplyPunkStyle(MainFrame, 16)

Services.TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 680, 0, 460)}):Play()

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = IsMobile and 0.7 or 1

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

-- MacOS Dots
for i, color in ipairs({Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 20 + ((i-1) * 20), 0.5, -6)
    dot.BackgroundColor3 = color
    dot.Parent = TitleBar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot
end

-- Tiêu đề Hub (Rainbow Text)
local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, -200, 0, 30)
HubTitle.Position = UDim2.new(0, 95, 0.5, -15)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "NovaX Hub | Lightning Punk"
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 16
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 128)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 128, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))
}
TitleGradient.Parent = HubTitle

-- Nút Profile
local ProfileBtn = Instance.new("TextButton")
ProfileBtn.Size = UDim2.new(0, 32, 0, 32)
ProfileBtn.Position = UDim2.new(1, -45, 0.5, -16)
ProfileBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProfileBtn.BackgroundTransparency = 0.2
ProfileBtn.Text = ""
ProfileBtn.Parent = TitleBar
ApplyPunkStyle(ProfileBtn, 16)
AddButtonEffects(ProfileBtn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))

local ProfileImg = Instance.new("ImageLabel")
ProfileImg.Size = UDim2.new(1, -4, 1, -4)
ProfileImg.Position = UDim2.new(0, 2, 0, 2)
ProfileImg.BackgroundTransparency = 1
ProfileImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
ProfileImg.Parent = ProfileBtn
local PImgCorner = Instance.new("UICorner")
PImgCorner.CornerRadius = UDim.new(1, 0)
PImgCorner.Parent = ProfileImg

-- Drag Logic
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
Services.UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- [ 3. SIDEBAR (TABS) ]
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -70)
Sidebar.Position = UDim2.new(0, 15, 0, 55)
Sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Sidebar.BackgroundTransparency = 0.5
Sidebar.Parent = MainFrame
ApplyPunkStyle(Sidebar, 12)

local currentTab = ""
local activeTween

local function SwitchTab(tabName, btn)
    if currentTab == tabName then return end
    if activeTween then activeTween:Cancel() end
    
    local oldPage, newPage
    if tabName == "Key" then oldPage, newPage = InfoPage, KeyPage
    else oldPage, newPage = KeyPage, InfoPage end
    
    newPage.Visible = true
    newPage.Position = UDim2.new(0, 30, 0, 0)
    
    activeTween = Services.TweenService:Create(newPage, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
    activeTween:Play()
    
    oldPage.Visible = false
    currentTab = tabName
    
    for _, child in ipairs(Sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            if child == btn then
                Services.TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
            else
                Services.TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
            end
        end
    end
end

local function CreateTabButton(name, text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(100, 100, 100)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    ApplyPunkStyle(btn, 8)
    AddButtonEffects(btn, Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
    return btn
end

local KeyTabBtn = CreateTabButton("KeyTabBtn", "Key System", 10)
local InfoTabBtn = CreateTabButton("InfoTabBtn", "Information", 60)

KeyTabBtn.MouseButton1Click:Connect(function() SwitchTab("Key", KeyTabBtn) end)
InfoTabBtn.MouseButton1Click:Connect(function() SwitchTab("Info", InfoTabBtn) end)

-- ==========================================
-- [ 4. CONTENT AREA ]
-- ==========================================
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -220, 1, -70)
ContentContainer.Position = UDim2.new(0, 210, 0, 55)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local KeyPage = Instance.new("Frame")
KeyPage.Size = UDim2.new(1, 0, 1, 0)
KeyPage.BackgroundTransparency = 1
KeyPage.Parent = ContentContainer

-- Tiêu đề trang Key
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Authentication"
Title.TextColor3 = Color3.fromRGB(0, 0, 0) -- Chữ đen
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 26
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = KeyPage

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 35)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Enter your key to proceed."
Subtitle.TextColor3 = Color3.fromRGB(80, 80, 80)
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 13
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = KeyPage

-- Input Frame
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -20, 0, 45)
InputFrame.Position = UDim2.new(0, 0, 0, 70)
InputFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
InputFrame.BackgroundTransparency = 0.1
InputFrame.Parent = KeyPage
ApplyPunkStyle(InputFrame, 12)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -100, 1, 0)
KeyInput.Position = UDim2.new(0, 15, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = SavedKey
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.TextColor3 = Color3.fromRGB(0, 0, 0) -- Chữ đen
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.Font = Enum.Font.GothamBold
KeyInput.TextSize = 14
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.Parent = InputFrame

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 80, 1, -10)
PasteBtn.Position = UDim2.new(1, -85, 0, 5)
PasteBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
PasteBtn.BackgroundTransparency = 0.1
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 12
PasteBtn.Parent = InputFrame
ApplyPunkStyle(PasteBtn, 8)
AddButtonEffects(PasteBtn, Color3.fromRGB(200, 200, 210), Color3.fromRGB(180, 180, 190))

PasteBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        local success, clip = pcall(getclipboard)
        if success and clip then KeyInput.Text = clip end
    end
end)

-- Buttons (Light Theme)
local function CreateButton(text, pos, color, textColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -8, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.1
    btn.Text = text
    btn.TextColor3 = textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = KeyPage
    ApplyPunkStyle(btn, 12)
    AddButtonEffects(btn, color, color:Lerp(Color3.fromRGB(255,255,255), 0.2))
    return btn
end

local GetKeyBtn = CreateButton("Get Key", UDim2.new(0, 0, 0, 130), Color3.fromRGB(0, 122, 255), Color3.fromRGB(255, 255, 255))
local SubmitBtn = CreateButton("Submit", UDim2.new(0.5, 8, 0, 130), Color3.fromRGB(52, 199, 89), Color3.fromRGB(255, 255, 255))
local DiscordBtn = CreateButton("Discord", UDim2.new(0, 0, 0, 190), Color3.fromRGB(88, 101, 242), Color3.fromRGB(255, 255, 255))
local WebsiteBtn = CreateButton("Website", UDim2.new(0.5, 8, 0, 190), Color3.fromRGB(60, 60, 70), Color3.fromRGB(255, 255, 255))

-- Info Page
local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.Parent = ContentContainer

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, 0, 0, 30)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "Information"
InfoTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextSize = 24
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = InfoPage

local InfTxt = Instance.new("TextLabel")
InfTxt.Size = UDim2.new(1, 0, 1, -30)
InfTxt.Position = UDim2.new(0, 0, 0, 40)
InfTxt.BackgroundTransparency = 1
InfTxt.Text = string.format("Time: %s\nMode: %s\nVersion: 19.0.0\n\nDeveloper: Nhism", os.date("%H:%M:%S - %d/%m/%Y"), Config.Script_Mode)
InfTxt.TextColor3 = Color3.fromRGB(50, 50, 50)
InfTxt.Font = Enum.Font.GothamMedium
InfTxt.TextSize = 14
InfTxt.TextXAlignment = Enum.TextXAlignment.Left
InfTxt.TextYAlignment = Enum.TextYAlignment.Top
InfTxt.Parent = InfoPage

SwitchTab("Key", KeyTabBtn)

-- ==========================================
-- [ 5. PROFILE MODAL ]
-- ==========================================
local ProfileModal = Instance.new("Frame")
ProfileModal.Size = UDim2.new(0, 0, 0, 0)
ProfileModal.AnchorPoint = Vector2.new(0.5, 0.5)
ProfileModal.Position = UDim2.new(0.5, 0, 0.5, 0)
ProfileModal.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
ProfileModal.BackgroundTransparency = 0.05
ProfileModal.Visible = false
ProfileModal.ZIndex = 200
ProfileModal.Parent = ScreenGui
ApplyPunkStyle(ProfileModal, 24)

local CloseModalBtn = Instance.new("TextButton")
CloseModalBtn.Size = UDim2.new(0, 30, 0, 30)
CloseModalBtn.Position = UDim2.new(1, -40, 0, 10)
CloseModalBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 86)
CloseModalBtn.Text = "X"
CloseModalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseModalBtn.Font = Enum.Font.GothamBold
CloseModalBtn.Parent = ProfileModal
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseModalBtn
AddButtonEffects(CloseModalBtn, Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 120, 110))

local BigAvatar = Instance.new("ImageLabel")
BigAvatar.Size = UDim2.new(0, 100, 0, 100)
BigAvatar.Position = UDim2.new(0.5, -50, 0, 30)
BigAvatar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
BigAvatar.Image = "rbxthumb://type=AvatarBust&id=" .. Player.UserId .. "&w=150&h=150"
BigAvatar.Parent = ProfileModal
local BigAvaCorner = Instance.new("UICorner")
BigAvaCorner.CornerRadius = UDim.new(1, 0)
BigAvaCorner.Parent = BigAvatar

local BigName = Instance.new("TextLabel")
BigName.Size = UDim2.new(1, 0, 0, 30)
BigName.Position = UDim2.new(0, 0, 0, 140)
BigName.BackgroundTransparency = 1
BigName.Text = Player.DisplayName
BigName.TextColor3 = Color3.fromRGB(0, 0, 0)
BigName.Font = Enum.Font.GothamBold
BigName.TextSize = 22
BigName.Parent = ProfileModal

local BigId = Instance.new("TextLabel")
BigId.Size = UDim2.new(1, 0, 0, 20)
BigId.Position = UDim2.new(0, 0, 0, 170)
BigId.BackgroundTransparency = 1
BigId.Text = "@" .. Player.Name
BigId.TextColor3 = Color3.fromRGB(100, 100, 100)
BigId.Font = Enum.Font.GothamMedium
BigId.TextSize = 14
BigId.Parent = ProfileModal

local InfoBox = Instance.new("Frame")
InfoBox.Size = UDim2.new(1, -40, 0, 100)
InfoBox.Position = UDim2.new(0, 20, 0, 210)
InfoBox.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
InfoBox.BackgroundTransparency = 0.3
InfoBox.Parent = ProfileModal
ApplyPunkStyle(InfoBox, 12)

local function CreateInfoRow(text, yPos, value)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(100, 100, 100)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = InfoBox

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -20, 0, 20)
    val.Position = UDim2.new(0, 10, 0, yPos + 12)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextColor3 = Color3.fromRGB(0, 0, 0)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.Parent = InfoBox
end

CreateInfoRow("MEMBER SINCE", 10, os.date("%b %d, %Y"))
CreateInfoRow("ROBLOX ACCOUNT", 50, Player.Name)

ProfileBtn.MouseButton1Click:Connect(function()
    ProfileModal.Visible = true
    ProfileModal.Size = UDim2.new(0, 0, 0, 0)
    Services.TweenService:Create(ProfileModal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 350)}):Play()
end)

CloseModalBtn.MouseButton1Click:Connect(function()
    local tween = Services.TweenService:Create(ProfileModal, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        ProfileModal.Visible = false
    end)
end)

-- ==========================================
-- [ 6. NOTIFICATION SYSTEM ]
-- ==========================================
local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 70)
    Notif.AnchorPoint = Vector2.new(0.5, 0)
    Notif.Position = UDim2.new(0.5, 0, 0, -120)
    Notif.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
    Notif.BackgroundTransparency = 0.05
    Notif.ZIndex = 300
    Notif.Parent = ScreenGui
    ApplyPunkStyle(Notif, 35)
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -60, 0, 25)
    NTitle.Position = UDim2.new(0, 20, 0, 15)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = isSuccess and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 59, 48)
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 15
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = Notif
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -60, 0, 25)
    NText.Position = UDim2.new(0, 20, 0, 35)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(80, 80, 80)
    NText.Font = Enum.Font.GothamMedium
    NText.TextSize = 13
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notif

    Services.TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 20)}):Play()
    task.delay(3, function()
        local out = Services.TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -120)})
        out:Play()
        out.Completed:Wait()
        Notif:Destroy()
    end)
end

-- ==========================================
-- [ 7. BUTTON LOGIC ]
-- ==========================================
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard("https://link-to-your-key-system.com") end) end
    ShowNotification("Copied", "Key link copied.", true)
end)

DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard("https://discord.gg/nhism") end) end
    ShowNotification("Copied", "Discord link copied.", true)
end)

WebsiteBtn.MouseButton1Click:Connect(function()
    if setclipboard then pcall(function() setclipboard("https://nhism.com") end) end
    ShowNotification("Copied", "Website link copied.", true)
end)

SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    local isPremium = false
    local isValid = false
    
    for _, k in ipairs(FreeKeys) do if enteredKey == k then isValid = true; isPremium = false; break end end
    if not isValid then for _, k in ipairs(PremiumKeys) do if enteredKey == k then isValid = true; isPremium = true; break end end end

    if isValid then
        local jsonData = Services.HttpService:JSONEncode({Key = enteredKey})
        SafeWriteFile(JsonFileName, jsonData)
        
        ShowNotification("Authenticated", "Key is valid. Loading...", true)
        task.wait(1)
        
        local closeTween = Services.TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 1.5, 0)})
        closeTween:Play()
        closeTween.Completed:Wait()
        
        ScreenGui:Destroy()
        ExecuteGameScript(isPremium)
    else
        ShowNotification("Failed", "Invalid key.", false)
        KeyInput.Text = ""
        task.wait(1)
        Player:Kick("[NovaX Hub] Invalid Key Attempt.")
    end
end)