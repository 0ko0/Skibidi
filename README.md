### library
```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/0ko0/Skibidi/refs/heads/main/ok.lua",true))()
```


### Adding Tab
```lua
local tab = library:CreateWindow("Your Title")
```



### Adding Folder
```lua
local folder = tab:Addtab("tab")
```



### Adding Button
```lua
tab:AddButton({
	text = "Click me",
	flag = "button",
	callback = function()
	print("hello world")
end
})
```




### Adding Toggle
```lua
tab:AddToggle({
    text = "test",
    state = false, 
    flag = "toggle",
    callback = function(Value)
        print("1")
    end
})
```




### Adding Label
```lua
tab:AddLabel({
    text = "hello",
    align = "Left" -- "Left", "Center", "Right"
})
```





### Adding Slider
```lua
tab:AddSlider({
    text = "speed",
    min = 16,
    max = 100,
    value = 16, 
    float = 1, 
    flag = "SpeedSlider",
    callback = function(Value)
        print("speed", Value)
    end
})
```





### Adding color
```lua
tab:AddColor({
    text = "color",
    color = Color3.fromRGB(255, 0, 0), 
    transparency = 0, 
    flag = "EColor",
    callback = function(Color, Transparency)
        print("color:", Color)
    end
})
```





### Adding Dropdown
```lua
tab:AddList({
    text = "select",
    values = {"1", "2", "3"},
    value = "1", 
    multiselect = false, 
    flag = "List",
    callback = function(Value)
        print("select:", Value)
    end
})
```

### Adding textbox
```lua
tab:AddBox({
    text = "test",
    value = "", 
    placeholder = "type here...",
    clearOnFocus = false,
    numeric = false, -- enter numbers only if true
    flag = "NameBox",
    callback = function(Value, enterPressed)
        if enterPressed then
            print("=>:", Value)
        end
    end
})
```


### Adding Notification
```lua
library:Notify({
    Title = "hello",
    Text = "hello",
    Duration = 5,
    Type = "success" -- "info", "success", "warning", "error"
})
```



### Adding Bind
```lua
tab:AddBind({
    text = "hide ui",
    key = "RightControl", 
    hold = false, -- true: Hold the key to activate || false: Press the key to activate
    flag = "bind",
    callback = function(Holding)        
        library:Close()
    end
})
```

### Close Lib
```lua
library:Close()
```



### Final (REQUIRED OR THE UI WILL NOT SHOW)
```lua
library:Init()
```
