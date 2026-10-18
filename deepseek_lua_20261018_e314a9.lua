-- [[ IPHONE iOS 27 LIQUID GLASS SIMULATOR ]]
-- Tác giả: Nhism (Dựa trên ý tưởng của bạn)
-- Ngôn ngữ: Luau

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ScreenGuiName = "IOS27_Simulator"

-- Xoá UI cũ nếu có
local CoreGui = game:GetService("CoreGui")
local ParentGui = gethui and gethui() or (CoreGui:FindFirstChild("RobloxGui") or CoreGui)
if ParentGui:FindFirstChild(ScreenGuiName) then
    ParentGui:FindFirstChild(ScreenGuiName):Destroy()
end

-- [ 1. HIỆU ỨNG BLUR NỀN (LIQUID GLASS) ]
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 15
BlurEffect.Parent = Lighting

-- [ 2. KHỞI TẠO MÀN HÌNH CHÍNH ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = ScreenGuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Tràn viền
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = ParentGui

-- Hàm tạo hiệu ứng Kính Lỏng (Liquid Glass)
local function ApplyGlass(element, radius, transparency)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 16)
    corner.Parent = element
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = transparency or 0.6
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = element
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 220, 255))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 0.95)
    }
    gradient.Rotation = 45
    gradient.Parent = element
end

-- [ 3. DYNAMIC ISLAND (SÁT MÉP TRÊN MÀN HÌNH) ]
local DynamicIsland = Instance.new("Frame")
DynamicIsland.Name = "DynamicIsland"
DynamicIsland.Size = UDim2.new(0, 120, 0, 32)
DynamicIsland.AnchorPoint = Vector2.new(0.5, 0)
DynamicIsland.Position = UDim2.new(0.5, 0, 0, 10) -- Sát trên cùng
DynamicIsland.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DynamicIsland.BorderSizePixel = 0
DynamicIsland.Parent = ScreenGui

local DICorner = Instance.new("UICorner")
DICorner.CornerRadius = UDim.new(1, 0)
DICorner.Parent = DynamicIsland

local DIText = Instance.new("TextLabel")
DIText.Size = UDim2.new(1, 0, 1, 0)
DIText.BackgroundTransparency = 1
DIText.Text = "00:00"
DIText.TextColor3 = Color3.fromRGB(0, 255, 128)
DIText.Font = Enum.Font.GothamBold
DIText.TextSize = 13
DIText.Parent = DynamicIsland

local DIExpanded = false
local IslandBtn = Instance.new("TextButton")
IslandBtn.Size = UDim2.new(1, 0, 1, 0)
IslandBtn.BackgroundTransparency = 1
IslandBtn.Text = ""
IslandBtn.Parent = DynamicIsland

IslandBtn.MouseButton1Click:Connect(function()
    DIExpanded = not DIExpanded
    if DIExpanded then
        TweenService:Create(DynamicIsland, TweenInfo.new(0.4, Enum.EasingStyle.Spring), {Size = UDim2.new(0, 250, 0, 70)}):Play()
        DIText.Text = "🦋 Music Playing...\nNhism Hub Active"
    else
        TweenService:Create(DynamicIsland, TweenInfo.new(0.4, Enum.EasingStyle.Spring), {Size = UDim2.new(0, 120, 0, 32)}):Play()
        DIText.Text = "00:00"
    end
end)

-- Cập nhật giờ thực tế
task.spawn(function()
    while ScreenGui.Parent do
        if not DIExpanded then
            DIText.Text = os.date("%H:%M")
        end
        task.wait(1)
    end
end)

-- [ 4. MÀN HÌNH KHÓA (LOCK SCREEN) ]
local LockScreen = Instance.new("Frame")
LockScreen.Name = "LockScreen"
LockScreen.Size = UDim2.new(1, 0, 1, 0)
LockScreen.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LockScreen.BackgroundTransparency = 0.2
LockScreen.Parent = ScreenGui

local LockTime = Instance.new("TextLabel")
LockTime.Size = UDim2.new(1, 0, 0, 100)
LockTime.Position = UDim2.new(0, 0, 0.2, 0)
LockTime.BackgroundTransparency = 1
LockTime.Text = os.date("%H:%M")
LockTime.TextColor3 = Color3.fromRGB(255, 255, 255)
LockTime.Font = Enum.Font.GothamBold
LockTime.TextSize = 80
LockTime.Parent = LockScreen

