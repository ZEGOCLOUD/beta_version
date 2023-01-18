part of 'uikit_service.dart';

mixin ZegoDeviceService {
  /// protocol: String is 'operator'
  Stream<String> getTurnOnYourCameraRequestStream() {
    return ZegoUIKitCore
        .shared.coreData.turnOnYourCameraRequestStreamCtrl.stream;
  }

  /// protocol: String is 'operator'
  Stream<String> getTurnOnYourMicrophoneRequestStream() {
    return ZegoUIKitCore
        .shared.coreData.turnOnYourMicrophoneRequestStreamCtrl.stream;
  }
}
