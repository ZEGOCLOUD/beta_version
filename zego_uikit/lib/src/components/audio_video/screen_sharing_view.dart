// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

// Project imports:
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'defines.dart';

const isScreenSharingExtraInfoKey = "isScreenSharing";

/// display user screensharing information,
/// and z order of widget(from bottom to top) is:
/// 1. background view
/// 2. screen sharing view
/// 3. foreground view
class ZegoScreenSharingView extends StatefulWidget {
  const ZegoScreenSharingView({
    Key? key,
    required this.user,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.borderRadius,
    this.borderColor = const Color(0xffA4A4A4),
    this.extraInfo = const {},
  }) : super(key: key);

  final ZegoUIKitUser? user;

  /// foreground builder, you can display something you want on top of the view,
  /// foreground will always show
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder, you can display something when user close camera
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final Color borderColor;
  final Map extraInfo;

  @override
  State<ZegoScreenSharingView> createState() => _ZegoScreenSharingViewState();
}

class _ZegoScreenSharingViewState extends State<ZegoScreenSharingView> {
  @override
  Widget build(BuildContext context) {
    return circleBorder(
      child: Stack(
        children: [
          background(),
          videoView(),
          foreground(),
        ],
      ),
    );
  }

  Widget videoView() {
    if (widget.user == null) {
      return Container(color: Colors.transparent);
    }

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder<Widget?>(
            valueListenable: ZegoUIKit().getAudioVideoViewNotifier(
              widget.user!.id,
              isMainStream: false,
            ),
            builder: (context, userView, _) {
              if (userView == null) {
                /// hide view when use not found
                return Container(color: Colors.transparent);
              }

              return StreamBuilder(
                stream: NativeDeviceOrientationCommunicator()
                    .onOrientationChanged(),
                builder: (context,
                    AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
                  if (asyncResult.hasData) {
                    /// Do not update ui when ui is building !!!
                    /// use postFrameCallback to update videoSize
                    WidgetsBinding.instance?.addPostFrameCallback((_) {
                      ///  notify sdk to update video render orientation
                      ZegoUIKit().updateAppOrientation(
                        deviceOrientationMap(asyncResult.data!),
                      );
                    });
                  }

                  return userView;
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget background() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            widget.backgroundBuilder?.call(
                  context,
                  Size(constraints.maxWidth, constraints.maxHeight),
                  widget.user,
                  {
                    ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name:
                        true,
                    ...widget.extraInfo
                  },
                ) ??
                Container(color: Colors.red), //test
          ],
        );
      },
    );
  }

  Widget foreground() {
    return LayoutBuilder(builder: ((context, constraints) {
      return Container(
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    userName(
                      context,
                      constraints.maxWidth * 0.8,
                    ),
                  ],
                ),
              ),
            ),
            widget.foregroundBuilder?.call(
                  context,
                  Size(constraints.maxWidth, constraints.maxHeight),
                  widget.user,
                  {
                    ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name:
                        true,
                    ...widget.extraInfo
                  },
                ) ??
                Container(),
          ],
        ),
      );
    }));
  }

  Widget circleBorder({required Widget child}) {
    if (widget.borderRadius == null) {
      return child;
    }

    BoxDecoration decoration = BoxDecoration(
      border: Border.all(color: widget.borderColor, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
    );

    return Container(
      decoration: decoration,
      child: PhysicalModel(
        color: widget.borderColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor: widget.borderColor.withOpacity(0.3),
        child: child,
      ),
    );
  }

  Widget userName(BuildContext context, double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Text(
        widget.user?.name ?? "",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 24.0.r,
          color: const Color(0xffffffff),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
