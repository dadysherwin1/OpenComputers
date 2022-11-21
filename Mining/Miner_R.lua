-- Makes 1 half of a mine, pls config rightHalf
-- Robot: CPU & Memory Tier 2, Chunkloader, Angel Upgrade, Experience Upgrade, Generator Upgrade, 4 Inv Upgrades, Inv Controller Upgrade, Database (w/ Upgrade Container), Hover (w/ Upgrade Container)
-- Robot needs a harddrive with home/.shrc running this script
-- 1 = coal, 2 = ore chest, 3 = torches, 4 = torch chest

-- CONFIGS:
local rightHalf = false
local homeSide = true
local length = 160
local startRow = 1

local component = require("component")
local robot = component.robot
local database = component.database
local inv = component.inventory_controller
local generator = component.generator

local torchCount = 1
local row = 0

function mine()
    robot.swing(3)
    forward()
    torchCount = torchCount - 1
    if torchCount == 0 and inv.getStackInInternalSlot(3) and inv.getStackInInternalSlot(3).label == database.get(3).label then
        torchCount = 10
        robot.select(3)
        if not robot.place(0) then
            robot.swing(0)
            robot.place(0)
        end
        robot.select(1)
    end
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
    if inv.getStackInInternalSlot(3) and inv.getStackInInternalSlot(3).label ~= database.get(3).label then
        -- torches are optional in our robot :)
        robot.select(3)
        robot.drop(0, 64)
    end
    if inv.getStackInInternalSlot(4) and inv.getStackInInternalSlot(4).label ~= database.get(4).label then
        -- torch chest is optional in our robot :)
        robot.select(4)
        robot.drop(0, 64)
    end
    for i = 5, 64 do
        robot.select(i)
        robot.drop(0, 64)
    end

    -- get ore chest back (making sure we dont accidently mine something else)
    robot.select(2)
    robot.swing(0)
    while database.get(2).label ~= inv.getStackInInternalSlot(2).label do
        robot.drop(0, 64)
        if inv.getStackInInternalSlot(3) and inv.getStackInInternalSlot(3).label ~= database.get(3).label then
            robot.select(3)
            robot.transferTo(2)
            shiftInvDown(4)
        else
            robot.select(5)
            robot.transferTo(2)
            shiftInvDown(6)
        end
    end

    if inv.getStackInInternalSlot(3) and inv.getStackInInternalSlot(3).label ~= database.get(3).label then
        -- torches are optional in our robot :)
        robot.select(3)
        robot.drop(0, 64)
    end
    if inv.getStackInInternalSlot(4) and inv.getStackInInternalSlot(4).label ~= database.get(4).label then
        -- torch chest is optional in our robot :)
        robot.select(4)
        robot.drop(0, 64)
    end

    -- check if we need torches
    if robot.count(3) < 64 then

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
    end
end

while true do

    if startRow > 1 then
        for i = 1, startRow - 1 do
            forward()
            forward()
            forward()
        end
    end

    robot.swing(3)
    robot.turn(rightHalf)
    row = startRow

    while true do

        -- refuel
        robot.select(1)
        local coalCount = robot.count()
        if coalCount > 1 then
            generator.insert(coalCount - 1)
        end

        torchCount = 10
        for i = 1, length - 3 do
            mine()
        end
        robot.swing(3)

        if homeSide then
            homeSide = false
        else
            homeSide = true
        end

        dumpInv()
        robot.select(1)

        -- turn
        if homeSide then
            if rightHalf then
                robot.turn(true)
            else
                robot.turn(false)
            end
        else
            if rightHalf then
                robot.turn(false)
            else
                robot.turn(true)
            end
        end

        -- forward
        forward()
        mine()
        mine()
        robot.swing(3)

        -- turn
        if homeSide then
            if rightHalf then
                robot.turn(true)
            else
                robot.turn(false)
            end
        else
            if rightHalf then
                robot.turn(false)
            else
                robot.turn(true)
            end
        end

        row = row + 1

    end

    -- return to base
    if rightHalf then
        robot.turn(false)
    else
        robot.turn(true)
    end

    for i = 1, row - 1 do
        forward()
        forward()
        forward()
    end

    if rightHalf then
        robot.turn(false)
        robot.turn(false)
    else
        robot.turn(true)
        robot.turn(true)
    end
    row = 0
end
