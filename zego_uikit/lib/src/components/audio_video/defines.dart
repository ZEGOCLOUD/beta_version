// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

/// type of audio video view foreground builder
typedef ZegoAudioVideoViewForegroundBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

/// type of audio video view background builder
typedef ZegoAudioVideoViewBackgroundBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

/// sort
typedef ZegoAudioVideoViewSorter = List<ZegoUIKitUser> Function(
    List<ZegoUIKitUser>);

enum ZegoViewBuilderMapExtraInfoKey {
  isScreenSharingView,
}
