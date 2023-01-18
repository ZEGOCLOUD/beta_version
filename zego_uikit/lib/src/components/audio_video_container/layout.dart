// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'layout_gallery.dart';
import 'layout_picture_in_picture.dart';
import 'picture_in_picture/defines.dart';

/// layout config
/// 1. picture in picture
/// 2. gallery
class ZegoLayout {
  const ZegoLayout.internal();

  factory ZegoLayout.pictureInPicture({
    /// small video view is draggable if set true
    bool isSmallViewDraggable = true,

    ///  Whether you can switch view's position by clicking on the small view
    bool switchLargeOrSmallViewByClick = true,

    /// whether to hide the local View when the local camera is closed
    ZegoViewPosition smallViewPosition = ZegoViewPosition.topRight,
    EdgeInsets? smallViewMargin,

    ///
    Size? smallViewSize,

    ///
    EdgeInsets? spacingBetweenSmallViews,
  }) {
    return ZegoLayoutPictureInPictureConfig(
      isSmallViewDraggable: isSmallViewDraggable,
      switchLargeOrSmallViewByClick: switchLargeOrSmallViewByClick,
      smallViewPosition: smallViewPosition,
      smallViewSize: smallViewSize,
      smallViewMargin: smallViewMargin,
      spacingBetweenSmallViews: spacingBetweenSmallViews,
    );
  }

  factory ZegoLayout.gallery({
    /// whether to display rounded corners and spacing between views
    bool addBorderRadiusAndSpacingBetweenView = true,
  }) {
    return ZegoLayoutGalleryConfig(
      addBorderRadiusAndSpacingBetweenView:
          addBorderRadiusAndSpacingBetweenView,
    );
  }
}
