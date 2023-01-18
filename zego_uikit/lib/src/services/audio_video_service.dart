part of 'uikit_service.dart';

mixin ZegoAudioVideoService {
  /// start play all audio video
  void startPlayAllAudioVideo() {
    ZegoUIKitCore.shared.startPlayAllAudioVideo();
  }

  /// stop play all audio video
  void stopPlayAllAudioVideo() {
    ZegoUIKitCore.shared.stopPlayAllAudioVideo();
  }

  /// set audio output to speaker
  void setAudioOutputToSpeaker(bool isSpeaker) {
    ZegoUIKitCore.shared.setAudioOutputToSpeaker(isSpeaker);
  }

  /// turn on/off camera
  void turnCameraOn(bool isOn, {String? userID}) {
    ZegoUIKitCore.shared.turnCameraOn(
      userID?.isEmpty ?? true
          ? ZegoUIKitCore.shared.coreData.localUser.id
          : userID!,
      isOn,
    );
  }

  /// turn on/off microphone
  void turnMicrophoneOn(bool isOn, {String? userID}) {
    ZegoUIKitCore.shared.turnMicrophoneOn(
      userID?.isEmpty ?? true
          ? ZegoUIKitCore.shared.coreData.localUser.id
          : userID!,
      isOn,
    );
  }

  /// local use front facing camera
  void useFrontFacingCamera(bool isFrontFacing) {
    ZegoUIKitCore.shared.useFrontFacingCamera(isFrontFacing);
  }

  /// set video mirror mode
  void enableVideoMirroring(bool isVideoMirror) {
    ZegoUIKitCore.shared.enableVideoMirroring(isVideoMirror);
  }

  void setAudioConfig() {}

  void setVideoConfig() {}

  /// get audio video view notifier
  ValueNotifier<Widget?> getAudioVideoViewNotifier(
    String? userID, {
    bool isMainStream = true,
  }) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return isMainStream
          ? ZegoUIKitCore.shared.coreData.localUser.view
          : ZegoUIKitCore.shared.coreData.localUser.auxView;
    } else {
      final targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty);
      return isMainStream ? targetUser.view : targetUser.auxView;
    }
  }

  /// get camera state notifier
  ValueNotifier<bool> getCameraStateNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.camera;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty)
          .camera;
    }
  }

  /// get front facing camera switch notifier
  ValueNotifier<bool> getUseFrontFacingCameraStateNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.isFrontFacing;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty)
          .isFrontFacing;
    }
  }

  /// get microphone state notifier
  ValueNotifier<bool> getMicrophoneStateNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.microphone;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty)
          .microphone;
    }
  }

  /// get audio output device notifier
  ValueNotifier<ZegoAudioRoute> getAudioOutputDeviceNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.audioRoute;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty)
          .audioRoute;
    }
  }

  /// get sound level notifier
  Stream<double> getSoundLevelStream(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.soundLevel.stream;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty)
          .soundLevel
          .stream;
    }
  }

  /// get audio video list
  List<ZegoUIKitUser> getAudioVideoList() {
    return ZegoUIKitCore.shared.coreData
        .getAudioVideoList()
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  Stream<List<ZegoUIKitUser>> getAudioVideoListStream() {
    return ZegoUIKitCore.shared.coreData.audioVideoListStreamCtrl.stream
        .map((users) => users.map((e) => e.toZegoUikitUser()).toList());
  }

  /// get screen sharing list
  List<ZegoUIKitUser> getScreenSharingList() {
    return ZegoUIKitCore.shared.coreData
        .getAudioVideoList(streamType: ZegoStreamType.screenSharing)
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  Stream<List<ZegoUIKitUser>> getScreenSharingListStream() {
    return ZegoUIKitCore.shared.coreData.screenSharingListStreamCtrl.stream
        .map((users) => users.map((e) => e.toZegoUikitUser()).toList());
  }

  /// get video size notifier
  ValueNotifier<Size> getVideoSizeNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.viewSize;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: ZegoUIKitCoreUser.empty)
          .viewSize;
    }
  }

  /// update texture render orientation
  void updateTextureRendererOrientation(Orientation orientation) {
    ZegoUIKitCore.shared.updateTextureRendererOrientation(orientation);
  }

  /// update app orientation
  void updateAppOrientation(DeviceOrientation orientation) {
    ZegoUIKitCore.shared.updateAppOrientation(orientation);
  }

  /// update video view mode
  void updateVideoViewMode(bool useVideoViewAspectFill) {
    ZegoUIKitCore.shared.updateVideoViewMode(useVideoViewAspectFill);
  }
}
