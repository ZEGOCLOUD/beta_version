library zego_plugin_adapter;

import 'package:flutter/material.dart';

import 'package:zego_plugin_adapter/src/adapter.dart';

export 'src/adapter.dart';

class ZegoPluginAdapter {
  factory ZegoPluginAdapter() => instance;
  ZegoPluginAdapter._internal() {
    WidgetsFlutterBinding.ensureInitialized();
    _impl = ZegoPluginAdapterImpl();
  }
  late final ZegoPluginAdapterImpl _impl;
  static final ZegoPluginAdapter instance = ZegoPluginAdapter._internal();

  String getVersion() {
    return _impl.getVersion();
  }

  void installPlugins(List<IZegoUIKitPlugin> instances) {
    _impl.installPlugins(instances);
  }

  IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type) {
    return _impl.getPlugin(type);
  }

  ZegoSignalingPluginInterface? get signalingPlugin => _impl.signalingPlugin;

  ZegoCallKitInterface? get callkit => _impl.callkit;
}
