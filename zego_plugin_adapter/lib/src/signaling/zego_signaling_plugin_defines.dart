import 'package:flutter/services.dart';

import 'package:zego_plugin_adapter/src/signaling/zego_signaling_plugin_enums.dart';

class ZegoSignalingPluginRoomPropertiesOperationResult {
  const ZegoSignalingPluginRoomPropertiesOperationResult({
    required this.errorKeys,
    this.error,
  });

  final PlatformException? error;
  final List<String> errorKeys;

  @override
  String toString() => '{errorKeys: $errorKeys, error: $error}';
}

class ZegoSignalingPluginConnectUserResult {
  const ZegoSignalingPluginConnectUserResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginDisconnectUserResult {
  const ZegoSignalingPluginDisconnectUserResult({
    required this.timeout,
  });

  final bool timeout;

  @override
  String toString() => '{timeout: $timeout}';
}

class ZegoSignalingPluginRenewTokenResult {
  const ZegoSignalingPluginRenewTokenResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginInvitationResult {
  const ZegoSignalingPluginInvitationResult({
    this.error,
    required this.invitationID,
    required this.errorInvitees,
  });

  final PlatformException? error;
  final String invitationID;
  final List<String> errorInvitees;

  @override
  String toString() => '{error: $error, '
      'invitationID: $invitationID, '
      'errorInvitees: $errorInvitees}';
}

class ZegoSignalingPluginSetUsersInRoomAttributesResult {
  const ZegoSignalingPluginSetUsersInRoomAttributesResult({
    this.error,
    required this.errorUserList,
    required this.attributes,
    required this.errorKeys,
  });

  final PlatformException? error;
  final List<String> errorUserList;

  // key: userID, value: attributes
  final Map<String, Map<String, String>> attributes;

  // key: userID, value: error keys
  final Map<String, List<String>> errorKeys;

  @override
  String toString() => '{error: $error, '
      'errorUserList: $errorUserList, '
      'attributes: $attributes, '
      'errorKeys: $errorKeys}';
}

class ZegoSignalingPluginEndRoomBatchOperationResult {
  const ZegoSignalingPluginEndRoomBatchOperationResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginQueryRoomPropertiesResult {
  const ZegoSignalingPluginQueryRoomPropertiesResult({
    this.error,
    required this.properties,
  });

  final PlatformException? error;
  final Map<String, String> properties;

  @override
  String toString() => '{error: $error, '
      'properties: $properties}';
}

class ZegoSignalingPluginQueryUsersInRoomAttributesResult {
  const ZegoSignalingPluginQueryUsersInRoomAttributesResult({
    this.error,
    required this.nextFlag,
    required this.attributes,
  });

  final PlatformException? error;

  // key: userID, value: attributes
  final Map<String, Map<String, String>> attributes;
  final String nextFlag;

  @override
  String toString() => '{error: $error, '
      'nextFlag: $nextFlag, '
      'attributes: $attributes}';
}

class ZegoSignalingPluginNotificationConfig {
  const ZegoSignalingPluginNotificationConfig({
    this.resourceID = '',
    this.title = '',
    this.message = '',
    this.payload = '',
  });

  final String resourceID;
  final String title;
  final String message;
  final String payload;

  @override
  String toString() => '{'
      'title: $title, '
      'message: $message, '
      'payload: $payload, '
      'resourceID: $resourceID'
      '}';
}

class ZegoSignalingPluginSendInvitationResult {
  const ZegoSignalingPluginSendInvitationResult({
    this.error,
    required this.invitationID,
    required this.errorInvitees,
  });

  final PlatformException? error;
  final String invitationID;
  final Map<String, ZegoSignalingPluginCallUserState> errorInvitees;

  @override
  String toString() => '{error: $error, '
      'invitationID: $invitationID, '
      'errorInvitees: $errorInvitees}';
}

class ZegoSignalingPluginCancelInvitationResult {
  const ZegoSignalingPluginCancelInvitationResult({
    this.error,
    required this.errorInvitees,
  });

  final PlatformException? error;
  final List<String> errorInvitees;

