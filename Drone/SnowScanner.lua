-- this drones got a Scan function, it can scan ores for ya
-- its lowkey useless tho cause every ore hsa a hardness of 3
-- its useful if u wanna find ores that have a higher hardness at least
-- not completed cause its not useful atm, if ryan wants it for draconium ore or smth then ill finish it
-- it hits the widget limit atm, fix that

-- CONFIGS
local unit = 24 -- ui scale

local drone = component.proxy(component.list("drone")())
local glasses = component.proxy(component.list("glasses")())
local particle = component.proxy(component.list("particle")())
local geo = component.proxy(component.list("geolyzer")())

drone.setLightColor(0x00ffff) -- 009999
glasses.setTerminalName("Snow")
glasses.startLinking()
glasses.removeAll()

-- add ui buttons
local title = glasses.addText2D()
title.setText("Drone")
title.setFontSize(unit)
title.addTranslation(unit,unit,0)
title.addColor(0, 1, 1, 0)
local widget1 = glasses.addText2D()
widget1.setText("Follow")
widget1.setFontSize(unit)
widget1.addTranslation(unit,unit*2,0)
local widget2 = glasses.addText2D()
widget2.setText("Move")
widget2.setFontSize(unit)
widget2.addTranslation(unit,unit*3,0)
local widget3 = glasses.addText2D()
widget3.setText("Scan")
widget3.setFontSize(unit)
widget3.addTranslation(unit,unit*4,0)

-- add 3D box to locate lost drones easier
local box = glasses.addCube3D()
box.addColor(.6,1,1)
box.addTranslation(0,-.5,0)
box.addScale(.3,.3,.3)
box.setVisibleThroughObjects(true)

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
    -- widget3.setText("")
    while true do
    	local event, _, _, _, _, _, _, _, _, _, goalX, goalY, goalZ = computer.pullSignal()
        if event == "interact_world_block_right" then
            drone.move(goalX, goalY + 1, goalZ)
            break
        end
    end
end

function tocolor(pl)
    local minpl = 2
    local maxpl = 5
    local color = (pl - minpl) / maxpl
    if color < 0 then
        return {1, 1, 1}
    elseif color > 1 then
        return {1, 0, 1}
    else
        return {color, 1 - color, 0}
    end
end
function create(x, y, z, p)
    local widget = glasses.addCube3D()
    widget.addTranslation(x + 0.125, y + 0.125, z + 0.125)
    widget.addScale(0.75, 0.75, 0.75)
    widget.setVisibleThroughObjects(true)

    local color = tocolor(p)
    color[4] = 1

    widget.addColor(table.unpack(color))
end
function scan()
    local size = 16
    local pl = 3
    local maxY = 1

    for x = -size, size do
        for z = -size, size do
            local tile = geo.scan(x, z)
            -- os.sleep(0)
            for Y = -math.min(size, 18), math.min(maxY, 18) do
                local y = Y + 32
                if tile[y] > pl then
                    create(x, Y, z, tile[y])
                end
            end
        end
    end
end

while true do
	local event, _, _, x, y = computer.pullSignal()
    if event == "interact_overlay" and x >= unit and x <= unit*5 then
    	if y >= unit*2 and y <= unit*3 then
            
            particle.spawn("heart",0,0,0)
            widget1.setText("Stop")
            widget2.setText("")
            widget3.setText("")
            
            while true do
                follow()
                local event, _, _, x, y = computer.pullSignal(0.05) -- 0.05
                if event == "interact_overlay" then
                    if x >= unit and x <= unit*5 and y >= unit*2 and y <= unit*3 then
                        break
                    end
                elseif event == "inventory_changed" then
                    computer.beep(500, .2)
                    computer.beep(700, .2)
                end
            end
        elseif y >= unit*3 and y <= unit*4 then
            move()
        elseif y >= unit*4 and y <= unit*5 then
            scan()
        end
    elseif event == "inventory_changed" then
        computer.beep(500, .2)
        computer.beep(700, .2)
    end
         
    widget1.setText("Follow")
    widget2.setText("Move")
    widget3.setText("Scan")
end
