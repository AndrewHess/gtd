local Parser = {}

local ASTNode = require('gtd.filter.ast')

-- Parse an individual expression
function Parser.parse(input)
    input = input:match("^%s*(.*)%s*$")  -- Trim leading and trailing whitespace

    if input:sub(1, 4) == "and(" then
        return Parser.parseAnd(input)
    elseif input:sub(1, 3) == "or(" then
        return Parser.parseOr(input)
    elseif input:sub(1, 4) == "not(" then
        return Parser.parseNot(input)
    else
        return Parser.parseTag(input)
    end
end

-- Parse an And expression
function Parser.parseAnd(input)
    local content = Parser.extractContent(input, "and")
    return ASTNode.And(Parser.parseListOfExpressions(content))
end

-- Parse an Or expression
function Parser.parseOr(input)
    local content = Parser.extractContent(input, "or")
    return ASTNode.Or(Parser.parseListOfExpressions(content))
end

-- Parse a Not expression
function Parser.parseNot(input)
    local content = Parser.extractContent(input, "not")
    return ASTNode.Not(Parser.parseListOfExpressions(content))
end

-- Parse a tag
function Parser.parseTag(input)
    -- Assuming a tag is a simple string starting with '@'
    if input:match("^@[%w%d_-]+") then
        return ASTNode.Tag(input)
    else
        error("Invalid tag format: " .. input)
    end
end

-- Extract content inside the function call
function Parser.extractContent(input, funcName)
    local pattern = "^" .. funcName .. "%((.*)%)$"
    local content = input:match(pattern)
    if not content then
        error("Invalid " .. funcName .. " format: " .. input)
    end
    return content
end

-- Parse a list of expressions separated by commas
function Parser.parseListOfExpressions(input)
    local depth = 0
    local expressions = {}
    atom_start = 1

    for i = 1, #input do
        local char = input:sub(i, i)
        if char == "(" then
            depth = depth + 1
        elseif char == ")" then
            depth = depth - 1
        elseif char == "," and depth == 0 then
            local exp = input:sub(atom_start, i - 1)
            table.insert(expressions, Parser.parse(exp))
            atom_start = i + 1
        end
    end

    -- Add the last expression
    table.insert(expressions, Parser.parse(input:sub(atom_start, #input)))

    return expressions
end

return Parser

