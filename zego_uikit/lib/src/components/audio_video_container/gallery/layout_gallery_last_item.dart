// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

class ZegoLayoutGalleryLastItem extends StatefulWidget {
  const ZegoLayoutGalleryLastItem({
    Key? key,
    required this.users,
    this.borderColor,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  final List<ZegoUIKitUser> users;
  final Color? borderColor;
  final double? borderRadius;
  final Color? backgroundColor;

  @override
  State<ZegoLayoutGalleryLastItem> createState() =>
      _ZegoLayoutGalleryLastItemState();
}

class _ZegoLayoutGalleryLastItemState extends State<ZegoLayoutGalleryLastItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!)
            : null,
        borderRadius: widget.borderRadius != null
            ? BorderRadius.all(Radius.circular(widget.borderRadius!))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          avatarUsers(),
          SizedBox(height: 16.r),
          hints(),
        ],
      ),
    );
  }

  Widget hints() {
    return Text(
      "${widget.users.length} others",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.r,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget avatarUsers() {
    var firstUser = widget.users.first;
    var lastUser = widget.users.last;

    return SizedBox.fromSize(
      size: Size(212.r, 120.r),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: avatarUser(context, firstUser, false),
          ),
          Positioned(
            top: 0,
            left: 92.r,
            child: avatarUser(context, lastUser, true),
          ),
        ],
      ),
    );
  }

  Widget avatarUser(
    BuildContext context,
    ZegoUIKitUser user,
    bool withBorderColor,
  ) {
    return SizedBox.fromSize(
      size: Size(120.r, 120.r),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffDBDDE3),
          shape: BoxShape.circle,
          border: Border.all(
              color: withBorderColor
                  ? const Color(0xff4A4B4D)
                  : Colors.transparent,
              width: 0.89.r),
        ),
        child: Center(
          child: Text(
            user.name.isNotEmpty ? user.name.characters.first : "",
            style: TextStyle(
              fontSize: 46.r,
              fontWeight: FontWeight.w600,
              color: const Color(0xff222222),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
