if not isfolder('polaris') then return nil end

local library: table = loadfile('polaris/libraries/interface.lua')()
local utils: table = loadfile('polaris/libraries/utils.lua')()
local weapons: table = loadfile('polaris/libraries/weapons.lua')()
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
local inventory = workspace[lplr.Name].InventoryFolder.Value

local user: string = lplr.Name
local HurtTime: string = 0
local release: string = 'rewrite'

repeat task.wait() until game:IsLoaded() and lplr.Character
if utils.getDevice == 'mobile' then return lplr:Kick('no mobile support :) - stav') end

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

local lastHPHurt = 100
task.spawn(function()
	repeat task.wait()
		if (lplr.Character.Humanoid.Health < lastHPHurt) then
			HurtTime = 0
		end

		lastHPHurt = lplr.Character.Humanoid.Health
		HurtTime += 1
	until false
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
	Chest = getRemote("Inventory/ChestGetItem")
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

local function placeBlock(pos, block)
	blockenginemanaged.PlaceBlock:InvokeServer({
		['blockType'] = block,
		['position'] = Vector3.new(pos.X / 3,pos.Y / 3,pos.Z / 3),
		['blockData'] = 0
	})
end

local function getWool()
	for i,v in pairs(inventory:GetChildren()) do if v.Name:lower():find("wool") then return v.Name end end
end

local chests: table = {}
for i,v in pairs(workspace:GetChildren()) do
	if v.Name == 'chest' then
		table.insert(chests, v)
	end
end

local viewmodel = workspace.Camera.Viewmodel.RightHand.RightWrist
local weld = viewmodel.C0
local oldweld = viewmodel.C0

local animRunning: boolean = true
local auraAnimations: table = {
	["Smooth"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(54), math.rad(33)), Timer = 0.16},
	},
	["Spin"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-145), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-180), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-220), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-270), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-310), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-360), math.rad(0), math.rad(0)), Timer = 0.05},
	},
	["Reverse Spin"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(145), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(180), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(220), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(270), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(310), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(360), math.rad(0), math.rad(0)), Timer = 0.05},
	},
	["Swoosh"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(94), math.rad(33)), Timer = 0.16},
	},
	["Swang"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-199), math.rad(74), math.rad(43)), Timer = 0.16},
	},
	["Zoom"] = {
		{CFrame = CFrame.new(0.69, -2, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -0.1, -1) * CFrame.Angles(math.rad(-179), math.rad(94), math.rad(33)), Timer = 0.16},
	},
	["Classic"] = {
		{CFrame = CFrame.new(0.69, -1, 0.1) * CFrame.Angles(math.rad(-16), math.rad(12), math.rad(-21)), Timer = 0.1},
		{CFrame = CFrame.new(0.69, -2, 0.1) * CFrame.Angles(math.rad(-72), math.rad(21), math.rad(-35)), Timer = 0.07},
		{CFrame = CFrame.new(0.69, -0.6, 0.1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Timer = 0.07},
	},
	["Other Spin"] = {
		{CFrame = CFrame.new(0.69, -2, 0.1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -0.1, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(180)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -0.1, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(270)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -0.1, -1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(360)), Timer = 0.1},
	},
	["Corrupt"] = {
		{CFrame = CFrame.new(0.69, -2, 0.1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(90)), Timer = 0.1},
		{CFrame = CFrame.new(0.69, -2, 0.1) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(60)), Timer = 0.3},
	},
	["OldAstralAnim"] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(290)), Time = 0.2},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.2}
	},
	["Test"] = {
		{CFrame = CFrame.new(1, -1, 2) * CFrame.Angles(math.rad(295), math.rad(55), math.rad(220)), Time = 0.1},
		{CFrame = CFrame.new(-1, 1, -2.2) * CFrame.Angles(math.rad(200), math.rad(60), math.rad(1)), Time = 0.1},
		{CFrame = CFrame.new(0.5, -0.5, 1) * CFrame.Angles(math.rad(250), math.rad(40), math.rad(180)), Time = 0.1},
		{CFrame = CFrame.new(-0.5, 0.5, -1.1) * CFrame.Angles(math.rad(160), math.rad(45), math.rad(5)), Time = 0.1},
		{CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0)), Time = 0.1}
	},
}
local funAnimations: table = {
	PLAYER_VACUUM_SUCK = "rbxassetid://9671620809",
	WINTER_BOSS_SPAWN = "rbxassetid://11843861791",
	GLUE_TRAP_FLYING = "rbxassetid://11466075174",
	VOID_DRAGON_TRANSFORM = "rbxassetid://10967424821",
	SIT_ON_DODO_BIRD = "http://www.roblox.com/asset/?id=2506281703",
	DODO_BIRD_FALL = "rbxassetid://7617326953",
	SWORD_SWING = "rbxassetid://7234367412",
}

