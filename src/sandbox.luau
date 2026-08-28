local Instance = require("./instances/Instance")
local DataModel = require("./instances/DataModel")
local trace = require("./logger/trace")
local buildRequire = require("./env/require")

local SandboxEnv = {
    game = DataModel.game,
    workspace = DataModel.workspace,

    Instance = {
        new = Instance.new
    },

    print = print,
    warn = warn,
    getfenv = getfenv,
    setfenv = setfenv,

    math = math,
    string = string,
    table = table
}

SandboxEnv.require = buildRequire(SandboxEnv)

local function executeCode(codeString)
    trace.clear()

    local fn, error = loadstring(codeString)

    if not fn then
        warn("Failed to compile code: ", error)
        return
    end

    setfenv(fn, SandboxEnv)

    local success, runtimeErr = pcall(fn)
    print(trace.dumpJSON())

    if not success then
        warn("Script Error:", runtimeErr)
    end

    return trace.dumpJSON()
end

return {
    execute = executeCode
}