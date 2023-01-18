import 'package:flutter/foundation.dart';

import 'package:zego_plugin_adapter/src/adapter.dart';

export 'defines.dart';
export 'signaling/signaling.dart';
export 'callkit/callkit.dart';

class ZegoPluginAdapterImpl {
  final plugins = Map<ZegoUIKitPluginType, IZegoUIKitPlugin?>.fromIterable(
    ZegoUIKitPluginType.values,
    key: (type) => type,
    value: (type) => null,
  );

  String getVersion() => 'adapter:1.0.0';

  void installPlugins(List<IZegoUIKitPlugin> instances) {
    for (final item in instances) {
      final itemType = item.getPluginType();
      if (plugins[itemType] != null) {
        debugPrint('plugin type:$itemType already exists '
            '(${plugins[itemType].hashCode}), '
            'will update plugin instance ${item.hashCode}');
      }
      plugins[itemType] = item;
    }
  }

  ZegoSignalingPluginInterface? get signalingPlugin {
    final ret =
        plugins[ZegoUIKitPluginType.signaling] as ZegoSignalingPluginInterface?;
    if (ret == null) {
      debugPrint('signalingPlugin is null');
    }
    return ret;
  }

  ZegoCallKitInterface? get callkit {
    final ret = plugins[ZegoUIKitPluginType.callkit] as ZegoCallKitInterface?;
    if (ret == null) {
      debugPrint('callkit is null');
    }
    return ret;
  }

  IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type) {
    debugPrint('getPlugin: $type');
    return plugins[type];
  }
}
