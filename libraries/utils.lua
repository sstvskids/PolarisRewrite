local utils: table = {}
local cloneref = cloneref or function(v) return v end
local Players: Players = cloneref(game:GetService('Players'))
local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'))
local lplr: Players = Players.LocalPlayer

utils.getDevice = function()
    if UserInputService.TouchEnabled then return 'mobile' end return 'pc'
end
utils.onGround = function()
    return lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air
end
utils.isMoving = function()
    if utils.getDevice() == 'mobile' then
        return lplr.Character.Humanoid.MoveDirection ~= Vector3.zero
    end
    return UserInputService:IsKeyDown("W") or UserInputService:IsKeyDown("A") or UserInputService:IsKeyDown("S") or UserInputService:IsKeyDown("D")
end
utils.newRaycast = function(start, dir)
    return workspace:Raycast(start, dir, Enum.RaycastFilterType.Exclude, {lplr.Character, workspace.CurrentCamera})
end
utils.isAlive = function(plr: string)
    if plr.Character and plr.Character:FindFirstChild('Humanoid') then return plr.Character.Humanoid.Health > 0 end
	return nil
end

return utils