-- ========================================================================= --
--    BLOX FRUITS: ULTRA LOW VRAM BOOSTER (MAX CẮT GIẢM) + NOTE QUẢN LÝ ĐƠN   --
-- ========================================================================= --

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========================================================================= --
-- [1] HỆ THỐNG GHI CHÚ ĐƠN CÀY THUÊ (NOTE FILE JSON)
-- ========================================================================= --
local playerGui = lp:WaitForChild("PlayerGui")
local DATA_DIR = "tzuancaythue/"[cite: 2]

local function ensureDir()
    if not isfolder(DATA_DIR) then
        makefolder(DATA_DIR)
    end
end[cite: 2]

local function saveUser(name, data)
    ensureDir()[cite: 2]
    local path = DATA_DIR .. name .. ".json"[cite: 2]
    writefile(path, HttpService:JSONEncode(data))[cite: 2]
end

local function loadUser(name)
    ensureDir()[cite: 2]
    local path = DATA_DIR .. name .. ".json"[cite: 2]
    if isfile(path) then[cite: 2]
        local ok, d = pcall(HttpService.JSONDecode, HttpService, readfile(path))[cite: 2]
        if ok then return d end[cite: 2]
    end
    return nil[cite: 2]
end

local uData = loadUser(lp.Name) or { username = lp.Name, orders = "", status = "working", savedAt = os.time() }[cite: 2]

local function hideName(name)
    local visibleLength = math.max(3, math.floor(#name * 0.5))[cite: 2]
    local hiddenPart = string.rep("*", #name - visibleLength)[cite: 2]
    return string.sub(name, 1, visibleLength) .. hiddenPart[cite: 2]
end

local nameHub = Instance.new("ScreenGui")[cite: 2]
nameHub.Name = "TzuanCayThue"[cite: 2]
nameHub.ResetOnSpawn = false[cite: 2]
nameHub.Parent = playerGui[cite: 2]

local mainFrame = Instance.new("Frame")[cite: 2]
mainFrame.Parent = nameHub[cite: 2]
mainFrame.Size = UDim2.new(0.45, 0, 0.2, 0)[cite: 2]
mainFrame.Position = UDim2.new(0.5, 0, 0.1, 0)[cite: 2]
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)[cite: 2]
mainFrame.BackgroundTransparency = 0.2[cite: 2]
mainFrame.BorderSizePixel = 0[cite: 2]
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)[cite: 2]
mainFrame.Active = true[cite: 2]
mainFrame.Draggable = true[cite: 2]

local uiCorner = Instance.new("UICorner")[cite: 2]
uiCorner.CornerRadius = UDim.new(0.15, 0)[cite: 2]
uiCorner.Parent = mainFrame[cite: 2]

local nameLabel = Instance.new("TextLabel")[cite: 2]
nameLabel.Parent = mainFrame[cite: 2]
nameLabel.Size = UDim2.new(1, 0, 0.5, 0)[cite: 2]
nameLabel.Position = UDim2.new(0, 0, 0, 0)[cite: 2]
nameLabel.BackgroundTransparency = 1[cite: 2]
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)[cite: 2]
nameLabel.TextScaled = true[cite: 2]
nameLabel.Font = Enum.Font.GothamBold[cite: 2]
nameLabel.Text = "👤 User :" .. hideName(lp.Name) .. ""[cite: 2]

local jobFrame = Instance.new("Frame")[cite: 2]
jobFrame.Parent = mainFrame[cite: 2]
jobFrame.Size = UDim2.new(1, 0, 0.5, 0)[cite: 2]
jobFrame.Position = UDim2.new(0, 0, 0.5, 0)[cite: 2]
jobFrame.BackgroundTransparency = 1[cite: 2]

local jobTitle = Instance.new("TextLabel")[cite: 2]
jobTitle.Parent = jobFrame[cite: 2]
jobTitle.Size = UDim2.new(0.3, 0, 1, 0)[cite: 2]
jobTitle.Position = UDim2.new(0, 0, 0, 0)[cite: 2]
jobTitle.BackgroundTransparency = 1[cite: 2]
jobTitle.TextColor3 = Color3.fromRGB(255, 223, 88)[cite: 2]
jobTitle.TextScaled = true[cite: 2]
jobTitle.Font = Enum.Font.GothamBold[cite: 2]
jobTitle.Text = "📌 Orders :"[cite: 2]

