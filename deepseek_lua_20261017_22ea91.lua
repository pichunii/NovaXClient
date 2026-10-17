-- [[ NOVAX HUB V12 - PERFECT HEAD LOCK ]]
-- Author: Nhism
-- Features: Perfect Silent Aim, Instant Camera Lock, Safe Engine.

if not game:IsLoaded() then game.Loaded:Wait() end
if not getgenv then getgenv = function() return _G end end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Stats = game:GetService("Stats"),
    VirtualUser = game:GetService("VirtualUser")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ConfigFile = "NovaX_V12_Config.json"

-- [ 1. CONFIGURATION ]
local Config = {
    Aimbot = {
        Enabled = false,
        SilentAim = true, -- Bật mặc định để đảm bảo 100% trúng
        LockLia = false,
        AutoShoot = false,
        TeamCheck = true,
        WallCheck = false, -- Tắt WallCheck để Silent Aim xuyên qua tường nếu cần
        Smoothness = 1, -- 1 = Snap ngay lập tức
        FOV = 300,
        TargetPart = "Head", -- Ép buộc Target là Head
        Keybind = "E",
        Prediction = 0.15
    },
    ESP = {
        Enabled = false,
        Box = true,
        Tracer = true,
        Ring = true,
        Rainbow = true
    },
    Exploits = {
        Speed = false,
        SpeedValue = 60,
        Jump = false,
        JumpValue = 120,
        Fly = false,
        FlySpeed = 80,
        Noclip = false,
        InfiniteAmmo = false
    }
}

-- Load/Save Config
local function LoadConfig()
    if isfile and readfile and isfile(ConfigFile) then
        local success, data = pcall(function() return Services.HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and data then
            for k, v in pairs(data) do if Config[k] then for k2, v2 in pairs(v) do Config[k][k2] = v2 end end end
        end
    end
end
local function SaveConfig()
    if writefile then pcall(function() writefile(ConfigFile, Services.HttpService:JSONEncode(Config)) end) end
end
LoadConfig()

local function GetRainbowColor() return Color3.fromHSV((tick() * 0.5) % 1, 1, 1) end

-- [ 2. ESP SYSTEM ]
local ESPObjects = {}
local function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = { Box = Drawing.new("Square"), Tracer = Drawing.new("Line"), Ring = Drawing.new("Circle"), Name = Drawing.new("Text") }
    esp.Box.Thickness = 1; esp.Box.Filled = false; esp.Box.Transparency = 1
    esp.Tracer.Thickness = 1; esp.Tracer.Transparency = 1
    esp.Ring.Thickness = 1; esp.Ring.Filled = false; esp.Ring.Transparency = 1; esp.Ring.Radius = 50
    esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true; esp.Name.OutlineColor = Color3.new(0, 0, 0)
    ESPObjects[player] = esp
end

local function RemoveESP(player)
    if ESPObjects[player] then for _, obj in pairs(ESPObjects[player]) do obj:Remove() end ESPObjects[player] = nil end
end

local function UpdateESP()
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPObjects[player] then CreateESP(player) end
            local esp = ESPObjects[player]
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")
            
            if not Config.ESP.Enabled or not hum or hum.Health <= 0 then
                for _, obj in pairs(esp) do obj.Visible = false end
            else
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local color = Config.ESP.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
                
                if onScreen then
                    if Config.ESP.Box then
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        esp.Box.Color = color; esp.Box.Visible = true
                    else esp.Box.Visible = false end
                    
                    if Config.ESP.Tracer then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
                        esp.Tracer.Color = color; esp.Tracer.Visible = true
                    else esp.Tracer.Visible = false end
                    
                    if Config.ESP.Ring then
                        esp.Ring.Position = Vector2.new(pos.X, pos.Y)
                        esp.Ring.Color = color; esp.Ring.Visible = true
                    else esp.Ring.Visible = false end
                    
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - 20)
                    esp.Name.Color = color; esp.Name.Visible = true
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            end
        end
    end
end

