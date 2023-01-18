import 'dart:async';

import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';

mixin ZegoSignalingPluginCoreEvent {
  List<StreamSubscription> streamSubscriptions = [];
  void initEvent() {
    final plugin = ZegoPluginAdapter().signalingPlugin!;
    streamSubscriptions.addAll([
      plugin.getConnectionStateChangedEventStream().listen(
            ZegoSignalingPluginCore.shared.coreData.onConnectionStateChanged,
          ),
      plugin.getRoomStateChangedEventStream().listen(
            ZegoSignalingPluginCore.shared.coreData.onRoomStateChanged,
          ),
      plugin.getErrorEventStream().listen(
            ZegoSignalingPluginCore.shared.coreData.onError,
          ),
      plugin.getIncomingInvitationReceivedEventStream().listen(
            ZegoSignalingPluginCore
                .shared.coreData.onIncomingInvitationReceived,
          ),
      plugin.getIncomingInvitationCancelledEventStream().listen(
            ZegoSignalingPluginCore
                .shared.coreData.onIncomingInvitationCancelled,
          ),
      plugin.getOutgoingInvitationAcceptedEventStream().listen(
            ZegoSignalingPluginCore
                .shared.coreData.onOutgoingInvitationAccepted,
          ),
      plugin.getOutgoingInvitationRejectedEventStream().listen(
            ZegoSignalingPluginCore
                .shared.coreData.onOutgoingInvitationRejected,
          ),
      plugin.getIncomingInvitationTimeoutEventStream().listen(
            ZegoSignalingPluginCore.shared.coreData.onIncomingInvitationTimeout,
          ),
      plugin.getOutgoingInvitationTimeoutEventStream().listen(
            ZegoSignalingPluginCore.shared.coreData.onOutgoingInvitationTimeout,
          ),
    ]);
  }

  void uninitEvent() {
    streamSubscriptions.forEach((element) {
      element.cancel();
    });
  }
}
