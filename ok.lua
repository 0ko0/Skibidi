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
	MouseButton4 = "MB4", MouseButton5 = "MB5",
	Insert = "Ins", Delete = "Del", Backspace = "Back", Return = "Enter", Escape = "Esc",
	PageUp = "PgUp", PageDown = "PgDn", Space = "Space",
	ButtonX = "Xbox X", ButtonY = "Xbox Y", ButtonA = "Xbox A", ButtonB = "Xbox B",
	ButtonR1 = "RB", ButtonL1 = "LB", ButtonR2 = "RT", ButtonL2 = "LT",
	ButtonR3 = "RS", ButtonL3 = "LS", DPadUp = "D-Up", DPadDown = "D-Down", DPadLeft = "D-Left", DPadRight = "D-Right",
	Unknown = "None"
}

local function formatKey(keyName)
	if not keyName or keyName == "" then return "None" end
	return shortKeys[keyName] or keyName
end

local function getIconForKey(keyName)
	if keyName:find("MB") or keyName:find("Mouse") then
		return "rbxassetid://140655072225632" 
	elseif keyName:find("Xbox") or keyName:find("Button") or keyName:find("DPad") then
		return "rbxassetid://96205762737948" 
	elseif keyName == "None" then
		return "rbxassetid://134588413858061" 
	else
		return "rbxassetid://77926385819793" 
	end
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
	local MAX_MENU_HEIGHT = 400 

	parentTable.main = library:Create("Frame", {
		LayoutOrder = subHolder and parentTable.position or 0,
		Position = UDim2.new(0, 20 + (250 * (parentTable.position or 0)), 0, 20),
		Size = UDim2.new(0, 230, 0, size),
		BackgroundColor3 = Color3.fromRGB(15, 15, 17),
		BackgroundTransparency = subHolder and 1 or 0.05,
		ClipsDescendants = false, 
		Parent = parent
	})
	
	
	library:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = parentTable.main })
	
	
	local mainStroke = library:Create("UIStroke", {
		Color = Color3.fromRGB(60, 60, 70),
		Thickness = 1,
		Transparency = subHolder and 1 or 0,
		Parent = parentTable.main
	})

	if not subHolder then
		library:Create("ImageLabel", {
			ZIndex = -1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 4),
			Size = UDim2.new(1, 30, 1, 30),
			BackgroundTransparency = 1,
			Image = "rbxassetid://4731308832",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.5,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(21, 21, 278, 278),
			Parent = parentTable.main
		})
	end
	
	local topBar = library:Create("Frame", {
		Size = UDim2.new(1, 0, 0, size),
		BackgroundColor3 = subHolder and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(25, 25, 30),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = parentTable.main
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = topBar })

	local bottomHider = library:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 1, -6),
		BackgroundColor3 = subHolder and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(25, 25, 30),
		BorderSizePixel = 0,
		BackgroundTransparency = parentTable.open and 0 or 1,
		Parent = topBar
	})

	local title = library:Create("TextLabel", {
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = holderTitle,
		TextSize = subHolder and 14 or 15,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(240, 240, 245),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar
	})
	
	local closeHolder = library:Create("TextButton", {
		Position = UDim2.new(1, -size, 0, 0),
		Size = UDim2.new(0, size, 0, size),
		BackgroundTransparency = 1,
		Text = "",
		Parent = topBar
	})
	
	local close = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Rotation = parentTable.open and 90 or 0,
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = parentTable.open and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
		ScaleType = Enum.ScaleType.Fit,
		Parent = closeHolder
	})
	
	local contentClip = library:Create("Frame", {
		Position = UDim2.new(0, 0, 0, size),
		Size = UDim2.new(1, 0, 1, -size),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = parentTable.main
	})

	parentTable.content = library:Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2, 
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120), 
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = contentClip
	})
	
	local layout = library:Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = parentTable.content
	})
	
	library:Create("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		Parent = parentTable.content
	})
	
	layout.Changed:connect(function()
		parentTable.content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
		local targetHeight = math.min(layout.AbsoluteContentSize.Y + size + 12, MAX_MENU_HEIGHT)
		if parentTable.open then
			parentTable.main.Size = #parentTable.options > 0 and UDim2.new(0, 230, 0, targetHeight) or UDim2.new(0, 230, 0, size)
		end
	end)

	local function createRipple(posX, posY)
		local ripple = library:Create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, posX, 0, posY),
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2708891598", 
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0.6,
			ZIndex = 5,
			Parent = topBar
		})
		tweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 300, 0, 300),
			ImageTransparency = 1
		}):Play()
		task.delay(0.5, function() ripple:Destroy() end)
	end
	
	if not subHolder then
		local dragging, dragStart, startPos
		local dragInputConnection, renderSteppedConnection
		local targetPos = parentTable.main.Position

		topBar.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = parentTable.main.Position

				local relativeX = input.Position.X - topBar.AbsolutePosition.X
				local relativeY = input.Position.Y - topBar.AbsolutePosition.Y
				createRipple(relativeX, relativeY)

				if not renderSteppedConnection then
					renderSteppedConnection = runService.RenderStepped:Connect(function()
						
						parentTable.main.Position = parentTable.main.Position:Lerp(targetPos, 0.25)
					end)
				end
			end
		end)

		inputService.InputChanged:connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				local yPos = math.max((startPos.Y.Offset + delta.Y), -36)
				targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, yPos)
			end
		end)

		inputService.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				task.delay(0.5, function() 
					if not dragging and renderSteppedConnection then
						renderSteppedConnection:Disconnect()
						renderSteppedConnection = nil
					end
				end)
			end
		end)

		topBar.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				tweenService:Create(mainStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(100, 100, 120)}):Play()
			end
		end)
		topBar.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				tweenService:Create(mainStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 70)}):Play()
			end
		end)
	end
	
	local function toggleTab()
		parentTable.open = not parentTable.open
		
		tweenService:Create(close, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Rotation = parentTable.open and 90 or 0, 
			ImageColor3 = parentTable.open and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
		}):Play()
		
		bottomHider.BackgroundTransparency = parentTable.open and 0 or 1
		
		local targetHeight = math.min(layout.AbsoluteContentSize.Y + size + 12, MAX_MENU_HEIGHT)
		local endSize = (#parentTable.options > 0 and parentTable.open) and UDim2.new(0, 230, 0, targetHeight) or UDim2.new(0, 230, 0, size)
		
		tweenService:Create(parentTable.main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = endSize}):Play()
	end

	closeHolder.MouseButton1Click:Connect(toggleTab)
	
	function parentTable:SetTitle(newTitle)
		title.Text = tostring(newTitle)
	end
	
	return parentTable
end
	
local function createLabel(option, parent)
	local padding = option.padding or 10
	local align = option.align or "Left"
	local hasIcon = option.icon ~= nil
	local iconSize = option.iconSize or 18
	local iconSpacing = 8
	
	
	local hasBg = option.bgTransparency and option.bgTransparency < 1
	local defaultBgColor = option.bgColor or Color3.fromRGB(30, 30, 35)
	local hoverBgColor = option.hoverBgColor or Color3.fromRGB(40, 40, 45)

	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = option.bgTransparency or 1,
		BackgroundColor3 = defaultBgColor,
		ClipsDescendants = true,
		Parent = parent.content
	})

	if hasBg then
		library:Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
			Parent = main
		})
		
		
		if option.border then
			library:Create("UIStroke", {
				Color = Color3.fromRGB(60, 60, 70),
				Thickness = 1,
				Transparency = 0.5,
				Parent = main
			})
		end
	end

	
	local contentFrame = library:Create("Frame", {
		Size = UDim2.new(1, -(padding * 2), 1, 0),
		Position = UDim2.new(0, padding, 0, 0),
		BackgroundTransparency = 1,
		Parent = main
	})

	local layout = library:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment[align],
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, iconSpacing),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = contentFrame
	})

	
	local iconImg
	if hasIcon then
		iconImg = library:Create("ImageLabel", {
			Size = UDim2.new(0, iconSize, 0, iconSize),
			BackgroundTransparency = 1,
			Image = option.icon,
			ImageColor3 = option.iconColor or option.color or Color3.fromRGB(240, 240, 240),
			LayoutOrder = align == "Right" and 2 or 0,
			Parent = contentFrame
		})
	end

	
	local defaultColor = option.color or Color3.fromRGB(240, 240, 240)
	local textLabel = library:Create("TextLabel", {
		Size = UDim2.new(1, hasIcon and -(iconSize + iconSpacing) or 0, 1, 0),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = option.textSize or 14,
		Font = Enum.Font[option.font or "GothamMedium"], 
		TextColor3 = defaultColor,
		TextXAlignment = Enum.TextXAlignment[align],
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true, 
		TextWrapped = true, 
		LayoutOrder = 1,
		Parent = contentFrame
	})

	
	if option.stroke then
		library:Create("UIStroke", {
			Color = option.strokeColor or Color3.fromRGB(0, 0, 0),
			Thickness = option.strokeThickness or 1,
			Transparency = option.strokeTransparency or 0.3,
			Parent = textLabel
		})
	end

	
	local textGradient
	if option.gradient then
		textGradient = library:Create("UIGradient", {
			Color = typeof(option.gradient) == "ColorSequence" and option.gradient or ColorSequence.new({
				ColorSequenceKeypoint.new(0, option.gradient[1] or Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, option.gradient[2] or defaultColor)
			}),
			Rotation = option.gradientRotation or 0,
			Parent = textLabel
		})
	end

	
	local function updateSize()
		local maxWidth = main.AbsoluteSize.X - (padding * 2) - (hasIcon and (iconSize + iconSpacing) or 0)
		if maxWidth <= 0 then maxWidth = 9e9 end
		
		local bounds = textService:GetTextSize(
			textLabel.Text, 
			textLabel.TextSize, 
			textLabel.Font, 
			Vector2.new(maxWidth, 9e9)
		)
		
		local targetHeight = math.max(hasBg and 30 or 26, bounds.Y + (hasBg and 14 or 10))
		
		
		tweenService:Create(main, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, targetHeight)
		}):Play()
	end

	textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateSize)
	main:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
	
	
	local interactBtn = library:Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		Parent = main,
		ZIndex = 5
	})

	local isHovering = false
	local hoverTextColor = option.hoverColor or Color3.fromRGB(255, 255, 255)

	
	interactBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			isHovering = true
			if option.copyable or option.hoverable then
				tweenService:Create(textLabel, TweenInfo.new(0.2), {TextColor3 = hoverTextColor}):Play()
				if hasBg then
					tweenService:Create(main, TweenInfo.new(0.2), {BackgroundColor3 = hoverBgColor}):Play()
				end
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if option.copyable then
				
				local ripple = library:Create("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://2708891598",
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ImageTransparency = 0.8,
					ZIndex = 4,
					Parent = main
				})
				
				local localX = input.Position.X - main.AbsolutePosition.X
				local localY = input.Position.Y - main.AbsolutePosition.Y
				ripple.Position = UDim2.new(0, localX, 0, localY)
				ripple.Size = UDim2.new(0, 0, 0, 0)
				ripple.AnchorPoint = Vector2.new(0.5, 0.5)
				
				local maxSize = math.max(main.AbsoluteSize.X, main.AbsoluteSize.Y) * 2.5
				tweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, maxSize, 0, maxSize),
					ImageTransparency = 1
				}):Play()
				game.Debris:AddItem(ripple, 0.6)

				
				local textToCopy = option.copyText or textLabel.Text
				pcall(function()
					if setclipboard then setclipboard(textToCopy)
					elseif toClipboard then toClipboard(textToCopy) end
				end)

				if library.Notify then
					library:Notify({
						Title = "Copied",
						Content = "Copied: " .. textToCopy,
						Type = "success",
						Duration = 3
					})
				end
			end
		end
	end)

	interactBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			isHovering = false
			if option.copyable or option.hoverable then
				tweenService:Create(textLabel, TweenInfo.new(0.2), {TextColor3 = defaultColor}):Play()
				if hasBg then
					tweenService:Create(main, TweenInfo.new(0.2), {BackgroundColor3 = defaultBgColor}):Play()
				end
			end
		end
	end)

	function option:SetText(newText)
		textLabel.Text = tostring(newText)
		updateSize()
	end
    
	function option:SetColor(newColor)
		defaultColor = typeof(newColor) == "Color3" and newColor or Color3.fromRGB(255, 255, 255)
		if not isHovering then textLabel.TextColor3 = defaultColor end
		if iconImg and not option.iconColor then iconImg.ImageColor3 = defaultColor end
	end

	function option:SetIcon(newIconId)
		if iconImg then iconImg.Image = tostring(newIconId) end
	end

	function option:SetGradient(color1, color2)
		if not textGradient then
			textGradient = library:Create("UIGradient", {Parent = textLabel})
		end
		textGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, typeof(color1) == "Color3" and color1 or Color3.fromRGB(255,255,255)),
			ColorSequenceKeypoint.new(1, typeof(color2) == "Color3" and color2 or defaultColor)
		})
	end

	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" or i == "text" then
			t:SetText(v)
		elseif i == "Color" or i == "color" then
			t:SetColor(v)
		end
	end})
	
	task.spawn(updateSize)
	
	return option
