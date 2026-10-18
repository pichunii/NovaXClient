-- [[ FARIAl HUB V36 - PREMIUM EDITION (STRICT CONFIG ONLY) ]]
-- Tác giả: Nhism
-- Chú thích kỹ thuật: Hệ thống bảo mật nghiêm ngặt, không có UI, bắt buộc Config, Webhook chạy ngầm và log rõ ràng ra Console.

if not getgenv then getgenv = function() return _G end end

-- ==========================================
-- [ 1. CONFIG & ANTI-SPAM ]
-- ==========================================
local Config = {
    Key = getgenv().Key or "",
    ID = tostring(getgenv().id or ""),
    Script_Mode = getgenv().Script_Mode or "Main"
}

local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService"),
    CoreGui = game:GetService("CoreGui")
}

local Player = Services.Players.LocalPlayer

-- Bộ đếm chống Spam Executor
if not getgenv().FarialLoadCount then getgenv().FarialLoadCount = 0 end
getgenv().FarialLoadCount = getgenv().FarialLoadCount + 1
if getgenv().FarialLoadCount >= 10 then
    Player:Kick("[Farial Hub] Security: Phát hiện Spam Executor. Vui lòng khởi động lại game.")
    return
end

-- ==========================================
-- [ 2. CẤU HÌNH HỆ THỐNG BÊN TRONG ]
-- ==========================================
local Whitelist = { ["153601438942"] = true, ["129198757199"] = true }
local Blacklist = { ["999999999"] = true }
local FreeKeys = {["NHISM-FREE-111"] = true, ["FARIALHUB_PRO"] = true}
local PremiumKeys = {["NHISM-PREMIUM-999"] = true, ["PREMIUM_KEY_VIP"] = true}

local ScriptURLs = {
    ["Main"]   = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", 
    ["Kaitun"] = "https://raw.githubusercontent.com/yourname/yourrepo/main/kaitun.lua",
    ["Aimbot"] = "https://raw.githubusercontent.com/pichunii/NovaXClient/refs/heads/main/Aimbot.lua",
    ["Fixlag"] = "https://raw.githubusercontent.com/pichunii/NovaXClient/refs/heads/main/Fixlag.luau"
}

local WebhookURL = "https://discord.com/api/webhooks/1561300293612863539/SSgdQIlIPMMpzyQ2Y0oedU4iaVMb-WHaDQuSTvwk97TC00RBDc6gho6K_iEPHrJPwhH5"

