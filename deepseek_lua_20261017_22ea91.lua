-- [[ NOVAX AIMBOT V14 - TRUE CAMERA LOCK ]]
-- Author: Nhism
-- Strict Focus: 100% Aimbot functionality, Body Part Dropdown, No Lag, No Crash.

if not game:IsLoaded() then game.Loaded:Wait() end
if not getgenv then getgenv = function() return _G end end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- ==========================================
-- [ 1. CONFIGURATION ]
-- ==========================================
local Config = {
    Enabled = false,
    LockLia = false, -- Tự động khóa không cần giữ phím
    Keybind = "E",
    TargetPart = "Head", -- Mặc định khóa đầu
    FOV = 300,
    Smoothness = 1, -- 1 = Snap ngay lập tức (Aim chặt nhất)
    TeamCheck = true
}

-- ==========================================
-- [ 2. TARGET LOGIC & BODY PART MAPPING ]
-- ==========================================
local function GetAimPart(character)
    local target = Config.TargetPart
    
    if target == "Head" then
        return character:FindFirstChild("Head")
        
    elseif target == "Torso" then
        -- Hỗ trợ cả R15 (UpperTorso) và R6 (Torso)
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
        
    elseif target == "Neck" then
        -- R15 nằm ở UpperTorso (phần cổ), R6 nằm ở Torso
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        
    elseif target == "Belly" then
        -- R15 nằm ở LowerTorso (phần bụng), R6 nằm ở Torso
        return character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
    end
    
    return character:FindFirstChild("Head") -- Fallback
end

local function GetClosestPlayer()
    local closest, shortestDistance = nil, Config.FOV
    local center = Camera.ViewportSize / 2
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if hrp and hum and hum.Health > 0 then
                if Config.TeamCheck and LocalPlayer.Team == player.Team then continue end
                
                -- Check khoảng cách trên màn hình
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDistance then
                        closest = player
                        shortestDistance = dist
                    end
                end
            end
        end
    end
    return closest
end

-- ==========================================
-- [ 3. CORE AIMBOT LOGIC (BIND TO RENDER STEP) ]
-- ==========================================
-- Sử dụng BindToRenderStep với Priority Camera + 1 để ghi đè Camera mặc định
Services.RunService:BindToRenderStep("NovaX_TrueAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if Config.Enabled then
        local isKeyDown = Services.UserInputService:IsKeyDown(Enum.KeyCode[Config.Keybind])
        
        if isKeyDown or Config.LockLia then
            local targetPlayer = GetClosestPlayer()
            
            if targetPlayer and targetPlayer.Character then
                local aimPart = GetAimPart(targetPlayer.Character)
                
                if aimPart then
                    -- Lấy vị trí chính xác của bộ phận cần Aim
                    local targetPos = aimPart.Position
                    
                    -- Tính toán CFrame khóa Camera vào bộ phận đó
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    
                    if Config.LockLia or Config.Smoothness >= 1 then
                        -- Snap 100% (Aim Cứng)
                        Camera.CFrame = targetCFrame
                    else
                        -- Aim mượt (Nếu Smoothness < 1)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- [ 4. FOV VISUALIZER ]
-- ==========================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 0)

Services.RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = Config.FOV
        FOVCircle.Visible = Config.Enabled
    end
end)

-- ==========================================
-- [ 5. UI CONSTRUCTION (RAYFIELD) ]
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "NovaX AimBot V14",
    LoadingTitle = "Loading Aim Engine...",
    LoadingSubtitle = "by Nhism | Pure Lock",
    ConfigurationSaving = {Enabled = false}, -- Tắt lưu config để tránh lỗi file
    KeySystem = false
})

local AimTab = Window:CreateTab("Aimbot", 4483362458)
AimTab:CreateSection("Aim Settings")

AimTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = Config.Enabled,
    Flag = "AimbotToggle",
    Callback = function(Value) Config.Enabled = Value end
})

AimTab:CreateToggle({
    Name = "Lock Camera (Auto Aim)",
    Description = "Tự động khóa mục tiêu không cần giữ phím",
    CurrentValue = Config.LockLia,
    Flag = "LockLia",
    Callback = function(Value) Config.LockLia = Value end
})

AimTab:CreateToggle({
    Name = "Team Check",
    Description = "Không Aim vào đồng đội",
    CurrentValue = Config.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(Value) Config.TeamCheck = Value end
})

AimTab:CreateDropdown({
    Name = "Target Body Part",
    Options = {"Head", "Torso", "Neck", "Belly"},
    CurrentOption = {"Head"},
    Flag = "TargetPart",
    Callback = function(option) 
        Config.TargetPart = option[1] 
    end
})

AimTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 800},
    Increment = 10,
    Suffix = "px",
    CurrentValue = Config.FOV,
    Flag = "FOV",
    Callback = function(Value) Config.FOV = Value end
})

AimTab:CreateSlider({
    Name = "Aim Smoothness",
    Description = "Để 100% (Cột phải) để Aim Cứng - Khóa Chặt",
    Range = {10, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = Config.Smoothness * 100,
    Flag = "Smoothness",
    Callback = function(Value) Config.Smoothness = Value / 100 end
})

AimTab:CreateKeybind({
    Name = "Aimbot Keybind",
    CurrentKeybind = Config.Keybind,
    HoldToInteract = false,
    Flag = "AimKey",
    Callback = function(Key) Config.Keybind = Key end
})

Rayfield:Notify({
    Title = "NovaX V14 Loaded",
    Content = "True Aimbot Engine Active. No Silent Aim.",
    Duration = 5
})
