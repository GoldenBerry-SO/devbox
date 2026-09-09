# devbox

**Your laptop can sleep. Your agents don't.**

One command spins up a personal, always-on Linux dev box on [Hetzner Cloud](https://www.hetzner.com/cloud):
a stock Ubuntu 24.04 server, fully configured with a modern shell, editor, container runtime,
language toolchains and an AI-agent stack, so your coding agents keep working while your laptop
is closed.

It's driven by **Ansible** against stock Ubuntu, no custom image to bake, no lock-in. Your
`/home` lives on a separate persistent volume, so you can delete and rebuild the server itself
and keep every byte of your work.

```bash
git clone https://github.com/GoldenBerry-SO/devbox && cd devbox
cp config.example.yml config.yml     # set your Hetzner token + SSH key
./up                                  # ~10 min later:
ssh devbox                            # …you're in.
herdr --remote devbox                 # start an agent that outlives your laptop
```

## What you get

The box is a stock **Ubuntu 24.04** Hetzner Cloud server (`cpx41`, 8 vCPU / 16 GB, by default)
with a persistent volume mounted at `/home`. Ansible then installs and configures:

- **A beautiful shell**: zsh with autosuggestions, syntax highlighting, history-substring
  search, vi keybindings, [starship](https://starship.rs) prompt, zoxide, direnv,
  `eza`/`bat`/`fd`/`ripgrep`/`fzf`.
- **Editor**: Neovim (latest) preconfigured with LazyVim.
- **Containers**: Docker CE + compose + buildx.
- **Languages & runtimes**: Node 24, `bun`, `uv`, pnpm, yarn (via corepack).
- **Agent stack** *(toggle: `agent`)*: [herdr](https://herdr.dev), Claude Code, Codex, pi,
  graphify, ccstatusline, plus the Playwright CLI + Chrome + a shared Playwright Chromium cache
  for headless browser testing, and a preconfigured `chrome-devtools` MCP server for the agents.
- **Kubernetes tooling** *(toggle: `k8s`)*: kubectl, helm, k9s, kubeconform.
- **Cloud/IaC tooling** *(toggle: `cloud`, off by default)*: terraform, packer.
- **Dev niceties** (always installed): `gh`, `glab`, `lazygit`, `git-extras`, `mkcert`, `psql`,
  `redis-cli`, `sqlite3`, `yq`, `ast-grep`, `jq`, `htop`, `tmux` (with a 4-pane `t` helper).
- **Persistent `/home`** on a Hetzner volume, rebuild the server, keep your work.
- **Idle-stop** *(toggle)*: powers the box off after ~2h of genuine idle (no SSH session, no
  agent process, low load); `./start` wakes it. The same toggle also drives a nightly refresh of
  the agent CLIs, see [Updating](#updating-the-box) below.
- Unattended OS security upgrades.

Everything is a toggle in `config.yml`, but the defaults are meant to be *the* experience. See
[docs/CONFIGURING.md](docs/CONFIGURING.md) for every knob.

## Prerequisites

- A Hetzner Cloud account and an **API token** (Project → Security → API Tokens, read/write).
  `config.yml` reads it from the `HCLOUD_TOKEN` environment variable by default, so the token
  itself never has to live on disk.
- **Ansible** on your machine, plus the `hcloud` Python SDK; `./up` checks for both and installs
  the SDK for you if it's missing. (The repo targets a reasonably current Ansible; it isn't
  pinned to a specific minimum version here.)
- An **SSH keypair** (defaults to `~/.ssh/id_ed25519` / `.pub`). The public half is installed on
  the box; the private half connects you to it afterwards.

## What `./up` does

`./up` is a thin wrapper: it checks your local tooling, then runs `ansible-playbook devbox.yml`.
That playbook is one Ansible run in three plays:

1. **Provision** (on your machine): creates the Hetzner SSH key, firewall, persistent volume and
   server, and waits for SSH to come up. Skipped entirely if `provider: existing` (see
   [Bring your own server](#bring-your-own-server)).
2. **Configure** (over SSH, as root): mounts the persistent volume at `/home`, creates the
   `devbox` user, and installs everything in [What you get](#what-you-get) above, one Ansible
   role per area. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full role breakdown.
3. **Connect** (on your machine): writes a managed `Host devbox` block into your `~/.ssh/config`
   and prints the connect commands.

`./up` is idempotent: rerun it any time (after editing `config.yml`, or after pulling role
changes in this repo) to bring the box up to date.

## Using the box

Once `./up` finishes:

- `ssh devbox` gets you a shell.
- `herdr --remote devbox` starts an agent session that keeps running after you close your
  laptop.
- `./doctor` SSHes in and reports what's installed and what still needs your personal login.

The first time you log in, a one-time walkthrough prints the handful of things that need *your*
identity, since nothing on the box is pre-authenticated: `gh auth login`, your git
name/email, joining the `docker` group, and logging in to whichever agent CLI you use. If you
listed `repos:` in `config.yml`, it also points you at `devbox-repos`, which clones them into
`~/Src`.

## Updating the box

- **Config or role changes**: edit `config.yml` (or this repo) and rerun `./up`. It only changes
  what's different.
- **Agent CLIs** (Claude Code, Codex, pi, graphify, the Playwright CLI): refreshed automatically
  every night by a systemd timer, as long as `features.idle_stop` is on (that toggle installs
  both the idle-poweroff timer and this refresh timer, see
  [docs/CONFIGURING.md](docs/CONFIGURING.md)). Turning `idle_stop` off also turns off the nightly
  refresh; rerun `./up` to pick up new CLI versions in that case.
- **OS security patches**: unattended-upgrades, always on.

## Tearing down

| Command | What it does |
|---|---|
| `./up` | Create (or update) the box, configure everything, wire up `ssh devbox`. |
| `./start` / `./stop` | Power the box on / off (server and volume both persist). |
| `./down` | Delete the **server** but keep the volume (your `/home`). `./down --purge` also deletes the volume: it asks you to type `destroy` to confirm first, since that's permanent data loss. |
| `./doctor` | SSH in and report what's installed and what still needs your personal auth. |

## Costs

Hetzner charges for a server simply existing, not only for it running: a **powered-off** server
(`./stop`) still costs the same as a running one, only its network traffic stops. If you won't touch the box
for a while, `./down` (no `--purge`) deletes the server and keeps the volume, then `./up` rebuilds
it in about the same ~10 minutes with your `/home` intact. `idle_stop`'s auto-poweroff exists to
avoid leaving a machine running idle, not to save money by itself: see
[docs/CONFIGURING.md](docs/CONFIGURING.md) for the full cost note. This repo does not state a
dollar figure for any server type; check current Hetzner pricing for that.

## Bring your own server

Set `provider: existing` in `config.yml`, add your host to `inventory/hosts.yml` (copy
`inventory/hosts.yml.example`), and only the Configure and Connect plays run. The configuration
roles are provider-agnostic and just need root SSH to an Ubuntu host (built and routinely tested
against 24.04). `persistent_home` no-ops, since your box's own disk already holds `/home`.

## Design principles

1. **No shared credentials, ever.** Nothing is pre-authenticated. You log into `gh`, `git`,
   your agents as *you*, at first login. CI fails if a secret is ever committed to this repo.
2. **`/home` is sacred.** It's a separate volume, untouched by rebuilds. Boot disk is cattle,
   home is pet.
3. **SSH is the only door.** Key auth, firewall-locked. herdr and everything else ride on it.
4. **Opinionated defaults, modular underneath.** It's beautiful with zero config, but every
   group is a switch.
5. **Bring your own server.** Point it at any existing Ubuntu host (skip the Hetzner role) and
   it configures that instead.

## Developing this repo

There's no test harness that provisions a real server: this repo only ever gets exercised against
real Hetzner infrastructure and real SSH targets, which isn't something CI (or a docs pass) should
do automatically. CI (`.github/workflows/ci.yml`) runs on every push and pull request against
`main` and covers two things:

- `yamllint -c yamllint.yml .` and `ansible-lint` (config in `yamllint.yml` / `.ansible-lint`).
- The `no-secrets` job, which refuses any commit containing a token-shaped string, a real
  `config.yml`, or a private key.

Two more checks are useful locally but not wired into CI, so run them yourself before pushing:

- `ansible-playbook devbox.yml --syntax-check` catches structural mistakes without touching
  any host.
- `shellcheck` on the top-level scripts (`up`, `start`, `stop`, `down`, `doctor`) and the files
  under `roles/*/files/`.

Anything that needs a live box (the actual provisioning, the systemd timers firing, first login)
has to be checked by hand against a real box.

## Docs

- [docs/CONFIGURING.md](docs/CONFIGURING.md): every knob in `config.yml`.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): how the roles map onto the box.
- [docs/SECURITY.md](docs/SECURITY.md): the access & credential model.

## License

MIT. This is a give-away, fork it, theme it, make it yours.
