local Filter = {}

local ASTNode = require('gtd.filter.ast')
local Evaluator = require('gtd.filter.evaluator')
local Parser = require('gtd.filter.parser')

local ast_node = nil -- Call set_filter to set the AST

function Filter.set_filter(filter_text)
	ast_node = Parser.parse(filter_text)
end

local function extract_tags_from_file(filePath)
    local tags = {}
    for line in io.lines(filePath) do
        for tag in line:gmatch("(%s@[%S]+)") do
            -- Remove leading whitespace
            tag = tag:match("@[%S]+")
--            tags[tag] = true
            table.insert(tags, tag)
        end
        -- Check for a tag at the start of the line
        local initialTag = line:match("^@[%S]+")
        if initialTag then
--            tags[initialTag] = true
            table.insert(tags, initialTag)
        end
    end
    return tags
end

function Filter.file_passes_filter(file_path)
    if ast_node == nil then
        error("Error: Filter not set.")
    end

    local fileTags = extract_tags_from_file(file_path)
    return Evaluator.evaluate(ast_node, fileTags)
end

return Filter

