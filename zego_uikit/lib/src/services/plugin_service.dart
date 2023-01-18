part of 'uikit_service.dart';

// see IZegoUIKitPlugin
mixin ZegoPluginService {
  /// install plugins
  void installPlugins(List<IZegoUIKitPlugin> plugins) {
    ZegoPluginAdapter().installPlugins(plugins);
  }

  /// get plugin object
  IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type) {
    return ZegoPluginAdapter().getPlugin(type);
  }

  /// signal plugin
  ZegoUIKitSignalingPluginImpl getSignalingPlugin() {
    return ZegoUIKitSignalingPluginImpl.shared;
  }
}
