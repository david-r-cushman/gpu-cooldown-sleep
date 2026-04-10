# Project Direction

This document captures the intended direction for `gpu-cooldown-sleep` before the module implementation was built out.

The goal is to preserve the worthwhile ideas from the earlier rough draft while starting this repository from a cleaner, more deliberate foundation.

As of April 10, 2026, the first end-to-end implementation exists. This document is retained as the original direction and evaluation criteria, with a short “Current State” section added for alignment.

## Problem Statement

This project exists to solve a real, personal systems problem with PowerShell:

After GPU-intensive activity ends, the system may still be too warm to sleep immediately. I want a reliable way to wait until the GPU has cooled to a defined threshold and then put the system to sleep without manually monitoring temperature.

The project is intentionally focused on GPU temperature as the primary signal.

CPU load may eventually be used as a supporting heuristic, but CPU temperature is not treated as a dependable first-class input for the initial design.

## Initial Scope

The first usable version of this project focused on:

- querying GPU temperature from a supported provider
- waiting until a target temperature is reached
- enforcing a maximum runtime so the process does not run indefinitely
- providing clear progress or status feedback while waiting
- putting the system to sleep safely once the threshold condition is met

The initial implementation is NVIDIA-first because that is the only hardware currently available for testing, but the repository structure remains vendor-neutral.

## Design Goals

### Vendor-Neutral Shape

Even if NVIDIA is the first implemented provider, the project should be organized so that additional GPU providers can be added later without rewriting the orchestration flow.

### PowerShell Module Discipline

This is organized as a PowerShell module rather than a single script. Public commands, private helpers, tests, and documentation have a clear place in the repository.

### Safe Power-State Control

Because the project changes system power state, the design should be careful about when sleep is triggered, how dependencies are validated, and how temporary keep-awake behavior is restored if execution stops unexpectedly.

### Clear Observability

The module should make it easy to understand what is happening while cooldown is being monitored. That may include progress display, structured verbose output, or logging.

### Testable Orchestration

The logic that decides whether to continue waiting, fail, or sleep should be testable without depending on live hardware for every validation path.

## Non-Goals

The initial version of this project is not intended to be:

- a full hardware monitoring suite
- a GPU overclocking or fan-control tool
- a cross-platform thermal management framework
- a polished multi-vendor implementation from day one

The goal is to solve one real problem well and leave room for future expansion.

## Suggested First-Cut Module Shape

The rough draft surfaced a few durable architectural ideas worth keeping:

- a public orchestration command such as `Start-GpuCooldownSleep`
- provider-specific temperature retrieval behind a cleaner abstraction
- a dedicated sleep action/helper rather than embedding power-state logic everywhere
- separate handling for progress display and internal diagnostics

Whether the final implementation uses functions or classes should be decided based on clarity, testability, and maintainability rather than aesthetics alone.

## Portfolio Worthiness Criteria

This project is included in the portfolio because it grew into more than a clever personal script.

The signals that made it portfolio-worthy include:

- disciplined module design
- hardware and tool abstraction
- dependency and failure handling
- safe sleep and power-state control
- useful observability or logging
- tests around parsing, orchestration, and timeout behavior

This project demonstrates the ability to take a niche real-world problem and turn it into reliable, maintainable PowerShell automation with guardrails.

## Current State (April 10, 2026)

The repository now contains:

- a packaged module under `GpuCooldownSleep\`
- public commands for device discovery, temperature retrieval, cooldown waiting, sleep orchestration, and support checks
- an NVIDIA provider integration backed by `nvidia-smi`
- operator observability via `-ShowProgress` and `-Verbose` event-style diagnostics
- Pester unit tests runnable locally and in GitHub Actions CI

## Practical Direction

The earlier `Start-NvidiaCooldownSleep` prototype should be treated as a concept reference, not as code that must be migrated directly.

The best material to carry forward from that draft is:

- the core problem being solved
- the idea of vendor-neutral structure
- the keep-awake-until-ready concept
- the need for timeout behavior
- the desire for useful progress feedback

The implementation in this repository should be built fresh against the structure and standards already provided by the PowerShell project template.
