part of 'zego_uikit_core.dart';

mixin ZegoUIKitCoreEvent {
  void uninitEventHandle() {
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
    ZegoExpressEngine.onRemoteCameraStateUpdate = null;
    ZegoExpressEngine.onRemoteMicStateUpdate = null;
    ZegoExpressEngine.onRemoteSoundLevelUpdate = null;
    ZegoExpressEngine.onCapturedSoundLevelUpdate = null;
    ZegoExpressEngine.onAudioRouteChange = null;
    ZegoExpressEngine.onPlayerVideoSizeChanged = null;
    ZegoExpressEngine.onRoomStateChanged = null;
    ZegoExpressEngine.onRoomExtraInfoUpdate = null;
    ZegoExpressEngine.onIMRecvBroadcastMessage = null;
    ZegoExpressEngine.onIMRecvCustomCommand = null;
  }

  void initEventHandle() {
    ZegoExpressEngine.onRoomStreamUpdate =
        ZegoUIKitCore.shared.coreData.onRoomStreamUpdate;
    ZegoExpressEngine.onRoomStreamExtraInfoUpdate =
        ZegoUIKitCore.shared.coreData.onRoomStreamExtraInfoUpdate;

    ZegoExpressEngine.onRoomUserUpdate =
        ZegoUIKitCore.shared.coreData.onRoomUserUpdate;

    ZegoExpressEngine.onPublisherStateUpdate =
        ZegoUIKitCore.shared.coreData.onPublisherStateUpdate;
    ZegoExpressEngine.onPlayerStateUpdate =
        ZegoUIKitCore.shared.coreData.onPlayerStateUpdate;

    ZegoExpressEngine.onRemoteCameraStateUpdate =
        ZegoUIKitCore.shared.coreData.onRemoteCameraStateUpdate;

    ZegoExpressEngine.onRemoteMicStateUpdate =
        ZegoUIKitCore.shared.coreData.onRemoteMicStateUpdate;

    ZegoExpressEngine.onRemoteSoundLevelUpdate =
        ZegoUIKitCore.shared.coreData.onRemoteSoundLevelUpdate;

    ZegoExpressEngine.onCapturedSoundLevelUpdate =
        ZegoUIKitCore.shared.coreData.onCapturedSoundLevelUpdate;

    ZegoExpressEngine.onAudioRouteChange =
        ZegoUIKitCore.shared.coreData.onAudioRouteChange;

    ZegoExpressEngine.onPlayerVideoSizeChanged =
        ZegoUIKitCore.shared.coreData.onPlayerVideoSizeChanged;

    ZegoExpressEngine.onRoomStateChanged =
        ZegoUIKitCore.shared.coreData.onRoomStateChanged;

    ZegoExpressEngine.onRoomExtraInfoUpdate =
        ZegoUIKitCore.shared.coreData.onRoomExtraInfoUpdate;

    ZegoExpressEngine.onIMRecvBroadcastMessage =
        ZegoUIKitCore.shared.coreMessage.onIMRecvBroadcastMessage;

    ZegoExpressEngine.onIMRecvCustomCommand =
        ZegoUIKitCore.shared.coreData.onIMRecvCustomCommand;

    ZegoExpressEngine.onNetworkModeChanged =
        ZegoUIKitCore.shared.coreData.onNetworkModeChanged;
  }
}
