local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7Lib/UI/main/Library.lua"))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 250, 0, 80)
MainButton.Position = UDim2.new(0.5, -125, 0.1, 0)
MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextColor3 = Color3.fromRGB(0, 0, 0)
MainButton.TextSize = 20
MainButton.Text = "auto back stab OFF"
MainButton.BorderSizePixel = 2
MainButton.Parent = ScreenGui

local active = false

MainButton.MouseButton1Click:Connect(function()
    active = not active
    if active then
        MainButton.Text = "auto back stab ON"
    else
        MainButton.Text = "auto back stab OFF"
    end
end)

local function getKiller()
    for _, p in pairs(Players:GetPlayers()) do
        if p.TeamColor == BrickColor.new("Bright red") or p:FindFirstChild("KillerTag") then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                return p.Character
            end
        end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not active then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local killer = getKiller()
    if killer and killer:FindFirstChild("HumanoidRootPart") then
        local distance = (character.HumanoidRootPart.Position - killer.HumanoidRootPart.Position).Magnitude
        
        if distance <= 10 then
            local backPos = killer.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            character.HumanoidRootPart.CFrame = CFrame.lookAt(backPos.Position, killer.HumanoidRootPart.Position)
            
            local skill1 = character:FindFirstChild("Skill1") or LocalPlayer.Backpack:FindFirstChild("Skill1")
            if skill1 then
                skill1.Parent = character
                skill1:Activate()
            end
        end
    end
end)

