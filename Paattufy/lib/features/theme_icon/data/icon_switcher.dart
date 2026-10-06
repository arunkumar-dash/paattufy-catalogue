import 'package:flutter/services.dart';

/// Runtime launcher-icon swap via activity-aliases (AP §3.7b, TP §5.8).
class IconSwitcher {
  IconSwitcher([MethodChannel? channel]) : _channel = channel ?? const MethodChannel('paattufy/icon_switch');
  final MethodChannel _channel;

  Future<int> current() async => (await _channel.invokeMethod<int>('current')) ?? 0;
  Future<bool> set(int variant) async => (await _channel.invokeMethod<bool>('set', {'variant': variant})) ?? false;
}
