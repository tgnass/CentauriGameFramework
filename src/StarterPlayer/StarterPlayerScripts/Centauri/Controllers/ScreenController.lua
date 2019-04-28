-- Screen Controller
-- StarWars
-- April 9, 2019

--[[
    
    ScreenController:GetPlatform()
    ScreenController:IsLoaded()

--]]



local ScreenController = {}


local UserInputService = game:GetService("UserInputService")


local isLoaded = false


function ScreenController:GetPlatform()
    if UserInputService.KeyboardEnabled and not self.Modules.Device:IsPhone() or self.Modules.Device:IsTablet() then
        return "Large"
    end

    return "Small"
end


function ScreenController:IsLoaded()
    return isLoaded
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
				for _, obj in pairs(v:GetChildren()) do
					if obj:IsA("Folder") then
						local moduleObj = obj:FindFirstChildOfClass("ModuleScript")
						if moduleObj then
							local module = require(moduleObj)
							if type(module) == "table" and not module.__centPreventWrap then
								_G.Centauri:WrapModule(module)
							end
							
							_G.Centauri.Screens[moduleObj.Name] = module 
						end
					end
				end
            else
                v:Destroy()
            end
        end
    end

    isLoaded = true
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