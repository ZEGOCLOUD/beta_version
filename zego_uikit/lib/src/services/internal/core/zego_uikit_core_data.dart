part of 'zego_uikit_core.dart';

class ZegoUIKitCoreData {
  ZegoUIKitCoreUser localUser = ZegoUIKitCoreUser.localDefault();

  final List<ZegoUIKitCoreUser> remoteUsersList = [];

  final Map<String, String> streamDic = {}; // stream_id:user_id

  ZegoUIKitCoreRoom room = ZegoUIKitCoreRoom('');

  bool isAllPlayStreamAudioVideoMuted = false;

  StreamController<List<ZegoUIKitCoreUser>> userJoinStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();
  StreamController<List<ZegoUIKitCoreUser>> userLeaveStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();
  StreamController<List<ZegoUIKitCoreUser>> userListStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();

  StreamController<List<ZegoUIKitCoreUser>> audioVideoListStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();
  StreamController<List<ZegoUIKitCoreUser>> screenSharingListStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();

  StreamController<String> meRemovedFromRoomStreamCtrl = StreamController<String>.broadcast();
  StreamController<ZegoInRoomCommandReceivedData> customCommandReceivedStreamCtrl =
      StreamController<ZegoInRoomCommandReceivedData>.broadcast();
  StreamController<ZegoNetworkMode> networkModeStreamCtrl = StreamController<ZegoNetworkMode>.broadcast();

  StreamController<String> turnOnYourCameraRequestStreamCtrl = StreamController<String>.broadcast();
  StreamController<String> turnOnYourMicrophoneRequestStreamCtrl =
      StreamController<String>.broadcast();

  ZegoUIKitVideoConfig videoConfig = ZegoUIKitVideoConfig();

  ZegoEffectsBeautyParam beautyParam = ZegoEffectsBeautyParam.defaultParam();

  void clearStream() {
    ZegoLoggerService.logInfo(
      'clear stream',
      tag: 'uikit',
      subTag: 'core data',
    );

    for (final user in remoteUsersList) {
      if (user.streamID.isNotEmpty) {
        stopPlayingStream(user.streamID);
      }
      user.destroyTextureRenderer();

      if (user.auxStreamID.isNotEmpty) {
        stopPlayingStream(user.auxStreamID);
      }
      user.destroyTextureRenderer(isMainStream: false);
    }

    if (localUser.streamID.isNotEmpty) {
      stopPublishingStream();
    }
    localUser.destroyTextureRenderer();
  }

  void clear() {
    ZegoLoggerService.logInfo(
      'clear',
      tag: 'uikit',
      subTag: 'core data',
    );

    clearStream();

    isAllPlayStreamAudioVideoMuted = false;

    remoteUsersList.clear();
    streamDic.clear();
    room.clear();
  }

  ZegoUIKitCoreUser login(String id, String name) {
    ZegoLoggerService.logInfo(
      'login, id:"$id", name:$name',
      tag: 'uikit',
      subTag: 'core data',
    );

    localUser.id = id;
    localUser.name = name;

    userJoinStreamCtrl.add([localUser]);
    final allUserList = [localUser, ...remoteUsersList];
    userListStreamCtrl.add(allUserList);

    return localUser;
  }

  void logout() {
    ZegoLoggerService.logInfo(
      'logout',
      tag: 'uikit',
      subTag: 'core data',
    );

    localUser.id = '';
    localUser.name = '';

    userLeaveStreamCtrl.add([localUser]);
    userListStreamCtrl.add(remoteUsersList);
  }

  void setRoom(
    String roomID, {
    bool markAsLargeRoom = false,
  }) {
    ZegoLoggerService.logInfo(
      'set room:"$roomID", markAsLargeRoom:$markAsLargeRoom}',
      tag: 'uikit',
      subTag: 'core data',
    );

    room.id = roomID;
    room.markAsLargeRoom = markAsLargeRoom;
  }

