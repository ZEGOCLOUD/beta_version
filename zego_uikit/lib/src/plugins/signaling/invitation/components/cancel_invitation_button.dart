// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoCancelInvitationButton extends StatefulWidget {
  const ZegoCancelInvitationButton({
    Key? key,
    required this.invitees,
    this.text,
    this.textStyle,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.iconTextSpacing,
    this.verticalLayout = true,
    this.onPressed,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  }) : super(key: key);
  final List<String> invitees;

  final String? text;
  final TextStyle? textStyle;
  final ButtonIcon? icon;

  final Size? iconSize;
  final Size? buttonSize;
  final double? iconTextSpacing;
  final bool verticalLayout;

  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  ///  You can do what you want after pressed.
  final void Function(String code, String message, List<String>)? onPressed;

  @override
  State<ZegoCancelInvitationButton> createState() =>
      _ZegoCancelInvitationButtonState();
}

class _ZegoCancelInvitationButtonState
    extends State<ZegoCancelInvitationButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: onPressed,
      text: widget.text,
      textStyle: widget.textStyle,
      icon: widget.icon,
      iconTextSpacing: widget.iconTextSpacing,
      iconSize: widget.iconSize,
      buttonRadius: widget.buttonSize?.width ?? 0 / 2,
      buttonSize: widget.buttonSize,
      verticalLayout: widget.verticalLayout,
      clickableTextColor: widget.clickableTextColor,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
    );
  }

  void onPressed() async {
    final result = await ZegoUIKit()
        .getSignalingPlugin()
        .cancelInvitation(invitees: widget.invitees, data: '');

    widget.onPressed?.call(
      result.error?.code ?? '',
      result.error?.message ?? '',
      result.errorInvitees,
    );
  }
}
