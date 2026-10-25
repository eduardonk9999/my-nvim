#!/bin/bash
# Claude Code PostToolUse hook (Read|Edit|Write|NotebookEdit):
# abre no Neovim o arquivo que o Claude acabou de ler/editar.
# Descobre a instância nvim certa pelos sockets automáticos em /tmp/nvim.$USER/,
# preferindo a instância cujo getcwd() contém o arquivo. Se só houver uma
# instância viva, usa ela mesmo sem match de diretório.
#
# Instalação: copie para ~/.claude/hooks/nvim-open.sh e registre o hook
# em ~/.claude/settings.json (veja settings.example.json). Precisa de `jq`.

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -z "$file" ] || [ ! -f "$file" ] && exit 0

# não abrir binários no nvim (o Read do Claude também lê imagens/PDFs)
case "${file##*.}" in
  png|jpg|jpeg|gif|webp|ico|pdf|zip|gz|tar|woff|woff2|ttf|eot|mp4|mp3|ipynb) exit 0 ;;
esac

live_socks=()
match_sock=""

for sock in /tmp/nvim."$USER"/*/nvim.*.0; do
  [ -S "$sock" ] || continue
  cwd=$(nvim --server "$sock" --remote-expr 'getcwd()' 2>/dev/null) || continue
  [ -z "$cwd" ] && continue
  live_socks+=("$sock")
  case "$file" in
    "$cwd"/*) match_sock="$sock"; break ;;
  esac
done

if [ -z "$match_sock" ]; then
  [ "${#live_socks[@]}" -eq 1 ] && match_sock="${live_socks[0]}"
fi
[ -z "$match_sock" ] && exit 0

nvim --server "$match_sock" --remote "$file" 2>/dev/null
# recarrega o buffer se já estava aberto (arquivo mudou no disco)
nvim --server "$match_sock" --remote-send '<Cmd>checktime<CR>' 2>/dev/null
exit 0