end

function createToggle(option, parent)
	
	option = typeof(option) == "table" and option or {}
	local text = tostring(option.text or "Toggle")
	local state = option.state or false
	local isLocked = option.locked or false
	local accentColor = option.color or Color3.fromRGB(0, 255, 0) 
	local flag = option.flag or text
	
	library.flags[flag] = state

	
	local main = library:Create("TextButton", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 36), 
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = parent.content
	})
	
	local titleText = library:Create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextSize = 15,
		Font = Enum.Font.GothamMedium,
		TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})
	
	local switchBg = library:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 42, 0, 20),
		BackgroundColor3 = state and accentColor or Color3.fromRGB(25, 25, 30),
		Parent = main
	})
	
	library:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = switchBg
	})
	
	local stroke = library:Create("UIStroke", {
		Color = state and accentColor or Color3.fromRGB(70, 70, 75),
		Thickness = 1.2,
		Transparency = state and 1 or 0, 
		Parent = switchBg
	})
	
	
	local glow = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 16, 1, 16),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843", 
		ImageColor3 = accentColor,
		ImageTransparency = state and 0.5 or 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = 0,
		Parent = switchBg
	})
	
	local switchCircle = library:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165),
		ZIndex = 2,
		Parent = switchBg
	})
	
	library:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = switchCircle
	})

	
	library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 2),
		Size = UDim2.new(1, 6, 1, 6),
		BackgroundTransparency = 1,
		Image = "rbxassetid://4731308832",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.7,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(21, 21, 278, 278),
		ZIndex = 1,
		Parent = switchCircle
	})

	
	if isLocked then
		titleText.TextColor3 = Color3.fromRGB(100, 100, 100)
		switchBg.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
		stroke.Color = Color3.fromRGB(40, 40, 45)
		switchCircle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end

	local inContact = false

	
	main.InputBegan:Connect(function(input)
		if isLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.state then
				tweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(110, 110, 120)}):Play()
				tweenService:Create(titleText, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			
			tweenService:Create(switchCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 20, 0, 16),
				Position = option.state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			}):Play()
		end
	end)
	
	main.InputEnded:Connect(function(input)
		if isLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not option.state then
				tweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(70, 70, 75)}):Play()
				tweenService:Create(titleText, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			
			tweenService:Create(switchCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 16, 0, 16),
				Position = option.state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			}):Play()
		end
	end)
	
	main.Activated:Connect(function()
		if isLocked then return end
		option:SetState(not option.state)
	end)
	
	function option:SetState(newState)
		if isLocked then return end
		library.flags[flag] = newState
		self.state = newState
		
		local tweenInfoBack = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfoColor = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		
		tweenService:Create(switchBg, tweenInfoColor, {
			BackgroundColor3 = newState and accentColor or Color3.fromRGB(25, 25, 30)
		}):Play()
		
		tweenService:Create(glow, tweenInfoColor, {
			ImageTransparency = newState and 0.4 or 1,
			ImageColor3 = accentColor
		}):Play()
		
		tweenService:Create(switchCircle, tweenInfoBack, {
			Position = newState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundColor3 = newState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
		}):Play()
		
		tweenService:Create(stroke, tweenInfoColor, {
			Transparency = newState and 1 or 0,
			Color = newState and accentColor or (inContact and Color3.fromRGB(110, 110, 120) or Color3.fromRGB(70, 70, 75))
		}):Play()
		
		tweenService:Create(titleText, tweenInfoColor, {
			TextColor3 = newState and Color3.fromRGB(255, 255, 255) or (inContact and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(180, 180, 180))
		}):Play()
		
		task.spawn(function()
			pcall(self.callback, newState)
		end)
	end

	function option:SetText(newText)
		titleText.Text = tostring(newText)
	end

	function option:SetColor(newColor)
		accentColor = typeof(newColor) == "Color3" and newColor or Color3.fromRGB(255, 255, 255)
		if self.state then
			tweenService:Create(switchBg, TweenInfo.new(0.3), {BackgroundColor3 = accentColor}):Play()
			tweenService:Create(glow, TweenInfo.new(0.3), {ImageColor3 = accentColor}):Play()
		end
	end

	function option:SetLocked(stateLock)
		isLocked = stateLock
		local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		
		if isLocked then
			tweenService:Create(titleText, tInfo, {TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			tweenService:Create(switchBg, tInfo, {BackgroundColor3 = Color3.fromRGB(20, 20, 22)}):Play()
			tweenService:Create(stroke, tInfo, {Color = Color3.fromRGB(40, 40, 45), Transparency = 0}):Play()
			tweenService:Create(switchCircle, tInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
			tweenService:Create(glow, tInfo, {ImageTransparency = 1}):Play()
		else
			self:SetState(self.state) 
		end
	end

	setmetatable(option, {
		__newindex = function(t, i, v)
			if i == "Text" or i == "text" then
				t:SetText(v)
			elseif i == "Value" or i == "state" then
				t:SetState(v)
			elseif i == "Locked" or i == "locked" then
				t:SetLocked(v)
			end
		end
	})
	
	if option.state then
		task.delay(0.1, function() 
			task.spawn(function() pcall(option.callback, true) end)
		end)
	end
	
	return option
end

function createButton(option, parent)
	
	option = typeof(option) == "table" and option or {}
	local text = tostring(option.text or "Button")
	local iconId = option.icon 
	local isLocked = option.locked or false 
	local accentColor = option.color or Color3.fromRGB(110, 150, 255) 

	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 36), 
		BackgroundTransparency = 1,
		Parent = parent.content
	})

	
	local shadow = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 2),
		Size = UDim2.new(1, 8, 1, 10),
		BackgroundTransparency = 1,
		Image = "rbxassetid://4731308832",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(21, 21, 278, 278),
		Parent = main
	})

	
	local buttonFrame = library:Create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -12, 1, -8),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		AutoButtonColor = false,
		Text = "",
		ClipsDescendants = true,
		Parent = main
	})

	
	library:Create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = buttonFrame
	})

	
	local stroke = library:Create("UIStroke", {
		Color = Color3.fromRGB(60, 60, 70),
		Thickness = 1.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = 0,
		Parent = buttonFrame
	})

	
	local uigradient = library:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
		}),
		Rotation = 90,
		Parent = buttonFrame
	})

	
	local contentFrame = library:Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = buttonFrame
	})

	library:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		Parent = contentFrame
	})

	
	local iconImg
	if iconId then
		iconImg = library:Create("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			BackgroundTransparency = 1,
			Image = iconId,
			ImageColor3 = isLocked and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(220, 220, 220),
			Parent = contentFrame
		})
	end

	
	local btnText = library:Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = text,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold, 
		TextColor3 = isLocked and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(220, 220, 220),
		Parent = contentFrame
	})

	
	if isLocked then
		buttonFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
		stroke.Color = Color3.fromRGB(40, 40, 45)
		uigradient.Color = ColorSequence.new(Color3.fromRGB(150, 150, 150))
	end

	
	local function createRipple(input)
		local ripple = library:Create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://2708891598", 
			ImageColor3 = accentColor,
			ImageTransparency = 0.8,
			ZIndex = 5,
			Parent = buttonFrame
		})
		
		local absolutePos = buttonFrame.AbsolutePosition
		local mousePos = input.Position
		
		local localX = mousePos.X - absolutePos.X
		local localY = mousePos.Y - absolutePos.Y
		
		ripple.Position = UDim2.new(0, localX, 0, localY)
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		
		local maxSize = math.max(buttonFrame.AbsoluteSize.X, buttonFrame.AbsoluteSize.Y) * 2.5
		
		local tween = tweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, maxSize, 0, maxSize),
			ImageTransparency = 1
		})
		tween:Play()
		
		task.delay(0.6, function()
			ripple:Destroy()
		end)
	end

	
	local inContact = false
	local isClicking = false

	buttonFrame.InputBegan:connect(function(input)
		if isLocked then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not isClicking then
				
				tweenService:Create(buttonFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(40, 40, 45),
					Size = UDim2.new(1, -10, 1, -6) 
				}):Play()
				tweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Color = accentColor 
				}):Play()
				tweenService:Create(btnText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
				if iconImg then
					tweenService:Create(iconImg, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end
			end
		elseif input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			isClicking = true
			library.flags[option.flag] = true
			
			createRipple(input)
			
			
			tweenService:Create(buttonFrame, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, -16, 1, -12), 
				BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			}):Play()
			tweenService:Create(stroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(60, 60, 70)
			}):Play()
		end
	end)

	buttonFrame.InputEnded:connect(function(input)
		if isLocked then return end

		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not isClicking then
				
				tweenService:Create(buttonFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(30, 30, 35),
					Size = UDim2.new(1, -12, 1, -8)
				}):Play()
				tweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Color = Color3.fromRGB(60, 60, 70)
				}):Play()
				tweenService:Create(btnText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = Color3.fromRGB(220, 220, 220)
				}):Play()
				if iconImg then
					tweenService:Create(iconImg, TweenInfo.new(0.3), { ImageColor3 = Color3.fromRGB(220, 220, 220) }):Play()
				end
			end
		elseif input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			isClicking = false
			
			local endScale = inContact and UDim2.new(1, -10, 1, -6) or UDim2.new(1, -12, 1, -8)
			local endBg = inContact and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(30, 30, 35)
			local endStroke = inContact and accentColor or Color3.fromRGB(60, 60, 70)
			
			
			tweenService:Create(buttonFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = endScale,
				BackgroundColor3 = endBg
			}):Play()
			tweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Color = endStroke
			}):Play()
			
			
			task.spawn(function()
				pcall(option.callback)
			end)
		end
	end)

	
	function option:SetText(newText)
		btnText.Text = tostring(newText)
	end

	function option:SetColor(newColor)
		accentColor = newColor
	end

	function option:SetLocked(state)
		isLocked = state
		local targetBg = isLocked and Color3.fromRGB(20, 20, 22) or Color3.fromRGB(30, 30, 35)
		local targetStroke = isLocked and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(60, 60, 70)
		local targetText = isLocked and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(220, 220, 220)

		tweenService:Create(buttonFrame, TweenInfo.new(0.3), {BackgroundColor3 = targetBg}):Play()
		tweenService:Create(stroke, TweenInfo.new(0.3), {Color = targetStroke}):Play()
		tweenService:Create(btnText, TweenInfo.new(0.3), {TextColor3 = targetText}):Play()
		if iconImg then
			tweenService:Create(iconImg, TweenInfo.new(0.3), {ImageColor3 = targetText}):Play()
		end
	end

	function option:Fire()
		if not isLocked then
			task.spawn(function() pcall(option.callback) end)
		end
	end

	setmetatable(option, {__newindex = function(t, i, v)
		if i == "Text" or i == "text" then
			btnText.Text = tostring(v)
		end
	end})

	return option
