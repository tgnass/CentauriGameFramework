local module = {}

local MAX_LENGTH = 5000

local function rayCast(start, direction, length)
	length = (type(length) == 'number' and math.min(length, MAX_LENGTH)) or MAX_LENGTH
	local newRay = Ray.new(start, direction * length)
	
	return newRay
end

function module:FindPartOnRayWithIgnoreList(start, direction, length, ignoreList)
	ignoreList = ignoreList or {}
	if workspace:FindFirstChild("Ignore") then
		table.insert(ignoreList, workspace.Ignore)
	end
	local newRay = rayCast(start, direction, length)
	
	return workspace:FindPartOnRayWithIgnoreList(newRay, ignoreList)
end

function module:FindPartOnRayWithWhiteList(start, direction, length, whiteList)
	whiteList = whiteList or {}
	local newRay = rayCast(start, direction, length)
	
	return workspace:FindPartOnRayWithWhitelist(newRay, whiteList)
end

return module
