-- Screen Controller
-- StarWars
-- April 9, 2019

--[[
    
    ScreenController:GetPlatform()

--]]



local ScreenController = {}


local UserInputService = game:GetService("UserInputService")


-- Setup table to load modules on demand
function LazyLoadSetup(tbl, folder)
    setmetatable(tbl, {
        __index = function(t, i)
            local obj = require(folder[i])
            if type(obj) == "table" and not obj.__centPreventWrap then
                _G.Centauri:WrapModule(obj)
            end

            rawset(t, i, obj)
            return obj
        end
    })
end


function ScreenController:GetPlatform()
    if UserInputService.KeyboardEnabled and not self.Modules.Device:IsPhone() or self.Modules.Device:IsTablet() then
        return "Large"
    end

    return "Small"
end


function ScreenController:Start()
    -- Don't want to yield forever, so there's a one second wait for the gui to appear in ReplicatedStorage
    local gui = game:GetService("ReplicatedStorage"):WaitForChild("Gui", 1)
    
    if gui then
        local layoutName = self:GetPlatform()
        local layout = gui[layoutName]

        if gui.Parent == game:GetService("ReplicatedStorage") then
            gui.Parent = self.Player:WaitForChild("PlayerGui")
        end

        for _, v in pairs(gui:GetChildren()) do
            if v == layout then
                LazyLoadSetup(_G.Centauri.Screens, v)
            else
                v:Destroy()
            end
        end
    end
end


function ScreenController:Init()
    self:RegisterLock("ChatLock")
    self:RegisterLock("PlayerlistLock")
    self:RegisterLock("XboxLock")
    self:RegisterLock("PopupLock")

    self:RegisterLock("MobileControlsLock")
    self:RegisterLock("MobileHudLock")

    self:RegisterLock("TopbarLock")
    self:RegisterLock("MainHud")
    self:RegisterLock("MobileHub")

    self:ConnectLock("MobileControlsLock", function(locked)
        local touchGui = self.Player:WaitForChild("PlayerGui"):FindFirstChild("TouchGui")
        if touchGui then
            touchGui.Enabled = not locked
        end
    end)
end


return ScreenController