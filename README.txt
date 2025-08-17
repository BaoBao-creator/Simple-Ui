Load Simple UI
------------------
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
------------------------------
Create window
-----------------
local window = simpleui:CreateWindow({Name= "Simple Hub, BaoBao developer"})
---------------------------------------
Create a tab
--------------
local tab = window:CreateTab("Tab")
------------------
Create a toggle
--------------------
tab:CreateToggle({
    Name = "Toggle",
    CurrentValue = false,
    Callback = function(v)
        print(v)
    end
})
------------------
Create a textbox
-----------------
tab:CreateTextBox({
    Name = "Input",
    PlaceholderText = "",
    RemoveTextAfterFocusLost = false,
    CharacterLimit = 0,
    NumbersOnly = false,
    Callback = function(v)
        print(v)
    end
})
----------------------------
Create a dropdown 
-------------------
tab:CreateDropdown({
    Name = "Dropdown",
    Options = {},
    Multi = false,
    Callback = function(v) 
        print(v)
    end
})
