# Changelog

All notable changes to this GPU Cooldown Sleep project are documented in this file.

This project uses Semantic Versioning for the project itself. The project version is separate from the synced template guidance version shown in the README badge.

## Unreleased

### Changed

- Synced the downstream guidance baseline to template 0.15.0 and aligned the repo's Windows CI contract around tracked ci.yml, actions/checkout@v7, and Pester 6.0.0.

### Added

### Changed

- Hardened the Pester GitHub Actions workflow to re-register `PSGallery` when missing before installing pinned `Pester 5.7.1`.

## 0.1.0 - 2026-06-22

### Added

- Added root-level `AGENTS.md` from the synced template guidance.
- Added AI governance documentation and the ADR scaffold README from `pwsh-dev-template` guidance version `0.11.0`.

### Changed

- Synced AI guidance and guardrail documentation from `pwsh-dev-template` guidance version `0.11.0`.
- Refreshed `.github/copilot-instructions.md` with the current AI coding instructions.
- Updated the README template-version badge to `template-0.11.0`.
