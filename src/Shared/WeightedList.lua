--[[
	Takes a map of the form
	{
		Key1 = Weight1,
		Key2 = Weight2,
		...
	}
	And returns a function that accepts a weight from [0, 1) and returns an item such that, if the probability distribution of the weight is uniform, then the probability of it returning a given key K is WeightK / (TotalOfWeights)
]]
return function(Map) 
	local Keys = {}
	local Weights = {}
	local Total = 0
	for K, W in pairs(Map) do
		table.insert(Keys, K)
		Total = Total + W 
		table.insert(Weights, Total)
	end
	return function(P)
		if not P then
			P = math.random()
		end
		local Weight = Total * P
		for i = 1, #Keys do
			if Weights[i] > Weight then
				return Keys[i]
			end
		end
	end
end