-- Makes 1 half of a mine, place a block next to it in the direction you want it to go
-- Chunkloader, Angel Upgrade, Experience Upgrade, Generator Upgrade, 4 Inv Upgrades, Inv Controller Upgrade, Hover (w/ Upgrade Container)

-- This'll be the first thing we make in a server, so here's the specs
-- The mine should be Y=11 (head level) so the lava pools are on the floor

-- Speedrun Resources required:
    -- Computer:
        -- Computer Case T3
        -- CPU T1
        -- Memory T1.5 (T1 wasn't enough)
        -- Graphics Card T1
        -- Hard Disk Drive T1
        -- OpenOS Disk
        -- EEPROM (flash this on it)
        -- Screen T1
        -- Keyboard
    -- Electronics Assembler:
        -- 2.5m RF for assembly (500 RF/t takes 4 mins)
    -- Robot:
        -- Computer Case T3 (owned)
        -- CPU T1 (owned)
        -- Memory T1.5 (owned, T1 works too)
        -- EEPROM (owned)
        -- Chunkloader Upgrade
        -- Inventory Controller Upgrade
        -- Generator Upgrade
        -- Angel Upgrade
        -- Experience Upgrade
        -- 4 Inventory Upgrades
        -- Upgrade Container
        -- Hover Upgrade (in upgrade container)
        -- 2.5m RF for assembly (500 RF/t takes 4 mins)
    -- Mining:
            -- Steel Hammer
            -- Fortune/Luck III: 6 stacks of lapis
            -- Mending: Mending Moss (9 Mossy Cobblestone)
        -- 64 Coal
        -- 2x Ender Chest (Ore)
        -- 64 Torches
        -- 2x Ender Chest (Torch)
            -- Torch chest needs to be filled reliably, consider using Stone Torches
    -- Ore Chest
        -- Needs to be emptied reliably, consider using servos, item ducts, chests, & storage drawers
        -- SET IT UP ON THE SURFACE AT BASE, NEXT TO THE ME SYSTEM, OR ELSE ALL UR ITEMS ARE DOWN IN THE MINE AND ITS ANNOYING
        -- 1) Start with chests, item ducts, servos
        -- 2) Start using barrels for cobble, andestite, diorite, granite. Manually move em
        -- 3) Use storage drawers for ores & gems. Manually move em

        

-- 1 = coal, 2 = ore chest [, 3 = torches, 4 = torch chest] 
-- OR (netherMode == true)
-- 1 = fuel chest, 2 = ore chest, 3 = torches (optional), 4 = torch chest (optional)

-- REQUIRES
local robot = component.proxy(component.list("robot")())
local inv = component.proxy(component.list("inventory_controller")())
local generator = component.proxy(component.list("generator")())

-- VARIABLES:
local goRight = true
robot.turn(true)
if not robot.detect(3) then
    goRight = false
end
robot.turn(false)
local length = 150
local netherMode = false -- if true, the first slot will be a 'fuel' chest
local isPlaceTorches = (inv.getStackInInternalSlot(3).label == "Torch" or inv.getStackInInternalSlot(3).label == "Stone Torch")
local torchCount = isPlaceTorches and 1 or math.huge
local row = 1


function placeTorch()
    torchCount = torchCount - 1
    if torchCount == 0 and robot.count(3) > 1 then
        torchCount = 10 -- optimal number to prevent mob spawning
        robot.select(3)
        if not robot.place(0) then
            robot.swing(0)
            robot.place(0)
        end
        robot.select(1)
    end
end

function mine()
    robot.swing(3)
    forward()
    placeTorch()
end

function forward()
    if not robot.move(3) then
        repeat
            robot.swing(3)
        until robot.move(3)
    end
end

function shiftInvDown(firstSlot)
    for i = firstSlot, 63 do -- last slot is reserved
        robot.select(i)
        robot.transferTo(i - 1, 64)
    end
end

function dumpInv()

    -- place ore chest
    robot.select(2)
    if not robot.place(0) then
        repeat
            robot.swing(0)
        until robot.place(0)
    end

    -- drop all items
    local startSlot = isPlaceTorches and 5 or 3
    for i = startSlot, 64 do
        robot.select(i)
        robot.drop(0, 64)
    end

    -- get ore chest back (making sure we dont accidently mine something else, cause gravel exists)
    robot.select(2)
    robot.swing(0)
    while inv.getStackInInternalSlot(2).label ~= "Ender Chest" do
        robot.drop(0, 64)
        if isPlaceTorches then
            robot.select(5)
            robot.transferTo(2)
            shiftInvDown(6)
        else
            robot.select(3)
            robot.transferTo(2)
            shiftInvDown(4)
        end
    end

    -- check if we need torches
    if isPlaceTorches and robot.count(3) < 64 then

        -- place torch chest
        robot.select(4)
        robot.place(0)

        -- grab torches
        robot.select(3)
        local itemsRequired = robot.space()
        robot.suck(0, itemsRequired)

        -- get torch chest back
        robot.select(4)
        robot.swing(0)
        while inv.getStackInInternalSlot(4).label ~= "Ender Chest" do
            robot.drop(0, 64)
            if isPlaceTorches then
                robot.select(5)
                robot.transferTo(4)
                shiftInvDown(6)
            end
        end
    end
end


while true do
    robot.turn(goRight)

    -- refuel
    robot.select(1)
    local coalCount = robot.count()
    if coalCount > 1 then
        generator.insert(coalCount - 1)
    end

    --torchCount = 10
    for i = 3, length - 1 do
        mine()
    end
    robot.swing(3)

    goRight = not goRight

    dumpInv()
    robot.select(1)

    robot.turn(goRight)
    forward()
    mine()
    mine()
    robot.swing(3)

    row = row + 1
end