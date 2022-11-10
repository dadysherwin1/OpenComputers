local robot = component.proxy(component.list("robot")())
local geolyzer = component.proxy(component.list("geolyzer")())
 
 
local seedSlot = 1
local firstHalf = true
 
function dumpInv()
  local invSize = robot.inventorySize()
    
  for i = 1, 8 do -- first 8 slots are reserved for seeds
    robot.select(i)
        local count = robot.count()
        if count > 32 then
      robot.drop(3, count - 32)
        end
  end
    
    for i = 9, invSize do -- the rest of the slots can be dumped
    robot.select(i)
    robot.drop(3)
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
    seedSlot = seedSlot + 1
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
    
    farmRow()
    
    robot.turn(not firstHalf)
    forward()
    robot.turn(not firstHalf)
    
    dumpInv()
    
    firstHalf = not firstHalf
    if firstHalf then seedSlot = 1 end
end