end

local function createBind(option, parent)
	local binding = false
	local holding = false
	local currentKey = option.key or "None"
	local accentColor = option.color or Color3.fromRGB(80, 160, 255) 

	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = parent.content
	})

	local titleBtn = library:Create("TextButton", {
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 15,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		Parent = main
	})

	local bindContainer = library:Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 50, 0, 24),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		AutoButtonColor = false,
		Text = "",
		ClipsDescendants = true,
		Parent = main
	})

	library:Create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = bindContainer
	})

	local stroke = library:Create("UIStroke", {
		Color = Color3.fromRGB(60, 60, 70),
		Thickness = 1.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = bindContainer
	})

	local bindLayout = library:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		Parent = bindContainer
	})

	local bindIcon = library:Create("ImageLabel", {
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundTransparency = 1,
		Image = getIconForKey(currentKey),
		ImageColor3 = Color3.fromRGB(180, 180, 180),
		Parent = bindContainer
	})

	local bindText = library:Create("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = formatKey(currentKey),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(180, 180, 180),
		Parent = bindContainer
	})

	local glowTween = tweenService:Create(stroke, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Color = accentColor})

	local function updateBindSize()
		bindIcon.Image = getIconForKey(currentKey)
		local bounds = textService:GetTextSize(bindText.Text, 13, Enum.Font.GothamBold, Vector2.new(9e9, 9e9))
		local targetWidth = bounds.X + 28
		tweenService:Create(bindContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, targetWidth, 0, 24)}):Play()
	end
	updateBindSize()

	bindContainer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if not binding then
				tweenService:Create(bindContainer, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
				tweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 100, 110)}):Play()
				tweenService:Create(bindText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				tweenService:Create(bindIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end
		elseif input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			if not binding then
				binding = true
				bindText.Text = "..."
				bindIcon.Image = "rbxassetid://10086818169" 
				tweenService:Create(bindContainer, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
				glowTween:Play()
				updateBindSize()
			end
		end
	end)

	bindContainer.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if not binding then
				tweenService:Create(bindContainer, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
				tweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 70)}):Play()
				tweenService:Create(bindText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
				tweenService:Create(bindIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(180, 180, 180)}):Play()
			end
		end
	end)

	titleBtn.MouseButton1Click:Connect(function()
		if not binding then
			
			local rippleTween = tweenService:Create(titleBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = accentColor})
			rippleTween:Play()
			task.delay(0.1, function()
				tweenService:Create(titleBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
			end)
			
			if option.hold then
				option.callback(true)
				task.wait(0.1)
				option.callback(false)
			else
				option.callback()
			end
		end
	end)

	local blacklist = {"Unknown", "MouseMovement", "Focus", "TextInput", "Touch"}
	
	inputService.InputBegan:Connect(function(input, gameProcessed)
		local keyName = (input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name) or input.UserInputType.Name
		local isBlacklisted = table.find(blacklist, keyName) ~= nil

		if binding then
			if isBlacklisted then return end

			glowTween:Cancel()
			
			if keyName == "Escape" then
				option:SetKey(currentKey) 
			elseif keyName == "Backspace" or keyName == "Delete" then
				option:SetKey("None") 
			else
				option:SetKey(keyName) 
			end
		else
			if gameProcessed and keyName ~= currentKey then return end 
			if currentKey ~= "None" and keyName == currentKey then
				
				tweenService:Create(bindContainer, TweenInfo.new(0.1), {Size = UDim2.new(0, bindContainer.AbsoluteSize.X - 4, 0, 20), BackgroundColor3 = accentColor}):Play()
				tweenService:Create(bindText, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				tweenService:Create(bindIcon, TweenInfo.new(0.1), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()

				if option.hold then
					holding = true
					option.callback(true)
				else
					option.callback()
				end
			end
		end
	end)

	inputService.InputEnded:Connect(function(input)
		local keyName = (input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name) or input.UserInputType.Name
		if not binding and keyName == currentKey and currentKey ~= "None" then
			
			tweenService:Create(bindContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, bindContainer.AbsoluteSize.X + 4, 0, 24), BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
			tweenService:Create(bindText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
			tweenService:Create(bindIcon, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(180, 180, 180)}):Play()

			if option.hold and holding then
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
		
		tweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Color = Color3.fromRGB(60, 60, 70)}):Play()
		tweenService:Create(bindContainer, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
	end
end

local function createSlider(option, parent)
	
	local accentColor = option.color or Color3.fromRGB(114, 137, 218)
	local bgDark = Color3.fromRGB(20, 20, 22)
	local bgLight = Color3.fromRGB(40, 40, 45)
	local textColor = Color3.fromRGB(240, 240, 240)
	
	option.locked = option.locked or false

	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 55),
		BackgroundTransparency = 1,
		Visible = option.visible ~= false,
		Parent = parent.content
	})
	option.main = main
	
	
	local topFrame = library:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 24),
		Position = UDim2.new(0, 10, 0, 4),
		BackgroundTransparency = 1,
		Parent = main
	})
	
	local title = library:Create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextColor3 = textColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topFrame
	})
	
	
	local valueBg = library:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 45, 0, 20),
		BackgroundColor3 = bgDark,
		Parent = topFrame
	})
	library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = valueBg })
	local valueStroke = library:Create("UIStroke", {
		Color = bgLight,
		Thickness = 1,
		Parent = valueBg
	})
	
	local inputvalue = library:Create("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = tostring(option.value),
		TextColor3 = textColor,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextEditable = not option.locked,
		ClearTextOnFocus = false,
		Parent = valueBg
	})

	
	local sliderArea = library:Create("TextButton", {
		Position = UDim2.new(0, 10, 0, 32),
		Size = UDim2.new(1, -20, 0, 16),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = main
	})
	
	
	local sliderBg = library:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = bgDark,
		ClipsDescendants = false,
		Parent = sliderArea
	})
	library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderBg })
	library:Create("UIStroke", { Color = Color3.fromRGB(30, 30, 35), Thickness = 1, Parent = sliderBg })
	
	
	local fill = library:Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = sliderBg
	})
	library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
	local fillGradient = library:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, accentColor),
			ColorSequenceKeypoint.new(1, Color3.new(math.clamp(accentColor.R + 0.2, 0, 1), math.clamp(accentColor.G + 0.2, 0, 1), math.clamp(accentColor.B + 0.2, 0, 1)))
		}),
		Parent = fill
	})
	
	
	local knob = library:Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = fill
	})
	library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
	local knobStroke = library:Create("UIStroke", {
		Color = accentColor,
		Thickness = 2,
		Parent = knob
	})
	
	local knobGlow = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843",
		ImageColor3 = accentColor,
		ImageTransparency = 1, 
		ZIndex = 0,
		Parent = knob
	})

	
	local sliding = false
	local inContact = false
	
	
	local function formatValue(val)
		local decimals = 0
		if option.float < 1 then
			local strFloat = tostring(option.float)
			local dotIndex = strFloat:find("%.")
			if dotIndex then decimals = #strFloat:sub(dotIndex + 1) end
		end
		local mult = 10 ^ decimals
		local rounded = math.floor((val * mult) + 0.5) / mult
		return string.format("%." .. decimals .. "f", rounded), rounded
	end

	
	local function updateSlider(input)
		
		local width = math.max(sliderBg.AbsoluteSize.X, 1)
		local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / width, 0, 1)
		
		local min = math.min(option.min, option.max)
		local max = math.max(option.min, option.max)

		local newValue = min + ((max - min) * percent)
		option:SetValue(newValue, true) 
	end

	sliderArea.InputBegan:Connect(function(input)
		if option.locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			inputvalue:ReleaseFocus() 
			sliding = true
			tweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 16, 0, 16)}):Play()
			tweenService:Create(knobGlow, TweenInfo.new(0.2), {ImageTransparency = 0.6, Size = UDim2.new(0, 34, 0, 34)}):Play()
			tweenService:Create(sliderBg, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 6)}):Play()
			updateSlider(input)
		end
	end)
	
	sliderArea.MouseEnter:Connect(function()
		if option.locked then return end
		inContact = true
		if not sliding then tweenService:Create(knobStroke, TweenInfo.new(0.2), {Thickness = 3}):Play() end
	end)
	
	sliderArea.MouseLeave:Connect(function()
		if option.locked then return end
		inContact = false
		if not sliding then tweenService:Create(knobStroke, TweenInfo.new(0.2), {Thickness = 2}):Play() end
	end)

	inputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	inputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if sliding then
				sliding = false
				local endKnobSize = inContact and UDim2.new(0, 14, 0, 14) or UDim2.new(0, 12, 0, 12)
				tweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = endKnobSize}):Play()
				tweenService:Create(knobGlow, TweenInfo.new(0.3), {ImageTransparency = 1, Size = UDim2.new(0, 24, 0, 24)}):Play()
				tweenService:Create(sliderBg, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 4)}):Play()
			end
		end
	end)

	inputvalue.Focused:Connect(function()
		if option.locked then inputvalue:ReleaseFocus() return end
		tweenService:Create(valueStroke, TweenInfo.new(0.2), {Color = accentColor}):Play()
	end)

	inputvalue.FocusLost:Connect(function()
		tweenService:Create(valueStroke, TweenInfo.new(0.2), {Color = bgLight}):Play()
		local rawText = inputvalue.Text:gsub("[^%-%d%.]", "")
		local num = tonumber(rawText)
		
		if num then
			option:SetValue(num, true) 
		else
			option:SetValue(option.value, true)
		end
	end)

	function option:SetValue(value, forceUpdateText)
		local min = math.min(self.min, self.max)
		local max = math.max(self.min, self.max)
		
		value = math.clamp(value, min, max)
		
		local formattedStr, finalValue = formatValue(value)
		
		local range = max - min
		if range == 0 then range = 0.0001 end
		local percent = (finalValue - min) / range

		tweenService:Create(fill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
		
		library.flags[self.flag] = finalValue
		self.value = finalValue
		
		if forceUpdateText or not inputvalue.IsFocused then
			inputvalue.Text = formattedStr
			
			local textBounds = textService:GetTextSize(formattedStr, 12, Enum.Font.Gotham, Vector2.new(999, 20))
			local newBoxWidth = math.clamp(textBounds.X + 16, 35, 80)
			tweenService:Create(valueBg, TweenInfo.new(0.2), {Size = UDim2.new(0, newBoxWidth, 0, 20)}):Play()
		end
		
		pcall(function() self.callback(finalValue) end)
	end

	function option:SetText(newText)
		title.Text = tostring(newText)
		self.text = tostring(newText)
	end

	function option:SetMinMax(min, max)
		self.min = tonumber(min) or self.min
		self.max = tonumber(max) or self.max
		self:SetValue(self.value, true) 
	end

	function option:SetColor(newColor)
		accentColor = newColor
		fillGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, accentColor),
			ColorSequenceKeypoint.new(1, Color3.new(math.clamp(accentColor.R + 0.2, 0, 1), math.clamp(accentColor.G + 0.2, 0, 1), math.clamp(accentColor.B + 0.2, 0, 1)))
		})
		knobStroke.Color = accentColor
		knobGlow.ImageColor3 = accentColor
	end

	function option:SetVisible(state)
		main.Visible = state
		self.visible = state
	end

	function option:SetLocked(state)
		self.locked = state
		inputvalue.TextEditable = not state
		
		local targetTextColor = state and Color3.fromRGB(120, 120, 120) or textColor
		local targetStrokeColor = state and Color3.fromRGB(60, 60, 60) or accentColor
		
		tweenService:Create(title, TweenInfo.new(0.3), {TextColor3 = targetTextColor}):Play()
		tweenService:Create(inputvalue, TweenInfo.new(0.3), {TextColor3 = targetTextColor}):Play()
		
		if state then
			fillGradient.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
			knobStroke.Color = Color3.fromRGB(100, 100, 100)
		else
			self:SetColor(accentColor) 
		end
	end

	option:SetValue(option.value, true)
	if option.locked then option:SetLocked(true) end

	setmetatable(option, {
		__newindex = function(t, i, v)
			if i == "Value" or i == "value" then t:SetValue(v, true)
			elseif i == "Text" or i == "text" then t:SetText(v)
			elseif i == "Locked" or i == "locked" then t:SetLocked(v)
			elseif i == "Visible" or i == "visible" then t:SetVisible(v)
			elseif i == "Color" or i == "color" then t:SetColor(v)
			else rawset(t, i, v) end
		end
	})

	return option
