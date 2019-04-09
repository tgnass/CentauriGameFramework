-- Lock
-- StarWars
-- April 9, 2019

--[[
    local lock = Lock.new()

    lock:Lock(name)
    lock:Unlock(name)
    lock:IsLocked()
    lock:UnlockAll()
--]]

local Lock = {}
Lock.__index = Lock


function Lock.new()
    local self = setmetatable({
        Keys = {},
        Lock.Shared.Event.new()
    }, Lock)

    return self
end


function Lock:Lock(name)
    for i, v in pairs(self.Keys) do
        if v == name then
            return
        end
    end

    table.insert(self.Keys, name)
    self.Changed:Fire(true)
end


function Lock:Unlock(name)
    for i, v in pairs(self.Keys) do
        if v == name then
            table.remove(self.Keys, i)
            self.Changed:Fire(self:IsLocked())
        end
    end
end


function Lock:IsLocked()
    return #self.Keys > 0
end


function Lock:UnlockAll()
    self.Keys = {}
    self.Changed:Fire(self:IsLocked())
end


return Lock
