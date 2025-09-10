return function()
	local player = game.Players.LocalPlayer
	_G.SelectedPlayer = nil
	_G.Ring1_P1 = false
	_G.Ring1_P2 = false
	_G.Ring4_P1 = false
	_G.Ring4_P2 = false
	
	-- Trigger setup
	workspace.Spar_Ring1.Player1_Button.Touch.Touched:Connect(function(hit)
	    if hit and hit.Parent == player.Character then
	        _G.Ring1_P1 = true
	    end
	end)
	
	workspace.Spar_Ring1.Player2_Button.Touch.Touched:Connect(function(hit)
	    if hit and hit.Parent == player.Character then
	        _G.Ring1_P2 = true
	    end
	end)
	
	workspace.Spar_Ring4.Player1_Button.Touch.Touched:Connect(function(hit)
	    if hit and hit.Parent == player.Character then
	        _G.Ring4_P1 = true
	    end
	end)
	
	workspace.Spar_Ring4.Player2_Button.Touch.Touched:Connect(function(hit)
	    if hit and hit.Parent == player.Character then
	        _G.Ring4_P2 = true
	    end
	end)
	
	-- Teleport-only
	local function teleportOnly(pos)
	    local char = player.Character or player.CharacterAdded:Wait()
	    if not char then return end
	    local hrp = char:FindFirstChild("HumanoidRootPart")
	    if hrp then hrp.CFrame = CFrame.new(pos) end
	end
	
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
	
	-- Loop logic
	local playerConfigs = {
	    DUMMY = {
	        points = {
	            Vector3.new(-139.10, 29.82, 408.20),
	            Vector3.new(-137.85, 29.82, 487.46)
	        },
	        deathDelay = 0.8,
	        teleportDelay = 6.5
	    },
	    MAIN = {
	        points = {
	            Vector3.new(-144.95, 29.82, 400.64),
	            Vector3.new(-142.56, 29.82, 498.20)
	        },
	        deathDelay = 0.4,
	        teleportDelay = 5.4
	    }
	}
	
	local function runLoop(role)
	    local config = playerConfigs[role]
	
	    while _G.SelectedPlayer == role do
	        -- Ring 4
	        repeat
	            if _G.SelectedPlayer ~= role then return end
	            teleportOnly(config.points[2])
	            task.wait(config.teleportDelay)
	        until _G.Ring4_P1 and _G.Ring4_P2
	
	        teleportAndDie(config.points[2], config.deathDelay)
	        _G.Ring4_P1 = false
	        _G.Ring4_P2 = false
	        task.wait(config.teleportDelay)
	
	        -- Ring 1
	        repeat
	            if _G.SelectedPlayer ~= role then return end
	            teleportOnly(config.points[1])
	            task.wait(config.teleportDelay)
	        until _G.Ring1_P1 and _G.Ring1_P2
	
	        teleportAndDie(config.points[1], config.deathDelay)
	        _G.Ring1_P1 = false
	        _G.Ring1_P2 = false
	        task.wait(config.teleportDelay)
	    end
	end
	
	-- GUI Setup (your original version)
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
