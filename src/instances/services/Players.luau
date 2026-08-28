local Instance = require("../Instance")
local trace = require("../../logger/trace")

local Players = Instance.new("Players")
Players.Name = "Players"

local function generateFakePlayer(playerName)
    trace.log("FAKE_PLAYER_GENERATED", { targetPlayer = playerName})

    local player = Instance.new("Player")
    rawset(player, "Name", playerName)
    rawset(player, "UserId", 9840698982)

    local character = Instance.new("Model")
    rawset(character, "Name", playerName)

    local playerGui = Instance.new("PlayerGui")
    rawset(playerGui, "Name", "PlayerGui")
    rawset(playerGui, "Parent", player)

    rawset(player, "Character", character)

    return player
end

local originalFindFirstChild = Players.FindFirstChild
function Players:FindFirstChild(name)
    local existing = originalFindFirstChild(self, name)
    if existing then return existing end

    local newPlayer = generateFakePlayer(name)
    newPlayer.Parent = self
    return newPlayer
end

local mt = getmetatable(Players)
local originalIndex = mt.__index

mt.__index = function(self, key)
    local result = originalIndex(self, key)
    if result then return result end

    local newPlayer = generateFakePlayer(key)
    newPlayer.Parent = self
    return newPlayer
end

return Players