local SwipeUpText = Instance.new("TextLabel")
SwipeUpText.Size = UDim2.new(1, 0, 0, 30)
SwipeUpText.Position = UDim2.new(0, 0, 1, -80)
SwipeUpText.BackgroundTransparency = 1
SwipeUpText.Text = "Swipe up to unlock (Click Here)"
SwipeUpText.TextColor3 = Color3.fromRGB(255, 255, 255)
SwipeUpText.Font = Enum.Font.GothamMedium
SwipeUpText.TextSize = 14
SwipeUpText.Parent = LockScreen

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Size = UDim2.new(1, 0, 0, 100)
UnlockBtn.Position = UDim2.new(0, 0, 1, -120)
UnlockBtn.BackgroundTransparency = 1
UnlockBtn.Text = ""
UnlockBtn.Parent = LockScreen

-- [ 5. MÀN HÌNH CHÍNH (HOME SCREEN) ]
local HomeScreen = Instance.new("Frame")
HomeScreen.Name = "HomeScreen"
HomeScreen.Size = UDim2.new(1, 0, 1, 0)
HomeScreen.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
HomeScreen.BackgroundTransparency = 0.1
HomeScreen.Parent = ScreenGui

local AppContainer = Instance.new("Frame")
AppContainer.Size = UDim2.new(1, -60, 1, -200)
AppContainer.Position = UDim2.new(0, 30, 0, 80)
AppContainer.BackgroundTransparency = 1
AppContainer.Parent = HomeScreen
local AppGrid = Instance.new("UIGridLayout")
AppGrid.CellSize = UDim2.new(0, 70, 0, 90)
AppGrid.CellPadding = UDim2.new(0, 20, 0, 20)
AppGrid.Parent = AppContainer

-- Dock (Thanh dưới cùng)
local Dock = Instance.new("Frame")
Dock.Size = UDim2.new(0, 320, 0, 80)
Dock.AnchorPoint = Vector2.new(0.5, 1)
Dock.Position = UDim2.new(0.5, 0, 1, -20)
Dock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Dock.BackgroundTransparency = 0.8
Dock.Parent = HomeScreen
ApplyGlass(Dock, 24, 0.5)

-- Hàm tạo App Icon
local function CreateApp(name, icon, parent)
    local app = Instance.new("TextButton")
    app.Size = UDim2.new(0, 70, 0, 70)
    app.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    app.Text = icon
    app.TextSize = 30
    app.Font = Enum.Font.GothamBold
    app.TextColor3 = Color3.fromRGB(255, 255, 255)
    app.Parent = parent
    ApplyGlass(app, 16, 0.3)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 10
    label.Parent = app
    
    return app
end

-- Thêm App vào Home
CreateApp("Settings", "⚙️", AppContainer)
CreateApp("Photos", "🖼️", AppContainer)
CreateApp("Camera", "📷", AppContainer)
CreateApp("Music", "🎵", AppContainer)
CreateApp("Weather", "⛅", AppContainer)
CreateApp("Calendar", "📅", AppContainer)
CreateApp("Clock", "⏰", AppContainer)
CreateApp("Calculator", "🔢", AppContainer)
CreateApp("Notes", "📝", AppContainer)
CreateApp("Phone", "📞", AppContainer)

-- Thêm App vào Dock
local DockGrid = Instance.new("UIListLayout")
DockGrid.FillDirection = Enum.FillDirection.Horizontal
DockGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
DockGrid.VerticalAlignment = Enum.VerticalAlignment.Center
DockGrid.Padding = UDim.new(0, 15)
DockGrid.Parent = Dock

CreateApp("Phone", "📞", Dock)
CreateApp("Safari", "🧭", Dock)
CreateApp("Messages", "💬", Dock)
CreateApp("Music", "🎵", Dock)

-- [ 6. HIỆU ỨNG CHUYỂN CẢNH ]
UnlockBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(LockScreen, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, -1, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        LockScreen.Visible = false
    end)
end)

-- [ 7. APP CONTAINER (MỞ APP) ]
local OpenAppFrame = Instance.new("Frame")
OpenAppFrame.Size = UDim2.new(0, 0, 0, 0)
OpenAppFrame.AnchorPoint = Vector2.new(0.5, 0.5)
OpenAppFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
OpenAppFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
OpenAppFrame.Visible = false
OpenAppFrame.ZIndex = 100
OpenAppFrame.Parent = ScreenGui
ApplyGlass(OpenAppFrame, 24, 0.1)

local CloseAppBtn = Instance.new("TextButton")
CloseAppBtn.Size = UDim2.new(0, 40, 0, 40)
CloseAppBtn.Position = UDim2.new(1, -50, 0, 10)
CloseAppBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseAppBtn.Text = "X"
CloseAppBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseAppBtn.Font = Enum.Font.GothamBold
CloseAppBtn.Parent = OpenAppFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseAppBtn

local AppTitle = Instance.new("TextLabel")
AppTitle.Size = UDim2.new(1, -100, 0, 40)
AppTitle.Position = UDim2.new(0, 20, 0, 10)
AppTitle.BackgroundTransparency = 1
AppTitle.Text = "App Name"
AppTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AppTitle.Font = Enum.Font.GothamBold
AppTitle.TextSize = 24
AppTitle.TextXAlignment = Enum.TextXAlignment.Left
AppTitle.Parent = OpenAppFrame

