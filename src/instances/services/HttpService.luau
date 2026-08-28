local Instance = require("../Instance")
local trace = require("../../logger/trace")
local serde = require("@lune/serde")

local HttpService = Instance.new("HttpService")
HttpService.Name = "HttpService"

function HttpService:PostAsync(url, data, content_type, compress, headers)
    trace.log("HTTP_POST_INTERCEPTED", {
        url = url,
        payload = data,
        headers = headers or {}
    })

    return '{"message": "success", "id": "200"}'
end


function HttpService:GetAsync(url, nocache, headers)
    trace.log("HTTP_GET_INTERCEPTED", {
        url = url,
        headers = headers or {}
    })

    return '{"status": "ok"}'
end

function HttpService:JSONEncode(data)
    return serde.encode("json", data)
end

function HttpService:JSONDecode(data)
    return serde.decode("json", data)
end

function HttpService:GenerateGUID(bool)
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    local guid = string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)

        return string.format("%x", v)
    end)

    if bool == false then
        return guid
    end

    return "{".. guid .."}"
end

return HttpService