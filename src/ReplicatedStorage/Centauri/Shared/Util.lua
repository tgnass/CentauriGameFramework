local module = {}

local INFINITE_SYMBOL = "∞"

function module:AddCommas(number)
	if number == math.huge then
		return INFINITE_SYMBOL
	end	
	
	local s = tostring(math.floor(number))
	
	for i=1, (#s-1)/3 do
		local anchor = -(3*i + (i-1))
		s = s:sub(1, anchor-1)..','..s:sub(anchor)
	end
	
	if number%1 ~= 0 then
		s = s..'.'..(number%1)
	end
	
	return s
end

function module:Round(number, factor)
	local mult = 10^(factor or 0)
	
	return math.floor((number * mult) + 0.5) / mult
end

function module:RoundNearestInterval(number, factor)
	return module:Round(number / factor) * factor
end

function module:ConvertToDisplayName(name)
	local displayName = ("_" .. name):gsub("%a", string.lower, 1)
	
	return displayName
end

function module:ReadableNumber(number, places, canAddCommas)
	local returnValue
	local placeValue = ("%%.%df"):format(places or 0)
	if number == math.huge then
		return INFINITE_SYMBOL
	end
	if not number then
		return 0
	elseif number >= 1000000000000 then
		returnValue = placeValue:format(number / 1000000000000) .. " T"
	elseif number >= 1000000000  then
		returnValue = placeValue:format(number / 1000000000) .. " B"
	elseif number >= 1000000 then
		returnValue = placeValue:format(number / 1000000) .. " M"
	elseif number >= 10000 then
		returnValue = placeValue:format(number / 1000) .. "k"
	else
		returnValue = (canAddCommas and module:AddCommas(number)) or number
	end
	
	return returnValue
end

--function module:ScaleModel(model, newSize)
--	if not (typeof(model) == 'Instance' and model:IsA("Model") and model.PrimaryPart) then return end 
--	if typeof(newSize) ~= 'Vector3' then return end 
--	print("scale")
--	local cachePositions = {}	
--	
--	local oldSize = model.PrimaryPart.Size
--	local scaleFactor = newSize / oldSize	
--	
--	for _, obj in next, model:GetDescendants() do
--		if obj:IsA("BasePart") and obj ~= model.PrimaryPart then
--			cachePositions[obj] = model.PrimaryPart.CFrame:toObjectSpace(obj.CFrame)
--		end
--	end
--	
--	model.PrimaryPart.Size = newSize
--	for part, cf in next, cachePositions do
--		part.Size = part.Size * scaleFactor
--		part.CFrame = model.PrimaryPart.CFrame:toWorldSpace(cf)
--	end	
--end

function module:ScaleModel(model, scaleFactor)
	if not (typeof(model) == 'Instance' and model:IsA("Model") and model.PrimaryPart) then return end 
	if type(scaleFactor) ~= "number" then return end
	
	local primaryPart = model.PrimaryPart
	local primaryCFrame = primaryPart.CFrame
	
	for _, obj in pairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Size = obj.Size * scaleFactor
--			if obj ~= primaryPart then
				local orientation = obj.CFrame - obj.CFrame.Position
				obj.CFrame = (primaryCFrame + (primaryCFrame:Inverse() * obj.CFrame.Position * scaleFactor)) * orientation
--			end
		end
	end
end

function module:SecondsToClock(seconds)
	local seconds = tonumber(seconds)
	
	if seconds <= 0 then
		return "00:00:00"
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600))
		local minutes = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - minutes * 60))
		
		return hours .. ":" .. minutes .. ":" .. secs
	end
end

function module:Weld(p0, p1, c0, c1)
	local weld = Instance.new("Weld")
	weld.Part0 = p0
	weld.Part1 = p1
	if c0 and c1 then
		weld.C0 = c0
		weld.C1 = c1
	else
		weld.C1 = p1.CFrame:toObjectSpace(p0.CFrame)
	end
	
	weld.Parent = p0
end

function module:UnanchorModel(model)
	for _, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Anchored = false
		end
	end
end

function module:Color3ToHex(color3)
	local r = color3.r * 255
	local g = color3.g * 255
	local b = color3.b * 255

	local rgb = {r, g, b}

	local hexaDecimal = "#"
	for _, value in pairs(rgb) do
		local hex = ""

		while value > 0 do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)

			hex = string.sub("0123456789ABCDEF", index, index) .. hex
		end

		if string.len(hex) == 0 then
			hex = "00"
		elseif string.len(hex) == 1 then
			hex = "0" .. hex
		end

		hexaDecimal = hexaDecimal .. hex
	end

	return hexaDecimal
end

function module:HexToColor3(hex)
	hex = hex:gsub("#", "")

	local r = tonumber("0X" .. hex:sub(1, 2))
	local g = tonumber("0X" .. hex:sub(3, 4))
	local b = tonumber("0X" .. hex:sub(5, 6))

	local colorValue = Color3.fromRGB(r, g, b)

	return colorValue
end


module.__centPreventWrap = true
return module