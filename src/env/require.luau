local trace = require("../logger/trace")
local net = require("@lune/net")
local fs = require("@lune/fs")
local process = require("@lune/process")
local TreeBuilder = require("../instances/TreeBuilder")

local loadedModules = {}

return function(env)

    local function fakeRequire(path)
        if loadedModules[path] then
            return loadedModules[path]
        end

        local rootInstance

        trace.log("REQUIRE_CALLED", { path = tostring(path) })

        local sourceCode = ""

        if type(path) == table and path.ClassName = "ModuleScript" then
            sourceCode = path.Source or "return {}"

        elseif type(path) == number then
            if not fs.isDir("assets") then
                fs.writeDir("assets")
            end

            local inputRbxmPath = "assets/model_".. path ..".rbxm"
            local outputJsonPath = "parsed_module.json"

            if not fs.isFile(inputRbxmPath) then
                print("Downloading asset id ".. path)

                local response = net.request({
                    url = "https://assetdelivery.roblox.com/v1/asset?id=".. path,
                    method = "GET"
                })

                if response.ok then
                    fs.writeFile(inputRbxmPath, response.body)
                    print("ok.")
                else
                    error(string.format("Failed to download asset! HTTP %d: %s", response.statusCode, response.statusMessage))
                end
            end

            local procResult = process.spawn("node", {
                "parse_module.js",
                inputRbxmPath,
                outputJsonPath,
                tostring(path)
            })

            if not procResult.ok then
                error("Failed downloading asset id ".. path .." Node.js error.")
            end

            local jsonString = fs.readFile("parsed_module.json")
            local parsedTree = serde.decode("json", jsonString)

            rootInstance = TreeBuilder.buildFromJSON(parsedTree)
        else
            error("Attempted to require an invalid target type")
        end

        local fn, err = loadstring(sourceCode)
        if not fn then
            error("Failed to compile required module: ".. tostring(err))
        end

        local moduleEnv = {}
        for key, value in pairs(sandboxEnv) do 
            moduleEnv[key] = value
        end
        moduleEnv.script = rootInstance

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