local jobBox = Instance.new("TextBox")[cite: 2]
jobBox.Parent = jobFrame[cite: 2]
jobBox.Size = UDim2.new(0.7, 0, 1, 0)[cite: 2]
jobBox.Position = UDim2.new(0.3, 0, 0, 0)[cite: 2]
jobBox.BackgroundTransparency = 1[cite: 2]
jobBox.TextColor3 = Color3.fromRGB(255, 255, 255)[cite: 2]
jobBox.TextScaled = true[cite: 2]
jobBox.Font = Enum.Font.GothamBold[cite: 2]
jobBox.Text = uData.orders or ""[cite: 2]
jobBox.ClearTextOnFocus = false[cite: 2]
jobBox.TextWrapped = true[cite: 2]

jobBox.FocusLost:Connect(function(enterPressed)[cite: 2]
    if enterPressed and jobBox.Text ~= "" then[cite: 2]
        uData.orders = jobBox.Text[cite: 2]
        uData.status = "working"[cite: 2]
        uData.savedAt = os.time()[cite: 2]
        saveUser(lp.Name, uData)[cite: 2]
    end[cite: 2]
end)[cite: 2]

saveUser(lp.Name, uData)[cite: 2]

-- ========================================================================= --
-- [2] FIX LAG ÉP VRAM TỐI ĐA (GIỮ NGUYÊN SỨC MẠNH ÉP XUNG GPU)
-- ========================================================================= --

-- Tùy chọn tắt kết xuất 3D (Nếu bật true, VRAM giảm về ~100MB sàn tuyệt đối)
local ENABLE_NO_RENDER = false 

if ENABLE_NO_RENDER then
    RunService:Set3dRenderingEnabled(false)
end

-- TỰ ĐỘNG SỬA LỖI CAMERA LEVIATHAN
task.spawn(function()
    while task.wait(0.5) do
        -- Nếu camera bị kẹt ở chế độ Scriptable do cutscene mở đầu Leviathan gây ra
        if Camera.CameraType == Enum.CameraType.Scriptable then
            task.wait(3.5) -- Đợi hiệu ứng spawn Leviathan hoàn tất
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

-- 1. XÓA SẠCH LIGHTING, BẦU TRỜI & CUBEMAP
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

-- 2. TỐI ƯU TERRAIN MẶT NƯỚC TRIỆT ĐỂ
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

-- 3. HÀM ÉP TRẮNG VRAM (CHỈ LOẠI TRỪ CAMERA & PHẦN TỬ SỰ KIỆN LEVIATHAN)
local function isLeviOrUI(obj)
    if obj:IsA("Camera") then return true end
    if obj:IsDescendantOf(nameHub) then return true end
    
    local name = obj.Name:lower()
    -- Chỉ tha các object của gate/mũi tên/leviathan để không bị bug màn hình vát chéo
    if name:find("levi") or name:find("gate") or name:find("compass") or name:find("heart") then
        return true
    end
    return false
end

local function stripVramHogs(obj)
    if isLeviOrUI(obj) then return end

    -- Gỡ Texture và Decal khỏi VRAM
    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Texture = ""
        obj.Transparency = 1
    -- Đưa Part về SmoothPlastic trơn không bóng
    elseif obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    -- Gỡ sạch Texture của Mesh
    elseif obj:IsA("MeshPart") then
        obj.TextureID = ""
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
    elseif obj:IsA("SpecialMesh") then
        obj.TextureId = ""
    -- Vô hiệu hóa hạt và nguồn sáng
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") then
        obj.Enabled = false
        obj.Texture = ""
    elseif obj:IsA("Light") then
        obj.Enabled = false
    -- Xóa quần áo NPC/Quái để giải phóng bộ nhớ texture nhân vật
    elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
        obj:Destroy()
    end
end

-- Quét toàn bộ workspace hiện tại
for _, item in ipairs(Workspace:GetDescendants()) do
    stripVramHogs(item)
end

-- Bắt các skill / quái vừa sinh ra để ép VRAM ngay lập tức
Workspace.DescendantAdded:Connect(function(item)
    stripVramHogs(item)
end)

-- Tắt toàn bộ Sound Buffer trong RAM
for _, sound in ipairs(Workspace:GetDescendants()) do
    if sound:IsA("Sound") then
        sound.Volume = 0
        sound:Stop()
    end
end

-- Thu gom rác Lua định kỳ mỗi 30s
task.spawn(function()
    while task.wait(30) do
        collectgarbage("collect")
    end
end)
