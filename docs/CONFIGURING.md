# Configuring

Everything lives in `config.yml` (copied from `config.example.yml`, gitignored). Any key
overrides the defaults in `group_vars/all.yml`.

## Required
- `hcloud_token`: Hetzner API token. Prefer the env form: `export HCLOUD_TOKEN=...`.
- `ssh_public_key_file` / `ssh_private_key_file`: your keypair.

## Box
- `server_type`: `cpx41` (8 vCPU / 16 GB, default), `cpx51` (16 vCPU / 32 GB), or any hcloud type.
- `location`: `nbg1`/`fsn1`/`hel1` (EU), `ash`/`hil` (US).
- `volume_size`: GB for the persistent `/home` (default 100).
- `server_name`: names the server, volume (`<name>-home`), firewall, key.

## Access
- `allow_ssh_from`: `auto` (your current public IP/32, default), a CIDR list, or `0.0.0.0/0`.
- `devbox_user`: the login user (default `dev`).
- `ssh_host_alias`: the `Host` written to `~/.ssh/config` (default `devbox`).

## Features (all default on except `cloud`)
- `agent`: herdr, Claude Code, Codex, pi, graphify and ccstatusline. This role also installs
  Chrome and Playwright, but only if `browsers` (below) is also on.
- `k8s`: kubectl, helm, k9s, kubeconform.
- `cloud`: terraform, packer.
- `browsers`: Chrome + Playwright, installed as part of the `agent` role. It needs `agent: true`
  as well to actually run, so turning `agent` off turns this off too regardless of its own value.
- `idle_stop`: powers the box off after ~2h of no SSH session, no agent process and low load.
  This same toggle also installs the nightly agent-CLI refresh timer, so turning it off stops
  both the auto-poweroff and the nightly refresh, not just the poweroff.
- `dotfiles`: seed the shell/editor/agent config.

## Repos
`repos:` is a list of git URLs. Nothing clones them automatically: they're written to
`/etc/devbox/repos`, and the `devbox-repos` helper clones any not already present into `~/Src`
(it needs your `gh`/SSH auth). The first-login walkthrough reminds you to run `devbox-repos`
when the list isn't empty. Empty by default.

## Cost note (Hetzner vs GCP)
A **powered-off** Hetzner server is still billed, only traffic stops. For real savings when
you won't use the box for a while, `./down` deletes the server and keeps the volume; `./up`
rebuilds it (~10 min) with your `/home` intact. `idle_stop`'s poweroff is about not running an
idle machine, not about cost: flip it off if you'd rather leave the box up.
