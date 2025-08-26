--// Load Simple UI
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()

--// Create Window
local window = simpleui:CreateWindow({Name = "✨ Simple Hub - BaoBao Developer"})

--// Create Tab
local tab = window:CreateTab("Main Tab")

--// 🔘 Toggle
tab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end
})

--// ⏺️ Button
tab:CreateButton({
    Name = "Claim Reward",
    Callback = function()
        print("Reward claimed!")
    end
})

--// 📝 TextBox
tab:CreateTextBox({
    Name = "Enter Username",
    Placeholder = "Type here...",
    CurrentValue = "",
    Callback = function(v)
        print("Username:", v)
    end
})

--// 📂 Dropdown
local dropdown = tab:CreateDropdown({
    Name = "Select Pet",
    Options = {"Dog", "Cat", "Bird"},
    Multi = false, -- true = multi select
    Callback = function(v)
        if v ~= nil then
            print("Selected:", v)
        else
            -- return new list when refresh button is pressed
            return {"Dog", "Cat", "Bird", "Dragon"}
        end
    end
})

-- Example usage of Dropdown API:
-- dropdown:SetOptions({"Apple", "Banana", "Orange"})
-- print(dropdown:GetValue())
-- dropdown:Refresh()

--// 🎚️ Slider
tab:CreateSlider({
    Name = "Volume",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 50,
    Callback = function(v)
        print("Volume:", v)
    end
})

--// 🔔 Notification
simpleui:Notify({
    Title = "Simple UI",
    Content = "Welcome to Simple Hub!",
    Duration = 3
})