end

local function createList(option, parent, holder)
	local valueCount = 0
	local items = {}
	local ACCENT_COLOR = option.color or Color3.fromRGB(110, 150, 255)
	
	
	option.multiselect = option.multiselect or false
	option.maxSelect = option.maxSelect or math.huge 
	option.locked = option.locked or false 
	option.allowNull = option.allowNull == nil and true or option.allowNull 
	option.value = option.value or (option.multiselect and {} or "")

	
	option.main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		Parent = parent.content
	})
	local main = option.main
	
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

	local round = library:Create("ImageLabel", {
		Position = UDim2.new(0, 8, 0, 22),
		Size = UDim2.new(1, -16, 1, -26),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(20, 20, 22),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.03,
		Parent = main
	})

	local stroke = library:Create("UIStroke", {
		Color = Color3.fromRGB(50, 50, 50),
		Thickness = 1.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = round
	})
	
	local listvalue = library:Create("TextLabel", {
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, 
		Parent = round
	})
	
	local arrow = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Rotation = 90, 
		BackgroundTransparency = 1,
		Image = "rbxassetid://4918373417",
		ImageColor3 = Color3.fromRGB(160, 160, 160),
		ScaleType = Enum.ScaleType.Fit,
		Parent = round
	})

	
	local clearBtn = library:Create("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(924, 724),
		ImageRectSize = Vector2.new(36, 36),
		ImageColor3 = Color3.fromRGB(150, 150, 150),
		Visible = false,
		ZIndex = 5,
		Parent = round
	})

	local function updateDisplayText()
		local hasValue = false
		if option.multiselect then
			if type(option.value) == "table" then
				if #option.value == 0 then
					listvalue.Text = "Select options..."
					listvalue.TextColor3 = Color3.fromRGB(120, 120, 120)
				elseif #option.value <= 2 then
					listvalue.Text = table.concat(option.value, ", ")
					listvalue.TextColor3 = Color3.fromRGB(255, 255, 255)
					hasValue = true
				else
					listvalue.Text = tostring(#option.value) .. "/" .. (option.maxSelect == math.huge and "∞" or tostring(option.maxSelect)) .. " Selected"
					listvalue.TextColor3 = ACCENT_COLOR
					hasValue = true
				end
			end
		else
			if option.value == "" then
				listvalue.Text = "Select option..."
				listvalue.TextColor3 = Color3.fromRGB(120, 120, 120)
			else
				listvalue.Text = tostring(option.value)
				listvalue.TextColor3 = Color3.fromRGB(255, 255, 255)
				hasValue = true
			end
		end
		
		
		clearBtn.Visible = hasValue and option.allowNull and not option.locked
	end
	updateDisplayText()

	
	clearBtn.MouseButton1Click:Connect(function()
		if option.locked then return end
		option:SetValue(option.multiselect and {} or "")
		tweenService:Create(clearBtn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 80, 80)}):Play()
		task.delay(0.2, function() tweenService:Create(clearBtn, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play() end)
	end)
	
	
	option.mainHolder = library:Create("Frame", {
		ZIndex = 50,
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = library.base
	})

	local dropShadow = library:Create("ImageLabel", {
		ZIndex = 49,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -2),
		Size = UDim2.new(1, 16, 1, 18),
		BackgroundTransparency = 1,
		Image = "rbxassetid://4731308832",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(21, 21, 278, 278),
		Parent = option.mainHolder
	})

	local dropBg = library:Create("ImageLabel", {
		ZIndex = 50,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3570695787",
		ImageColor3 = Color3.fromRGB(25, 25, 30),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.03,
		ClipsDescendants = true,
		Parent = option.mainHolder
	})
	
	library:Create("UIStroke", {
		Color = Color3.fromRGB(60, 60, 60),
		Thickness = 1,
		Parent = dropBg
	})

	
	local searchBoxHolder = library:Create("Frame", {
		ZIndex = 51,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		BorderSizePixel = 0,
		Parent = dropBg
	})
	
	local searchIcon = library:Create("ImageLabel", {
		ZIndex = 52,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6031154871",
		ImageColor3 = Color3.fromRGB(150, 150, 150),
		Parent = searchBoxHolder
	})

	local searchBox = library:Create("TextBox", {
		ZIndex = 52,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(1, -38, 1, 0),
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		Text = "",
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = searchBoxHolder
	})
	
	library:Create("Frame", {
		ZIndex = 51,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(50, 50, 55),
		Parent = searchBoxHolder
	})

	
	local actionOffset = 32
	if option.multiselect then
		actionOffset = 58
		local actionHolder = library:Create("Frame", {
			ZIndex = 51,
			Position = UDim2.new(0, 0, 0, 32),
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = Color3.fromRGB(22, 22, 26),
			BorderSizePixel = 0,
			Parent = dropBg
		})

		local selectAllBtn = library:Create("TextButton", {
			ZIndex = 52, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1, Text = "Select All", TextSize = 11, Font = Enum.Font.GothamBold,
			TextColor3 = ACCENT_COLOR, Parent = actionHolder
		})
		local deselectAllBtn = library:Create("TextButton", {
			ZIndex = 52, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
			BackgroundTransparency = 1, Text = "Deselect All", TextSize = 11, Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(255, 100, 100), Parent = actionHolder
		})

		selectAllBtn.MouseButton1Click:Connect(function()
			local all = {}
			for i, v in ipairs(items) do if i <= option.maxSelect then table.insert(all, v.name) end end
			option:SetValue(all)
		end)
		deselectAllBtn.MouseButton1Click:Connect(function() option:SetValue({}) end)
		
		library:Create("Frame", {ZIndex = 51, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.fromRGB(50, 50, 55), BorderSizePixel = 0, Parent = actionHolder})
	end
	
	local content = library:Create("ScrollingFrame", {
		ZIndex = 51,
		Position = UDim2.new(0, 0, 0, actionOffset),
		Size = UDim2.new(1, 0, 1, -actionOffset),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = ACCENT_COLOR,
		ScrollBarThickness = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = dropBg
	})
	
	local layout = library:Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = content
	})
	
	library:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent = content
	})
	
	local function updateDropdownSize()
		local contentHeight = layout.AbsoluteContentSize.Y + 8
		local targetHeight = math.clamp(contentHeight, 0, 180) + actionOffset
		content.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
		return targetHeight
	end

	
	local inContact = false
	round.InputBegan:connect(function(input)
		if option.locked then return end
		
		if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
			if library.activePopup and library.activePopup ~= option then library.activePopup:Close() end
			
			if option.open then
				option:Close()
			else
				option.open = true
				library.activePopup = option
				option.mainHolder.Visible = true
				searchBox.Text = "" 
				
				task.wait()
				local absPos = round.AbsolutePosition
				local absSize = round.AbsoluteSize
				local targetHeight = updateDropdownSize()
				local viewportY = workspace.CurrentCamera.ViewportSize.Y
				
				local viewport = workspace.CurrentCamera.ViewportSize
				
				local targetX = absPos.X + absSize.X + 25
				
				if targetX + absSize.X + 10 > viewport.X then
					targetX = absPos.X - absSize.X - 25
				end

				local targetY = absPos.Y
				
				if targetY + targetHeight + 10 > viewport.Y then
					targetY = viewport.Y - targetHeight - 10
				end
				
				option.mainHolder.Position = UDim2.new(0, targetX, 0, targetY)
				option.mainHolder.Size = UDim2.new(0, absSize.X, 0, 0)
				
				tweenService:Create(arrow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 0, ImageColor3 = ACCENT_COLOR}):Play()
				tweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = ACCENT_COLOR}):Play()
				tweenService:Create(round, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(30, 30, 35)}):Play()
				
				tweenService:Create(option.mainHolder, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, absSize.X, 0, targetHeight)
				}):Play()

				
				if option.value ~= "" then
					for _, item in pairs(items) do
						local isSelected = option.multiselect and table.find(option.value, item.name) or option.value == item.name
						if isSelected then
							task.spawn(function()
								task.wait(0.1)
								local targetScroll = item.instance.AbsolutePosition.Y - content.AbsolutePosition.Y
								tweenService:Create(content, TweenInfo.new(0.3), {CanvasPosition = Vector2.new(0, targetScroll)}):Play()
							end)
							break
						end
					end
				end
			end
		end
		
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not option.open and not option.locked then
				tweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 100, 100)}):Play()
				tweenService:Create(round, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(25, 25, 30)}):Play()
			end
		end
	end)
	
	round.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not option.open and not option.locked then
				tweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 50)}):Play()
				tweenService:Create(round, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(20, 20, 22)}):Play()
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
		task.spawn(function()
			task.wait()
			if option.open then
				tweenService:Create(option.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, round.AbsoluteSize.X, 0, updateDropdownSize())}):Play()
			end
		end)
	end)

	
	local function createItemRipple(btn, color)
		local ripple = library:Create("ImageLabel", {
			BackgroundTransparency = 1, Image = "rbxassetid://2708891598", ImageColor3 = color, ImageTransparency = 0.6,
			ZIndex = 55, Parent = btn, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 0, 0, 0)
		})
		tweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 50, 1, 50), ImageTransparency = 1}):Play()
		game.Debris:AddItem(ripple, 0.5)
	end

	
	local function shakeUI(uiElem)
		local orig = uiElem.Position
		local t = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true)
		tweenService:Create(uiElem, t, {Position = orig + UDim2.new(0, 4, 0, 0)}):Play()
	end
	
	
	function option:AddValue(value)
		local isSelected = option.multiselect and (table.find(option.value, tostring(value)) ~= nil) or (option.value == tostring(value))
		valueCount = valueCount + 1
		
		local btn = library:Create("TextButton", {
			ZIndex = 52, Size = UDim2.new(1, -8, 0, 28), BackgroundTransparency = isSelected and 0.85 or 1,
			BackgroundColor3 = ACCENT_COLOR, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ClipsDescendants = true, Parent = content
		})
		library:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })
		
		local accentLine = library:Create("Frame", {
			ZIndex = 53, Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 4, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = ACCENT_COLOR, BorderSizePixel = 0, BackgroundTransparency = isSelected and 0 or 1, Parent = btn
		})
		library:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = accentLine })

		local itemText = library:Create("TextLabel", {
			ZIndex = 53, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, isSelected and 28 or 12, 0, 0), BackgroundTransparency = 1,
			Text = tostring(value), TextSize = 13, Font = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham,
			TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180), TextXAlignment = Enum.TextXAlignment.Left, Parent = btn
		})

		local checkIcon = library:Create("ImageLabel", {
			ZIndex = 53, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
			Image = "rbxassetid://6031094667", ImageColor3 = ACCENT_COLOR, ImageTransparency = isSelected and 0 or 1, Parent = btn
		})
		
		table.insert(items, {name = tostring(value), instance = btn, textLabel = itemText, check = checkIcon, line = accentLine})
		
		btn.InputBegan:connect(function(input)
			if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
				if self.multiselect then
					local index = table.find(self.value, tostring(value))
					if index then
						
						if not self.allowNull and #self.value <= 1 then
							shakeUI(btn) createItemRipple(btn, Color3.fromRGB(255, 50, 50)) return
						end
						table.remove(self.value, index)
					else
				
						if #self.value >= self.maxSelect then
							shakeUI(btn) createItemRipple(btn, Color3.fromRGB(255, 50, 50)) return
						end
						table.insert(self.value, tostring(value))
					end
					createItemRipple(btn, ACCENT_COLOR)
					self:SetValue(self.value)
				else
					if not self.allowNull and self.value == tostring(value) then return end
					createItemRipple(btn, ACCENT_COLOR)
					self:SetValue(value)
					self:Close()
				end
			end
		end)
		
		btn.MouseEnter:Connect(function()
			if not (self.multiselect and table.find(self.value, tostring(value)) or self.value == tostring(value)) then
				tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.95, BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				tweenService:Create(itemText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230), Position = UDim2.new(0, 16, 0, 0)}):Play()
			end
		end)
		
		btn.MouseLeave:Connect(function()
			if not (self.multiselect and table.find(self.value, tostring(value)) or self.value == tostring(value)) then
				tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				tweenService:Create(itemText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180), Position = UDim2.new(0, 12, 0, 0)}):Play()
			end
		end)
		if option.open then updateDropdownSize() end
	end

	for _, value in next, option.values do option:AddValue(tostring(value)) end
	
	function option:Refresh(newValues)
		for _, item in pairs(items) do item.instance:Destroy() end
		items = {} valueCount = 0
		for _, val in pairs(newValues) do self:AddValue(tostring(val)) end
		
		if self.multiselect then
			local validValues = {}
			for _, v in pairs(self.value) do if table.find(newValues, v) then table.insert(validValues, v) end end
			self:SetValue(validValues)
		else
			self:SetValue(table.find(newValues, self.value) and self.value or (newValues[1] or ""))
		end
	end
	
	
	function option:SetValue(value)
		if self.multiselect then
			self.value = type(value) == "table" and value or {tostring(value)}
		else
			self.value = tostring(value)
		end
		library.flags[self.flag] = self.value
		updateDisplayText()
		
		for _, item in pairs(items) do
			local isSelected = self.multiselect and table.find(self.value, item.name) ~= nil or item.name == self.value
			local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			tweenService:Create(item.instance, tInfo, {BackgroundTransparency = isSelected and 0.85 or 1, BackgroundColor3 = isSelected and ACCENT_COLOR or Color3.fromRGB(255, 255, 255)}):Play()
			tweenService:Create(item.textLabel, tInfo, {TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180), Position = UDim2.new(0, isSelected and 28 or 12, 0, 0)}):Play()
			item.textLabel.Font = isSelected and Enum.Font.GothamSemibold or Enum.Font.Gotham
			tweenService:Create(item.line, tInfo, {BackgroundTransparency = isSelected and 0 or 1}):Play()
			tweenService:Create(item.check, tInfo, {ImageTransparency = isSelected and 0 or 1}):Play()
		end
		pcall(self.callback, self.value)
	end
	
	
	function option:SetLocked(state)
		self.locked = state
		if state and self.open then self:Close() end
		local targetColor = state and Color3.fromRGB(30, 30, 32) or Color3.fromRGB(20, 20, 22)
		local targetStroke = state and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(50, 50, 50)
		local targetText = state and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(180, 180, 180)
		
		tweenService:Create(round, TweenInfo.new(0.3), {ImageColor3 = targetColor}):Play()
		tweenService:Create(stroke, TweenInfo.new(0.3), {Color = targetStroke}):Play()
		tweenService:Create(title, TweenInfo.new(0.3), {TextColor3 = targetText}):Play()
		tweenService:Create(arrow, TweenInfo.new(0.3), {ImageColor3 = targetText}):Play()
		clearBtn.Visible = (not state) and (self.value ~= "" and self.allowNull)
	end

	
	function option:Close()
		library.activePopup = nil
		self.open = false
		tweenService:Create(arrow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = 90, ImageColor3 = Color3.fromRGB(160, 160, 160)}):Play()
		tweenService:Create(stroke, TweenInfo.new(0.3), {Color = inContact and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(50, 50, 50)}):Play()
		tweenService:Create(round, TweenInfo.new(0.3), {ImageColor3 = inContact and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(20, 20, 22)}):Play()
		
		local closeTween = tweenService:Create(self.mainHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, round.AbsoluteSize.X, 0, 0)})
		closeTween:Play()
		task.delay(0.3, function() if not self.open then self.mainHolder.Visible = false end end)
	end

	return option
