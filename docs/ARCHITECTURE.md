# Architecture

devbox is one Ansible run in three plays (`devbox.yml`):

1. **Provision** (`localhost`) — `hetzner_provision` creates the SSH key, firewall,
   persistent volume and server via the `hetzner.hcloud` collection, waits for SSH, and
   hands the box to the next play with `add_host`. Skipped for `provider: existing`.
2. **Configure** (`devbox` group, over SSH as root) — the roles that turn a stock Ubuntu
   24.04 box into the devbox.
3. **Connect** (`localhost`) — `connect` writes the managed `~/.ssh/config` entry so
   `ssh <alias>` and `herdr --remote <alias>` work.

## Roles

| Role | Does |
|---|---|
| `hetzner_provision` | hcloud ssh_key + firewall + volume + server; power/teardown for `./stop`/`./start`/`./down`. |
| `persistent_home` | Mounts the Hetzner volume at `/home`, formatting **only** a fresh volume (never wipes existing data). Runs before the user is created so the home lands on the volume. |
| `base` | apt essentials, zsh + plugins + starship, the `devbox` user (uid pinned), sudo, SSH key, shell defaults, MOTD, unattended-upgrades. |
| `dev_tools` | Docker, Node 24, bun/uv, pnpm/yarn, gh/glab, nvim, psql/redis/mkcert/lazygit/ast-grep/yq. Toggle includes: `k8s` (kubectl/helm/k9s/kubeconform), `cloud` (terraform/packer). |
| `agent` | herdr, Claude Code, Codex, pi, ccstatusline, the Playwright CLI + Chrome + shared Playwright Chromium. Toggle: `features.agent`. |
| `dotfiles` | Seeds `.zshrc` / nvim (LazyVim) / Claude defaults / ccstatusline into the owner's home, seed-once. First-login walkthrough + `devbox-repos` helper. |
| `idle_stop` | systemd timers: idle-check (~2h → poweroff) + nightly agent-CLI refresh. |
| `connect` | Local `~/.ssh/config` block. |

## The pet/cattle split

Your `/home` is a **Hetzner volume** — a pet. The server (boot disk) is cattle. `./down`
deletes the server but keeps the volume; `./up` rebuilds the server and re-mounts the same
`/home`, so your work is intact. This is the same "home is sacred" model as the GCP original,
minus GCP.

## Bring your own server

Set `provider: existing`, add your host to `inventory/hosts.yml`, and only plays 2–3 run —
the configuration roles are provider-agnostic (they just need SSH to an Ubuntu 24.04 host).
`persistent_home` no-ops (your box's own disk holds `/home`).
