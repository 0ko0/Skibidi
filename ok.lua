local library = {flags = {}, windows = {}, open = true}

--Services
local runService = game:GetService"RunService"
local tweenService = game:GetService"TweenService"
local textService = game:GetService"TextService"
local inputService = game:GetService"UserInputService"
local ui = Enum.UserInputType.MouseButton1
--Locals

local shortKeys = {
	LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift",
	LeftAlt = "LAlt", RightAlt = "RAlt", MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
	Insert = "Ins", Delete = "Del", Backspace = "Back", Return = "Enter", Escape = "Esc",
	PageUp = "PgUp", PageDown = "PgDn", Space = "Space", Unknown = "None"
}

local function formatKey(keyName)
	if not keyName or keyName == "" then return "None" end
	return shortKeys[keyName] or keyName
end

local dragging, dragInput, dragStart, startPos, dragObject

--Functions
local function round(num, bracket)
	bracket = bracket or 1
	local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
	if a < 0 then
		a = a + bracket
	end
	return a
end

local function keyCheck(x,x1)
	for _,v in next, x1 do
		if v == x then
			return true
		end
	end
end

local function update(input)
	local delta = input.Position - dragStart
	local yPos = (startPos.Y.Offset + delta.Y) < -36 and -36 or startPos.Y.Offset + delta.Y
	dragObject:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos), "Out", "Quint", 0.1, true)
end
 
--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
local chromaColor
local rainbowTime = 5
spawn(function()
	while wait() do
		chromaColor = Color3.fromHSV(tick() % rainbowTime / rainbowTime, 1, 1)
	end
end)

function library:Create(class, properties)
	properties = typeof(properties) == "table" and properties or {}
	local inst = Instance.new(class)
	for property, value in next, properties do
		inst[property] = value
	end
	return inst
end

local function createOptionHolder(holderTitle, parent, parentTable, subHolder)
	local size = subHolder and 34 or 40
	parentTable.main = library:Create("ImageButton", {
		LayoutOrder = subHolder and parentTable.position or 0,
		Position = UDim2.new(0, 20 + (250 * (parentTable.position or 0)), 0, 20),
		Size = UDim2.new(0, 230, 0, size),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.04,
		ClipsDescendants = true,
		Parent = parent
	})
	
	local round
	if not subHolder then
		round = library:Create("ImageLabel", {
			Size = UDim2.new(1, 0, 0, size),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = parentTable.open and (subHolder and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)) or (subHolder and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.04,
			Parent = parentTable.main
		})
	end
	
	local title = library:Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, size),
		BackgroundTransparency = subHolder and 0 or 1,
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderSizePixel = 0,
		Text = holderTitle,
		TextSize = subHolder and 16 or 17,
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Parent = parentTable.main
	})
	
	local closeHolder = library:Create("Frame", {
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(-1, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Parent = title
	})
	
	local close = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -size - 10, 1, -size - 10),
		Rotation = parentTable.open and 90 or 180,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Fit,
		Parent = closeHolder
	})
	
	parentTable.content = library:Create("Frame", {
		Position = UDim2.new(0, 0, 0, size),
		Size = UDim2.new(1, 0, 1, -size),
		BackgroundTransparency = 1,
		Parent = parentTable.main
	})
	
	local layout = library:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parentTable.content
	})
	
	layout.Changed:connect(function()
		parentTable.content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
		parentTable.main.Size = #parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size)
	end)
	
	if not subHolder then
		library:Create("UIPadding", {
			Parent = parentTable.content
		})
		
		title.InputBegan:connect(function(input)
			if input.UserInputType == ui then
				dragObject = parentTable.main
				dragging = true
				dragStart = input.Position
				startPos = dragObject.Position
			elseif input.UserInputType == Enum.UserInputType.Touch then
				dragObject = parentTable.main
				dragging = true
				dragStart = input.Position
				startPos = dragObject.Position
			end
		end)
		title.InputChanged:connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			elseif dragging and input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
			title.InputEnded:connect(function(input)
			if input.UserInputType == ui then
				dragging = false
			elseif input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end
	
	closeHolder.InputBegan:connect(function(input)
		if input.UserInputType == ui then
			parentTable.open = not parentTable.open
			tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = parentTable.open and 90 or 180, ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
			if subHolder then
				tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = parentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
			else
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
			end
			parentTable.main:TweenSize(#parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size), "Out", "Quad", 0.2, true)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			parentTable.open = not parentTable.open
			tweenService:Create(close, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = parentTable.open and 90 or 180, ImageColor3 = parentTable.open and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)}):Play()
			if subHolder then
				tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = parentTable.open and Color3.fromRGB(16, 16, 16) or Color3.fromRGB(10, 10, 10)}):Play()
			else
				tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = parentTable.open and Color3.fromRGB(10, 10, 10) or Color3.fromRGB(6, 6, 6)}):Play()
			end
			parentTable.main:TweenSize(#parentTable.options > 0 and parentTable.open and UDim2.new(0, 230, 0, layout.AbsoluteContentSize.Y + size) or UDim2.new(0, 230, 0, size), "Out", "Quad", 0.2, true)
		end
	end)

	function parentTable:SetTitle(newTitle)
		title.Text = tostring(newTitle)
	end
	
	return parentTable
end
	
