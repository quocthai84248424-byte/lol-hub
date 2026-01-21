_G.PlayerName = NamePlayer 
game:GetService("RunService").Stepped:Connect(function()
if game.Players:FindFirstChild(_G.PlayerName) then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[_G.PlayerName].Character.HumanoidRootPart.CFrame - Vector3.new(0,0,(10 - 5))
end
end)
