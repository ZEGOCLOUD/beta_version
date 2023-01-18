// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';
import 'ripple_animation.dart';

/// display sound level value through circular ripples
class ZegoRippleAvatar extends StatefulWidget {
  const ZegoRippleAvatar({
    Key? key,
    required this.user,
    required this.child,
    this.color,
    this.minRadius = 60,
    this.radiusIncrement = 0.2,
  }) : super(key: key);

  final Widget child;

  final ZegoUIKitUser? user;

  /// min radius of ripple
  final double minRadius;

  final Color? color;

  final double radiusIncrement;

  @override
  State<ZegoRippleAvatar> createState() => _ZegoRippleAvatarState();
}

class _ZegoRippleAvatarState extends State<ZegoRippleAvatar> {
  /// subscription of sound level value's stream
  StreamSubscription<double>? soundLevelStreamSubscription;

  /// ripple count notifier
  final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    /// listen subscription
    soundLevelStreamSubscription = ZegoUIKit()
        .getSoundLevelStream(widget.user?.id ?? "")
        .listen(onSoundLevelChanged);
  }

  @override
  void dispose() {
    /// cancel subscription
    soundLevelStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ZegoRippleAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    soundLevelStreamSubscription?.cancel();
    soundLevelStreamSubscription = ZegoUIKit()
        .getSoundLevelStream(widget.user?.id ?? "")
        .listen(onSoundLevelChanged);
  }

  @override
  Widget build(BuildContext context) {
    return RippleAnimation(
      color: widget.color ?? const Color(0xffDBDDE3).withOpacity(0.1),
      minRadius: widget.minRadius,
      radiusIncrement: widget.radiusIncrement,
      countReceiver: countNotifier,
      child: Center(child: widget.child),
    );
  }

  /// update ripple count when the sound level value is updated.
  void onSoundLevelChanged(double value) {
    int newCount = soundLevelConvertToRippleCount(value);
    if (newCount != countNotifier.value) {
      countNotifier.value = newCount;
    }
  }

  /// convert sound level value to ripple count,
  /// the larger sound level, the more ripples.
  int soundLevelConvertToRippleCount(double soundLevel) {
    /// in order to show the wave effect even if the sound wave is small

    /** make (0~100) sound level value to (0,10) ripple count
     * 1~3 => 1
     * 4~6 => 2
     * 7~9 => 3
     * 10~20 => 4
     * 21~30 => 5
     * 31~40 => 6
     * 41~50 => 7
     * 51~65 => 8
     * 66~80 => 9
     * 81~100 => 10
     */
    var currentValue = 0;
    if (soundLevel < 1) {
      currentValue = 0;
    } else if (soundLevel < 3) {
      currentValue = 1;
    } else if (soundLevel < 6) {
      currentValue = 2;
    } else if (soundLevel < 9) {
      currentValue = 3;
    } else if (soundLevel < 20) {
      currentValue = 4;
    } else if (soundLevel < 30) {
      currentValue = 5;
    } else if (soundLevel < 40) {
      currentValue = 6;
    } else if (soundLevel < 50) {
      currentValue = 7;
    } else if (soundLevel < 65) {
      currentValue = 8;
    } else if (soundLevel < 80) {
      currentValue = 9;
    } else if (soundLevel < 100) {
      currentValue = 10;
    }

    return currentValue;
  }
}
