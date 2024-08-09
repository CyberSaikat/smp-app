import 'package:permission_handler/permission_handler.dart';

class RequestPermission {
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.storage.request();
    }
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
