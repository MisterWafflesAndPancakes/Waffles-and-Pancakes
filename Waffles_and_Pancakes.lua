return function()
	local player = game.Players.LocalPlayer
	_G.DummyName = ""
	_G.MainName = ""
	_G.MainLoopActive = false
	_G.SelectedRole = nil
	
	-- Configs
	local config = {
	    dummy = {
	        points = {
	            Vector3.new(-139.10, 29.82, 408.20),
	            Vector3.new(-137.85, 29.82, 487.46)
	        },
	        deathDelay = 1.2,
	        teleportDelay = 6.5
	    },
	    main = {
	        points = {
	            Vector3.new(-144.95, 29.82, 400.64),
	            Vector3.new(-142.56, 29.82, 498.20)
	        },
	        deathDelay = 0.4,
	        teleportDelay = 5.4
	    }
	}
	
	-- Core functions
	local function teleportOnly(pos)
	    local char = player.Character or player.CharacterAdded:Wait()
	    if not char then return end
	    local hrp = char:FindFirstChild("HumanoidRootPart")
	    if hrp then hrp.CFrame = CFrame.new(pos) end
	end
	
	local function killCharacter(deathDelay)
	    print("Preparing to kill dummy...")
	    task.wait(deathDelay)
	    local char = player.Character or player.CharacterAdded:Wait()
	    if not char then
	        warn("No character found for dummy")
	        return
	    end
	    local hum = char:FindFirstChild("Humanoid")
	    if not hum then
	        warn("No Humanoid found—forcing BreakJoints")
	        char:BreakJoints()
	        task.wait(0.5)
	        return
	    end
	    print("Killing dummy now")
	    hum.Health = 0
	    char:BreakJoints()
	    task.wait(0.5)
	    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	end
	
	local function teleportAndDie(pos, deathDelay)
	    local char = player.Character or player.CharacterAdded:Wait()
	    if not char then return end
	    local hrp = char:FindFirstChild("HumanoidRootPart")
	    local hum = char:FindFirstChild("Humanoid")
	    if not hrp or not hum then return end
	    hrp.CFrame = CFrame.new(pos)
	    task.wait(deathDelay)
	    hum.Health = 0
	    char:BreakJoints()
	    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	end
	
	-- Dummy loop
	local function runDummyLoop()
	    local points = config.dummy.points
	    local deathDelay = config.dummy.deathDelay
	    local teleportDelay = config.dummy.teleportDelay
	
	    local running = true
	    while running and _G.SelectedRole == "DUMMY" do
	        repeat
	            if _G.SelectedRole ~= "DUMMY" then running = false break end
	            teleportOnly(points[2])
	            task.wait(teleportDelay)
	        until _G.MainLoopActive
	
	        if not running then break end
	        print("Main loop detected—dummy will die at Ring 4")
	        teleportOnly(points[2])
	        killCharacter(deathDelay)
	        task.wait(teleportDelay)
	
	        repeat
	            if _G.SelectedRole ~= "DUMMY" then running = false break end
	            teleportOnly(points[1])
	            task.wait(teleportDelay)
	        until _G.MainLoopActive
	
	        if not running then break end
	        print("Main loop detected—dummy will die at Ring 1")
	        teleportOnly(points[1])
	        killCharacter(deathDelay)
	        task.wait(teleportDelay)
	    end
	end
	
	-- Main loop
	local function runMainLoop()
	    local points = config.main.points
	    local deathDelay = config.main.deathDelay
	    local teleportDelay = config.main.teleportDelay
	
	    while _G.SelectedRole == "MAIN" do
	        _G.MainLoopActive = true
	        teleportAndDie(points[2], deathDelay)
	        task.wait(teleportDelay)
	
	        teleportAndDie(points[1], deathDelay)
	        task.wait(teleportDelay)
	
	        _G.MainLoopActive = false
	    end
	end
	
	-- GUI Setup
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RoleConfigGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	-- Toggle Button
	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0, 150, 0, 40)
	toggleButton.Position = UDim2.new(0.5, -75, 0, 10)
	toggleButton.Text = "Open Role Config"
	toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.SourceSansBold
	toggleButton.TextSize = 18
	toggleButton.Parent = screenGui
	
	-- Config Panel
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 300, 0, 180)
	panel.Position = UDim2.new(0.5, -150, 0, 60)
	panel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	panel.Visible = false
	panel.Parent = screenGui
	
	-- Dummy Name Input
	local dummyBox = Instance.new("TextBox")
	dummyBox.Size = UDim2.new(0, 280, 0, 30)
	dummyBox.Position = UDim2.new(0, 10, 0, 10)
	dummyBox.PlaceholderText = "Enter Dummy Username"
	dummyBox.Text = ""
	dummyBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	dummyBox.TextColor3 = Color3.new(1, 1, 1)
	dummyBox.Font = Enum.Font.SourceSans
	dummyBox.TextSize = 18
	dummyBox.Parent = panel
	
	-- Main Name Input
	local mainBox = Instance.new("TextBox")
	mainBox.Size = UDim2.new(0, 280, 0, 30)
	mainBox.Position = UDim2.new(0, 10, 0, 50)
	mainBox.PlaceholderText = "Enter Main Username"
	mainBox.Text = ""
	mainBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	mainBox.TextColor3 = Color3.new(1, 1, 1)
	mainBox.Font = Enum.Font.SourceSans
	mainBox.TextSize = 18
	mainBox.Parent = panel
	
	-- Start Dummy Button
	local startDummy = Instance.new("TextButton")
	startDummy.Size = UDim2.new(0, 130, 0, 30)
	startDummy.Position = UDim2.new(0, 10, 0, 100)
	startDummy.Text = "Start Dummy"
	startDummy.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	startDummy.TextColor3 = Color3.new(1, 1, 1)
	startDummy.Font = Enum.Font.SourceSansBold
	startDummy.TextSize = 18
	startDummy.Parent = panel
	
	-- Start Main Button
	local startMain = Instance.new("TextButton")
	startMain.Size = UDim2.new(0, 130, 0, 30)
	startMain.Position = UDim2.new(0, 160, 0, 100)
	startMain.Text = "Start Main"
	startMain.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	startMain.TextColor3 = Color3.new(1, 1, 1)
	startMain.Font = Enum.Font.SourceSansBold
	startMain.TextSize = 18
	startMain.Parent = panel
	
	-- Toggle Panel Visibility
	toggleButton.MouseButton1Click:Connect(function()
	    panel.Visible = not panel.Visible
	    toggleButton.Text = panel.Visible and "Close Role Config" or "Open Role Config"
	end)
	
	-- Start Dummy Logic
	startDummy.MouseButton1Click:Connect(function()
	    _G.DummyName = dummyBox.Text
	    _G.MainName = mainBox.Text
	    if player.Name == _G.DummyName then
	        _G.SelectedRole = "DUMMY"
	        print("Dummy loop started for", player.Name)
	        coroutine.wrap(runDummyLoop)()
	    else
	        print("You are not the dummy:", player.Name)
	    end
	end)
	
	-- Start Main Logic
	startMain.MouseButton1Click:Connect
end
