part of '../zego_signaling_plugin_interface.dart';

mixin ZegoSignalingPluginNotificationAPI {
  Future<ZegoSignalingPluginEnableNotifyResult>
      enableNotifyWhenAppRunningInBackgroundOrQuit({
    bool isIOSSandboxEnvironment = false,
  });
}

mixin ZegoSignalingPluginNotificationEvent {
  Stream<ZegoSignalingPluginNotificationRegisteredEvent>
      getNotificationRegisteredEventStream();

  Stream<ZegoSignalingPluginNotificationArrivedEvent>
      getNotificationArrivedEventStream();

  Stream<ZegoSignalingPluginNotificationClickedEvent>
      getNotificationClickedEventStream();
}
