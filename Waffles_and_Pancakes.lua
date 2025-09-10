return function()
	local player = game.Players.LocalPlayer
	_G.SelectedPlayer = nil
	
	-- Player configs
	local playerConfigs = {
	    [1] = {
	        points = {
	            Vector3.new(-139.10, 29.82, 408.20), -- Ring 1
	            Vector3.new(-137.85, 29.82, 487.46)  -- Ring 4
	        },
	        deathDelay = 1.2,
	        teleportDelay = 6.5
	    },
	    [2] = {
	        points = {
	            Vector3.new(-144.95, 29.82, 400.64), -- Ring 1
	            Vector3.new(-142.56, 29.82, 498.20)  -- Ring 4
	        },
	        deathDelay = 0.4,
	        teleportDelay = 5.4
	    }
	}
	
	-- Exclusive teleport-only for Player 1 (dummy)
	local function teleportOnlyDummy(pos)
	    local char = player.Character or player.CharacterAdded:Wait()
	    if not char then return end
	
	    local hrp = char:FindFirstChild("HumanoidRootPart")
	    if hrp then
	        hrp.CFrame = CFrame.new(pos)
	    end
	end
	
	-- Standard teleport + kill
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
	
	-- Kill-only for Player 1 after trigger
	local function killCharacter(deathDelay)
	    task.wait(deathDelay)
	
	    local char = player.Character or player.CharacterAdded:Wait()
	    if not char then return end
	
	    local hum = char:FindFirstChild("Humanoid")
	    if hum then
	        hum.Health = 0
	        char:BreakJoints()
	    end
	
	    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	end
	
	-- Wait for Player 2 to teleport near target
	local function waitForPlayer2Teleport(targetPos)
	    local threshold = 10
	    local otherPlayer = nil
	
	    for _, p in pairs(game.Players:GetPlayers()) do
	        if p ~= player then
	            otherPlayer = p
	            break
	        end
	    end
	
	    if not otherPlayer then return end
	
	    repeat
	        if _G.SelectedPlayer ~= 1 then return end
	
	        local char = otherPlayer.Character
	        local hrp = char and char:FindFirstChild("HumanoidRootPart")
	
	        if hrp and (hrp.Position - targetPos).Magnitude < threshold then
	            break
	        end
	
	        task.wait(0.5)
	    until false
	end
	
	-- Loop logic
	local function runLoop(playerId)
	    local config = playerConfigs[playerId]
	
	    while _G.SelectedPlayer == playerId do
	        -- Phase A: Ring 4
	        if playerId == 1 then
	            repeat
	                if _G.SelectedPlayer ~= playerId then return end
	                teleportOnlyDummy(config.points[2])
	                task.wait(config.teleportDelay)
	            until false -- broken by Player 2 detection below
	
	            waitForPlayer2Teleport(config.points[2])
	            teleportOnlyDummy(config.points[2])
	            killCharacter(config.deathDelay)
	            task.wait(config.teleportDelay)
	        else
	            teleportAndDie(config.points[2], config.deathDelay)
	            task.wait(config.teleportDelay)
	        end
	
	        -- Phase B: Ring 1
	        if playerId == 1 then
	            repeat
	                if _G.SelectedPlayer ~= playerId then return end
	                teleportOnlyDummy(config.points[1])
	                task.wait(config.teleportDelay)
	            until false -- broken by Player 2 detection below
	
	            waitForPlayer2Teleport(config.points[1])
	            teleportOnlyDummy(config.points[1])
	            killCharacter(config.deathDelay)
	            task.wait(config.teleportDelay)
	        else
	            teleportAndDie(config.points[1], config.deathDelay)
	            task.wait(config.teleportDelay)
	        end
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
	    if _G.SelectedPlayer == 1 then
	        _G.SelectedPlayer = nil
	        button1.Text = "PLAYER 1: DUMMY"
	        button1.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	        print("PLAYER 1 stopped")
	    else
	        _G.SelectedPlayer = 1
	        button1.Text = "PLAYER 1: RUNNING"
	        button1.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	        button2.Text = "PLAYER 2: MAIN"
	        button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	        print("PLAYER 1 started")
	        coroutine.wrap(function() runLoop(1) end)()
	    end
	end)
	
	button2.MouseButton1Click:Connect(function()
	    if _G.SelectedPlayer == 2 then
	        _G.SelectedPlayer = nil
	        button2.Text = "PLAYER 2: MAIN"
	        button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	        print("PLAYER 2 stopped")
	    else
	        _G.SelectedPlayer = 2
	        button2.Text = "PLAYER 2: RUNNING"
	        button2.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
	        button1.Text = "PLAYER 1: DUMMY"
	        button1.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	        print("PLAYER 2 started")
	        coroutine.wrap(function() runLoop(2) end)()
	    end
	end)
end
