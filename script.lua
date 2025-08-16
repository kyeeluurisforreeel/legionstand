-- Float behind/above/left of Owner
local ownerName = getgenv().Owner or "Player"

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Local player
local localPlayer = Players.LocalPlayer

-- Find the owner player
local function getOwner()
    return Players:FindFirstChild(ownerName)
end

RunService.RenderStepped:Connect(function()
    local owner = getOwner()
    if owner and owner.Character and owner.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = owner.Character.HumanoidRootPart
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = localPlayer.Character.HumanoidRootPart
            
            -- Offset: 3 studs above, behind, and left
            local offset = CFrame.new(-3, 3, 3)
            
            -- Position relative to owner
            myHRP.CFrame = hrp.CFrame * offset
        end
    end
end)
