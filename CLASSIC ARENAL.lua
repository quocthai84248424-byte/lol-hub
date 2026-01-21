local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "script by ilovedog1901ilovecat5551",
    LoadingTitle = "Classic Arena Hub Pro",
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

local function AntiBanSystem()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            return nil
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end
pcall(AntiBanSystem)

local MainTab = Window:CreateTab("Main", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483345998)

MainTab:CreateInput({
    Name = "Target Player Name",
    PlaceholderText = "Nhập tên người muốn kill...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        targetPlayer = Text
    end,
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
                        lp.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5)
                        if lp.Character:FindFirstChildOfClass("Tool") then
                            lp.Character:FindFirstChildOfClass("Tool"):Activate()
                        end
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
VisualPart.Color = Color3.fromRGB(255, 0, 0)
VisualPart.Transparency = 0.8
VisualPart.CanCollide = false
VisualPart.Anchored = false

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
            weld.Part0 = VisualPart
            weld.Part1 = lp.Character.HumanoidRootPart
            
            spawn(function()
                while hitboxSize > 1 do
                    for _, v in pairs(game.Players:GetPlayers()) do
                        if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") then
                            local dist = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= hitboxSize then
                                game:GetService("ReplicatedStorage").Events.HitEvent:FireServer(v.Character.Humanoid)
                                game:GetService("ReplicatedStorage").Events.Skill:FireServer("Attack", v.Character.Humanoid)
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
            bv.Name = "VipFly"
            spawn(function()
                while flyEnabled do
                    local cam = workspace.CurrentCamera.CFrame
                    local move = Vector3.new(0,0,0)
                    local UIS = game:GetService("UserInputService")
                    if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
                    bv.Velocity = move * flySpeed
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
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
    end,
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
                        if type(v) == "table" and rawget(v, "DashCD") then
                            v.DashCD = 0
                            v.CanDash = true
                        end
                    end
                    local dashScript = lp.Character:FindFirstChild("DashHandler") or lp.PlayerScripts:FindFirstChild("DashHandler")
                    if dashScript then
                        getsenv(dashScript).DashCD = 0
                        getsenv(dashScript).CanDash = true
                    end
                end)
                task.wait()
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
                        if type(v) == "table" then
                            if rawget(v, "Cooldown") then v.Cooldown = 0 end
                            if rawget(v, "MaxCooldown") then v.MaxCooldown = 0 end
                            if rawget(v, "LastUsed") then v.LastUsed = 0 end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end,
})

Rayfield:Notify({
    Title = "Classic Arena Hub Pro",
    Content = "Script by ilovedog1901ilovecat5551 Loaded!",
    Duration = 5,
    Image = 4483345998,
})
