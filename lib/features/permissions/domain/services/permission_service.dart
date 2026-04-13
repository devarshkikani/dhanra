import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestSMSPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<void> openSystemAppSettings() async {
    await openAppSettings();
  }
}
