local M = {}

vim.api.nvim_command([[ autocmd BufRead,BufNewFile *.gtd set filetype=gtd ]])
vim.api.nvim_command('autocmd FileType gtd lua require("gtd.gtd_file_view").setup_gtd_file(0)')

return M

