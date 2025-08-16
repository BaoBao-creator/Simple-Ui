Load Simple UI
------------------
local simpleui = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaoBao-creator/Simple-Ui/main/ui.lua"))()
------------------------------
Create a toggle
--------------------
CreateToggle({
    Name = "Toggle",
    CurrentValue = false,
    Callback = function(v) -- The function run when toggle change, v is the value true/false
        print(v)
    end
})
----------------------------
