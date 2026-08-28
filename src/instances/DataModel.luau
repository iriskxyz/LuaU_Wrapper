local Instance = require("./Instance")
local HttpService = require("./services/HttpService")
local Players = require("./services/Players")
local RunService = require("./services/RunService")

local DataModel = Instance.new("DataModel")
DataModel.Name = "Game"


rawset(DataModel, "PlaceId", 123456789)
rawset(DataModel, "JobId", "12354-341232-32441-3412333")
rawset(DataModel, "CreatorId", 9840698982)
rawset(DataModel, "CreatorType", 1)
rawset(DataModel, "PrivateServerId", "")
rawset(DataModel, "PrivateServerOwnerId", 0)

local workspace = Instance.new("Workspace")
workspace.Name = "Workspace"
workspace.Parent = DataModel

Players.Parent = DataModel

local replicatedStorage = Instance.new("ReplicatedStorage", DataModel)
replicatedStorage.Name = "ReplicatedStorage"

local serverScriptService = Instance.new("ServerScriptService", DataModel)
serverScriptService.Name = "ServerScriptService"

local mockedServices = {
    HttpService = HttpService,
    Players = Players,
    RunService = RunService
}

function DataModel:GetService(serviceName)
    if mockedServices[serviceName] then
        local service = mockedServices[serviceName]
        if not service.Parent then
            rawset(service, "Parent", self)
        end

        return service
    end

    warn("Requested non-mocked service.")

    local service = self:FindFirstChild(serviceName)

    if not service then
        service = Instance.new(serviceName)
        service.Parent = self
    end
    
    return service
end

return {
    game = DataModel,
    workspace = workspace,
}
