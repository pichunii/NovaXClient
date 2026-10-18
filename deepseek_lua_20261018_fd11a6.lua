-- [[ NOVAX HUB V13 - ORIGINOS DOCK & LIQUID GLASS ]]
-- Tác giả: Nhism
-- Sửa lỗi: Chống spam crash Tab, Bố cục lại OriginOS, Tăng cường hiệu ứng Liquid Glass.

if not getgenv then getgenv = function() return _G end end
if not getgenv().NhismLoadCount then getgenv().NhismLoadCount = 0 end
getgenv().NhismLoadCount = getgenv().NhismLoadCount + 1

if getgenv().NhismLoadCount >= 10 then
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
local ScreenGuiName = "NovaX_OriginOS_V13"
local JsonFileName = "NovaX_Config_V13.json"

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
                warn("[NovaX Hub] Executor không hỗ trợ loadstring.")
            end
        end)
        if not success then warn("[NovaX Hub] Lỗi tải script: " .. tostring(err)) end
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
            Player:Kick("[NovaX Hub] Config ID Discord không hợp lệ.")
            return
        end
    else
        Player:Kick("[NovaX Hub] Config Key không hợp lệ.")
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

-- [ HIỆU ỨNG NỀN ]
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 20
BlurEffect.Parent = Services.Lighting

-- ==========================================
-- [ KHỞI TẠO UI CHÍNH ]
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true 
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = ParentGui

-- HÀM TẠO HIỆU ỨNG LIQUID GLASS PREMIUM
local function ApplyGlass(element, radius, transparency, hasShadow)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 16)
    corner.Parent = element
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = transparency or 0.7
    stroke.Thickness = 1.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = element
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 248, 255))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0.95)
    }
    gradient.Rotation = 45
    gradient.Parent = element
    
    if hasShadow then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.Image = "rbxassetid://1316045217"
        shadow.ImageColor3 = Color3.new(0,0,0)
        shadow.ImageTransparency = 0.65
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(10, 10, 118, 118)
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.BackgroundTransparency = 1
        shadow.ZIndex = -1
        shadow.Parent = element
    end
end

-- Nút bấm phản hồi (Nhấn xuống nhỏ lại)
local function AddPressEffect(button)
    local originalSize = button.Size
    button.MouseButton1Down:Connect(function()
        Services.TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(originalSize.X.Scale * 0.95, originalSize.X.Offset, originalSize.Y.Scale * 0.95, originalSize.Y.Offset)}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        Services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize}):Play()
    end)
    button.MouseLeave:Connect(function()
        Services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize}):Play()
    end)
end

-- ==========================================
-- [ 1. DYNAMIC ISLAND ]
-- ==========================================
local DynamicIsland = Instance.new("TextButton")
DynamicIsland.Name = "DynamicIsland"
DynamicIsland.Size = UDim2.new(0, 140, 0, 35)
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
DIStroke.Color = Color3.fromRGB(60, 60, 60)
DIStroke.Thickness = 1
DIStroke.Parent = DynamicIsland

local DIIcon = Instance.new("TextLabel")
DIIcon.Size = UDim2.new(0, 30, 1, 0)
DIIcon.Position = UDim2.new(0, 5, 0, 0)
DIIcon.BackgroundTransparency = 1
DIIcon.Text = "🦋"
DIIcon.TextColor3 = Color3.fromRGB(0, 255, 128)
DIIcon.Font = Enum.Font.GothamBold
DIIcon.TextSize = 16
DIIcon.Parent = DynamicIsland

local DIText = Instance.new("TextLabel")
DIText.Size = UDim2.new(1, -40, 1, 0)
DIText.Position = UDim2.new(0, 35, 0, 0)
DIText.BackgroundTransparency = 1
DIText.Text = "00:00 | Main"
DIText.TextColor3 = Color3.fromRGB(0, 255, 128)
DIText.Font = Enum.Font.GothamMedium
DIText.TextSize = 13
DIText.TextXAlignment = Enum.TextXAlignment.Right
DIText.Parent = DynamicIsland

local DIExpanded = false
local DI_Tween = nil
DynamicIsland.MouseButton1Click:Connect(function()
    DIExpanded = not DIExpanded
    if DI_Tween then DI_Tween:Cancel() end
    if DIExpanded then
        DI_Tween = Services.TweenService:Create(DynamicIsland, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 65)})
        DI_Tween:Play()
        Services.TweenService:Create(DICorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(0, 20)}):Play()
        DIText.Text = "Session Active\nClick to close"
        DIText.TextXAlignment = Enum.TextXAlignment.Center
        DIText.Position = UDim2.new(0, 0, 0, 5)
        DIText.Size = UDim2.new(1, 0, 1, -10)
    else
        DI_Tween = Services.TweenService:Create(DynamicIsland, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 140, 0, 35)})
        DI_Tween:Play()
        Services.TweenService:Create(DICorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(1, 0)}):Play()
        DIText.TextXAlignment = Enum.TextXAlignment.Right
        DIText.Position = UDim2.new(0, 35, 0, 0)
        DIText.Size = UDim2.new(1, -40, 1, 0)
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
-- [ 2. MAIN WINDOW (ORIGINOS LAYOUT) ]
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 450) -- Cao hơn để chứa Dock
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
ApplyGlass(MainFrame, 24, 0.6, true)

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = IsMobile and 0.65 or 1

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

