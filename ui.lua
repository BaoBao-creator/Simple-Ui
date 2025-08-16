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
            local name = config.Name or "Slider"
            local range = config.Range or {0, 100}
            local inc = config.Increment or 1
            local suffix = config.Suffix or ""
            local init = config.CurrentValue or range[1]
            local callback = config.Callback or function() end

            local sliderContainer = Instance.new("Frame")
            sliderContainer.Parent = contentScroll
            sliderContainer.Size = UDim2.new(1, 0, 0, 30)
            sliderContainer.BackgroundTransparency = 1

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = sliderContainer
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.Text = name

            local track = Instance.new("TextButton")
            track.Parent = sliderContainer
            track.Size = UDim2.new(0.58, 0, 0, 10)
            track.Position = UDim2.new(0.4, 0, 0.5, -5)
            track.BackgroundColor3 = Color3.new(1,1,1)

            local handle = Instance.new("Frame")
            handle.Parent = track
            handle.Size = UDim2.new(0, 14, 1.5, 0)
            handle.Position = UDim2.new((init - range[1])/(range[2]-range[1]), -7, 0, -3)
            handle.BackgroundColor3 = Color3.new(0,0,0)

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Parent = sliderContainer
            valueLabel.Size = UDim2.new(0.58, 0, 1, 0)
            valueLabel.Position = UDim2.new(0.4, 0, 1, -30)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextColor3 = Color3.new(1,1,1)
            valueLabel.Text = tostring(init)..suffix

            local function setValueFromX(x)
                local absPos = track.AbsolutePosition.X
                local absSize = track.AbsoluteSize.X
                local mouseX = math.clamp(x, absPos, absPos + absSize)
                local ratio = (mouseX - absPos) / absSize
                local value = math.floor((range[1] + ratio * (range[2]-range[1]))/inc + 0.5) * inc
                value = math.clamp(value, range[1], range[2])
                handle.Position = UDim2.new((value - range[1])/(range[2]-range[1]), -7, 0, -3)
                valueLabel.Text = tostring(value)..suffix
                callback(value)
            end

            track.MouseButton1Down:Connect(function()
                setValueFromX(UserInputService:GetMouseLocation().X)
                local moveConn
                local releaseConn
                moveConn = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        setValueFromX(input.Position.X)
                    end
                end)
                releaseConn = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        moveConn:Disconnect()
                        releaseConn:Disconnect()
                    end
                end)
            end)
        end

        -- Dropdown hỗ trợ multi
        function tabObj:CreateDropdown(config)
            local name = config.Name or "Dropdown"
            local options = config.Options or {}
            local multi = config.Multi or false
            local callback = config.Callback or function() end

            local dropContainer = Instance.new("Frame")
            dropContainer.Parent = contentScroll
            dropContainer.Size = UDim2.new(1, 0, 0, 30)
            dropContainer.BackgroundTransparency = 1

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = dropContainer
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.Text = name

            local selectedBtn = Instance.new("TextButton")
            selectedBtn.Parent = dropContainer
            selectedBtn.Size = UDim2.new(0.6, 0, 1, -6)
            selectedBtn.Position = UDim2.new(0.4, 0, 0, 3)
            selectedBtn.BackgroundColor3 = Color3.new(1,1,1)
            selectedBtn.TextColor3 = Color3.new(0,0,0)
            selectedBtn.Text = multi and "Chọn ▼" or (options[1] or "").." ▼"

            local optionsFrame = Instance.new("Frame")
            optionsFrame.Parent = dropContainer
            optionsFrame.Position = UDim2.new(0, 0, 0, 30)
            optionsFrame.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
            optionsFrame.Visible = false

            local optionsLayout = Instance.new("UIListLayout", optionsFrame)
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local selectedList = {}
            local current = options[1] or ""

            local function updateButtonText()
                if multi then
                    selectedBtn.Text = (#selectedList == 0) and "Chọn ▼" or (table.concat(selectedList, ", ") .. " ▼")
                else
                    selectedBtn.Text = current.." ▼"
                end
            end

            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Parent = optionsFrame
                optBtn.Size = UDim2.new(1, 0, 0, 25)
                optBtn.BackgroundColor3 = Color3.new(0,0,0)
                optBtn.TextColor3 = Color3.new(1,1,1)
                optBtn.Text = multi and "[ ] "..opt or opt

                local isSelected = false
                optBtn.MouseButton1Click:Connect(function()
                    if multi then
                        isSelected = not isSelected
                        if isSelected then
                            table.insert(selectedList, opt)
                            optBtn.Text = "[✔] "..opt
                        else
                            for i,v in ipairs(selectedList) do
                                if v == opt then
                                    table.remove(selectedList, i)
                                    break
                                end
                            end
                            optBtn.Text = "[ ] "..opt
                        end
                        updateButtonText()
                        callback(selectedList)
                    else
                        current = opt
                        updateButtonText()
                        optionsFrame.Visible = false
                        dropContainer.Size = UDim2.new(1, 0, 0, 30)
                        callback(current)
                    end
                end)
            end

            selectedBtn.MouseButton1Click:Connect(function()
                optionsFrame.Visible = not optionsFrame.Visible
                if optionsFrame.Visible then
                    optionsFrame.Size = UDim2.new(1, 0, 0, #options * 25)
                    dropContainer.Size = UDim2.new(1, 0, 0, 30 + #options * 25)
                else
                    dropContainer.Size = UDim2.new(1, 0, 0, 30)
                end
            end)
        end

        self.Tabs[#self.Tabs+1] = tabObj
        return tabObj
    end

    SimpleUI.ActiveWindow = window
    return window
end

return SimpleUI
