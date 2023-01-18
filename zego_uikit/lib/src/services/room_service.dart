part of 'uikit_service.dart';

mixin ZegoRoomService {
  /// join room
  Future<ZegoRoomLoginResult> joinRoom(
    String roomID, {
    String token = '',
    bool markAsLargeRoom = false,
  }) async {
    return await ZegoUIKitCore.shared.joinRoom(
      roomID,
      token: token,
      markAsLargeRoom: markAsLargeRoom,
    );
  }

  /// leave room
  Future<ZegoRoomLogoutResult> leaveRoom() async {
    return await ZegoUIKitCore.shared.leaveRoom();
  }

  /// get room object
  ZegoUIKitRoom getRoom() {
    return ZegoUIKitCore.shared.coreData.room.toUIKitRoom();
  }

  /// get room state notifier
  ValueNotifier<ZegoUIKitRoomState> getRoomStateStream() {
    return ZegoUIKitCore.shared.coreData.room.state;
  }

  /// update one room property
  Future<bool> setRoomProperty(String key, String value) async {
    return ZegoUIKitCore.shared.setRoomProperty(key, value);
  }

  /// update room properties
  Future<bool> updateRoomProperties(Map<String, String> properties) async {
    return ZegoUIKitCore.shared
        .updateRoomProperties(Map<String, String>.from(properties));
  }

  /// get room properties
  Map<String, RoomProperty> getRoomProperties() {
    return Map<String, RoomProperty>.from(
        ZegoUIKitCore.shared.coreData.room.properties);
  }

  /// only notify the property which changed
  /// you can get full properties by getRoomProperties() function
  Stream<RoomProperty> getRoomPropertyStream() {
    return ZegoUIKitCore.shared.coreData.room.propertyUpdateStream.stream;
  }

  /// only notify the properties which changed
  /// you can get full properties by getRoomProperties() function
  Stream<Map<String, RoomProperty>> getRoomPropertiesStream() {
    return ZegoUIKitCore.shared.coreData.room.propertiesUpdatedStream.stream;
  }

  /// get network state notifier
  Stream<ZegoNetworkMode> getNetworkModeStream() {
    return ZegoUIKitCore.shared.coreData.networkModeStreamCtrl.stream;
  }
}
