local Instance = {}
Instance.__index = Instance

function Instance.new(className)
    local self: {className: string, Name: string, _children: table} = {
        ClassName = className,
        Name = className,
        _children = {},
    }

    local metatable = {
        __index = Instance,
        __newindex = function(table, key, value)
            if key == "Parent" then
                rawset(table, "Parent", value)
                if value and value._children then
                    table.insert(value._children, table)
                end
            else
                rawset(table, key, value)
            end
        end,
    }

    return setmetatable(self, metatable)
end

function Instance.fromExisting(InstanceT)
    local newInstance = self.new(InstanceT.Name)

    for key, value in pairs(InstanceT) do
        if key ~= "ClassName" and key ~= "Parent" and key ~= "_children" then
            newInstance[key] = value
        end
    end

    if InstanceT._children then
        for _, child in ipairs(InstanceT._children) do
            local clonedChild = Instance.fromExisting(child)

            clonedChild.Parent = newInstance
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

function Instance:WaitForChild(name)
    return self:FindFirstChild(name) or Instance.new("Folder")
end

return Instance