local animAuraTab: table = {}
for i,v in pairs(auraAnimations) do table.insert(animAuraTab, i) end
local targetInfo = Instance.new("TextLabel", library.ScreenGui)
table.insert(RBXScriptConnections, 'Aura')
Aura = Combat.NewButton({
    Name = "Aura",
    Function = function(calling)
        if calling then
            RBXScriptConnections['Aura'] = RunService.Heartbeat:Connect(function()
                local nearest = getNearestPlayer(18)
                if nearest ~= nil then
                    local weapon = getBestWeapon()
                    spoofHand(weapon.Name)

                    task.spawn(function()
                        remotes.SwordHit:FireServer({
                            chargedAttack = {
                                chargeRatio = 0
                            },
                            entityInstance = nearest.Character,
                            validate = {
                                raycast = {
                                    	cameraPosition = nearest.Character.PrimaryPart.Position,
                                        cursorDirection = (nearest.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Unit
                                    },
                                    targetPosition = {
                                        value = nearest.Character.PrimaryPart.Position + nearest.Character.PrimaryPart.MoveDirection
                                    },
                                    selfPosition = {
                                        value = lplr.Character.PrimaryPart.Position
                                    },
                                },
                            weapon = weapon
                        })
                    end)
                end

                task.spawn(function()
                    if nearest ~= nil then
                        pcall(function()
                            local animation = auraAnimations[auraAnimation.Option]
                            local allTime = 0
                            task.spawn(function()
                                if CustomAnimation.Enabled then
                                    animRunning = true
                                    for i,v in pairs(animation) do allTime += v.Timer end
                                    for i,v in pairs(animation) do
                                        local tween = TweenService:Create(viewmodel, TweenInfo.new(v.Timer), {C0 = oldweld * v.CFrame})
                                        tween:Play()
                                        task.wait(v.Timer - 0)
                                    end
                                    animRunning = false
                                    game.TweenService:Create(viewmodel, TweenInfo.new(1), {C0 = oldweld}):Play()
                                end
                            end)
                        end)
                    end
                end)

                task.spawn(function()
                    if nearest ~= nil then
                        local isWinning = function() return nearest.Character.Humanoid.Health > lplr.Character.Humanoid.Health end
                        if targetInfo ~= nil then
                            targetInfo = Instance.new('TextLabel', library.ScreenGui)
                        end

                        if TargetHudMode.Option == "Basic" then
                            pcall(function()
                                targetInfo.Size = UDim2.fromScale(.12, .05)
                                targetInfo.BackgroundColor3 = Color3.fromRGB(25,25,25)
                                targetInfo.BorderSizePixel = 0
                                targetInfo.AnchorPoint = Vector2.new(0.5,0.5)
                                targetInfo.Position = UDim2.fromScale(0.6,0.5)
                                targetInfo.TextColor3 = Color3.fromRGB(255,255,255)
                                targetInfo.Text = "  "..nearest.DisplayName.. " - IsWinning: ".. tostring(isWinning())
                                targetInfo.TextXAlignment = Enum.TextXAlignment.Left

                                local hp = Instance.new("Frame", targetInfo)
                                hp.Position = UDim2.fromScale(0, .9)
                                hp.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                                hp.BorderSizePixel = 0
        
                                TweenService:Create(hp,TweenInfo.new(1),{
                                    Size = UDim2.fromScale(0.01 * nearest.Character.Humanoid.Health,0.1)
                                }):Play()
                            end)
                        elseif TargetHudMode.Option == "Basic2" then
                            pcall(function()
                                TweenService:Create(targetInfo,TweenInfo.new(1),{
                                    Size = UDim2.fromScale(0.001 * nearest.Character.Humanoid.Health,0.04)
                                }):Play()
                                targetInfo.BackgroundColor3 = library.Color
                                targetInfo.BorderSizePixel = 0
                                targetInfo.AnchorPoint = Vector2.new(0.5,0.5)
                                targetInfo.Position = UDim2.fromScale(0.6,0.5)
                                targetInfo.TextColor3 = Color3.fromRGB(255,255,255)
                                targetInfo.Text = "  "..nearest.DisplayName
                                --targetInfo.TextScaled = true
                                targetInfo.TextXAlignment = Enum.TextXAlignment.Left
                            end)	
                        end
                    else
                        pcall(function()
                            targetInfo:Remove()
                            targetInfo = nil
                        end)
                    end
                    task.wait()
                end)
            end)
        else
            pcall(function()
                RBXScriptConnections['Aura']:Disconnect()
            end)
        end
    end
})
auraAnimation = Aura.NewPicker({
	Name = "Animations",
	Options = animAuraTab
})
CustomAnimation = Aura.NewToggle({
	Name = "CustomAnimation"
})
TargetHudMode = Aura.NewPicker({
	Name = "TargetHud",
	Options = {"None", "Basic", "Basic2"}
})

table.insert(connections, function(char)
	viewmodel = workspace.Camera.Viewmodel.RightHand.RightWrist
end)

table.insert(RBXScriptConnections, 'Speed')
local ticks = 0
Speed = Motion.NewButton({
    Name = "Speed",
    Function = function(calling)
        if calling then
            task.spawn(function()
                RBXScriptConnections['Speed'] = RunService.Heartbeat:Connect(function()
                    ticks += 1
                    local dir = lplr.Character.Humanoid.MoveDirection
                    local velo = lplr.Character.PrimaryPart.Velocity
                    local speed = lplr.Character:GetAttribute("SpeedBoost") and 0.18 or 0.021
					if DamageBoost.Enabled then
						if (HurtTime <= 50) then
							lplr.Character.PrimaryPart.CFrame += (0.25 * dir)
						end
					end

                    lplr.Character.PrimaryPart.CFrame += (speed * dir)
                end)
            end)
        else
            pcall(function()
                RBXScriptConnections['Speed']:Disconnect()
            end)
        end
    end
})
DamageBoost = Speed.NewToggle({
	Name = "DamageBoost"
})

table.insert(RBXScriptConnections, 'Fly')
Fly = Motion.NewButton({
    Name = "Fly",
    Keybind = Enum.KeyCode.R,
    Function = function(calling)
        if calling then
            RBXScriptConnections['Fly'] = RunService.Heartbeat:Connect(function()
                local velo = lplr.Character.PrimaryPart.Velocity
                lplr.Character.PrimaryPart.Velocity = Vector3.new(velo.X, 2.03, velo.Z)

                if UserInputService:IsKeyDown("Space") then
					lplr.Character.PrimaryPart.Velocity = Vector3.new(velo.X, 44, velo.Z)
				end
				if UserInputService:IsKeyDown("LeftShift") then
					lplr.Character.PrimaryPart.Velocity = Vector3.new(velo.X, -44, velo.Z)
				end
			end)
        else
            pcall(function()
                RBXScriptConnections['Fly']:Disconnect()
            end)
        end
    end
})

table.insert(RBXScriptConnections, 'NoFall')
NoFall = Misc.NewButton({
	Name = "NoFall",
	Function = function(callback)
		if callback then
			RBXScriptConnections['Fly'] = RunService.Heartbeat:Connect(function()
                if lplr.Character.PrimaryPart.Velocity.Y < -70 and not utils.onGround() then
                    task.wait()
                    lplr.Character.PrimaryPart.Velocity = Vector3.new(lplr.Character.PrimaryPart.Velocity.X, -10, lplr.Character.PrimaryPart.Velocity.Z)
                end
			end)
		end
	end,
})

local ESPAssets: table = {
	Sus = "http://www.roblox.com/asset/?id=9145833727",
	Damc = "rbxassetid://16930990336",
	Springs = "rbxassetid://16930908008",
	Xylex = "rbxassetid://16930961099",
	Alsploit = "http://www.roblox.com/asset/?id=12772788813",
	Matrix = "http://www.roblox.com/asset/?id=1412150157",
	Covid = "http://www.roblox.com/asset/?id=8518879821",
	Space = "http://www.roblox.com/asset/?id=2609221356",
	Windows = "http://www.roblox.com/asset/?id=472001646",
	Trol = "http://www.roblox.com/asset/?id=6403436054",
	Cat = "http://www.roblox.com/asset/?id=14841615129",
	Furry = "http://www.roblox.com/asset/?id=14831068996",
}
local stylesofskybox: table = {}
for i,v in ESPAssets do table.insert(stylesofskybox, i) end
table.insert(RBXScriptConnections, 'ESP')
ImageESP = Visuals.NewButton({
	Name = "ImageESP",
	Function = function(callback)
		if callback then
			task.spawn(function()
                RBXScriptConnections['ESP'] = RunService.Heartbeat:Connect(function()
					pcall(function()
						for i,v in pairs(Players:GetPlayers()) do
							if not (v.Character.PrimaryPart:FindFirstChild("nein")) then
								if v ~= lplr and v.Team ~= lplr.Team and ImageESP.Enabled then
									local e = Instance.new("BillboardGui", v.Character.PrimaryPart)

									local image = Instance.new("ImageLabel",e)
									image.Size = UDim2.fromScale(10,10)
									image.Position = UDim2.fromScale(-3,-4)
									image.Image = ESPAssets[ImageESPStyle.Option]
									image.BackgroundTransparency = 1

									e.Size = UDim2.fromScale(0.5,0.5)
									e.AlwaysOnTop = true
									e.Name = "nein"
								end
							end
						end
					end)
					task.wait()
				end)
			end)
		else
            task.spawn(function()
                RBXScriptConnections['ESP']:Disconnect()
            end)
			pcall(function()
				for i,v in pairs(Players:GetPlayers()) do
					if (v.Character.PrimaryPart:FindFirstChild("nein")) then
						if v ~= lplr then
							v.Character.PrimaryPart:FindFirstChild("nein"):Destroy()
						end
					end
				end
			end)
		end
	end,
})
ImageESPStyle = ImageESP.NewPicker({
	Name = "Style",
	Options = stylesofskybox
})

BlockingAnimation = Visuals.NewButton({
	Name = "BlockingAnimation",
	Function = function(callback)
		if callback then
			lplr:GetMouse().Button2Down:Connect(function()
				viewmodel.C0 = oldweld * CFrame.new(0.7, -0.4, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-50))
			end)
			lplr:GetMouse().Button2Up:Connect(function()
				viewmodel.C0 = oldweld
			end)
		end
	end,
})

