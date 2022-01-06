local LeaderstatsHandler = {}

LeaderstatsHandler.Players = {
	--[[
	[UserId] = {
		leaderstatsFolder,
		stats = {
			stat1 = {valueType1, value1},
			stat2 = {valueType2, value2}
		}
	}
	]]
}
local isReady = script.Ready
if not isReady then
	warn("Could not find the isReady BindableEvent. By default, this should be a direct child of the LeaderstatsHandler")
end
local Players = game:GetService("Players")
local VERSION_NUMBER = 1
local DataStoreService = game:GetService("DataStoreService")
local leaderstatsStore = DataStoreService:GetDataStore("leaderstats_" .. tostring(VERSION_NUMBER))

function LeaderstatsHandler:createLeaderstatsFolder(player)
	local userId = player.UserId
	local playerTable = self.Players[userId]
	if not playerTable then
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		
		self.Players[userId] = {
			leaderstats,
			stats = {
				
			}
		}
		return playerTable
	end
	return playerTable
end

function LeaderstatsHandler:removeLeaderstatsFolder(player)
	local userId = player.UserId
	self.Players[userId] = nil
end

function LeaderstatsHandler:getLeaderstats(player)
	local userId = player.UserId
	local playerLeaderstatsFolder = self.Players[userId]

	return playerLeaderstatsFolder
end

function LeaderstatsHandler:getValue(player, valueName, defaultType, defaultValue)
	local leaderstats = LeaderstatsHandler:getLeaderstats(player)
	if not leaderstats then
		repeat
			wait()
			leaderstats = LeaderstatsHandler:getLeaderstats(player)
		until leaderstats
	end
	
	local stats = leaderstats.stats
	
	if stats[valueName] == nil then
		stats[valueName] = {defaultType, defaultValue}
		LeaderstatsHandler:updateLeaderstats(player, valueName, defaultType, defaultValue)
	end
	
	local value = stats[valueName][2]
	return value
end

function LeaderstatsHandler:updateLeaderstats(player, valueName, valueType, newValue)
	local leaderstats = LeaderstatsHandler:getLeaderstats(player)
	if not leaderstats then
		repeat
			wait()
			leaderstats = LeaderstatsHandler:getLeaderstats(player)
		until leaderstats
	end
	
	local stats = leaderstats.stats
	local stat = stats[valueName]
	if not stat then
		stats[valueName] = newValue
	end
	stat = newValue	
	
	local userId = player.UserId
	local statsTable = self.Players[userId].stats
	statsTable[valueName] = {valueType, newValue}
	
	local leaderstatsFolder = leaderstats[1]
	if not leaderstatsFolder:FindFirstChild(valueName) then
		local value = Instance.new(valueType)
		value.Name = valueName
		value.Value = newValue
		value.Parent = leaderstatsFolder
	else
		local value = leaderstatsFolder[valueName]
		value.Value = newValue
	end
end

function LeaderstatsHandler.Init(STAT, STAT_TYPE, DEFAULT_VALUE)
	local function get(player)
		local value = LeaderstatsHandler:getValue(player, STAT, STAT_TYPE, DEFAULT_VALUE)
		return value or DEFAULT_VALUE
	end
	
	local function update(player, newValue)
		LeaderstatsHandler:updateLeaderstats(player, STAT, STAT_TYPE, newValue)
	end
	return get, update
end

game.Players.PlayerAdded:Connect(function(player)
	LeaderstatsHandler:createLeaderstatsFolder(player)
	local success, stats, keyInfo = pcall(function()
		return leaderstatsStore:GetAsync(player.UserId)
	end)
	
	if success then
		for stat, value in pairs(stats) do
			local valueType = value[1]
			local newValue = value[2]
			LeaderstatsHandler:updateLeaderstats(player, stat, valueType, newValue)
		end
	else
		warn("Data could not be loaded for player!")
	end
	
	isReady:Fire(player)
end)

game.Players.PlayerRemoving:Connect(function(player)
	warn("Player removing!")
	local userId = player.UserId
	local data = LeaderstatsHandler:getLeaderstats(player).stats

	local success, err = pcall(function()
		leaderstatsStore:SetAsync(userId, data)
	end)

	if not success then
		local attempts = 0
		warn(err)
		print("Failure :(", data)

		while(not success or attempts < 3)do
			wait(3)
			success, err = pcall(function()
				leaderstatsStore:SetAsync(userId, data)
			end)
			attempts = attempts + 1
		end
	else
		print("Success!", data)
	end
	
	LeaderstatsHandler:removeLeaderstatsFolder(player)
end)

return LeaderstatsHandler
