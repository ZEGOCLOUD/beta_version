part of 'uikit_service.dart';

mixin ZegoCustomCommandService {
  /// [toUserIDs] send to everyone if empty
  Future<bool> sendInRoomCommand(
    String command,
    List<String> toUserIDs,
  ) async {
    return ZegoUIKitCore.shared.sendInRoomCommand(command, toUserIDs);
  }

  /// get in-room command received notifier
  Stream<ZegoInRoomCommandReceivedData> getInRoomCommandReceivedStream() {
    return ZegoUIKitCore.shared.coreData.customCommandReceivedStreamCtrl.stream;
  }
}
