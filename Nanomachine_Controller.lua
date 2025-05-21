-- sets up your nanomachines, son
-- Home PC
-- Glasses Terminal Card, Network Card T1

-- Absorption gives u invincibility lol
-- U can get blue music note particles LIKE MIKU!

local glasses = component.proxy(component.list("glasses")())
local modem = component.proxy(component.list("modem")())

glasses.setTerminalName("Nanomachines")
glasses.startLinking()
glasses.removeAll()

-- port 1 sends nanomachine messages
modem.open(2) -- port 2 receives nanomachine messages

-- set response port
modem.broadcast(1, "nanomachines", "setResponsePort", 2)
while true do
    event, _, _, _, _, _, functionName, count = computer.pullSignal()
    if functionName == "port" then
        break
    end
end

-- get number of inputs
local inputCount = 0
modem.broadcast(1, "nanomachines", "getTotalInputCount")
while true do
    event, _, _, _, _, _, functionName, count = computer.pullSignal()
    if functionName == "totalInputCount" then
        inputCount = count
        break
    end
end

-- set response port
local safeActiveInputs = 0
modem.broadcast(1, "nanomachines", "getSafeActiveInputs")
while true do
    event, _, _, _, _, _, functionName, count = computer.pullSignal()
    if functionName == "safeActiveInputs" then
        safeActiveInputs = count
        break
    end
end

-- add UI labels
local buttons = {}
for i = 1, inputCount do
    local widget = glasses.addText2D()
    widget.setText(i)
    widget.setFontSize(20)
    widget.addTranslation(100 + i*20,20,0)
    buttons[i] = {widget, false}
end
local saveText = glasses.addText2D()
saveText.setText("Save")
saveText.setFontSize(20)
saveText.addTranslation(120 + inputCount*20,20,0)
local safeText = glasses.addText2D()
safeText.setText("Safe active inputs: " .. safeActiveInputs)
safeText.setFontSize(20)
safeText.addTranslation(160 + inputCount*20,20,0)

-- register click events
while true do
	local event, _, _, x, y, _, functionName, result = computer.pullSignal()
    if event == "interact_overlay" and y >= 20 and y <= 40 then
        if x >= 120 and x <= 120 + inputCount*20 then
    	    local input = math.floor((x - 100) / 20)
            if buttons[input][2] == false then
                modem.broadcast(1, "nanomachines", "setInput", input, true)
                buttons[input][2] = true
                buttons[input][1].addColor(0, 1, 0, 0)
            else
                modem.broadcast(1, "nanomachines", "setInput", input, false)
                buttons[input][2] = false
                buttons[input][1].addColor(1, 1, 1, 0)
            end
        elseif x >= 120 + inputCount*20 and x <= 140 + inputCount*20 then
            glasses.removeAll()
            break
        end
    end
end

