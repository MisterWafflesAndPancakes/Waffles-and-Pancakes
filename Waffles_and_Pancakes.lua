return function()
	local RunService = game:GetService("RunService")
	local player = game.Players.LocalPlayer
	local activeRole = nil
	
	-- Configs
	local configs = {
	    [1] = {
	        name = "PLAYER 1: DUMMY",
	        teleportDelay = 0.4,
	        deathDelay = 0.5,
	        cycleDelay = 5.7
	    },
	    [2] = {
	        name = "PLAYER 2: MAIN",
	        teleportDelay = 0.4,
	        deathDelay = 0.5,
	        cycleDelay = 5.7
	    }
	}
	
	-- Core loop (Heartbeat-driven state machine)
	local RunService = game:GetService("RunService")
	
	local function runLoop(role)
	    local points = role == 1 and {
	        workspace.Spar_Ring1.Player1_Button.CFrame,
	        workspace.Spar_Ring4.Player1_Button.CFrame
	    } or role == 2 and {
	        workspace.Spar_Ring1.Player2_Button.CFrame,
	        workspace.Spar_Ring4.Player2_Button.CFrame
	    }
	
	    if not points then return end
	
	    local config = configs[role]
	    local index = 1
	    local phase = "teleport"
	    local phaseStart = os.clock()
	
	    local connection
	    connection = RunService.Heartbeat:Connect(function()
	        if activeRole ~= role then
	            connection:Disconnect()
	            return
	        end
	
	        local now = os.clock()
	        local elapsed = now - phaseStart
	
	        if phase == "teleport" and elapsed >= config.teleportDelay then
	            phase = "kill"
	            phaseStart = now
	
	            local char = player.Character or player.CharacterAdded:Wait()
	            local hrp = char:FindFirstChild("HumanoidRootPart")
	            if hrp then
	                hrp.CFrame = points[index]
	            end
	
	        elseif phase == "kill" and elapsed >= config.deathDelay then
	            phase = "respawn"
	            phaseStart = now
	
	            local char = player.Character
	            if char then
	                pcall(function()
	                    char:BreakJoints()
	                end)
	            end
	
	        elseif phase == "respawn" then
	            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	            if hrp then
	                phase = "wait"
	                phaseStart = now
	            end
	
	        elseif phase == "wait" and elapsed >= config.cycleDelay then
	            phase = "teleport"
	            phaseStart = now
	            index = index % #points + 1
	        end
	    end)
	end
	
	-- GUI Setup
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RoleToggleGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	local function createButton(text, position)
	    local button = Instance.new("TextButton")
	    button.Size = UDim2.new(0, 200, 0, 40)
	    button.Position = position
	    button.Text = text
	    button.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	    button.TextColor3 = Color3.new(1, 1, 1)
	    button.Font = Enum.Font.SourceSansBold
	    button.TextSize = 20
	    button.Parent = screenGui
	    return button
	end
	
	local button1 = createButton("PLAYER 1: DUMMY", UDim2.new(0, 20, 0, 20))
	local button2 = createButton("PLAYER 2: MAIN", UDim2.new(0, 20, 0, 70))
	
	-- Button logic
	local function toggleRole(role)
	    if activeRole == role then
	        activeRole = nil
	        button1.Text = "PLAYER 1: DUMMY"
	        button2.Text = "PLAYER 2: MAIN"
	        button1.BackgroundColor3 = Color3.fromRGB(100, 170, 255)
	        button2.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	        print(configs[role].name .. " stopped")
	    else
	        activeRole = role
	        button1.Text = role == 1 and "PLAYER 1: RUNNING" or "PLAYER 1: DUMMY"
	        button2.Text = role == 2 and "PLAYER 2: RUNNING" or "PLAYER 2: MAIN"
	        button1.BackgroundColor3 = role == 1 and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 170, 255)
	        button2.BackgroundColor3 = role == 2 and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 100, 100)
	        print(configs[role].name .. " started")
	        runLoop(role)
	    end
	end
	
	button1.MouseButton1Click:Connect(function() toggleRole(1) end)
	button2.MouseButton1Click:Connect(function() toggleRole(2) end)
end
