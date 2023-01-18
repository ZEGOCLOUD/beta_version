enum ZegoSignalingPluginConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

enum ZegoSignalingPluginRoomState {
  disconnected,
  connecting,
  connected,
}

enum ZegoSignalingPluginConnectionAction {
  success,
  activeLogin,
  loginTimeout,
  interrupted,
  kickedOut,
}

enum ZegoSignalingPluginRoomAction {
  success,
  interrupted,
  disconnected,
  roomNotExist,
  activeCreate,
  createFailed,
  activeEnter,
  enterFailed,
  kickedOut,
  connectTimeout,
}

enum ZegoSignalingPluginCallUserState {
  inviting,
  accepted,
  rejected,
  cancelled,
  offline,
  received,
}