end

local function createBox(option, parent)
	local padding = 10
	local hasIcon = option.icon and option.icon ~= ""
	local maxLength = option.maxLength or 0
	
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 56), 
		BackgroundTransparency = 1,
		Parent = parent.content
	})

	local title = library:Create("TextLabel", {
		Position = UDim2.new(0, padding, 0, 4),
		Size = UDim2.new(1, -20, 0, 14),
		BackgroundTransparency = 1,
		Text = option.text,
		TextSize = 14,
		Font = Enum.Font.GothamSemibold, 
		TextColor3 = Color3.fromRGB(200, 200, 200),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main
	})

	local charCount = library:Create("TextLabel", {
		Position = UDim2.new(0, padding, 0, 4),
		Size = UDim2.new(1, -20, 0, 14),
		BackgroundTransparency = 1,
		Text = maxLength > 0 and "0/" .. tostring(maxLength) or "",
		TextSize = 12,
		Font = Enum.Font.Gotham, 
		TextColor3 = Color3.fromRGB(120, 120, 120),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = main
	})

	local boxBg = library:Create("Frame", {
		Position = UDim2.new(0, padding, 0, 24),
		Size = UDim2.new(1, -(padding * 2), 1, -28),
		BackgroundColor3 = Color3.fromRGB(25, 25, 28),
		Parent = main
	})
	
	library:Create("UICorner", {
		CornerRadius = UDim.new(0, 6),
		Parent = boxBg
	})

	local stroke = library:Create("UIStroke", {
		Color = Color3.fromRGB(50, 50, 55),
		Thickness = 1.2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = boxBg
	})

	local glow = library:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 20, 1, 20),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843", 
		ImageColor3 = Color3.fromRGB(100, 150, 255),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = 0,
		Parent = boxBg
	})

	local iconImage
	if hasIcon then
		iconImage = library:Create("ImageLabel", {
			Position = UDim2.new(0, 10, 0.5, -9),
			Size = UDim2.new(0, 18, 0, 18),
			BackgroundTransparency = 1,
			Image = option.icon,
			ImageColor3 = Color3.fromRGB(120, 120, 120),
			Parent = boxBg
		})
	end

	local clearBtn = library:Create("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(924, 724),
		ImageRectSize = Vector2.new(36, 36),
		ImageColor3 = Color3.fromRGB(150, 150, 150),
		ImageTransparency = 1,
		Visible = false,
		ZIndex = 5,
		Parent = boxBg
	})

	local textOffsetX = hasIcon and 36 or 12
	local textWidthLimit = 32 
	
	local inputvalue = library:Create("TextBox", {
		Position = UDim2.new(0, textOffsetX, 0, 0),
		Size = UDim2.new(1, -(textOffsetX + textWidthLimit), 1, 0),
		BackgroundTransparency = 1,
		Text = tostring(option.value or ""),
		PlaceholderText = option.placeholder or "",
		PlaceholderColor3 = Color3.fromRGB(100, 100, 105),
		ClearTextOnFocus = option.clearOnFocus or false,
		TextSize = 14,
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
		Parent = boxBg
	})

	
	local inContact = false
	local focused = false
	local accentColor = Color3.fromRGB(100, 150, 255) 

	local function shakeBox()
		local originalPos = boxBg.Position
		local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 3, true)
		tweenService:Create(boxBg, tweenInfo, {Position = originalPos + UDim2.new(0, 3, 0, 0)}):Play()
		tweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 80, 80)}):Play()
		task.delay(0.4, function()
			if focused then
				tweenService:Create(stroke, TweenInfo.new(0.2), {Color = accentColor}):Play()
			else
				tweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 50, 55)}):Play()
			end
		end)
	end

	local function updateTextLogic()
		local currentText = inputvalue.Text
		
		if option.numeric then
			local newText = currentText:gsub("%D", "")
			if newText ~= currentText then
				inputvalue.Text = newText
				currentText = newText
				shakeBox()
			end
		end

		if maxLength > 0 then
			if #currentText > maxLength then
				currentText = string.sub(currentText, 1, maxLength)
				inputvalue.Text = currentText
				shakeBox()
			end
			charCount.Text = tostring(#currentText) .. "/" .. tostring(maxLength)
			
			if #currentText == maxLength then
				tweenService:Create(charCount, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 120, 120)}):Play()
			else
				tweenService:Create(charCount, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
			end
		end

		if #currentText > 0 then
			clearBtn.Visible = true
			tweenService:Create(clearBtn, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
		else
			tweenService:Create(clearBtn, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
			task.delay(0.2, function() if #inputvalue.Text == 0 then clearBtn.Visible = false end end)
		end

		if option.liveUpdate then
			library.flags[option.flag] = currentText
			option.value = currentText
			task.spawn(function() pcall(option.callback, currentText, false) end)
		end
	end

	inputvalue:GetPropertyChangedSignal("Text"):Connect(updateTextLogic)

	clearBtn.MouseButton1Click:Connect(function()
		inputvalue.Text = ""
		inputvalue:CaptureFocus()
		updateTextLogic()
	end)

	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = true
			if not focused then
				tweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(80, 80, 85)}):Play()
				tweenService:Create(boxBg, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
			end
		end
	end)

	main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			inContact = false
			if not focused then
				tweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(50, 50, 55)}):Play()
				tweenService:Create(boxBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(25, 25, 28)}):Play()
			end
		end
	end)

	inputvalue.Focused:Connect(function()
		focused = true
		tweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = accentColor}):Play()
		tweenService:Create(glow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.6, Size = UDim2.new(1, 14, 1, 14)}):Play()
		tweenService:Create(title, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		if iconImage then tweenService:Create(iconImage, TweenInfo.new(0.3), {ImageColor3 = accentColor}):Play() end
	end)

	inputvalue.FocusLost:Connect(function(enterPressed)
		focused = false
		local targetStroke = inContact and Color3.fromRGB(80, 80, 85) or Color3.fromRGB(50, 50, 55)
		local targetBg = inContact and Color3.fromRGB(30, 30, 35) or Color3.fromRGB(25, 25, 28)
		
		tweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = targetStroke}):Play()
		tweenService:Create(boxBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = targetBg}):Play()
		tweenService:Create(glow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 1, Size = UDim2.new(1, 20, 1, 20)}):Play()
		tweenService:Create(title, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
		if iconImage then tweenService:Create(iconImage, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(120, 120, 120)}):Play() end

		local finalText = inputvalue.Text
		if finalText == "" and option.numeric then finalText = "0" inputvalue.Text = finalText end
		
		option:SetValue(finalText, enterPressed)
	end)

	function option:SetValue(value, enter)
		local val = tostring(value)
		if self.numeric then val = val:gsub("%D", "") if val == "" then val = "0" end end
		if maxLength > 0 and #val > maxLength then val = string.sub(val, 1, maxLength) end
		
		library.flags[self.flag] = val
		self.value = val
		
		if inputvalue.Text ~= val then
			inputvalue.Text = val
		end
		
		task.spawn(function()
			pcall(self.callback, val, enter)
		end)
	end

	updateTextLogic()
	
	return option
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

