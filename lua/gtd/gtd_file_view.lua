local GtdFileView = {}

function GtdFileView.setup_gtd_file(buf)
    GtdFileView.setup_gtd_file_syntax()
    GtdFileView.setup_gtd_keybindings(buf)
end

function GtdFileView.setup_gtd_keybindings(buf)
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':lua require("gtd.gtd_file_view").open_link()<CR>', {noremap = true, silent = true})
end

function GtdFileView.setup_gtd_file_syntax()
    -- Clear any existing syntax
    vim.api.nvim_command('syntax clear')

    -- Set the default text color
    vim.api.nvim_command('highlight Normal guifg=#ffffff guibg=none ctermfg=white ctermbg=none')

    -- Define syntax rules
    vim.api.nvim_command('syntax region GTDTitle start="^\\%1l" end="^.*$"')
    vim.api.nvim_command('syntax match GTDTags "@\\S\\+"')
    vim.api.nvim_command('syntax match GTDLink "\\v!\\w+\\d+\\.gtd\\[([^\\]]+)\\]"')

    -- ... highlight group definitions ...
    vim.api.nvim_command('highlight GTDTitle guifg=#faa719 ctermfg=214 gui=bold cterm=bold')
    vim.api.nvim_command('highlight GTDTags guifg=#8553c7 ctermfg=140')
    vim.api.nvim_command('highlight GTDLink guifg=#8eb9ed ctermfg=117')

    -- Define common end pattern
    local endPattern = "\\ze\\(\\(^\\s*[-✓^]\\)\\|\\(^\\s*$\\)\\)"

    -- Highlighting for Todo Items
    vim.api.nvim_command('syntax region GTDTodo start="^\\s*- " end="' .. endPattern .. '" contains=GTDLink')
    vim.api.nvim_command('highlight GTDTodo guifg=#ffffff guibg=#1C1C1C ctermfg=214')

    -- Highlighting for Completed Items
    vim.api.nvim_command('syntax region GTDDone start="^\\s*✓ " end="' .. endPattern .. '"')
    vim.api.nvim_command('highlight GTDDone guifg=#808080 guibg=none gui=strikethrough ctermfg=green ctermbg=none cterm=strikethrough')

    -- Highlighting for Notes
    vim.api.nvim_command('syntax region GTDNote start="^\\s*\\^ " end="' .. endPattern .. '" contains=GTDLink')
    vim.api.nvim_command('highlight GTDNote guifg=#8553c7 guibg=#1C1C1C ctermfg=214 gui=italic cterm=italic')
end

function GtdFileView.open_link()
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

return GtdFileView

