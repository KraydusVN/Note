local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")
local DATA_DIR = "tzuancaythue/"

local function ensureDir()
    if not isfolder(DATA_DIR) then
        makefolder(DATA_DIR)
    end
end

local function saveUser(name, data)
    ensureDir()
    local path = DATA_DIR .. name .. ".json"
    writefile(path, HttpService:JSONEncode(data))
end

local function loadUser(name)
    ensureDir()
    local path = DATA_DIR .. name .. ".json"
    if isfile(path) then
        local ok, d = pcall(HttpService.JSONDecode, HttpService, readfile(path))
        if ok then return d end
    end
    return nil
end

local function loadAll()
    ensureDir()
    local out = {}
    for _, fname in ipairs(listfiles(DATA_DIR)) do
        if fname:sub(-5) == ".json" then
            local ok, d = pcall(HttpService.JSONDecode, HttpService, readfile(fname))
            if ok then
                local name = fname:match("([^/\\]+)%.json$")
                if name then d.username = name table.insert(out, d) end
            end
        end
    end
    return out
end

local uData = loadUser(lp.Name) or { username = lp.Name, orders = "", status = "working", savedAt = os.time() }

-- Ẩn một phần tên
local function hideName(name)
    local visibleLength = math.max(3, math.floor(#name * 0.5))
    local hiddenPart = string.rep("*", #name - visibleLength)
    return string.sub(name, 1, visibleLength) .. hiddenPart
end

-- Tạo GUI chính
local nameHub = Instance.new("ScreenGui")
nameHub.Name = "TzuanCayThue"
nameHub.ResetOnSpawn = false
nameHub.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Parent = nameHub
mainFrame.Size = UDim2.new(0.45, 0, 0.2, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Active = true
mainFrame.Draggable = true

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.15, 0)
uiCorner.Parent = mainFrame

-- Hiển thị tên (ẩn bớt chữ)
local nameLabel = Instance.new("TextLabel")
nameLabel.Parent = mainFrame
nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
nameLabel.Position = UDim2.new(0, 0, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = "👤 User :" .. hideName(lp.Name) .. ""

-- Khung hiển thị đơn
local jobFrame = Instance.new("Frame")
jobFrame.Parent = mainFrame
jobFrame.Size = UDim2.new(1, 0, 0.5, 0)
jobFrame.Position = UDim2.new(0, 0, 0.5, 0)
jobFrame.BackgroundTransparency = 1

-- Hiển thị chữ "Đơn:"
local jobTitle = Instance.new("TextLabel")
jobTitle.Parent = jobFrame
jobTitle.Size = UDim2.new(0.3, 0, 1, 0)
jobTitle.Position = UDim2.new(0, 0, 0, 0)
jobTitle.BackgroundTransparency = 1
jobTitle.TextColor3 = Color3.fromRGB(255, 223, 88)
jobTitle.TextScaled = true
jobTitle.Font = Enum.Font.GothamBold
jobTitle.Text = "📌 Orders :"

-- Ô sửa nội dung đơn (đồng bộ với file lưu của user)
local jobBox = Instance.new("TextBox")
jobBox.Parent = jobFrame
jobBox.Size = UDim2.new(0.7, 0, 1, 0)
jobBox.Position = UDim2.new(0.3, 0, 0, 0)
jobBox.BackgroundTransparency = 1
jobBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jobBox.TextScaled = true
jobBox.Font = Enum.Font.GothamBold
jobBox.Text = uData.orders or ""
jobBox.ClearTextOnFocus = false
jobBox.TextWrapped = true

-- Khi nhấn Enter, cập nhật nội dung và lưu vào file như logic gốc
jobBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and jobBox.Text ~= "" then
        uData.orders = jobBox.Text
        uData.status = "working"
        uData.savedAt = os.time()
        saveUser(lp.Name, uData)
        jobBox.Text = jobBox.Text
    end
end)

saveUser(lp.Name, uData)

-- [[ FIX LAG BLOX FRUITS - AN TOÀN CHO LEVIATHAN & SEA EVENTS ]] --
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = Workspace.CurrentCamera

-- 1. GIỮ AN TOÀN CHO CAMERA (Tự động phục hồi nếu cutscene Leviathan bị treo góc nhìn)
task.spawn(function()
    while task.wait(1) do
        -- Nếu không trong cutscene mà góc camera bị nghiêng hoặc kẹt Scriptable quá lâu
        if Camera.CameraType == Enum.CameraType.Scriptable then
            -- Cho phép cutscene chạy tối đa 4 giây, nếu quá thời gian tự động trả về góc nhìn thường
            task.wait(4)
            if Camera.CameraType == Enum.CameraType.Scriptable then
                Camera.CameraType = Enum.CameraType.Custom
            end
        end
    end
end)

-- 2. TỐI ƯU LIGHTING (Không xóa để tránh làm đứt liên kết Cutscene)
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    
    for _, v in ipairs(Lighting:GetChildren()) do
        -- Chỉ tắt hiệu ứng làm mờ/lóa sáng, GIỮ LẠI ColorCorrection nếu liên quan đến cutscene
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
end)

-- 3. TỐI ƯU TERRAIN MẶT NƯỚC
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
end

-- 4. BỘ LỌC AN TOÀN: LOẠI TRỪ CÁC OBJECT LIÊN QUAN ĐẾN LEVIATHAN / SEA EVENTS
local function isProtected(obj)
    local name = obj.Name:lower()
    -- Tránh can thiệp vào mô hình Leviathan, thuyền móc tim, hoặc UI thông báo
    if name:find("levi") or name:find("heart") or name:find("gate") or name:find("boat") or name:find("harpoon") then
        return true
    end
    -- Tránh can thiệp vào người chơi và Camera
    if obj:IsDescendantOf(Players) or obj:IsA("Camera") then
        return true
    end
    return false
end

-- 5. HÀM TỐI ƯU VẬT THỂ AN TOÀN
local function safeOptimize(obj)
    if isProtected(obj) then return end

    if obj:IsA("BasePart") then
        obj.CastShadow = false
        -- Không can thiệp nếu part có chứa Script bên trong
        if not obj:FindFirstChildOfClass("Script") and not obj:FindFirstChildOfClass("LocalScript") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        -- Tránh xóa decal hiển thị hướng dẫn/mũi tên la bàn
        if not obj.Parent.Name:lower():find("compass") and not obj.Parent.Name:lower():find("arrow") then
            obj.Transparency = 1
        end
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
        -- Tắt hiệu ứng hạt nhưng không xóa để engine không báo lỗi logic
        obj.Enabled = false
    elseif obj:IsA("Light") then
        obj.Enabled = false
    end
end

-- 6. THỰC THI
for _, item in ipairs(Workspace:GetDescendants()) do
    safeOptimize(item)
end

Workspace.DescendantAdded:Connect(function(item)
    safeOptimize(item)
end)
