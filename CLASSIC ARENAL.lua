local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "script by ilovedog1901ilovecat5551",
    LoadingTitle = "Classic Arena Hub Pro",
    LoadingSubtitle = "by ilovedog1901ilovecat5551",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ArenaHub",
        FileName = "Config"
    },
    KeySystem = false
})

local AntiCheat = true
spawn(function()
    while AntiCheat do
        local check = game.Players.LocalPlayer:FindFirstChild("Character")
        if check then
            if check:FindFirstChild("Humanoid") then
                check.Humanoid.PlatformStand = false
            end
        end
        task.wait(0.1)
    end
end)

local MainTab = Window:CreateTab("Main", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483345998)

local targetPlayer = ""
local autoKillEnabled = false
local hitboxSize = 1
local flyEnabled = false
local flySpeed = 50
local infDash = false
local noCooldown = false

MainTab:CreateInput({
    Name = "Target Player Name",
    PlaceholderText = "Enter Name...",
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
        if Value then
            spawn(function()
                while autoKillEnabled do
                    pcall(function()
                        local target = game.Players:FindFirstChild(targetPlayer)
                        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            
                            local args = { [1] = "Attack" }
                            game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                            game:GetService("ReplicatedStorage").Events.Skill:FireServer(unpack(args))
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "Hitbox Size (Range)",
    Range = {1, 150},
    Increment = 1,
    Suffix = "Part Range",
    CurrentValue = 1,
    Flag = "HitboxSlider",
    Callback = function(Value)
        hitboxSize = Value
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(Value, Value, Value)
                v.Character.HumanoidRootPart.Transparency = 0.7
                v.Character.HumanoidRootPart.CanCollide = false
            end
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
            local camera = workspace.CurrentCamera
            local lp = game.Players.LocalPlayer
            local hrp = lp.Character.HumanoidRootPart
            
            spawn(function()
                while flyEnabled do
                    local moveDir = Vector3.new(0,0,0)
                    local userInput = game:GetService("UserInputService")
                    
                    if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
                    if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
                    if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
                    if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
                    
                    hrp.Velocity = moveDir * flySpeed
                    task.wait()
                end
                hrp.Velocity = Vector3.new(0,0,0)
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
                    local data = game.Players.LocalPlayer.Character:FindFirstChild("DashHandler")
                    if data then
                        debug.setconstant(data.Dash, 5, 0)
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
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "table" and rawget(v, "Cooldown") then
                            v.Cooldown = 0
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end,
})

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "By ilovedog1901ilovecat5551",
    Duration = 5,
    Image = 4483345998,
})
