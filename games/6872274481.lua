if not isfolder('polaris') then return nil end

local library: table = loadfile('polaris/libraries/interface.lua')()
local utils: table = loadfile('polaris/libraries/utils.lua')()
local weapons: table = loadfile('polaris/libraries/weapons.lua')()
local connections: table = {}

local cloneref = cloneref or function(v) return v end
local Players: Players = cloneref(game:GetService('Players'))
local Lighting: Lighting = cloneref(game:GetService("Lighting"))
local ReplicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'))
local RunService: RunService = cloneref(game:GetService('RunService'))
local TweenService: TweenService = cloneref(game:GetService('TweenService'))
local CollectionService: CollectionService = cloneref(game:GetService("CollectionService"))
local lplr: Players = Players.LocalPlayer
local inventory = workspace[lplr.Name].InventoryFolder.Value

local user: string = lplr.Name
local HurtTime: string = 0
local release: string = 'rewrite'

repeat task.wait() until game:IsLoaded() and lplr.Character

if not isfile("polaris/configs/"..game.PlaceId..".json") then library.saveConfig() end
library.loadConfig()

lplr.CharacterAdded:Connect(function(char)
    repeat task.wait(1) until char ~= nil
	local Character = char
	local Humanoid = char.Humanoid
	local PrimaryPart = char.PrimaryPart
	local Camera = workspace.Camera
	local CurrentCamera = workspace.CurrentCamera

	Character.Archivable = true

	for i,v in next, connections do
		task.spawn(function() v(char) end)
	end
end)

table.insert(connections, function(char)
	inventory = workspace[lplr.Name].InventoryFolder.Value
end)

Combat = library.NewWindow('Combat')
Player = library.NewWindow('Player')
Motion = library.NewWindow('Motion')
Visuals = library.NewWindow('Visuals')
Misc = library.NewWindow('Misc')
Exploit = library.NewWindow('Exploit')
Legit = library.NewWindow('Legit')

local _NetManaged: ReplicatedStorage = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
local blockenginemanaged: ReplicatedStorage = ReplicatedStorage.rbxts_include.node_modules:WaitForChild("@easy-games"):WaitForChild("block-engine").node_modules:WaitForChild("@rbxts").net.out:WaitForChild("_NetManaged")

local function getRemote(name)
    local remote
    task.spawn(function()
        for i,v in pairs(game:GetDescendants()) do
            if v.Name == name then
                remote = v
                break
            end
        end
    end)
    return remote
end

local remotes: table = {
    SetInvItem = getRemote("SetInvItem"),
    SwordHit = getRemote("SwordHit"),
}

local function hasItem(item)
    if inventory:FindFirstChild(item) then return true, 1 end
    return false
end

local function getBestWeapon()
    local bestSwordMeta, bestSword = 0, nil
    for i, sword in ipairs(weapons) do
        local name, meta = sword[1], sword[2]
        if hasItem(name) then
            if meta > bestSwordMeta and hasItem(name) then
                bestSword = name
                bestSwordMeta = meta
            end
        end
    end
    return inventory:FindFirstChild(bestSword)
end

local function getNearestPlayer(range)
    local nearestDist, nearest = math.huge
	for i,v in pairs(Players:GetPlayers()) do
		pcall(function()
			if v == lplr or v.Team == lplr.Team then return end
			if v.Character.Humanoid.health > 0 and (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude < nearestDist and (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude <= range then
				nearest = v
				nearestDist = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
			end
		end)
	end
	return nearest
end

local function spoofHand(item)
	if hasItem(item) then
		remotes.SetInvItem:InvokeServer({
			["hand"] = inventory:WaitForChild(item)
		})
	end
end

local viewmodel = workspace.Camera.Viewmodel.RightHand.RightWrist
local weld = viewmodel.C0
local oldweld = viewmodel.C0

table.insert(connections, Aura)
Aura = Combat.NewButton({
    Name = "Aura",
    Function = function(calling)
        if calling then
            task.spawn(function()
                connections.Aura = RunService.Heartbeat:Connect(function()
                    local nearest = getNearestPlayer(18)
                    if nearest ~= nil then
                        local nearestCharacter = nearest.Character
                        local nearestPrimaryPartPosition = nearestCharacter.PrimaryPart.Position
                        local selfPrimaryPartPosition = lplr.Character.PrimaryPart.Position
                        local weapon = getBestWeapon()
                        spoofHand(weapon.Name)
                    end

                    task.spawn(function()
                        remotes.SwordHit:FireServer({
                            chargedAttack = {
                                chargeRatio = 0
                            },
                            entityInstance = nearestCharacter,
                            validate = {
                                raycast = {
                                    cameraPosition = workspace.CurrentCamera,
                                    cursorDirection = CFrame.LookVector
                                },
                                targetPosition = {
                                    value = nearestPrimaryPartPosition
                                },
                                selfPosition = {
                                    value = selfPrimaryPartPosition
                                },
                            },
                            weapon = weapon
                        })
                    end)
                end)
            end)
        else
            pcall(function()
                connections.Aura:Disconnect()
            end)
        end
    end
})