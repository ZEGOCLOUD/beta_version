// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video_view.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'layout.dart';
import 'picture_in_picture/defines.dart';
import 'picture_in_picture/layout_pip_small_item.dart';
import 'picture_in_picture/layout_pip_small_item_list.dart';

/// layout config of picture in picture
class ZegoLayoutPictureInPictureConfig extends ZegoLayout {
  /// small video view is draggable if set true
  bool isSmallViewDraggable;

  ///  Whether you can switch view's position by clicking on the small view
  bool switchLargeOrSmallViewByClick;

  /// default position of small video view
  ZegoViewPosition smallViewPosition;

  EdgeInsets? smallViewMargin;

  ///
  Size? smallViewSize;

  ///
  EdgeInsets? spacingBetweenSmallViews;

  ZegoLayoutPictureInPictureConfig({
    this.isSmallViewDraggable = true,
    this.switchLargeOrSmallViewByClick = true,
    this.smallViewPosition = ZegoViewPosition.topRight,
    this.smallViewMargin,
    this.smallViewSize,
    this.spacingBetweenSmallViews,
  }) : super.internal();
}

/// picture in picture layout
class ZegoLayoutPictureInPicture extends StatefulWidget {
  const ZegoLayoutPictureInPicture({
    Key? key,
    required this.userList,
    required this.layoutConfig,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarConfig,
  }) : super(key: key);

  final List<ZegoUIKitUser> userList;
  final ZegoLayoutPictureInPictureConfig layoutConfig;

  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLayoutPictureInPicture> createState() =>
      _ZegoLayoutPictureInPictureState();
}

class _ZegoLayoutPictureInPictureState
    extends State<ZegoLayoutPictureInPicture> {
  late ZegoViewPosition currentPosition;

  @override
  void initState() {
    super.initState();

    currentPosition = widget.layoutConfig.smallViewPosition;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userList.length > 2) {
      return multiPIP();
    }

    return oneOnOnePIP();
  }

  Widget oneOnOnePIP() {
    var localUser = ZegoUIKit().getLocalUser();

    ZegoUIKitUser? largeViewUser =
        widget.userList.isNotEmpty ? widget.userList[0] : null;
    ZegoUIKitUser? smallViewUser =
        widget.userList.length > 1 ? widget.userList[1] : null;

    return Stack(
      children: [
        largeViewUser == null
            ? Container()
            : LayoutBuilder(builder: (context, constraints) {
                return ZegoAudioVideoView(
                  user: largeViewUser,
                  backgroundBuilder: widget.backgroundBuilder,
                  foregroundBuilder: widget.foregroundBuilder,
                  avatarConfig: widget.avatarConfig,
                );
              }),
        smallViewUser == null
            ? Container()
            : ZegoLayoutPIPSmallItem(
                targetUser: smallViewUser,
                localUser: localUser,
                defaultPosition: widget.layoutConfig.smallViewPosition,
                draggable: widget.layoutConfig.isSmallViewDraggable,
                showOnlyVideo: false,
                onTap: (ZegoUIKitUser? user) {
                  setState(() {
                    if (!widget.layoutConfig.switchLargeOrSmallViewByClick) {
                      return;
                    }

                    var firstUser = widget.userList[0];
                    widget.userList[0] = widget.userList[1];
                    widget.userList[1] = firstUser;
                  });
                },
                size: widget.layoutConfig.smallViewSize,
                margin: widget.layoutConfig.smallViewMargin,
                foregroundBuilder: widget.foregroundBuilder,
                backgroundBuilder: widget.backgroundBuilder,
              ),
      ],
    );
  }

  Widget multiPIP() {
    var largeViewUser = widget.userList[0];
    var smallViewList = widget.userList.sublist(1);

    return Stack(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return ZegoAudioVideoView(
            user: largeViewUser,
            backgroundBuilder: widget.backgroundBuilder,
            foregroundBuilder: widget.foregroundBuilder,
            avatarConfig: widget.avatarConfig,
          );
        }),
        ZegoLayoutPIPSmallItemList(
          targetUsers: smallViewList,
          defaultPosition: widget.layoutConfig.smallViewPosition,
          showOnlyVideo: false,
          onTap: (ZegoUIKitUser clickedUser) {
            setState(() {
              if (!widget.layoutConfig.switchLargeOrSmallViewByClick) {
                return;
              }

              /// swap large view user to small view user
              var largeViewUser = widget.userList[0];
              var indexOfClickedUser = widget.userList
                  .indexWhere((user) => clickedUser.id == user.id);
              widget.userList[0] = clickedUser;
              widget.userList[indexOfClickedUser] = largeViewUser;
            });
          },
          size: widget.layoutConfig.smallViewSize,
          margin: widget.layoutConfig.smallViewMargin,
          spacingBetweenSmallViews:
              widget.layoutConfig.spacingBetweenSmallViews,
          foregroundBuilder: widget.foregroundBuilder,
          backgroundBuilder: widget.backgroundBuilder,
        ),
      ],
    );
  }
}
