local Evaluator = {}

local ASTNode = require('gtd.filter.ast')

-- Main evaluate function
function Evaluator.evaluate(node, fileTags)
    if node.type == ASTNode.NodeType.Tag then
        return Evaluator.evaluateTag(node, fileTags)

    elseif node.type == ASTNode.NodeType.And then
        return Evaluator.evaluateAnd(node, fileTags)

    elseif node.type == ASTNode.NodeType.Or then
        return Evaluator.evaluateOr(node, fileTags)

    elseif node.type == ASTNode.NodeType.Not then
        return Evaluator.evaluateNot(node, fileTags)

    else
        error("Unknown node type: " .. tostring(node.type))
    end
end

-- Evaluate a Tag node
function Evaluator.evaluateTag(node, fileTags)
    return fileTags[node.value] ~= nil
end

-- Evaluate an And node
function Evaluator.evaluateAnd(node, fileTags)
    for _, child in ipairs(node.children) do
        if not Evaluator.evaluate(child, fileTags) then
            return false
        end
    end
    return true
end

-- Evaluate an Or node
function Evaluator.evaluateOr(node, fileTags)
    for _, child in ipairs(node.children) do
        if Evaluator.evaluate(child, fileTags) then
            return true
        end
    end
    return false
end

-- Evaluate a Not node
function Evaluator.evaluateNot(node, fileTags)
    for _, child in ipairs(node.children) do
        if Evaluator.evaluate(child, fileTags) then
            return false
        end
    end
    return true
end

return Evaluator

