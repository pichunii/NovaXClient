-- [[ HỆ THỐNG KEY UI NIGHT HUB STYLE (V9) ]]
-- Tác giả: Nhism
-- Cập nhật: Dynamic Island tương tác, Profile Animation, Fix UI hoàn toàn.

if not getgenv then getgenv = function() return _G end end
if not getgenv().NhismLoadCount then getgenv().NhismLoadCount = 0 end
getgenv().NhismLoadCount = getgenv().NhismLoadCount + 1

if getgenv().NhismLoadCount >= 10 then
    game:GetService("Players").LocalPlayer:Kick("[Nhism Hub] Anti-Cheat: Executor Spam Detected.")
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
local ScreenGuiName = "NhismKeySystem_V9"
local JsonFileName = "Nhism_Config_V9.json"

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
                warn("[Nhism Hub] Executor không hỗ trợ loadstring.")
            end
        end)
        if not success then warn("[Nhism Hub] Lỗi tải script: " .. tostring(err)) end
    else
        print("[Hệ Thống] Chưa cài đặt Link Script cho Mode: " .. Config.Script_Mode)
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
            Player:Kick("[Nhism Hub] Config ID Discord không hợp lệ.")
            return
        end
    else
        Player:Kick("[Nhism Hub] Config Key không hợp lệ.")
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

-- [ HIỆU ỨNG KÍNH LỎNG (BLUR BACKGROUND) ]
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 20
BlurEffect.Parent = Services.Lighting

-- [ KHỞI TẠO UI ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

-- ==========================================
-- [ 1. DYNAMIC ISLAND (TƯƠNG TÁC) ]
-- ==========================================
local DynamicIsland = Instance.new("TextButton")
DynamicIsland.Name = "DynamicIsland"
DynamicIsland.Size = UDim2.new(0, 140, 0, 32)
DynamicIsland.AnchorPoint = Vector2.new(0.5, 0)
DynamicIsland.Position = UDim2.new(0.5, 0, 0, 10)
DynamicIsland.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DynamicIsland.BorderSizePixel = 0
DynamicIsland.AutoButtonColor = false
DynamicIsland.Text = ""
DynamicIsland.Parent = ScreenGui

local DICorner = Instance.new("UICorner")
DICorner.CornerRadius = UDim.new(1, 0)
DICorner.Parent = DynamicIsland

local DIStroke = Instance.new("UIStroke")
DIStroke.Color = Color3.fromRGB(40, 40, 40)
DIStroke.Thickness = 1
DIStroke.Parent = DynamicIsland

local DIIcon = Instance.new("TextLabel")
DIIcon.Size = UDim2.new(0, 30, 1, 0)
DIIcon.Position = UDim2.new(0, 5, 0, 0)
DIIcon.BackgroundTransparency = 1
DIIcon.Text = "🦋" -- Icon con bướm như ảnh
DIIcon.TextColor3 = Color3.fromRGB(0, 255, 128)
DIIcon.Font = Enum.Font.GothamBold
DIIcon.TextSize = 16
DIIcon.Parent = DynamicIsland

local DIExpandedContent = Instance.new("Frame")
DIExpandedContent.Size = UDim2.new(1, -45, 1, 0)
DIExpandedContent.Position = UDim2.new(0, 35, 0, 0)
DIExpandedContent.BackgroundTransparency = 1
DIExpandedContent.ClipsDescendants = true
DIExpandedContent.Parent = DynamicIsland

local DIText = Instance.new("TextLabel")
DIText.Size = UDim2.new(1, 0, 1, 0)
DIText.BackgroundTransparency = 1
DIText.Text = "00:00 | Main"
DIText.TextColor3 = Color3.fromRGB(0, 255, 128)
DIText.Font = Enum.Font.GothamMedium
DIText.TextSize = 13
DIText.TextXAlignment = Enum.TextXAlignment.Right
DIText.Parent = DIExpandedContent

local DIExpanded = false
DynamicIsland.MouseButton1Click:Connect(function()
    DIExpanded = not DIExpanded
    if DIExpanded then
        Services.TweenService:Create(DynamicIsland, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 60)}):Play()
        Services.TweenService:Create(DICorner, TweenInfo.new(0.4), {CornerRadius = UDim.new(0, 20)}):Play()
        DIText.Text = "Session Active\nClick to close"
        DIText.TextXAlignment = Enum.TextXAlignment.Center
        DIText.Position = UDim2.new(0, 0, 0, 5)
        DIText.Size = UDim2.new(1, 0, 1, -10)
    else
        Services.TweenService:Create(DynamicIsland, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 140, 0, 32)}):Play()
        Services.TweenService:Create(DICorner, TweenInfo.new(0.4), {CornerRadius = UDim.new(1, 0)}):Play()
        DIText.Text = string.format("%02d:%02d | %s", math.floor((tick() % 3600) / 60), math.floor(tick() % 60), Config.Script_Mode)
        DIText.TextXAlignment = Enum.TextXAlignment.Right
        DIText.Position = UDim2.new(0, 0, 0, 0)
        DIText.Size = UDim2.new(1, 0, 1, 0)
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
-- [ 2. MAIN WINDOW (NIGHT HUB STYLE) ]
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22) -- Dark theme
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

