return function()
	local player = game.Players.LocalPlayer
	_G.SelectedPlayer = nil
	
	-- Player configs
	local playerConfigs = {
	    DUMMY = {
	        points = {
	            Vector3.new(-139.10, 29.82, 408.20), -- Ring 1
	            Vector3.new(-137.85, 29.82, 487.46)  -- Ring 4
	        },
	        deathDelay = 0.8,
	        teleportDelay = 6.5
	    },
	    MAIN = {
	        points = {
	            Vector3.new(-144.95, 29.82, 400.64), -- Ring 1
	            Vector3.new(-142.56, 29.82, 498.20)  -- Ring 4
	        },
	        deathDelay = 0.4,
	        teleportDelay = 5.4
	    }
	}
	
	-- Teleport and kill
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
	
	-- Loop logic based on role
	local function runLoop(role)
	    local config = playerConfigs[role]
	    local getValue = game:GetService("ReplicatedStorage"):WaitForChild("Get_Value_From_Workspace")
	
	    while _G.SelectedPlayer == role do
	        -- Ring 4
	        repeat
	            if _G.SelectedPlayer ~= role then return end
	            teleportAndDie(config.points[2], 0)
	            task.wait(config.teleportDelay)
	
	            local ring4 = getValue:WaitForChild("Get_Time_Spar_Ring4"):InvokeServer()
	        until typeof(ring4) == "number" and ring4 > 0
	
	        teleportAndDie(config.points[2], config.deathDelay)
	        task.wait(config.teleportDelay)
	
	        -- Ring 1
	        repeat
	            if _G.SelectedPlayer ~= role then return end
	            teleportAndDie(config.points[1], 0)
	            task.wait(config.teleportDelay)
	
	            local ring1 = getValue:WaitForChild("Get_Time_Spar_Ring1"):InvokeServer()
	        until typeof(ring1) == "number" and ring1 > 0
	
	        teleportAndDie(config.points[1], config.deathDelay)
	        task.wait(config.teleportDelay)
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
	        print("PLAYER 1 stopped")
	    else
	        _G.SelectedPlayer = "DUMMY"
	        button1.Text = "PLAYER 1: RUNNING"
	        button1.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	        button2.Text = "PLAYER 2: MAIN"
	        button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	        print("PLAYER 1 started")
	        coroutine.wrap(function() runLoop("DUMMY") end)()
	    end
	end)
	
	button2.MouseButton1Click:Connect(function()
	    if _G.SelectedPlayer == "MAIN" then
	        _G.SelectedPlayer = nil
	        button2.Text = "PLAYER 2: MAIN"
	        button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	        print("PLAYER 2 stopped")
	    else
	        _G.SelectedPlayer = "MAIN"
	        button2.Text = "PLAYER 2: RUNNING"
	        button2.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	        button1.Text = "PLAYER 1: DUMMY"
	        button1.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	        print("PLAYER 2 started")
	        coroutine.wrap(function() runLoop("MAIN") end)()
	    end
	end)
end
