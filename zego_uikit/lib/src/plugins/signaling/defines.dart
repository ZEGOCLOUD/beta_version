import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

export 'package:zego_plugin_adapter/zego_plugin_adapter.dart'
    show ZegoSignalingPluginNotificationConfig;

extension ZegoSignalingPluginNotificationConfigToMap
    on ZegoSignalingPluginNotificationConfig {
  Map<String, dynamic> toMap() {
    return {
      'resourceID': resourceID,
      'title': title,
      'message': message,
    };
  }
}

class ZegoNotificationConfig {
  ZegoNotificationConfig({
    this.notifyWhenAppIsInTheBackgroundOrQuit = true,
    this.resourceID = '',
    this.title = '',
    this.message = '',
  });
  bool notifyWhenAppIsInTheBackgroundOrQuit;
  String resourceID;
  String title;
  String message;

  @override
  String toString() {
    return 'title:$title, message:$message, resource id:$resourceID, notify:$notifyWhenAppIsInTheBackgroundOrQuit';
  }
}
