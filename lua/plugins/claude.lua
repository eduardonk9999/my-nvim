-- Claude Code dentro do Neovim (integração IDE via WebSocket/MCP).
-- Usa o `claude` CLI que você já tem instalado. <leader>a* = AI/Claude.
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" }, -- terminal provider (já vem no LazyVim)
  config = true,
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeStatus",
  },
  keys = {
    { "<leader>a", nil, desc = "AI / Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude: abrir/toggle" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focar janela" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: retomar sessão" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continuar última" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: escolher modelo" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: mandar buffer atual" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: mandar seleção" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Claude: mandar arquivo (tree)",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "snacks_picker_list" },
    },
    -- aceitar/rejeitar diffs que o Claude propõe
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: aceitar diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: rejeitar diff" },
  },
}
