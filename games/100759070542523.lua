--[[
local args = {
    [1] = {
        ["Attack"] = 2;
        ["Targets"] = {
            [1] = workspace:WaitForChild("Leo77935", 9e9):WaitForChild("Humanoid", 9e9);
        };
        ["Weapon"] = "Sword";
    };
}

game:GetService("ReplicatedStorage"):WaitForChild("Packages", 9e9):WaitForChild("Knit", 9e9):WaitForChild("Services", 9e9):WaitForChild("WeaponService", 9e9):WaitForChild("RE", 9e9):WaitForChild("Melee", 9e9):FireServer(unpack(args))
]]

if not isfolder('polaris') then return nil end

local library: table = loadfile('polaris/libraries/interface.lua')()
local utils: table = loadfile('polaris/libraries/utils.lua')()
local whitelist: table = loadfile('polaris/libraries/whitelist.lua')()
local connections: table = {}
local RBXScriptConnections: table = {}

local cloneref = cloneref or function(v) return v end
local Players: Players = cloneref(game:GetService('Players'))
local Lighting: Lighting = cloneref(game:GetService("Lighting"))
local ReplicatedStorage: ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'))
local RunService: RunService = cloneref(game:GetService('RunService'))
local TweenService: TweenService = cloneref(game:GetService('TweenService'))
local CollectionService: CollectionService = cloneref(game:GetService("CollectionService"))
local lplr: Players = Players.LocalPlayer

repeat task.wait() until game:IsLoaded() and utils.isAlive(lplr)
if utils.getDevice == 'mobile' then return lplr:Kick('no mobile support :) - stav') end

local user: string = lplr.Name
local HurtTime: string = 0
local release: string = 'rewrite'

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

Combat = library.NewWindow('Combat')
Player = library.NewWindow('Player')
Motion = library.NewWindow('Motion')
Visuals = library.NewWindow('Visuals')
Misc = library.NewWindow('Misc')
Exploit = library.NewWindow('Exploit')
Legit = library.NewWindow('Legit')

whitelist:kill(library)
return lplr:Kick('100 gorillas vs solara support :scream:')