local function createLabel(option, parent)
	local padding = 10
	
	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = parent.content
	})

	
	local textLabel = library:Create("TextLabel", {
		Size = UDim2.new(1, -(padding * 2), 1, 0),
		Position = UDim2.new(0, padding, 0, 0),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = option.textSize or 15,
		Font = Enum.Font[option.font or "GothamMedium"], 
		TextColor3 = option.color or Color3.fromRGB(240, 240, 240),
		TextXAlignment = Enum.TextXAlignment[option.align or "Left"],
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true, 
		TextWrapped = true, 
		Parent = main
	})

	
	local function updateSize()
		local bounds = textService:GetTextSize(
			textLabel.Text, 
			textLabel.TextSize, 
			textLabel.Font, 
			Vector2.new(textLabel.AbsoluteSize.X, 9e9)
		)
		
		main.Size = UDim2.new(1, 0, 0, math.max(26, bounds.Y + 10))
	end

	textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
	textLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)

	
	function option:SetText(newText)
		textLabel.Text = tostring(newText)
	end
    
	
	function option:SetColor(newColor)
		textLabel.TextColor3 = typeof(newColor) == "Color3" and newColor or Color3.fromRGB(255, 255, 255)
	end

	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" or i == "text" then
			textLabel.Text = tostring(v)
		end
	end})
	
	
	task.spawn(updateSize)
	
	return option
end

function createToggle(option, parent)
	
	local main = library:Create("TextButton", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 34), 
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = parent.content
	})
	
	
	local titleText = library:Create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 17,
		Font = Enum.Font.SourceSans,
		TextColor3 = option.state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local switchBg = library:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 38, 0, 18),
		BackgroundColor3 = option.state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 25),
		Parent = main
	})
	
	library:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = switchBg
	})
	
	
	local stroke = library:Create("UIStroke", {
		Color = Color3.fromRGB(70, 70, 70),
		Thickness = 1.2,
		Transparency = option.state and 1 or 0, 
		Parent = switchBg
	})
	
	
	local switchCircle = library:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = option.state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundColor3 = option.state and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(150, 150, 150),
		Parent = switchBg
	})
	
	library:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = switchCircle
	})
	
	local inContact = false

	
	main.InputBegan:connect(function(input)
		if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			option:SetState(not option.state)
		end
		
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.state then
				tweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(110, 110, 110)}):Play()
				tweenService:Create(titleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
			end
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not option.state then
				tweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(70, 70, 70)}):Play()
				tweenService:Create(titleText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
			end
		end
	end)
	
	
	function option:SetState(state)
		library.flags[self.flag] = state
		self.state = state
		
		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		
		tweenService:Create(switchBg, tweenInfo, {
			BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(25, 25, 25)
		}):Play()
		
		tweenService:Create(switchCircle, tweenInfo, {
			Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			BackgroundColor3 = state and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(150, 150, 150)
		}):Play()
		
		tweenService:Create(stroke, tweenInfo, {
			Transparency = state and 1 or 0,
			Color = state and Color3.fromRGB(255, 255, 255) or (inContact and Color3.fromRGB(110, 110, 110) or Color3.fromRGB(70, 70, 70))
		}):Play()
		
		tweenService:Create(titleText, tweenInfo, {
			TextColor3 = state and Color3.fromRGB(255, 255, 255) or (inContact and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(180, 180, 180))
		}):Play()
		
		
		task.spawn(function()
			pcall(self.callback, state)
		end)
	end

	
	if option.state then
		task.delay(0.1, function() 
			task.spawn(function() pcall(option.callback, true) end)
		end)
	end
	
	
	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" then
			titleText.Text = tostring(v)
		end
	end})
end

function createButton(option, parent)
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local buttonFrame = library:Create("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		ClipsDescendants = true,
		AutoButtonColor = false,
		Parent = main
	})
	
	local btnText = library:Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 15,
		Font = Enum.Font.GothamSemibold, 
		TextColor3 = Color3.fromRGB(200, 200, 200),
		Parent = buttonFrame
	})
	
	
	local function createRipple(input)
		local ripple = library:Create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://3570695787",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0.6,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 1,
			ZIndex = 5,
			Parent = buttonFrame
		})
		
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = ripple
		
		local absolutePos = buttonFrame.AbsolutePosition
		local mousePos = input.Position
		
		
		local localX = (mousePos.X > 0) and (mousePos.X - absolutePos.X) or (buttonFrame.AbsoluteSize.X / 2)
		local localY = (mousePos.Y > 0) and (mousePos.Y - absolutePos.Y) or (buttonFrame.AbsoluteSize.Y / 2)
		
		ripple.Position = UDim2.new(0, localX, 0, localY)
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		
		
		local maxSize = math.max(buttonFrame.AbsoluteSize.X, buttonFrame.AbsoluteSize.Y) * 1.5
		
		local tween = tweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, maxSize, 0, maxSize),
			ImageTransparency = 1
		})
		tween:Play()
		
		
		coroutine.wrap(function()
			tween.Completed:Wait()
			ripple:Destroy()
		end)()
	end

	local inContact = false
	local isClicking = false

	buttonFrame.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not isClicking then
				tweenService:Create(buttonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(55, 55, 55)}):Play()
				tweenService:Create(btnText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end
		elseif input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			isClicking = true
			library.flags[option.flag] = true
			
			
			createRipple(input)
			
			
			tweenService:Create(buttonFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, -16, 1, -14),
				ImageColor3 = Color3.fromRGB(70, 70, 70)
			}):Play()
			tweenService:Create(btnText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextSize = 14
			}):Play()
			
			option.callback()
		end
	end)

	buttonFrame.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not isClicking then
				tweenService:Create(buttonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
				tweenService:Create(btnText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
			end
		elseif input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			isClicking = false
			
			local endColor = inContact and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(40, 40, 40)
			local endTextColor = inContact and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
			
			
			tweenService:Create(buttonFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, -12, 1, -10),
				ImageColor3 = endColor
			}):Play()
			tweenService:Create(btnText, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				TextSize = 15,
				TextColor3 = endTextColor
			}):Play()
		end
	end)
