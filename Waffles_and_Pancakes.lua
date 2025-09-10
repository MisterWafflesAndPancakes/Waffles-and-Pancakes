return function()
	local player = game.Players.LocalPlayer
	local UserInputService = game:GetService("UserInputService")
	local activeRole = nil
	
	-- Configs
	local configs = {
	    [1] = {
	        name = "PLAYER 1: DUMMY",
	        teleportDelay = 0.4,
	        deathDelay = 0.52,
	        cycleDelay = 5.8
	    },
	    [2] = {
	        name = "PLAYER 2: MAIN",
	        teleportDelay = 0.4,
	        deathDelay = 0.52,
	        cycleDelay = 5.8
	    }
	}
	
	-- 🛡️ Constant-check respawn gate
	local function waitForRespawn()
	    repeat task.wait()
	    until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	end
	
	-- 🧱 Core loop
	local function runLoop(role)
	    local config = configs[role]
	    local points
	
	    if role == 1 then
	        points = {
	            game.Workspace["Spar_Ring1"]["Player1_Button"].CFrame.,
	            game.Workspace["Spar_Ring4"]["Player1_Button"].CFrame.
	        }
	    elseif role == 2 then
	        points = {
	            game.Workspace["Spar_Ring1"]["Player2_Button"].CFrame.,
	            game.Workspace["Spar_Ring4"]["Player2_Button"].CFrame.
	        }
	    else
	        return
	    end
	
	    while activeRole == role do
	        for _, pos in ipairs(points) do
	            local cycleStart = os.clock()
	
	            waitForRespawn()
	            local char = player.Character
	            local hrp = char:WaitForChild("HumanoidRootPart")
	            local hum = char:WaitForChild("Humanoid")
	
	            task.wait(config.teleportDelay)
	            pcall(function()
	                hrp.CFrame = CFrame.new(pos)
	            end)
	
	            task.wait(config.deathDelay)
	            hum.Health = 0
	            char:BreakJoints()
	
	            waitForRespawn()
	
	            local elapsed = os.clock() - cycleStart
	            local remaining = config.cycleDelay - elapsed
	            if remaining > 0 then task.wait(remaining) end
	        end
	    end
	end
	
	-- 🎮 GUI Setup
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
	
	-- 🖱️📱 Universal draggable support
	local function makeDraggable(guiObject)
	    local dragging = false
	    local dragStart, startPos
	
	    guiObject.InputBegan:Connect(function(input)
	        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
	            dragging = true
	            dragStart = input.Position
	            startPos = guiObject.Position
	        end
	    end)
	
	    guiObject.InputChanged:Connect(function(input)
	        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
	            local delta = input.Position - dragStart
	            guiObject.Position = UDim2.new(
	                startPos.X.Scale,
	                startPos.X.Offset + delta.X,
	                startPos.Y.Scale,
	                startPos.Y.Offset + delta.Y
	            )
	        end
	    end)
	
	    UserInputService.InputEnded:Connect(function(input)
	        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
	            dragging = false
	        end
	    end)
	end
	
	-- 🎮 Create buttons
	local button1 = createButton("PLAYER 1: DUMMY", UDim2.new(0, 20, 0, 20))
	local button2 = createButton("PLAYER 2: MAIN", UDim2.new(0, 20, 0, 70))
	
	makeDraggable(button1)
	makeDraggable(button2)
	
	-- 🔁 Button logic
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
	        coroutine.wrap(function() runLoop(role) end)()
	    end
	end
	
	button1.MouseButton1Click:Connect(function() toggleRole(1) end)
	button2.MouseButton1Click:Connect(function() toggleRole(2) end)
end
