#!/bin/sh
# shellcheck disable=SC2059
# devbox first-login walkthrough. Runs once per user (marker file). Everything
# here authenticates YOU personally — no credentials are shared or preinstalled.
[ -n "${DEVBOX_SKIP_FIRST_LOGIN:-}" ] && exit 0
MARKER="$HOME/.devbox-initialized"
# Executed (not sourced) by the rc hooks, so "$-" has no 'i' — test the terminal.
[ -t 0 ] || exit 0

mkdir -p "$HOME/screenshots" "$HOME/Src" "$HOME/.local/bin"

[ -f "$MARKER" ] && exit 0

C="\033[0;36m"; B="\033[1m"; R="\033[0m"
printf "\n${B}Welcome to your devbox — first-login setup${R}\n"
printf "Runs once. Everything below authenticates ${B}you${R}; nothing is shared or preinstalled.\n"
printf "This box has no display: each step prints a URL or code to open on your laptop.\n\n"
printf "  ${C}1.${R} GitHub:   gh auth login        (HTTPS, then \"paste an authentication code\")\n"
printf "  ${C}2.${R} Git id:   git config --global user.name  \"Your Name\"\n"
printf "             git config --global user.email you@example.com\n"
printf "  ${C}3.${R} Docker without sudo (takes effect next login):\n"
printf "             sudo gpasswd -a \$(whoami) docker\n"
printf "  ${C}4.${R} Agents:   claude   /   codex     (open the printed URL on your laptop)\n"
if [ -s /etc/devbox/repos ]; then
printf "  ${C}5.${R} Clone your repos into ~/Src:   devbox-repos\n"
fi
printf "\nStart an agent that outlives your laptop:  ${B}herdr${R}\n"
printf "Run ${B}devbox-init-done${R} to dismiss this message.\n\n"

if [ ! -e "$HOME/.local/bin/devbox-init-done" ]; then
    printf '#!/bin/sh\ntouch "$HOME/.devbox-initialized"\necho "devbox setup marked complete. Happy shipping!"\n' > "$HOME/.local/bin/devbox-init-done"
    chmod +x "$HOME/.local/bin/devbox-init-done"
fi
