// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Package imports:

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/event.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/invitation_data.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/notification_data.dart';

class ZegoSignalingPluginCoreData
    with
        ZegoSignalingPluginCoreInvitationData,
        ZegoSignalingPluginCoreNotificationData,
        ZegoSignalingPluginCoreEvent {
  bool inited = false;
  String? currentUserID;
  String? currentUserName;
  String? currentRoomID;
  String? currentRoomName;

  /// create engine
  Future<void> create({required int appID, String appSign = ''}) async {
    if (ZegoPluginAdapter().signalingPlugin == null) return;
    if (inited) {
      debugPrint('[zim] has created.');
      return;
    }

    ZegoPluginAdapter().signalingPlugin!.init(appID: appID, appSign: appSign);
    inited = true;

    debugPrint('[zim] create, appID:$appID');
  }

  /// destroy engine
  Future<void> destroy() async {
    if (ZegoPluginAdapter().signalingPlugin == null) return;
    if (inited) {
      debugPrint('[zim] is not created.');
      return;
    }

    ZegoPluginAdapter().signalingPlugin!.uninit();
    inited = false;
    debugPrint('[zim] destroy.');
    clear();
  }

  /// login
  Future<void> login(String id, String name) async {
    if (ZegoPluginAdapter().signalingPlugin == null) return;
    if (!inited) {
      debugPrint('[zim] is not created.');
      return;
    }

    if (currentUserID != null) {
      debugPrint('[zim] user has login.');
      return;
    }

    debugPrint('[zim] login request, user id:$id, user name:$name');
    currentUserID = id;
    currentUserName = name;

    debugPrint('[zim] ready to login..');

    final pluginResult = await ZegoPluginAdapter()
        .signalingPlugin!
        .connectUser(id: id, name: name);

    if (pluginResult.error == null) {
      debugPrint('[zim] login success');
    } else {
      debugPrint('[zim] login error, ${pluginResult.error}');
    }
  }

  /// logout
  Future<void> logout() async {
    if (ZegoPluginAdapter().signalingPlugin == null) return;
    debugPrint('user logout');

    currentUserID = null;
    currentUserName = null;

    final pluginResult =
        await ZegoPluginAdapter().signalingPlugin!.disconnectUser();

    if (pluginResult.timeout) {
      debugPrint('[zim] logout waitForDisconnect timeout');
    } else {
      debugPrint('[zim] logout success');
    }

    clear();
    debugPrint('[zim] logout.');
  }

  /// join room
  Future<ZegoSignalingPluginJoinRoomResult> joinRoom(
      String roomID, String roomName) async {
    if (!inited) {
      debugPrint('[zim] is not created.');
      return ZegoSignalingPluginJoinRoomResult(
        error: PlatformException(code: '-1', message: 'zim is not created.'),
      );
    }
    if (ZegoPluginAdapter().signalingPlugin == null) {
      return ZegoSignalingPluginJoinRoomResult(
        error: PlatformException(code: '-2', message: 'signaling is null'),
      );
    }

    if (currentRoomID != null) {
      debugPrint('[zim] room has login.');
      return ZegoSignalingPluginJoinRoomResult(
        error: PlatformException(code: '-3', message: 'room has login.'),
      );
    }

    currentRoomID = roomID;
    currentRoomName = roomName;

    debugPrint('[zim] join room, room id:"$roomID", room name:$roomName');

    final pluginResult = await ZegoPluginAdapter()
        .signalingPlugin!
        .joinRoom(roomID: roomID, roomName: roomName);

    if (pluginResult.error == null) {
      debugPrint('[zim] join room success');
    } else {
      debugPrint('[zim] exception on join room, ${pluginResult.error}');
      currentRoomID = null;
      currentRoomName = null;
    }
    return pluginResult;
  }

  /// leave room
  Future<void> leaveRoom() async {
    if (ZegoPluginAdapter().signalingPlugin == null) return;
    if (!inited) {
      debugPrint('[zim] is not created.');
      return;
    }

    if (currentRoomID == null) {
      debugPrint('[zim] room has not login.');
      return;
    }

    debugPrint('[zim] ready to leave room ${currentRoomID!}');
    final pluginResult = await ZegoPluginAdapter()
        .signalingPlugin!
        .leaveRoom(roomID: currentRoomID!);

    if (pluginResult.error == null) {
      debugPrint('[zim] leave room faild with ${pluginResult.error}}');
      currentRoomID = null;
    } else {
      debugPrint('[zim] leave room success');
    }
  }

  /// clear
  void clear() {
    debugPrint('[zim] clear');
    clearInvitationData();

    currentUserID = null;
    currentUserName = null;
    currentRoomID = null;
    currentRoomName = null;
  }

  ///  on error
  void onError(ZegoSignalingPluginErrorEvent event) {
    debugPrint('[zim] zim error, $event');
  }

  /// on connection state changed
  void onConnectionStateChanged(
      ZegoSignalingPluginConnectionStateChangedEvent event) {
    debugPrint('[zim] connection state changed, $event');

    if (event.state == ZegoSignalingPluginConnectionState.disconnected) {
      debugPrint('[zim] disconnected, auto logout');
      // TODO 这个逻辑怎么搞 zimkit一起用的话估计是有问题的
      logout();
    }
  }

  /// on room state changed
  void onRoomStateChanged(ZegoSignalingPluginRoomStateChangedEvent event) {
    debugPrint('[zim] room state changed, $event');

    if (event.state == ZegoSignalingPluginRoomState.disconnected) {
      debugPrint('[zim] room has been disconnect.');
      currentRoomID = null;
      currentRoomName = null;
    }
  }
}