-- Nút Profile (Góc phải TitleBar)
local ProfileBtn = Instance.new("TextButton")
ProfileBtn.Size = UDim2.new(0, 30, 0, 30)
ProfileBtn.Position = UDim2.new(1, -40, 0.5, -15)
ProfileBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProfileBtn.BackgroundTransparency = 0.5
ProfileBtn.Text = ""
ProfileBtn.Parent = TitleBar
ApplyGlass(ProfileBtn, 15, 0.5, false)
local ProfileImg = Instance.new("ImageLabel")
ProfileImg.Size = UDim2.new(1, -4, 1, -4)
ProfileImg.Position = UDim2.new(0, 2, 0, 2)
ProfileImg.BackgroundTransparency = 1
ProfileImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
ProfileImg.Parent = ProfileBtn
local PImgCorner = Instance.new("UICorner")
PImgCorner.CornerRadius = UDim.new(1, 0)
PImgCorner.Parent = ProfileImg

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
-- [ 3. CONTENT AREA ]
-- ==========================================
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -40, 1, -140)
ContentContainer.Position = UDim2.new(0, 20, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local KeyPage = Instance.new("Frame")
KeyPage.Size = UDim2.new(1, 0, 1, 0)
KeyPage.BackgroundTransparency = 1
KeyPage.Parent = ContentContainer

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Authentication"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = KeyPage

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Enter your key to proceed."
Subtitle.TextColor3 = Color3.fromRGB(80, 80, 80)
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = KeyPage

-- Input Frame
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -20, 0, 45)
InputFrame.Position = UDim2.new(0, 0, 0, 60)
InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InputFrame.BackgroundTransparency = 0.6
InputFrame.Parent = KeyPage
ApplyGlass(InputFrame, 12, 0.7, false)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -100, 1, 0)
KeyInput.Position = UDim2.new(0, 15, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = SavedKey
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
KeyInput.Font = Enum.Font.GothamBold
KeyInput.TextSize = 14
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.Parent = InputFrame

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 80, 1, -10)
PasteBtn.Position = UDim2.new(1, -85, 0, 5)
PasteBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
PasteBtn.BackgroundTransparency = 0.3
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 12
PasteBtn.Parent = InputFrame
local PasteCorner = Instance.new("UICorner")
PasteCorner.CornerRadius = UDim.new(0, 8)
PasteCorner.Parent = PasteBtn
AddPressEffect(PasteBtn)

PasteBtn.MouseButton1Click:Connect(function()
    if getclipboard then
        local success, clip = pcall(getclipboard)
        if success and clip then KeyInput.Text = clip end
    end
end)

