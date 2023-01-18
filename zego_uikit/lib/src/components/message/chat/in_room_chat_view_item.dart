// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoInRoomChatViewItem extends StatefulWidget {
  const ZegoInRoomChatViewItem({
    Key? key,
    required this.message,
    required this.avatarBuilder,
  }) : super(key: key);

  final ZegoInRoomMessage message;
  final ZegoAvatarBuilder? avatarBuilder;

  @override
  State<ZegoInRoomChatViewItem> createState() => _ZegoCallMessageListState();
}

class _ZegoCallMessageListState extends State<ZegoInRoomChatViewItem> {
  bool isLocalSender = false;

  @override
  void initState() {
    super.initState();

    isLocalSender = widget.message.user.id == ZegoUIKit().getLocalUser().id;
  }

  @override
  Widget build(BuildContext context) {
    var rowItems = [
      avatar(),
      SizedBox(width: 24.r),
      Column(
        crossAxisAlignment:
            isLocalSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          topInfo(),
          SizedBox(height: 6.r),
          content(),
        ],
      ),
    ];

    return Row(
      mainAxisAlignment:
          isLocalSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isLocalSender ? List.from(rowItems.reversed) : rowItems,
    );
  }

  Widget avatar() {
    return widget.avatarBuilder
            ?.call(context, Size(56.r, 56.r), widget.message.user, {}) ??
        circleName(context, Size(56.r, 56.r), widget.message.user);
  }

  Widget content() {
    var items = [
      contentMessage(),
      SizedBox(width: 14.r),
      contentState(),
    ];
    return Row(
      children: isLocalSender ? List.from(items.reversed) : items,
    );
  }

  Widget contentMessage() {
    return IntrinsicWidth(
      //  automatic shrinkage width
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 530.r,
          minHeight: 40.r,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isLocalSender
                ? const Color(0xff0055FF)
                : const Color(0xff4b4d47),
            borderRadius: BorderRadius.all(Radius.circular(18.r)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 28.0.r, vertical: 18.0.r),
          child: Align(
            alignment: isLocalSender ? Alignment.topRight : Alignment.topLeft,
            child: GestureDetector(
              child: Text(
                widget.message.message,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.r,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: widget.message.message));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget contentState() {
    if (ZegoInRoomMessageState.idle == widget.message.state.value ||
        ZegoInRoomMessageState.success == widget.message.state.value) {
      return Container();
    }

    return ValueListenableBuilder<ZegoInRoomMessageState>(
      valueListenable: widget.message.state,
      builder: (context, state, _) {
        if (ZegoInRoomMessageState.idle == widget.message.state.value ||
            ZegoInRoomMessageState.success == widget.message.state.value) {
          return Container();
        }

        String imageUrl = "";
        switch (widget.message.state.value) {
          case ZegoInRoomMessageState.sending:
            imageUrl = StyleIconUrls.messageLoading;
            break;
          case ZegoInRoomMessageState.failed:
            imageUrl = StyleIconUrls.messageFail;
            break;
          default:
            break;
        }

        return GestureDetector(
          onTap: () {
            if (widget.message.state.value == ZegoInRoomMessageState.failed) {
              ZegoUIKit().resendInRoomMessage(widget.message);
            }
          },
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: UIKitImage.asset(imageUrl).image,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget topInfo() {
    var sendTime =
        DateTime.fromMillisecondsSinceEpoch(widget.message.timestamp);
    var formatSendTime =
        "${sendTime.hour > 12 ? "P.M:" : "A.M"} ${sendTime.hour}:${sendTime.minute}";

    var topInfoChildren = [
      Text(
        widget.message.user.name,
        style: TextStyle(
          color: const Color(0xffCDCDCD),
          fontSize: 24.r,
          fontWeight: FontWeight.w400,
        ),
      ),
      SizedBox(width: 14.r),
      Text(
        formatSendTime,
        style: TextStyle(
          color: const Color(0xffA4A4A4),
          fontSize: 24.r,
          fontWeight: FontWeight.w400,
        ),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children:
          isLocalSender ? List.from(topInfoChildren.reversed) : topInfoChildren,
    );
  }

  Widget circleName(BuildContext context, Size size, ZegoUIKitUser? user) {
    var userName = user?.name ?? "";
    return Container(
      width: size.width,
      height: size.height,
      decoration:
          const BoxDecoration(color: Color(0xffDBDDE3), shape: BoxShape.circle),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName.characters.first : "",
          style: TextStyle(
            fontSize: 24.r,
            fontWeight: FontWeight.w600,
            color: const Color(0xff222222),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
