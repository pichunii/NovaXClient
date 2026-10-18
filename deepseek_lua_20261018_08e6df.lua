-- [[ FARIAl HUB V30 - MACOS UI (REAL FIX - 100% WORKING) ]]
-- Tác giả: Nhism
-- Chú thích kỹ thuật: Đã gỡ bỏ Active ở các Frame chứa để nhường quyền click cho Button. Cô lập Notification ra một ScreenGui riêng. Sửa luồng Submit để load script mượt mà.

if not getgenv then getgenv = function() return _G end end

-- ==========================================
-- [ 1. ANTI-SPAM & CONFIG BÊN NGOÀI ]
-- ==========================================
if not getgenv().FarialLoadCount then getgenv().FarialLoadCount = 0 end
getgenv().FarialLoadCount = getgenv().FarialLoadCount + 1

if getgenv().FarialLoadCount >= 15 then
    game:GetService("Players").LocalPlayer:Kick("[Farial Hub] Anti-Cheat: Executor Spam Detected.")
    return
end

if not game:IsLoaded() then game.Loaded:Wait() end

local Services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService")
}

local Player = Services.Players.LocalPlayer
local IsMobile = Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled
local ScreenGuiName = "FarialHub_MacOS_V30"

-- FIX: Ép kiểu an toàn cho ID
local Config = {
    Key = getgenv().Key or "",
    ID = tostring(getgenv().id or ""),
    Script_Mode = getgenv().Script_Mode or "Main"
}

local Whitelist = { ["153601438942"] = true, ["129198757199"] = true }
local Blacklist = { ["999999999"] = true }
local FreeKeys = {["NHISM-FREE-111"] = true, ["FARIALHUB_PRO"] = true}
local PremiumKeys = {["NHISM-PREMIUM-999"] = true}

-- LINK TEST: Sẽ in ra console để kiểm tra xem script có chạy không
local ScriptURLs = {
    ["Main"]   = "https://raw.githubusercontent.com/yourname/yourrepo/main/main.lua",
    ["Kaitun"] = "https://raw.githubusercontent.com/yourname/yourrepo/main/kaitun.lua",
    ["Aimbot"] = "https://raw.githubusercontent.com/pichunii/NovaXClient/refs/heads/main/Aimbot.lua",
    ["Fixlag"] = "https://raw.githubusercontent.com/pichunii/NovaXClient/refs/heads/main/Fixlag.luau"
}

local WebhookURL = "https://discord.com/api/webhooks/1561300293612863539/SSgdQIlIPMMpzyQ2Y0oedU4iaVMb-WHaDQuSTvwk97TC00RBDc6gho6K_iEPHrJPwhH5"

-- ==========================================
-- [ 2. HÀM TIỆN ÍCH & BẢO MẬT ]
-- ==========================================
local function Tween(obj, time, props, style, dir)
    local tweenInfo = TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tween = Services.TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- FIX: Cô lập Notification ra ScreenGui riêng để không bị hủy khi đóng UI chính
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "FarialHub_Notif"
NotifGui.ResetOnSpawn = false
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.DisplayOrder = 9999
NotifGui.Parent = Services.CoreGui

