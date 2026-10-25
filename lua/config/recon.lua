-- Camada de recon/scan do workbench de bug bounty.
-- Workspace em ~/Documents/bb-recon (um dir por alvo em targets/<dominio>).
-- Comandos: :ReconNew <dom>  :Recon [dom]  :ReconOpen
-- Atalhos (<leader>r): n=novo  r=rodar  o=abrir  t=terminal  w=workspace
local M = {}

M.workspace = vim.fn.expand("~/Documents/bb-recon")
M.script = M.workspace .. "/recon.sh"
M.last = nil

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "recon" })
end

-- terminal em split inferior rodando um comando
local function term(cmd)
  vim.cmd("botright split")
  vim.cmd("resize 18")
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end

local function target_dir(domain)
  return M.workspace .. "/targets/" .. domain
end

-- cria o scaffold de um alvo e abre as notas
function M.new(domain)
  domain = (domain or ""):gsub("%s+", "")
  if domain == "" then
    return notify("informe um domínio", vim.log.levels.WARN)
  end
  M.last = domain
  local dir = target_dir(domain)
  vim.fn.mkdir(dir, "p")
  local scope = dir .. "/scope.txt"
  if vim.fn.filereadable(scope) == 0 then
    vim.fn.writefile({ domain, "*." .. domain }, scope)
  end
  local notes = dir .. "/notes.md"
  if vim.fn.filereadable(notes) == 0 then
    vim.fn.writefile({
      "# Recon — " .. domain,
      "",
      "- iniciado: " .. os.date("%Y-%m-%d %H:%M"),
      "- escopo: ver `scope.txt`",
      "",
      "## Hosts vivos (de alive.txt)",
      "",
      "## Endpoints interessantes (de urls.txt)",
      "",
      "## Achados (nuclei / manual)",
      "",
      "## Próximos passos",
      "- [ ] revisar alive.txt (titulo / tech / status)",
      "- [ ] fuzzar dirs nos hosts vivos (ffuf / gobuster)",
      "- [ ] revisar nuclei.txt",
      "- [ ] escolher alvos e mandar pro Caido (Send to Replay)",
      "",
    }, notes)
  end
  vim.cmd("edit " .. vim.fn.fnameescape(notes))
  vim.cmd("cd " .. vim.fn.fnameescape(dir))
  notify("alvo pronto: " .. dir)
end

-- roda o pipeline (subfinder -> dnsx -> httpx -> katana/gau -> nuclei)
function M.run(domain)
  domain = (domain or M.last or ""):gsub("%s+", "")
  if domain == "" then
    return notify("informe um domínio (ou crie um alvo antes)", vim.log.levels.WARN)
  end
  if vim.fn.filereadable(M.script) == 0 then
    return notify("script nao encontrado: " .. M.script, vim.log.levels.ERROR)
  end
  M.last = domain
  term("bash " .. vim.fn.shellescape(M.script) .. " " .. vim.fn.shellescape(domain))
end

-- abre o workspace (picker se disponivel, senao netrw)
function M.open()
  local ok = pcall(function()
    require("snacks").picker.files({ cwd = M.workspace })
  end)
  if ok then
    return
  end
  ok = pcall(function()
    require("telescope.builtin").find_files({ cwd = M.workspace })
  end)
  if not ok then
    vim.cmd("edit " .. vim.fn.fnameescape(M.workspace))
  end
end

-- terminal do shell no workspace (ou no alvo atual, se cwd estiver nele)
function M.shell()
  local cwd = vim.fn.getcwd()
  local dir = cwd:find(M.workspace, 1, true) and cwd or M.workspace
  vim.cmd("botright split")
  vim.cmd("resize 18")
  vim.cmd("terminal")
  vim.cmd("startinsert")
  vim.fn.chansend(vim.b.terminal_job_id, "cd " .. vim.fn.shellescape(dir) .. " && clear\n")
end

local function input(prompt, default, cb)
  vim.ui.input({ prompt = prompt, default = default or "" }, function(v)
    if v and v ~= "" then
      cb(v)
    end
  end)
end

function M.setup()
  vim.fn.mkdir(M.workspace .. "/targets", "p")

  vim.api.nvim_create_user_command("ReconNew", function(o)
    M.new(o.args)
  end, { nargs = 1, desc = "scaffold de um novo alvo de recon" })

  vim.api.nvim_create_user_command("Recon", function(o)
    M.run(o.args)
  end, { nargs = "?", desc = "roda o pipeline de recon no alvo" })

  vim.api.nvim_create_user_command("ReconOpen", function()
    M.open()
  end, { nargs = 0, desc = "abre o workspace de recon" })

  local map = vim.keymap.set
  map("n", "<leader>rn", function()
    input("novo alvo (dominio): ", M.last, M.new)
  end, { desc = "recon: novo alvo" })
  map("n", "<leader>rr", function()
    input("rodar recon em: ", M.last, M.run)
  end, { desc = "recon: rodar pipeline" })
  map("n", "<leader>ro", M.open, { desc = "recon: abrir workspace" })
  map("n", "<leader>rt", M.shell, { desc = "recon: terminal no workspace" })
  map("n", "<leader>rw", function()
    vim.cmd("edit " .. vim.fn.fnameescape(M.workspace))
  end, { desc = "recon: explorar workspace" })
end

return M