end

local function createBind(option, parent)
	local binding = false
	local holding = false
	local currentKey = option.key or "None"
	
	local main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local bindContainer = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.new(0, 40, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local bindText = library:Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = formatKey(currentKey),
		TextSize = 15,
		Font = Enum.Font.SourceSansSemibold,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		Parent = bindContainer
	})

	
	local function updateBindSize()
		local textBounds = textService:GetTextSize(bindText.Text, 15, Enum.Font.SourceSansSemibold, Vector2.new(9e9, 9e9))
		bindContainer:TweenSize(UDim2.new(0, textBounds.X + 16, 1, -10), "Out", "Quad", 0.15, true)
	end
	updateBindSize()

	
	local pulseTween = tweenService:Create(bindContainer, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageColor3 = Color3.fromRGB(80, 80, 80)})

	local inContact
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not binding then
				tweenService:Create(bindContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				tweenService:Create(bindText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end
		elseif input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			if not binding then
				binding = true
				bindText.Text = "..."
				updateBindSize()
				pulseTween:Play() 
			end
		end
	end)
	 
	main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not binding then
				tweenService:Create(bindContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
				tweenService:Create(bindText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
			end
		end
	end)
	
	
	inputService.InputBegan:Connect(function(input, gameProcessed)
		if binding then
			local key = input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name
			
			
			if string.find(key, "MouseMovement") or string.find(key, "Touch") then return end

			pulseTween:Cancel() 
			
			if key == "Escape" then
				
				option:SetKey(currentKey)
			elseif key == "Backspace" or key == "Delete" then
				
				option:SetKey("None")
			else
				
				option:SetKey(key)
			end
		else
			if gameProcessed then return end 
			if currentKey ~= "None" then
				if input.KeyCode.Name == currentKey or input.UserInputType.Name == currentKey then
					if option.hold then
						holding = true
						option.callback(true)
					else
						option.callback()
					end
				end
			end
		end
	end)
	
	inputService.InputEnded:Connect(function(input)
		if not binding and option.hold and holding then
			if input.KeyCode.Name == currentKey or input.UserInputType.Name == currentKey then
				holding = false
				option.callback(false)
			end
		end
	end)
	
	function option:SetKey(key)
		binding = false
		currentKey = key
		self.key = key
		library.flags[self.flag] = key
		
		bindText.Text = formatKey(key)
		updateBindSize()
		
		
		local endColor = inContact and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)
		tweenService:Create(bindContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = endColor}):Play()
	end
end

local function createSlider(option, parent)
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local title = library:Create("TextLabel", {
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local sliderBg = library:Create("ImageLabel", {
		Position = UDim2.new(0, 10, 0, 34),
		Size = UDim2.new(1, -20, 0, 5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local fill = library:Create("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = sliderBg
	})
	
	local circle = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0), 
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 1,
		Parent = fill
	})
	
	local valueRound = library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(0, -60, 0, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local inputvalue = library:Create("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = tostring(option.value),
		TextColor3 = Color3.fromRGB(235, 235, 235),
		TextSize = 15,
		TextWrapped = true,
		Font = Enum.Font.SourceSans,
		Parent = valueRound
	})

	local sliding = false
	local inContact = false

	
	local function updateSlider(input)
		local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		local newValue = option.min + ((option.max - option.min) * percent)
		option:SetValue(newValue)
	end

	main.InputBegan:Connect(function(input)
		if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			
			tweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			tweenService:Create(circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 14, 0, 14), ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			updateSlider(input)
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not sliding then
				tweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
				tweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 10, 0, 10), ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
			end
		end
	end)
	
	
	inputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	
	inputService.InputEnded:Connect(function(input)
		if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			if sliding then
				sliding = false
				if inContact then
					tweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
					tweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 10, 0, 10), ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play()
				else
					tweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
					tweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				end
			end
		end
	end)

	main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			inputvalue:ReleaseFocus()
			if not sliding then
				tweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				tweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)


	inputvalue.FocusLost:Connect(function()
		local num = tonumber(inputvalue.Text)
		if num then
			option:SetValue(num)
		else
			inputvalue.Text = tostring(option.value)
		end
		if not inContact and not sliding then
			tweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
		end
	end)

	
	function option:SetValue(value)
		
		value = math.clamp(round(value, self.float), self.min, self.max)
		local percent = (value - self.min) / (self.max - self.min)
		
		
		local decimals = 0
		if self.float < 1 then
			local strFloat = tostring(self.float)
			local dotIndex = strFloat:find("%.")
			if dotIndex then
				decimals = #strFloat:sub(dotIndex + 1)
			end
		end
		local formattedValue = string.format("%." .. decimals .. "f", value)


		fill:TweenSize(UDim2.new(percent, 0, 1, 0), "Out", "Quint", 0.15, true)
		circle.Position = UDim2.new(1, 0, 0.5, 0) 

		library.flags[self.flag] = value
		self.value = value
		inputvalue.Text = formattedValue
		self.callback(value)
	end

	option:SetValue(option.value)
end

