#!/usr/bin/env node
// Driver for nutri_calc (Flutter app) - launches on a device/simulator and
// drives the running app over the Dart VM Service (evaluate expressions in
// the app's isolate: walk the widget tree, synthesize taps, fill text
// fields, read the current route). No test framework or Playwright needed -
// this talks to the real running app.
//
// Usage:
//   node driver.mjs launch [deviceId]      start `flutter run`, wait for VM Service, save state
//   node driver.mjs screenshot <file.png>  simctl screenshot (iOS simulator only)
//   node driver.mjs dump                   list on-screen Text/Icon widgets with center coords
//   node driver.mjs route                  print the current AppRoutes value
//   node driver.mjs tap <x> <y>            synthesize a tap at LOGICAL coords (not screenshot pixels)
//   node driver.mjs tapText <substring>    find a Text widget containing substring, tap its center
//   node driver.mjs type <text>            set the value of the currently focused text field
//   node driver.mjs eval <dart-expr>       raw expression evaluated in lib/main.dart's scope
//   node driver.mjs stop                   kill the `flutter run` process
//
// State (pid, wsUri, deviceId) is kept in .state.json next to this file.

import { spawn } from 'node:child_process';
import { readFileSync, writeFileSync, existsSync, openSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const STATE_FILE = path.join(HERE, '.state.json');
const LOG_FILE = path.join(HERE, '.flutter-machine.log');

function loadState() {
  if (!existsSync(STATE_FILE)) throw new Error('No state.json - run `launch` first');
  return JSON.parse(readFileSync(STATE_FILE, 'utf8'));
}

// ---- VM Service RPC ----------------------------------------------------

function connect(wsUri) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUri);
    let id = 0;
    const pending = new Map();
    ws.onmessage = (e) => {
      const m = JSON.parse(e.data);
      if (m.id && pending.has(m.id)) {
        const p = pending.get(m.id);
        pending.delete(m.id);
        m.error ? p.rej(new Error(JSON.stringify(m.error))) : p.res(m.result);
      }
    };
    ws.onerror = (e) => reject(e);
    ws.onopen = () => {
      const rpc = (method, params = {}) => {
        const i = String(++id);
        ws.send(JSON.stringify({ jsonrpc: '2.0', id: i, method, params }));
        return new Promise((res, rej) => pending.set(i, { res, rej }));
      };
      resolve({ ws, rpc });
    };
  });
}

// The VM Service expression compiler chokes on newlines (they truncate the
// expression at the first line). Every `evaluate` call must be one line.
const one = (s) => s.split('\n').map((l) => l.trim()).filter(Boolean).join(' ');

async function evalDart(expression) {
  const { wsUri } = loadState();
  const { ws, rpc } = await connect(wsUri);
  const vm = await rpc('getVM');
  const isolateId = vm.isolates[0].id;
  const rootLib = (await rpc('getIsolate', { isolateId })).rootLib.id;
  let result;
  try {
    result = await rpc('evaluate', { isolateId, targetId: rootLib, expression: one(expression) });
  } finally {
    ws.close();
  }
  if (result.type === 'Sentinel') throw new Error('Sentinel: ' + JSON.stringify(result));
  return result.valueAsString ?? JSON.stringify(result);
}

// ---- Commands ------------------------------------------------------------

async function launch(deviceId) {
  const args = ['run', '--machine'];
  if (deviceId) args.push('-d', deviceId);
  const out = openSync(LOG_FILE, 'w');
  const child = spawn('flutter', args, { cwd: path.join(HERE, '..', '..', '..'), detached: true, stdio: ['ignore', out, out] });
  child.unref();

  const deadline = Date.now() + 120_000;
  let wsUri;
  while (Date.now() < deadline) {
    await new Promise((r) => setTimeout(r, 1000));
    if (!existsSync(LOG_FILE)) continue;
    const log = readFileSync(LOG_FILE, 'utf8');
    const m = log.match(/"wsUri":"([^"]+)"/);
    if (m) {
      wsUri = m[1];
      break;
    }
  }
  if (!wsUri) throw new Error('Timed out waiting for app.debugPort - check .flutter-machine.log');
  writeFileSync(STATE_FILE, JSON.stringify({ pid: child.pid, wsUri, deviceId: deviceId ?? null }, null, 2));
  console.log('launched, pid', child.pid, 'wsUri', wsUri);
}

function stop() {
  const { pid } = loadState();
  try {
    process.kill(-pid);
  } catch {
    try {
      process.kill(pid);
    } catch {}
  }
  console.log('stopped', pid);
}

