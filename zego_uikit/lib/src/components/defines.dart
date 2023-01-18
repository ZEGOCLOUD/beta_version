// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

class ButtonIcon {
  Widget? icon;
  Color? backgroundColor;

  ButtonIcon({this.icon, this.backgroundColor});
}

enum ZegoAvatarAlignment {
  center,
  start,
  end,
}

typedef ZegoAvatarBuilder = Widget Function(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map extraInfo,
);

class ZegoAvatarConfig {
  final bool? showInAudioMode;
  final bool? showSoundWavesInAudioMode;
  final ZegoAvatarAlignment verticalAlignment;
  final Size? size;
  final Color? soundWaveColor;
  final ZegoAvatarBuilder? builder;

  const ZegoAvatarConfig({
    this.showInAudioMode,
    this.showSoundWavesInAudioMode,
    this.verticalAlignment = ZegoAvatarAlignment.center,
    this.size,
    this.soundWaveColor,
    this.builder,
  });
}
