return function()
	-- [WAFFLES AND PANCAKES VERSION 1.1] [UPDATE: AUTOBUY GEARS!]
	-- [SEED SELECTION AND GEAR SELECTION ENTIRELY CUSTOMISABLE]
	-- [MADE BY MISTER WAFFLES]

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

	-- [PUT SEEDNAME HERE TO SELECT SEED]
	local SeedsToBuy = {
	    "Sugar Apple",
 	   "Feijoa",
 	   "Loquat",
 	   "Prickly Pear",
 	   "Bell Pepper",
 	   "Kiwi",
 	   "Pineapple",
 	   "Banana",
 	   "Avocado",
 	   "Green Apple",
 	   "Sugar Apple"
	}

	local GearsToBuy = {
	    "Watering Can",
	    "Basic Sprinkler",
	    "Advanced Sprinkler",
	    "Godly Sprinkler",
	    "Master Sprinkler",
	}

	local AutoBuyEnabled = false
	local AutoBuyInterval = 1.5 -- [SECONDS]

	-- [BUY SEED FUNC]
	local function BuySeed(seedName)
	    if GameEvents:FindFirstChild("BuySeedStock") then
	        GameEvents.BuySeedStock:FireServer(seedName)
	        print("Bought seed:", seedName)
	    else
	        warn("BuySeedStock event not found")
	    end
	end

	-- [BUY GEAR FUNC]
	local function BuyGear(gearName)
	    if GameEvents:FindFirstChild("BuyGearStock") then
	        GameEvents.BuyGearStock:FireServer(gearName)
	        print("Bought gear:", gearName)
	    else
	        warn("BuyGearStock event not found")
	    end
	end

	local AutoBuyLoop

	local function StartAutoBuy()
	    if AutoBuyLoop then return end
	    AutoBuyEnabled = true
	    AutoBuyLoop = coroutine.create(function()
	        while AutoBuyEnabled do
	            for _, seed in ipairs(SeedsToBuy) do
	                BuySeed(seed)
	            end
	           for_, gear in ipairs(GearsToBuy) do
	                BuyGear(gear)
	           end
	            wait(AutoBuyInterval)
	        end
	    end)
	    coroutine.resume(AutoBuyLoop)
	end

	local function StopAutoBuy()
	    AutoBuyEnabled = false
	    AutoBuyLoop = nil
	end

	-- Create a simple ScreenGui with a toggle button
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AutoBuyGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Main container
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 200, 0, 90) -- taller to fit title
	container.Position = UDim2.new(0, 20, 0, 20)
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	container.BorderSizePixel = 0
	container.Active = true
	container.Draggable = true
	container.Parent = screenGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = container

	-- Title label
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Waffles and Pancakes"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamSemibold
	title.TextSize = 18
	title.Parent = container
	
	-- Button
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 35)
	button.Position = UDim2.new(0, 10, 0, 40)
	button.Text = "Enable Auto-Buy"
	button.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.AutoButtonColor = false
	button.Parent = container

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = button

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 255, 255)
	buttonStroke.Thickness = 1.2
	buttonStroke.Parent = button

	-- Hover effect
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(70, 200, 85)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = AutoBuyEnabled and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 180, 75)
	end)

	-- Button appearance update
	local function UpdateButtonAppearance()
		if AutoBuyEnabled then
			button.Text = "Disable Auto-Buy"
			button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		else
			button.Text = "Enable Auto-Buy"
			button.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
		end
	end

	-- Toggle behavior
	local function ToggleAutoBuy()
		if AutoBuyEnabled then
			StopAutoBuy()
		else
			StartAutoBuy()
		end
		UpdateButtonAppearance()
	end

	button.MouseButton1Click:Connect(ToggleAutoBuy)
	UpdateButtonAppearance()
end
