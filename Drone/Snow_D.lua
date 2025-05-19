-- emotional support drone
-- CPU T1, Memory T1.5, Lua EEPROM, 
-- Inventory Upgrade, Solar Generator Upgrade, Battery Upgrade T1, Particle FX Card, Glasses Terminal Card

-- CONFIGS
local unit = 24 -- ui scale

local drone = component.proxy(component.list("drone")())
local glasses = component.proxy(component.list("glasses")())
local particle = component.proxy(component.list("particle")())

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
-- local widget3 = glasses.addText2D()
-- widget3.setText("Use")
-- widget3.setFontSize(20)
-- widget3.addTranslation(20,60,0)

-- add 3D box to locate lost drones easier
local box = glasses.addCube3D()
box.addColor(.6,1,1,.75)
box.addTranslation(0,-.5,0)

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

-- function use()
--     drone.use(0)
-- end

while true do
	local event, _, _, x, y = computer.pullSignal()
    if event == "interact_overlay" and x >= unit and x <= unit*5 then
    	if y >= unit*2 and y <= unit*3 then
            
            particle.spawn("heart",0,0,0)
            widget1.setText("Stop")
            widget2.setText("")
            -- widget3.setText("")
            
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
        -- elseif y >= 60 and y <= 80 then
        --     use()
        end
    elseif event == "inventory_changed" then
        computer.beep(500, .2)
        computer.beep(700, .2)
    end
         
    widget1.setText("Follow")
    widget2.setText("Move")
    -- widget3.setText("Use")
end
