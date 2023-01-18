enum ZegoUIKitPluginType {
  signaling, // zim, fcm
  beauty, // effects or avatar
  whiteboard, // superboard
  callkit,
}

mixin IZegoUIKitPlugin {
  ZegoUIKitPluginType getPluginType();

  Future<String> getVersion();
}
