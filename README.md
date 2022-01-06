# LeaderstatsHandler
Automatically load and save leaderstats in Roblox

## Set-up
First, you'll need to `require` the LeaderstatsHandler module.
```lua
local LeaderstatsHandler = require("PATH-TO-MODULE")
```

Then, write down the name of the stat, the type of the stat (i.e., IntValue, StringValue), and the default value of the stat if one cannot be loaded in.
In the example below, I'd like to keep track of the number of minutes the player has played my game.
```lua
local STAT = "Minutes"
local STAT_TYPE = "IntValue"
local DEFAULT_VALUE = 0
```

Next, user the `Init()` function.
This takes three parameters; STAT, STAT_TYPE, DEFAULT_VALUE.
It returns two functions, get() and update()
```lua
local get, update = LeaderstatsHandler.Init(STAT, STAT_TYPE, DEFAULT_VALUE)
```

## Get and Update
`get()` takes one parameter, the `Player` instance. It returns the value of the stat.

`update()` takes two parameters, the `Player` instance and the new value. It does not return.
Be sure that the new value is of the proper type.

## AVOID DATA LOSS (isReady BindableEvent)
`LeaderstatsHandler.lua` assumes that the `isReady` BindableEvent is a direct child.

Optionally, use a `BindableEvent` to make sure `get()` and `update()` are only run once the datastores have loaded in.
Below is the code used to keep track of the player's playtime. It only runs when `isReady` is fired.
`isReady` fires from the LeaderstatsHandler module once the player's data is loaded in through the `PlayerAdded` event.
Without using `isReady`, it is possible that the oldValue will equal 0 and lead to data loss when `update()` is called.
```lua
isReady.Event:Connect(function(player)
	local oldValue = get(player)

	while true do
		task.wait(TIME_TO_INCREMENT)
		oldValue = get(player)
		update(player, oldValue + 1)
	end
end)
```

## Example Script
This script keeps track of how many minutes the player has played a game.
One thing to note is that `isReady` (a BindableEvent) and `Minutes.lua` are both children of `LeaderstatsHandler.lua` in this example.
```lua
local Players = game:GetService("Players")
local LeaderstatsHandler = require(script.Parent)

local isReady = script.Parent.Ready

local STAT = "Minutes"
local STAT_TYPE = "IntValue"
local DEFAULT_VALUE = 0

local TIME_TO_INCREMENT = 1 -- Every 'x' seconds, add 1

local get, update = LeaderstatsHandler.Init(STAT, STAT_TYPE, DEFAULT_VALUE)
isReady.Event:Connect(function(player)
	local oldValue = get(player)

	while true do
		task.wait(TIME_TO_INCREMENT)
		oldValue = get(player)
		update(player, oldValue + 1)
	end
end)
```
