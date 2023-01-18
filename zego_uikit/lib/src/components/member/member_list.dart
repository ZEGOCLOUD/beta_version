// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/camera_state_icon.dart';
import 'package:zego_uikit/src/components/audio_video/microphone_state_icon.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// type of audio video view background builder
typedef ZegoMemberListItemBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser user, Map extraInfo);

/// sort
typedef ZegoMemberListSorter = List<ZegoUIKitUser> Function(
    ZegoUIKitUser localUser, List<ZegoUIKitUser> remoteUsers);

class ZegoMemberList extends StatefulWidget {
  final bool showMicrophoneState;
  final bool showCameraState;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoMemberListItemBuilder? itemBuilder;
  final ZegoMemberListSorter? sortUserList;

  const ZegoMemberList({
    Key? key,
    this.showMicrophoneState = true,
    this.showCameraState = true,
    this.avatarBuilder,
    this.itemBuilder,
    this.sortUserList,
  }) : super(key: key);

  @override
  State<ZegoMemberList> createState() => _ZegoCallMemberListState();
}

class _ZegoCallMemberListState extends State<ZegoMemberList> {
  var usersNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);
  StreamSubscription<dynamic>? userListSubscription;

  @override
  void initState() {
    super.initState();

    usersNotifier.value = ZegoUIKit().getAllUsers();
    userListSubscription =
        ZegoUIKit().getUserListStream().listen(onUserListUpdated);
  }

  @override
  void dispose() {
    super.dispose();

    userListSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ZegoUIKitUser>>(
      valueListenable: usersNotifier,
      builder: (context, _users, child) {
        List<ZegoUIKitUser> remoteUsers = List.from(_users.reversed);
        remoteUsers
            .removeWhere((user) => user.id == ZegoUIKit().getLocalUser().id);

        var users = widget.sortUserList
                ?.call(ZegoUIKit().getLocalUser(), remoteUsers) ??
            [ZegoUIKit().getLocalUser(), ...remoteUsers];
        var itemSize = Size(750.w, 72.h);
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 48.r),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var user = users[index];
            return widget.itemBuilder?.call(context, itemSize, user, {}) ??
                listItem(context, itemSize, user);
          },
        );
      },
    );
  }

  Widget listItem(BuildContext context, Size itemSize, ZegoUIKitUser user) {
    var userName = ZegoUIKit().getLocalUser().id == user.id
        ? "${user.name} "
            "(You)"
        : user.name;
    return Container(
      margin: EdgeInsets.only(bottom: 36.r),
      child: Row(
        children: [
          SizedBox(width: 36.r),
          avatarItem(context, user, widget.avatarBuilder),
          SizedBox(width: 20.r),
          userNameItem(userName),
          const Expanded(child: SizedBox()),
          widget.showMicrophoneState
              ? ZegoMicrophoneStateIcon(
                  targetUser: user,
                  iconMicrophoneOn:
                      UIKitImage.asset(StyleIconUrls.memberMicNormal),
                  iconMicrophoneOff:
                      UIKitImage.asset(StyleIconUrls.memberMicOff),
                  iconMicrophoneSpeaking:
                      UIKitImage.asset(StyleIconUrls.memberMicSpeaking))
              : Container(),
          widget.showCameraState
              ? ZegoCameraStateIcon(
                  targetUser: user,
                  iconCameraOn:
                      UIKitImage.asset(StyleIconUrls.memberCameraNormal),
                  iconCameraOff:
                      UIKitImage.asset(StyleIconUrls.memberCameraOff),
                )
              : Container(),
          SizedBox(width: 34.r)
        ],
      ),
    );
  }

  void onUserListUpdated(List<ZegoUIKitUser> users) {
    usersNotifier.value = users;
  }
}

Widget userNameItem(String name) {
  return Text(
    name,
    style: TextStyle(
      fontSize: 32.0.r,
      color: const Color(0xffffffff),
      decoration: TextDecoration.none,
    ),
  );
}

Widget avatarItem(
  BuildContext context,
  ZegoUIKitUser user,
  ZegoAvatarBuilder? builder,
) {
  return Container(
    width: 72.r,
    height: 72.r,
    decoration:
        const BoxDecoration(color: Color(0xffDBDDE3), shape: BoxShape.circle),
    child: Center(
      child: builder?.call(context, Size(72.r, 72.r), user, {}) ??
          Text(
            user.name.isNotEmpty ? user.name.characters.first : "",
            style: TextStyle(
              fontSize: 32.0.r,
              color: const Color(0xff222222),
              decoration: TextDecoration.none,
            ),
          ),
    ),
  );
}
