// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoUIKitRoom {
  String id = '';

  ZegoUIKitRoom({required this.id});
}

class ZegoUIKitRoomState {
  ///  Room state change reason.
  ZegoRoomStateChangedReason reason;

  /// Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for details.
  int errorCode;

  /// Extended Information with state updates. When the room login is successful, the key "room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, which identifies the continuous communication from the first user in the room to the end of the audio and video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
  Map<String, dynamic> extendedData;

  ZegoUIKitRoomState(this.reason, this.errorCode, this.extendedData);
}

class RoomProperty {
  String key = "";
  String value = "";
  String? oldValue;
  int updateTime = 0;
  String updateUserID = "";

  RoomProperty(this.key, this.value, this.updateTime, this.updateUserID);

  RoomProperty.copyFrom(RoomProperty property)
      : key = property.key,
        value = property.value,
        oldValue = property.oldValue,
        updateTime = property.updateTime,
        updateUserID = property.updateUserID;

  void copyFrom(RoomProperty property) {
    key = property.key;
    value = property.value;
    oldValue = property.oldValue;
    updateTime = property.updateTime;
    updateUserID = property.updateUserID;
  }

  @override
  String toString() {
    return "key:$key, value:$value, old value:$oldValue, update time:$updateTime, update user id:$updateUserID";
  }
}

enum RoomPropertyKey {
  host,
  liveStatus,
}

extension RoomPropertyKeyExtension on RoomPropertyKey {
  static Map<String, RoomPropertyKey> textValues = {
    "host": RoomPropertyKey.host,
    "live_status": RoomPropertyKey.liveStatus,
  };

  String get text {
    var mapValues = {
      RoomPropertyKey.host: "host",
      RoomPropertyKey.liveStatus: "live_status",
    };

    return mapValues[this]!;
  }
}
