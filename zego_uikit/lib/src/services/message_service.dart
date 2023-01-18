part of 'uikit_service.dart';

mixin ZegoMessageService {
  /// get in-room messages
  List<ZegoInRoomMessage> getInRoomMessages() {
    return ZegoUIKitCore.shared.coreMessage.messageList;
  }

  /// get in-room messages notifier
  Stream<List<ZegoInRoomMessage>> getInRoomMessageListStream() {
    return ZegoUIKitCore.shared.coreMessage.streamControllerMessageList.stream;
  }

  /// get in-room messages one-by-one notifier
  Stream<ZegoInRoomMessage> getInRoomMessageStream() {
    return ZegoUIKitCore.shared.coreMessage.streamControllerMessage.stream;
  }

  /// send in-room message
  void sendInRoomMessage(String message) {
    return ZegoUIKitCore.shared.coreMessage.sendBroadcastMessage(message);
  }

  /// re-send in-room message
  void resendInRoomMessage(ZegoInRoomMessage message) {
    return ZegoUIKitCore.shared.coreMessage.resendInRoomMessage(message);
  }
}
