local FileListView = {}

local Filter = require('gtd.filter')

-- Custom comparison function for natural sort
local function naturalSort(a, b)
    -- Convert strings to sequences of digits and non-digits
    local function digitize(str)
        local result, _ = str:gsub('(%d+)', function (d) return string.format('%12s', d) end)
        return result
    end

    return digitize(a) < digitize(b)
end

-- Function to list files
function FileListView.list_gtd_files(filter_text)
    local gtd_path = vim.fn.expand('~/gtd/')  -- Expands to the full path
    local files = vim.fn.readdir(gtd_path)  -- Reads the directory

    -- Sort the files naturally
    table.sort(files, naturalSort)

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Setup the view filter.
    Filter.set_filter(filter_text)

    -- Add each file as a line in the buffer
    for _, file in ipairs(files) do
        local file_path = gtd_path .. file
        if not file:match("^item") or not Filter.file_passes_filter(file_path) then
            goto continue
        end

        local first_line = FileListView.get_first_line(file_path)
        local display_line = file .. " [" .. first_line .. "]"
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {display_line})

        ::continue::
    end

    -- Open the buffer in a new window
    vim.api.nvim_set_current_buf(buf)

    -- ... code to fill buffer with file names ...
    FileListView.setup_file_list_syntax(buf)

    FileListView.set_keybindings(buf)
end

-- Function to get the first line of a file
function FileListView.get_first_line(file_path)
    local file = io.open(file_path, "r")
    if file then
        local first_line = file:read()
        file:close()
        return first_line or ""
    else
        return ""
    end
end

function FileListView.setup_file_list_syntax(buf)
    vim.api.nvim_buf_set_option(buf, 'syntax', 'on')
    vim.api.nvim_command('syntax clear')

    -- Define syntax matches
    vim.api.nvim_buf_call(buf, function()
        vim.cmd('syntax match GTDFileName /^.*\\.gtd/ containedin=ALL')
        vim.cmd('syntax match GTDBrackets /\\[.*\\]/ containedin=ALL')
        vim.cmd('syntax match GTDFirstLine /\\] .* \\[/ contained')
    end)

    -- Set the colors
    vim.api.nvim_command('highlight GTDFileName guifg=#707070 ctermfg=244')
    vim.api.nvim_command('highlight GTDFirstLine guifg=#61afef ctermfg=75')
    vim.api.nvim_command('highlight GTDBrackets guifg=#f0f0f0 ctermfg=15')
end

function FileListView.set_keybindings(buf)
    -- Set keybinding for opening files
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':lua require("gtd.file_list_view").open_file()<CR>', {noremap = true, silent = true})

     -- Keybinding for creating a new file
    vim.api.nvim_buf_set_keymap(buf, 'n', 'n', ':lua require("gtd.file_list_view").create_new_file()<CR>', {noremap = true, silent = true})
end

function FileListView.open_file()
    local line = vim.fn.getline('.')
    -- Extract the filename part from the line (assuming the filename ends with '.gtd')
    local filename = line:match("^(.-)%.gtd")
    if filename then
        local file_path = vim.fn.expand('~/gtd/' .. filename .. '.gtd')
        vim.cmd('edit ' .. file_path)
    else
        -- Handle error or invalid line format
        print("Invalid line format. Could not extract filename.")
    end
end

function FileListView.create_new_file()
    local gtd_path = vim.fn.expand('~/gtd/')
    local files = vim.fn.readdir(gtd_path)
    local max_num = 0

    -- Find the highest number used so far
    for _, file in ipairs(files) do
        local num = file:match("item(%d+)%.gtd")
        if num then
            num = tonumber(num)
            max_num = math.max(max_num, num)
        end
    end

    -- Create the new file name
    local new_file_num = max_num + 1
    local new_file_path = gtd_path .. "item" .. new_file_num .. ".gtd"

    -- Create and open the new file
    vim.cmd('edit ' .. new_file_path)
end

return FileListView

