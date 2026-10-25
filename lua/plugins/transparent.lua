-- Fundo transparente do Neovim, pra casar com o Ghostty translúcido.
-- O colorscheme padrão do LazyVim é o tokyonight, que tem suporte nativo.

-- rede de segurança: zera o bg de grupos que o tema às vezes não cobre,
-- sempre que um colorscheme é (re)carregado.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    for _, g in ipairs({
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "MsgArea",
      "EndOfBuffer",
    }) do
      vim.api.nvim_set_hl(0, g, { bg = "none" })
    end
  end,
})

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
}
