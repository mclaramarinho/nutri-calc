---
name: run-nutri-calc
description: Build, run, and drive nutri_calc (Flutter/Dart nutrition-calculator app). Use when asked to start nutri_calc, run its tests, build it, take a screenshot of its UI, or interact with the running app (navigate, tap, type, fill forms).
---

nutri_calc is a Flutter app (flutter_bloc + go_router + get_it/injectable +
sqflite, code-gen via build_runner). It's driven over the **Dart VM
Service**: `.claude/skills/run-nutri-calc/driver.mjs` launches the app,
connects to its VM Service websocket, and evaluates Dart expressions
in the running isolate to walk the widget tree, synthesize taps, fill
text fields, and read the current route — no test framework, no
Playwright, no accessibility tree needed. All paths below are relative
to the repo root (`nutri_calc/`).

## Prerequisites

Verified on macOS with an iOS Simulator already available (`flutter
devices` lists it). No extra packages were needed beyond a working
Flutter SDK (`flutter --version` -> 3.44.6) and Node (for the driver;
tested with Node 26).

```bash
flutter devices   # confirm a simulator/device id, e.g. iPhone 17 Pro
```

## Setup / Build

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Note: with the pinned `build_runner: ^2.15.1` this actually prints
`These options have been removed and were ignored: --delete-conflicting-outputs`
— it's a no-op flag now, but harmless to keep (matches `scripts/build.sh`).
Generation itself still runs and regenerates `*.g.dart` / `di.config.dart`.

## Run (agent path)

Launch the app on a device/simulator, then drive it with `driver.mjs`.
Each driver subcommand is a **separate, short-lived Node process** —
it reads the saved VM Service URI from `.state.json` next to the
driver, opens a fresh websocket, runs one action, and exits. There is
no persistent REPL to manage or tmux session to wrap.

```bash
# 1. Get a device id
flutter devices

# 2. Launch (builds + starts `flutter run --machine` in the background,
#    waits for the VM Service, saves connection info to .state.json)
node .claude/skills/run-nutri-calc/driver.mjs launch <deviceId>

# 3. Drive it
node .claude/skills/run-nutri-calc/driver.mjs route              # -> AppRoutes.home
node .claude/skills/run-nutri-calc/driver.mjs dump                # list of on-screen Text/Icon + center coords
node .claude/skills/run-nutri-calc/driver.mjs tapText "Salvar"    # find a Text widget by substring, tap its center
node .claude/skills/run-nutri-calc/driver.mjs tap 361 731         # tap raw LOGICAL coords (not screenshot pixels)
node .claude/skills/run-nutri-calc/driver.mjs type "Joana"        # set the value of the currently FOCUSED text field
node .claude/skills/run-nutri-calc/driver.mjs eval "1+1"          # raw one-off Dart expression
node .claude/skills/run-nutri-calc/driver.mjs screenshot /tmp/shot.png   # xcrun simctl screenshot (iOS sim)

# 4. Stop
node .claude/skills/run-nutri-calc/driver.mjs stop
```

Verified real flow (this session, iPhone 17 Pro simulator):
`launch` -> `tap 361 731` (taps the home page's FAB) -> route became
`AppRoutes.createPatient` -> `tapText "Primeiro Nome"` -> `type "Joana"`
-> `tapText "Último Nome"` -> `type "Silva"` -> `tapText "Salvar"` ->
screenshot confirmed the app returned to the home page (patient saved).
A screenshot was also taken and inspected at every step along the way.

| command | what it does |
|---|---|
| `launch [deviceId]` | starts `flutter run --machine`, waits for `app.debugPort`, saves `wsUri`/`pid` to `.state.json` |
| `stop` | kills the `flutter run` process group |
| `screenshot <file>` | `xcrun simctl io <deviceId\|booted> screenshot` |
| `dump` | walks the widget tree, prints every visible `Text`/`Icon` as `label@x,y` |
| `route` | prints `getIt.get<AppRouter>().currentRoute` |
| `tap <x> <y>` | synthesizes a tap at logical coordinates |
| `tapText <substring>` | finds a `Text` widget whose data contains `substring` (case-insensitive) and taps its center — prefer this over raw `tap` |
| `type <text>` | sets the text of whichever `EditableText` currently **has focus** (tap the field first) |
| `eval <dart-expr>` | evaluates any single Dart expression in `lib/main.dart`'s library scope (`getIt`, all imports of `main.dart` are in scope) |

`.state.json` and `.flutter-machine.log` are written next to the
driver and are gitignored scratch state, not part of the skill itself.

## Run (human path)

```bash
flutter run -d <deviceId>   # interactive hot-reload session, Ctrl-C / `q` to quit
```

## Test

```bash
flutter test
```

Result at time of writing: 1 test file (`test/patient_measurements_tab_test.dart`), all passing.

## Gotchas

- **VM Service `evaluate` is single-line.** A newline inside the
  expression truncates it (`Can't find '}' to match '{'`). The driver
  collapses every multi-line expression to one line before sending it
  — write new eval snippets the same way (or just add to `driver.mjs`,
  which already does this via its `one()` helper).
- **Screenshot pixels ≠ logical coordinates.** `xcrun simctl` screenshots
  are physical pixels (this device: 1206×2622); `tap x y` wants logical
  points (402×874, i.e. divide by `devicePixelRatio` = 3.0 here). Get
  it wrong and taps land on the wrong widget with no error. Prefer
  `tapText` over computing pixel math by hand.
- **`type` must target the *focused* field, not the first one found.**
  A naive "find the first `EditableTextState` in the tree" walk always
  hits the first `TextField` in the whole page (e.g. the top "ID do
  paciente" field), silently overwriting it instead of whatever you
  just tapped. `driver.mjs` checks `s.widget.focusNode.hasFocus` —
  always `tapText`/`tap` a field immediately before `type`-ing into it.
- **`RenderBox.localToGlobal` can throw mid page-transition.** Widgets
  under a `FractionalTranslation` (used by the default route slide
  transition) assert if you read `.size`/call `localToGlobal` while a
  push/pop animation is in flight. `dump` and `tapText` swallow this
  per-widget (`try { ... } catch (_) {}`) so one animating widget
  doesn't blank the whole result — if you see fewer widgets than
  expected right after navigating, wait ~300ms and re-run.
- **`dump` shows widgets from routes still mounted underneath.** GoRouter's
  `push` (used by the home page's FAB) keeps the previous page in the
  `Navigator` stack; `dump` right after navigating can show both the
  new page's fields and the old page's text (at odd/negative
  coordinates, since they're offscreen). Not a bug — just don't be
  surprised by duplicate/negative-position entries.
- **A tap can occasionally crash the VM Service `evaluate` call itself**
  with an unrelated-looking framework assertion
  (`'match != null': Expected ... to match RegExp` in
  `stack_frame.dart`), seen once tapping "Salvar". This is a
  debug-mode bug in Flutter's own error reporting when it tries to
  format a stack trace containing the synthetic eval frame — it does
  **not** mean the tap failed or the app crashed (`route`/`dump`
  still worked immediately after). If a driver command reports this
  error, just re-run the same command.

## Troubleshooting

- **`node driver.mjs launch` times out ("Timed out waiting for
  app.debugPort")**: check `.claude/skills/run-nutri-calc/.flutter-machine.log`
  — usually a Gradle/Xcode build failure printed as a `daemon` JSON
  event, not a Node error.
- **`driver.mjs` command fails with "No state.json - run `launch`
  first"**: the driver has no memory between processes other than that
  file; if you deleted it or moved directories, run `launch` again.
