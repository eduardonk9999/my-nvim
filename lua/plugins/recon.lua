-- Rótulos do which-key pros grupos do workbench (os atalhos em si ficam
-- em lua/config/recon.lua, carregado via keymaps.lua).
return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>r", group = "recon", icon = { icon = "", color = "green" } },
        { "<leader>a", group = "ai / claude", icon = { icon = "", color = "orange" } },
      },
    },
  },
}
