// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_logs/flutter_logs.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/plugins.dart';
import 'package:zego_uikit/src/services/defines/defines.dart';
import 'package:zego_uikit/src/services/internal/internal.dart';

part 'room_service.dart';

part 'message_service.dart';

part 'custom_command_service.dart';

part 'device_service.dart';

part 'user_service.dart';

part 'audio_video_service.dart';

part 'effect_service.dart';

part 'plugin_service.dart';

part 'logger_service.dart';

class ZegoUIKit
    with
        ZegoAudioVideoService,
        ZegoRoomService,
        ZegoUserService,
        ZegoMessageService,
        ZegoCustomCommandService,
        ZegoDeviceService,
        ZegoEffectService,
        ZegoPluginService,
        ZegoLoggerService {
  factory ZegoUIKit() => instance;
  ZegoUIKit._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }
  static final ZegoUIKit instance = ZegoUIKit._internal();

  /// version
  Future<String> getZegoUIKitVersion() async {
    return ZegoUIKitCore.shared.getZegoUIKitVersion();
  }

  /// init
  Future<void> init(
      {required int appID,
      String appSign = '',
      ZegoScenario scenario = ZegoScenario.Default,
      String tokenServerUrl = ''}) async {
    return ZegoUIKitCore.shared.init(
        appID: appID,
        appSign: appSign,
        scenario: scenario,
        tokenServerUrl: tokenServerUrl);
  }

  /// uninit
  Future<void> uninit() async {
    return ZegoUIKitCore.shared.uninit();
  }
}