-- [ 3. PERFECT TARGET LOGIC ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.Transparency = 1

local function GetTargetPosition(part)
    -- Prediction để bắn trúng địch đang di chuyển
    local ping = Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    local predictedPos = part.Position + (part.Velocity * ping * Config.Aimbot.Prediction)
    return predictedPos
end

local function GetClosestPlayer()
    local closest, shortestDistance = nil, Config.Aimbot.FOV
    local center = Camera.ViewportSize / 2
    
    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChild("Humanoid")
            -- Ép cứng Target là Head
            local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            
            if targetPart and hum and hum.Health > 0 then
                if Config.Aimbot.TeamCheck and LocalPlayer.Team == player.Team then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
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

-- [ 4. SAFE SILENT AIM HOOK (V2) ]
-- Chỉ hook Raycast để chống crash, không hook Mouse
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and getgenv().SilentAimActive then
            if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
                local target = GetClosestPlayer()
                if target and target.Character then
                    local part = target.Character:FindFirstChild("Head")
                    if part then
                        local args = {...}
                        local targetPos = GetTargetPosition(part)
                        
                        if method == "Raycast" then
                            local origin = args[1]
                            local direction = args[2]
                            -- Ghi đè hướng đạn bay thẳng vào đầu
                            args[2] = (targetPos - origin).Unit * (direction.Magnitude or 1000)
                            return oldNamecall(self, unpack(args))
                        elseif method:find("FindPartOnRay") then
                            local ray = args[1]
                            -- Ghi đè tia đạn
                            args[1] = Ray.new(ray.Origin, (targetPos - ray.Origin).Unit * 1000)
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- [ 5. EXPLOITS (STABLE) ]
local SpeedBV, SpeedCon
local function ApplySpeed()
    if SpeedCon then SpeedCon:Disconnect() end
    if SpeedBV then SpeedBV:Destroy() end
    
    if Config.Exploits.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        SpeedBV = Instance.new("BodyVelocity")
        SpeedBV.MaxForce = Vector3.new(1e5, 0, 1e5)
        SpeedBV.Velocity = Vector3.new(0,0,0)
        SpeedBV.Parent = hrp
        
        SpeedCon = Services.RunService.Heartbeat:Connect(function()
            if not Config.Exploits.Speed or not LocalPlayer.Character then return end
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0 then
                SpeedBV.Velocity = hum.MoveDirection * Config.Exploits.SpeedValue
            else
                SpeedBV.Velocity = Vector3.new(0,0,0)
            end
        end)
    end
end

local function ApplyJump()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Exploits.Jump and Config.Exploits.JumpValue or 50
    end
end

local FlyBV, FlyCon
local function ApplyFly()
    if FlyCon then FlyCon:Disconnect() end
    if FlyBV then FlyBV:Destroy() end
    
    if Config.Exploits.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        FlyBV.Velocity = Vector3.new(0,0,0)
        FlyBV.Parent = LocalPlayer.Character.HumanoidRootPart
        
        FlyCon = Services.RunService.RenderStepped:Connect(function()
            if not Config.Exploits.Fly or not LocalPlayer.Character then return end
            local camCF = Camera.CFrame
            local moveDir = Vector3.new(0,0,0)
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
            
            if moveDir.Magnitude > 0 then
                FlyBV.Velocity = moveDir.Unit * Config.Exploits.FlySpeed
            else
                FlyBV.Velocity = Vector3.new(0,0,0)
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    ApplySpeed(); ApplyJump(); ApplyFly()
end)

-- [ 6. MAIN RENDER LOOP ]
Services.RunService.RenderStepped:Connect(function()
    -- FOV Circle
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Color = Config.ESP.Rainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = Config.Aimbot.Enabled
    
    UpdateESP()
    
    -- Aimbot & Auto Shoot & Silent Aim Logic
    if Config.Aimbot.Enabled then
        getgenv().SilentAimActive = Config.Aimbot.SilentAim
        
        local isKeyDown = Services.UserInputService:IsKeyDown(Enum.KeyCode[Config.Aimbot.Keybind])
        
        if isKeyDown or Config.Aimbot.LockLia or Config.Aimbot.AutoShoot then
            local target = GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild("Head")
                if part then
                    -- Camera Lock (Aim chặt)
                    if Config.Aimbot.LockLia or isKeyDown then
                        local targetPos = GetTargetPosition(part)
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                        -- Nếu LockLia bật, Snap 100%. Nếu không, Lerp theo Smoothness.
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.LockLia and 1 or (Config.Aimbot.Smoothness * 0.5))
                    end
                    
                    -- Auto Shoot
                    if Config.Aimbot.AutoShoot then
                        pcall(function() Services.VirtualUser:ClickButton1(Vector2.new()) end)
                    end
                end
            end
        end
    else
        getgenv().SilentAimActive = false
    end
    
    -- Exploits Logic
    if LocalPlayer.Character then
        if Config.Exploits.InfiniteAmmo then
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, v in pairs(tool:GetDescendants()) do
                        if v:IsA("IntValue") or v:IsA("NumberValue") then
                            if v.Name:lower():find("ammo") or v.Name:lower():find("clip") then
                                v.Value = 999
                            end
                        end
                    end
                end
            end
        end
        
        if Config.Exploits.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
            end
        end
    end
end)

-- [ 7. UI CONSTRUCTION ]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "NovaX Hub V12",
    LoadingTitle = "NovaX Hub Perfect Lock",
    LoadingSubtitle = "by Nhism | 100% Headshot",
    ConfigurationSaving = {Enabled = true, FolderName = "NovaXV12", FileName = "Config"},
    KeySystem = false
})