  @override
  String toString() => '{error: $error, '
      'errorInvitees: $errorInvitees}';
}

class ZegoSignalingPluginResponseInvitationResult {
  const ZegoSignalingPluginResponseInvitationResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginJoinRoomResult {
  const ZegoSignalingPluginJoinRoomResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginLeaveRoomResult {
  const ZegoSignalingPluginLeaveRoomResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginErrorEvent {
  ZegoSignalingPluginErrorEvent({
    required this.code,
    required this.message,
  });

  final int code;
  final String message;

  @override
  String toString() => '{code: $code, message: $message}';
}

class ZegoSignalingPluginConnectionStateChangedEvent {
  const ZegoSignalingPluginConnectionStateChangedEvent({
    required this.state,
    required this.action,
    required this.extendedData,
  });

  final ZegoSignalingPluginConnectionState state;
  final ZegoSignalingPluginConnectionAction action;
  final Map extendedData;

  @override
  String toString() => '{state: $state, '
      'action: $action, '
      'extendedData: $extendedData}';
}

class ZegoSignalingPluginTokenWillExpireEvent {
  const ZegoSignalingPluginTokenWillExpireEvent({
    required this.second,
  });

  final int second;

  @override
  String toString() => '{second: $second}';
}

class ZegoSignalingPluginIncomingInvitationReceivedEvent {
  const ZegoSignalingPluginIncomingInvitationReceivedEvent({
    required this.invitationID,
    required this.inviterID,
    required this.timeoutSecond,
    required this.extendedData,
  });

  final String invitationID;
  final String inviterID;
  final int timeoutSecond;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviterID: $inviterID, '
      'timeoutSecond: $timeoutSecond, '
      'extendedData: $extendedData}';
}

class ZegoSignalingPluginIncomingInvitationCancelledEvent {
  const ZegoSignalingPluginIncomingInvitationCancelledEvent({
    required this.invitationID,
    required this.inviterID,
    required this.extendedData,
  });

  final String invitationID;
  final String inviterID;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviterID: $inviterID, '
      'extendedData: $extendedData}';
}

class ZegoSignalingPluginOutgoingInvitationAcceptedEvent {
  const ZegoSignalingPluginOutgoingInvitationAcceptedEvent({
    required this.invitationID,
    required this.inviteeID,
    required this.extendedData,
  });

  final String invitationID;
  final String inviteeID;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviteeID: $inviteeID, '
      'extendedData: $extendedData}';
}

class ZegoSignalingPluginOutgoingInvitationRejectedEvent {
  const ZegoSignalingPluginOutgoingInvitationRejectedEvent({
    required this.invitationID,
    required this.inviteeID,
    required this.extendedData,
  });

  final String invitationID;
  final String inviteeID;
  final String extendedData;

  @override
  String toString() => '{invitationID: $invitationID, '
      'inviteeID: $inviteeID, '
      'extendedData: $extendedData}';
}

class ZegoSignalingPluginIncomingInvitationTimeoutEvent {
  const ZegoSignalingPluginIncomingInvitationTimeoutEvent(
      {required this.invitationID});

  final String invitationID;

  @override
  String toString() => '{invitationID: $invitationID}';
}

class ZegoSignalingPluginOutgoingInvitationTimeoutEvent {
  const ZegoSignalingPluginOutgoingInvitationTimeoutEvent({
    required this.invitationID,
    required this.invitees,
  });

  final String invitationID;
  final List<String> invitees;

  @override
  String toString() => '{invitationID: $invitationID, invitees: $invitees}';
}

class ZegoSignalingPluginRoomStateChangedEvent {
  const ZegoSignalingPluginRoomStateChangedEvent({
    required this.roomID,
    required this.state,
    required this.action,
    required this.extendedData,
  });

  final String roomID;
  final ZegoSignalingPluginRoomState state;
  final ZegoSignalingPluginRoomAction action;
  final Map extendedData;

  @override
  String toString() => '{roomID: $roomID, '
      'state: $state, '
      'action: $action, '
      'extendedData: $extendedData}';
}

class ZegoSignalingPluginRoomPropertiesBatchUpdatedEvent {
  const ZegoSignalingPluginRoomPropertiesBatchUpdatedEvent({
    required this.roomID,
    required this.setProperties,
    required this.deleteProperties,
  });

  final String roomID;
  final Map<String, String> setProperties;
  final Map<String, String> deleteProperties;

  @override
  String toString() => '{roomID: $roomID, '
      'setProperties: $setProperties, '
      'deleteProperties: $deleteProperties}';
}

class ZegoSignalingPluginRoomPropertiesUpdatedEvent {
  const ZegoSignalingPluginRoomPropertiesUpdatedEvent({
    required this.roomID,
    required this.setProperties,
    required this.deleteProperties,
  });

  final String roomID;
  final Map<String, String> setProperties;
  final Map<String, String> deleteProperties;

  @override
  String toString() => '{roomID: $roomID, '
      'setProperties: $setProperties, '
      'deleteProperties: $deleteProperties}';
}

class ZegoSignalingPluginUsersInRoomAttributesUpdatedEvent {
  const ZegoSignalingPluginUsersInRoomAttributesUpdatedEvent({
    required this.attributes,
    required this.editorID,
    required this.roomID,
  });

  // key: userID, value: attributes
  final Map<String, Map<String, String>> attributes;
  final String editorID;
  final String roomID;

  @override
  String toString() => '{attributes: $attributes, '
      'editorID: $editorID, '
      'roomID: $roomID}';
}

class ZegoSignalingPluginRoomMemberJoinedEvent {
  const ZegoSignalingPluginRoomMemberJoinedEvent({
    required this.usersID,
    required this.usersName,
    required this.roomID,
  });

  final List<String> usersID;
  final List<String> usersName;
  final String roomID;

  @override
  String toString() => '{usersID: $usersID, '
      'usersName: $usersName, '
      'roomID: $roomID}';
}

class ZegoSignalingPluginRoomMemberLeftEvent {
  const ZegoSignalingPluginRoomMemberLeftEvent({
    required this.usersID,
    required this.usersName,
    required this.roomID,
  });

  final List<String> usersID;
  final List<String> usersName;
  final String roomID;

  @override
  String toString() => '{usersID: $usersID, '
      'usersName: $usersName, '
      'roomID: $roomID}';
}

class ZegoSignalingPluginNotificationRegisteredEvent {
  ZegoSignalingPluginNotificationRegisteredEvent({
    required this.pushID,
    required this.code,
  });

  final String pushID;
  final int code;

  @override
  String toString() => '{pushID: $pushID, '
      'code: $code}';
}

class ZegoSignalingPluginNotificationArrivedEvent {
  ZegoSignalingPluginNotificationArrivedEvent({
    required this.title,
    required this.content,
    required this.extras,
  });

  final String title;
  final String content;
  final Map<String, Object> extras;

  @override
  String toString() => '{title: $title, '
      'content: $content, '
      'extras: $extras}';
}

class ZegoSignalingPluginNotificationClickedEvent {
  ZegoSignalingPluginNotificationClickedEvent({
    required this.title,
    required this.content,
    required this.extras,
  });

  final String title;
  final String content;
  final Map<String, Object> extras;

  @override
  String toString() => '{title: $title, '
      'content: $content, '
      'extras: $extras}';
}

class ZegoSignalingPluginInRoomTextMessageResult {
  const ZegoSignalingPluginInRoomTextMessageResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginEnableNotifyResult {
  const ZegoSignalingPluginEnableNotifyResult({
    this.error,
  });

  final PlatformException? error;

  @override
  String toString() => '{error: $error}';
}

class ZegoSignalingPluginInRoomTextMessage {
  ZegoSignalingPluginInRoomTextMessage({
    required this.text,
    required this.senderUserID,
    required this.orderKey,
    required this.timestamp,
  });

  final String text;
  final String senderUserID;
  final int timestamp;
  final int orderKey;

  @override
  String toString() => '{text: $text, '
      'senderUserID: $senderUserID, '
      'timestamp: $timestamp, '
      'orderKey: $orderKey}';
}

class ZegoSignalingPluginInRoomTextMessageReceivedEvent {
  ZegoSignalingPluginInRoomTextMessageReceivedEvent({
    required this.messages,
    required this.roomID,
  });

  final List<ZegoSignalingPluginInRoomTextMessage> messages;
  final String roomID;

  @override
  String toString() => '{messages: $messages, '
      'roomID: $roomID}';
}
