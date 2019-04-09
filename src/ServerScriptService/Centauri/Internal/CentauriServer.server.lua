local CentauriServer = {
    Services = {},
    Modules = {},
    Shared = {},
    Enum = {}
}

local mt = {__index = CentauriServer}

local serviceFolder = game:GetService("ServerStorage").Centauri.Services 
local modulesFolder = game:GetService("ServerStorage").Centauri.Modules
local sharedFolder = game:GetService("ReplicatedStorage").Centauri.Shared
local internalFolder = game:GetService("ReplicatedStorage").Centauri.Internal 
local enumsFolder = game:GetService("ReplicatedStorage").Centauri.Enums

local remoteServices = Instance.new("Folder")
remoteServices.Name = "CentauriRemoteServices"

local gui = game:GetService("StarterGui"):FindFirstChild("Gui")
gui.Parent = game:GetService("ReplicatedStorage")

local FastSpawn = require(internalFolder.FastSpawn)

function CentauriServer:RegisterLock(lockName)
    local lock = self.Shared.Lock.new()
    self._locks[lockName] = lock

    return lock
end

function CentauriServer:ConnectLock(lockName, func)
    return self._locks[lockName].Changed:Connect(func)
end

function CentauriServer:FireLock(lockName, name)
    self._locks[lockName]:Lock(name)
end

function CentauriServer:FireUnlock(lockName, name)
    self._locks[lockName]:Unlock(name)
end

function CentauriServer:FireUnlockAll(lockName)
    self._locks[lockName]:UnlockAll()
end

function CentauriServer:RegisterEvent(eventName)
    local event = self.Shared.Event.new()
    self._events[eventName] = event
    
    return event
end

function CentauriServer:IsLockLocked(lockName)
    return self._locks[lockName]:IsLocked()
end

function CentauriServer:RegisterClientEvent(eventName)
    local event = Instance.new("RemoteEvent")
    event.Name = eventName
    event.Parent = self._remoteFolder
    self._clientEvents[eventName] = event

    return event
end

function CentauriServer:FireEvent(eventName, ...)
    self._events[eventName]:Fire(...)
end

function CentauriServer:FireClientEvent(eventName, client, ...)
    self._clientEvents[eventName]:FireClient(client, ...)
end

function CentauriServer:FireAllClientsEvent(eventName, ...)
    self._clientEvents[eventName]:FireAllClients(...)
end

function CentauriServer:ConnectEvent(eventName, func)
    return self._events[eventName]:Connect(func)
end

function CentauriServer:ConnectClientEvent(eventName, func)
    return self._clientEvents[eventName].OnServerEvent:Connect(func)
end

function CentauriServer:WaitForEvent(eventName)
    return self._events[eventName]:Wait()
end

function CentauriServer:WaitForClientEvent(eventName)
    return self._clientEvents[eventName]:Wait()
end

function CentauriServer:RegisterClientFunction(funcName, func)
    local remoteFunc = Instance.new("RemoteFunction")
    remoteFunc.Name = funcName
    remoteFunc.OnServerInvoke = function(...)
        return func(self.Client, ...)
    end

    remoteFunc.Parent = self._remoteFolder
    return remoteFunc
end

function CentauriServer:WrapModule(tbl)
    assert(type(tbl) == "table", "Expected table for argument")
    tbl._events = {}
    tbl.locks = {}

    setmetatable(tbl, mt)
    if type(tbl.Init) == "function" and not tbl.__centPreventInit then
        tbl:Init()
    end

    if type(tbl.Start) == "function" and not tbl.__centPreventStart then
        FastSpawn(tbl.Start, tbl)
    end
end

-- Setup table to load modules on demand
function LazyLoadSetup(tbl, folder)
    setmetatable(tbl, {
        __index = function(t, i)
            local obj = require(folder[i])
            if type(obj) == "table" and not obj.__centPreventWrap then
                CentauriServer:WrapModule(obj)
            end

            rawset(t, i, obj)
            return obj
        end
    })
end

function LoadEnum(module)
    local newEnum = require(module)
    local enumValues = {}

    for i, v in pairs(newEnum) do
        enumValues[i] = v
        enumValues[v] = i
    end

    CentauriServer.Enum[module.Name] = enumValues
end

function LoadService(module)
    local remoteFolder = Instance.new("Folder")
    remoteFolder.Name = module.Name
    remoteFolder.Parent = remoteServices

    local service = require(module)
    CentauriServer.Services[module.Name] = service

    if type(service.Client) ~= "table" then
        service.Client = {}
    end

    service.Client.Server = service
    
    setmetatable(service, mt)

    service._events = {}
    service._locks = {}
    service._clientEvents = {}
    service._remoteFolder = remoteFolder
end

function InitService(service)
    if type(service.Init) == "function" then
        service:Init()
    end


    for funcName, func in pairs(service.Client) do
        if type(func) == "function" then
            service:RegisterClientFunction(funcName, func)
        end
    end
end

function StartService(service)
    if type(service.Start) == "function" then
        FastSpawn(service.Start, service)
    end
end

function Init()
    -- Load enums
    for _, module in pairs(enumsFolder:GetChildren()) do
        if module:IsA("ModuleScript") then 
            LoadEnum(module)
        end
    end

    -- Lazy load server and shared modules
    LazyLoadSetup(CentauriServer.Modules, modulesFolder)
    LazyLoadSetup(CentauriServer.Shared, sharedFolder)

    -- Load service modules
    for _, module in pairs(serviceFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            LoadService(module)
        end
    end

    -- Initialize service
    for _, service in pairs(CentauriServer.Services) do
        InitService(service)
    end

    -- Start service
    for _, service in pairs(CentauriServer.Services) do
        StartService(service)
    end

    -- Expose server framework to client and global scope
    remoteServices.Parent = game:GetService("ReplicatedStorage").Centauri
    _G.CentauriServer = CentauriServer
end

Init()