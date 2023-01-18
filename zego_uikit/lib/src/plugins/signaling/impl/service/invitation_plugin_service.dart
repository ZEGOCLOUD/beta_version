// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoPluginInvitationService {
  /// send invitation to one or more specified users
  /// [invitees] list of invitees.
  /// [timeout] timeout of the call invitation, the unit is seconds
  /// [type] call type
  /// [data] extended field, through which the inviter can carry information to the invitee.
  Future<ZegoSignalingPluginSendInvitationResult> sendInvitation({
    required String inviterName,
    required List<String> invitees,
    required int timeout,
    required int type,
    required String data,
    ZegoNotificationConfig? zegoNotificationConfig,
  }) async {
    invitees.removeWhere((item) => ['', null].contains(item));
    if (invitees.isEmpty) {
      debugPrint('[Error] invitees is empty');
      return const ZegoSignalingPluginSendInvitationResult(
          invitationID: '', errorInvitees: {});
    }

    final extendedData = const JsonEncoder().convert({
      'inviter_name': inviterName,
      'type': type,
      'data': data,
    });

    ZegoSignalingPluginNotificationConfig? pluginNotificationConfig;
    if (ZegoSignalingPluginCore
            .shared.coreData.notifyWhenAppIsInTheBackgroundOrQuit &&
        zegoNotificationConfig?.notifyWhenAppIsInTheBackgroundOrQuit == true) {
      pluginNotificationConfig = ZegoSignalingPluginNotificationConfig(
        resourceID: zegoNotificationConfig!.resourceID,
        title: zegoNotificationConfig.title,
        message: zegoNotificationConfig.message,
        payload: extendedData,
      );
    }

    debugPrint(
        'send invitation: invitees:$invitees, timeout:$timeout, type:$type, '
        'extendedData:$extendedData, '
        'notification config:$zegoNotificationConfig');

    return ZegoSignalingPluginCore.shared.coreData.invite(
      invitees: invitees,
      type: type,
      timeout: timeout,
      extendedData: extendedData,
      notificationConfig: pluginNotificationConfig,
    );
  }

  /// cancel invitation to one or more specified users
  /// [inviteeID] invitee's id
  /// [data] extended field
  Future<ZegoSignalingPluginCancelInvitationResult> cancelInvitation({
    required List<String> invitees,
    required String data,
  }) async {
    invitees.removeWhere((item) => ['', null].contains(item));
    if (invitees.isEmpty) {
      debugPrint('[Error] invitees is empty');
      return ZegoSignalingPluginCancelInvitationResult(
          error: PlatformException(code: '', message: ''),
          errorInvitees: <String>[]);
    }

    final invitationID = ZegoSignalingPluginCore.shared.coreData
        .queryInvitationIDByInviterID(
            ZegoSignalingPluginCore.shared.coreData.currentUserID!);
    debugPrint('cancel invitation: invitationID:$invitationID, '
        'invitees:$invitees, data:$data');

    return ZegoSignalingPluginCore.shared.coreData
        .cancel(invitees, invitationID, data);
  }

  /// invitee reject the call invitation
  /// [inviterID] inviter id, who send invitation
  /// [data] extended field, you can include your reasons such as Declined
  Future<ZegoSignalingPluginResponseInvitationResult> refuseInvitation({
    required String inviterID,
    required String data,
  }) async {
    var invitationID = '';
    Map<String, dynamic>? extendedDataMap;
    try {
      extendedDataMap = jsonDecode(data) as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('refuse invitation, data is not a json:$data');
    } finally {
      if (extendedDataMap?.containsKey('invitation_id') ?? false) {
        invitationID = extendedDataMap!['invitation_id']! as String;
      } else {
        invitationID = ZegoSignalingPluginCore.shared.coreData
            .queryInvitationIDByInviterID(inviterID);
      }
    }

    debugPrint('refuse invitation: invitationID:$invitationID, '
        'inviter id:$inviterID, data:$data');

    if (invitationID.isEmpty) {
      debugPrint('[Error] invitationID is empty');
      return const ZegoSignalingPluginResponseInvitationResult();
    }

    return ZegoSignalingPluginCore.shared.coreData.reject(invitationID, data);
  }

  /// invitee accept the call invitation
  /// [inviterID] inviter id, who send invitation
  /// [data] extended field
  Future<ZegoSignalingPluginResponseInvitationResult> acceptInvitation({
    required String inviterID,
    required String data,
  }) async {
    final invitationID = ZegoSignalingPluginCore.shared.coreData
        .queryInvitationIDByInviterID(inviterID);
    debugPrint(
        'accept invitation: invitationID:$invitationID, inviter id:$inviterID, data:$data');

    if (invitationID.isEmpty) {
      debugPrint('[Error] invitationID is empty');
      return const ZegoSignalingPluginResponseInvitationResult();
    }

    return ZegoSignalingPluginCore.shared.coreData.accept(invitationID, data);
  }

  /// stream callback, notify invitee when call invitation received
  Stream<Map> getInvitationReceivedStream() {
    return ZegoSignalingPluginCore
        .shared.coreData.streamCtrlInvitationReceived.stream;
  }

  /// stream callback, notify invitee if invitation timeout
  Stream<Map> getInvitationTimeoutStream() {
    return ZegoSignalingPluginCore
        .shared.coreData.streamCtrlInvitationTimeout.stream;
  }

  /// stream callback, When the call invitation times out, the invitee does not respond, and the inviter will receive a callback.
  Stream<Map> getInvitationResponseTimeoutStream() {
    return ZegoSignalingPluginCore
        .shared.coreData.streamCtrlInvitationResponseTimeout.stream;
  }

  /// stream callback, notify when call invitation accepted by invitee
  Stream<Map> getInvitationAcceptedStream() {
    return ZegoSignalingPluginCore
        .shared.coreData.streamCtrlInvitationAccepted.stream;
  }

  /// stream callback, notify when call invitation rejected by invitee
  Stream<Map> getInvitationRefusedStream() {
    return ZegoSignalingPluginCore
        .shared.coreData.streamCtrlInvitationRefused.stream;
  }

  /// stream callback, notify when call invitation cancelled by inviter
  Stream<Map> getInvitationCanceledStream() {
    return ZegoSignalingPluginCore
        .shared.coreData.streamCtrlInvitationCanceled.stream;
  }
}
