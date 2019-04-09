local Centauri = {
    Controllers = {},
    Modules = {},
    Shared = {},
    Services = {},
    Enum = {},
    Player = game:GetService("Players").LocalPlayer
}

local mt = {__index = Centauri}

local controllersFolder = script.Parent.Parent:WaitForChild("Controllers")
local modulesFolder = script.Parent.Parent:WaitForChild("Modules")
local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Centauri"):WaitForChild("Shared")
local internalFolder = game:GetService("ReplicatedStorage").Centauri:WaitForChild("Internal")
local enumsFolder = game:GetService("ReplicatedStorage").Centauri:WaitForChild("Enums")

local FastSpawn = require(internalFolder:WaitForChild("FastSpawn"))

function Centauri:RegisterEvent(eventName)
    local event = self.Shared.Event.new()
    self._events[eventName] = event

    return event 
end

function Centauri:FireEvent(eventName, ...)
    self._events[eventName]:Fire(...)
end

function Centauri:ConnectEvent(eventName, func)
    return self._events[eventName]:Connect(func)
end

function Centauri:WaitForEvent(eventName)
    return self._events[eventName]:Wait()
end

function Centauri:WrapModule(tbl)
    assert(type(tbl) == "table", "Expected table for argument")
    tbl._events = {}
    setmetatable(tbl, mt)

    if type(tbl.Init) == "function" and not tbl.__centPreventInit then
        tbl:Init()
    end

    if type(tbl.Start) == "function" and not tbl.__centPreventStart then
        FastSpawn(tbl.Start, tbl)
    end
end

function LoadService(serviceFolder)
    local service = {}

    Centauri.Services[serviceFolder.Name] = service
    for _, v in pairs(serviceFolder:GetChildren()) do
        if v:IsA("RemoteEvent") then
            local event = Centauri.Shared.Event.new()
            local fireEvent = event.Fire

            function event:Fire(...)
                v:FireServer(...)
            end
            
            v.OnClientEvent:Connect(function(...)
                fireEvent(event, ...)
            end)

            service[v.Name] = event 
        elseif v:IsA("RemoteFunction") then
            service[v.Name] = function(self, ...)
                return v:InvokeServer(...)
            end
        end
    end
end

function LoadServices()
    local remoteServices = game:GetService("ReplicatedStorage"):WaitForChild("Centauri"):WaitForChild("CentauriRemoteServices")
    for _, serviceFolder in pairs(remoteServices:GetChildren()) do
        if serviceFolder:IsA("Folder") then
            LoadService(serviceFolder)
        end
    end
end

function LoadEnum(module)
    local newEnum = require(module)
    local enumValues = {}

    for i, v in pairs(newEnum) do
        enumValues[i] = v
        enumValues[v] = i
    end

    Centauri.Enum[module.Name] = enumValues
end

-- Setup table to load modules on demand
function LazyLoadSetup(tbl, folder)
    setmetatable(tbl, {
        __index = function(t, i)
            local obj = require(folder[i])
            if type(obj) == "table" then
                Centauri:WrapModule(obj)
            end

            rawset(t, i, obj)
            return obj
        end
    })
end

function LoadController(module)
    local controller = require(module)
    Centauri.Controllers[module.Name] = controller
    controller._events = {}
    setmetatable(controller, mt)
end

function InitController(controller)
    if type(controller.Init) == "function" then
        controller:Init()
    end
end

function StartController(controller)
    if type(controller.Start) == "function" then
        FastSpawn(controller.Start, controller)
    end
end

function Init()
    -- Load enums
    for _, module in pairs(enumsFolder:GetChildren()) do
        if module:IsA("ModuleScript") then 
            LoadEnum(module)
        end
    end

    LazyLoadSetup(Centauri.Modules, modulesFolder)
    LazyLoadSetup(Centauri.Shared, sharedFolder)

    LoadServices()

    for _, module in pairs(controllersFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            LoadController(module)
        end
    end

    for _, controller in pairs(Centauri.Controllers) do
        InitController(controller)
    end

    for _, controller in pairs(Centauri.Controllers) do
        StartController(controller)
    end

    _G.Centauri = Centauri
end

Init()