local utils: table = {}
local cloneref = cloneref or function(v) return v end
local Players: Players = cloneref(game:GetService('Players'))
local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'))
local lplr: Players = Players.LocalPlayer

utils.getDevice = function(): string
    if UserInputService.TouchEnabled then
        return 'mobile'
    end
    return 'pc'
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
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lplr.Character}
    return workspace:Raycast(start, dir, params)
end
utils.isAlive = function(plr: string): Players
    if plr.Character and plr.Character:FindFirstChild('Humanoid') then return plr.Character.Humanoid.Health > 0 end
	return nil
end
utils.getMaxHealth = function(plr: string): Players
    if plr.Character and plr.Character:FindFirstChild('Humanoid') then return plr.Character.Humanoid.MaxHealth end
end
utils.getServerPos = function(pos)
	return Vector3.new(math.round(pos.X) / 3, math.round(pos.Y) / 3, math.round(pos.Z) / 3)
end

return utils