async function screenshot(file) {
  const { deviceId } = loadState();
  const { execFileSync } = await import('node:child_process');
  if (deviceId) {
    execFileSync('xcrun', ['simctl', 'io', deviceId, 'screenshot', file], { stdio: 'inherit' });
  } else {
    execFileSync('xcrun', ['simctl', 'io', 'booted', 'screenshot', file], { stdio: 'inherit' });
  }
  console.log('wrote', file);
}

const DUMP_EXPR = `
(() {
  final out = <String>[];
  void walk(Element el) {
    final w = el.widget;
    final ro = el.renderObject;
    String? label;
    if (w is Text && w.data != null) label = 'Text:' + w.data!;
    if (w is Icon && w.icon != null) label = 'Icon:U+' + w.icon!.codePoint.toRadixString(16);
    if (label != null && ro is RenderBox && ro.hasSize && ro.attached) {
      try {
        final o = ro.localToGlobal(Offset.zero);
        out.add(label + '@' + (o.dx + ro.size.width / 2).toStringAsFixed(0) + ',' + (o.dy + ro.size.height / 2).toStringAsFixed(0));
      } catch (_) {}
    }
    el.visitChildren(walk);
  }
  WidgetsBinding.instance.rootElement!.visitChildren(walk);
  return out.join(' | ');
})()`;

async function dump() {
  console.log(await evalDart(DUMP_EXPR));
}

async function route() {
  console.log(await evalDart(`getIt.get<AppRouter>().currentRoute.toString()`));
}

async function tap(x, y) {
  const expr = `
(() {
  final p = Offset(${x}, ${y});
  final binding = WidgetsBinding.instance;
  binding.handlePointerEvent(PointerDownEvent(position: p, pointer: 90001));
  binding.handlePointerEvent(PointerUpEvent(position: p, pointer: 90001));
  return 'tapped';
})()`;
  console.log(await evalDart(expr));
}

async function tapText(needle) {
  const escaped = needle.replace(/'/g, "\\'").toLowerCase();
  const expr = `
(() {
  Offset? center;
  void walk(Element el) {
    if (center != null) return;
    final w = el.widget;
    final ro = el.renderObject;
    if (w is Text && w.data != null && w.data!.toLowerCase().contains('${escaped}') && ro is RenderBox && ro.hasSize && ro.attached) {
      try {
        final o = ro.localToGlobal(Offset.zero);
        center = Offset(o.dx + ro.size.width / 2, o.dy + ro.size.height / 2);
      } catch (_) {}
    }
    el.visitChildren(walk);
  }
  WidgetsBinding.instance.rootElement!.visitChildren(walk);
  if (center == null) return 'NOTFOUND';
  final binding = WidgetsBinding.instance;
  binding.handlePointerEvent(PointerDownEvent(position: center!, pointer: 90002));
  binding.handlePointerEvent(PointerUpEvent(position: center!, pointer: 90002));
  return 'tapped ' + center.toString();
})()`;
  console.log(await evalDart(expr));
}

async function type(text) {
  const escaped = text.replace(/'/g, "\\'");
  const expr = `
(() {
  EditableTextState? found;
  void walk(Element el) {
    if (found != null) return;
    if (el is StatefulElement && el.state is EditableTextState) {
      final s = el.state as EditableTextState;
      if (s.widget.focusNode.hasFocus) found = s;
    }
    el.visitChildren(walk);
  }
  WidgetsBinding.instance.rootElement!.visitChildren(walk);
  if (found == null) return 'NO_FOCUSED_FIELD';
  found!.userUpdateTextEditingValue(TextEditingValue(text: '${escaped}', selection: TextSelection.collapsed(offset: ${text.length})), SelectionChangedCause.keyboard);
  return 'typed';
})()`;
  console.log(await evalDart(expr));
}

// ---- CLI -------------------------------------------------------------

const [, , cmd, ...rest] = process.argv;
try {
  switch (cmd) {
    case 'launch':
      await launch(rest[0]);
      break;
    case 'stop':
      stop();
      break;
    case 'screenshot':
      await screenshot(rest[0]);
      break;
    case 'dump':
      await dump();
      break;
    case 'route':
      await route();
      break;
    case 'tap':
      await tap(rest[0], rest[1]);
      break;
    case 'tapText':
      await tapText(rest.join(' '));
      break;
    case 'type':
      await type(rest.join(' '));
      break;
    case 'eval':
      console.log(await evalDart(rest.join(' ')));
      break;
    default:
      console.error('Unknown command:', cmd);
      console.error('Usage: node driver.mjs <launch|stop|screenshot|dump|route|tap|tapText|type|eval> [...args]');
      process.exit(1);
  }
} catch (err) {
  console.error('ERROR:', err.message ?? err);
  process.exit(1);
}
