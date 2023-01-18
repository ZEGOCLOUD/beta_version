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

class ZegoLayoutPIPSmallItem extends StatefulWidget {
  const ZegoLayoutPIPSmallItem({
    Key? key,
    required this.targetUser,
    required this.localUser,
    required this.defaultPosition,
    required this.draggable,
    required this.showOnlyVideo,
    required this.onTap,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.borderRadius,
    this.size,
    this.margin,
    this.avatarConfig,
  }) : super(key: key);

  final bool draggable;
  final bool showOnlyVideo;
  final ZegoUIKitUser? targetUser;
  final ZegoUIKitUser localUser;
  final ZegoViewPosition defaultPosition;
  final void Function(ZegoUIKitUser? user) onTap;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final EdgeInsets? margin;
  final Size? size;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLayoutPIPSmallItem> createState() => _ZegoLayoutPIPSmallItemState();
}

class _ZegoLayoutPIPSmallItemState extends State<ZegoLayoutPIPSmallItem> {
  late ZegoViewPosition currentPosition;

  Size get designedSize => widget.size ?? Size(190.0.w, 338.0.h);

  double get designedRatio => 9.0 / 16.0;

  @override
  void initState() {
    super.initState();
    currentPosition = widget.defaultPosition;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showOnlyVideo) {
      return ValueListenableBuilder<bool>(
        valueListenable:
            ZegoUIKit().getCameraStateNotifier(widget.targetUser?.id ?? ""),
        builder: (context, cameraEnabled, _) {
          if (cameraEnabled) {
            return view();
          } else {
            return const SizedBox();
          }
        },
      );
    } else {
      return view();
    }
  }

  Widget view() {
    return calculatePosition(
      child: makeDraggable(
        child: GestureDetector(
          onTap: () {
            widget.onTap(widget.targetUser);
          },
          child: AbsorbPointer(
            absorbing: false,
            child: calculateSize(
              user: widget.targetUser,
              child: ZegoAudioVideoView(
                user: widget.targetUser,
                borderRadius: widget.borderRadius ?? 18.0.r,
                backgroundBuilder: widget.backgroundBuilder,
                foregroundBuilder: widget.foregroundBuilder,
                avatarConfig: widget.avatarConfig,
              ),
            ),
          ),
        ),
      ),
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
        EdgeInsets.only(left: 20.r, top: 50.r, right: 20.r, bottom: 30.r);

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

  Widget makeDraggable({required Widget child}) {
    if (!widget.draggable) {
      /// not support
      return child;
    }

    return Draggable(
      feedback: child,
      childWhenDragging: Container(),
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        /// drag finished, update current position
        var size = MediaQuery.of(context).size;
        late ZegoViewPosition targetPosition;
        var centerPos = Offset(size.width / 2, size.height / 2);
        if (offset.dx < centerPos.dx && offset.dy < centerPos.dy) {
          targetPosition = ZegoViewPosition.topLeft;
        } else if (offset.dx >= centerPos.dx && offset.dy < centerPos.dy) {
          targetPosition = ZegoViewPosition.topRight;
        } else if (offset.dx < centerPos.dx && offset.dy >= centerPos.dy) {
          targetPosition = ZegoViewPosition.bottomLeft;
        } else {
          targetPosition = ZegoViewPosition.bottomRight;
        }

        if (targetPosition != currentPosition) {
          setState(() {
            currentPosition = targetPosition;
          });
        }
      },
      child: child,
    );
  }
}