  Future<void> startPreview() async {
    ZegoLoggerService.logInfo(
      'start preview',
      tag: 'uikit',
      subTag: 'core data',
    );

    createLocalUserVideoView(onViewCreated: () async {
      ZegoLoggerService.logInfo(
        'start preview, on view created',
        tag: 'uikit',
        subTag: 'core data',
      );

      assert(localUser.viewID != -1);

      final previewCanvas = ZegoCanvas(
        localUser.viewID,
        viewMode: videoConfig.useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit,
      );

      if (kIsWeb) {
        ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
      } else {
        ZegoExpressEngine.instance
          ..enableCamera(localUser.camera.value)
          ..startPreview(canvas: previewCanvas);
      }
    });
  }

  Future<void> stopPreview() async {
    ZegoLoggerService.logInfo(
      'stop preview',
      tag: 'uikit',
      subTag: 'core data',
    );

    localUser.destroyTextureRenderer();

    ZegoExpressEngine.instance.stopPreview();
  }

  Future<void> startPublishingStream() async {
    if (localUser.streamID.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'startPublishingStream local user stream id is empty',
        tag: 'uikit',
        subTag: 'core data',
      );
      return;
    }

    localUser.streamID =
        generateStreamID(localUser.id, room.id, ZegoStreamType.main);
    streamDic[localUser.streamID] = localUser.id;
    ZegoLoggerService.logInfo(
      'stream dict add ${localUser.streamID} for ${localUser.id}, $streamDic',
      tag: 'uikit',
      subTag: 'core data',
    );

    ZegoLoggerService.logInfo(
      'startPublishingStream ${localUser.streamID}',
      tag: 'uikit',
      subTag: 'core data',
    );

