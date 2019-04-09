local Event = {}
Event.__index = Event

function Event.new()
	local newEvent = setmetatable({}, Event)
	
	newEvent.Connections = {}
	newEvent.Destroyed = false
	newEvent.Bindable = Instance.new("BindableEvent")
	
	return newEvent
end

function Event:Connect(func)	
	assert(not self.Destroyed, "Cannon connect to destroyed event!")
	assert(type(func) == "function", "Arguments must be a function!")
		
	return self.Bindable.Event:Connect(function()
		func(unpack(self.Args, 1, self.NumOfArgs))
	end)		
end

function Event:Wait()
	self.Bindable.Event:Wait()
	
	return unpack(self.Args, 1, self.NumOfArgs)
end

function Event:Fire(...)
	self.Args = { ... }
	self.NumOfArgs = select("#", ...)
	self.Bindable:Fire()
end

function Event:DisconnectAll()
	self.Bindable:Destroy()
	self.Bindable = Instance.new("BindableEvent")
end

function Event:Destroy()
	if self.Destroyed then return end
	
	self.Destroyed = true
	self.Bindable:Destroy()
end

return Event