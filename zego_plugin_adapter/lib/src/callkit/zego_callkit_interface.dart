import 'dart:core';

import 'package:zego_plugin_adapter/src/defines.dart';

/// For all apis and events, See mixins.
abstract class ZegoCallKitInterface with IZegoUIKitPlugin {
  /// init
  Future<void> init({
    required int appID,
    String appSign = '',
  });

  /// uninit
  Future<void> uninit();
}
