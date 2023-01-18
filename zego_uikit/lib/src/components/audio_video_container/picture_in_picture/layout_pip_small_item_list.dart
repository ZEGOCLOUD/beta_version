// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video_view.dart';
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/audio_video_container/picture_in_picture/defines.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/services/services.dart';

class ZegoLayoutPIPSmallItemList extends StatefulWidget {
  const ZegoLayoutPIPSmallItemList({
    Key? key,
    required this.targetUsers,
    required this.defaultPosition,
    required this.showOnlyVideo,
    required this.onTap,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.borderRadius,
    this.spacingBetweenSmallViews,
    this.size,
    this.margin,
    this.avatarConfig,
  }) : super(key: key);

  final List<ZegoUIKitUser> targetUsers;
  final ZegoViewPosition defaultPosition;
  final bool showOnlyVideo;
  final void Function(ZegoUIKitUser user) onTap;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final EdgeInsets? spacingBetweenSmallViews;
  final EdgeInsets? margin;
  final Size? size;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLayoutPIPSmallItemList> createState() =>
      _ZegoLayoutPIPSmallItemListState();
}

class _ZegoLayoutPIPSmallItemListState
    extends State<ZegoLayoutPIPSmallItemList> {
  late ZegoViewPosition currentPosition;
  var displayUsersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  Size get designedSize => widget.size ?? Size(139.5.w, 248.0.h);

  double get designedRatio => 9.0 / 16.0;

  @override
  void initState() {
    super.initState();

    currentPosition = widget.defaultPosition;

    listenUsersCameraState();
    onUserCameraStateChanged();
  }

  @override
  void dispose() {
    super.dispose();

    removeListenUsersCameraState();
  }

  @override
  void didUpdateWidget(covariant ZegoLayoutPIPSmallItemList oldWidget) {
    super.didUpdateWidget(oldWidget);

    removeListenUsersCameraState();

    listenUsersCameraState();
    onUserCameraStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    removeListenUsersCameraState();

    listenUsersCameraState();
    onUserCameraStateChanged();

    const maxItemCount = 3;

    return calculatePosition(
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size(
          designedSize.width,
          (maxItemCount - 1) * 16.r + maxItemCount * designedSize.height,
        )),
        //  remove listview padding
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ValueListenableBuilder<List<ZegoUIKitUser>>(
            valueListenable: displayUsersNotifier,
            builder: (context, displayUsers, _) {
              return listview(displayUsers.length > maxItemCount
                  ? displayUsers.sublist(0, maxItemCount)
                  : List<ZegoUIKitUser>.from(displayUsers));
            },
          ),
        ),
      ),
    );
  }

  Widget listview(List<ZegoUIKitUser> userItems) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userItems.length,
      itemBuilder: (context, index) {
        var targetUser = userItems[index];
        return Padding(
          padding: widget.spacingBetweenSmallViews ??
              EdgeInsets.fromLTRB(
                widget.spacingBetweenSmallViews?.left ?? 0,
                widget.spacingBetweenSmallViews?.top ?? 0,
                widget.spacingBetweenSmallViews?.right ?? 0,
                (index == userItems.length - 1)
                    ? 0
                    : widget.spacingBetweenSmallViews?.bottom ?? 16.r,
              ),
          child: SizedBox(
            width: designedSize.width,
            height: designedSize.height,
            child: GestureDetector(
              onTap: () {
                widget.onTap(targetUser);
              },
              child: AbsorbPointer(
                absorbing: false,
                child: calculateSize(
                  user: targetUser,
                  child: ZegoAudioVideoView(
                    user: targetUser,
                    borderRadius: widget.borderRadius ?? 18.0.w,
                    backgroundBuilder: widget.backgroundBuilder,
                    foregroundBuilder: widget.foregroundBuilder,
                    avatarConfig: widget.avatarConfig,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// calculates smallView's size based on current screen
  Widget calculateSize({required ZegoUIKitUser? user, required Widget child}) {
    final portraitBaseSize =
        Size(designedSize.height, designedSize.width); // vertical
    final landscapeBaseSize = designedSize; //  horizontal

    if (user == null) {
      Size defaultSize = Size(
          landscapeBaseSize.height * designedRatio, landscapeBaseSize.height);
      return SizedBox.fromSize(size: defaultSize, child: child);
    } else {
      return ValueListenableBuilder<Size>(
        valueListenable: ZegoUIKit().getVideoSizeNotifier(user.id),
        builder: (context, Size size, _) {
          late double width, height;
          if (size.width > size.height) {
            width = portraitBaseSize.width;
            height = portraitBaseSize.width * designedRatio;
          } else {
            width = landscapeBaseSize.height * designedRatio;
            height = landscapeBaseSize.height;
          }

          return SizedBox(width: width, height: height, child: child);
        },
      );
    }
  }

  /// position container, calculates the coordinates based on current position
  Widget calculatePosition({required Widget child}) {
    var paddingSpace = widget.margin ??
        EdgeInsets.only(left: 24.r, top: 144.r, right: 24.r, bottom: 144.r);

    double? left, top, right, bottom;
    switch (currentPosition) {
      case ZegoViewPosition.topLeft:
        left = paddingSpace.left;
        top = paddingSpace.top;
        break;
      case ZegoViewPosition.topRight:
        right = paddingSpace.right;
        top = paddingSpace.top;
        break;
      case ZegoViewPosition.bottomLeft:
        left = paddingSpace.left;
        bottom = paddingSpace.bottom;
        break;
      case ZegoViewPosition.bottomRight:
        right = paddingSpace.right;
        bottom = paddingSpace.bottom;
        break;
    }

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: child,
    );
  }

  void listenUsersCameraState() {
    if (widget.showOnlyVideo) {
      for (var user in widget.targetUsers) {
        ZegoUIKit()
            .getCameraStateNotifier(user.id)
            .addListener(onUserCameraStateChanged);
      }
    }
  }

  void removeListenUsersCameraState() {
    if (widget.showOnlyVideo) {
      for (var user in widget.targetUsers) {
        ZegoUIKit()
            .getCameraStateNotifier(user.id)
            .removeListener(onUserCameraStateChanged);
      }
    }
  }

  void onUserCameraStateChanged() {
    if (widget.showOnlyVideo) {
      List<ZegoUIKitUser> targetUsers = List.from(widget.targetUsers);
      targetUsers.removeWhere((user) {
        /// hide if user's camera close
        return !ZegoUIKit().getCameraStateNotifier(user.id).value;
      });

      displayUsersNotifier.value = targetUsers;
    } else {
      displayUsersNotifier.value = List.from(widget.targetUsers);
    }
  }
}
