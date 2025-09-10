return function()
	local player = game.Players.LocalPlayer
	_G.SelectedPlayer = nil
	
	-- 🧠 Player configs
	local playerConfigs = {
	    [1] = {
	        points = {
	            Vector3.new(-139.10, 29.82, 408.20),
	            Vector3.new(-137.85, 29.82, 487.46)
	        },
	        deathDelay = 0.8,
	        teleportDelay = 6.5
	    },
	    [2] = {
	        points = {
	            Vector3.new(-144.95, 29.82, 400.64),
	            Vector3.new(-142.56, 29.82, 498.20)
	        },
	        deathDelay = 0.4,
	        teleportDelay = 5.4
	    }
	}
	
	-- ⚔️ Teleport and kill
	local function teleportAndDie(pos, deathDelay)
	    local char = player.Character or player.CharacterAdded:Wait()
	    local hrp = char:FindFirstChild("HumanoidRootPart")
	    local hum = char:FindFirstChild("Humanoid")
	
	    if not hrp or not hum then return end
	
	    hrp.CFrame = CFrame.new(pos)
	    task.wait(deathDelay)
	
	    if hum then
	        hum.Health = 0
	        char:BreakJoints()
	    end
	
	    repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	end
	
	-- 🧠 Wait until sparring starts on Ring 1 or Ring 4
	local function waitForSparStart()
	    local rs = game:GetService("ReplicatedStorage")
	    local getValue = rs:FindFirstChild("Get_Value_From_Workspace")
	    if not getValue then return end
	
	    repeat
	        if _G.SelectedPlayer == nil then return end
	
	        local ring1, ring4 = 0, 0
	
	        local success1, result1 = pcall(function()
	            return getValue:WaitForChild("Get_Time_Spar_Ring1"):InvokeServer()
	        end)
	        local success4, result4 = pcall(function()
	            return getValue:WaitForChild("Get_Time_Spar_Ring4"):InvokeServer()
	        end)
	
	        ring1 = success1 and result1 or 0
	        ring4 = success4 and result4 or 0
	
	        task.wait(1)
	    until ring1 > 0 or ring4 > 0
	end
	
	-- 🔁 Loop logic
	local function runLoop(playerId)
	    local config = playerConfigs[playerId]
	    while _G.SelectedPlayer == playerId do
	        waitForSparStart()
	
	        for _, pos in ipairs(config.points) do
	            teleportAndDie(pos, config.deathDelay)
	            task.wait(config.teleportDelay)
	            if _G.SelectedPlayer ~= playerId then break end
	        end
	    end
	end
	
	-- 🖱️ GUI Setup
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
	
	-- 🎮 Button logic
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
