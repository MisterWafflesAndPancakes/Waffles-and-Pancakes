return function()
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local player = game.Players.LocalPlayer
	local activeRole = nil

	local phaseSignal = Instance.new("BindableEvent")

	-- Configs
	local configs = {
		[1] = {
			name = "PLAYER 1: DUMMY",
			deathDelay = 0.2,
			cycleDelay = 0.8
		},
		[2] = {
			name = "PLAYER 2: MAIN",
			deathDelay = 0.2,
			cycleDelay = 0.8
		}
	}

	-- Core loop logic
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
		local nextPhaseTime = os.clock() + config.deathDelay
	
		phaseSignal.Event:Connect(function(newPhase)
			phase = newPhase
			nextPhaseTime = os.clock() + config.cycleDelay
		end)
	
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if activeRole ~= role then
				connection:Disconnect()
				return
			end
	
			local now = os.clock()
	
			if phase == "kill" and now >= nextPhaseTime then
				local char = player.Character
				if char then
					pcall(function()
						char:BreakJoints()
					end)
					print("Killed character for role:", role)
				end
	
				phase = "waitingForPlacement"
	
				coroutine.wrap(function()
					player.CharacterAdded:Wait()
					local newChar = player.Character
					if not newChar then return end
	
					local hrp = newChar:FindFirstChild("HumanoidRootPart")
					if not hrp then
						for _ = 1, 10 do
							RunService.Heartbeat:Wait()
							hrp = newChar:FindFirstChild("HumanoidRootPart")
							if hrp then break end
						end
					end
	
					if hrp then
						newChar.PrimaryPart = hrp
						task.defer(function()
							newChar:SetPrimaryPartCFrame(points[index])
						end)
						print("Placed at ring index:", index)
					else
						warn("HumanoidRootPart not found—spawned at default")
					end
	
					phase = "wait"
					nextPhaseTime = os.clock() + config.cycleDelay
				end)()
			end
	
			if phase == "wait" and now >= nextPhaseTime then
				index = (index % #points) + 1
				print("Advancing to next ring index:", index)
				phase = "kill"
				nextPhaseTime = os.clock() + config.deathDelay
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
