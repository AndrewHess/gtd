local Filter = {}

local ASTNode = require('filter.ast')
local Evaluator = require('filter.evaluator')
local Parser = require('filter.parser')

local function Filter.extractTagsFromFile(filePath)
    local tags = {}
    for line in io.lines(filePath) do
        for tag in line:gmatch("(%s@[%S]+)") do
            -- Remove leading whitespace
            tag = tag:match("@[%S]+")
            tags[tag] = true
        end
        -- Check for a tag at the start of the line
        local initialTag = line:match("^@[%S]+")
        if initialTag then
            tags[initialTag] = true
        end
    end
    return tags
end

function Filter.evaluateFileAgainstAST(ast, filePath)
    local fileTags = extractTagsFromFile(filePath)
    return Evaluator.evaluate(ast, fileTags)
end

local function Filter.readFilterFile(filterFilePath)
    -- Read the filter file and return its contents
    local file = io.open(filterFilePath, "r")
    if not file then error("Unable to open filter file: " .. filterFilePath) end
    local content = file:read("*a")
    file:close()
    return content
end

local function Filter.getGtdFilesInDirectory(directoryPath)
    local files = {}
    -- Assuming LuaFileSystem (lfs) is available; otherwise, this part needs OS-specific handling
    for file in lfs.dir(directoryPath) do
        if file:match("%.gtd$") then
            table.insert(files, directoryPath .. '/' .. file)
        end
    end
    return files
end

local function Filter.filterFiles(filterFilePath, directoryPath)
    local filterContent = readFilterFile(filterFilePath)
    local ast = Parser.parse(filterContent)

    local passingFiles = {}
    local gtdFiles = getGtdFilesInDirectory(directoryPath)
    for _, filePath in ipairs(gtdFiles) do
        if FileEvaluator.evaluateFileAgainstAST(ast, filePath) then
            table.insert(passingFiles, filePath)
        end
    end

    return passingFiles
end

return Filter