local function createDivider(option, parent)
	local main = library:Create("Frame", {
		LayoutOrder = option.position,
		Size = UDim2.new(1, 0, 0, 24), 
		BackgroundTransparency = 1,
		Parent = parent.content
	})

	if option.text and option.text ~= "" then
		
		local textLabel = library:Create("TextLabel", {
			Size = UDim2.new(0, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Text = option.text,
			TextSize = 13,
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.fromRGB(140, 140, 140),
			Parent = main
		})

		local leftLine = library:Create("Frame", {
			Size = UDim2.new(0.5, -20, 0, 1),
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BorderSizePixel = 0,
			Parent = main
		})

		local rightLine = library:Create("Frame", {
			Size = UDim2.new(0.5, -20, 0, 1),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BorderSizePixel = 0,
			Parent = main
		})
		
		
		local function updateDividerSize()
			local bounds = textService:GetTextSize(textLabel.Text, textLabel.TextSize, textLabel.Font, Vector2.new(9e9, 9e9))
			textLabel.Size = UDim2.new(0, bounds.X + 16, 1, 0)
			leftLine.Size = UDim2.new(0.5, -(bounds.X / 2) - 18, 0, 1)
			rightLine.Size = UDim2.new(0.5, -(bounds.X / 2) - 18, 0, 1)
		end
		
		textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateDividerSize)
		task.spawn(updateDividerSize)
	else
		
		library:Create("Frame", {
			Size = UDim2.new(1, -20, 0, 1),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			BorderSizePixel = 0,
			Parent = main
		})
	end

	return option
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
		elseif newOption.type == "divider" then 
			createDivider(newOption, option)   
		elseif newOption.type == "folder" then
			newOption:init()
		end
	end
