// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// button used to switch audio output route between speaker or system device
class ZegoSwitchAudioOutputButton extends StatefulWidget {
  const ZegoSwitchAudioOutputButton({
    Key? key,
    this.speakerIcon,
    this.headphoneIcon,
    this.bluetoothIcon,
    this.onPressed,
    this.defaultUseSpeaker = false,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final ButtonIcon? speakerIcon;
  final ButtonIcon? headphoneIcon;
  final ButtonIcon? bluetoothIcon;

  ///  You can do what you want after pressed.
  final void Function(bool isON)? onPressed;

  /// whether to open speaker by default
  final bool defaultUseSpeaker;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoSwitchAudioOutputButton> createState() =>
      _ZegoSwitchAudioOutputButtonState();
}

class _ZegoSwitchAudioOutputButtonState
    extends State<ZegoSwitchAudioOutputButton> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      /// synchronizing the default status
      ZegoUIKit().setAudioOutputToSpeaker(widget.defaultUseSpeaker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZegoAudioRoute>(
      /// listen local audio output route changes
      valueListenable: ZegoUIKit()
          .getAudioOutputDeviceNotifier(ZegoUIKit().getLocalUser().id),
      builder: (context, audioRoute, _) {
        /// update icon/background if route changed
        return getAudioRouteButtonByRoute(audioRoute);
      },
    );
  }

  Widget getAudioRouteButtonByRoute(ZegoAudioRoute audioRoute) {
    Widget icon = UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerOff);
    Color backgroundColor = controlBarButtonBackgroundColor;

    /// get the new icon and background color
    if (ZegoAudioRoute.Bluetooth == audioRoute) {
      /// always open
      icon = widget.bluetoothIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerBluetooth);
      backgroundColor = widget.bluetoothIcon?.backgroundColor ??
          controlBarButtonBackgroundColor;
    } else if (ZegoAudioRoute.Headphone == audioRoute) {
      /// always display speaker closed
      icon = widget.headphoneIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerOff);
      backgroundColor = widget.headphoneIcon?.backgroundColor ??
          controlBarButtonBackgroundColor;
    } else if (ZegoAudioRoute.Speaker == audioRoute) {
      icon = widget.speakerIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerNormal);
      backgroundColor = widget.speakerIcon?.backgroundColor ??
          controlBarButtonCheckedBackgroundColor;
    } else {
      icon = widget.headphoneIcon?.icon ??
          UIKitImage.asset(StyleIconUrls.iconS1ControlBarSpeakerOff);
      backgroundColor = widget.headphoneIcon?.backgroundColor ??
          controlBarButtonBackgroundColor;
    }

    Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: icon,
        ),
      ),
    );
  }

  void onPressed() {
    var audioRoute = ZegoUIKit()
        .getAudioOutputDeviceNotifier(ZegoUIKit().getLocalUser().id)
        .value;
    if (ZegoAudioRoute.Headphone == audioRoute ||
        ZegoAudioRoute.Bluetooth == audioRoute) {
      ///  not support close
      return;
    }

    var targetState = audioRoute != ZegoAudioRoute.Speaker;

    ZegoUIKit().setAudioOutputToSpeaker(targetState);

    if (widget.onPressed != null) {
      widget.onPressed!(targetState);
    }
  }
}
