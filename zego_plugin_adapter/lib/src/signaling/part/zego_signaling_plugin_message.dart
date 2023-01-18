part of '../zego_signaling_plugin_interface.dart';

mixin ZegoSignalingPluginMessageAPI {
  Future<ZegoSignalingPluginInRoomTextMessageResult> sendInRoomTextMessage({
    required String roomID,
    required String message,
  });
}

mixin ZegoSignalingPluginMessageEvent {
  Stream<ZegoSignalingPluginInRoomTextMessageReceivedEvent>
      getInRoomTextMessageReceivedEventStream();
}
