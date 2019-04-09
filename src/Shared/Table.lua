local module = {}

function module.contains(tbl, value)
	for _, v in next, tbl do
		if v == value then
			return v
		end
	end
	
	return false
end

function module.len(tbl)
	local length = 0
	
	for _ in next, tbl do
		length = length + 1
	end
	
	return length
end

function module.shallow(tbl)
	local cloneTable = {}
	
	for i, v in next, tbl do
		cloneTable[i] = v
	end	
	
	return cloneTable
end

function module.deep(tbl)
	local cloneTable = {}
	
	for i, v in next, tbl do
		if type(v) == 'table' then
			cloneTable[i] = module.deep(v)
		else
			cloneTable[i] = v
		end
	end	
	
	return cloneTable
end

function module.merge(tbl, ...)
	local newTable = {}
	
	for _, t in next, {tbl, ...} do
		for _, value in next, t do
			table.insert(newTable, value)
		end
	end	
	
	return newTable
end

module.__centPreventWrap = true
return setmetatable(module, {__index = table})
