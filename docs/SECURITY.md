# Security model

- **No shared credentials, ever.** Nothing on the box is pre-authenticated. You log into
  `gh`, `git`, your agents as *you* at first login. This repo must never contain a token, key,
  or personal secret: CI enforces it.
- **SSH is the only door.** Key auth only; password auth is off on stock Hetzner Ubuntu. The
  firewall allows TCP port 22 and ICMP (ping) from `allow_ssh_from` (your current IP by default)
  and nothing else inbound.
- **Least privilege.** One owner, one key. Sharing means adding another authorized key. There's
  no IAM to misconfigure.
- **Host keys & rebuilds.** Rebuilding the box regenerates its SSH host key. The generated
  ssh config uses a dedicated `known_hosts.devbox` with `accept-new`, and `./up` clears the
  stale entry, so a rebuild doesn't throw a "host key changed" wall, while still pinning the
  key between rebuilds.
- **Harden further (optional):** set `allow_ssh_from` to a fixed CIDR instead of `auto`, so the
  firewall doesn't silently widen if your IP changes. There's no built-in Tailscale/WireGuard
  option today; fronting the box with one yourself and pointing `allow_ssh_from` at the tailnet
  only is a reasonable way to go further, but it isn't wired into this repo.
