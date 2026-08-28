local trace = require("../logger/trace")
local net = require("@lune/net")

local loadedModules = {}

return function(env)
    local function fakeRequire(path)
        if loadedModules[path] then
            return loadedModules[path]
        end

        trace.log("REQUIRE_CALLED", { path = tostring(path) })

        local sourceCode = ""

        if type(path) == table and path.ClassName = "ModuleScript" then
            sourceCode = path.Source or "return {}"

        elseif type(path) == number then
            print("Downloading asset id ".. path)

            sourceCode = [[
            local module = {}
            function module.test()
                print('test')
            end
            return module
            ]]
        else
            error("Attempted to require an invalid target type")
        end

        local fn, err = loadstring(sourceCode)
        if not fn then
            error("Failed to compile required module: ".. tostring(err))
        end

        setfenv(fn, sandboxEnv)

        local success, result = pcall(fn)

        if not success then
            error("Module execution failed: ".. tostring(result))
        end

        loadedModules[target] = result
        return result
    end

    return customRequire
end