local function createList(option, parent, holder)
	local valueCount = 0
	local items = {}
	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	local round = library:Create("ImageLabel", {
		Position = UDim2.new(0, 6, 0, 4),
		Size = UDim2.new(1, -12, 1, -10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(40, 40, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = main
	})
	
	local title = library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 14),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 14,
		Font = Enum.Font.SourceSansBold,
		TextColor3 = Color3.fromRGB(160, 160, 160),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local listvalue = library:Create("TextLabel", {
		Position = UDim2.new(0, 12, 0, 22),
		Size = UDim2.new(1, -24, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		TextSize = 16,
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, 
		Parent = main
	})
	
	
	local function updateDisplayText()
		if option.multiselect then
			if type(option.value) == "table" then
				if #option.value == 0 then
					listvalue.Text = "None"
				else
					listvalue.Text = table.concat(option.value, ", ")
				end
			else
				listvalue.Text = "None"
			end
		else
			listvalue.Text = tostring(option.value)
		end
	end
	
	updateDisplayText()
	
	local arrow = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		Rotation = 90, 
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = Color3.fromRGB(160, 160, 160),
		ScaleType = Enum.ScaleType.Fit,
		Parent = round
	})
	
	option.mainHolder = library:Create("ImageButton", {
		ZIndex = 50,
		Size = UDim2.new(0, 230, 0, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(25, 25, 25),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		ClipsDescendants = true,
		Visible = false,
		Parent = library.base
	})
	
	local searchBoxHolder = library:Create("Frame", {
		ZIndex = 51,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = option.mainHolder
	})
	
	local searchBox = library:Create("TextBox", {
		ZIndex = 52,
		Position = UDim2.new(0, 10, 0, 5),
		Size = UDim2.new(1, -20, 0, 20),
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		Text = "",
		TextSize = 14,
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = searchBoxHolder
	})
	
	library:Create("Frame", {
		ZIndex = 51,
		Position = UDim2.new(0, 5, 1, -1),
		Size = UDim2.new(1, -10, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Parent = searchBoxHolder
	})
	
	local content = library:Create("ScrollingFrame", {
		ZIndex = 51,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 1, -30),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
		ScrollBarThickness = 4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = option.mainHolder
	})
	
	local layout = library:Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = content
	})
	
	library:Create("UIPadding", {
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		Parent = content
	})
	
	local function updateDropdownSize()
		local contentHeight = layout.AbsoluteContentSize.Y + 10
		local targetHeight = math.clamp(contentHeight, 0, 150) + 30
		content.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
		return targetHeight
	end

	local inContact
	round.InputBegan:connect(function(input)
		if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			if library.activePopup and library.activePopup ~= option then
				library.activePopup:Close()
			end
			
			if option.open then
				option:Close()
			else
				option.open = true
				library.activePopup = option
				option.mainHolder.Visible = true
				searchBox.Text = "" 
				
				local absPos = main.AbsolutePosition
				local targetHeight = updateDropdownSize()
				local viewportY = workspace.CurrentCamera.ViewportSize.Y
				
				local isDownwards = (absPos.Y + 52 + targetHeight) < viewportY
				local targetY = isDownwards and (absPos.Y + 48) or (absPos.Y - targetHeight + 5)
				
				option.mainHolder.Position = UDim2.new(0, absPos.X + 6, 0, isDownwards and (absPos.Y + 30) or (absPos.Y - 10))
				option.mainHolder.Size = UDim2.new(0, round.AbsoluteSize.X, 0, 0)
				
				tweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 180, ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				tweenService:Create(round, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
				tweenService:Create(option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, round.AbsoluteSize.X, 0, targetHeight),
					Position = UDim2.new(0, absPos.X + 6, 0, targetY)
				}):Play()
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(60, 60, 60)}):Play()
			end
		end
	end)
	
	round.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not option.open then
				tweenService:Create(round, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
			end
		end
	end)

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local searchText = searchBox.Text:lower()
		for _, item in pairs(items) do
			if item.name:lower():match(searchText) then
				item.instance.Visible = true
			else
				item.instance.Visible = false
			end
		end
		updateDropdownSize()
	end)
	
	function option:AddValue(value)
		local isSelected = false
		if self.multiselect then
			isSelected = table.find(self.value, tostring(value)) ~= nil
		else
			isSelected = (self.value == tostring(value))
		end
		
		valueCount = valueCount + 1
		
		local btn = library:Create("TextButton", {
			ZIndex = 52,
			Size = UDim2.new(1, -10, 0, 26),
			BackgroundTransparency = isSelected and 0.8 or 1,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Text = "  " .. tostring(value),
			TextSize = 14,
			Font = Enum.Font.SourceSans,
			TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			Parent = content
		})
		
		library:Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
			Parent = btn
		})
		
		table.insert(items, {name = tostring(value), instance = btn})
		
		btn.InputBegan:connect(function(input)
			if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
				if self.multiselect then
					local index = table.find(self.value, tostring(value))
					if index then
						table.remove(self.value, index)
					else
						table.insert(self.value, tostring(value))
					end
					self:SetValue(self.value)
					
				else
					self:SetValue(value)
					self:Close()
				end
			end
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local currentSelected = self.multiselect and table.find(self.value, tostring(value)) ~= nil or self.value == tostring(value)
				if not currentSelected then
					tweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.95, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end
			end
		end)
		
		btn.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local currentSelected = self.multiselect and table.find(self.value, tostring(value)) ~= nil or self.value == tostring(value)
				if not currentSelected then
					tweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
				end
			end
		end)
		
		if option.open then updateDropdownSize() end
	end

	for _, value in next, option.values do
		option:AddValue(tostring(value))
	end
	
	function option:Refresh(newValues)
		for _, item in pairs(items) do
			item.instance:Destroy()
		end
		items = {}
		valueCount = 0
		
		for _, val in pairs(newValues) do
			self:AddValue(tostring(val))
		end
		
		if self.multiselect then
			local validValues = {}
			for _, v in pairs(self.value) do
				if table.find(newValues, v) then
					table.insert(validValues, v)
				end
			end
			self:SetValue(validValues)
		else
			if not table.find(newValues, self.value) then
				self:SetValue(newValues[1] or "")
			else
				self:SetValue(self.value)
			end
		end
	end
	
	function option:SetValue(value)
		if self.multiselect then
			if type(value) ~= "table" then value = {tostring(value)} end
			self.value = value
			library.flags[self.flag] = self.value
		else
			self.value = tostring(value)
			library.flags[self.flag] = self.value
		end
		
		updateDisplayText()
		
		for _, item in pairs(items) do
			local isSelected = false
			if self.multiselect then
				isSelected = table.find(self.value, item.name) ~= nil
			else
				isSelected = (item.name == self.value)
			end
			
			tweenService:Create(item.instance, TweenInfo.new(0.2), {
				BackgroundTransparency = isSelected and 0.8 or 1,
				TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
			}):Play()
		end
		
		self.callback(self.value)
	end
	
	function option:Close()
		library.activePopup = nil
		self.open = false
		
		tweenService:Create(arrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 90, ImageColor3 = Color3.fromRGB(160, 160, 160)}):Play()
		tweenService:Create(round, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = inContact and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)}):Play()
		
		local closeTween = tweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, round.AbsoluteSize.X, 0, 0)})
		closeTween:Play()
		closeTween.Completed:Wait()
		
		if not self.open then
			self.mainHolder.Visible = false
		end
	end

	return option