-- ==========================================
-- [ 3. WEBHOOK LOGGING (BẮT BUỘC CHẠY) ]
-- ==========================================
local function SendWebhook(status, key, discordId, mode)
    if WebhookURL == "" then 
        warn("[Farial Hub] Webhook URL is empty!")
        return 
    end
    
    local maskedKey = "||" .. string.sub(tostring(key), 1, 4) .. "..." .. string.sub(tostring(key), -4) .. "||"
    local maskedId = "||" .. string.sub(tostring(discordId), 1, 4) .. "..." .. string.sub(tostring(discordId), -4) .. "||"
    
    local data = {
        ["content"] = "**Farial Hub Access Log**",
        ["embeds"] = {{
            ["title"] = "Trạng thái: " .. status,
            ["color"] = status:find("Online") and 65280 or 16711680,
            ["fields"] = {
                {["name"] = "Username", ["value"] = Player.Name, ["inline"] = true},
                {["name"] = "Key", ["value"] = maskedKey, ["inline"] = true},
                {["name"] = "Discord ID", ["value"] = maskedId, ["inline"] = true},
                {["name"] = "Script Mode", ["value"] = tostring(mode), ["inline"] = true},
                {["name"] = "Thời gian", ["value"] = os.date("%d/%m/%Y - %H:%M:%S"), ["inline"] = false}
            },
            ["footer"] = {["text"] = "Farial Hub Premium Security"}
        }}
    }
    
    local payload = Services.HttpService:JSONEncode(data)
    
    task.spawn(function()
        local success, err = pcall(function()
            if syn and syn.request then
                syn.request({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
            elseif request then
                request({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
            elseif http_request then
                http_request({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
            else
                Services.HttpService:PostAsync(WebhookURL, payload, Enum.HttpContentType.ApplicationJson)
            end
        end)
        
        if success then
            print("[Farial Hub] Webhook gửi thành công: " .. status)
        else
            warn("[Farial Hub] Webhook gửi thất bại: " .. tostring(err))
        end
    end)
end

-- ==========================================
-- [ 4. KIỂM TRA BẢO MẬT (PREMIUM STRICT) ]
-- ==========================================
print("[Farial Hub] Đang xác thực Config...")

-- 1. Kiểm tra ID rỗng
if Config.ID == "" or Config.ID == "nil" then
    SendWebhook("Offline (ID Empty)", Config.Key, Config.ID, Config.Script_Mode)
    Player:Kick("\n[Farial Hub] XÁC THỰC THẤT BẠI:\nBạn chưa nhập Discord ID vào Config.\nVui lòng thêm: getgenv().id = \"ID_CUA_BAN\"")
    return
end

-- 2. Kiểm tra ID trong Blacklist
if Blacklist[Config.ID] then
    SendWebhook("Offline (Blacklisted)", Config.Key, Config.ID, Config.Script_Mode)
    Player:Kick("\n[Farial Hub] XÁC THỰC THẤT BẠI:\nDiscord ID của bạn đã bị đưa vào Blacklist.")
    return
end

-- 3. Kiểm tra ID trong Whitelist
if not Whitelist[Config.ID] then
    SendWebhook("Offline (Unwhitelisted)", Config.Key, Config.ID, Config.Script_Mode)
    Player:Kick("\n[Farial Hub] XÁC THỰC THẤT BẠI:\nDiscord ID của bạn không có trong hệ thống (Whitelist).")
    return
end

-- 4. Kiểm tra Key rỗng
if Config.Key == "" or Config.Key == nil then
    SendWebhook("Offline (Key Empty)", Config.Key, Config.ID, Config.Script_Mode)
    Player:Kick("\n[Farial Hub] XÁC THỰC THẤT BẠI:\nBạn chưa nhập Key vào Config.\nVui lòng thêm: getgenv().Key = \"KEY_CUA_BAN\"")
    return
end

-- 5. Kiểm tra Key hợp lệ
local isValidKey = false
local isPremiumKey = false

if FreeKeys[Config.Key] then
    isValidKey = true
elseif PremiumKeys[Config.Key] then
    isValidKey = true
    isPremiumKey = true
end

if not isValidKey then
    SendWebhook("Offline (Invalid Key)", Config.Key, Config.ID, Config.Script_Mode)
    Player:Kick("\n[Farial Hub] XÁC THỰC THẤT BẠI:\nKey bạn nhập không hợp lệ hoặc đã hết hạn.")
    return
end

-- ==========================================
-- [ 5. KÍCH HOẠT PREMIUM ]
-- ==========================================
print("[Farial Hub] Xác thực thành công! Đang khởi chạy hệ thống...")
SendWebhook("Online (Premium Access)", Config.Key, Config.ID, Config.Script_Mode)

-- Tạo Dynamic Island
local IslandGui = Instance.new("ScreenGui")
IslandGui.Name = "FarialHub_Island"
IslandGui.ResetOnSpawn = false
IslandGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
IslandGui.IgnoreGuiInset = true
IslandGui.DisplayOrder = 9999
IslandGui.Parent = Services.CoreGui

local Island = Instance.new("Frame")
Island.Size = UDim2.new(0, 170, 0, 35)
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
IslandText.Text = "🦋 Premium | 00:00 | " .. Config.Script_Mode
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
        IslandText.Text = string.format("🦋 Premium | %02d:%02d | %s", mins, secs, Config.Script_Mode)
        task.wait(1)
    end
end)

-- Giả lập Loading Effect
task.wait(1)

-- Thực thi Script
local function ExecuteScript()
    local mode = Config.Script_Mode
    local link = ScriptURLs[mode] or ScriptURLs["Main"]
    
    print("[Farial Hub] Đang tải Script: " .. tostring(mode))
    
    task.spawn(function()
        local success, err = pcall(function()
            local scriptContent = game:HttpGet(link)
            if scriptContent then
                local func, loadErr = loadstring(scriptContent)
                if func then
                    func()
                    print("[Farial Hub] Script đã chạy thành công!")
                else
                    warn("[Farial Hub] Lỗi Loadstring: " .. tostring(loadErr))
                end
            end
        end)
        if not success then warn("[Farial Hub] Lỗi HTTP: " .. tostring(err)) end
    end)
end

ExecuteScript()
