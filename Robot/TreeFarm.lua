local robot = component.proxy(component.list("robot")())

-- Select the first slot, which is supposed to have a sapling.
robot.select(1)

-- Change these to change the tree farm grid size or the distance between each tree in the grid.
local treesX = 6
local treesZ = 6
local distanceBetweenTrees = 5

local function Move(direction)
	if not robot.move(direction) then
        repeat
            robot.swing(direction)
        until robot.move(direction)
    end
end

function DumpInv()
    -- drop all items
    local startSlot = 2
    for i = startSlot, robot.inventorySize() do
        robot.select(i)
        robot.drop(0, 64)
    end
	robot.select(1)
end

-- Checks for a tree
local function CheckForTree()
	-- Check for a block
	if robot.detect(3) then
		Move(1)
		
		-- Attempt to detect a block above which will determine if the tree has grown.
		local blockFound = robot.detect(3)
		Move(0)
		
		-- Check tree has grown and if so then go up.
		if blockFound then
			for blocksToMoveUp = 1, 8 do
				-- Destroy the wood in front of the robot
				robot.swing(3)
				
				Move(1)
			end
			
			-- Move back down again
			for blocksToMoveDown = 1, 8 do
				Move(0)
			end
			
			-- Suck up stuff
            Move(3)
			for rotation = 1, 4 do
				robot.turn(true)
				robot.suck(3)
			end
			
			-- Go back
			robot.turn(true)
            robot.turn(true)
			Move(3)
			robot.turn(true)
            robot.turn(true)
			
			-- Place the new sapling here
			robot.place(3)
		end
	else
		-- There is no block here, place the sapling
		robot.place(3)
	end
end

-- Scans a row of trees.
local function CheckRowOfTrees()
	-- Check for trees in the X row.
	for treeX = 1, treesX do
		CheckForTree()
		
		-- If this isn't the last tree in the row then move to the next tree in the row.
		if treeX < treesX then
			robot.turn(true)
			for blocksToMove = 1, distanceBetweenTrees do
				Move(3)
				robot.suck(3)
			end
			robot.turn(false)
		end
	end
	
	-- Go back to the first tree in the row.
	robot.turn(false)
	for blocksToMove = 1, distanceBetweenTrees*(treesX - 1) do
		Move(3)
	end
	robot.turn(true)
end

-- Do the complete cycle.
while true do
	-- Go to each X row in the grid.
	for treeZ = 1, treesZ do
		CheckRowOfTrees()
		
		-- If this isn't the last X row in the grid then go to the next X row in the grid.
		if treeZ < treesZ then
			robot.turn(true)
			Move(3)
			robot.turn(false)
			for blocksToMove = 1, distanceBetweenTrees do
				Move(3)
				robot.suck(3)
			end
			robot.turn(false)
			Move(3)
			robot.turn(true)
		end
	end
	
	-- Go back to the starting position.
	robot.turn(true)
	Move(3)
	robot.turn(true)
	for blocksToMove = 1, distanceBetweenTrees*(treesZ - 1) do
		Move(3)
		robot.suck(3)
	end
	robot.turn(true)
	Move(3)
	robot.turn(true)

    DumpInv()
end