local oldFOV = workspace.CurrentCamera.FieldOfView
table.insert(RBXScriptConnections, 'Camera')
Camera = Visuals.NewButton({
	Name = "FOVChanger",
	Function = function(callback)
		if callback then
			RBXScriptConnections['Camera'] = RunService.Heartbeat:Connect(function()
				workspace.CurrentCamera.FieldOfView = 120
			end)
		else
			RBXScriptConnections['Camera']:Disconnect()
			workspace.CurrentCamera.FieldOfView = oldFOV
		end
	end,
})

table.insert(RBXScriptConnections, 'Stealer')
Stealer = Player.NewButton({
	Name = "Stealer",
	Function = function(callback)
		if callback then
			RBXScriptConnections['Stealer'] = RunService.Heartbeat:Connect(function()
				task.spawn(function()
					for i,v in pairs(chests) do
						local Mag = (v.Position - lplr.Character.PrimaryPart.Position).Magnitude
						if Mag <= 30 then
							for _, item in pairs(v.ChestFolderValue.Value:GetChildren()) do
								if item:IsA("Accessory") then
									remotes.Chest:InvokeServer(v.ChestFolderValue.Value, item)
								end
							end
						end
					end
				end)
			end)
		else
			RBXScriptConnections['Stealer']:Disconnect()
		end
	end,
})

