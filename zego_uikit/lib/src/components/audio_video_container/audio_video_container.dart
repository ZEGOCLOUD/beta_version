// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/defines.dart';
import 'package:zego_uikit/src/components/audio_video_container/layout_gallery.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'layout.dart';
import 'layout_picture_in_picture.dart';

/// container of audio video view,
/// it will layout views by layout mode and config
class ZegoAudioVideoContainer extends StatefulWidget {
  const ZegoAudioVideoContainer({
    Key? key,
    required this.layout,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.sortAudioVideo,
    this.avatarConfig,
  }) : super(key: key);

  final ZegoLayout layout;

  /// foreground builder of audio video view
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder of audio video view
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// sorter
  final ZegoAudioVideoViewSorter? sortAudioVideo;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoAudioVideoContainer> createState() =>
      _ZegoAudioVideoContainerState();
}

class _ZegoAudioVideoContainerState extends State<ZegoAudioVideoContainer> {
  List<ZegoUIKitUser> userList = [];
  List<StreamSubscription<dynamic>?> subscriptions = [];

  @override
  void initState() {
    super.initState();

    subscriptions
        .add(ZegoUIKit().getAudioVideoListStream().listen(onStreamListUpdated));
    subscriptions.add(
        ZegoUIKit().getScreenSharingListStream().listen(onStreamListUpdated));
  }

  @override
  void dispose() {
    super.dispose();

    for (var subscription in subscriptions) {
      subscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    updateUserList(
        ZegoUIKit().getAudioVideoList() + ZegoUIKit().getScreenSharingList());

    return StreamBuilder<List<ZegoUIKitUser>>(
      stream: ZegoUIKit().getAudioVideoListStream(),
      builder: (context, snapshot) {
        if (widget.layout is ZegoLayoutPictureInPictureConfig) {
          return pictureInPictureLayout(userList);
        } else if (widget.layout is ZegoLayoutGalleryConfig) {
          return galleryLayout(userList);
        }

        assert(false, "Unimplemented layout");
        return Container();
      },
    );
  }

  /// picture in picture
  Widget pictureInPictureLayout(List<ZegoUIKitUser> userList) {
    return ZegoLayoutPictureInPicture(
      layoutConfig: widget.layout as ZegoLayoutPictureInPictureConfig,
      backgroundBuilder: widget.backgroundBuilder,
      foregroundBuilder: widget.foregroundBuilder,
      userList: userList,
    );
  }

  /// gallery
  Widget galleryLayout(List<ZegoUIKitUser> userList) {
    return ZegoLayoutGallery(
      layoutConfig: widget.layout as ZegoLayoutGalleryConfig,
      backgroundBuilder: widget.backgroundBuilder,
      foregroundBuilder: widget.foregroundBuilder,
      userList: userList,
      maxItemCount: 8,
    );
  }

  void onStreamListUpdated(List<ZegoUIKitUser> streamUsers) {
    setState(() {
      updateUserList(
          ZegoUIKit().getAudioVideoList() + ZegoUIKit().getScreenSharingList());
    });
  }

  void updateUserList(List<ZegoUIKitUser> streamUsers) {
    /// remove if not in stream
    userList.removeWhere((user) =>
        -1 == streamUsers.indexWhere((streamUser) => user.id == streamUser.id));

    /// add if stream added
    for (var streamUser in streamUsers) {
      if (-1 == userList.indexWhere((user) => user.id == streamUser.id)) {
        userList.add(streamUser);
      }
    }

    userList =
        widget.sortAudioVideo?.call(List<ZegoUIKitUser>.from(userList)) ??
            userList;
  }
}
