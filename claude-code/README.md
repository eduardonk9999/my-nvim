# Integração Claude Code + Neovim (fluxo Ghostty)

Fluxo de trabalho: Ghostty com dois splits lado a lado — Neovim num,
Claude Code (CLI) no outro. Quando o Claude lê ou edita um arquivo, ele
**abre sozinho no Neovim do lado**, pra você acompanhar o que ele está fazendo.

Isto aqui é config do **Claude Code** (mora em `~/.claude/`), guardada neste
repo ao lado da config do Neovim por conveniência. Não é um plugin de nvim.

## O que tem aqui

- `nvim-open.sh` — hook `PostToolUse`. Recebe o caminho do arquivo que o Claude
  tocou, acha a instância nvim viva pelos sockets automáticos que o nvim cria
  (procura em `$TMPDIR/nvim.$USER/`, `$XDG_RUNTIME_DIR/nvim.$USER/` e
  `/tmp/nvim.$USER/` — no macOS é o `$TMPDIR`), preferindo a que tem `getcwd()`
  compatível com o arquivo, e abre via `nvim --server <socket> --remote`, mais
  um `:checktime` pra recarregar o buffer se já estava aberto. Ignora binários
  (imagens, PDF, zip, fontes).
- `settings.example.json` — o bloco `hooks` que registra o script.

## Instalação

1. Copie o script e dê permissão de execução:

   ```bash
   mkdir -p ~/.claude/hooks
   cp claude-code/nvim-open.sh ~/.claude/hooks/nvim-open.sh
   chmod +x ~/.claude/hooks/nvim-open.sh
   ```

2. Mescle o bloco `hooks` de `settings.example.json` no seu
   `~/.claude/settings.json` (sem apagar o resto do arquivo).

3. Precisa do `jq` no PATH (`brew install jq`). O Neovim ≥ 0.10 já cria o
   socket RPC sozinho — nada a mudar no `init.lua`.

## Uso

1. No Ghostty, abra dois splits na raiz do projeto:

   ```bash
   nvim          # split esquerdo
   claude        # split direito
   ```

2. Peça algo ao Claude. Assim que ele ler/editar um arquivo, o Neovim pula
   pra ele.

### "abra o projeto X"

Se você quiser que o Claude abra um projeto no nvim do lado, adicione ao seu
`~/.claude/CLAUDE.md` uma instrução para ele rodar, no socket vivo:

```bash
nvim --server <socket> --remote-send '<Cmd>cd ~/Documents/jobs/X<CR><Cmd>e .<CR>'
```

(`:e .` abre o explorer na raiz). Para só abrir um arquivo sem editar:
`nvim --server <socket> --remote <arquivo>`.

## Notas

- Sessões do `claude` já abertas **antes** de instalar o hook precisam ser
  reiniciadas para carregá-lo.
- Abra o `nvim` na **raiz do projeto**; é por `getcwd()` que o hook decide
  qual instância usar quando há mais de uma aberta.
- O matcher inclui `Read`, então o nvim também troca de buffer quando o Claude
  só está explorando o código. Se incomodar, troque o matcher para
  `Edit|Write|NotebookEdit` em `settings.json`.
