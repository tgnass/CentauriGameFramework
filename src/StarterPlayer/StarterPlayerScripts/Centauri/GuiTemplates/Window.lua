-- Window
-- StarWars
-- April 9, 2019

--[[
	
	local window = Window.new(guiObject)
	
	Window:Open()
	Window:Close()
	Window:Toggle()
	Window:SetModal(value)
	Window:Focus()
	Window:Defocus()
	Window:IsFocusedWindow()
	Window:AnimateFocus()

--]]


local Window = {_windows = {}}
Window.__index = Window


local ContextActionService = game:GetService("ContextActionService")


local FOCUSED_ZINDEX = 3
local UNFOCUSED_ZINDEX = 2


function Window.new(guiObject)
	
	local self = setmetatable({
        rbx = guiObject,
        Closed = Window.Shared.Event.new()
    }, Window)
    

    local topbar = guiObject:FindFirstChild("Topbar")
    if topbar then
        local closeFrame = topbar:FindFirstChild("Close")
        if closeFrame then
            local button = Window.GuiTemplates.Button.new(closeFrame)
            button.OnButtonClicked:Connect(function()
                self.Closed:Fire(false)
            end)
        end
    end
    

    self.rbx.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:Focus()
        end
    end)

    table.insert(Window._windows, self)
	return self
	
end


function Window:Open()
	if self.rbx and self.rbx.Parent then
		self.rbx.Visible = true
		self:SetModal(true)
		
		ContextActionService:BindActionAtPriority("ButtonBWindow", function(actionName, inputState, input)
			if inputState == Enum.UserInputState.Begin then
				self:Close()
			end
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)
	end
end


function Window:Close()
	if self.rbx and self.rbx.Parent then
		ContextActionService:UnbindAction("ButtonBWindow")
		self.rbx.Visible = false
		self:SetModal(false)
	end
end


function Window:Toggle()
    if self.rbx and self.rbx.Parent then
        local visible = not self.rbx.Visible
        
        if visible then
            self:Open()
        else
            self:Close()
        end
	end
end


function Window:SetModal(value)
	if self.rbx:FindFirstChild("Topbar") and self.rbx.Topbar:FindFirstChildOfClass("TextButton") then
		self.rbx.Topbar:FindFirstChildOfClass("TextButton").Modal = value
	end
end


function Window:Focus()
	if not self:IsFocusedWindow() then
		if self.rbx.Parent then
			for i, v in next, self._windows do
				if v.rbx and v.rbx.Parent then
					if v.rbx == self.rbx then
						v.rbx.Parent.ZIndex = FOCUSED_ZINDEX
					else
						v.rbx.Parent.ZIndex = UNFOCUSED_ZINDEX
					end
					
					v:AnimateFocus()
				end
			end
		end
	end
end


function Window:Defocus()
	self.rbx.Parent.ZIndex = UNFOCUSED_ZINDEX
	self:AnimateFocus()
end


function Window:IsFocusedWindow()
	if self.rbx and self.rbx.Parent then
		return self.rbx.Parent.ZIndex == FOCUSED_ZINDEX
	end
	
	return false
end


function Window:AnimateFocus()
	if self.rbx:FindFirstChild("Title") then
		self.rbx.Title.TextColor3 = self:IsFocusedWindow() and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(165, 165, 165)
	end
end


return Window