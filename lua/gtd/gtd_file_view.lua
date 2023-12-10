local GtdFileView = {}

function GtdFileView.setup_gtd_file(buf)
    GtdFileView.setup_gtd_file_syntax()
    GtdFileView.setup_gtd_keybindings(buf)
end

function GtdFileView.setup_gtd_keybindings(buf)
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':lua require("gtd.gtd_file_view").open_link()<CR>', {noremap = true, silent = true})
end

function GtdFileView.setup_gtd_file_syntax()
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

