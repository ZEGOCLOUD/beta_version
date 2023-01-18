part of '../zego_signaling_plugin_interface.dart';

mixin ZegoSignalingPluginInvitationAPI {
  Future<ZegoSignalingPluginSendInvitationResult> sendInvitation({
    required List<String> invitees,
    required int timeout,
    String extendedData = '',
    ZegoSignalingPluginNotificationConfig? notificationConfig,
  });

  Future<ZegoSignalingPluginCancelInvitationResult> cancelInvitation({
    required String invitationID,
    required List<String> invitees,
    String extendedData = '',
  });

  Future<ZegoSignalingPluginResponseInvitationResult> refuseInvitation({
    required String invitationID,
    String extendedData = '',
  });

  Future<ZegoSignalingPluginResponseInvitationResult> acceptInvitation({
    required String invitationID,
    String extendedData = '',
  });
}

mixin ZegoSignalingPluginInvitationEvent {
  Stream<ZegoSignalingPluginIncomingInvitationReceivedEvent>
      getIncomingInvitationReceivedEventStream();
  Stream<ZegoSignalingPluginIncomingInvitationCancelledEvent>
      getIncomingInvitationCancelledEventStream();
  Stream<ZegoSignalingPluginOutgoingInvitationAcceptedEvent>
      getOutgoingInvitationAcceptedEventStream();
  Stream<ZegoSignalingPluginOutgoingInvitationRejectedEvent>
      getOutgoingInvitationRejectedEventStream();
  Stream<ZegoSignalingPluginIncomingInvitationTimeoutEvent>
      getIncomingInvitationTimeoutEventStream();
  Stream<ZegoSignalingPluginOutgoingInvitationTimeoutEvent>
      getOutgoingInvitationTimeoutEventStream();
}
