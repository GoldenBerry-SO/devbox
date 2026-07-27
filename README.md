# devbox

**Your laptop can sleep. Your agents don't.**

One command spins up a personal, always-on Linux dev box on [Hetzner Cloud](https://www.hetzner.com/cloud) —
fully loaded and gorgeous out of the box: `zsh` + `starship` + Neovim (LazyVim), Docker,
Node, the whole modern CLI toolchain, headless Chrome, and an AI-agent stack
([herdr](https://herdr.dev), Claude Code, Codex, pi) so your agents keep working while your
laptop is closed.

It's driven by **Ansible** against stock Ubuntu 24.04 — no image to bake, no lock-in. Your
`/home` lives on a persistent volume, so you can rebuild the box and keep every byte of your
work.

```bash
git clone https://github.com/GoldenBerry-SO/devbox && cd devbox
cp config.example.yml config.yml     # set your Hetzner token + SSH key
./up                                  # ~10 min later:
ssh devbox                            # …you're in.
herdr --remote devbox                 # start an agent that outlives your laptop
```

## What you get

- **A beautiful shell**: zsh with autosuggestions, syntax highlighting, history-substring
  search, vi keybindings, [starship](https://starship.rs) prompt, zoxide, direnv, `eza`/`bat`/`fd`/`ripgrep`/`fzf`.
- **Editor**: Neovim (latest) preconfigured with LazyVim.
- **Containers**: Docker CE + compose + buildx.
- **Languages & runtimes**: Node 24, `bun`, `uv`, pnpm, yarn (via corepack).
- **Agent stack** *(toggle: `agent`)*: herdr, Claude Code, Codex, pi, ccstatusline, plus the
  Playwright CLI + Chrome + Playwright Chromium in a shared cache for headless browser testing
  and a preconfigured chrome-devtools MCP.
- **Cloud/K8s tooling** *(toggle: `k8s`)*: kubectl, helm, k9s, kubeconform, yq.
- **Dev niceties**: `gh`, `glab`, `lazygit`, `git-extras`, `mkcert`, `psql`, `redis-cli`,
  `sqlite3`, `htop`, `tmux` (with a 4-pane `t` helper).
- **Persistent `/home`** on a Hetzner volume — rebuild the server, keep your work.
- **Idle-stop** *(toggle)*: powers the box off after ~2h of genuine idle; `./start` wakes it.
- **Unattended security upgrades** + a nightly refresh of the agent CLIs.

Everything is a toggle in `config.yml`, but the defaults are meant to be *the* experience.

## Requirements

- A Hetzner Cloud account + an **API token** (Project → Security → API Tokens, read/write).
- Ansible 2.15+ and the `hcloud` Python SDK on your machine (the `./up` wrapper checks and
  guides you).
- An SSH keypair.

## Design principles

1. **No shared credentials, ever.** Nothing is pre-authenticated. You log into `gh`, `git`,
   your agents as *you*, at first login. CI fails if a secret is ever committed to this repo.
2. **`/home` is sacred.** It's a separate volume, untouched by rebuilds. Boot disk = cattle,
   home = pet.
3. **SSH is the only door.** Key auth, firewall-locked. herdr and everything else ride on it.
4. **Opinionated defaults, modular underneath.** It's beautiful with zero config, but every
   group is a switch.
5. **Bring your own server.** Point it at any existing Ubuntu host (skip the Hetzner role) and
   it configures that instead.

## Commands

| Command | What it does |
|---|---|
| `./up` | Create (or update) the box, configure everything, wire up `ssh devbox`. |
| `./start` / `./stop` | Power the box on / off (persists the server). |
| `./down` | Delete the **server** but keep the volume (`--purge` also deletes the volume). |
| `./doctor` | SSH in and report what's installed and what still needs your personal auth. |

## Docs

- [docs/CONFIGURING.md](docs/CONFIGURING.md) — every knob in `config.yml`.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — how the roles map onto the box.
- [docs/SECURITY.md](docs/SECURITY.md) — the access & credential model.

## License

MIT. This is a give-away — fork it, theme it, make it yours.
