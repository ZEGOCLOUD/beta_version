// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit/src/plugins/signaling/impl/core/core.dart';

typedef InvitationID = String;

enum InvitationState { error, waiting, accept, refuse, cancel, timeout }

class InvitationUser {
  InvitationUser({required this.userID, required this.state});
  String userID;
  InvitationState state;

  @override
  String toString() {
    return 'userid :$userID, state:$state';
  }
}

class InvitationData {
  InvitationData({
    required this.id,
    required this.inviterID,
    required this.invitees,
    required this.type,
  });
  String id; // invitation ID
  String inviterID;
  List<InvitationUser> invitees;
  int type;

  @override
  String toString() {
    return 'id:$id, type:$type, inviter id:$inviterID, '
        'invitees:${invitees.map((e) => e.toString())}';
  }
}

mixin ZegoSignalingPluginCoreInvitationData {
  String? get _loginUser =>
      ZegoSignalingPluginCore.shared.coreData.currentUserID;

  Map<InvitationID, InvitationData> invitationMap = {};

  void addInvitationData(InvitationData invitationData) {
    debugPrint('[zim] add invitation data ${invitationData.toString()}');
    invitationMap[invitationData.id] = invitationData;
  }

  InvitationData? removeInvitationData(String invitationID) {
    debugPrint('[zim] remove invitation data, invitationID: $invitationID');
    return invitationMap.remove(invitationID);
  }

  InvitationUser? getInvitee(String callID, String userID) {
    for (final invitee
        in invitationMap[callID]?.invitees ?? <InvitationUser>[]) {
      if (invitee.userID == userID) {
        return invitee;
      }
    }

    return null;
  }

  String queryInvitationIDByInviterID(String inviterID) {
    for (final invitationData in invitationMap.values) {
      if (invitationData.inviterID == inviterID) {
        return invitationData.id;
      }
    }

    return '';
  }

  void removeIfAllInviteesDone(String invitationID) {
    var isDone = true;
    for (final invitee
        in invitationMap[invitationID]?.invitees ?? <InvitationUser>[]) {
      if (invitee.state == InvitationState.waiting) {
        isDone = false;
        break;
      }
    }

    if (isDone) {
      removeInvitationData(invitationID);
    }
  }

  void clearInvitationData() {
    invitationMap = {};
  }

  /// invite
  Future<ZegoSignalingPluginSendInvitationResult> invite({
    required int type,
    required List<String> invitees,
    required int timeout,
    String extendedData = '',
    ZegoSignalingPluginNotificationConfig? notificationConfig,
  }) async {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .sendInvitation(
          invitees: invitees,
          timeout: timeout,
          extendedData: extendedData,
          notificationConfig: notificationConfig,
        )
        .then((result) {
      if (result.error == null) {
        debugPrint(
            '[zim] send invitation done, invitationID:${result.invitationID}');

        final invitationData = InvitationData(
          id: result.invitationID,
          inviterID: _loginUser!,
          invitees: invitees
              .map((inviteeID) => InvitationUser(
                    userID: inviteeID,
                    state: InvitationState.waiting,
                  ))
              .toList(),
          type: type,
        );
        addInvitationData(invitationData);

        if (result.errorInvitees.isNotEmpty) {
          var errorMessage = '';
          result.errorInvitees.forEach((id, state) {
            errorMessage += '$id:${state.name};';
            debugPrint('[zim] invite error, $errorMessage');
          });

          final errorUserIDs = result.errorInvitees.keys.toList();
          for (final invitee in invitationData.invitees) {
            if (errorUserIDs.contains(invitee.userID)) {
              invitee.state = InvitationState.error;
            }
          }
          removeIfAllInviteesDone(result.invitationID);
          return ZegoSignalingPluginSendInvitationResult(
            invitationID: result.invitationID,
            errorInvitees: result.errorInvitees,
          );
        } else {
          debugPrint('[zim] invite done, invitationID:${result.invitationID}');
          return result;
        }
      } else {
        debugPrint('[zim] send invitation faild, error: ${result.error}');
      }
      return result;
    });
  }

  /// cancel
  Future<ZegoSignalingPluginCancelInvitationResult> cancel(
      List<String> invitees, String invitationID, String extendedData) async {
    return ZegoPluginAdapter()
        .signalingPlugin!
        .cancelInvitation(
          invitationID: invitationID,
          invitees: invitees,
          extendedData: extendedData,
        )
        .then((result) {
      if (result.error == null) {
        for (final invitee
            in invitationMap[invitationID]?.invitees ?? <InvitationUser>[]) {
          final isCancelUser = invitees.contains(invitee.userID);
          final isCancelError = result.errorInvitees.contains(invitee.userID);
          if (isCancelUser && !isCancelError) {
            invitee.state = InvitationState.cancel;
          } else {
            invitee.state = InvitationState.error;
          }
        }
        removeIfAllInviteesDone(invitationID);

        if (result.errorInvitees.isNotEmpty) {
          for (final element in result.errorInvitees) {
            debugPrint(
                '[zim] cancel invitation error, invitationID:$invitationID, '
                'invitee id:${element.toString()}');
          }
        } else {
          debugPrint(
              '[zim] cancel invitation done, invitationID:$invitationID');
        }
      } else {
        debugPrint('[zim] cancel invitation faild, error:${result.error}');
      }
      return result;
    });
  }

  /// accept
  Future<ZegoSignalingPluginResponseInvitationResult> accept(
      String invitationID, String extendedData) async {
    removeInvitationData(invitationID);

    return ZegoPluginAdapter()
        .signalingPlugin!
        .acceptInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
        )
        .then((result) {
      if (result.error == null) {
        debugPrint('[zim] accept invitation done, invitationID:$invitationID');
      } else {
        debugPrint('[zim] accept invitation faild, error: ${result.error}');
      }
      return result;
    });
  }

  /// reject
  Future<ZegoSignalingPluginResponseInvitationResult> reject(
      String invitationID, String extendedData) async {
    removeInvitationData(invitationID);

    return ZegoPluginAdapter()
        .signalingPlugin!
        .refuseInvitation(
          invitationID: invitationID,
          extendedData: extendedData,
        )
        .then((result) {
      if (result.error == null) {
        debugPrint('[zim] reject invitation done, invitationID:$invitationID');
      } else {
        debugPrint('[zim] reject invitation faild, error: ${result.error}');
      }
      return result;
    });
  }

  // ------- events ------

  // TODO delete these StreamController
  StreamController<Map> streamCtrlInvitationReceived =
      StreamController<Map>.broadcast();
  StreamController<Map> streamCtrlInvitationTimeout =
      StreamController<Map>.broadcast();
  StreamController<Map> streamCtrlInvitationResponseTimeout =
      StreamController<Map>.broadcast();
  StreamController<Map> streamCtrlInvitationAccepted =
      StreamController<Map>.broadcast();
  StreamController<Map> streamCtrlInvitationRefused =
      StreamController<Map>.broadcast();
  StreamController<Map> streamCtrlInvitationCanceled =
      StreamController<Map>.broadcast();

  /// on incoming invitation received
  void onIncomingInvitationReceived(
      ZegoSignalingPluginIncomingInvitationReceivedEvent event) {
    debugPrint('[zim] onIncomingInvitationReceived, $event');

    final extendedMap = jsonDecode(event.extendedData) as Map<String, dynamic>;

    final invitationData = InvitationData(
      id: event.invitationID,
      inviterID: event.inviterID,
      invitees: [
        InvitationUser(
          userID: _loginUser!,
          state: InvitationState.waiting,
        )
      ],
      type: extendedMap['type'] as int,
    );
    if (invitationMap.containsKey(invitationData.id)) {
      ZegoLoggerService.logInfo(
        'call id ${invitationData.id} is exist before',
        tag: 'signal',
        subTag: 'invitation data',
      );

      return;
    }

    addInvitationData(invitationData);

    streamCtrlInvitationReceived.add({
      'inviter': ZegoUIKitUser(
          id: event.inviterID, name: extendedMap['inviter_name'] as String),
      'type': extendedMap['type'] as int,
      'data': extendedMap['data'] as String,
      'invitation_id': event.invitationID,
    });
  }

  void onIncomingInvitationCancelled(
      ZegoSignalingPluginIncomingInvitationCancelledEvent event) {
    //  inviter extendedData
    debugPrint('[zim] onIncomingInvitationCancelled, $event');

    removeInvitationData(event.invitationID);

    streamCtrlInvitationCanceled.add({
      'inviter': ZegoUIKitUser(id: event.inviterID, name: ''),
      'data': event.extendedData,
      'invitation_id': event.invitationID,
    });
  }

  /// on call invitation accepted
  void onOutgoingInvitationAccepted(
      ZegoSignalingPluginOutgoingInvitationAcceptedEvent event) {
    //  inviter extendedData
    debugPrint('[zim] onOutgoingInvitationAccepted, $event');

    getInvitee(event.invitationID, event.inviteeID)?.state =
        InvitationState.accept;
    removeInvitationData(event.invitationID);

    streamCtrlInvitationAccepted.add({
      'invitee': ZegoUIKitUser(id: event.inviteeID, name: ''),
      'data': event.extendedData,
      'invitation_id': event.invitationID,
    });
  }

  /// on call invitation rejected
  void onOutgoingInvitationRejected(
      ZegoSignalingPluginOutgoingInvitationRejectedEvent event) {
    //  inviter extendedData
    debugPrint('[zim] onOutgoingInvitationRejected, $event');

    getInvitee(event.invitationID, event.inviteeID)?.state =
        InvitationState.refuse;
    removeIfAllInviteesDone(event.invitationID);

    streamCtrlInvitationRefused.add({
      'invitee': ZegoUIKitUser(id: event.inviteeID, name: ''),
      'data': event.extendedData,
      'invitation_id': event.invitationID,
    });
  }

  /// on call invitation timeout
  void onIncomingInvitationTimeout(
      ZegoSignalingPluginIncomingInvitationTimeoutEvent event) {
    debugPrint('[zim] onIncomingInvitationTimeout, $event');

    final invitationData = removeInvitationData(event.invitationID);

    streamCtrlInvitationTimeout.add({
      'inviter': ZegoUIKitUser(id: invitationData?.inviterID ?? '', name: ''),
      'data': '',
      'invitation_id': event.invitationID,
    });
  }

  /// on call invitation answered timeout
  void onOutgoingInvitationTimeout(
      ZegoSignalingPluginOutgoingInvitationTimeoutEvent event) {
    debugPrint('[zim] onOutgoingInvitationTimeout, $event');

    for (final invitee
        in invitationMap[event.invitationID]?.invitees ?? <InvitationUser>[]) {
      if (event.invitees.contains(invitee.userID)) {
        invitee.state = InvitationState.timeout;
      }
    }
    removeIfAllInviteesDone(event.invitationID);

    streamCtrlInvitationResponseTimeout.add({
      'invitees': event.invitees
          .map((inviteeID) => ZegoUIKitUser(id: inviteeID, name: ''))
          .toList(),
      'data': '',
      'invitation_id': event.invitationID,
    });
  }
}
