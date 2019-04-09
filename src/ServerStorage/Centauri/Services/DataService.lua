local DataService = {
    _playerData = {},
    _playerDefaultData = {},
    Client = {}
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DataStore2
local DebugPrint
local Table

local KEYS = {
	"coins",
	"inventory",
	"skills",
	"transactions",
	"equipped"
}

local DEFAULT = {
	coins = 0,
	inventory = {},
	skills = {
		Physical = 0,
		Magic = 0,
		Stamina = 0
	},
	transactions = {},
	equipped = {
		Armor = nil,
		Weapon = nil
	}
}

function DataService:GenerateDefaultDataByPlayer(player)
    if self._playerDefaultData[player] then
        return self._playerDefaultData[player]
    end

    local defaultData = Table.deep(DEFAULT)
    local defaultGuid = HttpService:GenerateGUID(false)

    defaultData.inventory = {
        {
            ItemType = "IronSword",
            Sword = {Damage = 10},
            GUID = defaultGuid
        }
    }

    defaultData.equipped = {
        Armor = nil,
        Weapon = defaultGuid
    }

    self._playerDefaultData[player] = defaultData
end

function DataService:IsDataLoaded(player)
    return self._playerData[player] ~= nil
end

function DataService:WaitForData(player, timeout)
    if timeout and type(timeout) ~= "number" then
        timeout = nil
    end

    local start = tick()

    repeat
        if not timeout and tick() - start >= 3 then
            DebugPrint:Message("DataSystem", self.Enum.SeverityType.Warn, script.Name, "Infinite data yield possible on '" .. player.Name .. "'")
            DebugPrint:Trace(debug.traceback())
        end
        
        wait()
    until self:IsDataLoaded(player) or (timeout and tick() - start >= timeout) or not Players:FindFirstChild(player.Name)
end

function DataService:GetDataByKey(player, key)
    self:GenerateDefaultDataByPlayer(player)

    if self._playerData[player] and self._playerData[player][key] and self._playerDefaultData[player] and self._playerDefaultData[player][key] then
        return self._playerData[player][key]:Get(self._playerDefaultData[player][key])
    end
end

function DataService:SetDataByKey(player, key, value)
    if self._playerData[player] and self._playerData[player][key] then
        self._playerData[player][key]:Set(value)
    end
end

function DataService.Client:GetDataByKey(player, key)
    return self:GetDataByKey(player, key)
end

function DataService:Start()
    local function playerAdded(player)
        self:GenerateDefaultDataByPlayer(player)

        local newData = {}
        for _, key in pairs(KEYS) do
            local store = DataStore2(key, player)

            if key == "inventory" then
                store:BeforeInitialGet(function(inventory)
                    local deserialized = {}
        
                    if inventory then
                        for _, item in pairs(inventory) do
                            local data = {}
                            
                            for key, value in pairs(item) do
                                if key == "ItemType" then
                                    local enumName = self.Enum.ItemType[value]
                                    data[key] = enumName
                                else
                                    data[key] = value
                                end	
                            end	
                            
                            table.insert(deserialized, data)			
                        end		
                        
                        return deserialized	
                    end
                end)

                store:BeforeSave(function(inventory)
                    local serialized = {}
                    
                    --[[
                        {
                            ItemType = itemType,
                            Sword = {Damage = number},
                            GUID = guid
                        }
                    --]]
                    
                    if inventory then
                        for _, item in pairs(inventory) do
                            local data = {}
                            
                            for key, value in pairs(item) do
                                if key == "ItemType" then
                                    local enumValue = self.Enum.ItemType[value]
                                    data[key] = enumValue
                                else
                                    data[key] = value
                                end	
                            end
                            
                            table.insert(serialized, data)
                        end
                        return serialized
                    end
                end)
            end

            newData[key] = store
        end

        self._playerData[player] = newData
    end

    Players.PlayerAdded:Connect(playerAdded)
    Players.PlayerRemoving:Connect(function(player)
        if self._playerData[player] then
            self._playerData[player] = nil
        end

        if self._playerDefaultData[player] then
            self._playerDefaultData[player] = nil
        end
    end)

    for _, player in pairs(Players:GetPlayers()) do
        spawn(function()
            playerAdded(player)
        end)
    end
end

function DataService:Init()
    DataStore2 = self.Modules.DataStore2
    Table = self.Shared.Table
    DebugPrint = self.Shared.DebugPrint

    DataStore2.Combine("MasterSave", unpack(KEYS))
end

return DataService