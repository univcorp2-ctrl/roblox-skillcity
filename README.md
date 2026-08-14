# SkillCity

A production-oriented Roblox MVP built around **social roleplay + traffic judgment + practical math + cooperative city incidents**.

The commercial thesis is simple: the fantasy is "be competent and respected in a living city." Learning is embedded inside actions that already make sense in that fantasy, rather than presented as schoolwork.

## Playable v0.1 loop

- Server builds the city map at runtime; no paid or copied third-party assets are required.
- Central traffic signal alternates directions and rewards clean crossings while flagging red-signal decisions.
- Market zone generates contextual arithmetic tasks: totals, change and route-time calculations.
- City incidents activate around the map and require 2–3 players to contribute, creating optional social coordination.
- Persistent coins/reputation and completion counters support visible progression.
- Monetization is fail-closed by default. Paid IDs and durable grants must be configured before purchases can ever be acknowledged.
- Custom analytics events instrument task start/correct/wrong, traffic decisions, incidents and session starts.

## Build

```bash
rojo build default.project.json -o SkillCity.rbxlx
```

GitHub Actions builds `SkillCity.rbxlx` on every push.

## Release standard

A GitHub artifact is **not** production. Follow `docs/STUDIO_MCP_RELEASE.md`: open the built place in Roblox Studio, run the exact MCP playtest matrix, inspect console/output, take release evidence, and only then promote it through the Place Publishing workflow.

## Monetization principle

Sell identity, status and convenience—not correctness. Cosmetics, garage/outfit slots and themed seasons are acceptable starting points. Never sell the correct answer, basic safety knowledge or unfair public-server power.
