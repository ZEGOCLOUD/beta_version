// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/components/widgets/widgets.dart';
import 'package:zego_uikit/src/services/services.dart';

/// monitor the camera status changes,
/// when the status changes, the corresponding icon is automatically switched
class ZegoCameraStateIcon extends ZegoServiceValueIcon {
  final ZegoUIKitUser? targetUser;

  final Image? iconCameraOn;
  final Image? iconCameraOff;

  ZegoCameraStateIcon({
    Key? key,
    required this.targetUser,
    this.iconCameraOn,
    this.iconCameraOff,
  }) : super(
          key: key,
          notifier: ZegoUIKit().getCameraStateNotifier(targetUser?.id ?? ""),
          normalIcon: iconCameraOff ??
              UIKitImage.asset(StyleIconUrls.iconVideoViewCameraOff),
          checkedIcon: iconCameraOn ??
              UIKitImage.asset(StyleIconUrls.iconVideoViewCameraOn),
        );
}
