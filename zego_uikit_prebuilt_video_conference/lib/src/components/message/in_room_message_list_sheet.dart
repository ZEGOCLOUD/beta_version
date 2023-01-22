// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_video_conference/src/components/icon_defines.dart';

class ZegoVideoConferenceMessageListSheet extends StatefulWidget {
  const ZegoVideoConferenceMessageListSheet({
    Key? key,
    this.avatarBuilder,
    this.itemBuilder,
    this.scrollController,
  }) : super(key: key);

  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoInRoomMessageItemBuilder? itemBuilder;
  final ScrollController? scrollController;

  @override
  State<ZegoVideoConferenceMessageListSheet> createState() =>
      _ZegoVideoConferenceMessageListSheetState();
}

class _ZegoVideoConferenceMessageListSheetState
    extends State<ZegoVideoConferenceMessageListSheet> {
  var focusNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    focusNotifier.addListener(onInputFocusChanged);
  }

  @override
  void dispose() {
    super.dispose();

    focusNotifier.removeListener(onInputFocusChanged);
  }

  @override
  Widget build(BuildContext context) {
    double viewHeight = MediaQuery.of(context).size.height * 0.85;
    double bottomBarHeight = 110.h;
    double headerHeight = 98.h;
    double lineHeight = 1.r;

    return Stack(
      children: [
        header(height: headerHeight),
        Positioned(
          left: 0,
          right: 0,
          top: headerHeight,
          child: Container(height: 1.r, color: Colors.white.withOpacity(0.15)),
        ),
        messageList(
          height: viewHeight -
              headerHeight -
              lineHeight -
              bottomBarHeight -
              lineHeight,
          top: headerHeight + lineHeight,
          lineHeight: lineHeight,
        ),
        bottomBar(height: bottomBarHeight),
      ],
    );
  }

  Widget bottomBar({required double height}) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: ZegoInRoomMessageInput(
        placeHolder: "Send a message to everyone",
        autofocus: false,
        focusNotifier: focusNotifier,
      ),
    );
  }

  Widget messageList({
    required double height,
    required double top,
    required double lineHeight,
  }) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.r),
            // height: height,
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(Size(690.w, height)),
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: Colors.transparent,
                body: ZegoInRoomChatView(
                  avatarBuilder: widget.avatarBuilder,
                  itemBuilder: widget.itemBuilder,
                  scrollController: widget.scrollController,
                ),
              ),
            ),
          ),
          Container(height: lineHeight, color: Colors.white.withOpacity(0.15)),
        ],
      ),
    );
  }

  Widget header({required double height}) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: height,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 70.r,
              height: 70.r,
              child: PrebuiltVideoConferenceImage.asset(
                  PrebuiltVideoConferenceIconUrls.back),
            ),
          ),
          SizedBox(width: 10.r),
          Text(
            "Chat",
            style: TextStyle(
              fontSize: 36.0.r,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  void onInputFocusChanged() {
    if (focusNotifier.value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.scrollController
            ?.jumpTo(widget.scrollController?.position.maxScrollExtent ?? 0);
      });
    }
  }
}

void showMessageSheet(
  BuildContext context, {
  ZegoAvatarBuilder? avatarBuilder,
  ZegoInRoomMessageItemBuilder? itemBuilder,
  ScrollController? scrollController,
  required ValueNotifier<bool> visibleNotifier,
}) {
  visibleNotifier.value = true;

  showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.85,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: ZegoVideoConferenceMessageListSheet(
              avatarBuilder: avatarBuilder,
              itemBuilder: itemBuilder,
              scrollController: scrollController,
            ),
          ),
        ),
      );
    },
  ).then((value) {
    visibleNotifier.value = false;
  });
}