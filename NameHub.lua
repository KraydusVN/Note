local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Thư mục lưu trữ trên workspace của executor
local SAVE_FOLDER = "NameHub"
local SAVE_FILE = SAVE_FOLDER .. "/job_" .. player.UserId .. ".txt"

-- Kiểm tra các hàm filesystem của executor (writefile/readfile/isfile/makefolder)
local hasFS = writefile and readfile and isfile and makefolder and isfolder

if hasFS then
    if not isfolder(SAVE_FOLDER) then
        makefolder(SAVE_FOLDER)
    end
end

-- ==== TỰ ĐỘNG REJOIN KHI BỊ KICK / RỚT MẠNG ====
-- game:BindToClose chạy khi client sắp đóng kết nối tới server hiện tại
-- (bao gồm cả trường hợp bị kick, server sập, hoặc rớt mạng).
-- Khi đó script sẽ tự teleport lại đúng place (và đúng server nếu có JobId).
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local function setupAutoRejoin()
    if RunService:IsStudio() then return end -- không rejoin khi test trong Studio

    game:BindToClose(function()
        local placeId = game.PlaceId
        local jobId = game.JobId -- rỗng nếu server đã sập hẳn

        local ok = pcall(function()
            if jobId ~= "" then
                -- Cố gắng vào lại ĐÚNG server cũ
                TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
            else
                -- Nếu không lấy được server cũ, vào server bất kỳ của cùng place
                TeleportService:Teleport(placeId, player)
            end
        end)

        if not ok then
            pcall(function()
                TeleportService:Teleport(placeId, player)
            end)
        end
    end)
end
-- Cách 1 (khuyên dùng - áp dụng mọi lần mở game/inject lại):
--   Hầu hết executor (Synapse X, Script-Ware, Fluxus, Codex, Wave...) đều có
--   sẵn thư mục/mục "Auto Execute" trong giao diện của chính executor.
--   Bạn chỉ cần lưu file NameHub.lua này vào đúng thư mục đó MỘT LẦN DUY NHẤT
--   (thường là "autoexec" trong workspace của executor) — không cần code gì thêm,
--   mọi lần vào game sau executor sẽ tự chạy script này.
--
-- Cách 2 (tự động qua code - áp dụng khi teleport sang map/server khác
--   trong CÙNG một phiên chơi, không cần tắt/mở lại executor):
local function setupAutoExecute()
    if syn and syn.queue_on_teleport then
        pcall(syn.queue_on_teleport, [[loadstring(readfile("NameHub/NameHub.lua"))()]])
    elseif queue_on_teleport then
        pcall(queue_on_teleport, [[loadstring(readfile("NameHub/NameHub.lua"))()]])
    end
end

-- Ẩn một phần tên
local function hideName(name)
    local visibleLength = math.max(3, math.floor(#name * 0.5))
    local hiddenPart = string.rep("*", #name - visibleLength)
    return string.sub(name, 1, visibleLength) .. hiddenPart
end

-- Lưu nội dung đơn vào workspace
local function saveJob(text)
    if hasFS then
        local ok, err = pcall(function()
            writefile(SAVE_FILE, text)
        end)
        if not ok then
            warn("NameHub: không thể lưu file - " .. tostring(err))
        end
    end
end

-- Đọc nội dung đơn đã lưu (nếu có)
local function loadJob()
    if hasFS and isfile(SAVE_FILE) then
        local ok, content = pcall(readfile, SAVE_FILE)
        if ok then
            return content
        end
    end
    return ""
end

-- Tạo GUI chính
local nameHub = Instance.new("ScreenGui")
nameHub.Name = "NameHub"
nameHub.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Parent = nameHub
mainFrame.Size = UDim2.new(0.6, 0, 0.2, 0) -- Khung kéo dài ra
mainFrame.Position = UDim2.new(0.5, 0, 0.12, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Active = true -- Cho phép kéo
mainFrame.Draggable = true -- Kéo thả được

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.15, 0)
uiCorner.Parent = mainFrame

-- Hiển thị tên (ẩn bớt chữ)
local nameLabel = Instance.new("TextLabel")
nameLabel.Parent = mainFrame
nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
nameLabel.Position = UDim2.new(0, 0, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = "👤 Tên :" .. hideName(player.Name) .. ""

-- Khung hiển thị đơn
local jobFrame = Instance.new("Frame")
jobFrame.Parent = mainFrame
jobFrame.Size = UDim2.new(1, 0, 0.6, 0)
jobFrame.Position = UDim2.new(0, 0, 0.4, 0)
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
jobTitle.Text = "📌 Đơn :"

-- Ô sửa nội dung đơn
local jobBox = Instance.new("TextBox")
jobBox.Parent = jobFrame
jobBox.Size = UDim2.new(0.7, 0, 1, 0)
jobBox.Position = UDim2.new(0.3, 0, 0, 0)
jobBox.BackgroundTransparency = 1
jobBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jobBox.TextScaled = true
jobBox.Font = Enum.Font.GothamBold
jobBox.Text = loadJob() -- Tự động tải nội dung đã lưu trước đó
jobBox.ClearTextOnFocus = false
jobBox.TextWrapped = true

-- Khi nhấn Enter, cập nhật nội dung và lưu vào workspace
jobBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and jobBox.Text ~= "" then
        saveJob(jobBox.Text)
    end
end)

-- Kích hoạt tự động execute khi teleport sang map/server khác (nếu executor hỗ trợ)
setupAutoExecute()

-- Kích hoạt tự động rejoin nếu bị kick / rớt mạng / server sập
setupAutoRejoin()
