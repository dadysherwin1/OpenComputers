-- adds a button on ur glasses to place fog down
local glasses = component.proxy(component.list("glasses")())
local nanofog_terminal = component.proxy(component.list("os_nanofog_terminal")())

glasses.setTerminalName("Fog")
glasses.startLinking()
glasses.removeAll()

-- add ui buttons
local title = glasses.addText2D()
title.setText("Blocks")
title.setFontSize(20)
title.addTranslation(20,200,0)
title.addColor(1, 0, 1, 0)
local widget1 = glasses.addText2D()
widget1.setText("Place Blocks")
widget1.setFontSize(20)
widget1.addTranslation(20,220,0)
local widget2 = glasses.addText2D()
widget2.setText("Switch to Ghost")
widget2.setFontSize(20)
widget2.addTranslation(20,240,0)

local blocksPlaced = {}
local isSolid = true

-- functions
function placeBlock(x, y, z)
    y = y + 1
    nanofog_terminal.set(x, y, z, "ice")
    if isSolid then
        nanofog_terminal.setSolid(x, y, z)
    end
    table.insert(blocksPlaced, {x, y, z})
end

function destroyBlock(x, y, z)
    y = y + 1
    nanofog_terminal.reset(x, y, z)
end

function switchToSolid()
    isSolid = true
    for _,pos in pairs(blocksPlaced) do
        local x = pos[1]
        local y = pos[2]
        local z = pos[3]
        nanofog_terminal.setSolid(x, y, z)
    end
end

function switchToGhost()
    isSolid = false
    for _,pos in pairs(blocksPlaced) do
        local x = pos[1]
        local y = pos[2]
        local z = pos[3]
        nanofog_terminal.setShield(x, y, z)
    end
end

while true do
	local event, _, _, x, y = computer.pullSignal()
    if event == "interact_overlay" and x >= 20 and x <= 100 then
    	if y >= 220 and y <= 240 then
            
            widget1.setText("Stop")
            widget2.setText("")
            
            while true do
                local event, _, _, x, y, _, _, _, _, _, blockX, blockY, blockZ, face = computer.pullSignal()
                if event == "interact_overlay" and x >= 20 and x <= 100 and y >= 220 and y <= 240 then
                    break
                elseif event == "interact_world_block_right" then
                    if face == "north" then
                        placeBlock(blockX, blockY, blockZ - 1)
                    elseif face == "east" then
                        placeBlock(blockX + 1, blockY, blockZ)
                    elseif face == "south" then
                        placeBlock(blockX, blockY, blockZ + 1)
                    elseif face == "west" then
                        placeBlock(blockX - 1, blockY, blockZ)
                    elseif face == "up" then
                        placeBlock(blockX, blockY + 1, blockZ)
                    else -- if face == "down" then
                        placeBlock(blockX, blockY - 1, blockZ)
                    end
                elseif event == "interact_world_block_left" then
                    destroyBlock(blockX, blockY, blockZ)
                end
            end

            widget1.setText("Place Blocks")
            if isSolid then
                widget2.setText("Switch to Ghost")
            else
                widget2.setText("Switch to Solid")
            end
        elseif y >= 240 and y <= 260 then
            if isSolid then
                switchToGhost()
                widget2.setText("Switch to Solid")
            else
                switchToSolid()
                widget2.setText("Switch to Ghost")
            end
        end
    end
end