local function OpenApp(appName)
    AppTitle.Text = appName
    OpenAppFrame.Visible = true
    OpenAppFrame.Size = UDim2.new(0, 0, 0, 0)
    
    TweenService:Create(OpenAppFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 350)
    }):Play()
end

CloseAppBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(OpenAppFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        OpenAppFrame.Visible = false
    end)
end)

-- Gắn sự kiện mở App cho tất cả Icon
for _, v in pairs(HomeScreen:GetDescendants()) do
    if v:IsA("TextButton") and v:FindFirstChild("TextLabel") and v.Name ~= "CloseAppBtn" then
        v.MouseButton1Click:Connect(function()
            OpenApp(v.TextLabel.Text)
        end)
    end
end
for _, v in pairs(Dock:GetDescendants()) do
    if v:IsA("TextButton") and v:FindFirstChild("TextLabel") then
        v.MouseButton1Click:Connect(function()
            OpenApp(v.TextLabel.Text)
        end)
    end
end

-- [ 8. TRUNG TÂM ĐIỀU KHIỂN (CONTROL CENTER) ]
local ControlCenter = Instance.new("Frame")
ControlCenter.Size = UDim2.new(0, 350, 0, 250)
ControlCenter.Position = UDim2.new(1, -370, 0, 20)
ControlCenter.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ControlCenter.BackgroundTransparency = 0.3
ControlCenter.Visible = false
ControlCenter.ZIndex = 50
ControlCenter.Parent = ScreenGui
ApplyGlass(ControlCenter, 24, 0.4)

local CCTitle = Instance.new("TextLabel")
CCTitle.Size = UDim2.new(1, -20, 0, 30)
CCTitle.Position = UDim2.new(0, 10, 0, 10)
CCTitle.BackgroundTransparency = 1
CCTitle.Text = "Control Center"
CCTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
CCTitle.Font = Enum.Font.GothamBold
CCTitle.TextSize = 18
CCTitle.Parent = ControlCenter

-- Nút mở Control Center (Mô phỏng vuốt từ góc phải)
local CCOpenBtn = Instance.new("TextButton")
CCOpenBtn.Size = UDim2.new(0, 40, 0, 40)
CCOpenBtn.Position = UDim2.new(1, -50, 0, 50)
CCOpenBtn.BackgroundTransparency = 0.5
CCOpenBtn.Text = "≡"
CCOpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CCOpenBtn.Font = Enum.Font.GothamBold
CCOpenBtn.TextSize = 20
CCOpenBtn.Parent = ScreenGui
ApplyGlass(CCOpenBtn, 20, 0.5)

CCOpenBtn.MouseButton1Click:Connect(function()
    ControlCenter.Visible = not ControlCenter.Visible
end)

-- Các nút trong Control Center
local function CreateCCToggle(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -15, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ControlCenter
    ApplyGlass(btn, 12, 0.5)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(50, 50, 55)
    end)
end

CreateCCToggle("Wi-Fi", UDim2.new(0, 10, 0, 50))
CreateCCToggle("Bluetooth", UDim2.new(0.5, 5, 0, 50))
CreateCCToggle("Flashlight", UDim2.new(0, 10, 0, 110))
CreateCCToggle("Dark Mode", UDim2.new(0.5, 5, 0, 110))

-- Thanh trượt độ sáng (Mô phỏng)
local BrightnessSlider = Instance.new("Frame")
BrightnessSlider.Size = UDim2.new(1, -20, 0, 40)
BrightnessSlider.Position = UDim2.new(0, 10, 0, 170)
BrightnessSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
BrightnessSlider.Parent = ControlCenter
ApplyGlass(BrightnessSlider, 12, 0.5)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.7, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderFill.Parent = BrightnessSlider
ApplyGlass(SliderFill, 12, 0)

local BtnText = Instance.new("TextLabel")
BtnText.Size = UDim2.new(1, 0, 1, 0)
BtnText.BackgroundTransparency = 1
BtnText.Text = "☀️ Brightness"
BtnText.TextColor3 = Color3.fromRGB(0, 0, 0)
BtnText.Font = Enum.Font.GothamBold
BtnText.TextSize = 14
BtnText.Parent = SliderFill

-- [ 9. NÚT ẨN/HIỆN TOÀN BỘ UI ]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.BackgroundTransparency = 0.5
ToggleBtn.Text = "📱"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 24
ToggleBtn.Parent = ScreenGui
ApplyGlass(ToggleBtn, 25, 0.3)

ToggleBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Phím tắt RightShift để ẩn/hiện
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("[iOS 27 Simulator] Loaded Successfully.")
