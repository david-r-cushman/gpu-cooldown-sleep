# Observability And Provider Model

This document captures the next-stage design direction for `gpu-cooldown-sleep` now that the initial command surface exists.

The current implementation already supports:

- device discovery
- temperature polling
- cooldown waiting
- sleep orchestration
- support validation

The next design challenge is to make future provider expansion, logging, and user-facing progress behavior evolve from a shared model instead of as unrelated features.

## Why These Concerns Belong Together

Three upcoming areas are tightly connected:

- provider extensibility
- logging and verbose diagnostics
- progress and user experience

If they evolve independently, the project risks becoming inconsistent:

- each provider may expose different runtime details
- progress output may become NVIDIA-specific
- logging may capture different kinds of events than the progress UI

Instead, the module should define a small provider-neutral runtime story and let each provider plug into that story.

## Provider Contract Direction

The current provider implementation is NVIDIA-first, but future support should be shaped around a provider-neutral contract.

At minimum, each provider should be able to support:

- device discovery
- device selection inputs
- current temperature retrieval
- stable provider-specific device identity

Those provider outputs should continue to be normalized into module-owned object shapes rather than exposing raw tool output directly.

### Current Normalized Device Shape

The module already treats these as stable characteristics of a supported GPU device:

- `Provider`
- `Vendor`
- `Name`
- `DeviceId`
- `ProviderDeviceId`
- `PciBusId`
- `IsSupported`
- `IsSelectedByDefault`

That shape should remain the basis for future providers.

### Current Normalized Temperature Shape

Temperature retrieval also now returns a stable shape:

- `Provider`
- `Vendor`
- `Name`
- `DeviceId`
- `ProviderDeviceId`
- `PciBusId`
- `TemperatureCelsius`
- `RetrievedAt`

That is enough for the current workflow and should remain provider-neutral.

## Observability Model

The module should distinguish between three different forms of runtime visibility:

### Structured Output

Structured output is the official command contract.

Examples:

- the temperature reading returned by `Get-GpuCooldownTemperature`
- the result object returned by `Wait-GpuCooldown`
- the result object returned by `Start-GpuCooldownSleep`
- the support summary returned by `Test-GpuCooldownSupport`

These objects are the automation-facing truth. They should remain stable and machine-friendly.

### Verbose Diagnostics

Verbose output should explain what the command is doing while it runs.

Examples:

- which device is being monitored
- polling cadence
- whether a provider dependency is missing
- current temperature and elapsed time
- why a command timed out or skipped a sleep action

Verbose output is for troubleshooting and operator confidence. It should be descriptive, but not treated as the system of record.

### Progress UI

Progress UI is optional and interactive.

Its purpose is to make long waits easier to understand without changing the command output contract.

For this project, progress should answer:

- which device is being monitored
- current temperature
- target temperature
- how long the wait has been running
- when timeout is expected

The progress UI should remain helpful, but not become so elaborate that it becomes harder to maintain than the core module behavior.

## Logging Direction

The project does not yet need a permanent logging framework.

At the current stage, the better priority is to ensure that:

- structured outputs remain stable
- verbose output remains useful
- progress display remains optional

If persistent logging is added later, it should likely be designed around the same event model already implied by the module:

- support check
- device discovery
- temperature read
- cooldown wait started
- cooldown target reached
- cooldown timed out
- sleep requested
- sleep skipped
- sleep failed

That would make future logging align naturally with both verbose output and result objects.

## Near-Term Implementation Guidance

The next implementation work should prefer:

1. refining provider-neutral helper shapes
2. improving verbose output consistency
3. keeping progress logic lightweight and optional

It should avoid:

- introducing a heavy custom logging framework too early
- baking NVIDIA-specific assumptions into progress or result objects
- expanding UI complexity faster than the core provider model

## Practical Standard

Before adding a new provider or richer UI behavior, ask:

- does this fit the normalized device contract?
- does this fit the normalized temperature contract?
- does this add value to structured output, verbose diagnostics, or progress UI without blurring their responsibilities?

If the answer is yes, the enhancement is probably aligned with the intended direction of the module.
