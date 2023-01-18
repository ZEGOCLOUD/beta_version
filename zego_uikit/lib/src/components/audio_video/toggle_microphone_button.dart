// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// button used to open/close microphone
class ZegoToggleMicrophoneButton extends StatefulWidget {
  const ZegoToggleMicrophoneButton({
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

  /// whether to open microphone by default
  final bool defaultOn;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoToggleMicrophoneButton> createState() =>
      _ZegoToggleMicrophoneButtonState();
}

class _ZegoToggleMicrophoneButtonState
    extends State<ZegoToggleMicrophoneButton> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      /// synchronizing the default status
      ZegoUIKit().turnMicrophoneOn(widget.defaultOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);

    /// listen local microphone state changes
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoUIKit().getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id),
      builder: (context, isMicrophoneOn, _) {
        /// update if microphone state changed
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: containerSize.width,
            height: containerSize.height,
            decoration: BoxDecoration(
              color: isMicrophoneOn
                  ? widget.normalIcon?.backgroundColor ??
                      controlBarButtonCheckedBackgroundColor
                  : widget.offIcon?.backgroundColor ??
                      controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: SizedBox.fromSize(
              size: sizeBoxSize,
              child: isMicrophoneOn
                  ? widget.normalIcon?.icon ??
                      UIKitImage.asset(
                          StyleIconUrls.iconS1ControlBarMicrophoneNormal)
                  : widget.offIcon?.icon ??
                      UIKitImage.asset(
                          StyleIconUrls.iconS1ControlBarMicrophoneOff),
            ),
          ),
        );
      },
    );
  }

  void onPressed() {
    /// get current microphone state
    var valueNotifier =
        ZegoUIKit().getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id);

    var targetState = !valueNotifier.value;

    if (targetState) {
      requestPermission(Permission.microphone);
    }

    /// reverse current state
    ZegoUIKit().turnMicrophoneOn(targetState);

    if (widget.onPressed != null) {
      widget.onPressed!(targetState);
    }
  }
}
