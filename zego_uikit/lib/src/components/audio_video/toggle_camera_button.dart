// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// button used to open/close camera
class ZegoToggleCameraButton extends StatefulWidget {
  const ZegoToggleCameraButton({
    Key? key,
    this.normalIcon,
    this.offIcon,
    this.onPressed,
    this.defaultOn = true,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final ButtonIcon? normalIcon;
  final ButtonIcon? offIcon;

  ///  You can do what you want after pressed.
  final void Function(bool isON)? onPressed;

  /// whether to open camera by default
  final bool defaultOn;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoToggleCameraButton> createState() => _ZegoToggleCameraButtonState();
}

class _ZegoToggleCameraButtonState extends State<ZegoToggleCameraButton> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      /// synchronizing the default status
      ZegoUIKit().turnCameraOn(widget.defaultOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);

    /// listen local camera state changes
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id),
      builder: (context, isCameraOn, _) {
        /// update if camera state changed
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: containerSize.width,
            height: containerSize.height,
            decoration: BoxDecoration(
              color: isCameraOn
                  ? widget.normalIcon?.backgroundColor ??
                      controlBarButtonCheckedBackgroundColor
                  : widget.offIcon?.backgroundColor ??
                      controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: SizedBox.fromSize(
              size: sizeBoxSize,
              child: isCameraOn
                  ? widget.normalIcon?.icon ??
                      UIKitImage.asset(
                          StyleIconUrls.iconS1ControlBarCameraNormal)
                  : widget.offIcon?.icon ??
                      UIKitImage.asset(StyleIconUrls.iconS1ControlBarCameraOff),
            ),
          ),
        );
      },
    );
  }

  void onPressed() {
    /// get current camera state
    var valueNotifier =
        ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id);

    var targetState = !valueNotifier.value;

    if (targetState) {
      requestPermission(Permission.camera);
    }

    /// reverse current state
    ZegoUIKit().turnCameraOn(targetState);

    if (widget.onPressed != null) {
      widget.onPressed!(targetState);
    }
  }
}
