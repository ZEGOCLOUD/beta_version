// Project imports:
import 'user_defines.dart';

const removeUserInRoomCommandKey = "zego_remove_user";
const turnCameraOnInRoomCommandKey = "zego_turn_camera_on";
const turnCameraOffInRoomCommandKey = "zego_turn_camera_off";
const turnMicrophoneOnInRoomCommandKey = "zego_turn_microphone_on";
const turnMicrophoneOffInRoomCommandKey = "zego_turn_microphone_off";

class ZegoInRoomCommandReceivedData {
  ZegoUIKitUser fromUser;
  String command;

  ZegoInRoomCommandReceivedData({
    required this.fromUser,
    required this.command,
  });
}
