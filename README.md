# net2
CC modem wrapper

Server example
```lua
local net2 = require "net2"
net2.setID("server", "devserver1")
net2.setUUID("06dc6530-0fd673")
print(net2.getID().." running")
net2.open()

local function response(message, _)
    print(message[1] .. " from " .. message[3])
    print("Headers: " .. textutils.serialise(message[4]))
end

while true do
    net2.receive({callback = response})
end
```

Client example
```lua
local net2 = require "net2"
net2.setID("computer", "devcomputer1")
print(net2.getID().." running")
net2.send("Hello, world!", "server:devserver1:06dc6530-0fd673", {})
```
