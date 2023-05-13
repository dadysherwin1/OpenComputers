-- adds a button on ur glasses to open connected OpenSecurity doors
local glasses = component.proxy(component.list("glasses")())
local doorcontroller = component.proxy(component.list("os_doorcontroller")())

glasses.setTerminalName("Door")
glasses.startLinking()
glasses.removeAll()

-- add ui buttons
local title = glasses.addText2D()
title.setText("Doors")
title.setFontSize(20)
title.addTranslation(20,100,0)
title.addColor(1, 1, 0, 0)
local widget1 = glasses.addText2D()
widget1.setText("Toggle Doors")
widget1.setFontSize(20)
widget1.addTranslation(20,120,0)

while true do
	local event, _, _, x, y = computer.pullSignal()
    if event == "interact_overlay" and x >= 20 and x <= 100 then
    	if y >= 120 and y <= 140 then
            doorcontroller.toggle()
        end
    end
end