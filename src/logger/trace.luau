local serde = require("@lune/serde")
local datetime = require("@lune/datetime")

local trace = {
    events = {}
}

function trace.log(actionType, details)
    table.insert(trace.events, {
        action = actionType,
        details = details,
    })
end

function trace.dumpJSON()
    return serde.encode("json", trace.events, true)
end

function trace.clear()
    trace.events = {}
end

return trace