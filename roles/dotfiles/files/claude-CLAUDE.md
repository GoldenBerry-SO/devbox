# devbox conventions

You're running on a devbox — a remote Linux VM the developer connects to over SSH.
A few conventions for this machine:

- Save screenshots and generated reports under `~/screenshots/` so they're easy to pull
  back to the laptop (`scp` / `rsync`).
- Apps are usually tested from the laptop via SSH port-forwarding — bind services to
  `127.0.0.1` (common ports: frontend 3000, backend 3001).
- A `chrome-devtools` MCP server is preconfigured and Chrome/Chromium are installed — use
  them for browser verification and E2E checks.
- **Never** power the box off or reboot it (`shutdown`, `poweroff`, `reboot`). An idle-aware
  systemd timer owns the machine lifecycle and won't stop the box while you're working.
- Docker, compose, `psql`, `redis-cli` and the full toolchain are preinstalled — prefer them
  over per-project installs.
- This file is seeded once at first login — you own and edit it.
