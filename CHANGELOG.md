# Blue Whale Changelog

## v3.6 (2026-08-08)

### New Features
- **Systemless Hosts Support** — Hosts file changes are now handled through Magisk bind-mount. Fully systemless and compatible with modern Android (including A/B partitions and strict SELinux).
- **Magisk Action Button** — Added action button in Magisk Manager.
  - If service is running → Restart
  - If service is stopped → Start
  - Shows real success / error messages
- **System Notifications** — Sends Android system notification on:
  - Successful start after reboot
  - Automatic recovery by watchdog

### Stability Improvements
- Completely rewritten **service.sh** with stronger always-on watchdog
- Checks both process status and actual port listening
- Aggressive but safe residual cleanup before every start (old processes + leftover rules)
- Automatic recovery with progressive retry on repeated failures
- Detailed timestamped logging to `debug.log`

### Other Changes
- Added `post-fs-data.sh` for early systemless setup
- Improved `customize.sh` and permission handling
- Added `uninstall.sh` for cleaner module removal
- Better compatibility across different Android versions and devices

### Notes
- Core binary remains unchanged
- Recommended to uninstall previous version, reboot, then flash v3.6
- After install, reboot once for full activation

---

## v3.5
- Previous stable release

## v3.0 – v3.4
- Incremental stability and service improvements

## v2.0.6
- Simplified static binary structure