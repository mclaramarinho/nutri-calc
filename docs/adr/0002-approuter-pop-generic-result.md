# 0002. `AppRouter.pop` gains a generic optional result parameter

**Status:** Accepted
**Date:** 2026-09-07
**Feature:** docs/roadmap.md Priority 3 — `DsBottomSheet` design-system component

## Context

`DsBottomSheet.show<T>(context, ...)` (spec: `docs/design/design-conventions.md`) must return `Future<T?>`,
resolved from whatever value the sheet is popped with — mirroring how `showModalBottomSheet` already
resolves its own `Future` via `Navigator.pop(context, result)`.

All dismissal in this codebase is required to go through `AppRouter` (`lib/routing/app_router.dart`) rather
than raw `Navigator`/`context.pop()`, per `CLAUDE.md`'s routing convention and the existing `DsDialog`
pattern (`getIt.get<AppRouter>().pop()`). But `AppRouter.pop()` is currently:

```dart
void pop();
```

with no way to carry a result value back to the `Future` the sheet's `show()` caller is awaiting. Without a
change here, anything dismissing a `DsBottomSheet` from inside its own `actions`/body (the common case —
e.g. a "Salvar" button resolving the sheet with a value) would have to bypass `AppRouter` and call
`Navigator.pop(context, result)` directly, breaking the one dismissal convention the codebase otherwise
enforces everywhere.

Checked before deciding: grepped all `.pop()` call sites in `lib/` — only two call sites exist
(`ds_dialog.dart:70`, `ds_dialog.dart:132`), both no-arg, plus the `AppRouterImpl.pop` implementation itself
(`app_router.dart:56`, which forwards to `router.pop()` after a `canPop()` guard). No other file calls
`AppRouter.pop()`.

## Decision

Change the `AppRouter` interface method to:

```dart
void pop<T extends Object?>([T? result]);
```

`AppRouterImpl.pop` forwards the optional result to GoRouter's own `pop`, which already accepts and forwards
an optional result to the underlying `Navigator` (unchanged `canPop()` guard):

```dart
@override
void pop<T extends Object?>([T? result]) {
  router.canPop() ? router.pop(result) : debugPrint("Can't pop");
}
```

This is additive and backward compatible: `result` defaults to `null`, so both existing no-arg call sites
(`ds_dialog.dart`) keep compiling and behaving identically. `DsBottomSheet`'s internal close affordances
(e.g. a "Salvar" `DsButton` in `actions`) call `getIt.get<AppRouter>().pop<T>(value)` to resolve the
`Future<T?>` returned by `DsBottomSheet.show<T>`, keeping the single dismissal convention intact instead of
introducing a `Navigator`-based escape hatch just for this widget.

## Consequences

- Makes result-passing dismissal (`DsBottomSheet`, and any future modal DS widget needing a typed return
  value) possible without bypassing the `AppRouter` convention.
- No call-site migration needed for existing no-arg `.pop()` usages.
- Callers that do want a result must call the generic form explicitly (`pop<MyType>(value)` or rely on type
  inference from context); nothing enforces a caller actually supplies a `result` when the `Future<T?>` on
  the other end expects one — this is a convention, not compiler-enforced, same as `Navigator.pop`'s own
  looseness. No follow-up tracked; acceptable given `Navigator.pop` itself has the same looseness.

## Alternatives considered

- **Add a separate `popWithResult<T>(T? result)` method, leave `pop()` untouched.** Rejected: two methods
  doing the same underlying `router.pop(...)` call is redundant API surface for no real safety gain, given
  the generic-with-default-null form is fully backward compatible.
- **Bypass `AppRouter` and call `Navigator.of(context).pop(result)` directly from inside `DsBottomSheet`
  only.** Rejected: breaks the codebase-wide "all dismissal goes through `AppRouter`" convention for the one
  widget that most needs a result value, and reintroduces direct `Navigator`/`BuildContext` coupling that
  `AppRouter` exists to avoid (`AppRouter.context` gives context-less access to the current route from
  cubits; the DS widgets should stay consistent with that even though they do have a `BuildContext` at hand
  here).
