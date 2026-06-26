# GPU Cooldown Sleep

[![Pester](https://github.com/david-r-cushman/gpu-cooldown-sleep/actions/workflows/pester.yml/badge.svg?branch=main)](https://github.com/david-r-cushman/gpu-cooldown-sleep/actions/workflows/pester.yml)
![Template Version](https://img.shields.io/badge/template-0.11.0-blue)

This repository is a PowerShell project for monitoring GPU temperature and putting a Windows system to sleep once the GPU has cooled to a defined target.

The project started from a real personal need: after GPU-intensive work ends, the system may still be too warm to sleep immediately. Rather than manually watching temperatures and waiting, the goal is to automate that handoff safely.

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

## Requirements

- Windows (this module ultimately coordinates system sleep)
- PowerShell 7.4+
- NVIDIA GPU with `nvidia-smi` available (current provider implementation)

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

Import the module from the repository root during development:

```powershell
Import-Module .\GpuCooldownSleep -Force
```

Optionally, install it for normal imports by copying `.\GpuCooldownSleep\` into a path on `$env:PSModulePath`, then:

```powershell
Import-Module GpuCooldownSleep -Force
```

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

## Design Priorities

- vendor-neutral project structure
- disciplined PowerShell module organization
- safe power-state control and failure handling
- useful observability during cooldown monitoring
- testable orchestration logic

## Repository Layout

This repository is organized as a PowerShell module with:

- the module under [`GpuCooldownSleep`](GpuCooldownSleep)
- public commands under [`GpuCooldownSleep/src/Public`](GpuCooldownSleep/src/Public)
- shared helpers under [`GpuCooldownSleep/src/Private`](GpuCooldownSleep/src/Private)
- tests under [`Tests`](Tests)
- supporting notes under [`docs`](docs)

## Non-Goals

The initial version of this project is not intended to be:

- a full hardware monitoring suite
- a fan-control or overclocking tool
- a general thermal-management framework
- a polished multi-vendor implementation from day one

## Why This Repo Exists

This project is a portfolio-grade PowerShell module built around a real operational need: safely handing off from GPU-intensive work to system sleep once hardware has cooled.

If developed well, it can demonstrate the ability to:

- take a niche real-world problem seriously
- design safe automation around system power state
- structure provider-specific logic cleanly
- turn a rough utility idea into a maintainable PowerShell module

## Project Versioning

This repository versions the GPU Cooldown Sleep project itself using Semantic Versioning.

- Current project version: see [`VERSION`](VERSION)
- Version history: see [`CHANGELOG.md`](CHANGELOG.md)

The project version is separate from the template-version badge at the top of this README. The badge records the `pwsh-dev-template` guidance version used for synced AI guidance and guardrails.

## Development Notes

- The repository was created from [`pwsh-dev-template`](https://github.com/david-r-cushman/pwsh-dev-template).
- The starting direction for this repo intentionally favors clarity and structure over trying to rush straight into implementation.
- Earlier rough-draft work is being treated as reference material, not as code that must be migrated directly.
- Pester unit tests run in GitHub Actions and can be run locally via `pwsh -File .\Tests\Invoke-UnitTests.ps1`.
