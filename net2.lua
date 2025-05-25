local modem = peripheral.find("modem") or error("No modem attached", 0)
math.randomseed(os.epoch() * os.time())

local CHANNEL = 600

local function getUUID()
    return string.format("%08x", os.epoch()) .. "-" .. string.format("%06x", math.random(0, 0xFFFFFF))
end

local net2 = {}
local net2id = {}

function net2.open()
    modem.open(CHANNEL)
end

function net2.close()
    modem.close(CHANNEL)
end

function net2.getID(raw)
    if raw then
        return net2id
    elseif net2id.purpose and net2id.name and net2id.uuid then
        return net2id.purpose .. ":" .. net2id.name .. ":" .. net2id.uuid
    else
        return nil
    end
end

function net2.send(msg, id, headers)
    modem.transmit(CHANNEL, CHANNEL, {msg, id, net2.getID(), headers})
end

local function getMessage()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == CHANNEL and type(message) == "table" and message[2] == net2.getID() then
            return event, side, channel, replyChannel, message, distance
        end
    end
end

local function timer(timeout)
    if timeout then
        local timerID = os.startTimer(timeout)
        while true do
            local _, id = os.pullEvent("timer")
            if id == timerID then return nil end
        end
    else while true do sleep(0) end
    end
end

function net2.receive(opts)
    local timeout = opts.timeout
    local callback = opts.callback
    local message, distance
    local function wGetMessage()
        _, _, _, _, message, distance = getMessage()
    end

    local result = parallel.waitForAny(wGetMessage, function() timer(timeout) end)
    if result == 1 then
        if callback then return callback(message, distance)
        else return message, distance end
    else
        return nil
    end
end

function net2.setID(purpose, name)
    net2id.purpose = purpose
    net2id.name = name
    net2id.uuid = getUUID()
end

net2.setID("computer", os.getComputerID())

function net2.setUUID(uuid)
    if uuid:match("^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]%-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$") then
        net2id.uuid = uuid
        return true
    else
        return false
    end
end

return net2
