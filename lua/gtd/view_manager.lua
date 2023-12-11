local ViewManager = {}

local FileListView = require('gtd.file_list_view')

function ViewManager.show_views_list()
    local views = ViewManager.read_views()  -- Returns a table of views
    local buf = vim.api.nvim_create_buf(false, true)  -- Create a new buffer

    -- Populate the buffer with view names
    local lines = {}
    for _, view in ipairs(views) do
        table.insert(lines, view.name)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Open the buffer in a new window or tab
    vim.api.nvim_set_current_buf(buf)

    -- Set the keybindings
    ViewManager.set_keybindings(views)
end

function ViewManager.read_views()
    local views_path = vim.fn.expand('~/gtd/views')  -- Expands to the full path
    local views = {}

    for filename in io.popen('ls "' .. views_path .. '"'):lines() do
        local viewName = filename
        local filter = ViewManager.read_filter(views_path .. "/" .. filename)
        table.insert(views, { name = viewName, filter = filter })
    end

    return views
end

function ViewManager.read_filter(filePath)
    local file = io.open(filePath, "r")
    if not file then return nil end

    local filter = file:read("*line")
    file:close()
    return filter
end

function ViewManager.set_keybindings(views)
    vim.api.nvim_set_keymap('n', '<CR>', ':lua require("gtd.view_manager").open_view()<CR>', {noremap = true, silent = true})
end

function ViewManager.open_view()
    -- The whole line is the filename
    local filename = vim.fn.getline('.')
    local file_path = vim.fn.expand('~/gtd/views/' .. filename)
    local file = io.open(file_path, "r")

    if not file then
        error("Error: Unable to open file at path " .. file_path)
    end

    -- Read the first line, which has the filter text
    local filter_text = file:read("*line")
    file:close()

    if not filter_text then
        error("Error: The file is empty.")
    end

    FileListView.list_gtd_files(filter_text)
end

return ViewManager

