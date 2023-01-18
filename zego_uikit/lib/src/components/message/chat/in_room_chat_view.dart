// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/message/defines.dart';
import 'package:zego_uikit/src/components/message/in_room_message_view.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'in_room_chat_view_item.dart';

class ZegoInRoomChatView extends StatefulWidget {
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoInRoomMessageItemBuilder? itemBuilder;
  final ScrollController? scrollController;

  const ZegoInRoomChatView({
    Key? key,
    this.avatarBuilder,
    this.itemBuilder,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ZegoInRoomChatView> createState() => _ZegoInRoomChatViewState();
}

class _ZegoInRoomChatViewState extends State<ZegoInRoomChatView> {
  @override
  Widget build(BuildContext context) {
    return ZegoInRoomMessageView(
      historyMessages: ZegoUIKit().getInRoomMessages(),
      stream: ZegoUIKit().getInRoomMessageListStream(),
      scrollController: widget.scrollController,
      itemBuilder: widget.itemBuilder ??
          (BuildContext context, ZegoInRoomMessage message, _) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 0.0.r, vertical: 20.0.r),
              child: ZegoInRoomChatViewItem(
                avatarBuilder: widget.avatarBuilder,
                message: message,
              ),
            );
          },
    );
  }
}
