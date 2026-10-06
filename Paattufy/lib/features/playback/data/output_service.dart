import 'dart:async';

import 'package:flutter/services.dart';

/// A selectable audio output (AP §3.6).
class OutputDevice {
  const OutputDevice({required this.id, required this.kind, required this.name, required this.active});
  final int id;

  /// 'speaker' | 'wired' | 'bluetooth'
  final String kind;
  final String name;
  final bool active;
}

/// Output route as the UI shows it.
class OutputRoute {
  const OutputRoute(this.kind, this.name);

  /// 'speaker' | 'wired' | 'bluetooth'
  final String kind;
  final String name;

  static OutputRoute parse(String route) {
    if (route == 'speaker' || route.isEmpty) return const OutputRoute('speaker', 'Phone speaker');
    final i = route.indexOf(':');
    if (i < 0) return OutputRoute(route, route);
    return OutputRoute(route.substring(0, i), route.substring(i + 1));
  }

  String get label => kind == 'speaker' ? 'Phone speaker' : name;
}

/// Platform access for route awareness (TP §5.5) — a seam so the watcher is
/// testable without a device.
abstract class OutputPlatform {
  Future<String> currentRoute();
  Stream<String> get routeChanges;
  Future<List<OutputDevice>> listOutputs();
  Future<bool> openSwitcher();
  Future<bool> openEqualizer(int audioSessionId);
}

class NativeOutputPlatform implements OutputPlatform {
  NativeOutputPlatform({MethodChannel? method, EventChannel? events, MethodChannel? system})
      : _method = method ?? const MethodChannel('paattufy/output'),
        _events = events ?? const EventChannel('paattufy/output_events'),
        _system = system ?? const MethodChannel('paattufy/system');

  final MethodChannel _method;
  final EventChannel _events;
  final MethodChannel _system;

  @override
  Future<String> currentRoute() async => (await _method.invokeMethod<String>('currentRoute')) ?? 'speaker';

  @override
  Stream<String> get routeChanges => _events.receiveBroadcastStream().map((e) => e as String);

  @override
  Future<List<OutputDevice>> listOutputs() async {
    final raw = await _method.invokeListMethod<Map<Object?, Object?>>('listOutputs') ?? const [];
    return [
      for (final m in raw)
        OutputDevice(
          id: (m['id'] as num).toInt(),
          kind: m['kind'] as String,
          name: m['name'] as String,
          active: m['active'] == true,
        ),
    ];
  }

  @override
  Future<bool> openSwitcher() async => (await _method.invokeMethod<bool>('openSwitcher')) ?? false;

  @override
  Future<bool> openEqualizer(int audioSessionId) async =>
      (await _system.invokeMethod<bool>('openEqualizer', {'audioSessionId': audioSessionId})) ?? false;
}

/// Watches the output route and reports every *real* change. The controller
/// reacts by stopping playback — for every route change, no exceptions
/// (AP §3.6). Duplicate events for the same route are swallowed so a chatty
/// platform never stops playback spuriously.
class OutputWatcher {
  OutputWatcher(this._platform, {required this._onChange});

  final OutputPlatform _platform;
  final Future<void> Function(String route) _onChange;
  StreamSubscription<String>? _sub;
  String? _last;

  String get current => _last ?? 'speaker';

  Future<void> start() async {
    _last = await _platform.currentRoute();
    _sub = _platform.routeChanges.listen((route) async {
      if (route == _last) return;
      _last = route;
      await _onChange(route);
    });
  }

  Future<void> dispose() async => _sub?.cancel();
}