end

local function createBox(option, parent)
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 56), 
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	
	
	local title = library:Create("TextLabel", {
		Position = UDim2.new(0, 10, 0, 4),
		Size = UDim2.new(1, -20, 0, 14),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold, 
		TextColor3 = Color3.fromRGB(180, 180, 180),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})

	local outline = library:Create("ImageLabel", {
		Position = UDim2.new(0, 8, 0, 22),
		Size = UDim2.new(1, -16, 1, -26),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(50, 50, 50),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.03,
		Parent = main
	})
	
	
	local round = library:Create("ImageLabel", {
		Position = UDim2.new(0, 1, 0, 1),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.03,
		ClipsDescendants = true,
		Parent = outline
	})
	
	
	local accentLine = library:Create("Frame", {
		Position = UDim2.new(0.5, 0, 1, -1),
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.new(0, 0, 0, 2), 
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = round
	})
	
	
	local inputvalue = library:Create("TextBox", {
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		Text = option.value,
		PlaceholderText = option.placeholder or "",
		PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
		ClearTextOnFocus = option.clearOnFocus or false,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, 
		Parent = round
	})
	
	local inContact = false
	local focused = false
	
	
	local function triggerFocus()
		if not focused then
			inputvalue:CaptureFocus()
		end
	end

	main.InputBegan:connect(function(input)
		if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			triggerFocus()
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not focused then
				tweenService:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
				tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(210, 210, 210)}):Play()
			end
		end
	end)
	
	main.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not focused then
				tweenService:Create(outline, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(50, 50, 50)}):Play()
				tweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
			end
		end
	end)
	
	
	inputvalue.Focused:connect(function()
		focused = true
		tweenService:Create(outline, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(40, 40, 40)}):Play()
		tweenService:Create(title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		
		accentLine:TweenSize(UDim2.new(1, 0, 0, 2), "Out", "Quint", 0.4, true)
	end)
	
	
	inputvalue.FocusLost:connect(function(enterPressed)
		focused = false
		
		
		accentLine:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Quint", 0.4, true)
		
		if inContact then
			tweenService:Create(outline, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		else
			tweenService:Create(outline, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(50, 50, 50)}):Play()
			tweenService:Create(title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
		end

		
		local finalText = inputvalue.Text
		if option.numeric then
			finalText = finalText:gsub("%D", "") 
			if finalText == "" then finalText = "0" end
			inputvalue.Text = finalText
		end
		
		option:SetValue(finalText, enterPressed)
	end)
	
	
	function option:SetValue(value, enter)
		local val = tostring(value)
		library.flags[self.flag] = val
		self.value = val
		inputvalue.Text = val
		self.callback(val, enter)
	end
end

local function createColorPickerWindow(option)
	
	option.mainHolder = library:Create("ImageButton", {
		ZIndex = 3,
		Size = UDim2.new(0, 240, 0, 240),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ImageColor3 = Color3.fromRGB(30, 30, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = library.base
	})
		
	local hue, sat, val = Color3.toHSV(option.color)
	local alpha = option.transparency or 0
	hue, sat, val = hue == 0 and 1 or hue, sat, val
	
	local currentColor = option.color
	local originalColor = option.color
	local rainbowEnabled = false
	local rainbowLoop = nil
	
	local draggingHue, draggingSat, draggingAlpha = false, false, false

	
	function option:updateVisuals(Color, Transparency)
		currentColor = Color
		alpha = Transparency or alpha
		hue, sat, val = Color3.toHSV(Color)
		hue = hue == 0 and 1 or hue
		
		
		self.satval.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		self.satvalSlider.Position = UDim2.new(sat, 0, 1 - val, 0)
		
		
		self.hueSlider.Position = UDim2.new(1 - hue, 0, 0.5, 0)
		
		
		self.alphaGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, currentColor)
		})
		self.alphaSlider.Position = UDim2.new(1 - alpha, 0, 0.5, 0)
		
		
		self.visualize2.ImageColor3 = currentColor
		self.visualize2.ImageTransparency = alpha
		if not self.hexInput.IsFocused then
			self.hexInput.Text = "#" .. currentColor:ToHex():upper()
		end
	end
	
	
	option.satval = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(1, -16, 0, 100),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		BorderSizePixel = 0,
		Image = "rbxassetid://4155801252",
		ImageTransparency = 1,
		ClipsDescendants = true,
		Parent = option.mainHolder
	})
	
	option.satvalSlider = library:Create("Frame", {
		ZIndex = 4,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(sat, 0, 1 - val, 0),
		Size = UDim2.new(0, 8, 0, 8),
		BackgroundTransparency = 1,
		Parent = option.satval
	})
	
	library:Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1.5,
		Parent = option.satvalSlider
	})
	library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = option.satvalSlider })

	
	option.hue = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 116),
		Size = UDim2.new(1, -16, 0, 16),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.mainHolder
	})
	
	library:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = option.hue
	})
	
	option.hueSlider = library:Create("Frame", {
		ZIndex = 4,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1 - hue, 0, 0.5, 0),
		Size = UDim2.new(0, 4, 1, 4),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = option.hue
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = option.hueSlider })
	
	
	option.alpha = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 140),
		Size = UDim2.new(1, -16, 0, 16),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Image = "rbxassetid://3893218059", 
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0, 8, 0, 8),
		Parent = option.mainHolder
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = option.alpha })
	
	option.alphaGradient = library:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, currentColor)
		}),
		Parent = option.alpha
	})
	
	option.alphaSlider = library:Create("Frame", {
		ZIndex = 4,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1 - alpha, 0, 0.5, 0),
		Size = UDim2.new(0, 4, 1, 4),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = option.alpha
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = option.alphaSlider })

	
	option.visualize2_bg = library:Create("ImageLabel", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 164),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 0,
		Image = "rbxassetid://3893218059",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0, 8, 0, 8),
		Parent = option.mainHolder
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = option.visualize2_bg })

	option.visualize2 = library:Create("ImageLabel", {
		ZIndex = 4,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = currentColor,
		ImageTransparency = alpha,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.visualize2_bg
	})
	
	option.hexInput = library:Create("TextBox", {
		ZIndex = 3,
		Position = UDim2.new(0, 40, 0, 164),
		Size = UDim2.new(1, -48, 0, 24),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		Text = "#" .. currentColor:ToHex():upper(),
		Font = Enum.Font.Code,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		ClearTextOnFocus = false,
		Parent = option.mainHolder
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = option.hexInput })
	
	
	option.rainbow = library:Create("TextButton", {
		ZIndex = 3,
		Position = UDim2.new(0, 8, 0, 196),
		Size = UDim2.new(0.5, -12, 0, 24),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		Text = "Rainbow",
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		Parent = option.mainHolder
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = option.rainbow })

	
	option.confirm = library:Create("TextButton", {
		ZIndex = 3,
		Position = UDim2.new(0.5, 4, 0, 196),
		Size = UDim2.new(0.5, -12, 0, 24),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		Text = "Confirm",
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		Parent = option.mainHolder
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = option.confirm })

	local function UpdateColorFromMouse(Input, dragType)
		if dragType == "SatVal" then
			local X = math.clamp((Input.Position.X - option.satval.AbsolutePosition.X) / option.satval.AbsoluteSize.X, 0, 1)
			local Y = math.clamp((Input.Position.Y - option.satval.AbsolutePosition.Y) / option.satval.AbsoluteSize.Y, 0, 1)
			option:SetColor(Color3.fromHSV(hue, X, 1 - Y), alpha)
		elseif dragType == "Hue" then
			local X = math.clamp((Input.Position.X - option.hue.AbsolutePosition.X) / option.hue.AbsoluteSize.X, 0, 1)
			option:SetColor(Color3.fromHSV(1 - X, sat, val), alpha)
		elseif dragType == "Alpha" then
			local X = math.clamp((Input.Position.X - option.alpha.AbsolutePosition.X) / option.alpha.AbsoluteSize.X, 0, 1)
			option:SetColor(currentColor, 1 - X)
		end
	end

	
	option.satval.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			draggingSat = true
			UpdateColorFromMouse(Input, "SatVal")
		end
	end)
	
	
	option.hue.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
			UpdateColorFromMouse(Input, "Hue")
		end
	end)
	
	
	option.alpha.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			draggingAlpha = true
			UpdateColorFromMouse(Input, "Alpha")
		end
	end)

	inputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			if draggingSat then UpdateColorFromMouse(Input, "SatVal") end
			if draggingHue then UpdateColorFromMouse(Input, "Hue") end
			if draggingAlpha then UpdateColorFromMouse(Input, "Alpha") end
		end
	end)

	inputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			draggingSat = false
			draggingHue = false
			draggingAlpha = false
		end
	end)

	option.hexInput.FocusLost:Connect(function()
		local success, result = pcall(function()
			return Color3.fromHex(option.hexInput.Text)
		end)
		if success and result then
			option:SetColor(result, alpha)
		else
			option.hexInput.Text = "#" .. currentColor:ToHex():upper()
		end
	end)
	
	local function ButtonHover(btn)
		btn.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
			end
		end)
		btn.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
			end
		end)
	end
	
	ButtonHover(option.rainbow)
	ButtonHover(option.confirm)

	option.rainbow.MouseButton1Click:Connect(function()
		rainbowEnabled = not rainbowEnabled
		if rainbowEnabled then
			option.rainbow.TextColor3 = Color3.fromRGB(0, 255, 128)
			rainbowLoop = runService.Heartbeat:Connect(function()
				option:SetColor(Color3.fromHSV(tick() % 5 / 5, 1, 1), alpha)
			end)
		else
			option.rainbow.TextColor3 = Color3.fromRGB(255, 255, 255)
			if rainbowLoop then rainbowLoop:Disconnect() end
		end
	end)

	option.confirm.MouseButton1Click:Connect(function()
		option:Close()
	end)
	
	return option
