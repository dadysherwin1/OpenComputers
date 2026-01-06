local component = require("component")

io.write("Title: ")
local args = {io.read()}

io.write("Body (EOF to finish):\n")
while true do
    local line = io.read()
    if string.upper(line) == "EOF" then break end
    table.insert(args, line)
end

component.tunnel.send(table.unpack(args))