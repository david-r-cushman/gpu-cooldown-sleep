# GPU Cooldown Sleep

This repository is a PowerShell project for monitoring GPU temperature and putting a Windows system to sleep once the GPU has cooled to a defined target.

The project started from a real personal need: after GPU-intensive work ends, the system may still be too warm to sleep immediately. Rather than manually watching temperatures and waiting, the goal is to automate that handoff safely.

## Current Status

This repository is in active early development.

The initial module scaffold and first command set now exist, but the project is still in its first implementation phase.

For the current design intent, see [`docs/project-direction.md`](docs/project-direction.md).

## Problem Space

The initial problem this project is trying to solve is narrow and practical:

- poll GPU temperature from a supported provider
- wait until the temperature reaches a target threshold
- avoid running indefinitely by enforcing a timeout
- provide useful progress feedback while waiting
- put the system to sleep safely once the target condition is met

The first implementation will likely be NVIDIA-first because that is the hardware currently available for testing, but the repository is intentionally being shaped so that additional GPU providers can be added later.

## Current Commands

The module currently exports these commands:

- `Get-GpuCooldownDevice`
- `Get-GpuCooldownTemperature`
- `Wait-GpuCooldown`
- `Start-GpuCooldownSleep`

These commands provide the first end-to-end slice of the workflow:

- discover supported GPU devices
- retrieve normalized temperature data
- wait for cooldown using a timeout-aware loop
- initiate sleep with `ShouldProcess` support

The current provider implementation is NVIDIA-based and uses `nvidia-smi`.

## Current Usage

Import the module from the repository root during development:

```powershell
Import-Module .\GpuCooldownSleep.psd1 -Force
```

Discover the supported GPU device:

```powershell
Get-GpuCooldownDevice
```

Get the current temperature for the default supported device:

```powershell
Get-GpuCooldownTemperature
```

Wait for the GPU to cool to a target temperature without changing system power state:

```powershell
Wait-GpuCooldown -TargetTemperature 40 -PollIntervalSeconds 10 -TimeoutMinutes 15
```

Exercise the full sleep command safely with `-WhatIf`:

```powershell
Start-GpuCooldownSleep -TargetTemperature 40 -PreventSystemSleep -WhatIf
```

## Design Priorities

- vendor-neutral project structure
- disciplined PowerShell module organization
- safe power-state control and failure handling
- useful observability during cooldown monitoring
- testable orchestration logic

## Intended Shape

This repository is expected to grow into a properly organized PowerShell module with:

- public commands under [`src/Public`](src/Public)
- shared helpers under [`src/Private`](src/Private)
- tests under [`Tests`](Tests)
- supporting notes under [`docs`](docs)

The goal is to build this as a maintainable PowerShell project, not leave it as a single experimental script.

## Non-Goals

The initial version of this project is not intended to be:

- a full hardware monitoring suite
- a fan-control or overclocking tool
- a general thermal-management framework
- a polished multi-vendor implementation from day one

## Why This Repo Exists

This project may or may not eventually earn a place in the public portfolio, but it is absolutely worth pursuing as a real engineering exercise.

If developed well, it can demonstrate the ability to:

- take a niche real-world problem seriously
- design safe automation around system power state
- structure provider-specific logic cleanly
- turn a rough utility idea into a maintainable PowerShell module

## Development Notes

- The repository was created from [`pwsh-dev-template`](https://github.com/david-r-cushman/pwsh-dev-template).
- The starting direction for this repo intentionally favors clarity and structure over trying to rush straight into implementation.
- Earlier rough-draft work is being treated as reference material, not as code that must be migrated directly.
- Pester tests are being added alongside each public command, although test execution in some local environments may still require attention depending on registry access constraints.