end

local function getFnctions(parent)

function parent:AddDivider(option)
		
		if type(option) == "string" then
			option = {text = option}
		else
			option = typeof(option) == "table" and option or {}
		end
		
		option.text = option.text or ""
		option.type = "divider"
		option.position = #self.options
		table.insert(self.options, option)
		
		return option
	end

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
		option.numeric = typeof(option.numeric) == "boolean" and option.numeric or false 
		option.maxLength = typeof(option.maxLength) == "number" and option.maxLength or 0 
		option.liveUpdate = typeof(option.liveUpdate) == "boolean" and option.liveUpdate or false 
		option.icon = typeof(option.icon) == "string" and option.icon or "" 
		
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

function library:CreateWindow(options)
	local titleText = typeof(options) == "string" and options or (options.Title or options.title or "Window")
	local window = {title = tostring(titleText), options = {}, open = true, canInit = true, init = false, position = #self.windows}

	getFnctions(window)
	
	table.insert(library.windows, window)
	
	return window
end

local UIToggle

function library:Watermark(options)
	options = typeof(options) == "table" and options or {}
	
	self.wmSettings = self.wmSettings or {
		Title = "empty",
		Rainbow = true,
		Color = Color3.fromRGB(110, 150, 255), 
		Visible = true
	}

	if options.Title ~= nil then self.wmSettings.Title = tostring(options.Title) end
	if options.Visible ~= nil then self.wmSettings.Visible = options.Visible end
	if options.Color ~= nil then 
		self.wmSettings.Color = options.Color 
		if options.Rainbow == nil then self.wmSettings.Rainbow = false end
	end
	if options.Rainbow ~= nil then self.wmSettings.Rainbow = options.Rainbow end

	if not self.base then
		self.base = self:Create("ScreenGui")
	end

	if not self.watermark then
		self.wmContainer = self:Create("Frame", {
			Name = "WatermarkContainer",
			Position = UDim2.new(0, 20, 0, 20),
			Size = UDim2.new(0, 0, 0, 34),
			BackgroundTransparency = 1,
			Parent = self.base,
			Active = true
		})

		local auraGlow = self:Create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 40, 1, 40),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6015897843",
			ImageColor3 = self.wmSettings.Color,
			ImageTransparency = 0.4,
			SliceCenter = Rect.new(49, 49, 450, 450),
			ScaleType = Enum.ScaleType.Slice,
			ZIndex = 0,
			Parent = self.wmContainer
		})

		self.watermark = self:Create("Frame", {
			Name = "MainAcrylic",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(15, 15, 18),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ZIndex = 2,
			Parent = self.wmContainer
		})

		self:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.watermark })

		local stroke = self:Create("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1.5,
			Transparency = 0.1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = self.watermark
		})
		local strokeGradient = self:Create("UIGradient", { Rotation = 0, Parent = stroke })

		local topAccent = self:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = self.watermark
		})
		local accentGradient = self:Create("UIGradient", { Parent = topAccent })

		local wmText = self:Create("TextLabel", {
			Size = UDim2.new(1, -24, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Text = "",
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextColor3 = Color3.fromRGB(240, 240, 245),
			TextXAlignment = Enum.TextXAlignment.Left,
			RichText = true,
			ZIndex = 3,
			Parent = self.watermark
		})

		local isCollapsed = false
		local wmDragging, wmDragInput, wmDragStart, wmStartPos
		local dragStartTime = 0

		self.wmContainer.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				wmDragging = true
				wmDragInput = input
				wmDragStart = input.Position
				wmStartPos = self.wmContainer.Position
				dragStartTime = os.clock()
			end
		end)

		inputService.InputChanged:Connect(function(input)
			if input == wmDragInput and wmDragging then
				local delta = input.Position - wmDragStart
				if delta.Magnitude > 2 then 
					local viewport = workspace.CurrentCamera.ViewportSize
					local wmSize = self.wmContainer.AbsoluteSize
					local newX = math.clamp(wmStartPos.X.Offset + delta.X, 0, viewport.X - wmSize.X)
					local newY = math.clamp(wmStartPos.Y.Offset + delta.Y, 0, viewport.Y - wmSize.Y)

					tweenService:Create(self.wmContainer, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Position = UDim2.new(0, newX, 0, newY)
					}):Play()
				end
			end
		end)

		inputService.InputEnded:Connect(function(input)
			if input == wmDragInput then
				wmDragging = false
				wmDragInput = nil
				if os.clock() - dragStartTime < 0.25 then 
					local delta = input.Position - wmDragStart
					if delta.Magnitude < 5 then 
						isCollapsed = not isCollapsed
						tweenService:Create(self.watermark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundColor3 = Color3.fromRGB(40, 40, 50)
						}):Play()
						task.wait(0.1)
						tweenService:Create(self.watermark, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundColor3 = Color3.fromRGB(15, 15, 18)
						}):Play()
					end
				end
			end
		end)

		
		local currentFPS = 0
		local frameHistory = {}
		local maxFrames = 15 

		runService.RenderStepped:Connect(function(deltaTime)
			table.insert(frameHistory, deltaTime)
			if #frameHistory > maxFrames then
				table.remove(frameHistory, 1)
			end
			
			local totalDt = 0
			for _, dt in ipairs(frameHistory) do
				totalDt = totalDt + dt
			end
			
			
			currentFPS = math.round(1 / (totalDt / #frameHistory))
		end)

		local lastTargetWidth = 0
		local rotationValue = 0
		local localPlayer = game:GetService("Players").LocalPlayer
		local statsService = game:GetService("Stats")

		runService.Heartbeat:Connect(function(dt)
			if not self.wmContainer.Visible then return end
			local settings = self.wmSettings

			
			rotationValue = (rotationValue + (dt * 60)) % 360
			strokeGradient.Rotation = rotationValue

			local mainColor = settings.Color
			if settings.Rainbow then
				local h = tick() % 4 / 4
				mainColor = Color3.fromHSV(h, 0.8, 1)
				local color2 = Color3.fromHSV((h + 0.15) % 1, 0.8, 1)
				
				local seq = ColorSequence.new({
					ColorSequenceKeypoint.new(0, mainColor),
					ColorSequenceKeypoint.new(0.5, color2),
					ColorSequenceKeypoint.new(1, mainColor)
				})
				
				strokeGradient.Color = seq
				accentGradient.Color = seq
			else
				local h, s, v = Color3.toHSV(mainColor)
				local color2 = Color3.fromHSV(h, s, math.clamp(v - 0.3, 0.2, 1))
				local seq = ColorSequence.new({
					ColorSequenceKeypoint.new(0, mainColor),
					ColorSequenceKeypoint.new(0.5, color2),
					ColorSequenceKeypoint.new(1, mainColor)
				})
				strokeGradient.Color = seq
				accentGradient.Color = seq
			end
			
			auraGlow.ImageColor3 = mainColor
			auraGlow.ImageTransparency = 0.3 + math.sin(tick() * 3) * 0.1

			local targetWidth = 0
			local titleHex = "#" .. mainColor:ToHex()
			local dotHex = "<font color='#555555'> • </font>"

			if isCollapsed then
				local firstChar = string.sub(settings.Title, 1, 1)
				wmText.Text = string.format("<b><font color='%s'>%s</font></b>", titleHex, firstChar)
				wmText.TextXAlignment = Enum.TextXAlignment.Center
				targetWidth = 34
			else
				
				local ping = 0
				local networkPing = localPlayer:GetNetworkPing() * 1000
				if networkPing > 0 then
					ping = math.round(networkPing)
				else
					
					pcall(function()
						ping = math.round(statsService.Network.ServerStatsItem["Data Ping"]:GetValue())
					end)
				end

				
				local fpsColor = currentFPS >= 55 and "#55FF55" or (currentFPS >= 30 and "#FFFF55" or "#FF5555")
				local pingColor = ping <= 80 and "#55FF55" or (ping <= 150 and "#FFFF55" or "#FF5555")

				
				local timeStr = os.date("%H:%M:%S")
				local playerName = localPlayer.Name
				
				
				local finalText = string.format(
					"<b><font color='%s'>%s</font></b>%s%s%s<font color='%s'>%d FPS</font>%s<font color='%s'>%dms</font>%s%s", 
					titleHex, settings.Title, 
					dotHex, playerName, 
					dotHex, fpsColor, currentFPS, 
					dotHex, pingColor, ping, 
					dotHex, timeStr
				)
				
				wmText.Text = finalText
				wmText.TextXAlignment = Enum.TextXAlignment.Left

				
				local stripText = string.format("%s   %s   %d FPS   %dms   %s", settings.Title, playerName, currentFPS, ping, timeStr)
				local textBounds = textService:GetTextSize(stripText, 13, Enum.Font.GothamMedium, Vector2.new(9999, 34))
				targetWidth = textBounds.X + 24 
			end

			
			if targetWidth ~= lastTargetWidth then
				lastTargetWidth = targetWidth
				tweenService:Create(self.wmContainer, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
					Size = UDim2.new(0, targetWidth, 0, 34)
				}):Play()
			end
		end)
	end
	
	self.wmContainer.Visible = self.wmSettings.Visible
end

local function generateRandomName()
    local HttpService = game:GetService("HttpService")
    local randomName = HttpService:GenerateGUID(false):gsub("-", "")
    return randomName
end


local function ProtectAndParentGui(gui)
    
    gui.Name = generateRandomName()
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 2147483647
    gui.IgnoreGuiInset = true
    
    
    if set_thread_identity then set_thread_identity(8) end
    gui.Archivable = false 

    
    local hui = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui())
    local protect = (syn and syn.protect_gui) or protect_gui or protectgui or (krnl and krnl.protectgui)
    
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    
    if hui then
        
        if protect then pcall(protect, gui) end
        gui.Parent = hui
    elseif protect then
        
        pcall(protect, gui)
        gui.Parent = CoreGui
    else
       
        local successRobloxGui = pcall(function()
            local robloxGui = CoreGui:FindFirstChild("RobloxGui")
            if robloxGui then
                gui.Parent = robloxGui
            else
                error("No RobloxGui")
            end
        end)

        if not successRobloxGui then
            local successCore = pcall(function()
                gui.Parent = CoreGui
            end)
            
            if not successCore then
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                gui.Parent = playerGui
                warn("[Library] Warning: Your executor does not support hiding the GUI, basic stealth mode has been used")
            end
        end
    end
