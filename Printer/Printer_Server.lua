local openprinter = component.proxy(component.list("openprinter")())

while true do
    local args = table.pack(computer.pullSignal())
	-- local event, _, _, _, distance, title, lines = computer.pullSignal()
    if args[1] == "modem_message" then
        openprinter.clear()
        openprinter.setTitle(args[6])
        for i = 7, #args do
            local line = args[i]
            openprinter.writeln(line)
        end
    end
    openprinter.print()
end

