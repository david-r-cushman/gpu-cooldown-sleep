# GPU Cooldown Sleep

<!-- BEGIN generated:readme-powershell-badge -->
![PowerShell 7.4](https://img.shields.io/badge/PowerShell-7.4-blue)
<!-- END generated:readme-powershell-badge -->
![Template Version](https://img.shields.io/badge/template-0.15.0-blue)

[![CI](https://github.com/david-r-cushman/gpu-cooldown-sleep/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/david-r-cushman/gpu-cooldown-sleep/actions/workflows/ci.yml)

This repository is a PowerShell project for monitoring GPU temperature and putting a Windows system to sleep once the GPU has cooled to a defined target.

The project started from a real personal need: after GPU-intensive work ends, the system may still be too warm to sleep immediately. Rather than manually watching temperatures and waiting, the goal is to automate that handoff safely.

Quick navigation:

- [Portfolio Context](#portfolio-context)
- [Engineering Principles in Practice](#engineering-principles-in-practice)
- [Validation And Maintenance](#validation-and-maintenance)
- [Repository Structure](#repository-structure)


## Portfolio Context

This repository is part of a PowerShell portfolio built from `pwsh-dev-template`, and it is centered on a real operational need rather than a generic sample. It demonstrates safe automation around system power state, provider-aware hardware polling, and the discipline required to turn a narrow utility into a maintainable PowerShell module.

A reviewer should pay attention first to the end-to-end cooldown workflow, the safety posture around system sleep, and how provider-specific concerns are being isolated so the NVIDIA-first implementation can grow into a cleaner multi-provider design over time.

## Engineering Principles in Practice

<!-- BEGIN generated:readme-runtime-philosophy -->
- **Deterministic Development Runtime:** PowerShell 7.4 is the maintained baseline, and real module execution stays on a Windows host because the workload is Windows-specific
<!-- END generated:readme-runtime-philosophy -->
- **Safe Power-State Control:** System sleep orchestration should be explicit, observable, and guarded by clear result contracts
- **Provider-Aware Design:** Device discovery, telemetry, and cooldown logic should stay structured so the NVIDIA-first implementation can expand without collapsing into vendor-specific sprawl
- **Timeout-Bounded Automation:** Cooldown waiting should remain explicitly bounded so the module never blocks indefinitely while waiting for thermal conditions to change
- **Observability During Cooldown:** Operators should be able to understand what the cooldown loop is doing without reverse-engineering internal state
- **Disciplined Module Structure:** Public commands, private helpers, and provider-specific behavior should stay cleanly separated
- **Testable Orchestration:** The cooldown and sleep handoff should remain structured around behavior that can be validated through unit tests

For the deeper operating model behind that approach, see [`docs/powershell-ai-operating-model.md`](docs/powershell-ai-operating-model.md). For repository-specific design direction, provider modeling, and module architecture, see [`docs/project-direction.md`](docs/project-direction.md), [`docs/observability-and-provider-model.md`](docs/observability-and-provider-model.md), and [`docs/module-architecture-overview.md`](docs/module-architecture-overview.md).

## Use This Repository

1. Import the module from `./GpuCooldownSleep` during development and use `Test-GpuCooldownSupport` to confirm the local environment is ready.
2. Start with `Get-GpuCooldownDevice` and `Get-GpuCooldownTemperature` to understand provider discovery and normalized telemetry.
3. Use `Wait-GpuCooldown` when you want to validate cooldown behavior without changing system power state.
4. Use `Start-GpuCooldownSleep -WhatIf` before attempting a real sleep workflow so you can review the orchestration path safely.
5. Refer to the `Current Commands`, `Usage`, and linked architecture documents below for the full command walkthrough and design rationale.

## Runtime And Environment

<!-- BEGIN generated:readme-runtime-stack -->
- **Runtime:** PowerShell 7.4.x on Windows for module development and execution
<!-- END generated:readme-runtime-stack -->
- **Host Requirement:** Windows is required because the module ultimately coordinates system sleep on a Windows system
- **Current Provider Baseline:** The implemented provider path is NVIDIA-first and expects `nvidia-smi` to be available
- **Development Modes:** Local VS Code, Docker Dev Containers, and GitHub Codespaces
- **Isolation Strategy:** Use the container to reduce host tooling and credential exposure during development work

## Tooling

<!-- BEGIN generated:readme-tooling-list -->
- **Pester 6.0.0:** For unit and integration testing
- **PSScriptAnalyzer 1.25.0:** To enforce PowerShell best practices and security rules
- **Azure CLI:** Pre-installed for cloud resource management
- **PSReadLine 2.4.5:** Configured for a more efficient terminal experience
<!-- END generated:readme-tooling-list -->

Unit tests run in GitHub Actions and can also be run locally through the repository validation and test entrypoints.

## Repository Structure

- `GpuCooldownSleep/`: module root
- `GpuCooldownSleep/src/Public/`: exported commands and public entrypoints
- `GpuCooldownSleep/src/Private/`: shared helpers and internal orchestration logic
- `Tests/`: Pester tests and test entrypoints
- `docs/`: design notes, operating model guidance, and supporting documentation
- `scripts/`: validation, README alignment, and downstream maintenance entrypoints

## Validation And Maintenance

Run the standard repository checks before committing meaningful changes:

```powershell
pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1
```

Run the focused unit-test entrypoint directly when you want the repository's dedicated Pester workflow:

```powershell
pwsh -File .\Tests\Invoke-UnitTests.ps1
```

If this repository keeps the template-managed generated Markdown blocks, refresh or validate them through:

```powershell
pwsh -NoProfile -File ./scripts/Update-GeneratedMarkdown.ps1 -Check
```

## Downstream Guidance Sync

Use `.codex/skills/downstream-guidance-sync/SKILL.md` with `scripts/Invoke-TemplateGuidanceSync.ps1` when you want to adopt newer `pwsh-dev-template` guidance, README workflow assets, or guardrails without overwriting repository-owned implementation.

## Prerequisites And Setup

- Install PowerShell 7.4 or use the repository Dev Container / Codespace baseline.
- Ensure an NVIDIA GPU is present and `nvidia-smi` is available for the current provider implementation.
- Import the module from the repository root during development with `Import-Module .\GpuCooldownSleep -Force`.
- For normal imports, copy `./GpuCooldownSleep/` into a path on `$env:PSModulePath`, then run `Import-Module GpuCooldownSleep -Force`.
- Review `docs/agent-workflows.md`, `AGENTS.md`, and `.github/copilot-instructions.md` before using agent-driven repository changes.

## Template Versioning

This repository versions the GPU Cooldown Sleep project itself using Semantic Versioning.

- Current project version: see [`VERSION`](VERSION)
- Version history: see [`CHANGELOG.md`](CHANGELOG.md)

The project version is separate from the template-version badge at the top of this README. That badge records the synced `pwsh-dev-template` guidance and workflow baseline used by this repository.

## Current Status

The module is functional and actively evolving.

The core workflow is implemented end-to-end (device discovery, temperature polling, cooldown waiting, and safe sleep orchestration), and unit tests run in CI via GitHub Actions.

For the original design intent and the next-stage direction, see:

- [`docs/project-direction.md`](docs/project-direction.md)
- [`docs/observability-and-provider-model.md`](docs/observability-and-provider-model.md)
- [`docs/module-architecture-overview.md`](docs/module-architecture-overview.md)

## Problem Space

The initial problem this project is trying to solve is narrow and practical:

- poll GPU temperature from a supported provider
- wait until the temperature reaches a target threshold
- avoid running indefinitely by enforcing a timeout
- provide useful progress feedback while waiting
- put the system to sleep safely once the target condition is met

The current implementation is NVIDIA-first because that is the hardware currently available for testing, but the repository is intentionally being shaped so that additional GPU providers can be added later.

## Current Commands

The module currently exports these commands:

- `Get-GpuCooldownDevice`
- `Get-GpuCooldownTemperature`
- `Wait-GpuCooldown`
- `Start-GpuCooldownSleep`
- `Test-GpuCooldownSupport`

These commands provide the first end-to-end slice of the workflow:

- discover supported GPU devices
- retrieve normalized temperature data
- wait for cooldown using a timeout-aware loop
- initiate sleep with `ShouldProcess` support and an explicit result contract

The current provider implementation is NVIDIA-based and uses `nvidia-smi`.

## Usage

Discover the supported GPU device:

```powershell
Get-GpuCooldownDevice
```

Review the current environment and dependency readiness:

```powershell
Test-GpuCooldownSupport
```

Get the current temperature for the default supported device:

```powershell
Get-GpuCooldownTemperature
```

Target a GPU by module-stable device id:

```powershell
Get-GpuCooldownTemperature -DeviceId 'nvidia:00000000:01:00.0'
```

Target a GPU by friendly name:

```powershell
Get-GpuCooldownTemperature -Name 'NVIDIA GeForce RTX 2070 SUPER'
```

Wait for the GPU to cool to a target temperature without changing system power state:

```powershell
Wait-GpuCooldown -TargetTemperature 40 -PollIntervalSeconds 10 -TimeoutMinutes 15 -ShowProgress
```

Show structured diagnostics while monitoring:

```powershell
Start-GpuCooldownSleep -TargetTemperature 40 -ShowProgress -Verbose
```

Exercise the full sleep command safely with `-WhatIf`:

```powershell
Start-GpuCooldownSleep -TargetTemperature 40 -PreventSystemSleep -ShowProgress -WhatIf
```

The `-Name` parameter is intended to be the friendlier interactive selection path, while `-DeviceId` remains the more stable automation-oriented selector.

## Verbose Output

This module uses `Write-Verbose` for structured, event-style diagnostics.

- `Get-GpuCooldownDevice -Verbose` emits `DeviceDiscovered` events as it enumerates supported GPUs.
- Commands that need to select a single GPU emit a single `DeviceSelected` event to confirm which device will be monitored.

Verbose output is intended for operator confidence and troubleshooting. The structured objects returned from the commands remain the source of truth for automation.

## Non-Goals

The initial version of this project is not intended to be:

- a full hardware monitoring suite
- a fan-control or overclocking tool
- a general thermal-management framework
- a polished multi-vendor implementation from day one
