# AtlasFastStart

The canonical checkout and local archive are in `D:\AtlasFastStart`.
This project archives original Windows installers and provides a catalogue and download/verification scripts.

- Never execute third-party installers as part of collecting or testing the archive.
- Use HTTPS publisher downloads and original publisher release assets. Preserve pinned SHA256 and installer size.
- Keep `Local`, `verification`, `Support`, `Sources`, and `Installers` out of Git. Raw machine inventory and account paths belong only in `Local`.
- Publish installer binaries only after recording their redistribution basis and required notices/source in `THIRD_PARTY.md`. Use GitHub Releases for binary assets.
- Update linked notes in `D:\Obsidian\Main\Atlas` when changing the archive or release.
- Verify PowerShell syntax, perform a real small-package download, and run `Verify-Installers.ps1` after catalogue changes. Never change Windows execution policy globally.
- A recorded shutdown time describes a completed request. Schedule another shutdown only when the user explicitly requests it in the current task.
