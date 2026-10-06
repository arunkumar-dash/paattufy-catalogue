import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermission { audio, notifications, bluetooth, allFiles }

extension AppPermissionInfo on AppPermission {
  Permission get permission => switch (this) {
        AppPermission.audio => Permission.audio,
        AppPermission.notifications => Permission.notification,
        AppPermission.bluetooth => Permission.bluetoothConnect,
        AppPermission.allFiles => Permission.manageExternalStorage,
      };

  String get title => switch (this) {
        AppPermission.audio => 'Music & audio',
        AppPermission.notifications => 'Notifications',
        AppPermission.bluetooth => 'Bluetooth',
        AppPermission.allFiles => 'All files access',
      };

  String get reason => switch (this) {
        AppPermission.audio => 'To find the songs on your device. Paattufy only reads them.',
        AppPermission.notifications => 'For the playback controls on your lock screen and notification shade.',
        AppPermission.bluetooth => 'To show which Bluetooth speaker or headphones are playing.',
        AppPermission.allFiles => 'To read lyrics files next to songs, save downloads to your chosen folder and edit tags.',
      };
}

class PermissionsService {
  Future<bool> isGranted(AppPermission p) => p.permission.isGranted;
  Future<bool> request(AppPermission p) async => (await p.permission.request()).isGranted;
  Future<void> openSettings() => openAppSettings();
}

final permissionsServiceProvider = Provider<PermissionsService>((ref) => PermissionsService());

final permissionStatusProvider = FutureProvider.autoDispose.family<bool, AppPermission>(
  (ref, p) => ref.watch(permissionsServiceProvider).isGranted(p),
);
