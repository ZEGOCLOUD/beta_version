// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:zego_uikit/src/plugins/signaling/impl/service/user_attributes_p.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoUIKitUserInRoomAttributesPluginService {
  final _private = ZegoUIKitUserInRoomAttributesPluginServicePrivate();

  void initUserInRoomAttributes() {
    ZegoLoggerService.logInfo(
      'user in-room init',
      tag: 'uikit',
      subTag: 'user attributes',
    );
    _private.init();
  }

  void uninitUserInRoomAttributes() {
    ZegoLoggerService.logInfo(
      'user in-room uninit',
      tag: 'uikit',
      subTag: 'user attributes',
    );
    _private.uninit();
  }

  /// set users in-room attributes
  Future<ZegoSignalingPluginSetUsersInRoomAttributesResult>
      setUsersInRoomAttributes(
          {required String roomID,
          required String key,
          required String value,
          required List<String> userIDs}) async {
    return ZegoPluginAdapter().signalingPlugin!.setUsersInRoomAttributes(
          roomID: roomID,
          setAttributes: {key: value},
          userIDs: userIDs,
        );
  }

  /// query user in-room attributes
  Future<ZegoSignalingPluginQueryUsersInRoomAttributesResult>
      queryUsersInRoomAttributes({
    required String roomID,
    String nextFlag = '',
    int count = 100,
  }) async {
    final result =
        await ZegoPluginAdapter().signalingPlugin!.queryUsersInRoomAttributes(
              roomID: roomID,
              nextFlag: nextFlag,
              count: count,
            );

    if (result.error != null) {
      _private.updateUserInRoomAttributes(result.attributes);
    }

    return result;
  }

  /// get users in-room attributes notifier
  Stream<ZegoSignalingPluginUsersInRoomAttributesUpdatedEvent>
      getUsersInRoomAttributesStream() {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .getUsersInRoomAttributesUpdatedEventStream();
  }
}
