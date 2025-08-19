import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> requestSMSPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<Map<Permission, bool>> checkAllPermissions() async {
    final notification = await Permission.notification.status;
    final location = await Permission.location.status;
    final sms = await Permission.sms.status;

    return {
      Permission.notification: notification.isGranted,
      Permission.location: location.isGranted,
      Permission.sms: sms.isGranted,
    };
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
