-- ========================================================
-- KHỞI TẠO SERVICES
-- ========================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ========================================================
-- PHẦN 1: QUẢN LÝ DỮ LIỆU & GIAO DIỆN CÀY THUÊ (NOTE)
-- ========================================================
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
                if name then
                    d.username = name
                    table.insert(out, d)
                end
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
nameLabel.Text = "👤 User :" .. hideName(lp.Name)

-- Khung hiển thị đơn
local jobFrame = Instance.new("Frame")
jobFrame.Parent = mainFrame
jobFrame.Size = UDim2.new(1, 0, 0.5, 0)
jobFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
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
jobTitle.Text = "Orders :"

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

-- Khi nhấn Enter, cập nhật nội dung và lưu vào file
jobBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and jobBox.Text ~= "" then
        uData.orders = jobBox.Text
        uData.status = "working"
        uData.savedAt = os.time()
        saveUser(lp.Name, uData)
    end
end)

saveUser(lp.Name, uData)

-- ========================================================
-- PHẦN 2: TỐI ƯU VRAM & FIX LAG (ULTRA LOW BOOSTER)
-- ========================================================

-- 1. Chế độ Black Screen (Tùy chọn)
local ENABLE_NO_RENDER = false 

if ENABLE_NO_RENDER then
    RunService:Set3dRenderingEnabled(false)
end

-- Bảo vệ góc nhìn Camera cho Leviathan
task.spawn(function()
    while task.wait(1) do
        if Camera.CameraType == Enum.CameraType.Scriptable then
            task.wait(3.5)
            if Camera.CameraType == Enum.CameraType.Scriptable then
                Camera.CameraType = Enum.CameraType.Custom
                local char = lp.Character
                if char and char:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = char.Humanoid
                end
            end
        end
    end
end)

-- 2. Dọn sạch Lighting và Skybox
pcall(function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    Lighting.Technology = Enum.Technology.Compatibility

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Clouds") then
            v:Destroy()
        end
    end
end)

-- 3. Triệt tiêu Texture & vật liệu Terrain
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    pcall(function()
        Terrain.MaterialColors = Terrain.MaterialColors
        sethiddenproperty(Terrain, "Decoration", false)
    end)
end

-- 4. Bẻ gãy toàn bộ Texture / Mesh (Loại trừ Leviathan)
local function stripVramHogs(obj)
    if obj:IsA("Camera") then return end
    local name = obj.Name:lower()
    if name:find("levi") or name:find("gate") or name:find("compass") then return end

    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Texture = ""
        obj.Transparency = 1
    elseif obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("MeshPart") then
        obj.TextureID = ""
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
    elseif obj:IsA("SpecialMesh") then
        obj.TextureId = ""
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") then
        obj.Enabled = false
        obj.Texture = ""
    elseif obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
        obj:Destroy()
    end
end

-- Quét toàn bộ Workspace hiện tại
for _, item in ipairs(Workspace:GetDescendants()) do
    stripVramHogs(item)
end

-- Tự động áp dụng cho đối tượng / hiệu ứng mới xuất hiện
Workspace.DescendantAdded:Connect(function(item)
    stripVramHogs(item)
end)

-- 5. Giải phóng Audio Buffer
for _, sound in ipairs(Workspace:GetDescendants()) do
    if sound:IsA("Sound") then
        sound.Volume = 0
        sound:Stop()
    end
end

-- 6. Dọn dẹp bộ nhớ đệm định kỳ
task.spawn(function()
    while task.wait(30) do
        collectgarbage("collect")
    end
end)
