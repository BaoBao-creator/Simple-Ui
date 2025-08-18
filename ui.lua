local SimpleUI = {}
-- Tạo ScreenGui chính để chứa tất cả UI
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Hàm hỗ trợ kéo thả GUI (như gợi ý từ DevForum910)
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

-- Tạo nút vuông "S" để bật/tắt giao diện
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.AnchorPoint = Vector2.new(0, 0)
toggleButton.BackgroundColor3 = Color3.new(0,0,0)
toggleButton.BorderColor3 = Color3.new(1,1,1)
toggleButton.BorderSizePixel = 2
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "S"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.TextSize = 18
-- Kéo thả được
makeDraggable(toggleButton)
-- Khi nhấn, bật/tắt cửa sổ chính (nếu đã tạo)
toggleButton.MouseButton1Click:Connect(function()
    if SimpleUI.ActiveWindow and SimpleUI.ActiveWindow.Frame then
        local w = SimpleUI.ActiveWindow
        w.Frame.Visible = not w.Frame.Visible
    end
end)

-- Hàm tạo cửa sổ chính (Window)
function SimpleUI:CreateWindow(params)
    -- Thông tin tham số (chỉ dùng Name làm tiêu đề)
    local titleText = params.Name or "Window"
    -- Tạo Frame chính
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "SimpleHubFrame"
    windowFrame.Size = UDim2.new(0, 600, 0, 400)
    windowFrame.Position = UDim2.new(0, 50, 0, 50)
    windowFrame.BackgroundColor3 = Color3.new(0,0,0)
    windowFrame.BorderColor3 = Color3.new(1,1,1)
    windowFrame.BorderSizePixel = 2
    windowFrame.Parent = screenGui
    windowFrame.Visible = true
    -- Tạo thanh tiêu đề
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = windowFrame
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.new(0,0,0)
    titleBar.BorderColor3 = Color3.new(1,1,1)
    titleBar.BorderSizePixel = 0
    -- Text tiêu đề ở góc trái
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
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    -- Cho phép kéo thả cửa sổ qua thanh tiêu đề
    makeDraggable(windowFrame, titleBar)
    -- Hai cột: bên trái (tab list) và bên phải (nội dung)
    -- Cột trái: ScrollingFrame cho danh sách tab
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Parent = windowFrame
    tabList.Size = UDim2.new(0, 150, 1, -30)
    tabList.Position = UDim2.new(0, 0, 0, 30)
    tabList.BackgroundColor3 = Color3.new(0,0,0)
    tabList.BorderColor3 = Color3.new(1,1,1)
    tabList.BorderSizePixel = 2
    tabList.ScrollBarThickness = 6
    -- Sử dụng UIListLayout để tự động xếp các nút tab theo chiều dọc
    local tabLayout = Instance.new("UIListLayout", tabList)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    -- Lưu trữ cửa sổ và tab
    local window = {}
    window.Frame = windowFrame
    window.TabList = tabList
    window.Tabs = {}
    -- Phương thức tạo tab mới
    function window:CreateTab(name)
        -- Tạo nút tab ở cột trái
        local tabIndex = #self.Tabs + 1
        local btn = Instance.new("TextButton")
        btn.Name = "TabButton_"..name
        btn.Parent = self.TabList
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.new(0,0,0)
        btn.BorderColor3 = Color3.new(1,1,1)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.SourceSans
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 18
        btn.Text = name
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = tabIndex
        -- Cập nhật chiều cao khả dụng của tabList
        tabList.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 5)
        -- Tạo khung nội dung cho tab mới (mặc định ẩn)
        local contentFrame = Instance.new("Frame")
        contentFrame.Name = "Content_"..name
        contentFrame.Parent = windowFrame
        -- Đặt contentFrame nằm trong vùng bên phải
        contentFrame.Size = UDim2.new(1, -160, 1, -30)
        contentFrame.Position = UDim2.new(0, 160, 0, 30)
        contentFrame.BackgroundColor3 = Color3.new(0,0,0)
        contentFrame.BorderColor3 = Color3.new(1,1,1)
        contentFrame.BorderSizePixel = 0
        contentFrame.Visible = (tabIndex == 1)  -- hiển thị tab đầu tiên
        -- ScrollingFrame bên trong contentFrame để chứa phần tử (nếu cần cuộn)
        local contentScroll = Instance.new("ScrollingFrame")
        contentScroll.Name = "ContentScroll"
        contentScroll.Parent = contentFrame
        contentScroll.Size = UDim2.new(1, -10, 1, -10)
        contentScroll.Position = UDim2.new(0, 5, 0, 5)
        contentScroll.BackgroundTransparency = 1
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentScroll.ScrollBarThickness = 6
        -- Layout vertical cho nội dung
        local contentLayout = Instance.new("UIListLayout", contentScroll)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 5)
        -- Đối tượng tab
        local tabObj = {Button = btn, Frame = contentFrame, Content = contentScroll}
        tabObj._index = tabIndex
        -- Khi nhấn nút tab: ẩn hết các tab khác, hiện tab này
        btn.MouseButton1Click:Connect(function()
            for _,t in ipairs(window.Tabs) do
                t.Frame.Visible = false
                t.Button.BackgroundColor3 = Color3.new(0,0,0)
                t.Button.TextColor3 = Color3.new(1,1,1)
            end
            tabObj.Frame.Visible = true
            btn.BackgroundColor3 = Color3.new(1,1,1)
            btn.TextColor3 = Color3.new(0,0,0)
        end)
        -- Hàm tạo Toggle trong tab này
        function tabObj:CreateToggle(config)
            config = config or {}
            local name = config.Name or "Toggle"
            local init = config.CurrentValue or false
            local callback = config.Callback or function() end
            -- Container khung cho toggle (để đặt label + nút)
            local toggleContainer = Instance.new("Frame")
            toggleContainer.Name = "Toggle_"..name
            toggleContainer.Parent = contentScroll
            toggleContainer.BackgroundTransparency = 1
            toggleContainer.Size = UDim2.new(1, 0, 0, 30)
            toggleContainer.LayoutOrder = contentLayout.AbsoluteContentSize.Y
            -- Label tên ở bên trái
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = toggleContainer
            nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextSize = 18
            nameLabel.Text = name
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            -- Nút toggle ở bên phải
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Parent = toggleContainer
            toggleBtn.Size = UDim2.new(0.3, 0, 1, -6)
            toggleBtn.Position = UDim2.new(0.6, 0, 0, 3)
            toggleBtn.Font = Enum.Font.SourceSans
            toggleBtn.TextSize = 18
            toggleBtn.BorderColor3 = Color3.new(1,1,1)
            toggleBtn.BorderSizePixel = 2
            -- Giao diện ban đầu
            local function updateToggle()
                if init then
                    toggleBtn.BackgroundColor3 = Color3.new(1,1,1)
                    toggleBtn.TextColor3 = Color3.new(0,0,0)
                    toggleBtn.Text = "ON"
                else
                    toggleBtn.BackgroundColor3 = Color3.new(0,0,0)
                    toggleBtn.TextColor3 = Color3.new(1,1,1)
                    toggleBtn.Text = "OFF"
                end
            end
            updateToggle()
            -- Xử lý khi nhấn đổi trạng thái
            toggleBtn.MouseButton1Click:Connect(function()
                init = not init
                updateToggle()
                callback(init)
            end)
            -- Cập nhật kích thước canvas sau khi thêm
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end
        -- Hàm tạo Button (nút bấm) trong tab này
        function tabObj:CreateButton(config)
            config = config or {}
            local name = config.Name or "Button"
            local callback = config.Callback or function() end
            local btn = Instance.new("TextButton")
            btn.Name = name
            btn.Parent = contentScroll
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.LayoutOrder = contentLayout.AbsoluteContentSize.Y
            btn.BackgroundColor3 = Color3.new(0,0,0)
            btn.BorderColor3 = Color3.new(1,1,1)
            btn.BorderSizePixel = 2
            btn.Font = Enum.Font.SourceSans
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextSize = 18
            btn.Text = name
            btn.MouseButton1Click:Connect(function()
                callback()
            end)
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end
        -- Hàm tạo TextBox (ô nhập văn bản)
        function tabObj:CreateTextBox(config)
            config = config or {}
            local name = config.Name or "Input"
            local placeholder = config.PlaceholderText or ""
            local removeText = config.RemoveTextAfterFocusLost or false
            local charLimit = config.CharacterLimit or 0
            local numbersOnly = config.NumbersOnly or false
            local callback = config.Callback or function() end
            -- Container khung cho input
            local inputContainer = Instance.new("Frame")
            inputContainer.Name = "Input_"..name
            inputContainer.Parent = contentScroll
            inputContainer.BackgroundTransparency = 1
            inputContainer.Size = UDim2.new(1, 0, 0, 30)
            inputContainer.LayoutOrder = contentLayout.AbsoluteContentSize.Y
            -- Label tên ở trái
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = inputContainer
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextSize = 18
            nameLabel.Text = name
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            -- TextBox ở phải
            local textBox = Instance.new("TextBox")
            textBox.Parent = inputContainer
            textBox.Size = UDim2.new(0.6, 0, 1, -6)
            textBox.Position = UDim2.new(0.4, 0, 0, 3)
            textBox.BackgroundColor3 = Color3.new(1,1,1)
            textBox.BorderColor3 = Color3.new(0,0,0)
            textBox.Font = Enum.Font.SourceSans
            textBox.TextColor3 = Color3.new(0,0,0)
            textBox.TextSize = 18
            textBox.ClearTextOnFocus = removeText
            textBox.PlaceholderText = placeholder
            if charLimit > 0 then
                textBox.MaxLength = charLimit
            end
            if numbersOnly then
                textBox:GetPropertyChangedSignal("Text"):Connect(function()
                    textBox.Text = textBox.Text:gsub("%D","")
                end)
            end
            -- Gọi callback khi nhập xong (FocusLost)
            textBox.FocusLost:Connect(function(enterPressed)
                callback(textBox.Text)
            end)
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
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
            local startIndex = 1
            local maxVisible = 5
            local function renderOptions()
                optionsFrame:ClearAllChildren()
                optionsLayout.Parent = optionsFrame
                if startIndex > 1 then
                    local prevBtn = Instance.new("TextButton")
                    prevBtn.Parent = optionsFrame
                    prevBtn.Size = UDim2.new(1, 0, 0, 25)
                    prevBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
                    prevBtn.TextColor3 = Color3.new(1,1,1)
                    prevBtn.Text = "..."
                    prevBtn.MouseButton1Click:Connect(function()
                        startIndex = math.max(1, startIndex - maxVisible)
                        renderOptions()
                    end)
                end
                for i = startIndex, math.min(startIndex + maxVisible - 1, #options) do
                    local opt = options[i]
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
                if startIndex + maxVisible - 1 < #options then
                    local nextBtn = Instance.new("TextButton")
                    nextBtn.Parent = optionsFrame
                    nextBtn.Size = UDim2.new(1, 0, 0, 25)
                    nextBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
                    nextBtn.TextColor3 = Color3.new(1,1,1)
                    nextBtn.Text = "..."
                    nextBtn.MouseButton1Click:Connect(function()
                        startIndex = math.min(#options - maxVisible + 1, startIndex + maxVisible)
                        renderOptions()
                    end)
                end
                local count = optionsFrame.UIListLayout.AbsoluteContentSize.Y
                optionsFrame.Size = UDim2.new(1, 0, 0, count)
                dropContainer.Size = UDim2.new(1, 0, 0, 30 + count)
            end
            selectedBtn.MouseButton1Click:Connect(function()
                optionsFrame.Visible = not optionsFrame.Visible
                if optionsFrame.Visible then
                    renderOptions()
                else
                    dropContainer.Size = UDim2.new(1, 0, 0, 30)
                end
            end)
        end
        -- Hàm tạo Slider (thanh trượt)
        function tabObj:CreateSlider(config)
            config = config or {}
            local name = config.Name or "Slider"
            local range = config.Range or {0, 100}
            local inc = config.Increment or 1
            local suffix = config.Suffix or ""
            local init = config.CurrentValue or range[1]
            local callback = config.Callback or function() end

            local sliderContainer = Instance.new("Frame")
            sliderContainer.Name = "Slider_"..name
            sliderContainer.Parent = contentScroll
            sliderContainer.BackgroundTransparency = 1
            sliderContainer.Size = UDim2.new(1, 0, 0, 45)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = sliderContainer
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextSize = 18
            nameLabel.Text = name
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left

            local track = Instance.new("Frame")
            track.Parent = sliderContainer
            track.Size = UDim2.new(0.55, 0, 0, 10)
            track.Position = UDim2.new(0.42, 0, 0.5, -5)
            track.BackgroundColor3 = Color3.new(1,1,1)
            track.BorderColor3 = Color3.new(0,0,0)
            track.BorderSizePixel = 2

            local handle = Instance.new("Frame")
            handle.Parent = track
            handle.Size = UDim2.new(0, 16, 1, 0)
            handle.BackgroundColor3 = Color3.new(0,0,0)
            handle.BorderColor3 = Color3.new(1,1,1)
            handle.BorderSizePixel = 2
            handle.Position = UDim2.new((init - range[1])/(range[2]-range[1]), 0, 0, 0)

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Parent = track
            valueLabel.Size = UDim2.new(0, 50, 1, -20)
            valueLabel.Position = UDim2.new(0.5, -25, -1, 0) -- nằm trên thanh trượt
            valueLabel.BackgroundTransparency = 1
            valueLabel.Font = Enum.Font.SourceSansBold
            valueLabel.TextColor3 = Color3.new(1,1,1)
            valueLabel.TextSize = 16
            valueLabel.Text = tostring(init)..suffix
            valueLabel.TextXAlignment = Enum.TextXAlignment.Center

            local dragging = false
            local currentValue = init

            local function updateValueFromX(mouseX)
                local absPos = track.AbsolutePosition.X
                local absSize = track.AbsoluteSize.X
                local clamped = math.clamp(mouseX, absPos, absPos + absSize)
                local ratio = (clamped - absPos) / absSize
                local value = math.floor((range[1] + ratio * (range[2]-range[1]))/inc + 0.5) * inc
                value = math.clamp(value, range[1], range[2])
                currentValue = value
                handle.Position = UDim2.new((value - range[1])/(range[2]-range[1]), 0, 0, 0)
                valueLabel.Text = tostring(value)..suffix
            end

            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateValueFromX(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    dragging = false
                    callback(currentValue)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateValueFromX(input.Position.X)
                end
            end)

            contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end

        -- Thêm tab vào danh sách
        self.Tabs[#self.Tabs+1] = tabObj
        return tabObj
    end

    -- Lưu cửa sổ vừa tạo
    SimpleUI.ActiveWindow = window
    return window
end

-- Hàm tạo thông báo trên màn hình (giống Rayfield:Notify11)
function SimpleUI:Notify(params)
    params = params or {}
    local title = params.Title or ""
    local content = params.Content or ""
    local duration = params.Duration or 2
    -- Tạo frame thông báo
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Parent = screenGui
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(0.5, -150, 0, 10)
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.BackgroundColor3 = Color3.new(0,0,0)
    notif.BorderColor3 = Color3.new(1,1,1)
    notif.BorderSizePixel = 2
    -- Tiêu đề
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notif
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.TextSize = 18
    titleLabel.Text = title
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    -- Nội dung
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Parent = notif
    contentLabel.Size = UDim2.new(1, -20, 1, -50)
    contentLabel.Position = UDim2.new(0, 10, 0, 40)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.TextColor3 = Color3.new(1,1,1)
    contentLabel.TextSize = 16
    contentLabel.TextWrapped = true
    contentLabel.Text = content
    contentLabel.TextXAlignment = Enum.TextXAlignment.Center
    -- Tự động xóa sau duration
    delay(duration, function()
        if notif then notif:Destroy() end
    end)
end

return SimpleUI
