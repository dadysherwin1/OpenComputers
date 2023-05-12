local drone = component.proxy(component.list("drone")())
local glasses = component.proxy(component.list("glasses")())

drone.setLightColor(0x009999)
glasses.setTerminalName("Snow")
glasses.startLinking()
glasses.removeAll()

-- add ui buttons
local widget1 = glasses.addText2D()
widget1.setText("Follow")
widget1.addScale(3,3,0)
widget1.addTranslation(10,10,0)
local widget2 = glasses.addText2D()
widget2.setText("Move")
widget2.addScale(3,3,0)
widget2.addTranslation(10,25,0)
local widget3 = glasses.addText2D()
widget3.setText("Use")
widget3.addScale(3,3,0)
widget3.addTranslation(10,40,0)

local offsetX = 0
local offsetY = 0
local offsetZ = 0

function follow()
    if drone.getOffset() <= 1 then
        local relativePos = glasses.getUserPosition()[1]
        local relativePosX = relativePos["x"]
        local relativePosY = relativePos["y"] + 0.5
        local relativePosZ = relativePos["z"]
        if math.abs(relativePosX) + math.abs(relativePosY) + math.abs(relativePosZ)  > 2.5 then
            drone.move(relativePosX, relativePosY, relativePosZ)
        end
    end
end

function move()
	widget1.setText("Right-click a block")
    widget2.setText("")
    widget3.setText("")
    while true do
    	local event, _, _, _, _, _, _, _, _, _, goalX, goalY, goalZ = computer.pullSignal()
        if event == "interact_world_block_right" then
            drone.move(goalX, goalY + 1, goalZ)
            break
        end
    end
end

function use()
    drone.use(0)
end

while true do
	local event, _, _, x, y = computer.pullSignal()
    if event == "interact_overlay" and x >= 10 * 3 and x <= 40 * 3 then
    	if y >= 10 * 3 and y <= 20 * 3 then
            
            widget1.setText("Stop")
            widget2.setText("")
            widget3.setText("")
            
            while true do
                follow()
                local event, _, _, x, y = computer.pullSignal(0.05)
                if event == "interact_overlay" and x >= 10 * 3 and x <= 40 * 3 and y >= 10 * 3 and y <= 20 * 3 then
                    break
                end
            end
        elseif y >= 25 * 3 and y <= 35 * 3 then
            move()
        elseif y >= 40 * 3 and y <= 50 * 3 then
            use()
        end
    end
         
    widget1.setText("Follow")
    widget2.setText("Move")
    widget3.setText("Use")
end
