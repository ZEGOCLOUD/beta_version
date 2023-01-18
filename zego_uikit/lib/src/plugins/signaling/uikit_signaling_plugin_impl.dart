// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/invitation_plugin_service.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/notification_service.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/service/room_properties.dart';
import 'package:zego_uikit/zego_uikit.dart';

import 'package:zego_uikit/src/plugins/signaling/impl/service/user_attributes.dart';
export 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

class ZegoUIKitSignalingPluginImpl
    with
        ZegoPluginInvitationService,
        ZegoPluginNotificationService,
        ZegoUIKitRoomAttributesPluginService,
        ZegoUIKitUserInRoomAttributesPluginService {
  factory ZegoUIKitSignalingPluginImpl() => shared;
  ZegoUIKitSignalingPluginImpl._internal() {
    WidgetsFlutterBinding.ensureInitialized();
    assert(ZegoPluginAdapter().signalingPlugin != null,
        'ZegoUIKitSignalingPluginImpl: ZegoUIKitPluginType.signaling is null');
  }
  static final ZegoUIKitSignalingPluginImpl shared =
      ZegoUIKitSignalingPluginImpl._internal();

  /// init
  Future<void> init(
    int appID, {
    String appSign = '',
  }) async {
    initUserInRoomAttributes();
    return ZegoSignalingPluginCore.shared.init(appID: appID, appSign: appSign);
  }

  /// uninit
  Future<void> uninit() async {
    uninitUserInRoomAttributes();

    return ZegoSignalingPluginCore.shared.uninit();
  }

  /// login
  Future<void> login({
    required String id,
    required String name,
  }) async {
    return ZegoSignalingPluginCore.shared.login(id, name);
  }

  /// logout
  Future<void> logout() async {
    return ZegoSignalingPluginCore.shared.logout();
  }

  /// join room
  Future<ZegoSignalingPluginJoinRoomResult> joinRoom(String roomID,
      {String roomName = ''}) async {
    return ZegoSignalingPluginCore.shared.joinRoom(roomID, roomName);
  }

  /// leave room
  Future<void> leaveRoom() async {
    return ZegoSignalingPluginCore.shared.leaveRoom();
  }

  Stream<ZegoSignalingPluginConnectionStateChangedEvent>
      getConnectionStateStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getConnectionStateChangedEventStream();
  }

  Stream<ZegoSignalingPluginRoomStateChangedEvent> getRoomStateStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getRoomStateChangedEventStream();
  }
}
