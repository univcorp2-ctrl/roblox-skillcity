from pathlib import Path

root = Path(__file__).resolve().parents[1]
required = [
    "src/ServerScriptService/SkillCityServer.server.luau",
    "src/ServerScriptService/Services/MapBuilder.luau",
    "src/ServerScriptService/Services/TrafficService.luau",
    "src/ServerScriptService/Services/JobService.luau",
    "src/ServerScriptService/Services/IncidentService.luau",
    "src/StarterPlayer/StarterPlayerScripts/SkillCityClient.client.luau",
    "default.project.json",
]
for rel in required:
    path = root / rel
    assert path.exists() and path.stat().st_size > 200, f"missing/incomplete {rel}"

all_text = "\n".join((root / rel).read_text(encoding="utf-8") for rel in required if rel.endswith(".luau"))
assert "ProcessReceipt" in (root / "src/ServerScriptService/Services/MonetizationService.luau").read_text(encoding="utf-8")
assert "NotProcessedYet" in (root / "src/ServerScriptService/Services/MonetizationService.luau").read_text(encoding="utf-8")
assert "math_task" in all_text
assert "traffic" in all_text.lower()
assert "incident" in all_text.lower()
print("SkillCity static checks passed")
