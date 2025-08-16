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
        -- Hàm tạo Dropdown (menu chọn)
        function tabObj:CreateDropdown(config)
            config = config or {}
            local name = config.Name or "Dropdown"
            local options = config.Options or {}
            local callback = config.Callback or function() end
            -- Container khung cho dropdown
            local dropContainer = Instance.new("Frame")
            dropContainer.Name = "Dropdown_"..name
            dropContainer.Parent = contentScroll
            dropContainer.BackgroundTransparency = 1
            dropContainer.Size = UDim2.new(1, 0, 0, 30)
            dropContainer.LayoutOrder = contentLayout.AbsoluteContentSize.Y
            -- Label tên
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = dropContainer
            nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextSize = 18
            nameLabel.Text = name
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            -- Nút hiển thị tùy chọn đã chọn
            local selectedBtn = Instance.new("TextButton")
            selectedBtn.Parent = dropContainer
            selectedBtn.Size = UDim2.new(0.6, 0, 1, -6)
            selectedBtn.Position = UDim2.new(0.4, 0, 0, 3)
            selectedBtn.BackgroundColor3 = Color3.new(1,1,1)
            selectedBtn.BorderColor3 = Color3.new(0,0,0)
            selectedBtn.Font = Enum.Font.SourceSans
            selectedBtn.TextColor3 = Color3.new(0,0,0)
            selectedBtn.TextSize = 18
            -- Tạo khung chứa các tùy chọn, ban đầu ẩn
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Parent = dropContainer
            optionsFrame.Size = UDim2.new(1, 0, 0, 0)
            optionsFrame.Position = UDim2.new(0, 0, 0, 30)
            optionsFrame.BackgroundTransparency = 0
            optionsFrame.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
            optionsFrame.Visible = false
            local optionsLayout = Instance.new("UIListLayout", optionsFrame)
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Padding = UDim.new(0, 2)
            -- Khởi tạo lựa chọn đầu tiên
            local current = options[1] or ""
            selectedBtn.Text = current.." ▼"
            -- Tạo các nút chọn
            for i,opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Parent = optionsFrame
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.LayoutOrder = i
                optBtn.BackgroundColor3 = Color3.new(0,0,0)
                optBtn.BorderColor3 = Color3.new(1,1,1)
                optBtn.BorderSizePixel = 2
                optBtn.Font = Enum.Font.SourceSans
                optBtn.TextColor3 = Color3.new(1,1,1)
                optBtn.TextSize = 18
                optBtn.Text = opt
                optBtn.TextXAlignment = Enum.TextXAlignment.Left
                optBtn.MouseButton1Click:Connect(function()
                    current = opt
                    selectedBtn.Text = current.." ▼"
                    optionsFrame.Visible = false
                    dropContainer.Size = UDim2.new(1, 0, 0, 30)
                    -- Cập nhật canvas sau khi thu gọn
                    contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
                    callback(current)
                end)
            end
            -- Khi nhấn nút, toggle danh sách options
            selectedBtn.MouseButton1Click:Connect(function()
                if optionsFrame.Visible then
                    optionsFrame.Visible = false
                    dropContainer.Size = UDim2.new(1, 0, 0, 30)
                else
                    local optCount = #options
                    optionsFrame.Size = UDim2.new(1, 0, 0, optCount*30)
                    optionsFrame.Visible = true
                    dropContainer.Size = UDim2.new(1, 0, 0, 30 + optCount*30)
                end
                contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
            end)
            contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
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
