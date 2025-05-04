-- [[ Services & Vars ]] --
local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local MainEvent = ReplicatedStorage:FindFirstChild("MainEvent")

-- [[ Config ]] --
local ForceHit = {
    Enabled = false,
    BlankShots = false,
    HitPart = "Head",
    Keybind = Enum.KeyCode.C,

    FOV = {
        Visible = true,
        Transparency = 1,
        Thickness = 1,
        Radius = 400,
        Color = Color3.fromRGB(0, 255, 0)
    }
}

-- [[ Drawings ]] --
local Fov = Drawing.new("Circle")
Fov.Color = ForceHit.FOV.Color
Fov.Thickness = ForceHit.FOV.Thickness
Fov.Filled = false
Fov.Transparency = ForceHit.FOV.Transparency
Fov.Radius = ForceHit.FOV.Radius

local Highlight = Instance.new("Highlight")
Highlight.Parent = game.CoreGui
Highlight.FillColor = Color3.fromRGB(0, 255, 0)
Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
Highlight.FillTransparency = 0.5
Highlight.OutlineTransparency = 0
Highlight.Enabled = false

-- [[ Functions ]] --
local function GetClosestPlayer()
    local ClosestDistance, ClosestPart, ClosestCharacter = nil, nil, nil
    local MousePosition = UserInput:GetMouseLocation()

    for _, Player in next, Players:GetPlayers() do
        if Player ~= LocalPlayer and Player.Character then
            local Character = Player.Character
            local HitPart = Character:FindFirstChild(ForceHit.HitPart)
            local Humanoid = Character:FindFirstChild("Humanoid")
            local ForceField = Character:FindFirstChildOfClass("ForceField")

            if HitPart and Humanoid and Humanoid.Health > 0 and not ForceField then
                local ScreenPosition, Visible = workspace.CurrentCamera:WorldToScreenPoint(HitPart.Position)
                if Visible then
                    local Distance = (MousePosition - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude
                    if Distance <= ForceHit.FOV.Radius and (not ClosestDistance or Distance < ClosestDistance) then
                        ClosestDistance, ClosestPart, ClosestCharacter = Distance, HitPart, Character
                    end
                end
            end
        end
    end
    return ClosestPart, ClosestCharacter
end

-- [[ Rendering ]] --
RunService.RenderStepped:Connect(function()
    if ForceHit.Enabled then
        -- Update FOV Circle Position and Visibility
        Fov.Visible = ForceHit.FOV.Visible
        Fov.Position = UserInput:GetMouseLocation()
        Fov.Radius = ForceHit.FOV.Radius

        -- Update Player Highlighting
        local ClosestPart, ClosestCharacter = GetClosestPlayer()
        if ClosestPart then
            Highlight.Adornee = ClosestCharacter
            Highlight.Enabled = true
        else
            Highlight.Enabled = false
        end
    else
        Fov.Visible = false
        Highlight.Enabled = false
    end
end)

-- [[ Keybind Handling ]] --
UserInput.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == ForceHit.Keybind then
        ForceHit.Enabled = not ForceHit.Enabled
        print("ForceHit " .. (ForceHit.Enabled and "enabled" or "disabled"))
    end
end)

-- Return ForceHit table so it can be accessed in other scripts
return ForceHit
