-- this boi mines an infinite tunnel, 200 blocks wide

-- first slot = torches
-- second slot = coal
-- third slot = ender chest

-- CONFIGS

local length = 200 -- how wide should it mine
local x = 0 -- the starting row. only change if the mine has already been started
local left = false -- the starting side. only change if the mine has already been started
local placeTorches = true

-- FUNCTIONS

local event = require("event")
local robot = require("robot")
local component = require("component")
local invController = component.inventory_controller
local network = component.tunnel
local generator = component.generator

local torch = math.random(8,12)

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
			network.send(robot.name() .. ": Turning off. Couldn't place down ender chest ;(")
			os.exit()
		end	
	end
	
	-- drop all items
	local numOfSlots = robot.inventorySize()
	if not placeTorches then
		robot.select(1)
		robot.dropDown()
	end
	for i = 3, numOfSlots do
		robot.select(i)
		robot.dropDown()
	end
	
end

function getItems()

	-- check coal, and consume it
	robot.select(2)
	if robot.count() < 64 then
		local numOfCoal = robot.count()
		if not generator.insert(numOfCoal - 1) then
			network.send(robot.name() .. ": Turning off. There is a non-coal in my coal slot ;(")
			os.exit()
		end
	end

	-- check torches
	if placeTorches then

		-- grab some torches
		robot.select(1)
		local torchesRequired = robot.space()
		invController.suckFromSlot(0,1,torchesRequired)
		if robot.count() < 30 then
			network.send(robot.name() .. ": Turning off. Not enough torches ;(")
			os.exit()
		end
		
	end
	
	-- grab ender chest back
	robot.swingDown(nil, true)
end

function pong()
	network.send(robot.name() .. ": Pong!")
end

-- MAIN

event.listen("modem_message", pong)

if x == 0 then -- new mine!!
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
	network.send(robot.name() .. ": Mined out my 1st row! <3")
end

while true do

	dumpInv()
	getItems()

	for i = 1, length do
		mineForward()
	end

	if left then
		left = false
		robot.turnLeft()
		forward()
		forward()
		forward()
		robot.turnLeft()
	else
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
