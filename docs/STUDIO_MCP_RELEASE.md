# Studio MCP production gate

Use Roblox Studio's built-in MCP server for every release candidate.

## Gate A — load and integrity

1. Open `SkillCity.rbxlx` in a clean Studio session.
2. Use MCP to inspect Explorer/DataModel; verify expected ReplicatedStorage, ServerScriptService and StarterPlayer scripts exist.
3. Start Play mode and capture server/client output. Any SkillCity error or infinite yield is a hard fail.

## Gate B — core loop

4. Spawn at City Hall; confirm HUD shows coins and reputation.
5. Move to Market; verify exactly one math task opens, submit a correct and incorrect answer, and ensure server-side rewards only occur on correct answers.
6. Cross the central intersection once on green and once on red; confirm distinct analytics/toast paths and no reward spam from touch events.
7. Trigger an incident with a 2-player local server using StudioTestService/MCP. Confirm one player cannot complete a two-person event alone and duplicate touches do not double-count.

## Gate C — safety and device QA

8. Switch device presets through StudioDeviceSimulatorService for desktop and phone; confirm the math modal remains usable.
9. Verify `Config.Monetization.Enabled == false` for the first public MVP unless real IDs and durable grants have been separately tested.
10. Simulate unknown receipts only; never spend Robux during automated QA. Unknown/unconfigured products must remain `NotProcessedYet`.
11. Capture screenshot + console transcript + test result JSON as release evidence.

## Repair loop

A failed gate creates one bounded repair task against the responsible module. Rebuild and rerun the failed gate plus all earlier regression gates. After three consecutive failures, quarantine the candidate instead of publishing.
