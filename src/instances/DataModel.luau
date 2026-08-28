local Instance = require("Instance")

local DataModel = Instance.new("DataModel")
DataModel.Name = "Game"

local workspace = Instance.new("Workspace")
workspace.Name = "Workspace"
workspace.Parent = DataModel

local replicatedStorage = Instance.new("ReplicatedStorage")
replicatedStorage.Name = "ReplicatedStorage"
replicatedStorage.Parent = DataModel

function DataModel:GetService(serviceName)
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