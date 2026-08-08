# Blue Whale Changelog
# 4.3
- Fixed certificate issues in some devices
- Added support to Kernel SU
- Internal Optimization 

# Note
- Must delete old module after update 

## v4.1 (2026-08-08)

### Fixed
- **Critical DNS fix** — Upstream requests no longer fail with `[::1]:53 connection refused` when running as Magisk service. Uses public DNS (8.8.8.8) for resolution.

### Added
- Control API on (`/status`, `/test`) for WebUI.
- WebUI support (status + live test button).
- Always-on listener with automatic rebind if port is lost.
- Systemless-friendly hosts handling (Magisk module path + best-effort system hosts).

### Improved
- Binary never exits on bind/DNS/network errors; retries forever.
- iptables DNAT aligned with original working Python logic.

### Notes
- Action button: Start / Restart service.

---

## v4.0
- Initial WebUI + control API attempt
- Full debug logging to isolate failures

## v3.x
- Stability and service script iterations
- Systemless hosts bind-mount experiments

## v2.0.6
- Simplified static aarch64 binary structure
