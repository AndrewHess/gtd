local ASTNode = {}
ASTNode.__index = ASTNode

ASTNode.NodeType = {
    Tag = "Tag",
    Not = "Not",
    And = "And",
    Or = "Or"
}

function ASTNode:new(type, value, children)
    assert(ASTNode.NodeType[type], "Invalid node type: " .. tostring(type))

    local self = setmetatable({}, ASTNode)
    self.type = type
    self.value = value              -- Only used on Tag nodes
    self.children = children or {}  -- Only used on non-Tag nodes
    return self
end

-- Factory functions for different types of nodes
function ASTNode.Tag(value)
    return ASTNode:new("Tag", value)
end

function ASTNode.And(children)
    return ASTNode:new("And", nil, children)
end

function ASTNode.Or(children)
    return ASTNode:new("Or", nil, children)
end

function ASTNode.Not(child)
    return ASTNode:new("Not", nil, {child})
end

return ASTNode

