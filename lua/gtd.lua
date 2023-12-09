local M = {}

vim.api.nvim_command([[ autocmd BufRead,BufNewFile *.gtd set filetype=gtd ]])
vim.api.nvim_command('autocmd FileType gtd lua require("gtd").setup_gtd_file(0)')

-- Function to list files
function M.list_gtd_files()
    local gtd_path = vim.fn.expand('~/gtd/')  -- Expands to the full path
    local files = vim.fn.readdir(gtd_path)  -- Reads the directory

    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Add each file as a line in the buffer
    for _, file in ipairs(files) do
        local file_path = gtd_path .. file
        local first_line = M.get_first_line(file_path)
        local display_line = file .. " [" .. first_line .. "]"
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {display_line})
    end

    -- Open the buffer in a new window
    vim.api.nvim_set_current_buf(buf)

    -- ... code to fill buffer with file names ...
    M.setup_file_list_syntax(buf)

    M.set_keybindings(buf)
end

function M.setup_file_list_syntax(buf)
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


function M.set_keybindings(buf)
    -- Set keybinding for opening files
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':lua require("gtd").open_file()<CR>', {noremap = true, silent = true})

     -- Keybinding for creating a new file
    vim.api.nvim_buf_set_keymap(buf, 'n', 'n', ':lua require("gtd").create_new_file()<CR>', {noremap = true, silent = true})
end

function M.setup_gtd_file()
    M.setup_gtd_file_syntax()
    M.setup_gtd_keybindings(buf)
end

function M.setup_gtd_keybindings(buf)
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':lua require("gtd").open_link()<CR>', {noremap = true, silent = true})
end

function M.setup_gtd_file_syntax()
    -- ... highlight group definitions ...
    vim.api.nvim_command('highlight GTDTitle guifg=#61afef ctermfg=75 gui=underline cterm=underline')
    vim.api.nvim_command('highlight GTDContent guifg=#f0f0f0 ctermfg=15')
    vim.api.nvim_command('highlight GTDTags guifg=#e5c07b ctermfg=215')
    vim.api.nvim_command('highlight GTDLink guifg=#ff6b6b ctermfg=167')

    -- Clear any existing syntax
    vim.api.nvim_command('syntax clear')

    -- Define syntax rules
    vim.api.nvim_command('syntax match GTDTitle "^.*$"')
    vim.api.nvim_command('syntax region GTDContent start="^$" end="^\\ze@\\w" keepend contains=GTDLink')
    vim.api.nvim_command('syntax match GTDTags "@\\S\\+"')
    vim.api.nvim_command('syntax match GTDLink "\\v!\\w+\\d+\\.gtd\\[([^\\]]+)\\]"')
end


function M.open_file()
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

function M.create_new_file()
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

-- Function to get the first line of a file
function M.get_first_line(file_path)
    local file = io.open(file_path, "r")
    if file then
        local first_line = file:read()
        file:close()
        return first_line or ""
    else
        return ""
    end
end

function M.open_link()
    local line = vim.fn.getline('.')
    local col = vim.fn.col('.') -- Get the cursor's column position
    local filename_regex = "[%w%d-_]*%.gtd"
    local link_regex = "!" .. filename_regex .. "%[[^[]*%]"

    for full_link in line:gmatch(link_regex) do
        local start, _end = line:find(full_link, 1, true)
        if start and start <= col and col <= _end then
            -- Extract the filename from the full link
            local filename = full_link:match("!(" .. filename_regex .. ")")
            if filename then
                local file_path = vim.fn.expand('~/gtd/' .. filename)
                vim.cmd('edit ' .. file_path)
                return
            end
        end
    end

    print("No valid link found under the cursor.")
end

return M