end

local function createColor(option, parent, holder)
	option.main = library:Create("TextLabel", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundTransparency = 1,
		Text = " " .. option.text,
		TextSize = 17,
		Font = Enum.Font.SourceSans,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent.content
	})
	
	local colorBoxOutline = library:Create("ImageLabel", {
		Position = UDim2.new(1, -6, 0, 4),
		Size = UDim2.new(-1, 10, 1, -10),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(100, 100, 100),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = option.main
	})
	
	
	local checkerBg = library:Create("ImageLabel", {
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 0,
		Image = "rbxassetid://3893218059",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0, 6, 0, 6),
		Parent = colorBoxOutline
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = checkerBg })
	
	option.visualize = library:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = option.color,
		ImageTransparency = option.transparency or 0,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.02,
		Parent = checkerBg
	})
	
	local inContact
	option.main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not option.mainHolder then createColorPickerWindow(option) end
			if library.activePopup and library.activePopup ~= option then
				library.activePopup:Close()
			end
			local position = option.main.AbsolutePosition
			option.mainHolder.Position = UDim2.new(0, position.X - 5, 0, position.Y - 10)
			option.open = true
			option.mainHolder.Visible = true
			library.activePopup = option
			
			
			tweenService:Create(option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0, position.X - 5, 0, position.Y - 4)}):Play()
			tweenService:Create(option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1), {Position = UDim2.new(0, position.X - 5, 0, position.Y + 1)}):Play()
			tweenService:Create(option.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
			
			for _,object in next, option.mainHolder:GetDescendants() do
				if object:IsA("TextLabel") or object:IsA("TextBox") then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
				elseif object:IsA("ImageLabel") and object.Name ~= "satval" and object.Name ~= "visualize2" then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
				elseif object:IsA("Frame") or object:IsA("TextButton") then
					tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
				end
			end
			option.visualize2.ImageTransparency = option.transparency or 0
		end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open then
				tweenService:Create(colorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(140, 140, 140)}):Play()
			end
		end
	end)
	
	option.main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not option.open then
				tweenService:Create(colorBoxOutline, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			end
		end
	end)
	
	function option:SetColor(newColor, newTransparency)
		newTransparency = newTransparency or self.transparency or 0
		if self.mainHolder then
			self:updateVisuals(newColor, newTransparency)
		end
		self.visualize.ImageColor3 = newColor
		self.visualize.ImageTransparency = newTransparency
		library.flags[self.flag] = newColor
		self.color = newColor
		self.transparency = newTransparency
		self.callback(newColor, newTransparency)
	end
	
	function option:Close()
		library.activePopup = nil
		self.open = false
		local position = self.main.AbsolutePosition
		
		tweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1, Position = UDim2.new(0, position.X - 5, 0, position.Y - 10)}):Play()
		tweenService:Create(self.satval, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		for _,object in next, self.mainHolder:GetDescendants() do
			if object:IsA("TextLabel") or object:IsA("TextBox") then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
			elseif object:IsA("ImageLabel") and object.Name ~= "satval" and object.Name ~= "visualize2" then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
			elseif object:IsA("Frame") or object:IsA("TextButton") then
				tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end
		end
		task.delay(0.3, function()
			if not self.open then
				self.mainHolder.Visible = false
			end 
		end)
	end
end

local function loadOptions(option, holder)
	for _,newOption in next, option.options do
		if newOption.type == "label" then
			createLabel(newOption, option)
		elseif newOption.type == "toggle" then
			createToggle(newOption, option)
		elseif newOption.type == "button" then
			createButton(newOption, option)
		elseif newOption.type == "list" then
			createList(newOption, option, holder)
		elseif newOption.type == "box" then
			createBox(newOption, option)
		elseif newOption.type == "bind" then
			createBind(newOption, option)
		elseif newOption.type == "slider" then
			createSlider(newOption, option)
		elseif newOption.type == "color" then
			createColor(newOption, option, holder)
		elseif newOption.type == "folder" then
			newOption:init()
		end
	end
end

local function getFnctions(parent)
	function parent:AddLabel(option)
		
		if type(option) == "string" then
			option = {text = option}
		end
		
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text or "Label")
		option.align = option.align or "Left" 
		option.type = "label"
		option.position = #self.options
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddToggle(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.state = typeof(option.state) == "boolean" and option.state or false
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "toggle"
		option.position = #self.options
		option.flag = option.flag or option.text
		library.flags[option.flag] = option.state
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddButton(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "button"
		option.position = #self.options
		option.flag = option.flag or option.text
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddBind(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text or "Bind")
		
		
		if typeof(option.key) == "EnumItem" then
			option.key = option.key.Name
		elseif typeof(option.key) ~= "string" then
			option.key = "None"
		end
		
		option.hold = typeof(option.hold) == "boolean" and option.hold or false
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "bind"
		option.position = #self.options
		option.flag = option.flag or option.text
		library.flags[option.flag] = option.key
		
		table.insert(self.options, option)
		return option
	end
	
	function parent:AddSlider(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.min = typeof(option.min) == "number" and option.min or 0
		option.max = typeof(option.max) == "number" and option.max or 0
		option.dual = typeof(option.dual) == "boolean" and option.dual or false
		option.value = math.clamp(typeof(option.value) == "number" and option.value or option.min, option.min, option.max)
		option.value2 = typeof(option.value2) == "number" and option.value2 or option.max
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.float = typeof(option.value) == "number" and option.float or 1
		option.type = "slider"
		option.position = #self.options
		option.flag = option.flag or option.text
		library.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddList(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.values = typeof(option.values) == "table" and option.values or {}
		option.multiselect = typeof(option.multiselect) == "boolean" and option.multiselect or false
		
		
		if option.multiselect then
			option.value = typeof(option.value) == "table" and option.value or {}
		else
			option.value = tostring(option.value or option.values[1] or "")
		end
		
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.open = false
		option.type = "list"
		option.position = #self.options
		option.flag = option.flag or option.text
		library.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddBox(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text or "TextBox")
		option.value = tostring(option.value or "")
		option.placeholder = tostring(option.placeholder or "Type here…") 
		option.clearOnFocus = typeof(option.clearOnFocus) == "boolean" and option.clearOnFocus or false 
		option.numeric = typeof(option.numeric) == "boolean" and option.numeric or false -- Mới
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.type = "box"
		option.position = #self.options
		option.flag = option.flag or option.text
		library.flags[option.flag] = option.value
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddColor(option)
		option = typeof(option) == "table" and option or {}
		option.text = tostring(option.text)
		option.color = typeof(option.color) == "table" and Color3.new(tonumber(option.color[1]), tonumber(option.color[2]), tonumber(option.color[3])) or option.color or Color3.new(1, 1, 1)
		option.transparency = typeof(option.transparency) == "number" and option.transparency or 0
		option.callback = typeof(option.callback) == "function" and option.callback or function() end
		option.open = false
		option.type = "color"
		option.position = #self.options
		option.flag = option.flag or option.text
		library.flags[option.flag] = option.color
		table.insert(self.options, option)
		
		return option
	end
	
	function parent:AddFolder(title)
		local option = {}
		option.title = tostring(title)
		option.options = {}
		option.open = false
		option.type = "folder"
		option.position = #self.options
		table.insert(self.options, option)
		
		getFnctions(option)
		
		function option:init()
			createOptionHolder(self.title, parent.content, self, true)
			loadOptions(self, parent)
		end
		
		return option
	end
end

function library:CreateWindow(title)
	local window = {title = tostring(title), options = {}, open = true, canInit = true, init = false, position = #self.windows}
	getFnctions(window)
	
	table.insert(library.windows, window)
	
	return window
end

local UIToggle
function library:Init()
	self.base = self.base or self:Create("ScreenGui")
	if syn and syn.protect_gui then
		syn.protect_gui(self.base)
	elseif get_hidden_gui then
		get_hidden_gui(self.base)
	elseif gethui then
		gethui(self.base)
	else
		game:GetService"Players".LocalPlayer:Kick("Error: protect_gui function not found")
		return
	end
	self.base.Parent = game:GetService"CoreGui"
	self.base.ResetOnSpawn = true
	self.base.Name = "skibidi"
	
	
	for _, window in next, self.windows do
		if window.canInit and not window.init then
			window.init = true
			createOptionHolder(window.title, self.base, window)
			loadOptions(window)
		end
	end
	return self.base
end

function library:Close()
	if typeof(self.base) ~= "Instance" then end
	self.open = not self.open
	if self.activePopup then
		self.activePopup:Close()
	end
	for _, window in next, self.windows do
		if window.main then
			window.main.Visible = self.open
		end
	end
end

inputService.InputBegan:connect(function(input)
	if input.UserInputType == ui then
		if library.activePopup then
			if input.Position.X < library.activePopup.mainHolder.AbsolutePosition.X or input.Position.Y < library.activePopup.mainHolder.AbsolutePosition.Y then
				library.activePopup:Close()
			end
		end
		if library.activePopup then
			if input.Position.X > library.activePopup.mainHolder.AbsolutePosition.X + library.activePopup.mainHolder.AbsoluteSize.X or input.Position.Y > library.activePopup.mainHolder.AbsolutePosition.Y + library.activePopup.mainHolder.AbsoluteSize.Y then
				library.activePopup:Close()
			end
		end
	elseif input.UserInputType == Enum.UserInputType.Touch then
		if library.activePopup then
			if input.Position.X < library.activePopup.mainHolder.AbsolutePosition.X or input.Position.Y < library.activePopup.mainHolder.AbsolutePosition.Y then
				library.activePopup:Close()
			end
		end
		if library.activePopup then
			if input.Position.X > library.activePopup.mainHolder.AbsolutePosition.X + library.activePopup.mainHolder.AbsoluteSize.X or input.Position.Y > library.activePopup.mainHolder.AbsolutePosition.Y + library.activePopup.mainHolder.AbsoluteSize.Y then
				library.activePopup:Close()
			end
		end
	end
end)

inputService.InputChanged:connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

wait(1)
local VirtualUser=game:service'VirtualUser'
game:service('Players').LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)

return library
