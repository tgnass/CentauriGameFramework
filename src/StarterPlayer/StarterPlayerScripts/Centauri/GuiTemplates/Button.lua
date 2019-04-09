-- Button
-- StarWars
-- April 9, 2019

--[[
	
	local button = Button.new(guiObject)
    
    button:Open()
    button:Close()
    button:BindKeyToButton(key)
    button:UnbindKeyFromButton(key)
    button:Destroy()    

--]]


local Button = {}
Button.__index = Button


local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://2026103348"
clickSound.Name = "Click"
clickSound.Parent = script


local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")


local downButton
local overButton


local VALID_INPUT_TYPES = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.Touch] = true,
}

local ANIMATE_GUI_OBJECT_TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Sine)

-- // Helper functions
local function animateGuiObject(guiObject)
	local animationContainter = guiObject:FindFirstChild("AnimationContainer")
    if animationContainter then
        local tween = Button.Modules.Tween.fromService(animationContainter, ANIMATE_GUI_OBJECT_TWEEN_INFO, {Size = UDim2.new(0.95, 0, 0.95, 0)})
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                local nextTween = Button.Modules.Tween.fromService(animationContainter, ANIMATE_GUI_OBJECT_TWEEN_INFO, {Size = UDim2.new(1, 0, 1, 0)})
                nextTween.Completed:Connect(function(nextPlaybackState)
                    if nextPlaybackState == Enum.PlaybackState.Completed then
                        nextTween:Destroy()
                        tween:Destroy()
                    end
                end)

                nextTween:Play()
            end
        end)

        tween:Play()
	end	
end


local function hoverGuiObject(guiObject)
	local animationContainter = guiObject:FindFirstChild("AnimationContainer")
    if animationContainter then
        local tween = Button.Modules.Tween.fromService(animationContainter, ANIMATE_GUI_OBJECT_TWEEN_INFO, {Size = UDim2.new(1.1, 0, 1.1, 0)})
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                tween:Destroy()
            end 
        end)

        tween:Play()
	end
end


local function unhoverGuiObject(guiObject)
	local animationContainter = guiObject:FindFirstChild("AnimationContainer")
    if animationContainter then
        local tween = Button.Modules.Tween.fromService(animationContainter, ANIMATE_GUI_OBJECT_TWEEN_INFO, {Size = UDim2.new(1, 0, 1, 0)})
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                tween:Destroy()
            end 
        end)

        tween:Play()        
	end
end


function AnimateDown(self)
    if self.rbx:FindFirstChild("AnimationContainer") then
        local tween = Button.Modules.Tween.fromService(self.rbx.AnimationContainer, ANIMATE_GUI_OBJECT_TWEEN_INFO, {Size = UDim2.new(0.95, 0, 0.95, 0)})
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                tween:Destroy()
            end 
        end)

        tween:Play()
	end
end


function AnimateUp(self)
    if self.rbx:FindFirstChild("AnimationContainer") then
        local tween = Button.Modules.Tween.fromService(self.rbx.AnimationContainer, ANIMATE_GUI_OBJECT_TWEEN_INFO, {Size = UDim2.new(0.95, 0, 0.95, 0)})
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                if self.rbx:IsDescendantOf(game) then
                    AnimateIdle(self, 0.05)
                end

                tween:Destroy()
            end 
        end)

        tween:Play()
	end
end


function AnimateIdle(self, t)
    if self.rbx:FindFirstChild("AnimationContainer") then
        t = t or 0.2
        local tweenInfo = t == 0.1 or TweenInfo.new(t, Enum.EasingStyle.Sine)

        local tween = Button.Modules.Tween.fromService(self.rbx.AnimationContainer, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                tween:Destroy()
            end
        end)

        tween:Play()
	end
end

function AnimateOver(self)
    if self.rbx:FindFirstChild("AnimationContainer") then
        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine)

        local tween = Button.Modules.Tween.fromService(self.rbx.AnimationContainer, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
        tween.Completed:Connect(function(playbackState)
            if playbackState == Enum.PlaybackState.Completed then
                tween:Destroy()
            end
        end)

        tween:Play()
	end
end

function Release(self, commit)
	if self.IsDown then
		self.IsDown = false
		downButton = nil
	end
	
	if self.rbx:IsDescendantOf(game) then
		if not commit then
			AnimateIdle(self)
		else
			AnimateUp(self)
		end
	end
	
	self.OnButtonClicked:Fire()
end


function InvokeDown(self)
	if not self.IsDown then
		SoundService:PlayLocalSound(clickSound)
		if downButton ~= nil then
			Release(self, false)
		end
		
		downButton = self
		self.IsDown = true
		AnimateDown(self)
	end
end


function InvokeEnter(self)
	self.IsOver = true
	if overButton then
		if overButton.rbx:IsDescendantOf(game) then
			InvokeLeave(self)
		else
			overButton = nil
		end
	end
	
	overButton = self
	if downButton == nil then
		AnimateOver(self)
	end
end


function InvokeLeave(self)
	self.IsOver = false
	if overButton == self then
		overButton = nil
	end
	if downButton == nil then
		AnimateIdle(self)
	end
end


function Button.new(guiObject)
	
	local self = setmetatable({
        IsOver = false,
        IsDown = false,
        rbx = guiObject,
        OnButtonClicked = Button.Shared.Event.new(),
        OnMouseEnter = Button.Shared.Event.new(),
        OnMouseLeave = Button.Shared.Event.new(),

        _connections = {},
        _keys = {}
		
    }, Button)
    
    local captureButton = guiObject:FindFirstChildOfClass("TextButton") or guiObject:FindFirstChildOfClass("ImageButton")
    
    if captureButton then
		local downConn = captureButton.MouseButton1Down:Connect(function()
			InvokeDown(self)
		end)
		
		local enterConn = captureButton.MouseEnter:Connect(function()
			InvokeEnter(self)
			self.OnMouseEnter:Fire()
		end)
		
		local leaveConn = captureButton.MouseLeave:Connect(function()
			InvokeLeave(self)
			self.OnMouseLeave:Fire()
		end)
		
		table.insert(self._connections, downConn)
		table.insert(self._connections, enterConn)
        table.insert(self._connections, leaveConn)
    end
	
	return self
end


function Button:Open()
    self.rbx.Visible = true
end


function Button:Close()
    self.rbx.Visible = false
end


function Button:BindKeyToButton(key)
    local newName = key .. HttpService:GenerateGUID(false)
    ContextActionService:BindActionAtPriority(newName, function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            InvokeDown(self)

            return Enum.ContextActionResult.Sink
        elseif inputState == Enum.UserInputState.End then
            Release(self)
        end

        return Enum.ContextActionResult.Pass
    end, false, Enum.ContextActionPriority.High.Value, key)

    self.keys[key] = newName
end


function Button:UnbindKeyFromButton(key)
    if self._keys[key] then
        ContextActionService:UnbindAction(self._key[key])
    end
end


function Button:Destroy()
    for _, conn in pairs(self._connections) do
        if conn then
            conn:Disconnect()
        end
    end

    for _, key in pairs(self._keys) do
		self:UnbindKeyFromButton(key)
	end

    self.OnButtonClicked:Destroy()
    self.OnMouseEnter:Destroy()
    self.OnMouseLeave:Destroy()

    self._connections = {}
    self._keys = {}
end


return Button