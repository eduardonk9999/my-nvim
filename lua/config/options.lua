-- Options are automatically loaded before lazy.nvim startup
-- Default LazyVim options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
local opt = vim.opt

opt.relativenumber = true
opt.wrap = false
opt.scrolloff = 6
opt.confirm = true

-- notas de recon ficam legiveis (markdown)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = false
  end,
})
