-- this boi mines an infinite tunnel, 200 blocks wide

-- first slot = torches
-- second slot = coal
-- second slot = ender chest
-- third slot = diamond pick

-- CONFIGS

local length = 200 -- how wide should it mine
local placeTorches = true

-- FUNCTIONS

local event = require("event")
local robot = require("robot")
local component = require("component")
local invController = component.inventory_controller
local network = component.tunnel
local generator = component.generator

local torch = math.random(8,12)
local left = false

function forward()
	while true do
		if robot.forward() then break end
		robot.swing()
	end
end

function mineForward()
	while true do
		robot.swing()
		if robot.forward() then break end
	end
  	
	if placeTorches then
		torch = torch - 1
		if torch <= 0 then
			robot.placeDown()
			torch = math.random(8,12)
		end
	end
end

function dumpInv()

	-- place an ender chest
	robot.select(3)
	if not robot.placeDown() then
		robot.swingDown()
		if not robot.placeDown() then
			network.send(robot.name(), 2)
			os.exit()
		end	
	end
	
	-- drop all items
	local numOfSlots = robot.inventorySize()
	if not placeTorches then
		robot.select(1)
		robot.dropDown()
	end
	for i = 5, numOfSlots do
		robot.select(i)
		robot.dropDown()
	end
	
end

function getItems()

	-- check coal, and consume it
	robot.select(2)
	generator.insert(64)
	if robot.count() < 32 then
		robot.select(2)
		local coalNeeded = robot.space()
		for i = 2, 27 do
			if invController.getStackInSlot(0, i) == getStackInInternalSlot(2) then
				invController.suckFromSlot(0, i, coalNeeded)
				if robot.space() == 0 then break end
			end
		end
	end

	-- check torches
	if placeTorches then
		-- grab some torches
		robot.select(1)
		local torchesRequired = robot.space()
		invController.suckFromSlot(0,1,torchesRequired)
	end
	
	-- grab ender chest back
	robot.select(4)
	invController.equip()
	robot.select(3)
	robot.swingDown(nil, true)
	robot.select(4)
	invController.equip()
	
	robot.select(1)
end

function pong()
	network.send(robot.name() .. ": Pong!")
end

-- MAIN

event.listen("modem_message", pong)

if row == 0 then -- new mine!!
	dumpInv()
	getItems()

	robot.turnLeft()
	for i = 1, length / 2 do
		mineForward()
	end
	robot.turnAround()
	dumpInv()
	getItems()
	for i = 1, length do
		mineForward()
	end
	robot.turnLeft()
	forward()
	forward()
	forward()
	robot.turnLeft()

	x = x + 1
	network.send(robot.name(), 1, x)
end

while true do

	dumpInv()
	getItems()

	for i = 1, length do
		mineForward()
	end

	if left then -- if we are now on the right side
		left = false
		robot.turnLeft()
		forward()
		forward()
		forward()
		robot.turnLeft()
	else -- if we are now on the left side
		left = true
		robot.turnRight()
		forward()
		forward()
		forward()
		robot.turnRight()
	end

	x = x + 1

	if math.floor(x/10) == x / 10 then
		network.send(robot.name() .. ": Mined out my " .. x .. "th row! <3")
	else
		network.send(robot.name() .. ": Mined row " .. x)
	end
end
