// Dart imports:

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Package imports:

// Project imports:

mixin ZegoSignalingPluginCoreNotificationData {
  bool notifyWhenAppIsInTheBackgroundOrQuit = false;

  /// enable notification
  Future<ZegoSignalingPluginEnableNotifyResult>
      enableNotifyWhenAppRunningInBackgroundOrQuit(
    bool enabled, {
    bool isIOSSandboxEnvironment = false,
  }) {
    debugPrint('[zim notification] enable notify when app is in '
        'the background or quit: $enabled');
    notifyWhenAppIsInTheBackgroundOrQuit = enabled;

    return ZegoPluginAdapter()
        .signalingPlugin!
        .enableNotifyWhenAppRunningInBackgroundOrQuit(
          isIOSSandboxEnvironment: isIOSSandboxEnvironment,
        );
  }
}
