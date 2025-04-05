local library = {}
local config = {
	Buttons = {},
	Toggles = {},
	Options = {},
	Keybinds = {}
}

local cloneref = cloneref or function(v) return v end
local Players: Players = cloneref(game:GetService('Players'))
local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'))
local TweenService: TweenService = cloneref(game:GetService('TweenService'))
local HttpService: HttpService = cloneref(game:GetService('HttpService'))
local lplr = Players.LocalPlayer
local PlayerGui = lplr.PlayerGui

local cfgpath: string = "polaris/configs/"..game.PlaceId..".json"
local cansave = true
library.saveConfig = function()
	if not cansave then return nil end
	local encrypt = HttpService:JSONEncode(config)
	if isfile(cfgpath) then
		delfile(cfgpath)
	end
	writefile(cfgpath, encrypt)
end

library.loadConfig = function()
	local decrypt = HttpService:JSONDecode(readfile(cfgpath))
	config = decrypt
end

library.WindowCount = 0
library.Color = Color3.fromRGB(188, 106, 255)
library.KeyBind = Enum.KeyCode.RightShift
library.Modules = {}
library.Modules.Rotations = false

library.ScreenGui = Instance.new("ScreenGui", PlayerGui)
library.ScreenGui.ResetOnSpawn = false

local cmdBar = Instance.new("TextBox",library.ScreenGui)
cmdBar.Position = UDim2.fromScale(0,0)
cmdBar.BorderSizePixel = 0
cmdBar.Size = UDim2.fromScale(1,0.05)
cmdBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
cmdBar.TextSize = 12
cmdBar.TextColor3 = Color3.fromRGB(255,255,255)
cmdBar.ClearTextOnFocus = false
cmdBar.Text = "Command Bar"

UserInputService.InputBegan:Connect(function(key,gpe)
	if key.KeyCode == library.KeyBind then
		cmdBar.Visible = not cmdBar.Visible
	end
end)

local arrayFrame = Instance.new("Frame",library.ScreenGui)
arrayFrame.Size = UDim2.fromScale(0.3,1)
arrayFrame.Position = UDim2.fromScale(0.7,0)
arrayFrame.BackgroundTransparency = 1
local sort = Instance.new("UIListLayout", arrayFrame)
sort.SortOrder = Enum.SortOrder.LayoutOrder

local arrayStuff = {}
local id = "http://www.roblox.com/asset/?id=7498352732"

local arrayListFrame = Instance.new("Frame",library.ScreenGui)
arrayListFrame.Size = UDim2.fromScale(0.2,1)
arrayListFrame.Position = UDim2.fromScale(0.795,0.03)
arrayListFrame.BackgroundTransparency = 1
arrayListFrame.Name = "ArrayList"
local sort = Instance.new("UIListLayout", arrayListFrame)
sort.SortOrder = Enum.SortOrder.LayoutOrder
sort.HorizontalAlignment = Enum.HorizontalAlignment.Right

local colors = {
	["CottonCandy"] = {
		["Main"] = Color3.fromRGB(234, 149, 255),
		["Second"] = Color3.fromRGB(143, 253, 255)
	},
	["Purple"] = {
		["Main"] = Color3.fromRGB(191, 0, 255),
		["Second"] = Color3.fromRGB(119, 0, 255)
	},
	["Wave4Mc"] = {
		["Main"] = Color3.fromRGB(76, 118, 255),
		["Second"] = Color3.fromRGB(255, 255, 255)
	},
	["Hackerman"] = {
		["Main"] = Color3.fromRGB(0, 145, 17),
		["Second"] = Color3.fromRGB(255, 255, 255)
	},
	["Blurple"] = { -- Springs fav frfrfrfrfrfrfrfr :D
		["Main"] = Color3.fromRGB(124, 7, 191),
		["Second"] = Color3.fromRGB(66, 2, 227)
	},
}

