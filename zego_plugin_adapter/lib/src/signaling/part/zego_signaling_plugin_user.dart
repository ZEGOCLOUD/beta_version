part of '../zego_signaling_plugin_interface.dart';

mixin ZegoSignalingPluginUserAPI {
  /// login
  Future<ZegoSignalingPluginConnectUserResult> connectUser({
    required String id,
    String name = '',
    String token = '',
  });

  /// logout
  Future<ZegoSignalingPluginDisconnectUserResult> disconnectUser();

  Future<ZegoSignalingPluginRenewTokenResult> renewToken(String token);
}

mixin ZegoSignalingPluginUserEvent {
  Stream<ZegoSignalingPluginConnectionStateChangedEvent>
      getConnectionStateChangedEventStream();

  Stream<ZegoSignalingPluginTokenWillExpireEvent>
      getTokenWillExpireEventStream();
}
