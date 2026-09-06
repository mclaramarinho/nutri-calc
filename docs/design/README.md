# Design Decisions

Documents design/UX decisions so they don't need to be re-derived (or re-argued) every time a new feature touches the UI. Written and maintained by the `senior-designer` agent.

## Files

- `user-personas.md` — who uses this app (dietitians/nutritionists), their context of use, constraints (e.g. fast data entry during a consult, one-handed mobile use, clinical terminology). Fill in as research/assumptions accumulate.
- `design-conventions.md` — concrete UI/UX conventions (interaction patterns, copy tone, empty/error states, accessibility baseline) that aren't already captured by the design-system tokens in `lib/shared/design_system/tokens/`. This is the fallback source of truth when no Figma file is provided for a feature.
- Per-feature design notes, if a feature's UI decisions are non-obvious enough to need writing down — `feature-<name>.md`. Skip this for straightforward CRUD screens that just reuse existing DS widgets/tokens.

## Figma

If a Figma URL is provided for a feature, prefer inspecting it via the Figma MCP server (check with `ToolSearch`/available MCP tools) over guessing from a screenshot or description. If no Figma MCP is configured or no URL is given, fall back to this folder's conventions plus the existing DS tokens — don't block on Figma access.