local function ShowNotification(title, text, isSuccess)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 65)
    Notif.AnchorPoint = Vector2.new(0.5, 0)
    Notif.Position = UDim2.new(0.5, 0, 0, -100)
    Notif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Notif.BackgroundTransparency = 0.1
    Notif.ZIndex = 1000
    Notif.Parent = NotifGui
    
    local NCorner = Instance.new("UICorner")
    NCorner.CornerRadius = UDim.new(0, 16)
    NCorner.Parent = Notif
    
    local NStroke = Instance.new("UIStroke")
    NStroke.Color = Color3.fromRGB(200, 200, 200)
    NStroke.Transparency = 0.5
    NStroke.Parent = Notif
    
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -20, 0, 25)
    NTitle.Position = UDim2.new(0, 10, 0, 10)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = isSuccess and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 59, 48)
    NTitle.Font = Enum.Font.GothamBold
    NTitle.TextSize = 14
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.ZIndex = 1001
    NTitle.Parent = Notif
    
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 0, 20)
    NText.Position = UDim2.new(0, 10, 0, 35)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Color3.fromRGB(50, 50, 50)
    NText.Font = Enum.Font.GothamMedium
    NText.TextSize = 12
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.ZIndex = 1001
    NText.Parent = Notif

    Tween(Notif, 0.4, {Position = UDim2.new(0.5, 0, 0, 20)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.delay(3, function()
        local out = Tween(Notif, 0.3, {Position = UDim2.new(0.5, 0, 0, -100)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        out.Completed:Connect(function() Notif:Destroy() end)
    end)
end

local function SendWebhook(status, key, discordId, mode)
    if WebhookURL == "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL" then return end
    local maskedKey = "||" .. string.sub(tostring(key), 1, 4) .. "..." .. string.sub(tostring(key), -4) .. "||"
    local maskedId = "||" .. string.sub(tostring(discordId), 1, 4) .. "..." .. string.sub(tostring(discordId), -4) .. "||"
    
    local data = {
        ["content"] = "**Farial Hub Log**",
        ["embeds"] = {{
            ["title"] = "Trạng thái: " .. status,
            ["color"] = status:find("Online") and 65280 or 16711680,
            ["fields"] = {
                {["name"] = "Người dùng", ["value"] = Player.Name, ["inline"] = true},
                {["name"] = "Key", ["value"] = maskedKey, ["inline"] = true},
                {["name"] = "Discord ID", ["value"] = maskedId, ["inline"] = true},
                {["name"] = "Script Mode", ["value"] = tostring(mode), ["inline"] = true},
                {["name"] = "Thời gian", ["value"] = os.date("%d/%m/%Y - %H:%M:%S"), ["inline"] = false}
            },
            ["footer"] = {["text"] = "Farial Hub - made by Nhism"}
        }}
    }
    pcall(function()
        Services.HttpService:PostAsync(WebhookURL, Services.HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

local function VerifyID()
    local id = Config.ID
    if id == "" or id == "Unknown_ID" or id == "nil" then
        Player:Kick("[Farial Hub] Bảo mật: Bắt buộc phải nhập Discord ID trong Config.")
        return false
    end
    if Blacklist[id] then
        Player:Kick("[Farial Hub] Bảo mật: Discord ID của bạn nằm trong danh sách đen.")
        return false
    end
    if not Whitelist[id] then
        Player:Kick("[Farial Hub] Bảo mật: Discord ID không có trong danh sách trắng.")
        return false
    end
    return true
end

local function ValidateKey(key)
    task.wait(0.5)
    if FreeKeys[key] then return true, false end
    if PremiumKeys[key] then return true, true end
    return false, false
end

-- FIX: Bọc toàn bộ quá trình Load Script vào 1 luồng riêng biệt
local function ExecuteScriptMode()
    local mode = Config.Script_Mode
    local link = ScriptURLs[mode]
    
    if link and link:find("http") then
        print("[Farial Hub] Bắt đầu tải Script:", link)
        local success, err = pcall(function()
            local scriptContent = game:HttpGet(link)
            if scriptContent then
                print("[Farial Hub] Đã tải xong nội dung, đang thực thi...")
                local func, loadErr = loadstring(scriptContent)
                if func then
                    func() -- Chạy script
                else
                    warn("[Farial Hub] Lỗi Loadstring: ", loadErr)
                end
            else
                warn("[Farial Hub] Không thể tải nội dung script từ link.")
            end
        end)
        if not success then warn("[Farial Hub] Lỗi thực thi: " .. tostring(err)) end
    else
        warn("[Farial Hub] Mode không hợp lệ. Chạy mặc định: Main")
        if ScriptURLs["Main"] and ScriptURLs["Main"]:find("http") then
            pcall(function() 
                local mainFunc = loadstring(game:HttpGet(ScriptURLs["Main"]))
                if mainFunc then mainFunc() end
            end)
        end
    end
end

local function CreateDynamicIsland()
    local IslandGui = Instance.new("ScreenGui")
    IslandGui.Name = "FarialHub_Island"
    IslandGui.ResetOnSpawn = false
    IslandGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    IslandGui.IgnoreGuiInset = true
    IslandGui.DisplayOrder = 9999
    IslandGui.Parent = Services.CoreGui
    
    local Island = Instance.new("Frame")
    Island.Size = UDim2.new(0, 160, 0, 35)
    Island.AnchorPoint = Vector2.new(0.5, 0)
    Island.Position = UDim2.new(0.5, 0, 10, 0)
    Island.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Island.Parent = IslandGui
    
    local IslandCorner = Instance.new("UICorner")
    IslandCorner.CornerRadius = UDim.new(1, 0)
    IslandCorner.Parent = Island
    
    local IslandText = Instance.new("TextLabel")
    IslandText.Size = UDim2.new(1, 0, 1, 0)
    IslandText.BackgroundTransparency = 1
    IslandText.Text = "🦋 | 00:00 | " .. Config.Script_Mode
    IslandText.TextColor3 = Color3.fromRGB(0, 255, 128)
    IslandText.TextSize = 13
    IslandText.Font = Enum.Font.GothamBold
    IslandText.Parent = Island
    
    local startTime = tick()
    task.spawn(function()
        while IslandGui.Parent do
            local elapsed = tick() - startTime
            local mins = math.floor(elapsed / 60)
            local secs = math.floor(elapsed % 60)
            IslandText.Text = string.format("🦋 | %02d:%02d | %s", mins, secs, Config.Script_Mode)
            task.wait(1)
        end
    end)
end

-- ==========================================
-- [ 3. LUỒNG THỰC THI CHÍNH ]
-- ==========================================
if not VerifyID() then return end

if Config.Key ~= "" and Config.Key ~= nil then
    local isValid, isPremium = ValidateKey(Config.Key)
    if isValid then
        SendWebhook("Online (Config)", Config.Key, Config.ID, Config.Script_Mode)
        CreateDynamicIsland()
        ExecuteScriptMode()
    else
        SendWebhook("Offline (Sai Key Config)", Config.Key, Config.ID, Config.Script_Mode)
        Player:Kick("[Farial Hub] Bảo mật: Key trong Config không hợp lệ hoặc đã hết hạn.")
    end
    return
end

-- ==========================================
-- [ 4. KHỞI TẠO UI MACOS ]
-- ==========================================
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true 
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = ParentGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 247)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(200, 200, 200)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = IsMobile and 0.65 or 1

Tween(MainFrame, 0.5, {Size = UDim2.new(0, 650, 0, 420)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Active = true
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

local HubTitle = Instance.new("TextLabel")
HubTitle.Size = UDim2.new(1, -100, 1, 0)
HubTitle.Position = UDim2.new(0, 100, 0, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "Finder"
HubTitle.TextColor3 = Color3.fromRGB(50, 50, 50)
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextSize = 14
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.Parent = TitleBar

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

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
Sidebar.BackgroundTransparency = 0.2
Sidebar.Active = true
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

-- Profile
local ProfileImg = Instance.new("ImageLabel")
ProfileImg.Size = UDim2.new(0, 40, 0, 40)
ProfileImg.Position = UDim2.new(0, 10, 0, 10)
ProfileImg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
ProfileImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150"
ProfileImg.Parent = Sidebar
local PImgCorner = Instance.new("UICorner")
PImgCorner.CornerRadius = UDim.new(1, 0)
PImgCorner.Parent = ProfileImg

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(1, -60, 0, 20)
NameLabel.Position = UDim2.new(0, 60, 0, 15)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = Player.DisplayName
NameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextSize = 14
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = Sidebar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -60, 0, 20)
StatusLabel.Position = UDim2.new(0, 60, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Online"
StatusLabel.TextColor3 = Color3.fromRGB(52, 199, 89)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Sidebar

-- Content Container (FIX: Active = false để không chặn click)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -200, 1, -55)
Content.Position = UDim2.new(0, 190, 0, 45)
Content.BackgroundTransparency = 1
Content.Active = false 
Content.Parent = MainFrame

-- Tabs Pages (FIX: Active = false)
local MainPage = Instance.new("Frame")
MainPage.Size = UDim2.new(1, 0, 1, 0)
MainPage.BackgroundTransparency = 1
MainPage.Active = false
MainPage.Parent = Content

local SettingPage = Instance.new("Frame")
SettingPage.Size = UDim2.new(1, 0, 1, 0)
SettingPage.BackgroundTransparency = 1
SettingPage.Active = false
SettingPage.Visible = false
SettingPage.Parent = Content

local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Active = false
InfoPage.Visible = false
InfoPage.Parent = Content

local function CreateTabButton(text, yPos, page)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(80, 80, 80)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = true
    btn.Active = true
    btn.ZIndex = 10
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        MainPage.Visible = false
        SettingPage.Visible = false
        InfoPage.Visible = false
        page.Visible = true
        
        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                Tween(child, 0.2, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(80, 80, 80)})
            end
        end
        Tween(btn, 0.2, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(0, 0, 0)})
    end)
    return btn
end

local TabMain = CreateTabButton("Get Key", 80, MainPage)
local TabSetting = CreateTabButton("Settings", 120, SettingPage)
local TabInfo = CreateTabButton("Information", 160, InfoPage)

TabMain.BackgroundTransparency = 0
TabMain.TextColor3 = Color3.fromRGB(0, 0, 0)

-- ==========================================
-- [ MAIN PAGE - GET KEY ]
-- ==========================================
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Authentication"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainPage

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0, 40)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Enter your key to proceed."
Subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainPage

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -20, 0, 45)
InputFrame.Position = UDim2.new(0, 0, 0, 75)
InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InputFrame.Active = false -- FIX
InputFrame.ZIndex = 5
InputFrame.Parent = MainPage
local InCorner = Instance.new("UICorner")
InCorner.CornerRadius = UDim.new(0, 8)
InCorner.Parent = InputFrame
local InStroke = Instance.new("UIStroke")
InStroke.Color = Color3.fromRGB(220, 220, 220)
InStroke.Parent = InputFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -90, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 13
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.Active = true
KeyInput.ZIndex = 6
KeyInput.Parent = InputFrame

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 70, 1, -10)
PasteBtn.Position = UDim2.new(1, -80, 0, 5)
PasteBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
PasteBtn.Font = Enum.Font.GothamBold
PasteBtn.TextSize = 12
PasteBtn.Active = true
PasteBtn.ZIndex = 6
PasteBtn.Parent = InputFrame
local PstCorner = Instance.new("UICorner")
PstCorner.CornerRadius = UDim.new(0, 6)
PstCorner.Parent = PasteBtn

PasteBtn.MouseButton1Click:Connect(function()
    if setclipboard and getclipboard then
        local success, clip = pcall(getclipboard)
        if success and clip then KeyInput.Text = clip end
    end
end)

local function CreateActionButton(text, pos, color, textColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -10, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Active = true
    btn.ZIndex = 10
    btn.Parent = MainPage
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn
    
    btn.MouseEnter:Connect(function() Tween(btn, 0.2, {BackgroundTransparency = 0.2}) end)
    btn.MouseLeave:Connect(function() Tween(btn, 0.2, {BackgroundTransparency = 0}) end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local GetKeyBtn = CreateActionButton("Get Key", UDim2.new(0, 0, 0, 140), Color3.fromRGB(255, 149, 0), Color3.fromRGB(255, 255, 255), function()
    if setclipboard then setclipboard("https://link-to-your-key-system.com") end
    ShowNotification("Copied", "Key link copied to clipboard.", true)
end)

local SubmitBtn = CreateActionButton("Submit", UDim2.new(0.5, 10, 0, 140), Color3.fromRGB(52, 199, 89), Color3.fromRGB(255, 255, 255), function()
    local enteredKey = KeyInput.Text
    if enteredKey == "" then
        ShowNotification("Error", "Please enter a key.", false)
        return
    end
    
    SubmitBtn.Text = "Checking..."
    local isValid, isPremium = ValidateKey(enteredKey)

    if isValid then
        Config.Key = enteredKey
        SendWebhook("Online (UI)", enteredKey, Config.ID, Config.Script_Mode)
        ShowNotification("Authenticated", "Key is valid. Loading...", true)
        
        -- FIX: Đợi 1 giây cho thông báo hiện lên, sau đó hủy UI và chạy script ngầm
        task.delay(1, function()
            ScreenGui:Destroy()
            CreateDynamicIsland()
            ExecuteScriptMode()
        end)
    else
        SendWebhook("Offline (Sai Key UI)", enteredKey, Config.ID, Config.Script_Mode)
        ShowNotification("Failed", "Invalid key. Kicking...", false)
        SubmitBtn.Text = "Submit"
        
        Tween(InputFrame, 0.05, {Position = UDim2.new(0, 10, 0, 75)})
        task.wait(0.05)
        Tween(InputFrame, 0.05, {Position = UDim2.new(0, -10, 0, 75)})
        task.wait(0.05)
        Tween(InputFrame, 0.05, {Position = UDim2.new(0, 0, 0, 75)})
        task.wait(1.5)
        Player:Kick("[Farial Hub] Bảo mật: Nhập sai Key.")
    end
end)

local DiscordBtn = CreateActionButton("Discord", UDim2.new(0, 0, 0, 200), Color3.fromRGB(88, 101, 242), Color3.fromRGB(255, 255, 255), function()
    if setclipboard then setclipboard("https://discord.gg/nhism") end
    ShowNotification("Copied", "Discord link copied.", true)
end)
DiscordBtn.Size = UDim2.new(1, -20, 0, 45)

-- ==========================================
-- [ SETTING PAGE ]
-- ==========================================
local SetTitle = Instance.new("TextLabel")
SetTitle.Size = UDim2.new(1, 0, 0, 30)
SetTitle.Position = UDim2.new(0, 0, 0, 10)
SetTitle.BackgroundTransparency = 1
SetTitle.Text = "Settings"
SetTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
SetTitle.Font = Enum.Font.GothamBlack
SetTitle.TextSize = 22
SetTitle.TextXAlignment = Enum.TextXAlignment.Left
SetTitle.Parent = SettingPage

local ThemeFrame = Instance.new("Frame")
ThemeFrame.Size = UDim2.new(1, -20, 0, 50)
ThemeFrame.Position = UDim2.new(0, 0, 0, 60)
ThemeFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ThemeFrame.Active = false -- FIX
ThemeFrame.ZIndex = 5
ThemeFrame.Parent = SettingPage
local TFCorner = Instance.new("UICorner")
TFCorner.CornerRadius = UDim.new(0, 8)
TFCorner.Parent = ThemeFrame

local ThemeLabel = Instance.new("TextLabel")
ThemeLabel.Size = UDim2.new(1, -80, 1, 0)
ThemeLabel.Position = UDim2.new(0, 15, 0, 0)
ThemeLabel.BackgroundTransparency = 1
ThemeLabel.Text = "Dark Mode"
ThemeLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
ThemeLabel.Font = Enum.Font.GothamMedium
ThemeLabel.TextSize = 14
ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
ThemeLabel.Parent = ThemeFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 28)
ToggleBtn.Position = UDim2.new(1, -65, 0.5, -14)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 225)
ToggleBtn.Text = ""
ToggleBtn.Active = true
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = ThemeFrame
local TogCorner = Instance.new("UICorner")
TogCorner.CornerRadius = UDim.new(1, 0)
TogCorner.Parent = ToggleBtn

local ToggleDot = Instance.new("Frame")
ToggleDot.Size = UDim2.new(0, 24, 0, 24)
ToggleDot.Position = UDim2.new(0, 2, 0.5, -12)
ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleDot.Parent = ToggleBtn
local TDCorner = Instance.new("UICorner")
TDCorner.CornerRadius = UDim.new(1, 0)
TDCorner.Parent = ToggleDot

local isDark = false
ToggleBtn.MouseButton1Click:Connect(function()
    isDark = not isDark
    if isDark then
        Tween(ToggleBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(52, 199, 89)})
        Tween(ToggleDot, 0.2, {Position = UDim2.new(1, -26, 0.5, -12)})
        Tween(MainFrame, 0.3, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
        Tween(Sidebar, 0.3, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
        Tween(ThemeFrame, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        Tween(InputFrame, 0.3, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        Tween(PasteBtn, 0.3, {BackgroundColor3 = Color3.fromRGB(70, 70, 75), TextColor3 = Color3.fromRGB(255, 255, 255)})
        
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        SetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        InfTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
        ThemeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
        KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    else
        Tween(ToggleBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(220, 220, 225)})
        Tween(ToggleDot, 0.2, {Position = UDim2.new(0, 2, 0.5, -12)})
        Tween(MainFrame, 0.3, {BackgroundColor3 = Color3.fromRGB(245, 245, 247)})
        Tween(Sidebar, 0.3, {BackgroundColor3 = Color3.fromRGB(235, 235, 240)})
        Tween(ThemeFrame, 0.3, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        Tween(InputFrame, 0.3, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        Tween(PasteBtn, 0.3, {BackgroundColor3 = Color3.fromRGB(230, 230, 235), TextColor3 = Color3.fromRGB(0, 0, 0)})
        
        Title.TextColor3 = Color3.fromRGB(0, 0, 0)
        SetTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        InfoTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
        InfTxt.TextColor3 = Color3.fromRGB(50, 50, 50)
        ThemeLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        HubTitle.TextColor3 = Color3.fromRGB(50, 50, 50)
        NameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        Subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
        KeyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
        KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- ==========================================
-- [ INFO PAGE ]
-- ==========================================
local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, 0, 0, 30)
InfoTitle.Position = UDim2.new(0, 0, 0, 10)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "Information"
InfoTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
InfoTitle.Font = Enum.Font.GothamBlack
InfoTitle.TextSize = 22
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = InfoPage

local InfTxt = Instance.new("TextLabel")
InfTxt.Size = UDim2.new(1, -20, 1, -50)
InfTxt.Position = UDim2.new(0, 0, 0, 50)
InfTxt.BackgroundTransparency = 1
InfTxt.Text = string.format(
    "Date: %s\nTime: %s\nScripts: Main - Aimbot - Kaitun - Fixlag\nStatus: Online\nUpdate: V30.0.0\n\nCredit: Nhism\nWeb: farialhub.com\nDiscord: discord.gg/farialhub",
    os.date("%d/%m/%Y"), os.date("%H:%M:%S")
)
InfTxt.TextColor3 = Color3.fromRGB(50, 50, 50)
InfTxt.Font = Enum.Font.GothamMedium
InfTxt.TextSize = 13
InfTxt.TextXAlignment = Enum.TextXAlignment.Left
InfTxt.TextYAlignment = Enum.TextYAlignment.Top
InfTxt.Parent = InfoPage

-- Home Indicator
local HomeInd = Instance.new("Frame")
HomeInd.Size = UDim2.new(0, 120, 0, 5)
HomeInd.AnchorPoint = Vector2.new(0.5, 1)
HomeInd.Position = UDim2.new(0.5, 0, 1, -8)
HomeInd.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HomeInd.BackgroundTransparency = 0.6
HomeInd.Parent = MainFrame
local HICorner = Instance.new("UICorner")
HICorner.CornerRadius = UDim.new(1, 0)
HICorner.Parent = HomeInd
