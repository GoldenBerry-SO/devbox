# Architecture

devbox is one Ansible run in three plays (`devbox.yml`):

1. **Provision** (`localhost`): `hetzner_provision` creates the SSH key, firewall,
   persistent volume and server via the `hetzner.hcloud` collection, waits for SSH, and
   hands the box to the next play with `add_host`. Skipped for `provider: existing`.
2. **Configure** (`devbox` group, over SSH as root): the roles that turn a stock Ubuntu
   24.04 box into the devbox.
3. **Connect** (`localhost`): `connect` writes the managed `~/.ssh/config` entry so
   `ssh <alias>` and `herdr --remote <alias>` work.

## Roles

| Role | Does |
|---|---|
| `hetzner_provision` | hcloud ssh_key + firewall + volume + server; power/teardown for `./stop`/`./start`/`./down`. |
| `persistent_home` | Mounts the Hetzner volume at `/home`, formatting **only** a fresh volume (never wipes existing data). Runs before the user is created so the home lands on the volume. |
| `base` | apt essentials, zsh + plugins + starship, the `devbox` user (uid pinned), sudo, SSH key, shell defaults, MOTD, unattended-upgrades. |
| `dev_tools` | Docker, Node 24, bun/uv, pnpm/yarn, gh/glab, nvim, psql/redis/mkcert/lazygit/ast-grep/yq. Toggle includes: `k8s` (kubectl/helm/k9s/kubeconform), `cloud` (terraform/packer). |
| `agent` | herdr, Claude Code, Codex, pi, graphify, ccstatusline. Toggle: `features.agent`. The Playwright CLI + Chrome + shared Playwright Chromium install as part of this same role, gated on the nested `features.browsers` (default on), so they need both toggles set to run. |
| `dotfiles` | Seeds `.zshrc` / nvim (LazyVim) / Claude defaults / ccstatusline into the owner's home, seed-once. First-login walkthrough + `devbox-repos` helper. |
| `idle_stop` | systemd timers: idle-check (~2h, then poweroff) and nightly agent-CLI refresh. One toggle, `features.idle_stop`, controls both. |
| `connect` | Local `~/.ssh/config` block. |

## The pet/cattle split

Your `/home` is a **Hetzner volume**, a pet. The server (boot disk) is cattle. `./down`
deletes the server but keeps the volume; `./up` rebuilds the server and re-mounts the same
`/home`, so your work is intact. This is the same "home is sacred" model as the GCP original,
minus GCP.

## Bring your own server

Set `provider: existing`, add your host to `inventory/hosts.yml`, and only plays 2-3 run: the
configuration roles are provider-agnostic, they just need root SSH to an Ubuntu host. The
provisioned image is 24.04, and that's the only version this repo is routinely exercised
against, though the roles account for at least one 22.04 difference (see the comment on the
apt-keyrings task in `roles/dev_tools/tasks/main.yml`). `persistent_home` no-ops on an existing
host, since your box's own disk already holds `/home`.
