local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "script by ilovedog1901ilovecat5551",
    LoadingTitle = "Classic Arena Hub PRO - ULTIMATE FIX",
    LoadingSubtitle = "by ilovedog1901ilovecat5551",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ArenaFix",
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
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        local tool = lp.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        local args = {[1] = "Skill", [2] = target.Character.Humanoid}
                        game:GetService("ReplicatedStorage").Events.CombatEvent:FireServer(unpack(args))
                    end
                end)
                task.wait(0.05)
            end
        end)
    end,
})

local VisualPart = Instance.new("Part")
VisualPart.Shape = Enum.PartType.Ball
VisualPart.Color = Color3.fromRGB(0, 255, 150)
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
            local weld = VisualPart:FindFirstChild("ManualWeld") or Instance.new("Weld", VisualPart)
            weld.Name = "ManualWeld"
            weld.Part0 = VisualPart
            weld.Part1 = lp.Character.HumanoidRootPart
            
            spawn(function()
                while hitboxSize > 1 do
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") then
                            local mag = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if mag <= hitboxSize then
                                local args = {[1] = "Hit", [2] = v.Character.Humanoid}
                                game:GetService("ReplicatedStorage").Events.CombatEvent:FireServer(unpack(args))
                            end
                        end
                    end
                    task.wait(0.2)
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
            bv.Name = "VipFly"
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
    Increment = 10,
    CurrentValue = flySpeed,
    Callback = function(Value) flySpeed = Value end,
})

MiscTab:CreateToggle({
    Name = "Infinite Dash",
    CurrentValue = false,
    Flag = "InfDash",
    Callback = function(Value)
        infDash = Value
        spawn(function()
            while infDash do
                pcall(function()
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" and rawget(v, "Dash") then
                            v.DashCD = 0
                            v.CanDash = true
                            v.CurrentDashCD = 0
                        end
                    end
                end)
                task.wait(0.3)
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
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" and (rawget(v, "Cooldown") or rawget(v, "CD")) then
                            v.Cooldown = 0
                            v.CD = 0
                            v.LastUsed = 0
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end,
})

Rayfield:Notify({
    Title = "FIXED BY ilovedog1901ilovecat5551",
    Content = "Hitbox, Dash và Cooldown đã được tối ưu hóa!",
    Duration = 5,
    Image = 4483345998,
})
