part of 'zego_uikit_core.dart';

class ZegoUIKitCoreMessage {
  int localMessageId = 0;
  List<ZegoInRoomMessage> messageList = []; // uid:user

  StreamController<List<ZegoInRoomMessage>> streamControllerMessageList =
      StreamController<List<ZegoInRoomMessage>>.broadcast();
  StreamController<ZegoInRoomMessage> streamControllerMessage = StreamController<ZegoInRoomMessage>.broadcast();

  void onIMRecvBroadcastMessage(
      String roomID, List<ZegoBroadcastMessageInfo> _messageList) {
    for (final _message in _messageList) {
      final message = ZegoInRoomMessage.fromBroadcastMessage(_message);
      streamControllerMessage.add(message);
      messageList.add(message);
    }

    if (messageList.length > 500) {
      messageList.removeRange(0, messageList.length - 500);
    }

    streamControllerMessageList.add(List<ZegoInRoomMessage>.from(messageList));
  }

  void clear() {
    messageList.clear();
    streamControllerMessageList.add(List<ZegoInRoomMessage>.from(messageList));
  }

  void sendBroadcastMessage(String message) {
    localMessageId = localMessageId - 1;

    final messageItem = ZegoInRoomMessage(
      messageID: localMessageId,
      user: ZegoUIKitCore.shared.coreData.localUser.toZegoUikitUser(),
      message: message,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    messageItem.state.value = ZegoInRoomMessageState.idle;

    messageList.add(messageItem);
    streamControllerMessageList.add(List<ZegoInRoomMessage>.from(messageList));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (ZegoInRoomMessageState.idle == messageItem.state.value) {
        /// if the status is still Idle after 300 ms,  it mean the message is not sent yet.
        messageItem.state.value = ZegoInRoomMessageState.sending;
        streamControllerMessageList
            .add(List<ZegoInRoomMessage>.from(messageList));
      }
    });

    ZegoExpressEngine.instance
        .sendBroadcastMessage(ZegoUIKitCore.shared.coreData.room.id, message)
        .then((ZegoIMSendBroadcastMessageResult result) {
      messageItem.state.value = (result.errorCode == 0)
          ? ZegoInRoomMessageState.success
          : ZegoInRoomMessageState.failed;
      streamControllerMessageList
          .add(List<ZegoInRoomMessage>.from(messageList));
    });
  }

  void resendInRoomMessage(ZegoInRoomMessage message) {
    messageList
        .removeWhere((element) => element.messageID == message.messageID);
    sendBroadcastMessage(message.message);
  }
}