LongJump = Motion.NewButton({
	Name = "LongJump",
	Keybind = Enum.KeyCode.J,
	Function = function(callback)
		if callback then
			if LongJumpMethod.Option == "Boost" then
				TweenService:Create(lplr.Character.PrimaryPart, TweenInfo.new(2.2), {
					CFrame = lplr.Character.PrimaryPart.CFrame + lplr.Character.PrimaryPart.CFrame.LookVector * 50 + Vector3.new(0, 5, 0)
				}):Play()
				task.delay(0.8, function()
					LongJump.ToggleButton(false)
				end)
			elseif LongJumpMethod.Option == "Gravity" then
				workspace.Gravity = 5
				task.delay(0.01, function()
					lplr.Character.Humanoid:ChangeState(3)
				end)
			elseif LongJumpMethod.Option == "Yuzi" then
				ReplicatedStorage:FindFirstChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events").useAbility:FireServer("dash")
				workspace.Gravity = 0
				if utils.onGround() then
					for i = 1, 120 do
						lplr.Character.PrimaryPart.CFrame += lplr.Character.PrimaryPart.CFrame.LookVector * 2
						task.wait()
					end
					workspace.Gravity = 196.2
				end
			end
		else
			workspace.Gravity = 196.2
			task.delay(0.1, function()
				lplr.Character.PrimaryPart.Velocity = Vector3.zero
			end)
		end
	end,
})
LongJumpMethod = LongJump.NewPicker({
	Name = "Mode",
	Options = {"Boost", "Gravity", "Yuzi"}
})