-- Viền kính mờ (Liquid Glass)
local GlassStroke = Instance.new("UIStroke")
GlassStroke.Color = Color3.fromRGB(255, 255, 255)
GlassStroke.Transparency = 0.85
GlassStroke.Thickness = 1.5
GlassStroke.Parent = MainFrame

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = IsMobile and 0.7 or 1

-- Title Bar (MacOS dots)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

for i, color in ipairs({Color3.fromRGB(255, 95, 86), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)}) do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 15 + ((i-1) * 20), 0.5, -6)
    dot.BackgroundColor3 = color
    dot.Parent = TitleBar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot
end

-- Kéo thả
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
-- [ 3. SIDEBAR & PROFILE ANIMATION ]
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 200, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Sidebar.BackgroundTransparency = 0.5
Sidebar.Parent = MainFrame
local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- Mini Profile (Click để mở rộng)
local ProfileContainer = Instance.new("Frame")
ProfileContainer.Size = UDim2.new(1, -20, 0, 60)
ProfileContainer.Position = UDim2.new(0, 10, 0, 10)
ProfileContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ProfileContainer.BackgroundTransparency = 0.3
ProfileContainer.Parent = Sidebar
local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 10)
ProfileCorner.Parent = ProfileContainer

local MiniAvatar = Instance.new("ImageLabel")
MiniAvatar.Size = UDim2.new(0, 40, 0, 40)
MiniAvatar.Position = UDim2.new(0, 10, 0.5, -20)
MiniAvatar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
MiniAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
MiniAvatar.Parent = ProfileContainer
local MiniAvaCorner = Instance.new("UICorner")
MiniAvaCorner.CornerRadius = UDim.new(1, 0)
MiniAvaCorner.Parent = MiniAvatar

local MiniName = Instance.new("TextLabel")
MiniName.Size = UDim2.new(1, -60, 0, 20)
MiniName.Position = UDim2.new(0, 60, 0.5, -10)
MiniName.BackgroundTransparency = 1
MiniName.Text = Player.DisplayName
MiniName.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniName.Font = Enum.Font.GothamBold
MiniName.TextSize = 14
MiniName.TextXAlignment = Enum.TextXAlignment.Left
MiniName.Parent = ProfileContainer

local MiniStatus = Instance.new("TextLabel")
MiniStatus.Size = UDim2.new(1, -60, 0, 15)
MiniStatus.Position = UDim2.new(0, 60, 0.5, 8)
MiniStatus.BackgroundTransparency = 1
MiniStatus.Text = "Pro - Lifetime"
MiniStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
MiniStatus.Font = Enum.Font.GothamMedium
MiniStatus.TextSize = 11
MiniStatus.TextXAlignment = Enum.TextXAlignment.Left
MiniStatus.Parent = ProfileContainer

-- Expanded Profile (Ẩn ban đầu)
local ExpandedProfile = Instance.new("Frame")
ExpandedProfile.Size = UDim2.new(1, 0, 0, 0)
ExpandedProfile.Position = UDim2.new(0, 0, 0, 0)
ExpandedProfile.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
ExpandedProfile.BackgroundTransparency = 0.05
ExpandedProfile.ClipsDescendants = true
ExpandedProfile.Visible = false
ExpandedProfile.ZIndex = 5
ExpandedProfile.Parent = Sidebar
local ExpCorner = Instance.new("UICorner")
ExpCorner.CornerRadius = UDim.new(0, 12)
ExpCorner.Parent = ExpandedProfile

