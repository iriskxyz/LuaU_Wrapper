local trace = require("../logger/trace")
local net = require("@lune/net")
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local TreeBuilder = require("../instances/TreeBuilder")

--local loadedModules = {}
local sourceCache = {}

--TODO: Should improve this.

return function(sandboxEnv)
    local executedCache = {}
    local function fakeRequire(path)
        if executedCache[path] then
            return executedCache[path]
        end

        local rootInstance

        trace.log("REQUIRE_CALLED", { path = tostring(path) })

        local sourceCode = ""

        if type(path) == "table" and path.ClassName == "ModuleScript" then
            rootInstance = path

        elseif type(path) == "number" then
            if sourceCache[path] then
                rootInstance = sourceCache[path]
            else
                if not fs.isDir("assets") then
                    fs.writeDir("assets")
                end
                local inputRbxmPath = "assets/model_" .. path .. ".rbxm"
                local outputJsonPath = "parsed_module.json"
                if not fs.isFile(inputRbxmPath) then
                --TODO: This formatting is shit, but I don't care.
                print("Downloading asset id ".. path)
                local headers = {}
                if fs.isFile("conf.json") then
                    local confStr = fs.readFile("conf.json")
                    local conf = serde.decode("json", confStr)
                    if conf.Cookie and conf.Cookie ~= "" then
                        if string.find(conf.Cookie, ".ROBLOSECURITY=") then
                            headers["Cookie"] = conf.Cookie
                        else
                            headers["Cookie"] = ".ROBLOSECURITY=".. conf.Cookie
                        end
                    end
                end
                local procResult =
                    process.exec("node", {"parse_module.js", inputRbxmPath, outputJsonPath, tostring(path)})
                if not procResult.ok then
                    error("Failed downloading asset id " .. path .. " Node.js error: " .. procResult.stderr)
                end
                local jsonString = fs.readFile("parsed_module.json")
                local parsedTree = serde.decode("json", jsonString)
                rootInstance = TreeBuilder.buildFromJSON(parsedTree)
                sourceCache[path] = rootInstance
            end

            local procResult = process.exec("node", {
                "parse_module.js",
                inputRbxmPath,
                outputJsonPath,
                tostring(path)
            })

            if not procResult.ok then
                error("Failed downloading asset id ".. path .." Node.js error: " .. procResult.stderr)
            end

            local jsonString = fs.readFile("parsed_module.json")
            local parsedTree = serde.decode("json", jsonString)

            rootInstance = TreeBuilder.buildFromJSON(parsedTree)
        else
            error("Attempted to require an invalid target type")
        end

        local sourceCode = rootInstance.Source or "return {}"
        local fn, err = loadstring(sourceCode)
        if not fn then
            error("Failed to compile required module: ".. tostring(err))
        end

        local moduleEnv = {}
        for key, value in pairs(sandboxEnv) do 
            moduleEnv[key] = value
        end
        moduleEnv.script = rootInstance

        setfenv(fn, moduleEnv)

        local success, result = pcall(fn)
        if not success then
            error("Module execution failed: ".. tostring(result))
        end

        executedCache[path] = result
        return result
    end

    return fakeRequire
end
