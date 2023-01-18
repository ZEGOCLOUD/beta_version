// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// quit room/channel/group
class ZegoLeaveButton extends StatelessWidget {
  final ButtonIcon? icon;

  ///  You can do what you want before clicked.
  ///  Return true, exit;
  ///  Return false, will not exit.
  final Future<bool?> Function(BuildContext context)? onLeaveConfirmation;

  ///  You can do what you want after pressed.
  final VoidCallback? onPress;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  const ZegoLeaveButton({
    Key? key,
    this.onLeaveConfirmation,
    this.onPress,
    this.icon,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size containerSize = buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = iconSize ?? Size(56.r, 56.r);
    return GestureDetector(
      onTap: () async {
        ///  if there is a user-defined event before the click,
        ///  wait the synchronize execution result
        bool isConfirm = await onLeaveConfirmation?.call(context) ?? true;
        if (isConfirm) {
          quit();
        }
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: icon?.backgroundColor ?? Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(
              math.min(containerSize.width, containerSize.height) / 2)),
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child:
              icon?.icon ?? UIKitImage.asset(StyleIconUrls.iconS1ControlBarEnd),
        ),
      ),
    );
  }

  void quit() {
    ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        "leave room result, ${result.errorCode} ${result.extendedData}",
        tag: "uikit",
        subTag: "leave button",
      );
    });

    if (onPress != null) {
      onPress!();
    }
  }
}
