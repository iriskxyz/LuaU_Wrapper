local process = require("@lune/process")
local fs = require("@lune/fs")
local sandbox = require("../src/sandbox")

local args = process.args

if #args == 0 then
    print("============================")
    print("Roblox Engine Wrapper")
    print("Made by irisk/sourcefundings")
    print("============================")
    print("Usage: lune run bin/run.luau path")
    print("eg. lune run bin/run.luau scripts/test.luau")
    process.exit(1)
end

local path = args[1]
local codeToRun = ""

if path then
    if not fs.isFile(path) then
        warn("[CLI] Error: Target file could not be resolved. Path -> ".. path)
        process.exit(1)
    end

    codeToRun = fs.readFile(path)
end

print("\n[CLI] Executing on Sandbox...")
print("--------------------------------------------------")

local traceJson = sandbox.execute(codeToRun)

print("--------------------------------------------------")
print("[CLI] Sandbox execution complete.")

local tracePath = "sandbox_trace.json"
fs.writeFile(tracePath, traceJson or "[]")
print("[CLI] Full execution trace saved to -> " .. tracePath)