// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

typedef ZegoInRoomMessageItemBuilder = Widget Function(
    BuildContext context, ZegoInRoomMessage message, Map extraInfo);

typedef ZegoNotificationUserItemBuilder = Widget Function(
    BuildContext context, ZegoUIKitUser user, Map extraInfo);

typedef ZegoNotificationMessageItemBuilder = Widget Function(
    BuildContext context, ZegoInRoomMessage message, Map extraInfo);

enum NotificationItemType {
  userJoin,
  userLeave,
  message,
}
