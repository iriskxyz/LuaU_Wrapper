local trace = require("../logger/trace")

local Instance = {}
Instance.__index = Instance

local READ_ONLY_PROPERTIES = {
    PlaceId = true,
    JobId = true,
    CreatorId = true,
    ClassName = true
}

function Instance.new(className)
    local self: {className: string, Name: string, _children: table} = {
        ClassName = className,
        Name = className,
        _children = {},
    }

    local metatable = {
        __index = function(instance, key)
           if instance[key] then return Instance[key] end
           
           local prop = rawget(instance, key)
           if prop ~= nil then return prop end

           for _, child in ipairs(instance._children) do
                if child.Name == key then
                    return child
                end
           end

           return nil
        end,
        __newindex = function(instance, key, value)
            if READ_ONLY_PROPERTIES[key] then
                trace.log("TAMPER_ATTEMPT", {
                    property = key,
                    attemptedValue = value,
                    message = "Script tried to overwrite a read-only property"
                })

                warn("Sandbox blocked attempt to modify read-only property: ".. key)
                return
            end

            if key == "Parent" then
                rawset(instance, "Parent", value)

                if value and value._children then
                    table.insert(value._children, instance)
                end
            else
                rawset(instance, key, value)
            end
        end,
    }

    return setmetatable(self, metatable)
end

function Instance.fromExisting(InstanceT)
    local newInstance = Instance.new(InstanceT.Name)

    for key, value in pairs(InstanceT) do
        if key ~= "ClassName" and key ~= "Parent" and key ~= "_children" then
            newInstance[key] = value
        end
    end

    return newInstance
end

function Instance:GetChildren()
    return self._children
end

function Instance:FindFirstChild(name)
    for _, child in ipairs(self._children) do
        if child.Name == name then
            return child
        end
    end

    return nil
end

function Instance:FindFirstChildOfClass(className)
    for _, child in ipairs(self._children) do
        if child.ClassName == className then
            return child
        end
    end
    return nil
end

function Instance:WaitForChild(name)
    return self:FindFirstChild(name) or Instance.new("Folder")
end

function Instance:Clone()
    local clone = Instance.new(self.ClassName)

    for key, value in pairs(self) do
        if type(value) ~= "function" and type(value) ~= "table" and key ~= "Parent" then
            clone[key] = value
        end
    end

    for _, child in ipairs(self._children) do
        local childClone = child:Clone()

        childClone.Parent = clone
    end

    return clone
end

return Instance