    createLocalUserVideoView(onViewCreated: () async {
      assert(localUser.viewID != -1);
      final previewCanvas = ZegoCanvas(
        localUser.viewID,
        viewMode: videoConfig.useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit,
      );
      if (kIsWeb) {
        ZegoExpressEngine.instance
          ..mutePublishStreamVideo(!localUser.camera.value)
          ..mutePublishStreamAudio(!!localUser.microphone.value)
          ..startPreview(canvas: previewCanvas)
          ..startPublishingStream(localUser.streamID).then((value) {
            audioVideoListStreamCtrl.add(getAudioVideoList());
          });
      } else {
        ZegoExpressEngine.instance
          ..enableCamera(localUser.camera.value)
          ..muteMicrophone(!localUser.microphone.value)
          ..startPreview(canvas: previewCanvas)
          ..startPublishingStream(localUser.streamID).then((value) {
            audioVideoListStreamCtrl.add(getAudioVideoList());
          });
      }
    });
  }

  Future<void> stopPublishingStream() async {
    ZegoLoggerService.logInfo(
      'stopPublishingStream ${localUser.streamID}',
      tag: 'uikit',
      subTag: 'core data',
    );

    assert(localUser.streamID.isNotEmpty);

    streamDic.remove(localUser.streamID);
    ZegoLoggerService.logInfo(
      'stream dict remove ${localUser.streamID}, $streamDic',
      tag: 'uikit',
      subTag: 'core data',
    );

    localUser.streamID = '';
    localUser.destroyTextureRenderer();

    ZegoExpressEngine.instance
      ..stopPreview()
      ..stopPublishingStream().then((value) {
        audioVideoListStreamCtrl.add(getAudioVideoList());
      });
  }

  Future<void> startPublishOrNot() async {
    if (room.id.isEmpty) {
      ZegoLoggerService.logInfo(
        'startPublishOrNot room id is empty',
        tag: 'uikit',
        subTag: 'core data',
      );
      return;
    }

    if (localUser.camera.value || localUser.microphone.value) {
      startPublishingStream();
    } else {
      if (localUser.streamID.isNotEmpty) {
        stopPublishingStream();
      }
    }
  }

  void createLocalUserVideoView({required VoidCallback onViewCreated}) {
    if (-1 == localUser.viewID) {
      ZegoExpressEngine.instance.createCanvasView((viewID) {
        localUser.viewID = viewID;
        onViewCreated();

        audioVideoListStreamCtrl.add(getAudioVideoList());
      }).then((widget) {
        localUser.view.value = widget;
      });
    } else {
      //  user view had created
      onViewCreated();
    }
  }

  ZegoUIKitCoreUser removeUser(String uid) {
    final targetIndex = remoteUsersList.indexWhere((user) => uid == user.id);
    if (-1 == targetIndex) {
      return ZegoUIKitCoreUser.empty();
    }

    final targetUser = remoteUsersList.removeAt(targetIndex);
    if (targetUser.streamID.isNotEmpty) {
      stopPlayingStream(targetUser.streamID);
    }
    if (targetUser.auxStreamID.isNotEmpty) {
      stopPlayingStream(targetUser.auxStreamID);
    }
    return targetUser;
  }

  void muteAllPlayStreamAudioVideo(bool isMuted) async {
    ZegoLoggerService.logInfo(
      'mute all play stream audio video: $isMuted',
      tag: 'uikit',
      subTag: 'core data',
    );

    isAllPlayStreamAudioVideoMuted = isMuted;

    ZegoExpressEngine.instance
        .muteAllPlayStreamVideo(isAllPlayStreamAudioVideoMuted);
    ZegoExpressEngine.instance
        .muteAllPlayStreamAudio(isAllPlayStreamAudioVideoMuted);

    streamDic.forEach((streamID, userID) {
      if (isMuted) {
        // stop playing stream
        ZegoExpressEngine.instance.stopPlayingStream(streamID);
      } else {
        if (localUser.id != userID) {
          startPlayingStream(streamID, userID);
        }
      }
    });
  }

  /// will change data variables
  Future<void> startPlayingStream(String streamID, String streamUserID) async {
    ZegoLoggerService.logInfo(
      'start play stream id: $streamID, user id:$streamUserID',
      tag: 'uikit',
      subTag: 'core data',
    );

    final isMainStream = streamID.endsWith(ZegoStreamType.main.text);

    final targetUserIndex =
        remoteUsersList.indexWhere((user) => streamUserID == user.id);
    assert(-1 != targetUserIndex);
    isMainStream
        ? remoteUsersList[targetUserIndex].streamID = streamID
        : remoteUsersList[targetUserIndex].auxStreamID = streamID;

    ZegoExpressEngine.instance.createCanvasView((viewID) {
      isMainStream
          ? remoteUsersList[targetUserIndex].viewID = viewID
          : remoteUsersList[targetUserIndex].auxViewID = viewID;
      final canvas = ZegoCanvas(
        viewID,
        viewMode: videoConfig.useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit,
      );
      ZegoExpressEngine.instance
          .startPlayingStream(streamID, canvas: canvas)
          .then((value) {
        if (streamID.endsWith(ZegoStreamType.main.text)) {
          audioVideoListStreamCtrl.add(getAudioVideoList());
        } else {
          screenSharingListStreamCtrl
              .add(getAudioVideoList(streamType: ZegoStreamType.screenSharing));
        }
      });
    }).then((widget) {
      isMainStream
          ? remoteUsersList[targetUserIndex].view.value = widget
          : remoteUsersList[targetUserIndex].auxView.value = widget;
    });
  }

  /// will change data variables
  void stopPlayingStream(String streamID) {
    ZegoLoggerService.logInfo(
      'stop play stream id: $streamID',
      tag: 'uikit',
      subTag: 'core data',
    );
    assert(streamID.isNotEmpty);

    // stop playing stream
    ZegoExpressEngine.instance.stopPlayingStream(streamID);

    final targetUserID =
        streamDic.containsKey(streamID) ? streamDic[streamID] : '';
    ZegoLoggerService.logInfo(
      'stopped play stream id $streamID, user id  is: $targetUserID',
      tag: 'uikit',
      subTag: 'core data',
    );
    final targetUserIndex =
        remoteUsersList.indexWhere((user) => targetUserID == user.id);
    if (-1 != targetUserIndex) {
      final targetUser = remoteUsersList[targetUserIndex];

      if (streamID.endsWith(ZegoStreamType.main.text)) {
        targetUser.streamID = '';
        targetUser.destroyTextureRenderer();

        targetUser.camera.value = false;
        targetUser.microphone.value = false;
        targetUser.soundLevel.add(0);
      } else {
        targetUser.auxStreamID = '';
        targetUser.destroyTextureRenderer(isMainStream: false);
      }
    }

    // clear streamID
    streamDic.remove(streamID);
    ZegoLoggerService.logInfo(
      'stream dict remove $streamID, $streamDic',
      tag: 'uikit',
      subTag: 'core data',
    );
  }

  Future<void> onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) async {
    ZegoLoggerService.logInfo(
      'onRoomStreamUpdate, roomID:$roomID, update type:$updateType'
      ", stream list:${streamList.map((e) => "stream id:${e.streamID}, extra info${e.extraInfo}, user id:${e.user.userID}")},"
      ' extended data:$extendedData',
      tag: 'uikit',
      subTag: 'core data',
    );

    if (updateType == ZegoUpdateType.Add) {
      for (final stream in streamList) {
        streamDic[stream.streamID] = stream.user.userID;
        ZegoLoggerService.logInfo(
          'stream dict add ${stream.streamID} for ${stream.user.userID}, $streamDic',
          tag: 'uikit',
          subTag: 'core data',
        );

        if (-1 ==
            remoteUsersList
                .indexWhere((user) => stream.user.userID == user.id)) {
          /// user is not exist before stream added
          ZegoLoggerService.logInfo(
            "stream's user ${stream.user.userID}  ${stream.user.userName} is not exist, create",
            tag: 'uikit',
            subTag: 'core data',
          );

          final targetUser = ZegoUIKitCoreUser.fromZego(stream.user);
          stream.streamID.endsWith(ZegoStreamType.main.text)
              ? targetUser.streamID = stream.streamID
              : targetUser.auxStreamID = stream.streamID;
          remoteUsersList.add(targetUser);
        }

        if (isAllPlayStreamAudioVideoMuted) {
          ZegoLoggerService.logInfo(
            'audio video is not play enabled, user id:${stream.user.userID}, stream id:${stream.streamID}',
            tag: 'uikit',
            subTag: 'core data',
          );
        } else {
          await startPlayingStream(stream.streamID, stream.user.userID);
        }
      }

      onRoomStreamExtraInfoUpdate(roomID, streamList);
    } else {
      for (final stream in streamList) {
        stopPlayingStream(stream.streamID);
      }
    }

    if (-1 !=
        streamList.map((e) => e.streamID).toList().indexWhere(
            (element) => element.endsWith(ZegoStreamType.main.text))) {
      audioVideoListStreamCtrl.add(getAudioVideoList());
    }
    if (-1 !=
        streamList.map((e) => e.streamID).toList().indexWhere(
            (element) => element.endsWith(ZegoStreamType.screenSharing.text))) {
      screenSharingListStreamCtrl
          .add(getAudioVideoList(streamType: ZegoStreamType.screenSharing));
    }
  }

  void onRoomStreamExtraInfoUpdate(String roomID, List<ZegoStream> streamList) {
    /*
    * {
    * "isCameraOn": true,
    * "isMicrophoneOn": true,
    * "hasAudio": true,
    * "hasVideo": true,
    * }
    * */

    ZegoLoggerService.logInfo(
      "onRoomStreamExtraInfoUpdate, roomID:$roomID, stream list:${streamList.map((e) => "stream id:${e.streamID}, extra info${e.extraInfo}, user id:${e.user.userID}")}",
      tag: 'uikit',
      subTag: 'core data',
    );
    for (final stream in streamList) {
      if (stream.extraInfo.isEmpty) {
        ZegoLoggerService.logInfo(
          'onRoomStreamExtraInfoUpdate extra info is empty',
          tag: 'uikit',
          subTag: 'core data',
        );
        continue;
      }

      final extraInfos = jsonDecode(stream.extraInfo) as Map<String, dynamic>;
      if (extraInfos.containsKey(streamExtraInfoCameraKey)) {
        onRemoteCameraStateUpdate(
            stream.streamID,
            extraInfos[streamExtraInfoCameraKey]!
                ? ZegoRemoteDeviceState.Open
                : ZegoRemoteDeviceState.Mute);
      }
      if (extraInfos.containsKey(streamExtraInfoMicrophoneKey)) {
        onRemoteMicStateUpdate(
            stream.streamID,
            extraInfos[streamExtraInfoMicrophoneKey]!
                ? ZegoRemoteDeviceState.Open
                : ZegoRemoteDeviceState.Mute);
      }
    }
  }

  List<ZegoUIKitCoreUser> getAudioVideoList({
    ZegoStreamType streamType = ZegoStreamType.main,
  }) {
    return streamDic.entries
        .where((value) => value.key.endsWith(streamType.text))
        .map((entry) {
      final targetUserID = entry.value;
      if (targetUserID == localUser.id) {
        return localUser;
      }
      return remoteUsersList.firstWhere((user) => targetUserID == user.id,
          orElse: ZegoUIKitCoreUser.empty);
    }).where((user) {
      if (user.id.isEmpty) {
        return false;
      }

      if (streamType == ZegoStreamType.main) {
        return user.camera.value || user.microphone.value;
      }

      return true;
    }).toList();
  }

  void onRoomUserUpdate(
    String roomID,
    ZegoUpdateType updateType,
    List<ZegoUser> userList,
  ) {
    ZegoLoggerService.logInfo(
      'onRoomUserUpdate, room id:"$roomID", update type:$updateType'
      "user list:${userList.map((user) => '"${user.userID}":${user.userName}, ')}",
      tag: 'uikit',
      subTag: 'core data',
    );

    if (updateType == ZegoUpdateType.Add) {
      for (final _user in userList) {
        final targetUserIndex =
            remoteUsersList.indexWhere((user) => _user.userID == user.id);
        if (-1 != targetUserIndex) {
          continue;
        }

        remoteUsersList.add(ZegoUIKitCoreUser.fromZego(_user));
      }

      if (remoteUsersList.length >= 499) {
        /// turn to be a large room after more than 500 people, even if less than 500 people behind
        ZegoLoggerService.logInfo(
          'users is more than 500, turn to be a large room',
          tag: 'uikit',
          subTag: 'core data',
        );
        room.isLargeRoom = true;
      }

      userJoinStreamCtrl.add(
          userList.map(ZegoUIKitCoreUser.fromZego).toList());
    } else {
      for (final user in userList) {
        removeUser(user.userID);
      }

      userLeaveStreamCtrl.add(
          userList.map(ZegoUIKitCoreUser.fromZego).toList());
    }

    final allUserList = [localUser, ...remoteUsersList];
    userListStreamCtrl.add(allUserList);
  }

  void onPublisherStateUpdate(
    String streamID,
    ZegoPublisherState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    ZegoLoggerService.logInfo(
      'onPublisherStateUpdate, stream id:$streamID, state:$state, errorCode:$errorCode, extendedData:$extendedData',
      tag: 'uikit',
      subTag: 'core data',
    );
  }

  void onPlayerStateUpdate(
    String streamID,
    ZegoPlayerState state,
    int errorCode,
    Map<String, dynamic> extendedData,
  ) {
    ZegoLoggerService.logInfo(
      'onPlayerStateUpdate, stream id:$streamID, state:$state, errorCode:$errorCode, extendedData:$extendedData',
      tag: 'uikit',
      subTag: 'core data',
    );
  }

  void onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    if (!streamDic.containsKey(streamID)) {
      ZegoLoggerService.logInfo(
        'onRemoteCameraStateUpdate, stream $streamID is not exist',
        tag: 'uikit',
        subTag: 'core data',
      );
      return;
    }

    final targetUserIndex =
        remoteUsersList.indexWhere((user) => streamDic[streamID]! == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'onRemoteCameraStateUpdate, stream user $streamID is not exist',
        tag: 'uikit',
        subTag: 'core data',
      );
      return;
    }

    final targetUser = remoteUsersList[targetUserIndex];
    ZegoLoggerService.logInfo(
      'onRemoteCameraStateUpdate, stream id:$streamID, user:${targetUser.toString()}, state:$state',
      tag: 'uikit',
      subTag: 'core data',
    );
    final oldValue = targetUser.camera.value;
    switch (state) {
      case ZegoRemoteDeviceState.Open:
        targetUser.camera.value = true;
        break;
      case ZegoRemoteDeviceState.NoAuthorization:
        targetUser.camera.value = true;
        break;
      default:
        targetUser.camera.value = false;
    }

    if (oldValue != targetUser.camera.value) {
      /// notify outside to update audio video list
      if (streamID.endsWith(ZegoStreamType.main.text)) {
        audioVideoListStreamCtrl.add(getAudioVideoList());
      } else {
        screenSharingListStreamCtrl
            .add(getAudioVideoList(streamType: ZegoStreamType.screenSharing));
      }
    }
  }

  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    if (!streamDic.containsKey(streamID)) {
      ZegoLoggerService.logInfo(
        'onRemoteMicStateUpdate, stream $streamID is not exist',
        tag: 'uikit',
        subTag: 'core data',
      );
      return;
    }

    final targetUserIndex =
        remoteUsersList.indexWhere((user) => streamDic[streamID]! == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'onRemoteMicStateUpdate, stream user $streamID is not exist',
        tag: 'uikit',
        subTag: 'core data',
      );
      return;
    }

    final targetUser = remoteUsersList[targetUserIndex];
    ZegoLoggerService.logInfo(
      'onRemoteMicStateUpdate, stream id:$streamID, user:${targetUser.toString()}, state:$state',
      tag: 'uikit',
      subTag: 'core data',
    );
    final oldValue = targetUser.microphone.value;
    switch (state) {
      case ZegoRemoteDeviceState.Open:
        targetUser.microphone.value = true;
        break;
      case ZegoRemoteDeviceState.NoAuthorization:
        targetUser.microphone.value = true;
        break;
      default:
        targetUser.microphone.value = false;
        targetUser.soundLevel.add(0);
    }

    if (oldValue != targetUser.microphone.value) {
      /// notify outside to update audio video list
      if (streamID.endsWith(ZegoStreamType.main.text)) {
        audioVideoListStreamCtrl.add(getAudioVideoList());
      } else {
        screenSharingListStreamCtrl
            .add(getAudioVideoList(streamType: ZegoStreamType.screenSharing));
      }
    }
  }

  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    soundLevels.forEach((streamID, soundLevel) {
      if (!streamDic.containsKey(streamID)) {
        ZegoLoggerService.logInfo(
          'stream dic does not contain $streamID',
          tag: 'uikit',
          subTag: 'core data',
        );
        return;
      }

      final targetUserID = streamDic[streamID]!;
      final targetUserIndex =
          remoteUsersList.indexWhere((user) => targetUserID == user.id);
      if (-1 == targetUserIndex) {
        ZegoLoggerService.logInfo(
          'remote user does not contain $targetUserID',
          tag: 'uikit',
          subTag: 'core data',
        );
        return;
      }

      remoteUsersList[targetUserIndex].soundLevel.add(soundLevel);
    });
  }

  void onCapturedSoundLevelUpdate(double level) {
    localUser.soundLevel.add(level);
  }

  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    localUser.audioRoute.value = audioRoute;
  }

  void onPlayerVideoSizeChanged(String streamID, int width, int height) {
    final targetUserIndex =
        remoteUsersList.indexWhere((user) => streamDic[streamID]! == user.id);
    if (-1 == targetUserIndex) {
      ZegoLoggerService.logInfo(
        'onPlayerVideoSizeChanged, stream user $streamID is not exist',
        tag: 'uikit',
        subTag: 'core data',
      );
      return;
    }

    final targetUser = remoteUsersList[targetUserIndex];
    ZegoLoggerService.logInfo(
      'onPlayerVideoSizeChanged streamID: $streamID width: $width height: $height',
      tag: 'uikit',
      subTag: 'core data',
    );
    final size = Size(width.toDouble(), height.toDouble());

    if (streamID.endsWith(ZegoStreamType.main.text)) {
      if (targetUser.viewSize.value != size) {
        targetUser.viewSize.value = size;
      }
    } else {
      if (targetUser.auxViewSize.value != size) {
        targetUser.auxViewSize.value = size;
      }
    }
  }

  void onRoomStateChanged(String roomID, ZegoRoomStateChangedReason reason,
      int errorCode, Map<String, dynamic> extendedData) {
    ZegoLoggerService.logInfo(
      'onRoomStateChanged roomID: $roomID, reason: $reason, errorCode: $errorCode, extendedData: $extendedData',
      tag: 'uikit',
      subTag: 'core data',
    );

    room.state.value = ZegoUIKitRoomState(reason, errorCode, extendedData);

    if (reason == ZegoRoomStateChangedReason.KickOut) {
      ZegoLoggerService.logInfo(
        'local user had been kick out by room state changed',
        tag: 'uikit',
        subTag: 'core data',
      );

      meRemovedFromRoomStreamCtrl.add('');
    }
  }

  void onRoomExtraInfoUpdate(
      String roomID, List<ZegoRoomExtraInfo> roomExtraInfoList) {
    final roomExtraInfoString = roomExtraInfoList.map((info) =>
        'key:${info.key}, value:${info.value}'
        ' update user:${info.updateUser.userID},${info.updateUser.userName}, update time:${info.updateTime}');
    ZegoLoggerService.logInfo(
      'onRoomExtraInfoUpdate roomID: $roomID,roomExtraInfoList: $roomExtraInfoString',
      tag: 'uikit',
      subTag: 'core data',
    );

    for (final extraInfo in roomExtraInfoList) {
      if (extraInfo.key == 'extra_info') {
        final properties = jsonDecode(extraInfo.value) as Map<String, dynamic>;

        ZegoLoggerService.logInfo(
          'update room properties: $properties',
          tag: 'uikit',
          subTag: 'core data',
        );

        final updateProperties = <String, RoomProperty>{};

        properties.forEach((key, _value) {
          final value = _value as String;

          if (room.properties.containsKey(key) &&
              room.properties[key]!.value == value) {
            ZegoLoggerService.logInfo(
              'room property not need update, key:$key, value:$value',
              tag: 'uikit',
              subTag: 'core data',
            );
            return;
          }

          ZegoLoggerService.logInfo(
            'room property update, key:$key, value:$value',
            tag: 'uikit',
            subTag: 'core data',
          );
          if (room.properties.containsKey(key)) {
            final property = room.properties[key]!;
            if (extraInfo.updateTime > property.updateTime) {
              room.properties[key]!.oldValue = room.properties[key]!.value;
              room.properties[key]!.value = value;
              room.properties[key]!.updateTime = extraInfo.updateTime;
              room.properties[key]!.updateUserID = extraInfo.updateUser.userID;
            }
          } else {
            room.properties[key] = RoomProperty(
              key,
              value,
              extraInfo.updateTime,
              extraInfo.updateUser.userID,
            );
          }
          updateProperties[key] = room.properties[key]!;
          room.propertyUpdateStream.add(room.properties[key]!);
        });

        if (updateProperties.isNotEmpty) {
          room.propertiesUpdatedStream.add(updateProperties);
        }
      }
    }
  }

  void onIMRecvCustomCommand(String roomID, ZegoUser fromUser, String command) {
    ZegoLoggerService.logInfo(
      'onIMRecvCustomCommand roomID: $roomID, reason: ${fromUser.userID} ${fromUser.userName}, command:$command',
      tag: 'uikit',
      subTag: 'core data',
    );

    customCommandReceivedStreamCtrl.add(ZegoInRoomCommandReceivedData(
      fromUser: ZegoUIKitUser.fromZego(fromUser),
      command: command,
    ));
  }

  void onNetworkModeChanged(ZegoNetworkMode mode) {
    networkModeStreamCtrl.add(mode);
  }
}
