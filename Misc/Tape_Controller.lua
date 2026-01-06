-- put a tape drive next to this pc, chuck a cassette in, and play some tunes!
-- btw, to get a casette, u need to use the tape library (craft a OpenOS disc and a scrench!)

local tape_drive = component.proxy(component.list("tape_drive")())
while true do
    if tape_drive.getState() == "PLAYING" then
        if tape_drive.read(10) == "\0\0\0\0\0\0\0\0\0\0" then -- if no sound
            tape_drive.seek(-1000000000) -- rewind to start
        end
    end
    computer.pullSignal(.05)
end