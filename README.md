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
