return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local LocalPlayer = Players.LocalPlayer
	local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")

	--Find seed name in shop and copy exactly as it is written in the shop
	local SeedsToBuy = {
	 "Sugar Apple",
	 "Feijoa",
	 "Loquat", 
	 "Prickly Pear", 
	 "Bell Pepper",
	 "Kiwi"
	}

	--Find gear name in shop and copy exactly as it is written in the shop
	local GearsToBuy = {
	 "Watering Can", 
	 "Basic Sprinkler", 
	 "Advanced Sprinkler",
	 "Godly Sprinkler", 
	 "Master Sprinkler", 
	 "Tanning Mirror"
	}

	local AutoBuyEnabled = false
	local AutoBuyInterval = 1.5

	local function BuySeed(seedName)
		if GameEvents:FindFirstChild("BuySeedStock") then
			GameEvents.BuySeedStock:FireServer(seedName)
			print("🌱 Bought seed:", seedName)
		else
			warn("❌ BuySeedStock event not found")
		end
	end
	
	local function BuyGear(gearName)
		if GameEvents:FindFirstChild("BuyGearStock") then
			GameEvents.BuyGearStock:FireServer(gearName)
			print("🛠️ Bought gear:", gearName)
		else
			warn("❌ BuyGearStock event not found")
		end
	end
		end

	local AutoBuyLoop
	local function StartAutoBuy()
	    if AutoBuyLoop then return end
	    AutoBuyEnabled = true
	    AutoBuyLoop = coroutine.create(function()
	        while AutoBuyEnabled do
	            for _, seed in ipairs(SeedsToBuy) do BuySeed(seed) end
	            for _, gear in ipairs(GearsToBuy) do BuyGear(gear) end
	            wait(AutoBuyInterval)
	        end
	    end)
	    coroutine.resume(AutoBuyLoop)
	end

	local function StopAutoBuy()
	    AutoBuyEnabled = false
	    AutoBuyLoop = nil
	end

	-- GUI Setup
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AutoBuyGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 170, 0, 60)
	container.Position = UDim2.new(0, 20, 0, 20)
	container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	container.BorderSizePixel = 0
	container.Active = true
	container.BackgroundTransparency = 0 -- now fully visible
	container.Parent = screenGui
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 12)
	containerCorner.Parent = container
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 20)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Waffles and Pancakes"
	title.TextColor3 = Color3.fromRGB(255, 0, 0)
	title.Font = Enum.Font.Ubuntu
	title.TextSize = 16
	title.TextTransparency = 0 -- fully visible
	title.Parent = container
	
	-- RGB effect
	task.spawn(function()
		while true do
			for h = 0, 1, 0.01 do
				title.TextColor3 = Color3.fromHSV(h, 1, 1)
				task.wait(0.03)
			end
		end
	end)
	
	-- Button
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 1, -30)
	button.Position = UDim2.new(0, 10, 0, 25)
	button.Text = "Enable Auto-Buy"
	button.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.Ubuntu
	button.TextSize = 16
	button.AutoButtonColor = false
	button.BackgroundTransparency = 0 -- fully visible
	button.Parent = container
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = button
	
	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 255, 255)
	buttonStroke.Thickness = 1.2
	buttonStroke.Parent = button
	
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(70, 200, 85)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = AutoBuyEnabled and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(60, 180, 75)
	end)
	
	local function UpdateButtonAppearance()
		if AutoBuyEnabled then
			button.Text = "Disable Auto-Buy"
			button.Font = Enum.Font.Ubuntu
			button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
		else
			button.Text = "Enable Auto-Buy"
			button.Font = Enum.Font.Ubuntu
			button.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
		end
	end
	
	-- More pro RGB fr
	task.spawn(function()
		while true do
			for h = 0, 1, 0.01 do
				button.TextColor3 = Color3.fromHSV(h, 1, 1)
				task.wait(0.03)
			end
		end
	end)
	
	-- Universal Dragging
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function update(input)
		if not dragging then return end
		local delta = input.Position - dragStart
		container.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
	
	container.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = container.Position
	
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	
	container.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput then update(input) end
	end)
end
