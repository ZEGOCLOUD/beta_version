// Project imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';

mixin ZegoPluginNotificationService {
  /// enable notification
  Future<ZegoSignalingPluginEnableNotifyResult>
      enableNotifyWhenAppRunningInBackgroundOrQuit(
    bool enabled, {
    bool isIOSSandboxEnvironment = false,
  }) {
    return ZegoSignalingPluginCore.shared.coreData
        .enableNotifyWhenAppRunningInBackgroundOrQuit(
      enabled,
      isIOSSandboxEnvironment: isIOSSandboxEnvironment,
    );
  }
}
