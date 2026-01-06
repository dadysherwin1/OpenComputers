local tape_drive = component.proxy(component.list("tape_drive")())
while true do
    if tape_drive.getState() == "PLAYING" then
        if tape_drive.read(10) == "\0\0\0\0\0\0\0\0\0\0" then
            tape_drive.seek(-1000000000)
        end
    end
    computer.pullSignal(.05)
end