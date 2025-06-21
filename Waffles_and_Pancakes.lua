return function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        warn("❌ LocalPlayer is nil — script must run on the client.")
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "TestGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 100
    gui.Enabled = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 50)
    label.Position = UDim2.new(0.5, -100, 0.5, -25)
    label.Text = "✅ GUI Test Loaded"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    label.ZIndex = 100
    label.Parent = gui

    print("✅ Minimal GUI test executed")
end
