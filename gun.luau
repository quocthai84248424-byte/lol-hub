local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--[[ ==========================================
     BYPASS ANTI-CHEAT (SILENT)
     Chạy ngầm để chặn các gói tin ban/kick
========================================== ]]
local function ActivateBypass()
    local success, err = pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            local remoteName = tostring(self):lower()
            
            -- Chặn các RemoteEvent nguy hiểm
            if method == "FireServer" or method == "InvokeServer" then
                if remoteName:find("ban") or remoteName:find("kick") or remoteName:find("log") or remoteName:find("admin") or remoteName:find("detect") then
                    return nil
                end
            end
            
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end
ActivateBypass()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Config = {
    Combat = {
        TriggerBot = false,
        TriggerRange = 500
    },
    Movement = {
        Fly = false,
        FlySpeed = 50,
        WalkSpeed = 16,
        WS_Enabled = false,
        AutoJump = false,
        Invisible = false, -- Animation Underground
        InvisibleDepth = 15 -- Độ sâu
    },
    Visuals = {
        ESP = false,
        Color = Color3.fromRGB(0, 255, 0)
    }
}

local State = {
    FlyVel = nil,
    FlyGyro = nil,
    OriginalHipHeight = 2 -- Lưu chiều cao gốc của nhân vật
}

local function IsAlive(model)
    if not model then return false end
    local hum = model:FindFirstChild("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    return hum and root and hum.Health > 0
end

--[[ ==========================================
     LOGIC TRIGGERBOT (TÂM MÀN HÌNH)
========================================== ]]
local function GetTargetFromCenter()
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true

    -- Bắn tia từ giữa màn hình thẳng về phía trước
    local rayDirection = Camera.CFrame.LookVector * Config.Combat.TriggerRange
    local result = Workspace:Raycast(Camera.CFrame.Position, rayDirection, rayParams)

    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model and IsAlive(model) then
            local player = Players:GetPlayerFromCharacter(model)
            -- Kiểm tra xem có phải là người chơi hay zombie/quái vật (có Humanoid)
            if player or model:FindFirstChild("Humanoid") then
                return true
            end
        end
    end
    return false
end

--[[ ==========================================
     LOGIC INVISIBLE (ANIMATION HIPHEIGHT)
========================================== ]]
local function UpdateInvisible()
    local char = LocalPlayer.Character
    if not IsAlive(char) then return end
    local hum = char.Humanoid
    
    if Config.Movement.Invisible then
        -- Kỹ thuật Animation: Hạ thấp HipHeight xuống âm
        -- Server vẫn nghĩ chân bạn chạm đất, nhưng hình ảnh nhân vật bị tụt xuống
        if hum.HipHeight > 0 then
            State.OriginalHipHeight = hum.HipHeight
        end
        hum.HipHeight = -Config.Movement.InvisibleDepth
    else
        -- Khôi phục chiều cao
        if hum.HipHeight < 0 then
            hum.HipHeight = State.OriginalHipHeight
        end
    end
end

--[[ ==========================================
     MAIN LOOP (XỬ LÝ LIÊN TỤC)
========================================== ]]
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    
    -- 1. Fly Logic
    if Config.Movement.Fly and IsAlive(char) then
        local root = char.HumanoidRootPart
        if not State.FlyVel then
            State.FlyVel = Instance.new("BodyVelocity", root)
            State.FlyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            State.FlyGyro = Instance.new("BodyGyro", root)
            State.FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        State.FlyGyro.CFrame = Camera.CFrame
        State.FlyVel.Velocity = Camera.CFrame.LookVector * Config.Movement.FlySpeed
    else
        if State.FlyVel then State.FlyVel:Destroy() State.FlyVel = nil end
        if State.FlyGyro then State.FlyGyro:Destroy() State.FlyGyro = nil end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not IsAlive(char) then return end
    
    -- 2. TriggerBot (Auto Shoot)
    if Config.Combat.TriggerBot then
        if GetTargetFromCenter() then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate() -- Tự động kích hoạt súng/dao
            end
        end
    end

    -- 3. Invisible (Underground Animation)
    UpdateInvisible()

    -- 4. Auto Jump (Force Jump State)
    if Config.Movement.AutoJump then
        local hum = char.Humanoid
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- 5. WalkSpeed
    if Config.Movement.WS_Enabled then
        char.Humanoid.WalkSpeed = Config.Movement.WalkSpeed
    end
end)

--[[ ==========================================
     ESP LOOP (1 GIÂY QUÉT 1 LẦN CHO ĐỠ LAG)
========================================== ]]
task.spawn(function()
    while true do
        if Config.Visuals.ESP then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v ~= LocalPlayer.Character and IsAlive(v) then
                    -- Chỉ highlight Model có Humanoid (Player/Zombie)
                    if not v:FindFirstChild("DarkESP") then
                        local h = Instance.new("Highlight", v)
                        h.Name = "DarkESP"
                        h.FillColor = Config.Visuals.Color
                        h.OutlineTransparency = 1
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "DarkESP" then v:Destroy() end
            end
        end
        task.wait(1)
    end
end)

--[[ ==========================================
     GIAO DIỆN RAYFIELD
========================================== ]]
local Window = Rayfield:CreateWindow({
    Name = "DARK HUB",
    LoadingTitle = "BYPASS ACTIVE",
    LoadingSubtitle = "ANIMATION INVISIBLE",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local TabCombat = Window:CreateTab("Combat", 4483362458)
TabCombat:CreateToggle({
    Name = "TriggerBot (Crosshair Shoot)",
    CurrentValue = false,
    Callback = function(Value) Config.Combat.TriggerBot = Value end,
})

local TabMove = Window:CreateTab("Movement", 4483362458)
TabMove:CreateToggle({
    Name = "Invisible (Underground Anim)",
    CurrentValue = false,
    Callback = function(Value) Config.Movement.Invisible = Value end,
})
TabMove:CreateSlider({
    Name = "Invisible Depth",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(Value) Config.Movement.InvisibleDepth = Value end,
})
TabMove:CreateToggle({
    Name = "Auto Jump",
    CurrentValue = false,
    Callback = function(Value) Config.Movement.AutoJump = Value end,
})
TabMove:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value) Config.Movement.Fly = Value end,
})
TabMove:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value) Config.Movement.FlySpeed = Value end,
})
TabMove:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(Value) Config.Movement.WS_Enabled = Value end,
})
TabMove:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value) Config.Movement.WalkSpeed = Value end,
})

local TabVis = Window:CreateTab("Visuals", 4483362458)
TabVis:CreateToggle({
    Name = "ESP All (Green)",
    CurrentValue = false,
    Callback = function(Value) Config.Visuals.ESP = Value end,
})
