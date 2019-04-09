-- Device
-- StarWars
-- April 9, 2019

--[[
	
	Device:IsPhone()
	Device:IsTablet()
	Device:IsXbox()

--]]


local Device = {}


local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")


local function getSmallestViewportSize()
	local viewPortSize = 0
	while viewPortSize <= 1 do
		viewPortSize = math.min(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
		wait()
	end
	
	return viewPortSize
end


function Device:IsPhone()
	local touchEnabled = UserInputService.TouchEnabled
	local viewPortSize = getSmallestViewportSize()

	return touchEnabled and viewPortSize < 600
end


function Device:IsTablet()
	local touchEnabled = UserInputService.TouchEnabled
	local viewPortSize = getSmallestViewportSize()

	return touchEnabled and viewPortSize >= 600
end


function Device:IsXbox()
    return GuiService:IsTenFootInterface() and UserInputService.GamepadEnabled
end


return Device