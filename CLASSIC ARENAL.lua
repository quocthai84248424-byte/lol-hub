local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "script by ilovedog1901ilovecat5551",
    LoadingTitle = "Classic Arena Hub Pro - FIX LOG",
    LoadingSubtitle = "by ilovedog1901ilovecat5551",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ArenaHubVip",
        FileName = "Config"
    },
    KeySystem = false
})

local lp = game.Players.LocalPlayer
local targetPlayer = ""
local autoKillEnabled = false
local flyEnabled = false
local flySpeed = 50
local hitboxSize = 1
local infDash = false
local noCooldown = false

-- HỆ THỐNG CHỐNG BAN/KICK VIP
local function Bypass()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then return nil end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end
pcall(Bypass)

local MainTab = Window:CreateTab("Main", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483345998)

-- TAB MAIN
MainTab:CreateInput({
    Name = "Target Player Name",
    PlaceholderText = "Nhập tên...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) targetPlayer = Text end,
})

MainTab:CreateToggle({
    Name = "Auto Kill Player",
    CurrentValue = false,
    Flag = "AutoKill",
    Callback = function(Value)
        autoKillEnabled = Value
        spawn(function()
            while autoKillEnabled do
                pcall(function()
                    local target = game.Players:FindFirstChild(targetPlayer)
                    if target and target.Character then
                        lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        local tool = lp.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        game:GetService("ReplicatedStorage").Events.Skill:FireServer("Attack")
                    end
                end)
                task.wait()
            end
        end)
    end,
})

local VisualPart = Instance.new("Part")
VisualPart.Shape = Enum.PartType.Ball
VisualPart.Color = Color3.fromRGB(255, 255, 255)
VisualPart.Transparency = 0.8
VisualPart.CanCollide = false
VisualPart.Material = Enum.Material.ForceField

MainTab:CreateSlider({
    Name = "Player Hitbox Size (Range)",
    Range = {1, 150},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 1,
    Flag = "HitboxSlider",
    Callback = function(Value)
        hitboxSize = Value
        if Value > 1 then
            VisualPart.Parent = lp.Character.HumanoidRootPart
            VisualPart.Size = Vector3.new(Value, Value, Value)
            local weld = VisualPart:FindFirstChild("Weld") or Instance.new("Weld", VisualPart)
            weld.Part0 = VisualPart; weld.Part1 = lp.Character.HumanoidRootPart
            
            spawn(function()
                while hitboxSize > 1 do
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") then
                            local mag = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if mag <= hitboxSize then
                                -- Fire event sát thương trực tiếp của game
                                game:GetService("ReplicatedStorage").Events.HitEvent:FireServer(v.Character.Humanoid)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            VisualPart.Parent = nil
        end
    end,
})

MainTab:CreateToggle({
    Name = "Fly (Screen Logic)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        flyEnabled = Value
        if Value then
            local bv = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            spawn(function()
                while flyEnabled do
                    local cam = workspace.CurrentCamera.CFrame
                    local dir = Vector3.new(0,0,0)
                    local UIS = game:GetService("UserInputService")
                    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
                    bv.Velocity = dir * flySpeed
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    CurrentValue = 50,
    Callback = function(Value) flySpeed = Value end,
})

-- TAB MISC (FIXED NO COOLDOWN & INF DASH)
MiscTab:CreateToggle({
    Name = "Infinite Dash",
    CurrentValue = false,
    Flag = "InfDash",
    Callback = function(Value)
        infDash = Value
        spawn(function()
            while infDash do
                pcall(function()
                    -- Tìm module Dash trong bộ nhớ
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" and rawget(v, "Dash") then
                            v.DashCD = 0
                            v.CanDash = true
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end,
})

MiscTab:CreateToggle({
    Name = "Skills No Cooldown",
    CurrentValue = false,
    Flag = "NoCD",
    Callback = function(Value)
        noCooldown = Value
        spawn(function()
            while noCooldown do
                pcall(function()
                    -- Quét và ép mọi biến có tên Cooldown về 0
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" then
                            if v.Cooldown then v.Cooldown = 0 end
                            if v.MaxCooldown then v.MaxCooldown = 0 end
                            if v.LastUsed then v.LastUsed = 0 end
                        end
                    end
                end)
                task.wait(0.2)
            end
        end)
    end,
})

Rayfield:Notify({
    Title = "FIXED BY ilovedog1901ilovecat5551",
    Content = "Tất cả lỗi Hitbox và Cooldown đã được xử lý!",
    Duration = 5,
    Image = 4483345998,
})
