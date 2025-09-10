return function()
	local player = game.Players.LocalPlayer
	_G.SelectedPlayer = nil
	_G.MainLoopActive = false
	
	-- Configs
	local config = {
	    dummy = {
	        points = {
	            Vector3.new(-139.10, 29.82, 408.20), -- Ring 1
	            Vector3.new(-137.85, 29.82, 487.46)  -- Ring 4
	        },
	        deathDelay = 1.2,
	        teleportDelay = 6.5
	    },
	    main = {
	        points = {
	            Vector3.new(-144.95, 29.82, 400.64), -- Ring 1
	            Vector3.new(-142.56, 29.82, 498.20)  -- Ring 4
	        },
	        deathDelay = 0.4,
	        teleportDelay = 5.4
	    }
	}
	
	-- Teleport-only
	local function teleportOnly(pos)
	    local char = player.Character or player.CharacterAdded:Wait()
	    if not char then return end
	    local hrp = char:FindFirstChild("HumanoidRootPart")
	    if hrp then hrp.CFrame = CFrame.new(pos) end
	end
	
	-- Kill-only with logging
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
	        warn("No Humanoid found for dummy")
	        return
	    end
	
	    print("Killing dummy now")
	    hum.Health = 0
	    char:BreakJoints()
	
	    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	end
	
	-- Teleport + kill
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
	
	    while _G.SelectedPlayer == "DUMMY" do
	        -- Ring 4
	        repeat
	            teleportOnly(points[2])
	            task.wait(teleportDelay)
	        until _G.MainLoopActive
	
	        print("Main loop detected—dummy will die at Ring 4")
	        teleportOnly(points[2])
	        killCharacter(deathDelay)
	        task.wait(teleportDelay)
	
	        -- Ring 1
	        repeat
	            teleportOnly(points[1])
	            task.wait(teleportDelay)
	        until _G.MainLoopActive
	
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
	
	    while _G.SelectedPlayer == "MAIN" do
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
	screenGui.Name = "PlayerToggleGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	local button1 = Instance.new("TextButton")
	button1.Size = UDim2.new(0, 200, 0, 40)
	button1.Position = UDim2.new(0, 20, 0, 20)
	button1.Text = "PLAYER 1: DUMMY"
	button1.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	button1.TextColor3 = Color3.new(1, 1, 1)
	button1.Font = Enum.Font.SourceSansBold
	button1.TextSize = 20
	button1.Parent = screenGui
	
	local button2 = Instance.new("TextButton")
	button2.Size = UDim2.new(0, 200, 0, 40)
	button2.Position = UDim2.new(0, 20, 0, 70)
	button2.Text = "PLAYER 2: MAIN"
	button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	button2.TextColor3 = Color3.new(1, 1, 1)
	button2.Font = Enum.Font.SourceSansBold
	button2.TextSize = 20
	button2.Parent = screenGui
	
	-- Button logic
	button1.MouseButton1Click:Connect(function()
	    if _G.SelectedPlayer == "DUMMY" then
	        _G.SelectedPlayer = nil
	        button1.Text = "PLAYER 1: DUMMY"
	        button1.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	        print("Dummy stopped")
	    else
	        _G.SelectedPlayer = "DUMMY"
	        button1.Text = "PLAYER 1: RUNNING"
	        button1.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	        button2.Text = "PLAYER 2: MAIN"
	        button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	        print("Dummy started")
	        coroutine.wrap(runDummyLoop)()
	    end
	end)
	
	button2.MouseButton1Click:Connect(function()
	    if _G.SelectedPlayer == "MAIN" then
	        _G.SelectedPlayer = nil
	        button2.Text = "PLAYER 2: MAIN"
	        button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	        print("Main stopped")
	    else
	        _G.SelectedPlayer = "MAIN"
	        button2.Text = "PLAYER 2: RUNNING"
	        button2.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	        button1.Text = "PLAYER 1: DUMMY"
	        button1.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	        print("Main started")
	        coroutine.wrap(runMainLoop)()
	    end
	end)
end
