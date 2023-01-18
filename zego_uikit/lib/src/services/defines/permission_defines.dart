// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:zego_uikit/src/services/uikit_service.dart';

export 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermission(Permission permission) async {
  var status = await permission.request();
  if (status != PermissionStatus.granted) {
    ZegoLoggerService.logInfo(
      'Error: ${permission.toString()} permission not granted, $status',
      tag: "uikit",
      subTag: "permission",
    );
    return false;
  }

  return true;
}
