return function()
    print("📣 The script is actually running")

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Confirm LocalPlayer exists
    print("👤 LocalPlayer is:", LocalPlayer)
    if not LocalPlayer then
        warn("❌ LocalPlayer is nil — script must run on the client.")
        return
    end

    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    print("🎯 PlayerGui is:", PlayerGui)

    if not PlayerGui then
        warn("❌ PlayerGui not found")
        return
    end

    -- Build GUI
    print("🧱 Building GUI now...")

    local gui = Instance.new("ScreenGui")
    gui.Name = "TestGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000
    gui.Enabled = true
    gui.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 50)
    label.Position = UDim2.new(0.5, -100, 0.5, -25)
    label.Text = "✅ GUI Test Loaded"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    label.ZIndex = 1000
    label.Visible = true
    label.Parent = gui

    print("✅ Minimal GUI test executed")
end
