local Instance = require("../Instance")
local trace = require("../../logger/trace")
local serde = require("@lune/serde")
--Some of these might be un-needed

local RunService = Instance.new("RunService") --?
RunService.Name = "RunService"

function RunService:IsStudio()
    return false --If we are ever doing something like analzying a backdoor this should return false, since most backdoors check if this is true.
end

--TODO: Should IsClient and IsServer be changed?

function RunService:IsClient()
    return false
end

function RunService:IsServer()
    return true --We are a server script
end

function RunService:IsRunMode()
    return false --Original function in regular Roblox is inconsistent, returning true even if a Run wasn't initiated from Studio.
end

function RunService:IsRunning()
    return true --Yes.
end

return RunService
