-- Makes 1 half of a mine, pls config goRight
-- Robot: CPU & Memory Tier 2, Chunkloader, Angel Upgrade, Experience Upgrade, Generator Upgrade, 4 Inv Upgrades, Inv Controller Upgrade, Hover (w/ Upgrade Container)
-- Robot needs a harddrive with home/.shrc running this script

-- 1 = empty bucket, 2 = ender tank, 3 = ore chest

local component = require("component")
local robot = component.robot
local inv = component.inventory_controller
local generator = component.generator
local length = 160
local row = 1

local goRight = false
robot.turn(true)
if robot.detect(3) then
    goRight = true
end
robot.turn(false)

function mine()
    robot.swing(3)
    forward()
end

function forward()
    if not robot.move(3) then
        repeat
            robot.swing(3)
        until robot.move(3)
    end
end

function shiftInvDown(firstSlot)
    for i = firstSlot, 16 do
        robot.select(i)
        robot.transferTo(i - 1, 64)
    end
end

function dumpInv()

    -- place ore chest
    robot.select(3)
    if not robot.place(0) then
        repeat
            robot.swing(0)
        until robot.place(0)
    end

    for i = 4, 64 do
        robot.select(i)
        robot.drop(0, 64)
    end

    -- get ore chest back (making sure we dont accidently mine something else, cause gravel exists)
    robot.select(3)
    robot.swing(0)
    while inv.getStackInInternalSlot(3).label ~= "Ender Chest" do
        robot.drop(0, 64)
        shiftInvDown(4)
    end
end

function refuel()
    if generator.count() == 0 then
        robot.select(2)
        robot.place(0)
        robot.select(1)
        inv.equip()
        robot.use(0)
        inv.equip()
        generator.insert()
        robot.select(2)
        robot.swing(0)
    end
end


while true do
    refuel()

    robot.turn(goRight)
    for i = 3, length - 1 do
        mine()
    end
    robot.swing(3)
    goRight = not goRight
    robot.turn(goRight)
    forward()
    mine()
    mine()
    robot.swing(3)
    row = row + 1

    dumpInv()
end