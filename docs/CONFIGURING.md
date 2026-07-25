# Configuring

Everything lives in `config.yml` (copied from `config.example.yml`, gitignored). Any key
overrides the defaults in `group_vars/all.yml`.

## Required
- `hcloud_token` — Hetzner API token. Prefer the env form: `export HCLOUD_TOKEN=...`.
- `ssh_public_key_file` / `ssh_private_key_file` — your keypair.

## Box
- `server_type` — `cpx41` (8 vCPU / 16 GB, default) · `cpx51` (16 vCPU / 32 GB) · any hcloud type.
- `location` — `nbg1`/`fsn1`/`hel1` (EU) · `ash`/`hil` (US).
- `volume_size` — GB for the persistent `/home` (default 100).
- `server_name` — names the server, volume (`<name>-home`), firewall, key.

## Access
- `allow_ssh_from` — `auto` (your current public IP/32, default) · a CIDR list · `0.0.0.0/0`.
- `devbox_user` — the login user (default `dev`).
- `ssh_host_alias` — the `Host` written to `~/.ssh/config` (default `devbox`).

## Features (all default on except `cloud`)
- `agent` — herdr + Claude Code + Codex + Chrome + Playwright.
- `k8s` — kubectl + helm + k9s + kubeconform.
- `cloud` — terraform + packer.
- `browsers` — Chrome + Playwright (implied by `agent`).
- `idle_stop` — power off after ~2h idle.
- `dotfiles` — seed the shell/editor/agent config.

## Repos
`repos:` is a list of git URLs cloned into `~/Src` by `devbox-repos` at first login (needs
your `gh`/SSH auth). Empty by default.

## Cost note (Hetzner vs GCP)
A **powered-off** Hetzner server is still billed — only traffic stops. For real savings when
you won't use the box for a while, `./down` deletes the server and keeps the volume; `./up`
rebuilds it (~10 min) with your `/home` intact. `idle_stop`'s poweroff is about not running an
idle machine, not about cost — flip it off if you'd rather leave the box up.
