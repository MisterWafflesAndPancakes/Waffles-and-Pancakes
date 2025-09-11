return function()
	local RunService = game:GetService("RunService")
	local player = game.Players.LocalPlayer
	local activeRole = nil
	
	-- Configs
	local configs = {
	    [1] = {
	        name = "PLAYER 1: DUMMY",
	        teleportDelay = 0.4,
	        deathDelay = 0.52,
	        cycleDelay = 5.78
	    },
	    [2] = {
	        name = "PLAYER 2: MAIN",
	        teleportDelay = 0.4,
	        deathDelay = 0.52,
	        cycleDelay = 5.78
	    }
	}
	
	-- Core loop (Heartbeat-driven state machine)
	local function runLoop(role)
	    local points
	
	    if role == 1 then
	        points = {
	            game.Workspace["Spar_Ring1"]["Player1_Button"].CFrame,
	            game.Workspace["Spar_Ring4"]["Player1_Button"].CFrame
	        }
	    elseif role == 2 then
	        points = {
	            game.Workspace["Spar_Ring1"]["Player2_Button"].CFrame,
	            game.Workspace["Spar_Ring4"]["Player2_Button"].CFrame
	        }
	    else
	        return
	    end
	
	    local config = configs[role]
	    local index = 1
	    local timer = 0
	    local phase = "teleport"
	    local connection
	
	    connection = RunService.Heartbeat:Connect(function(deltaTime)
	        if activeRole ~= role then
	            connection:Disconnect()
	            return
	        end
	
	        timer += deltaTime
	
	        if phase == "teleport" and timer >= config.teleportDelay then
	            timer = 0
	            phase = "kill"
	
	            local char = player.Character or player.CharacterAdded:Wait()
	            local hrp = char:FindFirstChild("HumanoidRootPart")
	            if hrp then
	                hrp.CFrame = points[index]
	            end
	        elseif phase == "kill" and timer >= config.deathDelay then
	            timer = 0
	            phase = "respawn"
	
	            local char = player.Character
	            local hum = char and char:FindFirstChild("Humanoid")
	            if hum then
	                hum.Health = 0
	                char:BreakJoints()
	            end
	        elseif phase == "respawn" then
	            local char = player.Character
	            local hrp = char and char:FindFirstChild("HumanoidRootPart")
	            if hrp then
	                timer = 0
	                phase = "wait"
	            end
	        elseif phase == "wait" and timer >= config.cycleDelay then
	            timer = 0
	            phase = "teleport"
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
