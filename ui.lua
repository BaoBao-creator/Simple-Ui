local SimpleUI = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local UserInputService = game:GetService("UserInputService")
local function makeDraggable(gui, handle)
    handle = handle or gui
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
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
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.new(0,0,0)
toggleButton.BorderColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "S"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.TextSize = 18
makeDraggable(toggleButton)
toggleButton.MouseButton1Click:Connect(function()
    if SimpleUI.ActiveWindow and SimpleUI.ActiveWindow.Frame then
        local w = SimpleUI.ActiveWindow
        w.Frame.Visible = not w.Frame.Visible
    end
end)

function SimpleUI:CreateWindow(params)
    local titleText = params.Name or "Window"
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "SimpleHubFrame"
    windowFrame.Size = UDim2.new(0, 600, 0, 400)
    windowFrame.Position = UDim2.new(0, 50, 0, 50)
    windowFrame.BackgroundColor3 = Color3.new(0,0,0)
    windowFrame.BorderColor3 = Color3.new(1,1,1)
    windowFrame.Parent = screenGui
    windowFrame.Visible = true

    local titleBar = Instance.new("Frame")
    titleBar.Parent = windowFrame
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.new(0,0,0)
    titleBar.BorderColor3 = Color3.new(1,1,1)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.TextSize = 20
    titleLabel.Text = titleText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    makeDraggable(windowFrame, titleBar)

    local tabList = Instance.new("ScrollingFrame")
    tabList.Parent = windowFrame
    tabList.Size = UDim2.new(0, 150, 1, -30)
    tabList.Position = UDim2.new(0, 0, 0, 30)
    tabList.BackgroundColor3 = Color3.new(0,0,0)
    tabList.BorderColor3 = Color3.new(1,1,1)
    tabList.ScrollBarThickness = 6

    local tabLayout = Instance.new("UIListLayout", tabList)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)

    local window = {}
    window.Frame = windowFrame
    window.TabList = tabList
    window.Tabs = {}

    function window:CreateTab(name)
        local tabIndex = #self.Tabs + 1
        local btn = Instance.new("TextButton")
        btn.Parent = self.TabList
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.new(0,0,0)
        btn.BorderColor3 = Color3.new(1,1,1)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Text = name

        local contentFrame = Instance.new("Frame")
        contentFrame.Parent = windowFrame
        contentFrame.Size = UDim2.new(1, -160, 1, -30)
        contentFrame.Position = UDim2.new(0, 160, 0, 30)
        contentFrame.BackgroundColor3 = Color3.new(0,0,0)
        contentFrame.Visible = (tabIndex == 1)

        local contentScroll = Instance.new("ScrollingFrame")
        contentScroll.Parent = contentFrame
        contentScroll.Size = UDim2.new(1, -10, 1, -10)
        contentScroll.Position = UDim2.new(0, 5, 0, 5)
        contentScroll.BackgroundTransparency = 1
        contentScroll.ScrollBarThickness = 6

        local contentLayout = Instance.new("UIListLayout", contentScroll)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 5)

        local tabObj = {Button = btn, Frame = contentFrame, Content = contentScroll}

        -- Slider dễ kéo
        function tabObj:CreateSlider(config)
            config = config or {}
            local name = config.Name or "Slider"
            local range = config.Range or {0, 100}
            local inc = config.Increment or 1
            local suffix = config.Suffix or ""
            local init = config.CurrentValue or range[1]
            local callback = config.Callback or function() end
            -- Container khung cho slider
            local sliderContainer = Instance.new("Frame")
            sliderContainer.Name = "Slider_"..name
            sliderContainer.Parent = contentScroll
            sliderContainer.BackgroundTransparency = 1
            sliderContainer.Size = UDim2.new(1, 0, 0, 30)
            sliderContainer.LayoutOrder = contentLayout.AbsoluteContentSize.Y
            -- Label tên
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = sliderContainer
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextSize = 18
            nameLabel.Text = name
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            -- Khung thanh trượt (background)
            local track = Instance.new("Frame")
            track.Parent = sliderContainer
            track.Size = UDim2.new(0.58, 0, 0, 8)
            track.Position = UDim2.new(0.4, 0, 0.5, -4)
            track.BackgroundColor3 = Color3.new(1,1,1)
            track.BorderColor3 = Color3.new(0,0,0)
            track.BorderSizePixel = 2
            -- Nút kéo (handle)
            local handle = Instance.new("Frame")
            handle.Parent = track
            handle.Size = UDim2.new(0, 10, 1, 0)
            handle.Position = UDim2.new((init - range[1])/(range[2]-range[1]), 0, 0, 0)
            handle.BackgroundColor3 = Color3.new(0,0,0)
            handle.BorderColor3 = Color3.new(1,1,1)
            handle.BorderSizePixel = 2
            -- Text hiển thị giá trị (bên phải tên nếu cần)
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Parent = sliderContainer
            valueLabel.Size = UDim2.new(0.58, 0, 1, 0)
            valueLabel.Position = UDim2.new(0.4, 0, 1, -30)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextColor3 = Color3.new(1,1,1)
            valueLabel.TextSize = 18
            valueLabel.Text = tostring(init)..suffix
            valueLabel.TextXAlignment = Enum.TextXAlignment.Center
            -- Xử lý kéo thả handle
            local dragging = false
            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            handle.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    -- Tính giá trị mới theo vị trí trượt
                    local absPos = track.AbsolutePosition.X
                    local absSize = track.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X, absPos, absPos + absSize)
                    local ratio = (mouseX - absPos) / absSize
                    local value = math.floor((range[1] + ratio * (range[2]-range[1]))/inc + 0.5) * inc
                    value = math.clamp(value, range[1], range[2])
                    handle.Position = UDim2.new((value - range[1])/(range[2]-range[1]), 0, 0, 0)
                    valueLabel.Text = tostring(value)..suffix
                    callback(value)
                end
            end)
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end

        self.Tabs[#self.Tabs+1] = tabObj
        return tabObj
    end

    SimpleUI.ActiveWindow = window
    return window
end

return SimpleUI