end

function library:Init()
    self.base = self.base or self:Create("ScreenGui")
    
    ProtectAndParentGui(self.base)
    
    for _, window in next, self.windows do
        if window.canInit and not window.init then
            window.init = true
            createOptionHolder(window.title, self.base, window)
            loadOptions(window)
        end
    end
    
    if self.wmContainer then
        self.wmContainer.Parent = self.base
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
	if input.UserInputType == ui or input.UserInputType == Enum.UserInputType.Touch then
		if library.activePopup then
			local mx, my = input.Position.X, input.Position.Y
			
			local popup = library.activePopup.mainHolder
			local header = library.activePopup.main 
			
			local inPopup = false
			if popup and popup.Visible then
				inPopup = (mx >= popup.AbsolutePosition.X and mx <= popup.AbsolutePosition.X + popup.AbsoluteSize.X) and 
						  (my >= popup.AbsolutePosition.Y and my <= popup.AbsolutePosition.Y + popup.AbsoluteSize.Y)
			end
			
			local inHeader = false
			if header then
				inHeader = (mx >= header.AbsolutePosition.X and mx <= header.AbsolutePosition.X + header.AbsoluteSize.X) and 
						   (my >= header.AbsolutePosition.Y and my <= header.AbsolutePosition.Y + header.AbsoluteSize.Y)
			end
			
		
			if not inPopup and not inHeader then
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

local MAX_NOTIFICATIONS = 6
local notificationCount = 0

function library:Notify(options)
	options = typeof(options) == "table" and options or {}
	local titleText = tostring(options.Title or "Notification")
	local descText = tostring(options.Content or options.Text or "")
	local duration = tonumber(options.Duration) or 5
	local notifType = string.lower(tostring(options.Type or "info"))
	local customIcon = options.Icon
	local customColor = options.Color
	local buttons = options.Buttons or {}

	local runService = game:GetService("RunService")
	local tweenService = game:GetService("TweenService")
	local textService = game:GetService("TextService")

	local typeConfig = {
		info = {color = Color3.fromRGB(255, 255, 255), icon = "rbxassetid://85388369218358", sound = "rbxassetid://4590662766"},
		success = {color = Color3.fromRGB(80, 255, 140), icon = "rbxassetid://78807094206141", sound = "rbxassetid://4590662766"},
		warning = {color = Color3.fromRGB(255, 200, 80), icon = "rbxassetid://86180038425615", sound = "rbxassetid://4590662766"},
		error = {color = Color3.fromRGB(255, 80, 80), icon = "rbxassetid://79175218998472", sound = "rbxassetid://4590662766"},
		custom = {color = customColor or Color3.fromRGB(255, 255, 255), icon = customIcon or "rbxassetid://85388369218358", sound = "rbxassetid://4590662766"}
	}
	
	if not typeConfig[notifType] then notifType = "info" end
	local config = typeConfig[notifType]
	local accentColor = config.color

	
	if not self.base then
		self.base = self:Create("ScreenGui", { Name = "skibidi_notify", Parent = game:GetService("CoreGui"), ResetOnSpawn = true })
	end

	if not self.notifContainer then
		self.notifContainer = self:Create("Frame", {
			Name = "NotificationContainer",
			Size = UDim2.new(0, 320, 1, -40),
			Position = UDim2.new(1, -340, 0, 20),
			BackgroundTransparency = 1,
			Parent = self.base
		})

		self:Create("UIListLayout", {
			Parent = self.notifContainer,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	end


	local titleSize = 15
	local descSize = 13
	local descBounds = textService:GetTextSize(descText, descSize, Enum.Font.Gotham, Vector2.new(250, 9e9))
	
	local targetHeight = 44 
	if descText ~= "" then targetHeight = targetHeight + descBounds.Y + 6 end
	if #buttons > 0 then targetHeight = targetHeight + 36 end

	local holder = self:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = self.notifContainer,
		LayoutOrder = notificationCount
	})
	notificationCount = notificationCount + 1

	local mainCard = self:Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(1, 400, 0, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 18),
		BackgroundTransparency = 0.15,
		ClipsDescendants = false, 
		Parent = holder
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = mainCard })
	self:Create("UIStroke", { Color = accentColor, Thickness = 1.2, Transparency = 0.5, Parent = mainCard })


	self:Create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 40, 1, 40),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843",
		ImageColor3 = accentColor,
		ImageTransparency = 0.6,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ScaleType = Enum.ScaleType.Slice,
		ZIndex = 0,
		Parent = mainCard
	})

	
	local contentClip = self:Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = mainCard
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = contentClip })


	self:Create("ImageLabel", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 14, 0, 12),
		BackgroundTransparency = 1,
		Image = config.icon,
		ImageColor3 = accentColor,
		ZIndex = 3,
		Parent = contentClip
	})


	self:Create("TextLabel", {
		Size = UDim2.new(1, -50, 0, 20),
		Position = UDim2.new(0, 42, 0, 12),
		BackgroundTransparency = 1,
		Text = titleText,
		TextSize = titleSize,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
		Parent = contentClip
	})

	
	if descText ~= "" then
		self:Create("TextLabel", {
			Size = UDim2.new(1, -54, 0, descBounds.Y),
			Position = UDim2.new(0, 42, 0, 34),
			BackgroundTransparency = 1,
			Text = descText,
			TextSize = descSize,
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			ZIndex = 3,
			Parent = contentClip
		})
	end

	
	local progressContainer = self:Create("Frame", {
		Size = UDim2.new(1, -30, 0, 4),
		Position = UDim2.new(0, 15, 1, -12), 
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = contentClip
	})
	self:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressContainer })

	local progressFill = self:Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = progressContainer
	})
	self:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressFill })

	
	self:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, accentColor)
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8), 
			NumberSequenceKeypoint.new(1, 0)    
		}),
		Parent = progressFill
	})

	local function closeNotif() end 

	if #buttons > 0 then
		local btnContainer = self:Create("Frame", {
			Size = UDim2.new(1, -54, 0, 26),
			Position = UDim2.new(0, 42, 1, -44),
			BackgroundTransparency = 1,
			ZIndex = 4,
			Parent = contentClip
		})
		
		local btnLayout = self:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, 8),
			Parent = btnContainer
		})

		for _, btnData in ipairs(buttons) do
			local btnText = tostring(btnData.Title or "Button")
			local btnBounds = textService:GetTextSize(btnText, 12, Enum.Font.GothamBold, Vector2.new(999, 26))
			
			local btn = self:Create("TextButton", {
				Size = UDim2.new(0, btnBounds.X + 24, 1, 0),
				BackgroundColor3 = Color3.fromRGB(35, 35, 40),
				Text = btnText,
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				AutoButtonColor = false,
				ZIndex = 5,
				Parent = btnContainer
			})
			self:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = btn })
			self:Create("UIStroke", { Color = Color3.fromRGB(70, 70, 80), Thickness = 1, Parent = btn })

			btn.MouseEnter:Connect(function()
				tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = accentColor, TextColor3 = Color3.fromRGB(15, 15, 15)}):Play()
			end)
			btn.MouseLeave:Connect(function()
				tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end)

			btn.MouseButton1Click:Connect(function()
				if btnData.Callback then pcall(btnData.Callback) end
				if not btnData.KeepOpen then closeNotif() end
			end)
		end
	end

	
	local isClosing = false
	local connection = nil

	function closeNotif()
		if isClosing then return end
		isClosing = true

		
		if connection then
			connection:Disconnect()
			connection = nil
		end

		
		local tweenOut = tweenService:Create(mainCard, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 400, 0, 0)
		})
		tweenOut:Play()

		
		tweenOut.Completed:Connect(function()
			local shrink = tweenService:Create(holder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, 0)
			})
			shrink:Play()
			shrink.Completed:Connect(function()
				holder:Destroy()
			end)
		end)
	end

	
	local dismissBtn = self:Create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 1, 
		Parent = contentClip
	})
	dismissBtn.MouseButton1Click:Connect(closeNotif)

	
	local isHovering = false
	local timeLeft = duration

	mainCard.MouseEnter:Connect(function() isHovering = true end)
	mainCard.MouseLeave:Connect(function() isHovering = false end)


	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = config.sound
		sound.Volume = 0.6
		sound.Parent = game.Workspace
		sound:Play()
		game.Debris:AddItem(sound, 2)
	end)

	tweenService:Create(holder, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, targetHeight)
	}):Play()

	tweenService:Create(mainCard, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.1), {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()

	
	connection = runService.Heartbeat:Connect(function(dt)
		if isClosing then 
			connection:Disconnect() 
			return 
		end
		
		if not isHovering then
			timeLeft = timeLeft - dt
			local percent = math.clamp(timeLeft / duration, 0, 1)
			
		
			progressFill.Size = UDim2.new(percent, 0, 1, 0)
			
			if timeLeft <= 0 then
				closeNotif()
			end
		end
	end)
end

wait(1)
local VirtualUser=game:service'VirtualUser'
game:service('Players').LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)

return library