local imageId = "http://www.roblox.com/asset/?id=5857213084"
local currentTheme = colors.Purple
local arrayItems = {}
local arraylist = {
	Create = function(o)

		local item = Instance.new("TextLabel", arrayListFrame)
		item.Text = o
		item.BackgroundTransparency = 0.3
		item.BorderSizePixel = 0
		item.BackgroundColor3 = Color3.fromRGB(0,0,0)
		item.Size = UDim2.new(0,0,0,0)
		item.TextSize = 12
		item.TextColor3 = Color3.fromRGB(255,255,255)
		--item.TextXAlignment = Enum.TextXAlignment.Right

		local glow = Instance.new("ImageLabel",item)
		glow.Size = UDim2.fromScale(4,4)
		glow.BackgroundTransparency = 1
		glow.Image = imageId
		glow.ImageTransparency = 0.3
		glow.Position = UDim2.fromScale(-1,-1.5)
		glow.ZIndex = -10

		local size = UDim2.new(0.01,game.TextService:GetTextSize(o,22,Enum.Font.SourceSans,Vector2.new(0,0)).X,0.033,0)

		if o == "" then
			size = UDim2.fromScale(0,0)
		end

		item.Size = size

		item.BackgroundTransparency = 0.6
		item.TextTransparency = 0

		table.insert(arrayItems,item)
		table.sort(arrayItems,function(a,b) return game.TextService:GetTextSize(a.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X > game.TextService:GetTextSize(b.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X end)
		for i,v in ipairs(arrayItems) do
			v.LayoutOrder = i
		end

	end,
	Remove = function(o)
		table.sort(arrayItems,function(a,b) return game.TextService:GetTextSize(a.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X > game.TextService:GetTextSize(b.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X end)
		local c = 0
		for i,v in ipairs(arrayItems) do
			c += 1
			if (v.Text == o) then
				v:Destroy()
				table.remove(arrayItems,c)
			else
				v.LayoutOrder = i
			end
		end
	end,
}

arraylist.Create("")

task.spawn(function()
	local loops = 0
	repeat task.wait()
		loops += 1
		local count = 0

		local half = #arrayItems / 2
		local glowTemps = {}
		for i,v in pairs(arrayItems) do
			count += 1
			local formula = ((count - 1) / (#arrayItems - 1))
			local offset = math.sin(tick() * 2 + formula * 2 * math.pi) / 0.5
			game.TweenService:Create(v,TweenInfo.new(0.5),{
				TextColor3 = currentTheme.Main:Lerp(currentTheme.Second,math.clamp(offset + 0.5,0,1))
			}):Play()
			game.TweenService:Create(v.ImageLabel,TweenInfo.new(0.5),{
				ImageColor3 = currentTheme.Main:Lerp(currentTheme.Second,math.clamp(offset + 0.5,0,1))
			}):Play()
		end

		if loops > 1 then
			for i,v in pairs(glowTemps) do
				v:Destroy()
			end

			table.clear(glowTemps)
		end
	until false
end)

local cmdSystem
cmdSystem = {
	cmds = {},
	RegisterCommand = function(cmd,func)
		cmdSystem.cmds[cmd] = func
	end,
}

local function runCommand(cmd,args)
	if cmdSystem.cmds[cmd] ~= nil then

		cmdSystem.cmds[cmd](args)

	else
		print("INVALID COMMAND")
	end
end

cmdBar.FocusLost:Connect(function()
	local split = cmdBar.Text:split(" ")
	local cmd = split[1]

	table.remove(split,1)

	local args = split

	runCommand(cmd,args)

end)

cmdSystem.RegisterCommand("setgui",function(args)
	library.KeyBind = Enum.KeyCode[args[1]:upper()]
end)

cmdSystem.RegisterCommand("bind", function(args)
	local module = nil
	local name = ""

	for i,v in pairs(library.Modules) do
		if i:lower() == args[1]:lower() then
			module = v
			name = i
			break
		end
	end

	if module == nil then
		print("INVALID MODULE")
	else
		if args[2]:lower() == "none" then
			config.Keybinds[name] = nil
		end
		config.Keybinds[name] = args[2]:upper()
		module.Keybind = Enum.KeyCode[args[2]:upper()]
		task.delay(0.3,function()
			library.saveConfig()
		end)
	end
end)

function NewTween(item, totime, toChange)
	TweenService:Create(item, totime, toChange):Play()
end

local NOTIFY_FRAME = Instance.new("Frame", library.ScreenGui)
NOTIFY_FRAME.Position = UDim2.fromScale(0.8, 0.5)
NOTIFY_FRAME.Size = UDim2.fromScale(0.19, 0.4)
NOTIFY_FRAME.BackgroundTransparency = 1

local SORT_NOTIFY_FRAME = Instance.new("UIListLayout", NOTIFY_FRAME)
SORT_NOTIFY_FRAME.SortOrder = Enum.SortOrder.LayoutOrder
SORT_NOTIFY_FRAME.VerticalAlignment = Enum.VerticalAlignment.Bottom
SORT_NOTIFY_FRAME.Padding = UDim.new(0, 5)

function library:Notification(Description, Time)
	spawn(function()
		local newNotif = Instance.new("TextLabel", NOTIFY_FRAME)
		newNotif.Size = UDim2.fromScale(0.9, 0.1)
		newNotif.Position = UDim2.fromScale(0, 0)
		newNotif.BorderSizePixel = 0
		newNotif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		newNotif.BackgroundTransparency = 0.4
		newNotif.TextColor3 = Color3.fromRGB(255,255,255)
		newNotif.TextScaled = true
		newNotif.Text = Description

		local Box = Instance.new("Frame", newNotif)
		Box.Position = UDim2.fromScale(-0.05, 0)
		Box.Size = UDim2.fromScale(0.05, 1)
		Box.BorderSizePixel = 0
		Box.BackgroundColor3 = library.Color

		task.delay(Time, function()
			NewTween(newNotif, TweenInfo.new(1), {Transparency = 1})
			NewTween(Box, TweenInfo.new(1), {Transparency = 1})
		end)
	end)
end

library.NewWindow = function(name)

	local textlabel = Instance.new("TextLabel", library.ScreenGui)
	textlabel.Position = UDim2.fromScale(0.1 + (library.WindowCount / 8), 0.1)
	textlabel.Size = UDim2.fromScale(0.1, 0.0425)
	textlabel.Text = name
	textlabel.Name = name
	textlabel.BorderSizePixel = 0
	textlabel.BackgroundColor3 = Color3.fromRGB(35,35,35)
	textlabel.TextColor3 = Color3.fromRGB(255,255,255)

	local modules = Instance.new("Frame", textlabel)
	modules.Size = UDim2.fromScale(1, 5)
	modules.Position = UDim2.fromScale(0,1)
	modules.BackgroundTransparency = 1
	modules.BorderSizePixel = 0

	local sortmodules = Instance.new("UIListLayout", modules)
	sortmodules.SortOrder = Enum.SortOrder.Name

	UserInputService.InputBegan:Connect(function(k, g)
		if g then return end
		if k == nil then return end
		if k.KeyCode == library.KeyBind then
			textlabel.Visible = not textlabel.Visible
		end
	end)

	library.WindowCount += 1
	local lib = {}

	lib.NewButton = function(Table)
		library.Modules[Table.Name] = {
			Keybind = Table.Keybind,
		}

		if config.Buttons[Table.Name] == nil then
			config.Buttons[Table.Name] = {
				Enabled = false,
			}
		else
			library.saveConfig()
		end

		if config.Keybinds[Table.Name] == nil then
			config.Keybinds[Table.Name] = tostring(Table.Keybind):split(".")[3] or "Unknown"
		end

		library.Modules[Table.Name].Keybind = Enum.KeyCode[config.Keybinds[Table.Name]]

		local enabled = false
		local textbutton = Instance.new("TextButton", modules)
		textbutton.Size = UDim2.fromScale(1, 0.2)
		textbutton.Position = UDim2.fromScale(0,0)
		textbutton.BackgroundColor3 = Color3.fromRGB(60,60,60)
		textbutton.BorderSizePixel = 0
		textbutton.Text = Table.Name
		textbutton.Name = Table.Name
		textbutton.TextColor3 = Color3.fromRGB(255,255,255)

		local dropdown = Instance.new("Frame", textbutton)
		dropdown.Position = UDim2.fromScale(0,1)
		dropdown.Size = UDim2.fromScale(1,5)
		dropdown.BackgroundTransparency = 1
		dropdown.Visible = false

		local dropdownsort = Instance.new("UIListLayout", dropdown)
		dropdownsort.SortOrder = Enum.SortOrder.Name

		local lib2 = {}
		lib2.Enabled = false

		lib2.ToggleButton = function(v)
			if v then
				enabled = true
			else
				enabled = not enabled
			end

			if (enabled) then
				arraylist.Create(Table.Name)
				library:Notification(Table.Name.." has been enabled", 1)
			else
				arraylist.Remove(Table.Name)
				library:Notification(Table.Name.." has been disabled", 1)
			end

			lib2.Enabled = enabled
			task.spawn(function()
				task.delay(0.1, function()
					Table.Function(enabled)
				end)
			end)

			textbutton.BackgroundColor3 = (textbutton.BackgroundColor3 == Color3.fromRGB(60,60,60) and library.Color or Color3.fromRGB(60,60,60))
			config.Buttons[Table.Name].Enabled = enabled
			library.saveConfig()
		end

		lib2.NewToggle = function(v)
			local Enabled = false

			if config.Toggles[v.Name.."_"..Table.Name] == nil then 
				config.Toggles[v.Name.."_"..Table.Name] = {Enabled = false}
			end

			local textbutton2 = Instance.new("TextButton", dropdown)
			textbutton2.Size = UDim2.fromScale(1, 0.15)
			textbutton2.Position = UDim2.fromScale(0,0)
			textbutton2.BackgroundColor3 = Color3.fromRGB(60,60,60)
			textbutton2.BorderSizePixel = 0
			textbutton2.Text = v.Name
			textbutton2.Name = v.Name
			textbutton2.TextColor3 = Color3.fromRGB(255,255,255)

			local v2 = {}
			v2.Enabled = Enabled

			v2.ToggleButton = function(v3)
				if v3 then
					Enabled = v3
				else
					Enabled = not Enabled
				end
				v2.Enabled = Enabled
				task.spawn(function()
					v.Function(Enabled)
				end)
				textbutton2.BackgroundColor3 = (textbutton2.BackgroundColor3 == Color3.fromRGB(60,60,60) and library.Color or Color3.fromRGB(60,60,60))
				config.Toggles[v.Name.."_"..Table.Name].Enabled = Enabled
				library.saveConfig()
			end

			textbutton2.MouseButton1Down:Connect(function()	
				v2.ToggleButton()
			end)

			if config.Toggles[v.Name.."_"..Table.Name].Enabled then
				v2.ToggleButton()
			end

			return v2
		end

		lib2.NewPicker = function(v)
			local Enabled = false

			if config.Options[v.Name.."_"..Table.Name] == nil then
				config.Options[v.Name.."_"..Table.Name] = {Option = v.Options[1]}
			end

			local textbutton2 = Instance.new("TextButton", dropdown)
			textbutton2.Size = UDim2.fromScale(1, 0.15)
			textbutton2.Position = UDim2.fromScale(0,0)
			textbutton2.BackgroundColor3 = Color3.fromRGB(60,60,60)
			textbutton2.BorderSizePixel = 0
			textbutton2.Text = v.Name.." - "..v.Options[1]
			textbutton2.Name = v.Name
			textbutton2.TextColor3 = Color3.fromRGB(255,255,255)

			local v2 = {
				Option = v.Options[1]
			}

			local index = 0
			textbutton2.MouseButton1Down:Connect(function()
				index += 1

				if index > #v.Options then
					index = 1
				end

				v2.Option = v.Options[index]
				textbutton2.Text = v.Name.." - "..v2.Option

				config.Options[v.Name.."_"..Table.Name].Option = v.Options[index]
				library.saveConfig()
			end)

			textbutton2.MouseButton2Down:Connect(function()
				index -= 1

				if index < #v.Options then
					index = 1
				end

				v2.Option = v.Options[index]

				textbutton2.Text = v.Name.." - "..v2.Option
				config.Options[v.Name.."_"..Table.Name].Option = v.Options[index]
				library.saveConfig()
			end)

			local option = config.Options[v.Name.."_"..Table.Name].Option
			v2.Option = option
			textbutton2.Text = v.Name.." - "..option


			return v2
		end

		textbutton.MouseButton1Down:Connect(function()
			lib2.ToggleButton()
		end)

		textbutton.MouseButton2Down:Connect(function()
			dropdown.Visible = not dropdown.Visible
			for i,v in pairs(modules:GetChildren()) do
				if v.Name == Table.Name then continue end
				if v:IsA("UIListLayout") then continue end
				v.Visible = not v.Visible
			end
		end)

		UserInputService.InputBegan:Connect(function(k, g)
			if g then return end
			if k == nil then return end
			if k.KeyCode == library.Modules[Table.Name].Keybind and k.KeyCode ~= Enum.KeyCode.Unknown then
				lib2.ToggleButton()
			end
		end)

		if config.Buttons[Table.Name].Enabled then
			lib2.ToggleButton()
		end

		return lib2
	end
	return lib
end

function library:uninject()
	library.saveConfig()
	cansave = false

	for i,v in library.modules do
		if config.Buttons[i].Enabled then
			v:ToggleButton()
		end
		config.Keybinds[i] = nil
	end

	library.ScreenGui:Destroy()
	table.clear(arrayItems)
	table.clear(library.Modules)
	table.clear(cmdSystem.cmds)
end

return library