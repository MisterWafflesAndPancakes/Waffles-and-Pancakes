return function()
	local RunService = game:GetService("RunService")
	local player = game.Players.LocalPlayer
	local activeRole = nil

	-- Configs (Adjusted for possible fix to a no teleport death.)
	local configs = {
	    [1] = {
	        name = "PLAYER 1: DUMMY",
	        deathDelay = 0.5,
	        cycleDelay = 5.8
	    },
	    [2] = {
	        name = "PLAYER 2: MAIN",
	        deathDelay = 0.5,
	        cycleDelay = 5.8
	    }
	}

	-- Core loop (clock.os() based, undriftable)
	local function runLoop(role)
		local points = (role == 1) and {
			workspace.Spar_Ring4.Player1_Button.CFrame,
			workspace.Spar_Ring3.Player1_Button.CFrame,
			workspace.Spar_Ring2.Player1_Button.CFrame
		} or {
			workspace.Spar_Ring4.Player2_Button.CFrame,
			workspace.Spar_Ring3.Player2_Button.CFrame,
			workspace.Spar_Ring2.Player2_Button.CFrame
		}

		if not points then return end

		local config = configs[role]
		local index = 1
		local phase = "kill"
		local phaseStart = os.clock()

		local connection
		connection = RunService.Heartbeat:Connect(function()
			if activeRole ~= role then
				connection:Disconnect()
				return
			end

			local now = os.clock()
			local elapsed = now - phaseStart

			if phase == "kill" and elapsed >= config.deathDelay then
				local char = player.Character
				if char then
				local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	
				if char and humanoid and humanoid.Health > 0 then
					pcall(function()
						char:BreakJoints()
					end)
	
					phase = "waitingForPlacement"
					phaseStart = now
	
					-- Coroutine handles placement and phase transition
					coroutine.wrap(function()
						player.CharacterAdded:Wait()
						local newChar = player.Character
						if not newChar then return end
	
						local hrp = newChar:WaitForChild("HumanoidRootPart", 2)
						if hrp then
							hrp.CFrame = points[index]
							phase = "wait"
							phaseStart = os.clock()
						end
					end)()
				end
				phase = "waitingForPlacement"
				phaseStart = now
	
				-- Coroutine handles placement and phase transition
				coroutine.wrap(function()
					player.CharacterAdded:Wait()
					local char = player.Character
					if not char then return end
	
					local hrp = char:WaitForChild("HumanoidRootPart", 2)
					if hrp then
						hrp.CFrame = points[index]
						phase = "wait"
						phaseStart = os.clock()
					end
				end)()
			end

			-- waitingForPlacement: do nothing until coroutine transitions to "wait"

			if phase == "wait" and elapsed >= config.cycleDelay then
				index = index % #points + 1
				phase = "kill"
				phaseStart = os.clock()
			end
		end)
	end

	-- GUI Setup (Universally draggable, highly responsive)
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")

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
	    button.Active = true
	    button.Selectable = true
	    button.Parent = screenGui
	    return button
	end

	local function makeDraggable(gui)
	    local dragging = false
	    local dragStart, startPos

	    gui.InputBegan:Connect(function(input)
	        if input.UserInputType == Enum.UserInputType.MouseButton1 or
	           input.UserInputType == Enum.UserInputType.Touch then
	            dragging = true
	            dragStart = input.Position
	            startPos = gui.Position

	            input.Changed:Connect(function()
	                if input.UserInputState == Enum.UserInputState.End then
	                    dragging = false
	                end
	            end)
	        end
	    end)

	    UserInputService.InputChanged:Connect(function(input)
	        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
	                         input.UserInputType == Enum.UserInputType.Touch) then
	            local delta = input.Position - dragStart
	            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
	                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	        end
	    end)
	end

	local button1 = createButton("PLAYER 1: DUMMY", UDim2.new(0, 20, 0, 20))
	local button2 = createButton("PLAYER 2: MAIN", UDim2.new(0, 20, 0, 70))

	makeDraggable(button1)
	makeDraggable(button2)

	-- Button logic (Makes the button work!!!)
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
