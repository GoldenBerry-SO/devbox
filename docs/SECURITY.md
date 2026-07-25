# Security model

- **No shared credentials, ever.** Nothing on the box is pre-authenticated. You log into
  `gh`, `git`, your agents as *you* at first login. This repo must never contain a token, key,
  or personal secret — CI enforces it.
- **SSH is the only door.** Key auth only; password auth is off on stock Hetzner Ubuntu. The
  firewall allows port 22 from `allow_ssh_from` (your IP by default) and nothing else inbound.
- **Least privilege.** One owner, one key. Sharing = add another authorized key (or put a
  Tailscale ACL in front — a planned option). There's no IAM to misconfigure.
- **Host keys & rebuilds.** Rebuilding the box regenerates its SSH host key. The generated
  ssh config uses a dedicated `known_hosts.devbox` with `accept-new`, and `./up` clears the
  stale entry, so a rebuild doesn't throw a "host key changed" wall — while still pinning the
  key between rebuilds.
- **Harden further (optional):** set `allow_ssh_from` to a fixed CIDR, or front the box with
  Tailscale/WireGuard and set `allow_ssh_from` to the tailnet only. See the roadmap.
