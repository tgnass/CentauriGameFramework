-- Mouse
-- StarWars
-- April 8, 2019

--[[
	
	Mouse:GetMouseRay(mousePosition)
	Mouse:SetIcon(icon)
	Mouse:FindPartFromMouseRay(mouseRay)
    Mouse:AddToTargetFilter(object)
    Mouse:RemoveFromTargetFilter(object)

--]]


local Mouse = {
    DistanceCutOff = 1000,
    Icon = "",
    Hit = CFrame.new(),
    Target = nil,
    X = 0,
    Y = 0,
    TargetFilter = {}
}

local TOPBAR_OFFSET = 36

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ValidButton2Inputs = {
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.KeyCode.ButtonL2] = true
}

local ValidButton1Inputs = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.KeyCode.ButtonR2] = true,
	[Enum.UserInputType.Touch] = true
}

function Mouse:GetMouseRay(mousePosition)
    local mouseRay = workspace.CurrentCamera:ScreenPointToRay(mousePosition.X, mousePosition.Y - TOPBAR_OFFSET, 1)

    return Ray.new(mouseRay.Origin, mouseRay.Direction * self.DistanceCutOff)
end

function Mouse:SetIcon(icon)
	if type(icon) == "string" and string.match(icon, "rbxassetid://%d+") ~= nil then
		self.Icon = icon
		self.Player:GetMouse().Icon = icon
	elseif type(icon) == "string" then
		local success = pcall(function()
			self.Player:GetMouse().Icon = icon
		end)
		
		if success then
			self.Icon = icon
		end
	elseif type(icon) == "number" then
		self.Icon = "rbxassetid://" .. icon
		self.Player:GetMouse().Icon = self.Icon
	elseif type(icon) == nil or (type(icon) == "string" and icon == "") then
		self.Icon = ""
		self.Player:GetMouse().Icon = ""
	end
end

function Mouse:FindPartFromMouseRay(mouseRay)
    local filter = {}
    for obj in pairs(self.TargetFilter) do
        table.insert(filter, obj)
    end

    for _, player in pairs(Players:GetPlayers()) do 
        if player.Character then 
            table.insert(filter, player.Character)
        end
    end 

    table.insert(filter, workspace.CurrentCamera)
    table.insert(filter, workspace:FindFirstChild("Ignore"))

    local hit, endpoint = workspace:FindPartOnRayWithIgnoreList(mouseRay, filter)

    self.Hit = CFrame.new(endpoint)
    self.Target = hit 
end

function Mouse:AddToTargetFilter(object)
    if typeof(object) == "Instance" then
        self.TargetFilter[object] = true
    elseif typeof(object) == "table" then
        for _, v in pairs(object) do
            if typeof(object) == "Instance" then
                self.TargetFilter[v] = true
            end
        end
    end
end

function Mouse:RemoveFromTargetFilter(object)
    if typeof(object) == "Instance" then
        if object then
            self.TargetFilter[object] = nil
        end
    elseif typeof(object) == "table" then
        for _, obj in pairs(object) do 
            if obj then
                self.TargetFilter[obj] = nil
            end
        end
    end
end

function Mouse:Start()
    RunService:BindToRenderStep("MouseUpdate", Enum.RenderPriority.Input.Value, function(step)
        if not self._moveTouchObject then 
            local mousePosition = UserInputService:GetMouseLocation()

            self.X = mousePosition.X
            self.Y = mousePosition.Y - TOPBAR_OFFSET
        end 

        for obj in pairs(self.TargetFilter) do 
            if obj and obj.Parent == nil then 
                self.TargetFilter[obj] = nil 
            end
        end

        self:FindPartFromMouseRay(self:GetMouseRay(Vector2.new(self.X, self.Y + TOPBAR_OFFSET)))
        if self.Target and self.Target.Parent == nil then
            self.Target = nil 
        end 
    end)

    UserInputService.InputChanged:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            self:FireEvent("Move")
        end
    end)

    UserInputService.InputBegan:Connect(function(inputObject, proccessed)
        if not proccessed then
            if ValidButton1Inputs[inputObject.UserInputType] or ValidButton1Inputs[inputObject.KeyCode] then
                if inputObject.UserInputType == Enum.UserInputType.Touch then 
                    if self._moveTouchObject or inputObject.UserInputState ~= Enum.UserInputState.Begin then
                        return 
                    end 
                    
                    self._moveTouchObject = inputObject
                end
                
                self:FireEvent("Button1Down")
            elseif ValidButton2Inputs[inputObject.UserInputType] or ValidButton2Inputs[inputObject.KeyCode] then
                self:FireEvent("Button2Down")
            end 
        end 
    end)

    UserInputService.TouchMoved:Connect(function(input, isProcessed)
        if input == self._moveTouchObject and not isProcessed then
            self:FireEvent("Move")
        end 
    end)

    UserInputService.TouchEnded:Connect(function(input)
        if self._moveTouchObject == input then 
            self._moveTouchObject = nil 
        end
    end)

    UserInputService.InputEnded:Connect(function(inputObject, processed)
        if not processed then
            if ValidButton1Inputs[inputObject.UserInputType] or ValidButton1Inputs[inputObject.KeyCode] then
                self:FireEvent("Button1Up")
            elseif ValidButton2Inputs[inputObject.UserInputType] or ValidButton2Inputs[inputObject.KeyCode] then 
                self:FireEvent("Button2Up") 
            end
        end 
    end)
end

function Mouse:Init()
    self:RegisterEvent("Move")
    self:RegisterEvent("Button1Down")
    self:RegisterEvent("Button1Up")
    self:RegisterEvent("Button2Down")
    self:RegisterEvent("Button2Up")
end

return Mouse