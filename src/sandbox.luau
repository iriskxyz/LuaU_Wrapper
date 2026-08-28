local Instance = require("./instances/Instance")
local DataModel = require("./instances/DataModel")

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

local function executeCode(codeString)
    local fn, error = loadstring(codeString)

    if not fn then
        warn("Failed to compile code: ", err)
        return
    end

    setfenv(fn, SandboxEnv)

    print("Compiling code")
    local success, runtimeErr = pcall(fn)
    print("Compiler finished")

    if not success then
        warn("Script Error:", runtimeErr)
    end
end

executeCode([[
    local part = Instance.new("Part")
    part.Name = "MaliciousPart"
    part.Parent = workspace
    
    print("Workspace children count:", #workspace:GetChildren())
    print("Found part:", workspace:FindFirstChild("MaliciousPart").Name)
]])