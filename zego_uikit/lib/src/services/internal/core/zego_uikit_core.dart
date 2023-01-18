// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:wakelock/wakelock.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

// Project imports:
part 'zego_uikit_core_defines.dart';

part 'zego_uikit_core_event.dart';

part 'zego_uikit_core_data.dart';

part 'zego_uikit_core_message.dart';

class ZegoUIKitCore with ZegoUIKitCoreEvent {
  ZegoUIKitCore._internal();

  static final ZegoUIKitCore shared = ZegoUIKitCore._internal();

  final ZegoUIKitCoreData coreData = ZegoUIKitCoreData();
  final ZegoUIKitCoreMessage coreMessage = ZegoUIKitCoreMessage();

  bool isInit = false;
  bool isNeedDisableWakelock = false;
  List<StreamSubscription<dynamic>?> subscriptions = [];

  Future<String> getZegoUIKitVersion() async {
    final expressVersion = await ZegoExpressEngine.getVersion();
    const zegoUIKitVersion = 'zego_uikit:1.9.1; ';
    return '${zegoUIKitVersion}zego_express:$expressVersion';
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    ZegoScenario scenario = ZegoScenario.Default,
    String? tokenServerUrl,
  }) async {
    if (isInit) {
      ZegoLoggerService.logInfo(
        'core had init',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    isInit = true;

    final profile = ZegoEngineProfile(appID, scenario, appSign: appSign);
    if (kIsWeb) {
      profile.appSign = null;
      profile.enablePlatformView = true;
    }
    initEventHandle();

    await ZegoExpressEngine.createEngineWithProfile(profile);

    if (!kIsWeb) {
      ZegoExpressEngine.setEngineConfig(ZegoEngineConfig(advancedConfig: {
        'notify_remote_device_unknown_status': 'true',
        'notify_remote_device_init_status': 'true',
      }));

      final initAudioRoute =
          await ZegoExpressEngine.instance.getAudioRouteType();
      coreData.localUser.audioRoute.value = initAudioRoute;
      coreData.localUser.lastAudioRoute = initAudioRoute;
    }

    subscriptions.add(coreData.customCommandReceivedStreamCtrl.stream
        .listen(onInternalCustomCommandReceived));
  }

  Future<void> uninit() async {
    if (!isInit) {
      ZegoLoggerService.logInfo(
        'core is not init',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    isInit = false;

    uninitEventHandle();
    clear();

    for (final subscription in subscriptions) {
      subscription?.cancel();
    }

    await ZegoExpressEngine.destroyEngine();
  }

  void clear() {
    coreData.clear();
    coreMessage.clear();
  }

  @override
  void uninitEventHandle() {}

  Future<void> login(String id, String name) async {
    coreData.login(id, name);
  }

  Future<void> logout() async {
    coreData.logout();
  }

  Future<ZegoRoomLoginResult> joinRoom(
    String roomID, {
    String token = '',
    bool markAsLargeRoom = false,
  }) async {
    if (kIsWeb) {
      assert(token.isNotEmpty);
    }

    ZegoLoggerService.logInfo(
      'join room, room id:"$roomID", token:"$token", markAsLargeRoom:$markAsLargeRoom',
      tag: 'uikit',
      subTag: 'core',
    );

    clear();
    coreData.setRoom(roomID, markAsLargeRoom: markAsLargeRoom);

    final originWakelockEnabledF = Wakelock.enabled;

    final joinRoomResult = await ZegoExpressEngine.instance.loginRoom(
      roomID,
      coreData.localUser.toZegoUser(),
      config: ZegoRoomConfig(0, true, token),
    );
    ZegoLoggerService.logInfo(
      'join room result: ${joinRoomResult.errorCode} ${joinRoomResult.extendedData}',
      tag: 'uikit',
      subTag: 'core',
    );

    if (joinRoomResult.errorCode == 0) {
      coreData.startPublishOrNot();
      syncDeviceStatusByStreamExtraInfo();

      final originWakelockEnabled = await originWakelockEnabledF;
      if (originWakelockEnabled) {
        isNeedDisableWakelock = false;
      } else {
        isNeedDisableWakelock = true;
        Wakelock.enable();
      }
      if (!kIsWeb) ZegoExpressEngine.instance.startSoundLevelMonitor();
    } else if (joinRoomResult.errorCode == ZegoErrorCode.RoomCountExceed) {
      ZegoLoggerService.logInfo(
        'room count exceed',
        tag: 'uikit',
        subTag: 'core',
      );

      await leaveRoom();
      return await joinRoom(roomID, token: token);
    } else {
      ZegoLoggerService.logInfo(
        'joinRoom failed: ${joinRoomResult.errorCode}, ${joinRoomResult.extendedData.toString()}',
        tag: 'uikit',
        subTag: 'core',
      );
    }

    return joinRoomResult;
  }

  Future<ZegoRoomLogoutResult> leaveRoom() async {
    ZegoLoggerService.logInfo(
      'leave room',
      tag: 'uikit',
      subTag: 'core',
    );

    if (isNeedDisableWakelock) {
      Wakelock.disable();
    }

    clear();

    if (!kIsWeb) {
      await ZegoExpressEngine.instance.stopSoundLevelMonitor();
    }

    final leaveResult = await ZegoExpressEngine.instance.logoutRoom();
    if (leaveResult.errorCode != 0) {
      ZegoLoggerService.logInfo(
        'leaveRoom failed: ${leaveResult.errorCode}, ${leaveResult.extendedData.toString()}',
        tag: 'uikit',
        subTag: 'core',
      );
    }

    return leaveResult;
  }

  Future<bool> removeUserFromRoom(List<String> userIDs) async {
    ZegoLoggerService.logInfo(
      'remove users from room:$userIDs',
      tag: 'uikit',
      subTag: 'core',
    );

    if (ZegoUIKitCore.shared.coreData.room.isLargeRoom ||
        ZegoUIKitCore.shared.coreData.room.markAsLargeRoom) {
      ZegoLoggerService.logInfo(
        'remove all users, because is a large room',
        tag: 'uikit',
        subTag: 'core',
      );
      return await ZegoUIKitCore.shared.sendInRoomCommand(
        const JsonEncoder().convert({removeUserInRoomCommandKey: userIDs}),
        [],
      );
    } else {
      return await ZegoUIKitCore.shared.sendInRoomCommand(
        const JsonEncoder().convert({removeUserInRoomCommandKey: userIDs}),
        userIDs,
      );
    }
  }

  Future<bool> setRoomProperty(String key, String value) async {
    return ZegoUIKitCore.shared.updateRoomProperties({key: value});
  }

  Future<bool> updateRoomProperties(Map<String, String> properties) async {
    ZegoLoggerService.logInfo(
      'set room property: $properties',
      tag: 'uikit',
      subTag: 'core',
    );

    if (coreData.room.propertiesAPIRequesting) {
      properties.forEach((key, value) {
        coreData.room.pendingProperties[key] = value;
      });
      ZegoLoggerService.logInfo(
        'room property is updating, pending: ${coreData.room.pendingProperties}',
        tag: 'uikit',
        subTag: 'core',
      );
      return false;
    }

    if (!isInit) {
      ZegoLoggerService.logInfo(
        'core had not init',
        tag: 'uikit',
        subTag: 'core',
      );
      return false;
    }

    if (coreData.room.id.isEmpty) {
      ZegoLoggerService.logInfo(
        'room is not login',
        tag: 'uikit',
        subTag: 'core',
      );
      return false;
    }

    final localUser = ZegoUIKit().getLocalUser();

    var isAllPropertiesSame = coreData.room.properties.isNotEmpty;
    properties.forEach((key, value) {
      if (coreData.room.properties.containsKey(key) &&
          coreData.room.properties[key]!.value == value) {
        ZegoLoggerService.logInfo(
          'key exist and value is same, ${coreData.room.properties.toString()}',
          tag: 'uikit',
          subTag: 'core',
        );
        isAllPropertiesSame = false;
      }
    });
    if (isAllPropertiesSame) {
      ZegoLoggerService.logInfo(
        'all key exist and value is same',
        tag: 'uikit',
        subTag: 'core',
      );
      // return true;
    }

    final oldProperties = <String, RoomProperty?>{};
    properties.forEach((key, value) {
      if (coreData.room.properties.containsKey(key)) {
        oldProperties[key] =
            RoomProperty.copyFrom(coreData.room.properties[key]!);
        oldProperties[key]!.updateUserID = localUser.id;
      }
    });

    /// local update
    properties.forEach((key, value) {
      if (coreData.room.properties.containsKey(key)) {
        coreData.room.properties[key]!.oldValue =
            coreData.room.properties[key]!.value;
        coreData.room.properties[key]!.value = value;
        coreData.room.properties[key]!.updateTime =
            DateTime.now().millisecondsSinceEpoch;
      } else {
        coreData.room.properties[key] = RoomProperty(
          key,
          value,
          DateTime.now().millisecondsSinceEpoch,
          localUser.id,
        );
      }
    });

    /// server update
    final extraInfoMap = <String, String>{};
    coreData.room.properties.forEach((key, value) {
      extraInfoMap[key] = value.value;
    });
    final extraInfo = const JsonEncoder().convert(extraInfoMap);
    // if (extraInfo.length > 128) {
    //   ZegoLoggerService.logInfo("value length out of limit");
    //   return false;
    // }
    ZegoLoggerService.logInfo(
      'call set room extra info, $extraInfo',
      tag: 'uikit',
      subTag: 'core',
    );

    ZegoLoggerService.logInfo(
      'call setRoomExtraInfo',
      tag: 'uikit',
      subTag: 'core',
    );
    coreData.room.propertiesAPIRequesting = true;
    return ZegoExpressEngine.instance
        .setRoomExtraInfo(coreData.room.id, 'extra_info', extraInfo)
        .then((ZegoRoomSetRoomExtraInfoResult result) {
      ZegoLoggerService.logInfo(
        'setRoomExtraInfo finished',
        tag: 'uikit',
        subTag: 'core',
      );
      if (0 == result.errorCode) {
        properties.forEach((key, value) {
          final updatedProperty = coreData.room.properties[key]!;
          coreData.room.propertyUpdateStream.add(updatedProperty);
          coreData.room.propertiesUpdatedStream.add({key: updatedProperty});
        });
      } else {
        properties.forEach((key, value) {
          if (coreData.room.properties.containsKey(key)) {
            coreData.room.properties[key]!.copyFrom(oldProperties[key]!);
          }
        });
        ZegoLoggerService.logInfo(
          'fail to set room properties:$properties! error code:${result.errorCode}',
          tag: 'uikit',
          subTag: 'core',
        );
      }

      coreData.room.propertiesAPIRequesting = false;
      if (coreData.room.pendingProperties.isNotEmpty) {
        final pendingProperties =
            Map<String, String>.from(coreData.room.pendingProperties);
        coreData.room.pendingProperties.clear();
        ZegoLoggerService.logInfo(
          'update pending properties:$pendingProperties',
          tag: 'uikit',
          subTag: 'core',
        );
        updateRoomProperties(pendingProperties);
      }

      return 0 != result.errorCode;
    });
  }

  Future<bool> sendInRoomCommand(
    String command,
    List<String> toUserIDs,
  ) async {
    ZegoLoggerService.logInfo(
      'send in-room command:$command to $toUserIDs',
      tag: 'uikit',
      subTag: 'core',
    );

    return await ZegoExpressEngine.instance
        .sendCustomCommand(
            coreData.room.id,
            command,
            toUserIDs.isEmpty
                // empty mean send to all users
                ? coreData.remoteUsersList
                    .map((ZegoUIKitCoreUser user) =>
                        ZegoUser(user.id, user.name))
                    .toList()
                : toUserIDs
                    .map((String userID) => coreData.remoteUsersList
                        .firstWhere((element) => element.id == userID,
                            orElse: ZegoUIKitCoreUser.empty)
                        .toZegoUser())
                    .toList())
        .then(
      (ZegoIMSendCustomCommandResult result) {
        ZegoLoggerService.logInfo(
          'send custom command result, code:${result.errorCode}',
          tag: 'uikit',
          subTag: 'core',
        );

        return 0 == result.errorCode;
      },
    );
  }

  void useFrontFacingCamera(bool isFrontFacing) {
    if (kIsWeb) {
      return;
    }
    if (isFrontFacing == coreData.localUser.isFrontFacing.value) {
      return;
    }

    ZegoExpressEngine.instance.useFrontCamera(isFrontFacing);
    coreData.localUser.isFrontFacing.value = isFrontFacing;
  }

  void enableVideoMirroring(bool isVideoMirror) {
    ZegoExpressEngine.instance.setVideoMirrorMode(
      isVideoMirror
          ? ZegoVideoMirrorMode.BothMirror
          : ZegoVideoMirrorMode.NoMirror,
    );
  }

  void startPlayAllAudioVideo() {
    coreData.muteAllPlayStreamAudioVideo(false);
  }

  void stopPlayAllAudioVideo() {
    coreData.muteAllPlayStreamAudioVideo(true);
  }

  void setAudioOutputToSpeaker(bool useSpeaker) {
    if (!isInit) {
      ZegoLoggerService.logInfo(
        'set audio output to speaker, core had not init',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    if (kIsWeb) {
      return;
    }
    if (useSpeaker ==
        (coreData.localUser.audioRoute.value == ZegoAudioRoute.Speaker)) {
      return;
    }

    ZegoExpressEngine.instance.setAudioRouteToSpeaker(useSpeaker);

    // TODO: use sdk callback to update audioRoute
    if (useSpeaker) {
      coreData.localUser.lastAudioRoute = coreData.localUser.audioRoute.value;
      coreData.localUser.audioRoute.value = ZegoAudioRoute.Speaker;
    } else {
      coreData.localUser.audioRoute.value = coreData.localUser.lastAudioRoute;
    }
  }

  void turnCameraOn(String userID, bool isOn) {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID camera",
      tag: 'uikit',
      subTag: 'core',
    );

    if (coreData.localUser.id == userID) {
      turnOnLocalCamera(isOn);
    } else {
      final isLargeRoom =
          coreData.room.isLargeRoom || coreData.room.markAsLargeRoom;
      ZegoLoggerService.logInfo(
        'is large room:$isLargeRoom',
        tag: 'uikit',
        subTag: 'core',
      );

      if (isOn) {
        sendInRoomCommand(
          const JsonEncoder().convert({turnCameraOnInRoomCommandKey: userID}),
          isLargeRoom ? [] : [userID],
        );
      } else {
        sendInRoomCommand(
          const JsonEncoder().convert({turnCameraOffInRoomCommandKey: userID}),
          isLargeRoom ? [] : [userID],
        );
      }
    }
  }

  void turnOnLocalCamera(bool isOn) {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} local camera",
      tag: 'uikit',
      subTag: 'core',
    );

    if (!isInit) {
      ZegoLoggerService.logInfo(
        'turn on local camera, core had not init',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    if (isOn == coreData.localUser.camera.value) {
      ZegoLoggerService.logInfo(
        'turn on local camera, value is equal',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    if (isOn) {
      coreData.startPreview();
    } else {
      coreData.stopPreview();
    }

    if (kIsWeb) {
      ZegoExpressEngine.instance.mutePublishStreamVideo(!isOn);
    } else {
      ZegoExpressEngine.instance.enableCamera(isOn);
    }

    coreData.localUser.camera.value = isOn;

    coreData.startPublishOrNot();

    syncDeviceStatusByStreamExtraInfo();
  }

  void turnMicrophoneOn(String userID, bool isOn) {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID microphone",
      tag: 'uikit',
      subTag: 'core',
    );

    if (coreData.localUser.id == userID) {
      turnOnLocalMicrophone(isOn);
    } else {
      final isLargeRoom =
          coreData.room.isLargeRoom || coreData.room.markAsLargeRoom;
      ZegoLoggerService.logInfo(
        'is large room:$isLargeRoom',
        tag: 'uikit',
        subTag: 'core',
      );

      if (isOn) {
        sendInRoomCommand(
          const JsonEncoder()
              .convert({turnMicrophoneOnInRoomCommandKey: userID}),
          isLargeRoom ? [userID] : [],
        );
      } else {
        sendInRoomCommand(
          const JsonEncoder()
              .convert({turnMicrophoneOffInRoomCommandKey: userID}),
          isLargeRoom ? [userID] : [],
        );
      }
    }
  }

  void turnOnLocalMicrophone(bool isOn) {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} local microphone",
      tag: 'uikit',
      subTag: 'core',
    );

    if (!isInit) {
      ZegoLoggerService.logInfo(
        'turn on local microphone, core had not init',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    if (isOn == coreData.localUser.microphone.value) {
      ZegoLoggerService.logInfo(
        'turn on local microphone, value is equal',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    if (kIsWeb) {
      ZegoExpressEngine.instance.mutePublishStreamAudio(!isOn);
    } else {
      ZegoExpressEngine.instance.muteMicrophone(!isOn);
    }

    coreData.localUser.microphone.value = isOn;
    coreData.startPublishOrNot();

    syncDeviceStatusByStreamExtraInfo();
  }

  void syncDeviceStatusByStreamExtraInfo() {
    // sync device status via stream extra info
    final streamExtraInfo = {
      streamExtraInfoCameraKey: coreData.localUser.camera.value,
      streamExtraInfoMicrophoneKey: coreData.localUser.microphone.value
    };
    ZegoExpressEngine.instance
        .setStreamExtraInfo(const JsonEncoder().convert(streamExtraInfo));
  }

  void updateTextureRendererOrientation(Orientation orientation) {
    switch (orientation) {
      case Orientation.portrait:
        ZegoExpressEngine.instance
            .setAppOrientation(DeviceOrientation.portraitUp);
        break;
      case Orientation.landscape:
        ZegoExpressEngine.instance
            .setAppOrientation(DeviceOrientation.landscapeLeft);
        break;
    }
  }

  void setVideoConfig(ZegoUIKitVideoConfig config) {
    if (coreData.videoConfig.needUpdateVideoConfig(config)) {
      final zegoVideoConfig = config.toZegoVideoConfig();
      ZegoExpressEngine.instance.setVideoConfig(zegoVideoConfig);
      coreData.localUser.viewSize.value = Size(
          zegoVideoConfig.captureWidth.toDouble(),
          zegoVideoConfig.captureHeight.toDouble());
    }
    if (coreData.videoConfig.needUpdateOrientation(config)) {
      ZegoExpressEngine.instance.setAppOrientation(config.orientation);
    }

    coreData.videoConfig = config;
  }

  void updateAppOrientation(DeviceOrientation orientation) {
    if (coreData.videoConfig.orientation == orientation) {
      ZegoLoggerService.logInfo(
        'app orientation is equal',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    } else {
      setVideoConfig(coreData.videoConfig.copyWith(orientation: orientation));
    }
  }

  void updateVideoViewMode(bool useVideoViewAspectFill) {
    if (coreData.videoConfig.useVideoViewAspectFill == useVideoViewAspectFill) {
      ZegoLoggerService.logInfo(
        'video view mode is equal',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    } else {
      coreData.videoConfig.useVideoViewAspectFill = useVideoViewAspectFill;
      // TODO: need re preview, and re playStream
    }
  }

  void onInternalCustomCommandReceived(
      ZegoInRoomCommandReceivedData commandData) {
    dynamic commandJson;
    try {
      commandJson = jsonDecode(commandData.command);
    } catch (e) {
      ZegoLoggerService.logInfo(
        'custom command is not a json, ${e.toString()}',
        tag: 'uikit',
        subTag: 'core',
      );
    }

    if (commandJson is! Map<String, dynamic>) {
      ZegoLoggerService.logInfo(
        'custom command is not a map',
        tag: 'uikit',
        subTag: 'core',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'on map custom command received, from user:${commandData.fromUser.toString()}, command:${commandData.command}',
      tag: 'uikit',
      subTag: 'core',
    );

    final extraInfos = Map.from(commandJson);
    if (extraInfos.keys.contains(removeUserInRoomCommandKey) &&
        (extraInfos[removeUserInRoomCommandKey]! as List<dynamic>)
            .contains(coreData.localUser.id)) {
      ZegoLoggerService.logInfo(
        'local user had been remove by ${commandData.fromUser.id}, auto '
        'leave room',
        tag: 'uikit',
        subTag: 'core',
      );
      leaveRoom();

      coreData.meRemovedFromRoomStreamCtrl.add(commandData.fromUser.id);
    } else if (extraInfos.keys.contains(turnCameraOnInRoomCommandKey) &&
        extraInfos[turnCameraOnInRoomCommandKey]!.toString() ==
            coreData.localUser.id) {
      ZegoLoggerService.logInfo(
        'local camera request turn on by ${commandData.fromUser}',
        tag: 'uikit',
        subTag: 'core',
      );
      coreData.turnOnYourCameraRequestStreamCtrl.add(commandData.fromUser.id);
    } else if (extraInfos.keys.contains(turnCameraOffInRoomCommandKey) &&
        extraInfos[turnCameraOffInRoomCommandKey]!.toString() ==
            coreData.localUser.id) {
      ZegoLoggerService.logInfo(
        'local camera request turn off by ${commandData.fromUser}',
        tag: 'uikit',
        subTag: 'core',
      );
      turnCameraOn(coreData.localUser.id, false);
    } else if (extraInfos.keys.contains(turnMicrophoneOnInRoomCommandKey) &&
        extraInfos[turnMicrophoneOnInRoomCommandKey]!.toString() ==
            coreData.localUser.id) {
      ZegoLoggerService.logInfo(
        'local microphone request turn on by ${commandData.fromUser}',
        tag: 'uikit',
        subTag: 'core',
      );
      coreData.turnOnYourMicrophoneRequestStreamCtrl
          .add(commandData.fromUser.id);
    } else if (extraInfos.keys.contains(turnMicrophoneOffInRoomCommandKey) &&
        extraInfos[turnMicrophoneOffInRoomCommandKey]!.toString() ==
            coreData.localUser.id) {
      ZegoLoggerService.logInfo(
        'local microphone request turn off by ${commandData.fromUser}',
        tag: 'uikit',
        subTag: 'core',
      );
      turnMicrophoneOn(coreData.localUser.id, false);
    }
  }
}

extension ZegoUIKitCoreBaseBeauty on ZegoUIKitCore {
  Future<void> enableBeauty(bool isOn) async {
    ZegoExpressEngine.instance.enableEffectsBeauty(isOn);
  }

  Future<void> startEffectsEnv() async {
    await ZegoExpressEngine.instance.startEffectsEnv();
  }

  Future<void> stopEffectsEnv() async {
    await ZegoExpressEngine.instance.stopEffectsEnv();
  }
}
