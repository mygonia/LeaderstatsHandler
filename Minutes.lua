local Players = game:GetService("Players")
local LeaderstatsHandler = require(script.Parent)

local isReady = script.Parent.Ready

local STAT = "Minutes"
local STAT_TYPE = "IntValue"
local DEFAULT_VALUE = 0

local TIME_TO_INCREMENT = 1 -- Every 'x' seconds, add 1

local get, update = LeaderstatsHandler.Init(STAT, STAT_TYPE, DEFAULT_VALUE)
isReady.Event:Connect(function(player)
	local oldValue = get(player) or DEFAULT_VALUE

	while true do
		task.wait(TIME_TO_INCREMENT)
		oldValue = get(player)
		update(player, oldValue + 1)
	end
end)