local BigAvatar = Instance.new("ImageLabel")
BigAvatar.Size = UDim2.new(0, 80, 0, 80)
BigAvatar.Position = UDim2.new(0.5, -40, 0, 20)
BigAvatar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
BigAvatar.Image = "rbxthumb://type=AvatarBust&id=" .. Player.UserId .. "&w=150&h=150"
BigAvatar.Parent = ExpandedProfile
local BigAvaCorner = Instance.new("UICorner")
BigAvaCorner.CornerRadius = UDim.new(1, 0)
BigAvaCorner.Parent = BigAvatar

local BigName = Instance.new("TextLabel")
BigName.Size = UDim2.new(1, 0, 0, 25)
BigName.Position = UDim2.new(0, 0, 0, 110)
BigName.BackgroundTransparency = 1
BigName.Text = Player.DisplayName
BigName.TextColor3 = Color3.fromRGB(255, 255, 255)
BigName.Font = Enum.Font.GothamBold
BigName.TextSize = 18
BigName.Parent = ExpandedProfile

local BigId = Instance.new("TextLabel")
BigId.Size = UDim2.new(1, 0, 0, 20)
BigId.Position = UDim2.new(0, 0, 0, 135)
BigId.BackgroundTransparency = 1
BigId.Text = "@" .. Player.Name
BigId.TextColor3 = Color3.fromRGB(150, 150, 150)
BigId.Font = Enum.Font.GothamMedium
BigId.TextSize = 13
BigId.Parent = ExpandedProfile

local InfoBox = Instance.new("Frame")
InfoBox.Size = UDim2.new(1, -20, 0, 100)
InfoBox.Position = UDim2.new(0, 10, 0, 170)
InfoBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
InfoBox.Parent = ExpandedProfile
local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoBox

local function CreateInfoRow(text, yPos, value)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = InfoBox

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -20, 0, 20)
    val.Position = UDim2.new(0, 10, 0, yPos + 12)
    val.BackgroundTransparency = 1
    val.Text = value
    val.TextColor3 = Color3.fromRGB(255, 255, 255)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.Parent = InfoBox
end

CreateInfoRow("MEMBER SINCE", 10, os.date("%b %d, %Y"))
CreateInfoRow("ROBLOX ACCOUNT", 50, Player.Name)

ProfileContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ExpandedProfile.Visible = true
        ExpandedProfile.Size = UDim2.new(1, 0, 0, 0)
        Services.TweenService:Create(ExpandedProfile, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    end
end)

ExpandedProfile.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local tween = Services.TweenService:Create(ExpandedProfile, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            ExpandedProfile.Visible = false
        end)
    end
end)

-- Tab Buttons
local function CreateTabButton(name, text, yPos, icon)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = Sidebar
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    return btn
end

local KeyTabBtn = CreateTabButton("KeyTabBtn", "Key System", 90)
local InfoTabBtn = CreateTabButton("InfoTabBtn", "Information", 135)

-- ==========================================
-- [ 4. CONTENT AREA (KEY PAGE) ]
-- ==========================================
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -220, 1, -50)
ContentContainer.Position = UDim2.new(0, 210, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local KeyPage = Instance.new("Frame")
KeyPage.Size = UDim2.new(1, 0, 1, 0)
KeyPage.BackgroundTransparency = 1
KeyPage.Parent = ContentContainer

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Authentication"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = KeyPage

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Enter your key to proceed."
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = KeyPage

-- Input (Glassmorphism)
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -20, 0, 45)
InputFrame.Position = UDim2.new(0, 0, 0, 70)
InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InputFrame.BackgroundTransparency = 0.9
InputFrame.Parent = KeyPage
local InCorner = Instance.new("UICorner")
InCorner.CornerRadius = UDim.new(0, 10)
InCorner.Parent = InputFrame
local InStroke = Instance.new("UIStroke")
InStroke.Color = Color3.fromRGB(255, 255, 255)
InStroke.Transparency = 0.8
InStroke.Parent = InputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -100, 1, 0)
KeyInput.Position = UDim2.new(0, 15, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = SavedKey
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.Font = Enum.Font.GothamBold
KeyInput.TextSize = 14
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.Parent = InputFrame

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 70, 1, -10)
PasteBtn.Position = UDim2.new(1, -75, 0, 5)
PasteBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 12
PasteBtn.Parent = InputFrame
local PasteCorner = Instance.new("UICorner")
PasteCorner.CornerRadius = UDim.new(0, 8)
PasteCorner.Parent = PasteBtn

PasteBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        local success, clip = pcall(getclipboard)
        if success and clip then KeyInput.Text = clip end
    end
end)

-- Nút bấm (Sắp xếp 2x2)
local function CreateButton(text, pos, color, textColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -8, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.1
    btn.Text = text
    btn.TextColor3 = textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = KeyPage
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.8
    s.Parent = btn
    return btn
end

local GetKeyBtn = CreateButton("Get Key", UDim2.new(0, 0, 0, 140), Color3.fromRGB(0, 122, 255), Color3.fromRGB(255, 255, 255))
local SubmitBtn = CreateButton("Submit", UDim2.new(0.5, 8, 0, 140), Color3.fromRGB(52, 199, 89), Color3.fromRGB(255, 255, 255))
local DiscordBtn = CreateButton("Discord", UDim2.new(0, 0, 0, 195), Color3.fromRGB(88, 101, 242), Color3.fromRGB(255, 255, 255))
local WebsiteBtn = CreateButton("Website", UDim2.new(0.5, 8, 0, 195), Color3.fromRGB(40, 40, 40), Color3.fromRGB(255, 255, 255))

-- ==========================================
-- [ 5. TAB ANIMATION SWITCH ]
-- ==========================================
local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.Parent = ContentContainer

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, 0, 0, 30)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "System Info"
InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoTitle.Font = Enum.Font.GothamBlack
InfoTitle.TextSize = 24
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = InfoPage

local InfTxt = Instance.new("TextLabel")
InfTxt.Size = UDim2.new(1, 0, 1, -30)
InfTxt.Position = UDim2.new(0, 0, 0, 40)
InfTxt.BackgroundTransparency = 1
InfTxt.Text = string.format([[
    Time: %s
    Mode: %s
    Version: 9.0.0 (Night Hub UI)
    
    Developer: Nhism
    Status: Undetected
]], os.date("%H:%M:%S - %d/%m/%Y"), Config.Script_Mode)
InfTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
InfTxt.Font = Enum.Font.GothamMedium
InfTxt.TextSize = 14
InfTxt.TextXAlignment = Enum.TextXAlignment.Left
InfTxt.TextYAlignment = Enum.TextYAlignment.Top
InfTxt.Parent = InfoPage

local function SwitchTab(showPage, hidePage, activeBtn, inactiveBtn)
    hidePage.Visible = false
    showPage.Visible = true
    showPage.Position = UDim2.new(0, 15, 0, 0)
    Services.TweenService:Create(showPage, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    Services.TweenService:Create(activeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    Services.TweenService:Create(inactiveBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
end

KeyTabBtn.MouseButton1Click:Connect(function() SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn) end)
InfoTabBtn.MouseButton1Click:Connect(function() SwitchTab(InfoPage, KeyPage, InfoTabBtn, KeyTabBtn) end)

-- ==========================================
-- [ 6. IOS NOTIFICATION ]
-- ==========================================
local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 70)
    Notif.AnchorPoint = Vector2.new(0.5, 0)
    Notif.Position = UDim2.new(0.5, 0, 0, -120)
    Notif.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    Notif.BackgroundTransparency = 0.05
    Notif.Parent = ScreenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 35)
    c.Parent = Notif
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.8
    s.Thickness = 1
    s.Parent = Notif
    
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
    NText.TextColor3 = Color3.fromRGB(200, 200, 200)
    NText.Font = Enum.Font.GothamMedium
    NText.TextSize = 13
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = Notif

    Services.TweenService:Create(Notif, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 20)}):Play()
    task.delay(3, function()
        local out = Services.TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -120)})
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
        
        BlurEffect:Destroy()
        ScreenGui:Destroy()
        ExecuteGameScript(isPremium)
    else
        ShowNotification("Failed", "Invalid key.", false)
        KeyInput.Text = ""
        task.wait(1)
        Player:Kick("[Nhism Hub] Invalid Key Attempt.")
    end
end)

SwitchTab(KeyPage, InfoPage, KeyTabBtn, InfoTabBtn)