-- Buttons (iOS Style)
local function CreateButton(text, pos, color, textColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -8, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.15
    btn.Text = text
    btn.TextColor3 = textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = KeyPage
    ApplyGlass(btn, 12, 0.6, false)
    AddPressEffect(btn)
    return btn
end

local GetKeyBtn = CreateButton("Get Key", UDim2.new(0, 0, 0, 120), Color3.fromRGB(0, 122, 255), Color3.fromRGB(255, 255, 255))
local SubmitBtn = CreateButton("Submit", UDim2.new(0.5, 8, 0, 120), Color3.fromRGB(52, 199, 89), Color3.fromRGB(255, 255, 255))
local DiscordBtn = CreateButton("Discord", UDim2.new(0, 0, 0, 180), Color3.fromRGB(88, 101, 242), Color3.fromRGB(255, 255, 255))
local WebsiteBtn = CreateButton("Website", UDim2.new(0.5, 8, 0, 180), Color3.fromRGB(40, 40, 40), Color3.fromRGB(255, 255, 255))

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
InfTxt.Text = string.format("Time: %s\nMode: %s\nVersion: 13.0.0\n\nDeveloper: Nhism", os.date("%H:%M:%S - %d/%m/%Y"), Config.Script_Mode)
InfTxt.TextColor3 = Color3.fromRGB(80, 80, 80)
InfTxt.Font = Enum.Font.GothamMedium
InfTxt.TextSize = 14
InfTxt.TextXAlignment = Enum.TextXAlignment.Left
InfTxt.TextYAlignment = Enum.TextYAlignment.Top
InfTxt.Parent = InfoPage

-- ==========================================
-- [ 4. ORIGINOS BOTTOM DOCK (TAB BAR) ]
-- ==========================================
local BottomDock = Instance.new("Frame")
BottomDock.Size = UDim2.new(0, 300, 0, 60)
BottomDock.AnchorPoint = Vector2.new(0.5, 1)
BottomDock.Position = UDim2.new(0.5, 0, 1, -15)
BottomDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BottomDock.BackgroundTransparency = 0.6
BottomDock.Parent = MainFrame
ApplyGlass(BottomDock, 20, 0.5, true)

local DockLayout = Instance.new("UIListLayout")
DockLayout.FillDirection = Enum.FillDirection.Horizontal
DockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
DockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
DockLayout.Padding = UDim.new(0, 20)
DockLayout.Parent = BottomDock

-- Hàm tạo Tab với chống Spam
local currentTab = "Key"
local activeTween
local oldPage, newPage

local function SwitchTab(tabName, btn)
    if currentTab == tabName then return end
    currentTab = tabName
    
    if activeTween then activeTween:Cancel() end
    
    if tabName == "Key" then
        oldPage, newPage = InfoPage, KeyPage
    else
        oldPage, newPage = KeyPage, InfoPage
    end
    
    -- Animation chuyển tab (Scale & Fade)
    newPage.Visible = true
    newPage.Position = UDim2.new(0, 30, 0, 0)
    newPage.BackgroundTransparency = 1
    
    activeTween = Services.TweenService:Create(newPage, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    })
    activeTween:Play()
    
    oldPage.Visible = false
    
    -- Đổi màu nút Dock
    for _, child in ipairs(BottomDock:GetChildren()) do
        if child:IsA("TextButton") then
            if child == btn then
                Services.TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
            else
                Services.TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            end
        end
    end
end

local function CreateDockTab(name, text, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Text = icon .. "\n" .. text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = BottomDock
    ApplyGlass(btn, 12, 0.8, false)
    AddPressEffect(btn)
    return btn
end

local KeyTabBtn = CreateDockTab("KeyTabBtn", "Key", "🔑")
local InfoTabBtn = CreateDockTab("InfoTabBtn", "Info", "ℹ️")

KeyTabBtn.MouseButton1Click:Connect(function() SwitchTab("Key", KeyTabBtn) end)
InfoTabBtn.MouseButton1Click:Connect(function() SwitchTab("Info", InfoTabBtn) end)

-- Khởi tạo Tab đầu tiên
KeyTabBtn.BackgroundTransparency = 0.8
KeyTabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)

-- ==========================================
-- [ 5. PROFILE MODAL (TÁCH RIÊNG) ]
-- ==========================================
local ProfileModal = Instance.new("Frame")
ProfileModal.Size = UDim2.new(0, 300, 0, 350)
ProfileModal.AnchorPoint = Vector2.new(0.5, 0.5)
ProfileModal.Position = UDim2.new(0.5, 0, 0.5, 0)
ProfileModal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProfileModal.BackgroundTransparency = 0.1
ProfileModal.Visible = false
ProfileModal.ZIndex = 200
ProfileModal.Parent = ScreenGui
ApplyGlass(ProfileModal, 24, 0.6, true)

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
AddPressEffect(CloseModalBtn)

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
InfoBox.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
InfoBox.BackgroundTransparency = 0.5
InfoBox.Parent = ProfileModal
local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 12)
InfoCorner.Parent = InfoBox

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

-- Animation mở Profile
ProfileBtn.MouseButton1Click:Connect(function()
    ProfileModal.Visible = true
    ProfileModal.Size = UDim2.new(0, 0, 0, 0)
    Services.TweenService:Create(ProfileModal, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 350)}):Play()
end)

CloseModalBtn.MouseButton1Click:Connect(function()
    local tween = Services.TweenService:Create(ProfileModal, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        ProfileModal.Visible = false
    end)
end)

-- ==========================================
-- [ 6. IOS NOTIFICATION ]
-- ==========================================
local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 70)
    Notif.AnchorPoint = Vector2.new(0.5, 0)
    Notif.Position = UDim2.new(0.5, 0, 0, -120)
    Notif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Notif.BackgroundTransparency = 0.15
    Notif.ZIndex = 300
    Notif.Parent = ScreenGui
    ApplyGlass(Notif, 35, 0.6, true)
    
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

    Services.TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 20)}):Play()
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
        
        BlurEffect:Destroy()
        ScreenGui:Destroy()
        ExecuteGameScript(isPremium)
    else
        ShowNotification("Failed", "Invalid key.", false)
        KeyInput.Text = ""
        task.wait(1)
        Player:Kick("[NovaX Hub] Invalid Key Attempt.")
    end
end)

SwitchTab("Key", KeyTabBtn)