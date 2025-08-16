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
    Callback = function(v) -- The function run when toggle change, v is the value true/false
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