local MainTab = Window:CreateTab("Aimbot", 4483362458)
MainTab:CreateSection("Perfect Aim Settings")
MainTab:CreateToggle({Name = "Enable Aimbot", CurrentValue = Config.Aimbot.Enabled, Flag = "AimbotToggle", Callback = function(Value) Config.Aimbot.Enabled = Value end})
MainTab:CreateToggle({Name = "Silent Aim (100% Hit)", CurrentValue = Config.Aimbot.SilentAim, Flag = "SilentToggle", Callback = function(Value) Config.Aimbot.SilentAim = Value end})
MainTab:CreateToggle({Name = "Lock Camera (Instant Snap)", CurrentValue = Config.Aimbot.LockLia, Flag = "LockLia", Callback = function(Value) Config.Aimbot.LockLia = Value end})
MainTab:CreateToggle({Name = "Auto Shoot", CurrentValue = Config.Aimbot.AutoShoot, Flag = "AutoShoot", Callback = function(Value) Config.Aimbot.AutoShoot = Value end})
MainTab:CreateToggle({Name = "Team Check", CurrentValue = Config.Aimbot.TeamCheck, Flag = "TeamCheck", Callback = function(Value) Config.Aimbot.TeamCheck = Value end})
MainTab:CreateSlider({Name = "FOV Radius", Range = {50, 800}, Increment = 10, CurrentValue = Config.Aimbot.FOV, Flag = "FOV", Callback = function(Value) Config.Aimbot.FOV = Value end})
MainTab:CreateKeybind({Name = "Aimbot Key", CurrentKeybind = Config.Aimbot.Keybind, Flag = "AimKey", Callback = function(Key) Config.Aimbot.Keybind = Key end})

local ExploitTab = Window:CreateTab("Movement", 4483362458)
ExploitTab:CreateSection("Speed & Jump")
ExploitTab:CreateToggle({Name = "Speed Hack", CurrentValue = Config.Exploits.Speed, Flag = "SpeedToggle", Callback = function(Value) Config.Exploits.Speed = Value; ApplySpeed() end})
ExploitTab:CreateSlider({Name = "Speed Value", Range = {16, 250}, Increment = 1, CurrentValue = Config.Exploits.SpeedValue, Flag = "SpeedValue", Callback = function(Value) Config.Exploits.SpeedValue = Value end})
ExploitTab:CreateToggle({Name = "Jump Hack", CurrentValue = Config.Exploits.Jump, Flag = "JumpToggle", Callback = function(Value) Config.Exploits.Jump = Value; ApplyJump() end})
ExploitTab:CreateSlider({Name = "Jump Power", Range = {50, 500}, Increment = 5, CurrentValue = Config.Exploits.JumpValue, Flag = "JumpValue", Callback = function(Value) Config.Exploits.JumpValue = Value; ApplyJump() end})
ExploitTab:CreateToggle({Name = "Fly", CurrentValue = Config.Exploits.Fly, Flag = "FlyToggle", Callback = function(Value) Config.Exploits.Fly = Value; ApplyFly() end})
ExploitTab:CreateSlider({Name = "Fly Speed", Range = {10, 200}, Increment = 1, CurrentValue = Config.Exploits.FlySpeed, Flag = "FlySpeed", Callback = function(Value) Config.Exploits.FlySpeed = Value end})

ExploitTab:CreateSection("Miscellaneous")
ExploitTab:CreateToggle({Name = "Infinite Ammo", CurrentValue = Config.Exploits.InfiniteAmmo, Flag = "InfAmmoToggle", Callback = function(Value) Config.Exploits.InfiniteAmmo = Value end})
ExploitTab:CreateToggle({Name = "Noclip", CurrentValue = Config.Exploits.Noclip, Flag = "NoclipToggle", Callback = function(Value) Config.Exploits.Noclip = Value end})
ExploitTab:CreateButton({Name = "Save Configuration", Callback = function() SaveConfig() Rayfield:Notify({Title = "System", Content = "Configuration Saved", Duration = 2}) end})

local ESPTab = Window:CreateTab("Visuals", 4483362458)
ESPTab:CreateToggle({Name = "Enable ESP", CurrentValue = Config.ESP.Enabled, Flag = "ESPToggle", Callback = function(Value) Config.ESP.Enabled = Value end})
ESPTab:CreateToggle({Name = "Rainbow Mode", CurrentValue = Config.ESP.Rainbow, Flag = "RainbowToggle", Callback = function(Value) Config.ESP.Rainbow = Value end})
ESPTab:CreateToggle({Name = "Box ESP", CurrentValue = Config.ESP.Box, Flag = "BoxToggle", Callback = function(Value) Config.ESP.Box = Value end})
ESPTab:CreateToggle({Name = "Tracer (Line)", CurrentValue = Config.ESP.Tracer, Flag = "TracerToggle", Callback = function(Value) Config.ESP.Tracer = Value end})
ESPTab:CreateToggle({Name = "Ring ESP", CurrentValue = Config.ESP.Ring, Flag = "RingToggle", Callback = function(Value) Config.ESP.Ring = Value end})

Services.Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function(c) if Config.ESP.Enabled then CreateESP(p) end end) end)
Services.Players.PlayerRemoving:Connect(RemoveESP)

Rayfield:Notify({Title = "NovaX V12 Loaded", Content = "Perfect Head Lock Active. 100% Hit Rate.", Duration = 5})
