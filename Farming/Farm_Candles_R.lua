local robot = component.proxy(component.list("robot")())
local geolyzer = component.proxy(component.list("geolyzer")())
local crafting = component.proxy(component.list("crafting")())

local seedSlot = 8
local firstHalf = true

function emptyTopLeft()
    for i = 1, 3 do
        robot.select(i)
        robot.drop(3)
    end
    for i = 5, 7 do
        robot.select(i)
        robot.drop(3)
    end
    for i = 9, 11 do
        robot.select(i)
        robot.drop(3)
    end
end

function dumpInv()

    -- drop excess beetroot seeds
    robot.select(12)
    local seedCount = robot.count()
    if seedCount > 32 then
        robot.drop(3, seedCount - 32)
    end

    -- craft dye & drop excess
    robot.select(15)
    local dyeRequired = robot.space()
    crafting.craft(dyeRequired)
    robot.select(1)
    robot.drop(3)

    -- craft wax
    robot.select(4)
    local berryCount = robot.count() - 32
    if berryCount > 0 then

        -- make room
        robot.select(13)
        local waxSpace = robot.space()
        if waxSpace < berryCount then
            robot.drop(3, berryCount - waxSpace)
        end

        robot.select(4)
        robot.transferTo(2, berryCount)
        robot.select(16)
        robot.transferTo(1)
        robot.select(13)

        crafting.craft()

        robot.select(1)
        robot.transferTo(16)
    end

    -- craft string
    robot.select(8)
    local cottonCount = robot.count()
    if cottonCount >= 35 then
        local stringCraftable = math.floor((cottonCount - 32) / 3)

        -- make room
        robot.select(14)
        local stringSpace = robot.space()
        if stringSpace < stringCraftable * 2 then
            robot.drop(3, stringCraftable * 2 - stringSpace)
        end

        robot.select(8)
        robot.transferTo(1, stringCraftable)
        robot.transferTo(2, stringCraftable)
        robot.transferTo(5, stringCraftable)
        robot.select(14)
        crafting.craft()
    end

    -- craft candles
    robot.select(13)
    local wax = robot.count() - 32
    robot.select(14)
    local string = robot.count() - 32
    robot.select(15)
    local dye = robot.count() - 32
    local candlesCraftable = math.min(wax, string, dye, 16)
    if candlesCraftable > 0 then
        robot.select(13)
        robot.transferTo(1, wax + 32)
        robot.select(14)
        robot.transferTo(2, string + 32)
        crafting.craft(candlesCraftable * 4)

        robot.select(15)
        robot.transferTo(6, dye + 32)
        robot.select(14)
        robot.transferTo(15)
        robot.select(1)
        robot.transferTo(13)
        robot.select(2)
        robot.transferTo(14)

        robot.select(15)
        robot.transferTo(1, candlesCraftable)
        robot.transferTo(2, candlesCraftable)
        robot.transferTo(3, candlesCraftable)
        robot.transferTo(5, candlesCraftable)
        crafting.craft()

        robot.drop(3)
        robot.select(6)
        robot.transferTo(15)
    end

end

function forward()
    repeat
    until robot.move(3)
end

function farmTile()
    if geolyzer.analyze(0)["growth"] == 1 then -- check if its fully grown
        robot.swing(0)
        robot.suck(0)
        robot.place(0)
    end
end

function farmRow()
    robot.select(seedSlot)
    farmTile()
    for i = 1, 7 do
        forward()
        farmTile()
    end
end

while true do
    robot.turn(not firstHalf)
    forward()
    forward()
    forward()
    forward()
    forward()
    robot.turn(firstHalf)

    farmRow()

    robot.turn(firstHalf)
    forward()
    robot.turn(firstHalf)

    farmRow()

    robot.turn(not firstHalf)
    forward()
    forward()
    robot.turn(not firstHalf)

    farmRow()

    robot.turn(firstHalf)
    forward()
    robot.turn(firstHalf)

    seedSlot = 4
    farmRow()

    robot.turn(not firstHalf)
    forward()
    robot.turn(not firstHalf)

    dumpInv()

    firstHalf = not firstHalf
    if firstHalf then
        seedSlot = 8
    else
        seedSlot = 12
    end
end
