// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/defines.dart';

/// text button
/// icon button
/// text+icon button
class ZegoTextIconButton extends StatefulWidget {
  final String? text;
  final TextStyle? textStyle;
  final bool? softWrap;

  final ButtonIcon? icon;
  final Size? iconSize;
  final double? iconTextSpacing;
  final Color? iconBorderColor;

  final Size? buttonSize;
  final double? buttonRadius;

  final VoidCallback? onPressed;
  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  final bool verticalLayout;

  const ZegoTextIconButton({
    Key? key,
    this.text,
    this.textStyle,
    this.softWrap,
    this.icon,
    this.iconTextSpacing,
    this.iconSize,
    this.iconBorderColor,
    this.buttonSize,
    this.buttonRadius,
    this.onPressed,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
    this.verticalLayout = true,
  }) : super(key: key);

  @override
  State<ZegoTextIconButton> createState() => _ZegoTextIconButtonState();
}

class _ZegoTextIconButtonState extends State<ZegoTextIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: widget.buttonSize?.width ?? 120.r,
        height: widget.buttonSize?.height ?? 120.r,
        decoration: BoxDecoration(
          color: widget.onPressed != null
              ? widget.clickableBackgroundColor
              : widget.unclickableBackgroundColor,
          borderRadius: null != widget.buttonRadius
              ? BorderRadius.all(Radius.circular(widget.buttonRadius!))
              : null,
          shape: null != widget.buttonRadius
              ? BoxShape.rectangle
              : BoxShape.circle,
        ),
        child: widget.verticalLayout
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children(context),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children(context),
              ),
      ),
    );
  }

  List<Widget> children(BuildContext context) {
    return [
      icon(),
      ...text(),
    ];
  }

  Widget icon() {
    if (widget.icon == null) {
      return Container();
    }

    return Container(
      width: widget.iconSize?.width ?? 74.r,
      height: widget.iconSize?.height ?? 74.r,
      decoration: BoxDecoration(
        color: widget.icon?.backgroundColor ?? Colors.transparent,
        border: Border.all(
            color: widget.iconBorderColor ?? Colors.transparent, width: 1),
        borderRadius: BorderRadius.all(
            Radius.circular(widget.iconSize?.width ?? 74.r / 2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.iconSize?.width ?? 74.r / 2),
        child: widget.icon?.icon,
      ),
    );
  }

  List<Widget> text() {
    if (widget.text == null || widget.text!.isEmpty) {
      return [Container()];
    }

    return [
      widget.verticalLayout
          ? SizedBox(height: widget.iconTextSpacing ?? 12.r)
          : SizedBox(width: widget.iconTextSpacing ?? 12.r),
      Text(
        widget.text!,
        softWrap: widget.softWrap,
        style: widget.textStyle ??
            TextStyle(
              color: widget.onPressed != null
                  ? widget.clickableTextColor
                  : widget.unclickableTextColor,
              fontSize: 26.r,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
      ),
    ];
  }

  void onPressed() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }
}
