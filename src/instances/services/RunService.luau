local Instance = require("../Instance")
local trace = require("../../logger/trace")
local serde = require("@lune/serde")

local RunService = Instance.new("RunService") 
RunService.Name = "RunService"

local function createFakeSignal(eventName)
    local signal = {}

    function signal:Connect(callback)
        trace.log("RUNSERVICE_CONNECT", { event = eventName })

        local success, err = pcall(callback, 0.016) -- Standard 60FPS delta time
        if not success then
            warn("[RunService]: Callback error: ".. eventName ..": ".. tostring(err))
        end

        return {
            Disconnect = function() end
        }
    end

    function signal:Wait()
        trace.log("RUNSERVICE_WAIT", { event = eventName })
        return 0.016
    end

    return signal
end

rawset(RunService, "Heartbeat", createFakeSignal("Heartbeat"))
rawset(RunService, "Stepped", createFakeSignal("Stepped"))
rawset(RunService, "RenderStepped", createFakeSignal("RenderStepped"))

function RunService:IsStudio()
    return false --If we are ever doing something like analzying a backdoor this should return false, since most backdoors check if this is true.
end

function RunService:IsRunMode()
    return false --Original function in regular Roblox is inconsistent, returning true even if a Run wasn't initiated from Studio.
end

function RunService:IsRunning()
    return true
end

function RunService:IsClient()
    local callerEnv = getfenv(2)
    if callerEnv and type(callerEnv.script) == "table" then
        return callerEnv.script.ClassName == "LocalScript"
    end

    return false
end

--Is this correct?
function RunService:IsServer()
    local callerEnv = getfenv(2)
    if callerEnv and type(callerEnv.script) == "table" then
        return callerEnv.script.ClassName == "Script"
    end

    return false
end

return RunService
