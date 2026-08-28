local Instance = require("./Instance")

local TreeBuilder = {}

function TreeBuilder.buildFromJSON(nodeData, parentInstance)
    local inst = Instance.new(nodeData.ClassName)
    inst.Name = nodeData.Name

    if nodeData.Properties then
        for propName, propValue in pairs(nodeData.Properties) do
            rawset(inst, propName, propValue)     
        end
    end

    if parentInstance then
        inst.Parent = parentInstance
    end

    if nodeData.Children then
        for _, childData in ipairs(nodeData.Children) do
            TreeBuilder.buildFromJSON(childData, inst)
        end
    end

    return inst
end

return TreeBuilder