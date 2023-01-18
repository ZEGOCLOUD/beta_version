// Dart imports:
import 'dart:async';

// Project imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/data.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/event.dart';

// Package imports:

class ZegoSignalingPluginCore with ZegoSignalingPluginCoreEvent {
  ZegoSignalingPluginCore._internal();
  static ZegoSignalingPluginCore shared = ZegoSignalingPluginCore._internal();
  ZegoSignalingPluginCoreData coreData = ZegoSignalingPluginCoreData();

  /// get version
  Future<String> getVersion() async {
    return ZegoPluginAdapter().signalingPlugin?.getVersion() ??
        Future.value('signalingPlugin:null');
  }

  /// init
  Future<void> init({required int appID, String appSign = ''}) async {
    initEvent();
    coreData.create(appID: appID, appSign: appSign);
  }

  /// uninit
  Future<void> uninit() async {
    uninitEvent();
    return coreData.destroy();
  }

  /// login
  Future<void> login(String id, String name) async {
    await coreData.login(id, name);
  }

  /// logout
  Future<void> logout() async {
    await coreData.logout();
  }

  /// join room
  Future<ZegoSignalingPluginJoinRoomResult> joinRoom(
      String roomID, String roomName) async {
    return coreData.joinRoom(roomID, roomName);
  }

  /// leave room
  Future<void> leaveRoom() async {
    await coreData.leaveRoom();
  }
}
