import 'dart:core';

import 'package:zego_plugin_adapter/src/defines.dart';
import 'package:zego_plugin_adapter/src/signaling/zego_signaling_plugin_defines.dart';

part 'part/zego_signaling_plugin_user.dart';
part 'part/zego_signaling_plugin_invitation.dart';
part 'part/zego_signaling_plugin_message.dart';
part 'part/zego_signaling_plugin_notification.dart';
part 'part/zego_signaling_plugin_room.dart';

/// For all apis and events, See mixins.
abstract class ZegoSignalingPluginInterface
    with
        ZegoSignalingPluginRoomAPI,
        ZegoSignalingPluginRoomEvent,
        ZegoSignalingPluginInvitationAPI,
        ZegoSignalingPluginInvitationEvent,
        ZegoSignalingPluginUserAPI,
        ZegoSignalingPluginUserEvent,
        ZegoSignalingPluginNotificationAPI,
        ZegoSignalingPluginNotificationEvent,
        ZegoSignalingPluginMessageAPI,
        ZegoSignalingPluginMessageEvent,
        IZegoUIKitPlugin {
  void init({required int appID, String appSign = ''});
  void uninit();

  /// get error event stream
  Stream<ZegoSignalingPluginErrorEvent> getErrorEventStream();
}