table.insert(RBXScriptConnections, 'Scaffold')
Scaffold = Misc.NewButton({
	["Name"] = "Scaffold",
	["Function"] = function(callback)
		if callback then
			RBXScriptConnections['Scaffold'] = RunService.Heartbeat:Connect(function()
				local block = getWool()
				if game.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					local velo = lplr.Character.PrimaryPart.Velocity
					lplr.Character.PrimaryPart.Velocity = Vector3.new(velo.X,25,velo.Z)
					for i = 1, 4 do
						placeBlock((lplr.Character.PrimaryPart.CFrame + lplr.Character.PrimaryPart.CFrame.LookVector * 1) - Vector3.new(0,i + 4.5 * 1.4,0), block)
						placeBlock((lplr.Character.PrimaryPart.CFrame + lplr.Character.PrimaryPart.CFrame.LookVector) - Vector3.new(0,i + 4.5 * 1.1,0), block)
						placeBlock((lplr.Character.PrimaryPart.CFrame + lplr.Character.PrimaryPart.CFrame.LookVector / 1.1) - Vector3.new(0,i + 4.5 / 1.1,0), block)
						task.wait()
					end
				end
				if ScaffoldMode1.Option == "Normal" then
					if not Scaffold.Enabled then return end
					placeBlock((lplr.Character.PrimaryPart.CFrame + lplr.Character.PrimaryPart.CFrame.LookVector * 0.5) - Vector3.new(0,4.5,0),block)
				elseif ScaffoldMode1.Option == "Expand" then
					for i = 1, 8 do
						if not Scaffold.Enabled then return end
						placeBlock((lplr.Character.PrimaryPart.CFrame + lplr.Character.PrimaryPart.CFrame.LookVector * i) - Vector3.new(0,4.5,0),block)
						task.wait(0.01)
					end
				elseif ScaffoldMode1.Option == "Expand2" then
					for i = 1, 16 do
						if not Scaffold.Enabled then return end
						placeBlock((lplr.Character.PrimaryPart.CFrame + lplr.Character.PrimaryPart.CFrame.LookVector * i) - Vector3.new(0,4.5,0),block)
						task.wait(0.01)
					end
				end
			end)
		else
			RBXScriptConnections['Scaffold']:Disconnect()
		end
	end,
})
ScaffoldMode1 = Scaffold.NewPicker({
	Name = "Place Mode",
	Options = {"Normal", "Expand", "Expand2"}
})

table.insert(RBXScriptConnections, 'AirJump')
AirJump = Motion.NewButton({
	Name = "AirJump",
	Keybind = Enum.KeyCode.K,
	Function = function(callback)
		if callback then
			RBXScriptConnections['AirJump'] = UserInputService.InputBegan:Connect(function(k,g)
				if g then return end
				if k == nil then return end
				if k.KeyCode == Enum.KeyCode.Space then
					lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		else
			RBXScriptConnections['AirJump']:Disconnect()
		end
	end,
})

-- uninject FULLY uninjects Polaris this time
Uninject = Misc.NewButton({
	Name = "Uninject",
	Function = function(callback)
		if callback then
            task.spawn(function()
                Uninject.ToggleButton(false)
                library:uninject()
            end)
		end
	end,
})