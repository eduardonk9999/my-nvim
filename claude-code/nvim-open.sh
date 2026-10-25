#!/bin/bash
# Claude Code PostToolUse hook (Read|Edit|Write|NotebookEdit):
# abre no Neovim o arquivo que o Claude acabou de ler/editar.
# Descobre a instância nvim certa pelos sockets automáticos que o nvim cria,
# preferindo a que tem getcwd() contendo o arquivo. Se só houver uma viva,
# usa ela mesmo sem match de diretório.

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -z "$file" ] || [ ! -f "$file" ] && exit 0

# não abrir binários no nvim (o Read do Claude também lê imagens/PDFs)
case "${file##*.}" in
  png|jpg|jpeg|gif|webp|ico|pdf|zip|gz|tar|woff|woff2|ttf|eot|mp4|mp3|ipynb) exit 0 ;;
esac

# Bases onde o nvim cria o socket automático (varia por SO/sessão):
#   macOS: $TMPDIR/nvim.$USER/<rand>/nvim.<pid>.0
#   Linux: $XDG_RUNTIME_DIR/nvim.$USER/...  ou  /tmp/nvim.$USER/...
bases=()
[ -n "$TMPDIR" ] && bases+=("${TMPDIR%/}/nvim.$USER")
[ -n "$XDG_RUNTIME_DIR" ] && bases+=("${XDG_RUNTIME_DIR%/}/nvim.$USER")
bases+=("/tmp/nvim.$USER")

live_socks=()
match_sock=""

for base in "${bases[@]}"; do
  for sock in "$base"/*/nvim.*.0; do
    [ -S "$sock" ] || continue
    cwd=$(nvim --server "$sock" --remote-expr 'getcwd()' 2>/dev/null) || continue
    [ -z "$cwd" ] && continue
    live_socks+=("$sock")
    case "$file" in
      "$cwd"/*) match_sock="$sock"; break 2 ;;
    esac
  done
done

if [ -z "$match_sock" ]; then
  [ "${#live_socks[@]}" -eq 1 ] && match_sock="${live_socks[0]}"
fi
[ -z "$match_sock" ] && exit 0

nvim --server "$match_sock" --remote "$file" 2>/dev/null
# recarrega o buffer se já estava aberto (arquivo mudou no disco)
nvim --server "$match_sock" --remote-send '<Cmd>checktime<CR>' 2>/dev/null
exit 0
